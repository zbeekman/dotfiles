#!/bin/sh
# shellcheck shell=sh
#
# Shared POSIX helpers for shell startup files. Must stay sh-compatible:
# sourced natively by bash (.bash_profile, .profile) and zsh (.zprofile).
#
# Sourced by: .profile, .bash_profile, .zprofile (idempotent; safe to re-source)

# path_prepend DIR  -- put DIR at the front of PATH if it exists and is not already present
path_prepend() {
  [ -d "$1" ] || return 0
  case ":${PATH}:" in
    *":$1:"*) ;;
    *) PATH="$1${PATH:+:${PATH}}" ;;
  esac
  export PATH
}

# path_append DIR  -- put DIR at the end of PATH if it exists and is not already present
path_append() {
  [ -d "$1" ] || return 0
  case ":${PATH}:" in
    *":$1:"*) ;;
    *) PATH="${PATH:+${PATH}:}$1" ;;
  esac
  export PATH
}
