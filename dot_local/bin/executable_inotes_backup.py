#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["markdownify==1.2.3"]
# ///

"""Apple Notes backup: consistent store dump plus markdown mirror, both verified.

Layers, neither of which is sufficient alone:

  NoteStore.sqlite  a copy of the live store taken through SQLite's online backup API, so
                    notes edited while Notes is running are included and the WAL cannot
                    tear the snapshot. This is the complete copy: folders, formatting,
                    attachment references, and password-protected notes, which no
                    exporter is able to read.
  notes/            one markdown file per note, for greppable, diffable history. Names are
                    stable (title + note id), so unchanged notes are left untouched and
                    restic only stores the deltas instead of a fresh full copy each day.

Attachments are read live out of Accounts/ (written once, never rewritten in place).
Previews/ and Thumbnails/ sit at the container root, so nothing regenerable is captured.

Reading the container from a launchd job needs Full Disk Access for the binary doing the
read; without it the job dies with "operation not permitted". Run it by hand once first.

Usage:
    inotes_backup.py               stage, verify, then back up to restic
    inotes_backup.py --no-restic   stage and verify only
    inotes_backup.py --verify      restore the latest snapshot back and check it
"""

import argparse
import fcntl
import json
import logging
import os
import re
import shutil
import sqlite3
import subprocess
import sys
import tempfile
from contextlib import closing
from pathlib import Path

from markdownify import markdownify

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger("inotes")

CONTAINER = Path("~/Library/Group Containers/group.com.apple.notes").expanduser()
STAGING = Path("~/Library/Application Support/inotes-backup").expanduser()
DUMP = STAGING / "NoteStore.sqlite"
MIRROR = STAGING / "notes"
LOCK = STAGING / ".lock"
RESTIC_ENV = Path("~/.config/restic/env").expanduser()
KEEP = ("--keep-daily", "14", "--keep-weekly", "8", "--keep-monthly", "24")

READ_NOTES_JS = """
const app = Application("Notes");
const safe = fn => { try { return fn(); } catch (e) { return null; } };

JSON.stringify(app.notes().map(note => ({
    name: safe(() => note.name()),
    id: safe(() => note.id()),
    folder: safe(() => note.container().name()),
    created: safe(() => note.creationDate()),
    modified: safe(() => note.modificationDate()),
    locked: safe(() => note.passwordProtected()) === true,
    body: safe(() => note.body()),
})));
"""


def read_notes() -> list[dict]:
    """Every note as plain dicts, through osascript's JavaScript bridge."""
    proc = subprocess.run(
        ["osascript", "-l", "JavaScript", "-e", READ_NOTES_JS],
        capture_output=True,
        text=True,
        timeout=600,
    )
    if proc.returncode:
        raise RuntimeError(f"osascript failed: {proc.stderr.strip()}")
    return json.loads(proc.stdout)


def verify_store(path: Path) -> int:
    """Integrity-check a note store, return its note row count."""
    with closing(sqlite3.connect(path)) as con:
        result = con.execute("PRAGMA integrity_check").fetchone()[0]
        if result != "ok":
            raise RuntimeError(f"{path}: integrity_check reported {result}")
        return con.execute("SELECT count(*) FROM ZICNOTEDATA").fetchone()[0]


def dump_store(src: Path, dest: Path) -> int:
    """Consistent copy of the live store, verified before it replaces the last good one."""
    tmp = dest.with_name(f"{dest.name}.tmp")
    tmp.unlink(missing_ok=True)
    with closing(sqlite3.connect(src, timeout=30)) as live:
        with closing(sqlite3.connect(tmp)) as copy:
            live.backup(copy)
    try:
        rows = verify_store(tmp)
    except Exception:
        tmp.unlink(missing_ok=True)
        raise
    os.replace(tmp, dest)
    return rows


def note_path(note: dict) -> Path:
    def clean(value: str | None, fallback: str) -> str:
        return re.sub(r"[/:\\\r\n]+", "-", value or "").strip(" .-") or fallback

    title = clean(note.get("name"), "untitled")[:80]
    note_id = (note.get("id") or "").rsplit("/", 1)[-1] or "unknown"
    return MIRROR / clean(note.get("folder"), "Notes") / f"{title} - {note_id}.md"


def render(note: dict) -> str:
    front_matter = {
        "title": note.get("name"),
        "folder": note.get("folder"),
        "created": note.get("created"),
        "modified": note.get("modified"),
        "id": note.get("id"),
        "locked": note.get("locked"),
    }
    body = ""
    if not note.get("locked"):
        body = markdownify(
            note.get("body") or "", heading_style="ATX", strip=["object"]
        ).strip()
    meta = "\n".join(
        f"{key}: {json.dumps(value)}" for key, value in front_matter.items()
    )
    return f"---\n{meta}\n---\n\n{body}\n"


def write_mirror(path: Path, text: str) -> bool:
    """Write only when the content actually changed, atomically."""
    if path.exists() and path.read_text(encoding="utf-8") == text:
        return False
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(f"{path.name}.tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, path)
    return True


def stage_notes(notes: list[dict]) -> tuple[int, int]:
    written = set()
    updated = 0
    for note in notes:
        path = note_path(note)
        written.add(path)
        updated += write_mirror(path, render(note))
    removed = 0
    for stale in MIRROR.rglob("*.md"):
        if stale not in written:
            stale.unlink()
            removed += 1
    return updated, removed


def restic_env() -> dict:
    env = dict(os.environ)
    if RESTIC_ENV.exists():
        for line in RESTIC_ENV.read_text(encoding="utf-8").splitlines():
            line = line.removeprefix("export ").strip()
            if line and not line.startswith("#") and "=" in line:
                key, value = line.split("=", 1)
                env[key.strip()] = value.strip().strip("'\"")
    return env


def restic(env: dict, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    proc = subprocess.run(
        ["restic", *args], env=env, capture_output=True, text=True, timeout=3600
    )
    output = (proc.stdout + proc.stderr).strip()
    if proc.returncode and check:
        raise RuntimeError(f"restic {' '.join(args)} failed: {output}")
    if output:
        log.info("%s", output if len(output) < 2000 else output.splitlines()[-1])
    return proc


def push(env: dict) -> None:
    attachments = CONTAINER / "Accounts"
    if not attachments.exists():
        log.warning("%s is missing, attachments are not in this backup", attachments)
    sources = [str(path) for path in (STAGING, attachments) if path.exists()]
    if restic(env, "cat", "config", check=False).returncode:
        restic(env, "init")
    restic(env, "backup", "--tag", "inotes", *sources)
    restic(env, "forget", "--prune", "--tag", "inotes", *KEEP)


def drill(env: dict) -> None:
    """Restore the last snapshot and prove it opens and is complete."""
    restic(env, "check")
    with tempfile.TemporaryDirectory() as tmp:
        restic(env, "restore", "latest", "--target", tmp, "--include", str(DUMP))
        restored = Path(tmp, *DUMP.parts[1:])
        rows = verify_store(restored)
        listing = (restic(env, "ls", "latest", str(MIRROR)).stdout or "").splitlines()
        files = sum(line.endswith(".md") for line in listing)
    if not rows or not files:
        raise RuntimeError(f"restore drill incomplete: {rows} note rows, {files} files")
    log.info("restore drill ok: %d note rows, %d markdown files", rows, files)


def notify(title: str, message: str) -> None:
    """Best effort, so a failed notification never hides the failure it reports."""
    try:
        subprocess.run(
            [
                "osascript",
                "-e",
                f"display notification {json.dumps(message)} with title {json.dumps(title)}",
            ],
            check=False,
        )
    except OSError as error:
        log.error("could not notify: %s", error)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument(
        "--no-restic", action="store_true", help="stage only, no off-site leg"
    )
    parser.add_argument(
        "--verify", action="store_true", help="restore the latest snapshot"
    )
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    env = restic_env()
    if args.verify:
        drill(env)
        return 0

    STAGING.mkdir(parents=True, exist_ok=True)
    with LOCK.open("w") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)

        notes = read_notes()
        rows = dump_store(CONTAINER / "NoteStore.sqlite", DUMP)
        updated, removed = stage_notes(notes)
        files = sum(1 for _ in MIRROR.rglob("*.md"))
        if rows < files:
            raise RuntimeError(
                f"store holds {rows} note rows but {files} notes were exported"
            )
        locked = sum(1 for note in notes if note.get("locked"))
        log.info(
            "%d notes (%d locked, %d updated, %d removed), %d note rows in store",
            len(notes),
            locked,
            updated,
            removed,
            rows,
        )

        if args.no_restic:
            log.info("staged in %s; off-site leg skipped on request", STAGING)
            return 0
        if not shutil.which("restic"):
            raise RuntimeError("restic is not installed")
        if "RESTIC_REPOSITORY" not in env:
            raise RuntimeError(f"RESTIC_REPOSITORY is not set in {RESTIC_ENV}")
        push(env)

    log.info("backup done")
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as error:  # noqa: BLE001 - the report is the point of a scheduled job
        log.error("%s", error)
        notify("Apple Notes backup failed", str(error))
        sys.exit(1)
