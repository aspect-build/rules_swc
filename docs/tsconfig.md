# Synchronizing settings with tsconfig.json

TypeScript and SWC both need to be configured in their own files,
typically `tsconfig.json` and `.swcrc`, respectively. Some settings are meant to be common between the two, such as
how dependencies are resolved on the disk.

This is not a Bazel-specific problem, so we can just look for existing solutions in the ecosystem, and adapt those to be run under Bazel.

Ideally, we'd like SWC to simply read from `tsconfig.json`, as it
is the "source-of-truth" for how editors understand `.ts` files.
There is [an issue](https://github.com/swc-project/swc/issues/1348) already filed for this, but as of Jan 2023 it's not yet supported.

This document explores our options.

## Maintain two files

You might just check in both files as sources.

Since both `tsconfig.json` and `.swcrc` are JSON files, we recommend adding an [`assert_json_matches`](https://docs.aspect.build/rules/aspect_bazel_lib/docs/testing#assert_json_matches) rule to guarantee that they don't accidentally diverge.

A typical example looks like this:

```python
load("@aspect_bazel_lib//lib:testing.bzl", "assert_json_matches")

# Verify that the "paths" entry is the same
# between swc and TS language service (in the editor)
assert_json_matches(
    name = "check_paths",
    file1 = "tsconfig.json",
    file2 = ".swcrc",
    filter1 = ".compilerOptions.paths",
    filter2 = ".jsc.paths",
)
```

## Generate the .swcrc

Another option provided by the community is to convert the `tsconfig.json` file. Under Bazel we can model this as a codegen step that happens automatically.

The relevant package is [tsconfig-to-swcconfig](https://www.npmjs.com/package/tsconfig-to-swcconfig). Let's see how to wire it up.

There's a corresponding CLI tool, tswc, but it doesn't work well to just generate the `.swcrc` file,
see <https://github.com/Songkeys/tswc/issues/1>

So we'll make our own tiny CLI for the underlying package, let's call it `write_swcrc.js`, containing:

```javascript
const {convert} = require('tsconfig-to-swcconfig');
const [tsconfig] = process.argv.slice(2);
console.log(JSON.stringify(convert(tsconfig), undefined, 2));
```

And a bit of BUILD file content to invoke it (you might wrap this in a macro for better developer experience):

```python
js_binary(
    name = "converter",
    entry_point = "write_swcrc.js",
    data = [":node_modules/tsconfig-to-swcconfig"],
)

js_run_binary(
    name = "write_swcrc",
    tool = "converter",
    chdir = package_name(),
    args = ["./tsconfig.json"],
    srcs = ["tsconfig.json"],
    stdout = ".swcrc",
)
```

Now you can just use the standard `swc` rule with the `swcrc` attribute.
See `/examples/generate_swcrc` for a full example.
