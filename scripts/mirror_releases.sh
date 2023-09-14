#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

requested_version="${1-}"
url="https://api.github.com/repos/swc-project/swc/releases"

if [[ -z "$requested_version" ]]; then
  url="${url}?per_page=1"
else
  # Get a lot of releases to match against.
  url="${url}?per_page=50"
fi

releases=$(curl -sSL -H 'Accept: application/vnd.github.v3+json' $url | jq -f $(pwd)/scripts/filter.jq)
versions=$(echo $releases | jq --raw-output 'keys[]')

for version in $versions; do
    if [[ -z "$requested_version" ]] || [[ "$requested_version" == "$version" ]]; then
        echo "    \"$version\": {"
        assets=$(echo $releases | jq --raw-output --arg v "$version" '.["\($v)"] | keys[]')
        for asset in $assets; do
            url=$(echo $releases | jq --raw-output --arg v "$version" --arg a "$asset" '.["\($v)"] | .["\($a)"]')
            echo "        \"${asset%.exe}\": \"sha384-$(curl -sSL $url | shasum -b -a 384 | awk "{ print \$1 }" | xxd -r -p | base64)\","
        done
        echo "    },"
    fi
done

echo "Now, paste the above output into swc/private/versions.bzl as the first entry in TOOL_VERSIONS"
