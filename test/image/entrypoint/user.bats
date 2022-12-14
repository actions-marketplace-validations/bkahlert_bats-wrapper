#!/usr/bin/env bats
# bashsupport disable=BP5007

setup() {
  declare -r -g pattern='> %d <\n'
  declare -r -g puid='$(id -u)'
  declare -r -g pgid='$(id -g)'
}

@test "should persist APP_USER and APP_GROUP in entrypoint.sh" {
  image "$BUILD_TAG" .
  run docker cp "${BATS_TEST_NAME}:/usr/local/sbin/entrypoint.sh" -
  assert_line '  local -r app_user=tester app_group=tester'
}

@test "should change user ID to 1000 by default" {
  bats_test <<BATS >test.bats
  $(printf 'run printf "%b" "%b"' "$pattern" "$puid")
  trace
BATS
  IMAGE_PUID='' image "$BUILD_TAG" .
  assert_line --partial "> 1000 <"
}

@test "should change group ID to 1000 by default" {
  bats_test <<BATS >test.bats
  $(printf 'run printf "%b" "%b"' "$pattern" "$pgid")
  trace
BATS
  IMAGE_PGID='' image "$BUILD_TAG" .
  assert_line --partial "> 1000 <"
}

@test "should change user ID to specified ID" {
  bats_test <<BATS >test.bats
  $(printf 'run printf "%b" "%b"' "$pattern" "$puid")
  trace
BATS
  IMAGE_PUID="echo 2000" image "$BUILD_TAG" .
  assert_line --partial "> 2000 <"
}

@test "should change group ID to specified ID" {
  bats_test <<BATS >test.bats
  $(printf 'run printf "%b" "%b"' "$pattern" "$pgid")
  trace
BATS
  IMAGE_PGID="echo 2000" image "$BUILD_TAG" .
  assert_line --partial "> 2000 <"
}
