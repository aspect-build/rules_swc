#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

if [ ${1:-} ]; then
    # Fetch hashes of user supplied versions; these can be supplied as a list of arguments in the form:
    # ./script/mirror_releases.sh v1.2.3 v1.2.4 v1.2.5
    releases=$(curl -sSL -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/swc-project/swc/releases?per_page=100 | jq -f $(pwd)/scripts/filter.jq)
    versions=$@
else
    # Fetch hashes of just the latest version
    releases=$(curl -sSL -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/swc-project/swc/releases?per_page=1 | jq -f $(pwd)/scripts/filter.jq)
    versions=$(echo $releases | jq --raw-output 'keys[]')
fi

for version in $versions; do
    echo "    \"$version\": {"
    assets=$(echo $releases | jq --raw-output --arg v "$version" '.["\($v)"] | keys[]')
    for asset in $assets; do
        url=$(echo $releases | jq --raw-output --arg v "$version" --arg a "$asset" '.["\($v)"] | .["\($a)"]')
        echo "        \"${asset%.exe}\": \"sha384-$(curl -sSL $url | shasum -b -a 384 | awk "{ print \$1 }" | xxd -r -p | base64)\","
    done
    echo "    },"
done

echo "Now, paste the above output into swc/private/versions.bzl as the first entry in TOOL_VERSIONS"
