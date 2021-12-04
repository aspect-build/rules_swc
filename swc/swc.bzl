"swc rule"

load("//swc/private:swc.bzl", _swc_lib = "swc")
load("@bazel_skylib//lib:paths.bzl", "paths")

_swc = rule(
    implementation = _swc_lib.implementation,
    attrs = _swc_lib.attrs,
    toolchains = _swc_lib.toolchains,
)

_SUPPORTED_EXTENSIONS = [".ts", ".tsx", ".jsx", ".mjs", ".cjs"]

def _is_supported_src(src):
    for e in _SUPPORTED_EXTENSIONS:
        if src.endswith(e):
            return True
    return False

def swc(name, srcs = None, args = [], source_maps = None, source_map_outputs = False):
    """Execute the swc compiler

    Args:
        name: A name for the target
        srcs: srcs
        args: additional use args to pass to swc cli
        source_maps: If set, the --source-maps argument is passed to the swc cli with the value
          True/False are automaticaly converted to "true"/"false" string values the cli expects
          If source_maps is "true" or "both" then source_map_outputs is automatically set to True
        source_map_outputs: if the rule is expected to produce a .js.map file output for each .js file output
    """
    if srcs == None:
        srcs = native.glob(["**/*" + e for e in _SUPPORTED_EXTENSIONS])

    # Convert source_maps True/False to "true"/"false" args value
    if source_maps == True:
        source_maps = "true"
    elif source_maps == False:
        source_maps = "false"

    # Detect if we are expecting
    if not source_map_outputs:
        source_map_outputs = (source_maps == "true" or source_maps == "both")

    # Add the source_maps arg
    if source_maps:
        args = args + ["--source-maps", source_maps]

    # Determine js & map outputs
    js_outs = []
    map_outs = []
    for f in srcs:
        if _is_supported_src(f):
            js_outs.append(paths.replace_extension(f, ".js"))
            if source_map_outputs:
                map_outs.append(paths.replace_extension(f, ".js.map"))

    _swc(
        name = name,
        srcs = srcs,
        js_outs = js_outs,
        map_outs = map_outs,
        args = args,
    )
