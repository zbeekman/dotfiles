#!/usr/bin/env bash
# shellcheck shell=bash
#
# Shared setup for the .bats files: loads bats-support/bats-assert and
# discovers which interpreters are available on this machine.

bats_require_minimum_version 1.5.0

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'

REPO="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"
export REPO

# Prefer Homebrew bash over macOS /bin/bash (3.2): .bashrc targets bash >= 4.2
pick_bash() {
  local candidate
  for candidate in /opt/homebrew/bin/bash /usr/local/bin/bash; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done
  command -v bash
}
BASH_BIN=${BASH_BIN:-$(pick_bash)}
ZSH_BIN=${ZSH_BIN:-$(command -v zsh || true)}
export BASH_BIN ZSH_BIN

# POSIX interpreters to run .shell-lib.sh under; override with SHELLS="sh zsh"
posix_shells() {
  local sh
  for sh in ${SHELLS:-sh dash "$BASH_BIN" zsh}; do
    command -v "$sh" >/dev/null 2>&1 && printf '%s\n' "$sh"
  done
}

# Nth colon-separated PATH element containing DIR (1-based), empty if absent
path_index() {
  printf '%s\n' "$1" | tr ':' '\n' | grep -Fxn -- "$2" | head -1 | cut -d: -f1
}

# Number of PATH elements exactly equal to DIR
path_count() {
  printf '%s\n' "$1" | tr ':' '\n' | grep -Fxc -- "$2"
}
