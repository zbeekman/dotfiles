#!/usr/bin/env bash
# shellcheck shell=bash
# Use the system config if it exists

# shellcheck disable=SC1091
{
  if [ -f /etc/bashrc ]; then
    . /etc/bashrc
  elif [ -f /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
  fi
}

# Fix TMPDIR to point to a suitable location
if [ -z "${TMPDIR}" ] ; then
    if [ -d "${WORKDIR}" ] ; then
	export TMPDIR="${WORKDIR}/tmp"
    elif [ -d "/tmp" ] ; then
	export TMPDIR=/tmp
    fi
elif [[ ! "${TMPDIR}" =~ "/tmp/?$" ]] ; then
    export TMPDIR="${TMPDIR%/}/tmp"
fi

# Keep taucmdr from jamming up iTerm2 w/ it's fancy CPU meters
# __TAUCMDR_PROGRESS_BARS__="disable"
# export __TAUCMDR_PROGRESS_BARS__

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

if ! (echo "${PATH}" | grep "/usr/local/bin" > /dev/null 2>&1) && [[ -d "/usr/local/bin" ]]; then
  export PATH="/usr/local/bin:${PATH}"
fi

free_mosh () {
    for d in $(brew --cellar mosh)/* ; do
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add "${d}/bin/mosh-server"
	sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblockapp "${d}/bin/mosh-server"
    done
}

# mkcd: mkdir and cd into it
mkcd () { mkdir -p "$@" && eval cd "\"\$$#\""; }

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

if type -P module > /dev/null 2>&1 ; then
    [ -d "${PET_HOME}/modules" ] && module use --append "${PET_HOME}/modules"
    [ -d "${HOME}/apps/us3d/develop-current-knl-ic17/intel.onyx" ] && module use --append "${HOME}/apps/us3d/develop-current-knl-ic17/intel.onyx"
fi

# The following lines are only for interactive shells
[[ $- == *i* ]] || return

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
if [[ -f "${HOME}/.iterm2_shell_integration.$(basename "${SHELL}")" && "${TERM}" =~ "xterm" ]]; then
  # shellcheck source=/Users/ibeekman/.iterm2_shell_integration.bash
  . "${HOME}/.iterm2_shell_integration.$(basename "${SHELL}")"
  LP_PS1_PREFIX="${LP_PS1_PREFIX}\\[$(iterm2_prompt_mark)\\]"
  export LP_PS1_PREFIX
fi


# Use Bash completion, if installed
# shellcheck disable=SC1091
{
  [ -f /etc/bash_completion ] && . /etc/bash_completion
  [ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
}

# Use Liquid Prompt
if [[ -f "${HOME}/dotfiles/liquidprompt/liquidprompt" ]] ; then
  # shellcheck source=/Users/ibeekman/dotfiles/liquidprompt/liquidprompt
  source "${HOME}/dotfiles/liquidprompt/liquidprompt"
elif [[ -f "/usr/local/share/liquidprompt" ]] ; then
  source "/usr/local/share/liquidprompt"
fi

type -P liquidprompt_activate >/dev/null 2>&1 && liquidprompt_activate

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

rsa_keys=("${HOME}"/.ssh/*_rsa)
if [[ -f "${rsa_keys[0]}" ]]; then
  for k in "${rsa_keys[@]}" ; do
    ssh-add "$k"
  done
fi

dsa_keys=("${HOME}"/.ssh/*_dsa)
if [[ -f "${dsa_keys[0]}" ]]; then
  for k in "${dsa_keys[@]}" ; do
    ssh-add "$k"
  done
fi

# added by travis gem
[ -f /Users/ibeekman/.travis/travis.sh ] && source /Users/ibeekman/.travis/travis.sh

# Get tokens if they exist
if [[ -d "${HOME}/.secrets/tokens" ]]; then
    for token in ${HOME}/.secrets/tokens/* ; do
	echo "sourcing file $token"
	# shellcheck disable=SC1090
	source "$token"
    done
fi

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
[[ -d "${HOME}/.rvm/bin" ]] && export PATH="$PATH:$HOME/.rvm/bin"

# Set OVPN store
export OVPN_DATA=ovpn-data-PT-EAST
