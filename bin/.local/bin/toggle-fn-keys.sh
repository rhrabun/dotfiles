#!/bin/zsh

# Metadata for Raycast
# @raycast.schemaVersion 1
# @raycast.title Toggle Mac Function Keys
# @raycast.mode silent
# @raycast.packageName dotfiles

current=$(defaults read -g com.apple.keyboard.fnState 2>/dev/null || echo 0)

if [[ "$current" == "1" ]]; then
    new=false
    message="Special keys enabled"
else
    new=true
    message="Standard function keys enabled"
fi

defaults write -g com.apple.keyboard.fnState -bool "$new"

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

echo "$message"
