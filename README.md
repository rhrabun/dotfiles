# dotfiles

Configuration files for my local machine

Branches can be used to define specific configuration for different machines. `main` branch contains configuration for my main machine

## Prerequisites
* git
* stow

## CheatSheet
Run these from inside `~/.dotfiles`

```bash
# Stow all
stow -v */

# Unstow all
stow -D -v */

# Dry-run all
stow -n -v */

# Stow one
stow -v  package

# Unstow one
stow -D -v package

# Dry run one
stow -n -v package


### Note
Since ansible is configured to use https to clone the public repo without setting up keys first, configure ssh remote by
1. `git remote add origin git@github.com:rhrabun/dotfiles.git`
2. `git push -u origin main`
