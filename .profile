
#!/bin/sh
# shellcheck shell=sh

export DOT_PROFILE_SOURCED="yes"

if [ "$(uname)" = "Linux" ] ; then
    setxkbmap -layout us -option ctrl:nocaps
fi

emacs --help > /dev/null 2>&1 && export EDITOR="emacs -nw" && export VISUAL=emacs
less --help > /dev/null 2>&1 && export PAGER=less
if [ -d "${WORKDIR}" ]; then # DSRCs
  export TMPDIR="${WORKDIR}/tmp"
  export TMP="${WORKDIR}/tmp"
fi
if [ -d "${HOME}/.local/bin" ]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi
if [ -d "${HOME}/taucmdr/bin" ]; then
  export PATH="${HOME}/taucmdr/bin:${PATH}"
fi
export CTEST_OUTPUT_ON_FAILURE=1
export XML_CATALOG_FILES="/usr/local/etc/xml/catalog"
if [ -d "/usr/local/bin" ]; then
  export PATH="/usr/local/bin:${PATH}"
fi
if [ -d /usr/local/opt/jenv ]; then
  export JENV_ROOT=/usr/local/opt/jenv
elif [ -d "${HOME}/.jenv/bin" ]; then
  export PATH="${HOME}/.jenv/bin:${PATH}"
fi
jenv --help > /dev/null 2>&1 && eval "$(jenv init -)"

[ -d "/usr/local/sbin" ] && export PATH="/usr/local/sbin:${PATH}"
[ -d "/usr/local/opt/go" ] && export GOROOT="/usr/local/opt/go"
if [ -z "${GOPATH}" ]; then
    [ -d "${HOME}/go" ] && export GOPATH="${HOME}/go"
else
    [ -d "${HOME}/go" ] && export GOPATH="${HOME}/go:${GOPATH}"
fi

if [ -d "${GOPATH}/bin" ]; then
    export PATH="${PATH}:${GOPATH}/bin"
fi

export CLICOLOR=1
export GREP_COLORS="fn=34:mt=01;34:ln=01;30:se=30"
export HISTSIZE=""
export HISTFILESIZE=""
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S UTC%z] "
export HISTIGNORE="pwd:ls:ls -ltr:ls -lAhF:cd ..:.."
export HISTCONTROL="ignoreboth"

# less pager customization
# +--- Blink ---+
LESS_TERMCAP_mb="$(printf '\e[01;34m')"
export LESS_TERMCAP_mb

# +--- Keywords ---+
LESS_TERMCAP_md="$(printf '\e[01;34m')"
export LESS_TERMCAP_md

# +--- Mode Stop ---+
LESS_TERMCAP_me="$(printf '\e[0m')"
export LESS_TERMCAP_me

# +--- Standout-Mode (Info Box) ---+
LESS_TERMCAP_so="$(printf '\e[01;30m')"
export LESS_TERMCAP_so
LESS_TERMCAP_se="$(printf '\e[0m')"
export LESS_TERMCAP_se

# +--- Constants ---+
LESS_TERMCAP_us="$(printf '\e[01;34m')"
export LESS_TERMCAP_us
LESS_TERMCAP_ue="$(printf '\e[0m')"
export LESS_TERMCAP_ue

### LESS ###
# Enable syntax-highlighting in less.
# brew install source-highlight
# First, add these two lines to ~/.bashrc
if highlight --help > /dev/null 2>&1 ; then # we have highlight on the path
  LESSOPEN="| $(type -P highlight) %s --out-format xterm256 --quiet --force --style candy"
  show(){
      highlight "$@" --out-format xterm256 --line-numbers --quiet --force --style candy
  }
fi
export LESSOPEN
export LESS=" -i -R -J "

if [ -n "${PKG_CONFIG_PATH}" ]; then
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}"
else
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
fi

export __TAUCMDR_PROGRESS_BARS__="disabled"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
# shellcheck disable=SC2015
[ -d "${HOME}/.rvm/bin" ] && export PATH="${PATH}:${HOME}/.rvm/bin" || true

# shellcheck disable=SC1090,SC2015
[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" || true # Load RVM into a shell session *as a function*


if keychain --help > /dev/null ; then
    eval "$(keychain --agents "gpg,ssh" --eval)"
    export GPG_AGENT_PID="$(pgrep gpg-agent)"
    export SSH_AGENT_PID="$(pgrep ssh-agent)"
else
    if pid="$(pgrep gpg-agent)" ; then
        export GPG_AGENT_PID="$pid"
    else
        gpgconf --launch gpg-agent
        GPG_AGENT_PID="$(pgrep gpg-agent)"
    fi
fi
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)

if [ "$(basename "${SHELL}")" = "bash" ]; then
  # shellcheck source=/Users/ibeekman/dotfiles/.bashrc
  [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
fi
# Uncomment to enable pretty prompt:
# export MOOSE_PROMPT=true

# Uncomment to enable autojump:
# export MOOSE_JUMP=true

# # Source MOOSE profile
# if [ -f /opt/moose/environments/moose_profile ]; then
#     . /opt/moose/environments/moose_profile
# fi
