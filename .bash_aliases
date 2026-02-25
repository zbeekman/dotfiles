#!/usr/bin/env bash
#
# Sourcing order: .profile → .bashrc → .bashrc.personal → .bash_aliases (this file)
#
# Sourced by: .bashrc
# Sources:    (none)

if command -v less >/dev/null 2>&1 ; then
    alias more='less'
    alias less='less -i -F -X -M -N -J'
fi
if command -v emacs >/dev/null 2>&1 ; then
    alias qemacs="emacs -nw -Q"
    alias temacs="emacs -nw"
fi

[[ -d "${HOME}/Sandbox" ]] && alias s="cd ~/Sandbox" || true

