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

First, add the package to your devDependencies as usual.

Then, invoke it in your `BUILD` file, replacing `[my/pkg]` with the Bazel package where the `package.json` appears:

```python
load("@npm//[my/pkg]:tsconfig-to-swcconfig/package_json.bzl", tsconfig_to_swcconfig = "bin")

tsconfig_to_swcconfig.t2s(
    name = "write_swcrc",
    srcs = ["tsconfig.json"],
    args = ["--filename", "$(location tsconfig.json)"],
    stdout = ".swcrc",
    visibility = ["//:__subpackages__"],
)
```

Now you can just use the standard `swc` rule with the `swcrc` attribute.
See `/examples/generate_swcrc` for a full example.
