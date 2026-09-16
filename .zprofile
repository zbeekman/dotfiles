#!/usr/local/bin/zsh
# shellcheck shell=bash
#
# zsh login shells read this file. All real configuration lives in ~/.profile;
# this file only delegates to it (mirrors .bash_profile for bash).
#
# Landing pad for installers (Docker Desktop, etc.) that append to ~/.zprofile.
# Review any additions below and fold them into ~/.profile.

# shellcheck source=.shell-lib.sh
[[ -f ~/.shell-lib.sh ]] && source ~/.shell-lib.sh

# The following lines were added by Docker Desktop to add commands to your PATH.
# (sentinel: marker lines kept verbatim so Docker Desktop leaves this file alone)
path_append "${HOME}/.docker/bin"
# End of Docker Desktop section.

# Just pull everything from ~/.profile
[[ -f ~/.profile ]] && emulate sh -c '. ~/.profile'
