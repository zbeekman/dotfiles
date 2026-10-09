#!/usr/bin/env bats
# Static checks on the shell startup files: lint, shebangs, installer sentinels.

load helpers

STARTUP_FILES=(.shell-lib.sh .profile .bash_profile .zprofile)
SENTINEL_FILES=(.profile .bash_profile .zprofile)

@test "shellcheck passes on startup files and test helpers" {
  if ! command -v shellcheck >/dev/null 2>&1; then
    skip "shellcheck not installed"
  fi
  cd "$REPO"
  run shellcheck -x "${STARTUP_FILES[@]}" tests/helpers.bash
  assert_success
}

@test "every startup file has a shebang on line 1 (nothing injected above it)" {
  local f
  for f in "${STARTUP_FILES[@]}"; do
    run head -1 "$REPO/$f"
    assert_output --regexp '^#!'
  done
}

@test "no trailing whitespace in startup files" {
  local f
  for f in "${STARTUP_FILES[@]}"; do
    run grep -nE '[[:space:]]+$' "$REPO/$f"
    assert_failure
  done
}

@test "each login file carries exactly one Docker Desktop sentinel" {
  local f
  for f in "${SENTINEL_FILES[@]}"; do
    run grep -c 'added by Docker Desktop' "$REPO/$f"
    assert_output "1"
    run grep -c 'End of Docker Desktop section' "$REPO/$f"
    assert_output "1"
  done
}

@test ".bash_profile and .zprofile delegate to ~/.profile" {
  run grep -E '\. "\$\{HOME\}/\.profile"' "$REPO/.bash_profile"
  assert_success
  run grep -E "emulate sh -c '\. ~/\.profile'" "$REPO/.zprofile"
  assert_success
}

@test "bootstrap.sh links every startup file into \$HOME" {
  local f
  for f in "${STARTUP_FILES[@]}"; do
    run grep -F "ln -s dotfiles/$f" "$REPO/bootstrap.sh"
    assert_success
  done
}
