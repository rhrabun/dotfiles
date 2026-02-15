# dotfiles

Configuration files for my local machine

Branches can be used to define specific configuration for different machines. `main` branch contains configuration for my main machine

## Prerequisites
* git
* stow

## How-To
1. Clone repo into $HOME/.dotfiles
2. Create links with `stow . --dir $HOME/.dotfiles/ --target $HOME --verbose 2`
3. To unlink, `stow -D . -d $HOME/.dotfiles/ -t $HOME --verbose 2`

