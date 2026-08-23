# dotfiles

Configuration files for my local machine, managed with [chezmoi](https://www.chezmoi.io/).

## Prerequisites

* git
* chezmoi

## Setup on a new machine
```sh
chezmoi init --apply https://github.com/rhrabun/dotfiles.git
```
Clones the repo, computes the source → home diffs, and applies them.

> Note: place the age key at `~/.ssh/chezmoi-age-key.txt` (mode 600); it's needed to manage encrypted files.

## Day-to-day commands
| Command | What it does |
|---|---|
| `cm add ~/.config/foo` | Start managing an existing file (copies it into the source state) |
| `cm edit ~/.config/foo` | Open the *source* copy in your editor; then apply it |
| `cm diff` | Show what `apply` would change, without touching anything |
| `cm apply` | Sync the repo state to your home directory |
| `cm status` | Like `git status` — files whose target differs from source |
| `cm re-add` | Adopt manual edits made outside chezmoi back into the repo |
| `cm update` | `git pull` the repo, then apply |
| `cm cd` | Jump into the source repo directory |
| `cm source-path ~/.config/foo` | Print the source path for a target file |
| `cm execute-template < file.tmpl` | Render a template to inspect its output |
| `cm managed` | List every file chezmoi manages |
