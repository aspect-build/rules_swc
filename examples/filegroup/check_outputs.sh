#!/usr/bin/env bash
set -o errexit

cd "$TEST_SRCDIR/$TEST_WORKSPACE/$(dirname $TEST_TARGET)"

grep "export var a" filegroup/a.js
grep "sourceMappingURL=a.js.map" filegroup/a.js
grep --fixed-strings '"sourceRoot":""' filegroup/a.js.map
grep --fixed-strings '"sources":["a.ts"]' filegroup/a.js.map

grep "export var b" filegroup/b.js
grep "sourceMappingURL=b.js.map" filegroup/b.js
grep --fixed-strings '"sourceRoot":""' filegroup/b.js.map
grep --fixed-strings '"sources":["b.ts"]' filegroup/b.js.map

grep "export var c" filegroup/sub/c.js
grep "sourceMappingURL=c.js.map" filegroup/sub/c.js
grep --fixed-strings '"sourceRoot":""' filegroup/sub/c.js.map
grep --fixed-strings '"sources":["c.ts"]' filegroup/sub/c.js.map