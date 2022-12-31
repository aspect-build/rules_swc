"""API for running the SWC cli under Bazel

Simplest usage:

```starlark
load("@aspect_rules_swc//swc:defs.bzl", "swc")

swc(name = "transpile")
```
"""

load("//swc/private:swc.bzl", _swc_lib = "swc")

load("@bazel_skylib//lib:types.bzl", "types")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

swc_compile = rule(
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
    """Execute the SWC compiler

    Args:
        name: A name for this target

        srcs: List of labels of TypeScript source files.

        data: Files needed at runtime by binaries or tests that transitively depend on this target.
            See https://bazel.build/reference/be/common-definitions#typical-attributes

        output_dir: Whether to produce a directory output rather than individual files

        args: Additional options to pass to SWC cli, see https://swc.rs/docs/usage/cli

        source_maps: If set, the --source-maps argument is passed to the SWC cli with the value, see https://swc.rs/docs/usage/cli#--source-maps--s
          True/False are automaticaly converted to "true"/"false" string values the cli expects.

        swcrc: Label of a .swcrc configuration file for the SWC cli, see https://swc.rs/docs/configuration/swcrc
            Instead of a label, you can pass a dictionary matching the JSON schema.

        out_dir: The base directory for output files relative to the output directory for this package

        root_dir: A subdirectory under the input package which should be consider the root directory of all the input files

        **kwargs: passed through to underlying [`swc_compile`](#swc_compile), eg. `visibility`, `tags`
    """
    if srcs == None:
        srcs = native.glob(["**/*.ts", "**/*.tsx"])
    elif not types.is_list(srcs):
        fail("srcs must be a list, not a " + type(srcs))

    if type(swcrc) == type(dict()):
        swcrc.setdefault("sourceMaps", source_maps)

        write_file(
            name = "_gen_swcrc_%s" % name,
            out = "swcrc_%s.json" % name,
            content = [json.encode(swcrc)]
        )

        # From here, the configuration becomes a file, the same as if the
        # user supplied a .swcrc InputArtifact
        swcrc = "swcrc_%s.json" % name

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

    swc_compile(
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
