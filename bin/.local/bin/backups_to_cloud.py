#!/usr/bin/env -S uv run --script
#
# /// script
# requires-python = ">=3.12"
# dependencies = ["dirsync", "keyring"]
# ///

"""Backups sync script.

Scripts syncs local backup folder to cloud storage providers (iCloud, ProtonDrive, Google Drive).
Email names are used in Cloud Providers folder names and are stored in keyring to keep outside of code.
"""

import logging
from pathlib import Path

from dirsync import sync
from keyring import get_password, set_password

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)


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


def sync_dir(source_path: Path, target_path: Path, options: dict[str, object]) -> None:
    """Sync a source folder to a target folder.

    Args:
        source_path (Path): Local source directory to sync.
        target_path (Path): Remote or mounted target directory to sync into.
        options (dict[str, object]): Additional options passed to dirsync.sync.
    """
    if not source_path.exists():
        log.error(f"Source path {source_path} does not exist. Skipping sync.")
        raise FileNotFoundError(f"Source path {source_path} does not exist.")
    elif not target_path.exists():
        log.error(f"Target path {target_path} does not exist. Skipping sync.")
        raise FileNotFoundError(f"Target path {target_path} does not exist.")
    else:
        sync(source_path, target_path, "sync", **options)


def main() -> None:
    log.info("Starting backup sync")
    proton_email, google_email = get_emails()

    default_sync_options = {"logger": log, "purge": True, "verbose": False}
    SRC_PATH = Path("~/Backups").expanduser()
    TARGETS = {
        "icloud": {
            "target": "~/Library/Mobile Documents/com~apple~CloudDocs/[98] Backups",
            "options": {},
        },
        "proton": {
            "target": f"~/Library/CloudStorage/ProtonDrive-{proton_email}-folder/[98] Backups",
            "options": {},
        },
        "google": {
            "target": f"~/Library/CloudStorage/GoogleDrive-{google_email}/My Drive/[98] Backups/",
            "options": {"only": (r".*BackupsVault.*",)},
        },
    }

    for target_name, config in TARGETS.items():
        target_path = Path(config["target"]).expanduser()
        options = {**default_sync_options, **config.get("options", {})}

        log.info(f"Syncing to {target_name.capitalize()}")
        sync_dir(SRC_PATH, target_path, options)

    log.info("Backups sync done")


if __name__ == "__main__":
    main()
