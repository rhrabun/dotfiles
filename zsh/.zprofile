if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

export GOPATH=$HOME/.go
export PATH=$HOME/bin:/usr/local/bin:$PATH:$GOPATH/bin

export EDITOR=vim
export VISUAL=vim