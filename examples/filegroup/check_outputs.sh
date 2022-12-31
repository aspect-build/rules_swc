#!/usr/bin/env bash
set -o errexit

cd "$TEST_SRCDIR/$TEST_WORKSPACE/$(dirname $TEST_TARGET)"

grep "export var a" filegroup/a.js
grep "sourceMappingURL=a.js.map" filegroup/a.js
grep --fixed-strings '"sources":["examples/filegroup/a.ts"]' filegroup/a.js.map

grep "export var b" filegroup/b.js
grep "sourceMappingURL=b.js.map" filegroup/b.js
grep --fixed-strings '"sources":["examples/filegroup/b.ts"]' filegroup/b.js.map