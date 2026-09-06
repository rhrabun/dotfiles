#!/usr/bin/env bash
# backup all repos under ROOT that have a remote named 'backup'

# Metadata for Raycast
# @raycast.schemaVersion 1
# @raycast.title Repos Backup
# @raycast.mode fullOutput
# @raycast.packageName dotfiles

ROOT="${1:-$HOME/code}"
REMOTE="backup"
EXTRA_REPOS=( "$HOME/.local/share/chezmoi" "$HOME/.agents" )

backup() {
  echo "== push $1"
  git -C "$1" push "$REMOTE" --mirror || echo "FAILED: $1"
}

find "$ROOT" -type d -name .git -prune -print | while IFS= read -r g; do
  repo="$(dirname "$g")"
  if git -C "$repo" remote get-url "$REMOTE" >/dev/null 2>&1; then
    backup "$repo"
  fi
done

for repo in "${EXTRA_REPOS[@]}"; do
  if git -C "$repo" remote get-url "$REMOTE" >/dev/null 2>&1; then
    backup "$repo"
  fi
done
