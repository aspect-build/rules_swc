"""API for running the SWC cli under Bazel

The simplest usage is a single line.
It relies on the `swcrc` attribute automatically discovering `.swcrc`
and the `srcs` attribute default of `glob(["**/*.ts", "**/*.tsx"])`:

```starlark
load("@aspect_rules_swc//swc:defs.bzl", "swc")

swc(name = "compile")
```
"""

load("//swc/private:swc.bzl", _swc_lib = "swc")
load("@aspect_bazel_lib//lib:utils.bzl", "file_exists", "to_label")
load("@bazel_skylib//lib:types.bzl", "types")
load("@bazel_skylib//rules:write_file.bzl", "write_file")

swc_compile = rule(
    doc = """Underlying rule for the `swc` macro.

Most users should use [swc](#swc) instead, as it predicts the output files
and has convenient default values.

Use this if you need more control over how the rule is called,
for example to set your own output labels for `js_outs`.
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

        args: Additional options to pass to `swcx` cli, see https://github.com/swc-project/swc/discussions/3859
            Note: we do **not** run the [NodeJS wrapper `@swc/cli`](https://swc.rs/docs/usage/cli)

        source_maps: If set, the --source-maps argument is passed to the SWC cli with the value.
          See https://swc.rs/docs/usage/cli#--source-maps--s.
          True/False are automaticaly converted to "true"/"false" string values the cli expects.

        swcrc: Label of a .swcrc configuration file for the SWC cli, see https://swc.rs/docs/configuration/swcrc
            Instead of a label, you can pass a dictionary matching the JSON schema.
            If this attribute isn't specified, and a file `.swcrc` exists in the same folder as this rule, it is used.

            Note that some settings in `.swcrc` also appear in `tsconfig.json`.
            We recommend adding an `assert_json_matches` rule to guarantee
            these don't accidentally diverge.
            See an example in `examples/paths/BUILD.bazel`.

        out_dir: The base directory for output files relative to the output directory for this package

        root_dir: A subdirectory under the input package which should be considered the root directory of all the input files

        **kwargs: additional keyword arguments passed through to underlying [`swc_compile`](#swc_compile), eg. `visibility`, `tags`
    """
    if srcs == None:
        srcs = native.glob(["**/*.ts", "**/*.tsx"])
    elif not types.is_list(srcs):
        fail("srcs must be a list, not a " + type(srcs))

    if swcrc == None:
        if file_exists(to_label(":.swcrc")):
            swcrc = ".swcrc"
    elif type(swcrc) == type(dict()):
        swcrc.setdefault("sourceMaps", source_maps)
        rcfile = "{}_swcrc.json".format(name)
        write_file(
            name = "_gen_swcrc_" + name,
            out = rcfile,
            content = [json.encode(swcrc)],
        )

        # From here, the configuration becomes a file path, the same as if the
        # user supplied a .swcrc InputArtifact
        swcrc = rcfile

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
