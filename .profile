#!/bin/sh
# shellcheck shell=sh
#
# Sourcing order: .profile (this file) → .bashrc (if bash) → .bashrc.personal → .bash_aliases
#
# Sourced by: login shells (Terminal.app, SSH login, etc.)
#             .bash_profile and .zprofile are thin delegators that source this file.
# Sources:    .bashrc (for bash), autojump, iterm2 shell integration
#
# Installer sentinels: Docker Desktop (and similar tools) probe .bash_profile,
# .zprofile and .profile for their marker comment and inject a PATH block when
# it is missing. Keep the marker lines verbatim so they leave these files alone.

#set -o verbose

# shellcheck source=.shell-lib.sh
[ -f "${HOME}/.shell-lib.sh" ] && . "${HOME}/.shell-lib.sh"

if [ "$(uname)" = "Linux" ] && [ -n "${DISPLAY:-}" ] ; then
    setxkbmap -layout us -option ctrl:nocaps
fi

# Turn off the damn wysiwyg slack editor
export SLACK_DEVELOPER_MENU=true

# Caveman skill: default compression mode for Claude Code
export CAVEMAN_DEFAULT_MODE=ultra

# emacs --help > /dev/null 2>&1 && export EDITOR="emacs -nw" && export VISUAL=emacs
#export EDITOR="emacs -nw" && export VISUAL=emacs
command -v less > /dev/null 2>&1 && export PAGER=less

path_prepend "${HOME}/.local/bin"
path_prepend "${HOME}/taucmdr/bin"
path_prepend "${HOME}/fpm/bin"

# The following lines were added by Docker Desktop to add commands to your PATH.
# (sentinel: marker lines kept verbatim so Docker Desktop leaves this file alone)
path_append "${HOME}/.docker/bin"
# End of Docker Desktop section.

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

# --- ssh-agent: single persistent instance ---
# macOS launchd provides ssh-agent and sets SSH_AUTH_SOCK automatically.
# On Linux (or if launchd agent is absent), manage our own agent via env file.
_ssh_agent_env="$HOME/.ssh/agent-env"

_start_ssh_agent() {
    eval "$(ssh-agent -s)" > /dev/null
    printf 'SSH_AUTH_SOCK=%s; export SSH_AUTH_SOCK;\n' "$SSH_AUTH_SOCK" > "$_ssh_agent_env"
    printf 'SSH_AGENT_PID=%s; export SSH_AGENT_PID;\n' "$SSH_AGENT_PID" >> "$_ssh_agent_env"
    chmod 600 "$_ssh_agent_env"
}

if [ -n "$SSH_AUTH_SOCK" ] && [ -S "$SSH_AUTH_SOCK" ]; then
    # launchd (macOS) or parent process already set a valid agent socket — use it
    :
elif [ -f "$_ssh_agent_env" ]; then
    # shellcheck disable=SC1090
    . "$_ssh_agent_env" > /dev/null
    # Verify agent is still alive
    kill -0 "$SSH_AGENT_PID" 2>/dev/null || _start_ssh_agent
else
    _start_ssh_agent
fi

unset _ssh_agent_env

# Test the running shell, not $SHELL: zsh -l inherits SHELL=/usr/local/bin/bash
if [ -n "${BASH_VERSION:-}" ]; then
  # shellcheck source=.bashrc
  [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
fi

# shellcheck disable=SC1091
[ -f /usr/local/etc/profile.d/autojump.sh ] && . /usr/local/etc/profile.d/autojump.sh

path_prepend "${HOME}/.cargo/bin"
path_append /usr/local/go/bin

# shellcheck disable=SC1091
if [ -n "${BASH_VERSION:-}" ]; then
  test -e "${HOME}/.iterm2_shell_integration.bash" && . "${HOME}/.iterm2_shell_integration.bash"
fi
