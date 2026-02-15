# Set zinit directory
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit if not exists
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Theme
zinit ice depth=1; zinit light romkatv/powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ZSH plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Oh-My-Zsh plugins
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::aliases
zinit snippet OMZP::history
zinit snippet OMZP::colored-man-pages
zinit snippet OMZP::command-not-found
zinit snippet OMZP::uv
zinit snippet OMZP::aws
zinit snippet OMZP::docker
zinit snippet OMZP::golang
zinit snippet OMZP::ansible
zinit snippet OMZP::kubectl
zinit snippet OMZP::terraform

# Load completions
autoload -Uz compinit && compinit

# ZSH History configuration:
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.cache/zsh/history
HISTDUP=erase
setopt appendhistory
setopt hist_ignore_space
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_find_no_dups

# Keybindings
# Search cmd history with ctrl-p and ctrl-n
bindkey '^p' history-search-backwards
bindkey '^n' history-search-forward

# Completion tweaks
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive autocompletion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" # Colors for autocompletion
zstyle ':completion:*' menu no # Disable default completion menu (use fzf instead)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath' # Colors for zfz autocompletion
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath' # Preview of directory for fzf zoxide autocompletion

# Use fzf with zsh
eval "$(fzf --zsh)"

# Use zoxide instead of cd
eval "$(zoxide init zsh --cmd cd)"

# Create .zcompdump files in custom location instead of home
export ZSH_COMPDUMP=$ZSH/cache/.zcompdump-$HOST

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vi'
else
  export EDITOR='vi'
fi

# Set Golang env variables
export GOPATH=$HOME/.go
export PATH=$HOME/bin:/usr/local/bin:$PATH:$GOPATH/bin

# Aliases
alias ls="ls --color"