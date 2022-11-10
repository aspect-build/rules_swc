#!/usr/bin/env bash
set -o errexit

cd "$TEST_SRCDIR/$TEST_WORKSPACE/$(dirname $TEST_TARGET)"
grep "export var a" out_dir/out/a.js
grep "sourceMappingURL=a.js.map" out_dir/out/a.js
grep --fixed-strings '"sources":["../a.ts"]' out_dir/out/a.js.map

grep "export var b" out_dir/out/b.js
grep "sourceMappingURL=b.js.map" out_dir/out/b.js
grep --fixed-strings '"sources":["../b.ts"]' out_dir/out/b.js.map