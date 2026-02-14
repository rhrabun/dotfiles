# dotfiles

Configuration files for my local machine

Branches can be used to define specific configuration for different machines. `main` branch contains configuration for my main machine

## Prerequisites
* git
* stow

## CheatSheet
Clone repo into $HOME/.dotfiles  
`git clone https://github.com/rhrabun/dotfiles.git $HOME/.dotfiles`

Run these from inside `~/.dotfiles`

```bash
# All
stow */

# Package
stow package
```
Dry-run: `-v -n`
Unstow: `-D`

## System specific
#### VSCode
*Mac*
`stow vscode -t "$HOME/Library/Application Support/Code/User"`

*Linux*
`stow vscode -t "$HOME/.config/Code/User"`

### Note
Since ansible is configured to use https to clone the public repo without setting up keys first, configure ssh remote by
1. `git remote add origin git@github.com:rhrabun/dotfiles.git`
2. `git push -u origin main`
