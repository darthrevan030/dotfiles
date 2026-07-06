# Portable config for WSL (Ubuntu), Git Bash (Windows), and macOS

# =============================================================================
# INTERACTIVE CHECK — don't do anything if not interactive
# =============================================================================
case $- in
*i*) ;;
*) return ;;
esac

# =============================================================================
# OS DETECTION
# =============================================================================
case "$OSTYPE" in
linux-gnu*)
  if grep -qi microsoft /proc/version 2>/dev/null; then
    OS="wsl"
  else
    OS="linux"
  fi
  ;;
msys* | cygwin*) OS="windows" ;;
darwin*) OS="mac" ;;
*) OS="unknown" ;;
esac

# =============================================================================
# HOMEBREW (mac only) — must run early so later command -v checks
# (fnm, zoxide, fzf, atuin, etc.) can actually find brew-installed binaries
# =============================================================================
if [ "$OS" = "mac" ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# =============================================================================
# HISTORY
# =============================================================================
HISTCONTROL=ignoreboth
HISTSIZE=10000
HISTFILESIZE=20000
shopt -s histappend
shopt -s checkwinsize

# =============================================================================
# PROMPT — simple, works everywhere
# =============================================================================
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# =============================================================================
# PATH — npm global (WSL only, git bash uses windows npm)
# =============================================================================
if [ "$OS" = "wsl" ] || [ "$OS" = "linux" ]; then
  export PATH="$HOME/.npm-global/bin:$PATH"
  export PATH="$HOME/.local/bin:$PATH"
fi

# =============================================================================
# COLOURS
# =============================================================================
if [ -x /usr/bin/dircolors ]; then
  eval "$(dircolors -b ~/.dircolors 2>/dev/null || dircolors -b)"
  alias ls='ls --color=auto'
  alias grep='grep --color=auto'
fi

# =============================================================================
# CORE ALIASES — work everywhere
# =============================================================================
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias df='df -h'
alias du='du -sh'
alias ports='ss -tulnp 2>/dev/null || netstat -tulnp'
alias myip='curl -s ifconfig.me'

cl() {
  cd "$1" && ls -CF --color=auto
}

# Git
alias gs='git status'
alias gp='git push'
alias gl='git log --oneline --graph --decorate -15'
alias gco='git checkout'
alias gd='git diff'

# Safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# =============================================================================
# BAT — syntax-highlighted cat
# WSL/Linux: installed as 'batcat', Windows Git Bash: installed as 'bat'
# =============================================================================
if command -v batcat &>/dev/null; then
  alias bat='batcat'
fi

# =============================================================================
# FZF — fuzzy finder
# =============================================================================
if command -v fzf &>/dev/null; then
  # Load fzf keybindings (Ctrl+R, Ctrl+T, Alt+C)
  if [ "$OS" = "wsl" ] || [ "$OS" = "linux" ]; then
    [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] &&
      source /usr/share/doc/fzf/examples/key-bindings.bash
  elif [ "$OS" = "windows" ]; then
    [ -f "$HOME/.fzf/shell/key-bindings.bash" ] &&
      source "$HOME/.fzf/shell/key-bindings.bash"
  elif [ "$OS" = "mac" ]; then
    [ -f "$(brew --prefix)/opt/fzf/shell/key-bindings.bash" ] &&
      source "$(brew --prefix)/opt/fzf/shell/key-bindings.bash"
  fi
fi

# =============================================================================
# ZOXIDE — smart cd (z instead of cd)
# =============================================================================
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init bash)"
fi

# =============================================================================
# FNM — Node version manager
# =============================================================================
if [ "$OS" = "wsl" ] || [ "$OS" = "linux" ]; then
  FNM_PATH="$HOME/.local/share/fnm"
  if [ -d "$FNM_PATH" ]; then
    export PATH="$FNM_PATH:$PATH"
    eval "$(fnm env --shell bash)"
  fi
elif [ "$OS" = "windows" ]; then
  # fnm on Git Bash
  if command -v fnm &>/dev/null; then
    eval "$(fnm env --shell bash)"
  fi
elif [ "$OS" = "mac" ]; then
  # fnm installed via Homebrew, already on PATH from the shellenv block above
  if command -v fnm &>/dev/null; then
    eval "$(fnm env --shell bash)"
  fi
fi

# =============================================================================
# UV — Python package manager
# Checks for the command itself rather than a hardcoded install path, since
# uv can land at ~/.local/bin (official installer) or /opt/homebrew/bin (brew)
# =============================================================================
if command -v uv &>/dev/null; then
  export PATH="$HOME/.local/bin:$PATH"
fi

# =============================================================================
# ATUIN — shell history sync (WSL/Linux only, not supported on Git Bash)
# =============================================================================
if [ "$OS" = "wsl" ] || [ "$OS" = "linux" ]; then
  if command -v atuin &>/dev/null; then
    eval "$(atuin init bash --disable-up-arrow)"
  fi
fi

# =============================================================================
# WSL-SPECIFIC
# =============================================================================
if [ "$OS" = "wsl" ]; then
  alias open='explorer.exe'
  alias winhome='cd /mnt/c/Users/smart'
  alias dotfiles='cd ~/.dotfiles'

  # Fix WSL interop path issues
  export BROWSER='wslview'
fi

# =============================================================================
# WINDOWS GIT BASH-SPECIFIC
# =============================================================================
if [ "$OS" = "windows" ]; then
  alias open='start'
  alias winhome='cd /c/Users/smart'
  alias dotfiles='cd ~/dotfiles'

  # Clipboard
  alias clip='clip.exe'
fi

# =============================================================================
# MACOS-SPECIFIC
# =============================================================================
if [ "$OS" = "mac" ]; then
  alias dotfiles='cd ~/.dotfiles'
fi

# =============================================================================
# COMPLETIONS
# =============================================================================
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -f "$(brew --prefix 2>/dev/null)/etc/profile.d/bash_completion.sh" ]; then
    . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
  fi
fi

# =============================================================================
# LOCAL OVERRIDES — machine-specific, not committed to dotfiles repo
# =============================================================================
[ -f ~/.bashrc.local ] && source ~/.bashrc.local
