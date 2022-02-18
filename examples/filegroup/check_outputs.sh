#!/usr/bin/env bash
set -o errexit

cd "$TEST_SRCDIR/$TEST_WORKSPACE/$(dirname $TEST_TARGET)"
grep "export var a" filegroup/a.js
grep "sourceMappingURL=a.js.map" filegroup/a.js
grep "../../../../../examples/filegroup/a.ts" filegroup/a.js.map