#!/bin/sh
# Test entry point for the shared build and release workflows. Expects the image reference in $IMAGE.
set -eu

: "${IMAGE:?IMAGE must be set to the image under test}"

tests_dir=$(dirname "$0")
sh "$tests_dir/smoke.sh"
sh "$tests_dir/finalize.sh"
echo "all tests passed for $IMAGE"
