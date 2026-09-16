#!/usr/bin/env bash
# shellcheck shell=bash
#
# Bash reads ~/.bash_profile for login shells and, when it exists, SKIPS
# ~/.profile entirely. All real configuration lives in ~/.profile; this file
# only delegates to it (mirrors .zprofile for zsh).
#
# This file also acts as a landing pad for installers (Docker Desktop, nvm,
# conda, gcloud, ...) that append to ~/.bash_profile when present. Review any
# additions below and fold them into ~/.profile.

# shellcheck source=.shell-lib.sh
[ -f "${HOME}/.shell-lib.sh" ] && . "${HOME}/.shell-lib.sh"

# The following lines were added by Docker Desktop to add commands to your PATH.
# (sentinel: marker lines kept verbatim so Docker Desktop leaves this file alone)
path_append "${HOME}/.docker/bin"
# End of Docker Desktop section.

# shellcheck source=.profile
[ -f "${HOME}/.profile" ] && . "${HOME}/.profile"
