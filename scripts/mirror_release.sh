#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

releases=$(curl -sSL -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/swc-project/swc/releases?per_page=5 | jq -f $(pwd)/scripts/filter.jq)
versions=$(echo $releases | jq --raw-output 'keys[]')

echo -n "TOOL_VERSIONS = {"
echo ""

for version in $versions; do
    echo "    \"$version\": {"
    assets=$(echo $releases | jq --raw-output --arg v "$version" '.["\($v)"] | keys[]')
    for asset in $assets; do
        url=$(echo $releases | jq --raw-output --arg v "$version" --arg a "$asset" '.["\($v)"] | .["\($a)"]')
        echo "        \"$asset\": \"sha384-$(curl -sSL $url | shasum -b -a 384 | awk "{ print \$1 }" | xxd -r -p | base64)\","
    done
    echo "    },"
done
echo "}"

echo "Now, paste the above output into swc/private/versions.bzl"
