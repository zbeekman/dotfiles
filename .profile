#!/bin/sh
# shellcheck shell=sh
#
# Sourcing order: .profile (this file) → .bashrc (if bash) → .bashrc.personal → .bash_aliases
#
# Sourced by: login shells (Terminal.app, SSH login, etc.)
# Sources:    .bashrc (for bash), autojump, iterm2 shell integration

#set -o verbose

if [ "$(uname)" = "Linux" ] && [ -n "${DISPLAY:-}" ] ; then
    setxkbmap -layout us -option ctrl:nocaps
fi

# Turn off the damn wysiwyg slack editor
export SLACK_DEVELOPER_MENU=true

# emacs --help > /dev/null 2>&1 && export EDITOR="emacs -nw" && export VISUAL=emacs
#export EDITOR="emacs -nw" && export VISUAL=emacs
command -v less > /dev/null 2>&1 && export PAGER=less

if [ -d "${HOME}/.local/bin" ]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi
if [ -d "${HOME}/taucmdr/bin" ]; then
  export PATH="${HOME}/taucmdr/bin:${PATH}"
fi
if [ -d "${HOME}/fpm/bin" ]; then
  export PATH="${HOME}/fpm/bin:${PATH}"
fi
export CTEST_OUTPUT_ON_FAILURE=1

# Homebrew: detect and set up paths (Apple Silicon or Intel)
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

export XML_CATALOG_FILES="/usr/local/etc/xml/catalog"
export CLICOLOR=1
export GREP_COLORS="fn=34:mt=01;34:ln=01;30:se=30"
export HISTSIZE=""
export HISTFILESIZE=""
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S UTC%z] "
export HISTIGNORE="pwd:ls:ls -ltr:ls -lAhF:cd ..:.."
export HISTCONTROL="ignoreboth"

# less pager customization (using $'...' to avoid printf forks)
# shellcheck disable=SC3003  # $'...' works in bash/zsh/dash on macOS
{
export LESS_TERMCAP_mb=$'\e[01;34m'   # Blink
export LESS_TERMCAP_md=$'\e[01;34m'   # Keywords
export LESS_TERMCAP_me=$'\e[0m'       # Mode Stop
export LESS_TERMCAP_so=$'\e[01;30m'   # Standout-Mode (Info Box)
export LESS_TERMCAP_se=$'\e[0m'       # Standout End
export LESS_TERMCAP_us=$'\e[01;34m'   # Constants
export LESS_TERMCAP_ue=$'\e[0m'       # Constants End
}

export LESS=" -i -R -J "

if [ -n "${PKG_CONFIG_PATH}" ]; then
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}"
else
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
fi

export __TAUCMDR_PROGRESS_BARS__="disabled"

# Early return for non-interactive shells (scp/rsync safety)
# Essential PATH and env vars are set above; everything below is interactive-only
# shellcheck disable=SC2317
case "$-" in *i*) ;; *) return 0 2>/dev/null || exit 0;; esac

# if type keychain > /dev/null 2>&1 ; then
#     eval "$(keychain --agents "gpg,ssh" --eval)"
#     export GPG_AGENT_PID="$(pgrep gpg-agent)"
#     export SSH_AGENT_PID="$(pgrep ssh-agent)"
# else
#     if pid="$(pgrep gpg-agent)" ; then
#         export GPG_AGENT_PID="$pid"
#     else
#         gpgconf --launch gpg-agent
#         GPG_AGENT_PID="$(pgrep gpg-agent)"
#     fi
# fi
# export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

pgrep ssh-agent > /dev/null 2>&1 || eval "$(ssh-agent -s)" > /dev/null

if [ "${SHELL##*/}" = "bash" ]; then
  # shellcheck source=.bashrc
  [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
fi

# shellcheck disable=SC1091
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$PATH:/usr/local/go/bin"

# shellcheck disable=SC1091
test -e "${HOME}/.iterm2_shell_integration.bash" && . "${HOME}/.iterm2_shell_integration.bash"
