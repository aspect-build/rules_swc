#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
VERSIONS_BZL="$SCRIPT_DIR/../swc/private/versions.bzl"

releases=$(curl -sSL -H 'Accept: application/vnd.github.v3+json' https://api.github.com/repos/swc-project/swc/releases?per_page=20 | jq -f "$SCRIPT_DIR/filter.jq")
versions=$(echo $releases | jq --raw-output 'keys[]')

# Combine the new versions with the existing ones.
# New versions should appear first, but existing content should overwrite new
OUT=$(mktemp)
python3 -c "import json; exec(open('$VERSIONS_BZL').read()); print(json.dumps(TOOL_VERSIONS))" > $OUT

# Sadly swc doesn't publish the checksums for their releases, so we have to compute them ourselves
EACH_VERSION=$(mktemp)
for version in $versions; do
    assets=$(echo $releases | jq --raw-output --arg v "$version" '.["\($v)"] | keys[]')

    ASSETS_FOR_VERSION=""
    for asset in $assets; do
        url=$(echo $releases | jq --raw-output --arg v "$version" --arg a "$asset" '.["\($v)"] | .["\($a)"]')
        sha=$(curl -sSL $url | shasum -b -a 384 | awk "{ print \$1 }" | xxd -r -p | base64)
        ASSETS_FOR_VERSION="${ASSETS_FOR_VERSION} \"${asset%.exe}\": \"sha384-${sha}\","
    done

    # Remove final trailing comma so it's valid JSON
    ASSETS_FOR_VERSION=${ASSETS_FOR_VERSION%,}
    echo "{\"$version\": { ${ASSETS_FOR_VERSION} }}" >$EACH_VERSION

    TMP=$(mktemp)
    jq --slurp '.[0] * .[1]' $EACH_VERSION $OUT > $TMP
    mv $TMP $OUT
done

# Locate the TOOL_VERSIONS declaration in the source file and replace it
NEW=$(mktemp)
sed '/TOOL_VERSIONS =/Q' $VERSIONS_BZL > $NEW
echo -n "TOOL_VERSIONS = " >> $NEW
cat $OUT >> $NEW
cat $NEW
cp $NEW $VERSIONS_BZL
