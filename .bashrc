#!/usr/bin/env bash
# shellcheck shell=bash

# to profile and/or debug, set DEBUG=true
DEBUG=false

if [[ "${DEBUG}" == true ]]; then
    # This timing trace requires the `moreutils` package, e.g. `brew install moreutils`
    # open file descriptor 5 such that anything written to /dev/fd/5
    # is piped through ts and then to /tmp/timestamps
    exec 5> >(ts -i "%.s" >> /tmp/timestamps)

    # https://www.gnu.org/software/bash/manual/html_node/Bash-Variables.html
    export BASH_XTRACEFD="5"

    set -x
    set -o verbose
    set -o errexit
fi

# Debug completion with:
# export DOT_BASHRC_SOURCED="yes"

set -o errtrace

prepend_path () {
    # Add $1 to front of PATH or variable specified by $2
    if [[ -n "${2:-}" ]]; then
	VAR="${2}"
    else
	VAR=PATH
    fi
    if [[ ! -d "${1}" ]] || [[ -x "${1}" ]]; then
	return 1
    fi
    ${VAR}="${1}:${VAR}"
    export ${VAR}
}

add_path () {
    # Add $1 to back of PATH, if it's not in it already
    # or to $2 (instead of $PATH, if $2 is present)
    if [[ -n "${2:-}" ]]; then
	VAR="${2}"
    else
	VAR=PATH
    fi
    if [[ ! -d "${1}" ]] || [[ -x "${1}" ]]; then
	return 1
    fi

    if ! grep "$1" <<< $VAR > /dev/null 2>&1 ; then
	${VAR}="${VAR}:${1}"
	export ${VAR}
    fi
}

source_if_present () {
    if [ -f "$1" ] ; then
	. "$1"
    fi
}

# Use the system config if it exists
if [[ -z "${ETC_BASHRC_SOURCED:-}" ]] ; then
  # prevent infinite loops ~/.bashrc -> /etc/bashrc -> ~/.bashrc -> ... etc.
  export ETC_BASHRC_SOURCED="yes"
  # shellcheck disable=SC1091
  {
      source_if_present /etc/bashrc
      source_if_present /etc/bash.bashrc
  }
fi

# Don't source .bashrc more than once
if [[ -z "${DOT_BASHRC_SOURCED:-}" ]] ; then
    echo "Setting DOT_BASHRC_SOURCED=yes"
    export DOT_BASHRC_SOURCED="yes"
else
    echo "${HOME}/.bashrc already sourced! Unset DOT_BASHRC_SOURCED to do it again."
    return
fi

# Fix TMPDIR to point to a suitable location
if [ -z "${TMPDIR}" ] ; then
    if [ -d "${WORKDIR}" ] ; then
	export TMPDIR="${WORKDIR}/tmp"
    elif [ -d "/tmp" ] ; then
	export TMPDIR=/tmp
    fi
elif [[ ! "${TMPDIR}" =~ "/tmp/?$" ]] ; then
    mkdir -p "${TMPDIR%/}/tmp" && \
	export TMPDIR="${TMPDIR%/}/tmp"
fi

# Keep taucmdr from jamming up iTerm2 w/ it's fancy CPU meters
__TAUCMDR_PROGRESS_BARS__="disabled"
export __TAUCMDR_PROGRESS_BARS__

if [[ $OSTYPE == [Dd]arwin* ]]; then
  compilervars () {
    compilers=(
       gfortran
       gcc
       g++
    )
    for major_version in {9,8,7,6,5}; do
       echo "Looking for gcc-$major_version"
       for compiler in "${compilers[@]}"; do
         if ! type -P "${compiler}-${major_version}" >/dev/null 2>&1 ; then
           echo "Not found" # try next lower maj version
           continue 2
         fi
       done
       # have all 3 compilers
       FC="$(type -P gfortran-${major_version})"
       CC="$(type -P gcc-${major_version})"
       CXX="$(type -P g++-${major_version})"
       export FC
       export CC
       export CXX
       echo "FC=$FC CC=$CC CXX=$CXX"
       break
    done
  }
fi

if ! (echo "${PATH}" | grep "/usr/local/bin" > /dev/null 2>&1) ; then
    prepend_path "/usr/local/bin" PATH
fi

free_mosh () {
    for d in "$(brew --cellar mosh)"/* ; do
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add "${d}/bin/mosh-server"
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp "${d}/bin/mosh-server"
    done
}

# mkcd: mkdir and cd into it
mkcd () { mkdir -p "$@" && cd "$_" || return; }

# extract: untar all the things
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2)   tar xvjf "$1"    ;;
            *.tar.gz)    tar xvzf "$1"    ;;
            *.bz2)       bunzip2 "$1"     ;;
            *.rar)       unrar x "$1"     ;;
            *.gz)        gunzip "$1"      ;;
            *.tar)       tar xvf "$1"     ;;
            *.tbz2)      tar xvjf "$1"    ;;
            *.tgz)       tar xvzf "$1"    ;;
            *.zip)       unzip "$1"       ;;
            *.Z)         uncompress "$1"  ;;
            *.7z)        7z x "$1"        ;;
            *)           echo "I don't know how to extract \\'$1\\'..." ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

if type -P qstat > /dev/null 2>&1 ; then
    alias qme='qstat -u ${USER}'

    subjob () {
        set -o pipefail
        JID=$(qsub "${@}" | cut -d '.' -f 1)
        _ret=$?
        JIDARR=("${JID}" "${JIDARR[@]}") # push job id onto stack
        echo "${JID}"
        export JID
        export JIDARR
        set +o pipefail
        return $_ret
    }

    killastjob () {
        set -o pipefail
        qdel "${JID}"
        _ret="${?}"
        JIDARR=("${JIDARR[@]//$JID/}") # filter out job id, pop stack
        JID=${JIDARR[0]}
        export JIDARR
        export JID
        set +o pipefail
        return $_ret
    }

    afterjob () {
        set -o pipefail
        if [[ -n "$JID" ]]; then
            subjob -W depend="afterany:${JID}" "${@}"
            _ret=${?}
            export JID
            export JIDARR
        else
            echo "\$JID is empty, can't chain from unkown job!" >&2
            return 100
        fi
        return $_ret
    }

    peekjob () {
        qpeek "${JIDARR[${1:-0}]}"
    }

    killjarray () {
        for j in "${JIDARR[@]}"; do
            qdel "${j}"
        done
        unset JIDARR
    }
fi

if type -a module > /dev/null 2>&1 ; then
    if [ -d "${PET_HOME}/modules" ] ; then
	module use --append "${PET_HOME}/modules"
    fi
    # [ -d "${HOME}/apps/us3d/develop-current-knl-ic17/intel.onyx" ] && module use --append "${HOME}/apps/us3d/develop-current-knl-ic17/intel.onyx"
fi

# The following lines are only for interactive shells
[[ $- == *i* ]] || return

resize # make sure the terminal knows how big it is

# If a hashed command no longer exists, a normal path search is performed.
shopt -u checkhash

# Checks the window size after each command and, if necessary, updates the values of LINES and COLUMNS.
shopt -s checkwinsize
(( BASH_VERSINFO[0] > 3 )) && shopt -u direxpand
shopt -s progcomp
shopt -s cmdhist
shopt -s histappend
shopt -u histreedit

#export LP_PS1_PREFIX='\[\e]0;\h:\W\a\]'

# Use iTerm shell integration
# if [[ "${OSTYPE}" == [Dd]arwin* ]]; then
#   if [[ -f "${HOME}/.iterm2_shell_integration.$(basename "${SHELL}")" && "${TERM}" =~ "xterm" ]]; then
#     # shellcheck source=/Users/ibeekman/.iterm2_shell_integration.bash
#     source "${HOME}/.iterm2_shell_integration.$(basename "${SHELL}")"
#     LP_PS1_PREFIX="${LP_PS1_PREFIX}\\[$(iterm2_prompt_mark)\\]"
#     export LP_PS1_PREFIX
#   fi
# fi


# Use Bash completion, if installed
# shellcheck disable=SC1091
set +o errexit
{
  source_if_present /etc/bash_completion || true
  source_if_present /usr/local/etc/bash_completion || true
}
if [[ "${DEBUG}" == true ]]; then
    set -o errexit
fi

if [[ "$(hostname)" = [Oo]nyx* || "$(hostname)" = batch* ]]; then
  export LP_MARK_GIT="\\[-+\\]"
  module swap PrgEnv-cray PrgEnv-intel 2>/dev/null || true
  module load cray-shmem 2>/dev/null|| true
fi
# Use Liquid Prompt
if [[ -z "${LP_SET:-}" ]] ; then
  # liquid prompt not yet enabled
  if [[ -f "${HOME}/dotfiles/liquidprompt/liquidprompt" ]] ; then
    # shellcheck source=/Users/ibeekman/dotfiles/liquidprompt/liquidprompt
    source "${HOME}/dotfiles/liquidprompt/liquidprompt"
    export LP_SET="yes"
  else
    # shellcheck source=/Users/ibeekman/dotfiles/liquidprompt/liquidprompt
    source_if_present "/usr/local/share/liquidprompt"
    export LP_SET="yes"
  fi
fi
# trap err_report ERR

# Homebrew command not found
if brew command command-not-found-init >/dev/null 2>&1; then
  eval "$(brew command-not-found-init)"
fi

# Define a command to start an ssh SOCKS tunnel for proxying web traffic
sshproxy() {
    # shellcheck disable=SC2029
    ssh -D "${2:-8181}" -f -C -q -N "${1}" &
    export PROXY_TUNNELS="${PROXY_TUNNELS:-};${!}.${2:-8181}"
}

proxykill() {
    LAST_PAIR="${PROXY_TUNNELS##*;}"
    PROXY_PID="${LAST_PAIR%.*}"
    if [[ -n "${PROXY_PID}" ]]; then
	kill "${PROXY_PID}" > /dev/null 2>&1
	PROXY_TUNNELS="${PROXY_TUNNELS%;*}"
	export PROXY_TUNNELS
    fi
}

# Fire up an ssh agent
if ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
    echo "ssh-agent running with pid $SSH_AGENT_PID"
else
  eval "$(ssh-agent -s)"
fi

# If an agent is running...which it should be
if ps -p "$SSH_AGENT_PID" > /dev/null 2>&1; then
    # and if we haven't added the default keys...
    ssh-add -l &> /dev/null || ssh-add || echo "Could not add keys to ssh-agent."
fi

# added by travis gem
# shellcheck source=/Users/ibeekman/.travis/travis.sh
source_if_present /Users/ibeekman/.travis/travis.sh

# Get tokens if they exist
if [[ -d "${HOME}/.secrets/tokens" ]]; then
    for token in "${HOME}"/.secrets/tokens/* ; do
	echo "sourcing file $token"
	# shellcheck disable=SC1090
	source_if_present "$token"
    done
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
add_path "$HOME/.rvm/bin" || true

# Set OVPN store
#export OVPN_DATA=ovpn-data-PT-EAST
brew_show_outdated() {
    if [[ "${OSTYPE}" == [Dd]arwin* ]]; then
	if [[ -f "${2}"p ]] ; then
	    _lines="$(wc -l "${2}")"
	    if [[ $_lines -gt 0 ]]; then
		echo " "
		echo "\\* Outdated ${1}:"
		cat "${2}"
		echo ""
	    fi
	fi
    fi
}

# Print message telling user about outdated packages on macOS
brew_show_outdated Formulae /tmp/brew.outdated || true
brew_show_outdated Casks /tmp/cask.outdated || true
brew_show_outdated Apps /tmp/mas.outdated || true

export HOMEBREW_MIANTAINER=1
export HOMEBREW_BINTRAY_USER=zbeekman

# If debugging was turned on, turn off everything here:
if [[ "${DEBUG}" == true ]]; then
    unset  BASH_XTRACEFD
    set +x
    set +o verbose
    set +o errexit
fi
