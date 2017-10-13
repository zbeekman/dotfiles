# shellcheck shell=sh
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
fi
eval "$(jenv init -)" || true
if [ -d "/usr/local/sbin" ]; then
  export PATH="/usr/local/sbin:${PATH}"
fi
[ -d /usr/local/opt/go ] && export GOROOT=/usr/local/opt/go
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
export LESSOPEN="| $(type -P highlight) %s --out-format xterm256 --quiet --force --style candy"
export LESS=" -i -R -J "
alias less='less -i -F -X -M -N -J'
alias more='less'
alias show="highlight $@ --out-format xterm256 --line-numbers --quiet --force --style candy"


# shellcheck source=/Users/ibeekman/.secrets/tokens
test -e "${HOME}/.secrets/tokens" && . "${HOME}/.secrets/tokens"

if [ "$(basename "${SHELL}")" = "bash" ]; then
  # shellcheck source=/Users/ibeekman/.bashrc
  [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
fi

if [ -n "${PKG_CONFIG_PATH}" ]; then
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig:${PKG_CONFIG_PATH}"
else
  export PKG_CONFIG_PATH="/usr/local/lib/pkgconfig"
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export PATH=$PATH:$GOPATH/bin

export __TAUCMDR_PROGRESS_BARS__="minimal"
