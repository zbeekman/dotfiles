#!/usr/bin/env bash

# shellcheck disable=SC2015
asciinema --help > /dev/null 2>&1 && alias asciinema="LC_ALL=en_IN.UTF-8 asciinema" || true

alias stampede="ssh -tt login.xsede.org gsissh -p 2222 -tt stampede.tacc.xsede.org"

if command -v hub > /dev/null 2>&1 ; then
    eval "$(hub alias -s)"
fi

if less --help >/dev/null 2>&1 ; then
    alias more='less'
    alias less='less -i -F -X -M -N -J'
fi
if emacs --help >/dev/null 2>&1 ; then
    alias qemacs="emacs -nw -Q"
    alias temacs="emacs -nw"
fi

[[ -d "${HOME}/Sandbox" ]] && alias s="cd ~/Sandbox" || true

if command -v fortran-tags.py > /dev/null 2>&1 ; then
    function fortags {
	find "${@-.}" -name '*.[fF]90' ! -name '*__genmod.*' -print0 | xargs -0 fortran-tags.py -g
    }
fi
