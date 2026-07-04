# dotfiles

Configuration files for my local machine

## Prerequisites
* git
* chezmoi

## How-To
`chezmoi init --apply https://github.com/rhrabun/dotfiles.git`

## Note for myself
Since ansible is configured to use https to clone the public repo, to use ssh you need to configre `remote` accordingly
1. `git remote add origin git@github.com:rhrabun/dotfiles.git`
2. `git push -u origin main`
