#!/usr/bin/env bash
# shellcheck shell=bash
#
# Sourcing order: .profile → .bashrc (this file) → .bashrc.personal → .bash_aliases
#
# Sourced by: .profile (login shells), or directly by non-login interactive shells
# Sources:    .bashrc.personal, .bash_aliases, liquidprompt, bash_completion,
#             nvm, fzf, 1password completion, modules init

# to profile and/or debug, set DEBUG=true
DEBUG=false

# Set PROFILE_STARTUP=true to get per-line timing via $EPOCHREALTIME trace
# Usage: profile-shell (see bin/profile-shell)
PROFILE_STARTUP=${PROFILE_STARTUP:-false}
if [[ "${PROFILE_STARTUP}" == true ]]; then
    PS4='+ $EPOCHREALTIME\011${BASH_SOURCE[0]}:${LINENO}\011'
    set -x
fi

# Set VERBOSE=true to see diagnostic output during shell init
VERBOSE=${VERBOSE:-false}
_verbose() { [[ "$VERBOSE" == true ]] && echo "$@" || true; }

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
    set -o errtrace
fi

prepend_path () {
    # Add $1 to front of PATH or variable specified by $2
    if [[ -n "${2:-}" ]]; then
	VAR="${2}"
    else
	VAR=PATH
    fi
    if ! [[ -d "${1}" && -x "${1}" ]]; then
	return 1
    fi
    eval "${VAR}=\"${1}:${!VAR}\""
    export "${VAR?}"
    echo "${!VAR}"
}

add_path () {
    # Add $1 to back of PATH, if it's not in it already
    # or to $2 (instead of $PATH, if $2 is present)
    if [[ -n "${2:-}" ]]; then
	VAR="${2}"
    else
	VAR=PATH
    fi
    if ! [[ -d "${1}" && -x "${1}" ]]; then
	return 1
    fi

    if ! grep "$1" <<< "${!VAR}" > /dev/null 2>&1 ; then
	eval "${VAR}=\"${!VAR}:${1}\""
	export "${VAR?}"
	echo "${!VAR}"
    fi
}

source_if_present () {
    if [ -f "$1" ] ; then
	# shellcheck disable=SC1090
	. "$@"
    fi
}

dedupe_path () {
    if [[ -n "${1:-}" ]]; then
	VAR="${1}"
    else
	VAR=PATH
    fi
    OLD_IFS="$IFS"
    n='' IFS=':'
    for e in ${!VAR}; do
	[[ :$n == *:$e:* || -z "$e" ]]  ||  n+=$e:
    done
    IFS="$OLD_IFS"
    eval "${VAR}=\"${n:0: -1}\""
    export "${VAR?}"
    echo "${!VAR}"
}

brew_show_outdated() {
    if [[ "${OSTYPE}" == [Dd]arwin* ]]; then
	if [[ -f "${2}" ]] ; then
	    _lines="$(wc -l < "${2}")"
	    if (( _lines > 0 )); then
		echo " "
		echo "Outdated ${1}:"
		cat "${2}"
		echo ""
	    fi
	fi
    else
	true
    fi
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
            *)           printf "I don't know how to extract '%s'...\\n" "$1" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

if [[ $OSTYPE == [Dd]arwin* ]]; then
  compilervars () {
    compilers=(
       gfortran
       gcc
       g++
    )
    for major_version in {13,12,11,10,9}; do
       _verbose "Looking for gcc-$major_version"
       for compiler in "${compilers[@]}"; do
         if ! type -P "${compiler}-${major_version}" >/dev/null 2>&1 ; then
           _verbose "Not found" # try next lower maj version
           continue 2
         fi
       done
       # have all 3 compilers
       FC="$(type -P "gfortran-${major_version}")"
       CC="$(type -P "gcc-${major_version}")"
       CXX="$(type -P "g++-${major_version}")"
       export FC
       export CC
       export CXX
       _verbose "FC=$FC CC=$CC CXX=$CXX"
       break
    done
  }

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

# # Use the system config if it exists
# if [[ -z "${ETC_BASHRC_SOURCED:-}" ]] ; then
#   # prevent infinite loops ~/.bashrc -> /etc/bashrc -> ~/.bashrc -> ... etc.
#   export ETC_BASHRC_SOURCED="yes"
#   # shellcheck disable=SC1091
#   {
#       source_if_present /etc/bashrc
#       source_if_present /etc/bash.bashrc
#   }
# fi

# # Don't source .bashrc more than once
# if [[ -z "${DOT_BASHRC_SOURCED:-}" ]] ; then
#     echo "Setting DOT_BASHRC_SOURCED=yes"
#     export DOT_BASHRC_SOURCED="yes"
# else
#     echo "${HOME}/.bashrc already sourced! Unset DOT_BASHRC_SOURCED to do it again."
#     return
# fi


source_if_present ~/.bashrc.personal
source_if_present ~/.bash_aliases

# The following lines are only for interactive shells
if [[ $- == *i* ]] ; then

    # If a hashed command no longer exists, a normal path search is performed.
    shopt -u checkhash

    # Checks the window size after each command and, if necessary, updates the values of LINES and COLUMNS.
    shopt -s checkwinsize
    (( BASH_VERSINFO[0] > 3 )) && shopt -u direxpand
    shopt -s progcomp
    shopt -s cmdhist
    shopt -s histappend
    shopt -u histreedit

    # Homebrew command not found (source handler directly, avoid slow `brew` invocation)
    if [ -n "${HOMEBREW_REPOSITORY:-}" ] && [ -f "${HOMEBREW_REPOSITORY}/Library/Homebrew/command-not-found/handler.sh" ]; then
	# shellcheck disable=SC1091
	. "${HOMEBREW_REPOSITORY}/Library/Homebrew/command-not-found/handler.sh"
    fi

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

    # Use Liquid Prompt
    if [[ ! "${PROMPT_COMMAND:-}" = *lp_set_prompt ]] ; then
	# liquid prompt not yet enabled
	if [[ -f "${HOME}/dotfiles/liquidprompt/liquidprompt" ]] ; then
	    # shellcheck source=liquidprompt/liquidprompt
	    source "${HOME}/dotfiles/liquidprompt/liquidprompt"
	else
	    # shellcheck disable=SC1091
	    source_if_present "/usr/local/share/liquidprompt"
	fi
    fi
    # trap err_report ERR

    # export GPG_TTY=$(tty)
    # export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

    # If an agent is running...which it should be
#    if ps -p "$SSH_AGENT_PID" > /dev/null 2>&1 || ps -p "$GPG_AGENT_PID" > /dev/null 2>&1 ; then
    if ps -p "$SSH_AGENT_PID" > /dev/null 2>&1 > /dev/null 2>&1 ; then	
	# and if we haven't added the default keys...
	ssh-add -l &> /dev/null || ssh-add || echo "Could not add keys to ssh-agent."
    fi

    # Get tokens if they exist
    if [[ -d "${HOME}/.secrets/tokens" ]]; then
	for token in "${HOME}"/.secrets/tokens/* ; do
	    # shellcheck disable=SC1090
	    source_if_present "$token"
	done
    fi

    # Print message telling user about outdated packages on macOS
    brew_show_outdated Formulae /tmp/brew.outdated || true
    brew_show_outdated Casks /tmp/cask.outdated || true
    brew_show_outdated Apps /tmp/mas.outdated || true

    export HOMEBREW_MAINTAINER=1
    export HOMEBREW_DISPLAY_INSTALL_TIMES=1
    export HOMEBREW_NO_INSECURE_REDIRECT=1
    export HOMEBREW_CURL_RETRIES=4
    export HOMEBREW_BAT=1
    export HOMEBREW_NO_BOTTLE_SOURCE_FALLBACK=1

    export BAT_THEME=zenburn

    # Modules — lazy-load to avoid ~85ms Tcl interpreter startup
    if [ -f /usr/local/opt/modules/init/bash ]; then
	# shellcheck disable=SC1091
	module() { unset -f module; . /usr/local/opt/modules/init/bash; module "$@"; }
    fi

    if command -v dircolors > /dev/null 2>&1; then
	DIR_COLOR_PROG=dircolors
    elif command -v gdircolors > /dev/null 2>&1; then
	DIR_COLOR_PROG=gdircolors
    fi
    if [ -n "${DIR_COLOR_PROG:-}" ] && [ -r "$HOME/.dir_colors" ] ; then
	eval "$("${DIR_COLOR_PROG}" "$HOME/.dir_colors")"
    fi

    # NVM — lazy-load to avoid ~0.5s startup cost
    export NVM_DIR="$HOME/.nvm"
    if [ -s "$NVM_DIR/nvm.sh" ]; then
	_nvm_lazy_load() {
	    unset -f nvm node npm npx
	    # shellcheck disable=SC1091
	    \. "$NVM_DIR/nvm.sh"
	    # shellcheck disable=SC1091
	    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
	}
	nvm()  { _nvm_lazy_load; nvm  "$@"; }
	node() { _nvm_lazy_load; node "$@"; }
	npm()  { _nvm_lazy_load; npm  "$@"; }
	npx()  { _nvm_lazy_load; npx  "$@"; }
    fi

    # 1password completion — cached for speed, refreshed on first `op` use
    if command -v op > /dev/null 2>&1 ; then
	_op_cache="${HOME}/.cache/op/completion.bash"
	if [ -f "$_op_cache" ]; then
	    # shellcheck disable=SC1090
	    . "$_op_cache"
	else
	    mkdir -p "${HOME}/.cache/op"
	    chmod 700 "${HOME}/.cache/op"
	    op completion bash > "$_op_cache"
	    chmod 600 "$_op_cache"
	    # shellcheck disable=SC1090
	    . "$_op_cache"
	fi
	op() {
	    unset -f op
	    command op "$@"
	    local _ret=$?
	    # Refresh cache in background for next shell
	    op completion bash > "${HOME}/.cache/op/completion.bash" 2>/dev/null &
	    disown
	    return $_ret
	}
	unset _op_cache
    fi

    # shellcheck disable=SC1091
    source_if_present ~/.fzf.bash
fi

PATH="$(dedupe_path PATH)"
export PATH

# Turn off profiling/debugging if enabled
if [[ "${PROFILE_STARTUP}" == true ]]; then
    set +x
    PS4='+ '
fi
if [[ "${DEBUG}" == true ]]; then
    unset  BASH_XTRACEFD
    set +x
    set +o verbose
    set +o errexit
fi
