# dotfiles

Configuration files for my local machine, managed with [chezmoi](https://www.chezmoi.io/).

## Prerequisites
* git
* chezmoi

## How-To
On a new machine:
`chezmoi init --apply https://github.com/rhrabun/dotfiles.git`

Day-to-day commands: `chezmoi add`, `chezmoi edit`, `chezmoi diff`, `chezmoi apply`, `chezmoi update`.

## Note for myself
Since ansible is configured to use https to clone the public repo, to use ssh you need to configre `remote` accordingly
1. `git remote add origin git@github.com:rhrabun/dotfiles.git`
2. `git push -u origin main`
