# dotfiles

Configuration files for my local machine

## Prerequisites
* git
* stow

## How-To
I have a strange love for creating Makefiles, so you can use [this](./Makefile) to run Stow or to see commands

Some programs use very specific directory for config files (looking at you, VSCode), so [this Makefile](./Makefile) supports defining custom directories per package:
* In package directory, create a `.target-[Darwin/Linux]` file and put there a path (relative to HOME) to directory where config files should be symlinked to.

## Note for myself
Since ansible is configured to use https to clone the public repo, to use ssh you need to configre `remote` accordingly
1. `git remote add origin git@github.com:rhrabun/dotfiles.git`
2. `git push -u origin main`
