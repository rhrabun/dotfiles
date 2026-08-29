#!/usr/bin/env bash
# backup all repos under ROOT that have a remote named 'backup'

# Metadata for Raycast
# @raycast.schemaVersion 1
# @raycast.title Repos Backup
# @raycast.mode fullOutput
# @raycast.packageName dotfiles

ROOT="${1:-$HOME/code}"
REMOTE="backup"

find "$ROOT" -type d -name .git -prune -print | while IFS= read -r g; do
  repo="$(dirname "$g")"
  if git -C "$repo" remote get-url "$REMOTE" >/dev/null 2>&1; then
    echo "== push $repo"
    git -C "$repo" push "$REMOTE" --mirror || echo "FAILED: $repo"
  fi
done
