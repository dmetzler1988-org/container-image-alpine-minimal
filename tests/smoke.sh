#!/bin/sh
# Smoke tests for alpine-minimal. Expects the image reference in $IMAGE.
set -eu

: "${IMAGE:?IMAGE must be set to the image under test}"

readonly EXPECTED_UID=10001
readonly EXPECTED_GID=10001
readonly CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt
readonly ZONEINFO_SAMPLE=/usr/share/zoneinfo/Europe/Zurich
readonly FINALIZE=/usr/local/sbin/finalize
readonly BASE_NAME_LABEL=org.opencontainers.image.base.name

fail() {
  echo "FAIL (smoke): $*" >&2
  exit 1
}

pass() {
  echo "ok (smoke): $*"
}

run() {
  docker run --rm "$IMAGE" "$@"
}

uid=$(run id -u)
[ "$uid" = "$EXPECTED_UID" ] || fail "runs as uid $uid, expected $EXPECTED_UID"
gid=$(run id -g)
[ "$gid" = "$EXPECTED_GID" ] || fail "runs as gid $gid, expected $EXPECTED_GID"
pass "runs as $EXPECTED_UID:$EXPECTED_GID"

run test -s "$CA_BUNDLE" || fail "CA bundle $CA_BUNDLE missing"
pass "CA bundle present"

run test -f "$ZONEINFO_SAMPLE" || fail "time zone data missing ($ZONEINFO_SAMPLE)"
pass "time zone data present"

docker run --rm --user 0 "$IMAGE" apk info -e ca-certificates tzdata > /dev/null || fail "apk cannot read its package database"
pass "apk works as root"

run test -x "$FINALIZE" || fail "$FINALIZE missing or not executable"
pass "finalize installed"

base_name=$(docker inspect --format "{{ index .Config.Labels \"$BASE_NAME_LABEL\" }}" "$IMAGE")
alpine_release=$(run cat /etc/alpine-release)
if [ "$base_name" = "unknown" ]; then
  pass "base image label not set (local build), version check skipped"
else
  [ "${base_name##*:}" = "$alpine_release" ] || fail "label $BASE_NAME_LABEL=$base_name but /etc/alpine-release is $alpine_release"
  pass "base image label matches Alpine $alpine_release"
fi
