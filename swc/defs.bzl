"""API for running SWC under Bazel

Simplest usage:

```starlark
load("@aspect_rules_swc//swc:defs.bzl", "swc")

swc(name = "transpile")
```

Known issues:
- import statements improperly transformed when using symlinks: [swc#4057](https://github.com/swc-project/swc/issues/4057)
  See https://github.com/aspect-build/rules_swc/issues/31.
  You can add this to your `.bazelrc` to workaround by disabling sandboxing for SWC actions:
  `build --modify_execution_info=SWCTranspile=+no-sandbox`
"""

load("//swc/private:swc.bzl", _swc_lib = "swc")
load("@bazel_skylib//lib:types.bzl", "types")

swc_transpiler = rule(
    doc = """Underlying rule for the `swc` macro.

Most users should just use [swc](#swc) instead.

Use this if you need more control over how the rule is called,
for example to set your own output labels for `js_outs`.

This rule is also suitable for the
[ts_project#transpiler](https://github.com/aspect-build/rules_ts/blob/main/docs/rules.md#ts_project-transpiler)
attribute.
""",
    implementation = _swc_lib.implementation,
    attrs = _swc_lib.attrs,
    toolchains = _swc_lib.toolchains,
)

def swc(name, srcs = None, args = [], data = [], output_dir = False, swcrc = None, source_maps = False, out_dir = None, root_dir = None, **kwargs):
    """Execute the swc compiler

    Args:
        name: A name for the target
        srcs: source files, typically .ts files in the source tree
        data: runtime dependencies to be propagated in the runfiles
        output_dir: whether to produce a directory output rather than individual files
        args: additional arguments to pass to swc cli, see https://swc.rs/docs/usage/cli
        source_maps: If set, the --source-maps argument is passed to the swc cli with the value.
          See https://swc.rs/docs/usage/cli#--source-maps--s
          True/False are automaticaly converted to "true"/"false" string values the cli expects.
        swcrc: label of a configuration file for swc, see https://swc.rs/docs/configuration/swcrc
        out_dir: base directory for output files relative to the output directory for this package
        root_dir: a subdirectory under the input package which should be consider the root directory of all the input files
        **kwargs: additional named parameters like tags or visibility
    """
    if srcs == None:
        srcs = native.glob(["**/*.ts", "**/*.tsx"])
    elif not types.is_list(srcs):
        fail("srcs must be a list, not a " + type(srcs))

    # Convert source_maps True/False to "true"/"false" args value
    if source_maps == True:
        source_maps = "true"
    elif source_maps == False:
        source_maps = "false"

    # Determine js & map outputs
    js_outs = []
    map_outs = []

    if not output_dir:
        js_outs = _swc_lib.calculate_js_outs(srcs, out_dir, root_dir)
        map_outs = _swc_lib.calculate_map_outs(srcs, source_maps, out_dir, root_dir)

    swc_transpiler(
        name = name,
        srcs = srcs,
        js_outs = js_outs,
        map_outs = map_outs,
        output_dir = output_dir,
        source_maps = source_maps,
        args = args,
        data = data,
        swcrc = swcrc,
        out_dir = out_dir,
        root_dir = root_dir,
        **kwargs
    )
