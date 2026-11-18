#!/bin/sh
# Tests for /usr/local/sbin/finalize. Expects the image reference in $IMAGE.
set -eu

: "${IMAGE:?IMAGE must be set to the image under test}"

readonly FINALIZE=/usr/local/sbin/finalize
readonly APK_DB=/lib/apk/db/installed

fail() {
  echo "FAIL (finalize): $*" >&2
  exit 1
}

pass() {
  echo "ok (finalize): $*"
}

if docker run --rm "$IMAGE" "$FINALIZE" > /dev/null 2>&1; then
  fail "finalize ran as non-root user, expected a refusal"
fi
pass "refuses to run as non-root"

# Plant a setuid file, run finalize twice, then check the result inside the same container.
result=$(docker run --rm --user 0 --entrypoint /bin/sh "$IMAGE" -c "
  touch /usr/local/bin/planted && chmod 4755 /usr/local/bin/planted
  $FINALIZE > /dev/null || { echo 'first run failed'; exit 0; }
  $FINALIZE > /dev/null || { echo 'second run failed'; exit 0; }
  if command -v apk > /dev/null 2>&1; then echo 'apk still present'; exit 0; fi
  if [ ! -s $APK_DB ]; then echo 'package database removed'; exit 0; fi
  if [ -e /etc/apk ]; then echo '/etc/apk still present'; exit 0; fi
  if [ -n \"\$(find / -xdev -type f \\( -perm -4000 -o -perm -2000 \\) 2>/dev/null)\" ]; then echo 'setuid files remain'; exit 0; fi
  if ! command -v sh > /dev/null 2>&1; then echo 'shell removed'; exit 0; fi
  echo ok
")
[ "$result" = "ok" ] || fail "$result"
pass "removes apk and setuid bits, keeps package database and shell, safe to run twice"

if docker run --rm --user 0 --entrypoint /bin/sh "$IMAGE" -c "rm -f $APK_DB && $FINALIZE" > /dev/null 2>&1; then
  fail "finalize ran without a package database, expected a refusal"
fi
pass "refuses to run without a package database"
