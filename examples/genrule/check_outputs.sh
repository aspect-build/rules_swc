#!/usr/bin/env bash
set -o errexit

dir="genrule"
if $1; then
  dir="genrule/$1"
fi

cd "$TEST_SRCDIR/$TEST_WORKSPACE/$(dirname $TEST_TARGET)"

grep "export var a" $dir/a.js
grep "sourceMappingURL=a.js.map" $dir/a.js
grep -v --fixed-strings '"sourceRoot"' $dir/a.js.map
grep --fixed-strings '"sources":["a.ts"]' $dir/a.js.map

grep "export var b" $dir/b.js
grep "sourceMappingURL=b.js.map" $dir/b.js
grep -v --fixed-strings '"sourceRoot"' $dir/b.js.map
grep --fixed-strings '"sources":["b.ts"]' $dir/b.js.map

grep "export var c" $dir/sub/c.js
grep "sourceMappingURL=c.js.map" $dir/sub/c.js
grep -v --fixed-strings '"sourceRoot"' $dir/sub/c.js.map
grep --fixed-strings '"sources":["c.ts"]' $dir/sub/c.js.map
