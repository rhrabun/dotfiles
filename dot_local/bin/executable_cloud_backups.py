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

"""Backups sync script.

Scripts syncs local backup folder to cloud storage providers (iCloud, ProtonDrive, Google Drive).
Email names are used in Cloud Providers folder names and are stored in keyring to keep outside of code.

UpNote stores each note's content once at the space root and represents notebook
placement with relative symlinks, so moving a note between notebooks is just a
symlink move — no content rewrites, no extra disk usage.

Symlinks in the source (UpNote backup format) are dereferenced into real files, because
cloud providers (ProtonDrive, iCloud) do not sync symlinks.
"""

import logging
import subprocess
from pathlib import Path

from keyring import get_password, set_password

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

RSYNC_OK_CODES = (0, 24)  # 24 = files vanished during transfer, harmless for backups


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
        raise EnvironmentError("Missing required email credentials in keyring.")

    log.info("Retrieved emails from keyring.")

    return proton_email, google_email


def rsync_dir(source_path: Path, target_path: Path, options: list[str]) -> None:
    """Sync source to target with rsync, dereferencing symlinks into real files.

    Args:
        source_path (Path): Local source directory to sync.
        target_path (Path): Remote or mounted target directory to sync into.
        options (list[str]): Extra rsync options (e.g. include/exclude filters).
    """
    if not source_path.is_dir():
        raise FileNotFoundError(f"Source path {source_path} does not exist.")
    if not target_path.is_dir():
        raise FileNotFoundError(f"Target path {target_path} does not exist.")

    cmd = [
        "rsync",
        "-rlt",
        "--copy-links",
        "--delete",
        "--stats",
        *options,
        f"{source_path}/",
        f"{target_path}/",
    ]
    proc = subprocess.run(cmd, capture_output=True, text=True)

    for line in proc.stdout.splitlines():
        log.info(line)
    if proc.returncode not in RSYNC_OK_CODES:
        log.error(
            "rsync to %s failed (rc=%d): %s",
            target_path,
            proc.returncode,
            proc.stderr.strip(),
        )
        raise subprocess.CalledProcessError(proc.returncode, "rsync")


def main() -> None:
    log.info("Starting backup sync")
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
            "options": ["--include=*/", "--include=*BackupsVault*", "--exclude=*"],
        },
    }

    failed = []
    for target_name, config in TARGETS.items():
        target_path = Path(config["target"]).expanduser()
        log.info("")
        log.info("#" * 25)
        log.info(f"Syncing to {target_name.capitalize()}")
        try:
            rsync_dir(SRC_PATH, target_path, config["options"])
        except (FileNotFoundError, subprocess.CalledProcessError) as e:
            log.error("Sync to %s failed: %s", target_name, e)
            failed.append(target_name)

    if failed:
        log.error("Backups sync finished with failures: %s", ", ".join(failed))
        raise SystemExit(1)

    log.info("Backups sync done")


if __name__ == "__main__":
    main()
