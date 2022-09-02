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

readonly in_folder=$(rlocation $TEST_WORKSPACE/$(dirname $TEST_BINARY)/minify)
readonly expected="$in_folder/bazel-out/k8-fastbuild/bin/examples/directory/split_app/file1.js"
if ! [[ -e "$expected" ]]; then
    echo >&2 -e "Missing expected output file\n$expected in directory:"
    ls -R $in_folder
    exit 1
fi

if ! [[ -e $in_folder/directory/$1/file2.js ]]; then
    echo >&2 "Missing expected output file in directory"
    ls -R $in_folder
    exit 1
fi

if ! [[ -e $in_folder/directory/$1/file1.js.map ]]; then
    echo >&2 "Missing expected output file in directory"
    ls -R $in_folder
    exit 1
fi

if ! [[ -e $in_folder/directory/$1/file2.js.map ]]; then
    echo >&2 "Missing expected output file in directory"
    ls -R $in_folder
    exit 1
fi