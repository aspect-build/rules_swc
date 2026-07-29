#!/usr/bin/env bash
set -o errexit

# Without args the loop below would assert nothing and pass vacuously.
if [ "$#" -eq 0 ]; then
  echo "expected at least one <js output path>=<expected sources entry> arg" >&2
  exit 1
fi

cd "$TEST_SRCDIR/$TEST_WORKSPACE/$(dirname $TEST_TARGET)"

# Each arg is <js output path>=<expected sources entry>, the output path being
# relative to the genrule package.
for pair in "$@"; do
  js="genrule/${pair%%=*}"
  src="${pair#*=}"
  name=$(basename "$js" .js)

  grep "export var $name" "$js"
  grep "sourceMappingURL=$name.js.map" "$js"
  grep -v --fixed-strings '"sourceRoot"' "$js.map"
  grep --fixed-strings "\"sources\":[\"$src\"]" "$js.map"
done
