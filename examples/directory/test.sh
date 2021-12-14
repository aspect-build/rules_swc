#!/usr/bin/env bash

# --- begin runfiles.bash initialization v2 ---
# Copy-pasted from the Bazel Bash runfiles library v2.
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
  source "$0.runfiles/$f" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
  { echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---

set -o errexit

ARCH=$1
readonly in_folder=$(rlocation $TEST_WORKSPACE/$(dirname $TEST_BINARY)/minify)

# Due to https://github.com/swc-project/swc/issues/3028 the path is longer than we'd like
# It should really just contain $in_folder/file1.js
if ! [[ -e $in_folder/$ARCH/bin/examples/directory/split_app/file1.js ]]; then
    echo >&2 "Missing expected output file in directory"
    exit 1
fi
