#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail
SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
RAW=$(mktemp)

echo "Fetching release list from GitHub..."
(
  echo -e '"Mirror of release info"\n'
  echo -n "TOOL_VERSIONS = "
  curl --silent \
    -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/swc-project/swc/releases?per_page=2 \
    | jq -f $SCRIPT_DIR/filter.jq
) > $RAW

cat $RAW

echo "Fetching binaries to calculate their SHA-384..."

# sedd uses gnu-sed on darwin (https://formulae.brew.sh/formula/gnu-sed)
# install on macos with `brew install gnu-sed`
sedd () {
  case $(uname) in
    Darwin*) gsed "$@" ;;
    *) sed "$@" ;;
  esac
}

# FIXME: this is very slow, but only the md5 hash is available from S3 in a HEAD request, and bazel doesn't accept that
# Unsupported checksum algorithm: 'https://github.com/swc-project/swc/releases/download/v1.2.118/swc.linux-x64-gnu.node' (expected SHA-1, SHA-256, SHA-384, or SHA-512) at /home/alexeagle/Projects/rules_swc/WORKSPACE:17:24
sedd -r 's#\s+(.*): "(https://github.com.*\.node)#echo "    \\"\1\\": \\"\"sha384-$(curl --silent -L "\2" | shasum -b -a 384 | awk "{ print $1 }" | xxd -r -p | base64)\\""#e' < $RAW # | tee $SCRIPT_DIR/../swc/private/versions.bzl
