#!/usr/bin/env bash
# Use the system config if it exists

# shellcheck disable=SC1091
{
  if [ -f /etc/bashrc ]; then
    . /etc/bashrc
  elif [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
  fi
}

# The following lines are only for interactive shells
[[ $- == *i* ]] || return

# If a hashed command no longer exists, a normal path search is performed.
shopt -u checkhash

# Checks the window size after each command and, if necessary, updates the values of LINES and COLUMNS.
shopt -s checkwinsize

shopt -u direxpand
shopt -s progcomp
shopt -s cmdhist
shopt -s histappend
shopt -u histreedit

# Use iTerm shell integration
if [[ -f "${HOME}/.iterm2_shell_integration.$(basename "${SHELL}")" ]]; then
  # shellcheck source=/Users/ibeekman/.iterm2_shell_integration.bash
  . "${HOME}/.iterm2_shell_integration.$(basename "${SHELL}")"
  LP_PS1_PREFIX="\[$(iterm2_prompt_mark)\]"
  export LP_PS1_PREFIX
fi

# Use Bash completion, if installed
# shellcheck disable=SC1091
{
  [ -f /etc/bash_completion ] && . /etc/bash_completion
  [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
}

# Use Liquid Prompt
[ -f /usr/local/share/liquidprompt ] && . /usr/local/share/liquidprompt

# Homebrew command not found
if brew command command-not-found-init >/dev/null 2>&1; then
  eval "$(brew command-not-found-init)"
fi
