try {
  require("./b")();
} catch (e) {
  const assert = require("assert");
  const frames = e.stack
    .split("\n")
    .slice(1)
    .map((s) => s.trim());
  assert.deepEqual(
    frames.filter((f) => f.includes("source_map_support/test/simple/a")),
    [
      `at Object.<anonymous> (examples/source_map_support/test/simple/a.ts:2:11)`,
    ],
  );
  assert.deepEqual(
    frames.filter((f) => f.includes("source_map_support/test/simple/b")),
    [`at foo (examples/source_map_support/test/simple/b.ts:2:9)`],
  );
}
