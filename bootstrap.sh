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

xcode-select -p &> /dev/null
if [ ["$?" -ne "0"] -a [! -f "/Developer/Library/uninstall-devtools"] ]; then
  read -p "Please install Xcode and re-run this script"
  exit 0
fi

sudo xcodebuild -license

xcode-select --install

if [ -n "$WORKSPACE_DIR" ]; then
  # don't let them change it if it's already set
  DEFAULT_WORKING_DIRECTORY=$WORKSPACE_DIR
else
  DEFAULT_WORKING_DIRECTORY=$HOME/Sandbox
  echo "Please enter your local working directory (or hit Return to stick with '$DEFAULT_WORKING_DIRECTORY')"
  read working_dir
fi

if [ -n "$working_dir" ]; then
  export WORKSPACE_DIR=$working_dir
else
  export WORKSPACE_DIR=$DEFAULT_WORKING_DIRECTORY
fi

echo "Creating $WORKSPACE_DIR"
mkdir -p $WORKSPACE_DIR

echo "Please enter a host name (or hit Return to stay with '$HOSTNAME'): "
read computername

if [ -n "$computername" ]; then
  if [[ $computername =~ \.local$ ]]; then
    newhostname=$computername
  else
    newhostname="$computername.local"
  fi
  echo "Changing host name to $computername"
  scutil --set ComputerName $computername
  scutil --set LocalHostName $computername
  scutil --set HostName $newhostname
else
  echo "Not changing host name"
fi

if [ ! -f "$HOME/.ssh/id_rsa.pub" ]; then
  echo "Please enter your email: "
  read email
  ssh-keygen -t rsa -C "$email"
  cat $HOME/.ssh/id_rsa.pub
fi

cat $HOME/.ssh/id_rsa.pub | pbcopy
read -p "Your public ssh key is in your pasteboard. Add it to github.com if it's not already there and hit Return"

echo "Removing system gems"
sudo -i 'gem update --system'
sudo -i 'gem clean'

grep '. "$HOME/.bashrc"' $HOME/.bash_profile > /dev/null
if [[ "$?" -ne "0" ]]; then
  echo "Making .bash_profile source .bashrc"
  echo '. "$HOME/.bashrc"' >> $HOME/.bash_profile
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

brew bundle

echo "Preparing system for dotfiles"

cd $WORKSPACE_DIR
if [ ! -d "$HOME/dotfiles" ]; then
  git clone --recursive https://github.com/zbeekman/dotfiles dotfiles
  cd dotfiles
else
  cd dotfiles
  git pull --rebase
fi

git submodule init
git submodule update

echo "Writing .gemrc"
cat > $HOME/.gemrc <<GEMRC
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
defaults write NSGlobalDomain InitialKeyRepeat -int 12

echo "Setting a blazingly fast keyboard repeat rate..."
defaults write NSGlobalDomain KeyRepeat -int 0

source $HOME/.bash_profile
echo "Finished."

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
