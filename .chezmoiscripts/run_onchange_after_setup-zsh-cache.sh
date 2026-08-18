#!/bin/sh
# Ensure ~/.cache/zsh and its history file exist.
set -e

mkdir -p "$HOME/.cache/zsh"
touch "$HOME/.cache/zsh/history"
