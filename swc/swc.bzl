"""API for running SWC under Bazel

Simplest usage:

```starlark
load("@aspect_rules_swc//swc:swc.bzl", "swc")

swc(name = "transpile")
```
"""

load("//swc/private:swc.bzl", _swc_lib = "swc")
load("@bazel_skylib//lib:types.bzl", "types")

swc_transpiler = rule(
    doc = """Underlying rule for the `swc` macro.

Most users should just use [swc](#swc) instead.

Use this if you need more control over how the rule is called,
for example to set your own output labels for `js_outs`.""",
    implementation = _swc_lib.implementation,
    attrs = _swc_lib.attrs,
    toolchains = _swc_lib.toolchains,
)

def swc(name, srcs = None, args = [], data = [], output_dir = False, swcrc = None, source_maps = False, **kwargs):
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
        **kwargs: additional named parameters like tags or visibility
    """
    if srcs == None:
        srcs = native.glob(["**/*" + e for e in _swc_lib.SUPPORTED_EXTENSIONS])
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
        js_outs = _swc_lib.calculate_js_outs(srcs)
        map_outs = _swc_lib.calculate_map_outs(srcs, source_maps)

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
        **kwargs
    )
