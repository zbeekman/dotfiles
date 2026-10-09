#!/usr/bin/env bats
# Unit tests for .shell-lib.sh (path_prepend / path_append).
# Every test runs the same snippet under each available POSIX interpreter
# (sh, dash, bash, zsh) so the library stays portable.

load helpers

setup() {
  TMP="$(mktemp -d)"
  mkdir "$TMP/a" "$TMP/b" "$TMP/c" "$TMP/ab"
  touch "$TMP/file"
}

teardown() {
  rm -rf "$TMP"
}

# in_each_shell EXPECTED_PATH SNIPPET
# Runs SNIPPET (after sourcing the lib) under every interpreter and asserts the
# resulting PATH. Output is prefixed with the interpreter so failures name it.
in_each_shell() {
  local expected=$1 snippet=$2 sh
  while read -r sh; do
    run "$sh" -c ". '$REPO/.shell-lib.sh'; $snippet; printf '%s|%s' '$sh' \"\$PATH\""
    assert_success
    assert_output "$sh|$expected"
  done < <(posix_shells)
}

@test "at least two interpreters are available for portability coverage" {
  run posix_shells
  [ "${#lines[@]}" -ge 2 ]
}

@test "path_prepend puts dir first" {
  in_each_shell "$TMP/b:$TMP/a" "PATH='$TMP/a'; path_prepend '$TMP/b'"
}

@test "path_append puts dir last" {
  in_each_shell "$TMP/a:$TMP/c" "PATH='$TMP/a'; path_append '$TMP/c'"
}

@test "path_prepend of a present dir is a no-op and keeps its position" {
  in_each_shell "$TMP/b:$TMP/a" "PATH='$TMP/b:$TMP/a'; path_prepend '$TMP/a'"
}

@test "path_append of a present dir is a no-op and keeps its position" {
  in_each_shell "$TMP/b:$TMP/a" "PATH='$TMP/b:$TMP/a'; path_append '$TMP/b'"
}

@test "missing dir is skipped by both helpers and they still return 0" {
  in_each_shell "$TMP/a" "PATH='$TMP/a'; path_prepend '$TMP/missing' && path_append '$TMP/missing'"
}

@test "a regular file is not added" {
  in_each_shell "$TMP/a" "PATH='$TMP/a'; path_append '$TMP/file'"
}

@test "prepend onto empty PATH leaves no stray colon" {
  in_each_shell "$TMP/a" "PATH=''; path_prepend '$TMP/a'"
}

@test "append onto empty PATH leaves no stray colon" {
  in_each_shell "$TMP/a" "PATH=''; path_append '$TMP/a'"
}

@test "a dir whose name prefixes an existing entry is still added" {
  in_each_shell "$TMP/ab:$TMP/a" "PATH='$TMP/ab'; path_append '$TMP/a'"
}

@test "PATH is exported to child processes" {
  in_each_shell "$TMP/a:$TMP/b" "PATH='$TMP/a'; path_append '$TMP/b'; PATH=\$(/bin/sh -c 'printf %s \"\$PATH\"')"
}
