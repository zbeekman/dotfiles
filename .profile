# shellcheck shell=sh
which emacs > /dev/null 2>&1 && export EDITOR="emacs -nw"
which less > /dev/null 2>&1 && export PAGER=less
if [ -d "${WORKDIR}" ]; then # DSRCs
  export TMPDIR="${WORKDIR}/tmp"
  export TMP="${WORKDIR}/tmp"
fi
if [ -d "${HOME}/.local/bin" ]; then
  export PATH="${HOME}/.local/bin:${PATH}"
fi
export CTEST_OUTPUT_ON_FAILURE=1
#export VAGRANT_SERVER_URL="https://sourceryinstitute-vagrant-Sourcery-Institute-Lubuntu-VM.bintray.io"
export XML_CATALOG_FILES="/usr/local/etc/xml/catalog"
if [ -d "/usr/local/texlive/2016/bin/x86_64-darwin" ]; then
  export PATH="/usr/local/texlive/2016/bin/x86_64-darwin:${PATH}"
fi
if [ -d "/usr/local/bin" ]; then
  export PATH="/usr/local/bin:${PATH}"
fi
if [ -d "${HOME}/.jenv/bin" ]; then
  export PATH="${HOME}/.jenv/bin:${PATH}"
  eval "$(jenv init -)" || true
fi

[ -d "/usr/local/sbin" ] && export PATH="/usr/local/sbin:${PATH}"
[ -d "/usr/local/opt/go" ] && export GOROOT="/usr/local/opt/go"
[ -d "${HOME}/go" ] && export GOPATH="${HOME}/go"
export CLICOLOR=1
export GREP_COLORS="fn=34:mt=01;34:ln=01;30:se=30"
export HISTSIZE=""
export HISTFILESIZE=""
export HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S UTC%z] "
export HISTIGNORE="pwd:ls:ls -ltr:ls -lAhF:cd ..:.."
export HISTCONTROL="ignoreboth"
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
if which highlight > /dev/null 2>&1 ; then # we have highlight on the path
  LESSOPEN="| $(which highlight) %s --out-format xterm256 --quiet --force --style candy"
  alias show="highlight $@ --out-format xterm256 --line-numbers --quiet --force --style candy"
fi
export LESSOPEN
export LESS=" -i -R -J "
alias less='less -i -F -X -M -N -J'
alias more='less'



if [ "$(basename "${SHELL}")" = "bash" ]; then
  # shellcheck source=/Users/ibeekman/.bashrc
  [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
fi

if [ -n "${PKG_CONFIG_PATH}" ]; then
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}"
else
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
fi

export PATH="${PATH}:${GOPATH}/bin"

#export __TAUCMDR_PROGRESS_BARS__="minimal"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
[ -d "${HOME}/.rvm/bin" ] && export PATH="${PATH}:${HOME}/.rvm/bin"

# shellcheck disable=SC1091
[ -s "$HOME/.rvm/scripts/rvm" ] && . "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

which asciinema > /dev/null 2>&1 && alias asciinema="LC_ALL=en_IN.UTF-8 asciinema"

[ -d "/p/work/sameer/ff/firefox" ] && export PATH="/p/work/sameer/ff/firefox:${PATH}"
