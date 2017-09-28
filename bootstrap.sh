#!/usr/bin/env bash

# Development script for OS X
# Origin Author: Rogelio J. Samour from https://gist.github.com/1347350
# Modifications by Andrew Warner and Izaak Beeman
# - Customizes it slightly
# - Allows it to be re-run to standardize and environment
# Warning:
#   While it is unlikely any code below might damage your system,
#   it’s always a good idea to back up everything that matters to you
#   before running this script! Just in case. I am not responsible for
#   anything that may result from running this script. Proceed at
#   your own risk.
# License: See below


if ! xcode-select -p &> /dev/null && [[ ! -f "/Developer/Library/uninstall-devtools" ]]; then
  read -r -p "Please install Xcode and re-run this script"
  exit 0
fi

xcode-select --install

sudo xcodebuild -license

if [ -n "$WORKSPACE_DIR" ]; then
  # don't let them change it if it's already set
  DEFAULT_WORKING_DIRECTORY=$WORKSPACE_DIR
else
  DEFAULT_WORKING_DIRECTORY=$HOME/Sandbox
  echo "Please enter your local working directory (or hit Return to stick with '$DEFAULT_WORKING_DIRECTORY')"
  read -r working_dir
fi

if [ -n "$working_dir" ]; then
  export WORKSPACE_DIR=$working_dir
else
  export WORKSPACE_DIR=$DEFAULT_WORKING_DIRECTORY
fi

echo "Creating $WORKSPACE_DIR"
mkdir -p "$WORKSPACE_DIR"

echo "Please enter a host name (or hit Return to stay with '$HOSTNAME'): "
read -r computername

if [ -n "$computername" ]; then
  if [[ $computername =~ \.local$ ]]; then
    newhostname=$computername
  else
    newhostname="$computername.local"
  fi
  echo "Changing host name to $computername"
  scutil --set ComputerName "$computername"
  scutil --set LocalHostName "$computername"
  scutil --set HostName "$newhostname"
else
  echo "Not changing host name"
fi

if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "Please enter your email: "
  read -r email
  ssh-keygen -t rsa -C "$email"
  cat "$HOME/.ssh/id_rsa.pub"
fi

pbcopy < "$HOME/.ssh/id_rsa.pub"
read -r -p "Your public ssh key is in your pasteboard. Add it to github.com if it's not already there and hit Return"

echo "Starting ssh-agent and adding key"
eval "$(ssh-agent -s)"
ssh-add -K "$HOME/.ssh/id_rsa"

# shellcheck disable=SC2016
if ! grep '. "$HOME/.bashrc"' "$HOME/.bash_profile" > /dev/null ; then
  echo "Making .bash_profile source .bashrc"
  # shellcheck disable=SC2016
  echo '. "$HOME/.bashrc"' >> "$HOME/.bash_profile"
fi

if ! command -v brew > /dev/null; then
  echo "Installing homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew update
brew doctor
brew tap homebrew/bundle

echo "Installing tons of software via Homebrew... this could take a while..."
echo "Homebrew is installing standard packages..."

brew bundle --force

echo "Removing system gems"
sudo -i 'gem update --system'
sudo -i 'gem clean'

echo "Preparing system for dotfiles"

cd "$WORKSPACE_DIR" || exit 5
if [ ! -d "$HOME/dotfiles" ]; then
  git clone --recursive https://github.com/zbeekman/dotfiles dotfiles
  cd "$HOME/dotfiles" || exit 4
else
  cd "$HOME/dotfiles" || exit 3
  git pull --rebase
fi

git submodule init
git submodule update

echo "Writing .gemrc"
cat > "$HOME/.gemrc" <<GEMRC
---
:benchmark: false
gem: --no-ri --no-rdoc
:update_sources: true
:bulk_threshold: 1000
:verbose: true
:sources:
- https://rubygems.org
:backtrace: false
GEMRC

echo "Setting a shorter Delay until key repeat..."
defaults write -g InitialKeyRepeat -int 10 # normal minimum is 15 (225 ms)
defaults write -g KeyRepeat -int 2 # normal minimum is 2 (30 ms)

echo "Setting a blazingly fast keyboard repeat rate..."
defaults write NSGlobalDomain KeyRepeat -int 0

if [[ ! -f "$HOME/.bashrc" ]]; then
  touch "$HOME/.bashrc"
fi

# shellcheck source=/Users/ibeekman/.profile
[[ -f "$HOME/.profile" ]] && source "$HOME/.profile"
# shellcheck source=/Users/ibeekman/.bash_profile
[[ -f "$HOME/.bash_profile" ]] && source "$HOME/.bash_profile"
echo "Finished."

(cd ~ || exit 6
 ln -s dotfiles/secrets/.secrets
 ln -s dotfiles/screen/.screenrc
 ln -s .Brewfile dotfiles/Brewfile
 for d in dotfiles/git/.*/ ; do
   ln -s "$d"
 done
 (cd .ssh || exit 7
   ln -s ../dotfiles/ssh/.ssh/config
   ln -s ../dotfiles/ssh/.ssh/tmp
   ln -s ../dotfiles/ssh/.ssh/known_hosts
 )
)

if [[ -e /usr/local/bin/bash ]]; then
  echo "Adding Homebrew installed bash to allowable shells"
  echo "/usr/loca/bin/bash" | sudo tee -a /etc/shells
  chsh -s /usr/local/bin/bash "$USER"
fi

echo "To activate keyboard layout, restart computer then >System Preferences >Language and Region >Keyboard Preferences >Input Sources"
echo "Then click \"+\" and select \"others\" on the left hand side pane. Select the layout just added"
sudo cp "./osx-keylayout/My Layout.keylayout" "/Library/Keyboard Layouts"

# Copyright (c) 2011 Rogelio J. Samour

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
# OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
