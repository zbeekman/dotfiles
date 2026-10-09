#!/usr/bin/env bats
# Integration tests: build a throwaway $HOME wired like bootstrap.sh does, then
# start real interactive login shells against it from a scrubbed environment.

load helpers

setup_file() {
  FAKE_HOME="$(mktemp -d)"
  export FAKE_HOME
  mkdir -p "$FAKE_HOME/.ssh" "$FAKE_HOME/.docker/bin" "$FAKE_HOME/.cargo/bin" "$FAKE_HOME/.local/bin"
  # deliberately absent: $FAKE_HOME/taucmdr/bin and $FAKE_HOME/fpm/bin
  local f
  for f in .shell-lib.sh .profile .bash_profile .zprofile .bashrc .bashrc.personal .bash_aliases; do
    ln -s "$REPO/$f" "$FAKE_HOME/$f"
  done
  # bash-only integration hook: .profile must source it under bash, never zsh
  printf 'ITERM_SOURCED=1\n' > "$FAKE_HOME/.iterm2_shell_integration.bash"
}

teardown_file() {
  if [[ -f "$FAKE_HOME/.ssh/agent-env" ]]; then
    # .profile starts an ssh-agent when none is inherited; reap it
    # shellcheck disable=SC1091
    . "$FAKE_HOME/.ssh/agent-env"
    kill "${SSH_AGENT_PID:-}" 2>/dev/null || true
  fi
  rm -rf "$FAKE_HOME"
}

# login INTERPRETER COMMAND  -- interactive login shell, scrubbed env, stderr separated
login() {
  run --separate-stderr env -i HOME="$FAKE_HOME" PATH=/usr/bin:/bin:/usr/sbin:/sbin \
    TERM=dumb USER="${USER:-tester}" "$1" -l -i -c "$2"
}

# Expected stderr noise from interactive shells without a controlling tty
NOISE='cannot set terminal process group|no job control in this shell|can.t change option: zle'

assert_clean_stderr() {
  run grep -Ev -- "$NOISE" <<<"$stderr"
  refute_output --regexp '(not found|No such file|unknown argument|syntax error|bad option|unbound variable|substring expression)'
}

PROBE='printf "PATH=%s\n" "$PATH"; command -v dedupe_path >/dev/null 2>&1 && echo BASHRC=1 || echo BASHRC=0; echo ITERM=${ITERM_SOURCED:-0}'

path_of() {
  local p=${output#*PATH=}
  printf '%s\n' "${p%%$'\n'*}"
}

require_zsh() {
  [[ -n "$ZSH_BIN" ]] || skip "zsh not installed"
}

# --- bash ---------------------------------------------------------------------

@test "bash login: no errors on stderr" {
  login "$BASH_BIN" "$PROBE"
  assert_success
  assert_clean_stderr
}

@test "bash login: ~/.docker/bin appears exactly once" {
  login "$BASH_BIN" "$PROBE"
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/.docker/bin")" 1
}

@test "bash login: ~/.cargo/bin is first in PATH" {
  login "$BASH_BIN" "$PROBE"
  assert_equal "$(path_index "$(path_of)" "$FAKE_HOME/.cargo/bin")" 1
}

@test "bash login: ~/.local/bin appears exactly once" {
  login "$BASH_BIN" "$PROBE"
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/.local/bin")" 1
}

@test "bash login: absent dirs (taucmdr, fpm) are not added" {
  login "$BASH_BIN" "$PROBE"
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/taucmdr/bin")" 0
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/fpm/bin")" 0
}

@test "bash login: /usr/local/go/bin added iff it exists" {
  login "$BASH_BIN" "$PROBE"
  if [[ -d /usr/local/go/bin ]]; then
    assert_equal "$(path_count "$(path_of)" /usr/local/go/bin)" 1
  else
    assert_equal "$(path_count "$(path_of)" /usr/local/go/bin)" 0
  fi
}

@test "bash login: .bashrc reached via .bash_profile -> .profile" {
  login "$BASH_BIN" "$PROBE"
  assert_line "BASHRC=1"
}

@test "bash login: iTerm2 bash integration sourced" {
  login "$BASH_BIN" "$PROBE"
  assert_line "ITERM=1"
}

@test "bash login: re-sourcing .bash_profile does not duplicate PATH entries" {
  login "$BASH_BIN" '. ~/.bash_profile; . ~/.bash_profile; printf "PATH=%s\n" "$PATH"'
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/.docker/bin")" 1
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/.cargo/bin")" 1
}

# --- zsh ----------------------------------------------------------------------

@test "zsh login: no errors on stderr" {
  require_zsh
  login "$ZSH_BIN" "$PROBE"
  assert_success
  assert_clean_stderr
}

@test "zsh login: ~/.docker/bin appears exactly once" {
  require_zsh
  login "$ZSH_BIN" "$PROBE"
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/.docker/bin")" 1
}

@test "zsh login: ~/.cargo/bin is first in PATH" {
  require_zsh
  login "$ZSH_BIN" "$PROBE"
  assert_equal "$(path_index "$(path_of)" "$FAKE_HOME/.cargo/bin")" 1
}

@test "zsh login: .profile reached via .zprofile (~/.local/bin present once)" {
  require_zsh
  login "$ZSH_BIN" "$PROBE"
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/.local/bin")" 1
}

@test "zsh login: absent dirs are not added" {
  require_zsh
  login "$ZSH_BIN" "$PROBE"
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/taucmdr/bin")" 0
}

@test "zsh login: bash-only files (.bashrc, iTerm2 hook) are NOT sourced" {
  require_zsh
  login "$ZSH_BIN" "$PROBE"
  assert_line "BASHRC=0"
  assert_line "ITERM=0"
}

@test "zsh login: re-sourcing .zprofile does not duplicate PATH entries" {
  require_zsh
  login "$ZSH_BIN" 'source ~/.zprofile; source ~/.zprofile; printf "PATH=%s\n" "$PATH"'
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/.docker/bin")" 1
  assert_equal "$(path_count "$(path_of)" "$FAKE_HOME/.cargo/bin")" 1
}
