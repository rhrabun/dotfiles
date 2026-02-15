# dotfiles

Configuration files for my local machine

## Prerequisites
* git
* stow

## How-To
I have a strange love for creating Makefiles, so you can use [this](./Makefile) to run Stow or to see commands

## Note for myself
Since ansible is configured to use https to clone the public repo, to use ssh you need to configre `remote` accordingly
1. `git remote add origin git@github.com:rhrabun/dotfiles.git`
2. `git push -u origin main`
