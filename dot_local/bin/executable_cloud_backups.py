#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["keyring==25.7.0"]
# ///

# Metadata for Raycast
# @raycast.schemaVersion 1
# @raycast.title Cloud Backups
# @raycast.mode fullOutput
# @raycast.packageName dotfiles

"""Backups snapshot script.

Copies ~/Backups into a dated snapshot folder (YYYY-MM-DD) on each cloud
provider (iCloud, ProtonDrive, Google Drive), then verifies the snapshot with a
checksum comparison.

Email names are used in Cloud Providers folder names and are stored in keyring
to keep outside of code.

Symlinks in the source (UpNote backup format) are dereferenced into real files,
because cloud providers (ProtonDrive, iCloud) do not sync symlinks.
"""

import logging
import shutil
import subprocess
import time
from pathlib import Path

from keyring import get_password, set_password

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

RSYNC_OK_CODES = (0, 24)  # 24 = files vanished during transfer, harmless for backups


def resolve_rsync() -> str:
    """Return the GNU rsync binary path, rejecting macOS openrsync.

    openrsync's ``hash_file_by_path`` fails on symlinks when combined with
    ``--copy-links --checksum``, which breaks the snapshot verification.
    """
    rsync_bin = shutil.which("rsync", path="/opt/homebrew/bin:/usr/local/bin:/usr/bin")
    if not rsync_bin:
        raise FileNotFoundError("rsync not found; install with: brew install rsync")

    version = subprocess.run(
        [rsync_bin, "--version"], capture_output=True, text=True, check=False
    ).stdout
    if "openrsync" in version:
        raise OSError(
            f"GNU rsync required, found openrsync at {rsync_bin}; "
            "install with: brew install rsync"
        )

    log.info("Using rsync at %s", rsync_bin)
    return rsync_bin


def get_emails() -> tuple[str, str]:
    """Retrieve Proton and Google email addresses from the keyring.

    The function reads saved credentials from the keyring service.
    If one or both values are missing, it prompts to set them up

    Returns:
        tuple[str, str]: A tuple containing ``(proton_email, google_email)``.
    """
    SERVICE_NAME = "BACKUPS_PY_SCRIPT"
    proton_email = get_password(SERVICE_NAME, "PROTON_EMAIL")
    google_email = get_password(SERVICE_NAME, "GOOGLE_EMAIL")

    if not proton_email or not google_email:
        log.error("Email credentials not found in keyring.")

        if not proton_email:
            val = str(input("Enter Proton email: "))
            set_password(SERVICE_NAME, "PROTON_EMAIL", val)
            proton_email = get_password(SERVICE_NAME, "PROTON_EMAIL")

        if not google_email:
            val = str(input("Enter Google email: "))
            set_password(SERVICE_NAME, "GOOGLE_EMAIL", val)
            google_email = get_password(SERVICE_NAME, "GOOGLE_EMAIL")

    # If still missing, fail early so caller can handle it
    if not proton_email or not google_email:
        log.error("Failed to store or retrieve email credentials from keyring.")
        raise OSError("Missing required email credentials in keyring.")

    log.info("Retrieved emails from keyring.")

    return proton_email, google_email


def rsync(
    rsync_bin: str,
    source_path: Path,
    target_path: Path,
    options: list[str],
    verify: bool,
) -> subprocess.CompletedProcess:
    """Run rsync from source into an existing target directory.

    verify=False copies into the target (``--delete --stats``).
    verify=True does a checksum dry-run (``--checksum --itemize-changes
    --dry-run``); any stdout line means the target differs from the source.
    """
    if not source_path.is_dir():
        raise FileNotFoundError(f"Source path {source_path} does not exist.")

    cmd = [rsync_bin, "-rlt", "--copy-links", "--delete", "--omit-dir-times"]
    cmd += ["--dry-run", "--checksum", "--itemize-changes"] if verify else ["--stats"]
    cmd += [*options, f"{source_path}/", f"{target_path}/"]
    return subprocess.run(cmd, capture_output=True, text=True, check=False)


def sync_snapshot(
    rsync_bin: str, source_path: Path, base_path: Path, options: list[str]
) -> Path:
    """Copy source into ``<base>/<today>/`` and verify the copy.

    Args:
        source_path (Path): Local source directory to snapshot.
        base_path (Path): Mounted cloud snapshot root (e.g. ``[98] Backups``).
        options (list[str]): Extra rsync options (e.g. include/exclude filters).

    Returns:
        Path: The created snapshot directory.
    """
    if not base_path.is_dir():
        raise FileNotFoundError(f"Target path {base_path} does not exist.")

    snapshot = base_path / time.strftime("%Y-%m-%d")
    snapshot.mkdir(parents=True, exist_ok=True)

    copy = rsync(rsync_bin, source_path, snapshot, options, verify=False)
    for line in copy.stdout.splitlines():
        log.info(line)
    if copy.returncode not in RSYNC_OK_CODES:
        raise subprocess.CalledProcessError(
            copy.returncode, "rsync", copy.stderr.strip()
        )

    check = rsync(rsync_bin, source_path, snapshot, options, verify=True)
    diffs = [line for line in check.stdout.splitlines() if line.strip()]
    if check.returncode not in RSYNC_OK_CODES or diffs:
        raise OSError(
            f"integrity check failed for {snapshot}: {diffs or check.stderr.strip()}"
        )

    log.info("Verified %s", snapshot)
    return snapshot


def main() -> None:
    log.info("Starting backup snapshot")
    rsync_bin = resolve_rsync()
    proton_email, google_email = get_emails()

    SRC_PATH = Path("~/Backups").expanduser()
    TARGETS = {
        "icloud": {
            "target": "~/Library/Mobile Documents/com~apple~CloudDocs/[98] Backups",
            "options": [],
        },
        "proton": {
            "target": f"~/Library/CloudStorage/ProtonDrive-{proton_email}-folder/[98] Backups",
            "options": [],
        },
        "google": {
            "target": f"~/Library/CloudStorage/GoogleDrive-{google_email}/My Drive/[98] Backups/",
            "options": ["--include=BackupsVault/***", "--exclude=*"],
        },
    }

    failed = []
    for target_name, config in TARGETS.items():
        base_path = Path(config["target"]).expanduser()
        log.info("")
        log.info("#" * 25)
        log.info("Syncing to %s", target_name.capitalize())
        try:
            sync_snapshot(rsync_bin, SRC_PATH, base_path, config["options"])
        except (FileNotFoundError, subprocess.CalledProcessError, OSError) as e:
            log.error("Sync to %s failed: %s", target_name, e)
            failed.append(target_name)

    if failed:
        log.error("Backup snapshot finished with failures: %s", ", ".join(failed))
        raise SystemExit(1)

    log.info("Backup snapshot done")


if __name__ == "__main__":
    main()
