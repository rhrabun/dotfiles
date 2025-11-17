export GOPATH=$HOME/.go
export PATH=$HOME/bin:/usr/local/bin:$PATH:$GOPATH/bin

# Path to  oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# ZSH History configuration:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history
HISTDUP=erase
setopt appendhistory
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups

# ZSH Theme
#ZSH_THEME="fino"
source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  # system
  aliases
  history
  colored-man-pages
  zsh-autosuggestions
  zsh-syntax-highlighting
  # utils
  git
  terraform
  helm
  ansible
  httpie
  uv
  docker
  kubectl
  aws
  virtualenv
  pip
  golang
)

# Create .zcompdump files in custom location instead of home
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

source $ZSH/oh-my-zsh.sh

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vi'
else
  export EDITOR='vi'
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Use fzf with zsh
eval "$(fzf --zsh)"

# Use zoxide instead of cd
eval "$(zoxide init zsh --cmd cd)"