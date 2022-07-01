#!/usr/bin/env bash
# The pure-rust CLI is distributed within the platform-specific variant of the @swc/core npm package.

set -o errexit -o nounset -o pipefail

pkgs=$(curl --silent https://registry.npmjs.org/@swc/core/latest | jq --raw-output '.dependencies | keys[]')
version=$(curl --silent https://registry.npmjs.org/@swc/core/latest | jq --raw-output '.version')
echo "    \"v$version\": {"
for pkg in $pkgs; do
    echo "        \"${pkg#@swc/core-}\": $(curl --silent https://registry.npmjs.org/${pkg}/${version} | jq '.dist.integrity'),"
done
echo "    }"

echo
echo "Now, paste the above output into swc/private/versions.bzl"
