"Internal implementation details"

load("@aspect_bazel_lib//lib:platform_utils.bzl", "platform_utils")
load("@aspect_rules_js//js:libs.bzl", "js_lib_helpers")
load("@aspect_rules_js//js:providers.bzl", "js_info")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("//swc:providers.bzl", "SwcPluginConfigInfo")

_attrs = {
    "srcs": attr.label_list(
        doc = "source files, typically .ts files in the source tree",
        allow_files = True,
        mandatory = True,
    ),
    "args": attr.string_list(
        doc = """Additional arguments to pass to swcx cli (NOT swc!).
        
        NB: this is not the same as the CLI arguments for @swc/cli npm package.
        For performance, rules_swc does not call a Node.js program wrapping the swc rust binding.
        Instead, we directly spawn the (somewhat experimental) native Rust binary shipped inside the
        @swc/core npm package, which the swc project calls "swcx"
        Tracking issue for feature parity: https://github.com/swc-project/swc/issues/4017
        """,
    ),
    "source_maps": attr.string(
        doc = """Create source map files for emitted JavaScript files.

        see https://swc.rs/docs/usage/cli#--source-maps--s""",
        values = ["true", "false", "inline", "both"],
        default = "false",
    ),
    "source_root": attr.string(
        doc = """Specify the root path for debuggers to find the reference source code.

        see https://swc.rs/docs/usage/cli#--source-root
        
        If not set, then the directory containing the source file is used.""",
    ),
    "output_dir": attr.bool(
        doc = """Whether to produce a directory output rather than individual files.
        
        If out_dir is also specified, it is used as the name of the output directory.
        Otherwise, the directory is named the same as the target.""",
    ),
    "data": attr.label_list(
        doc = """Runtime dependencies to include in binaries/tests that depend on this target.

Follows the same semantics as `js_library` `data` attribute. See
https://docs.aspect.build/rulesets/aspect_rules_js/docs/js_library#data for more info.
""",
        allow_files = True,
    ),
    "swcrc": attr.label(
        doc = "label of a configuration file for swc, see https://swc.rs/docs/configuration/swcrc",
        allow_single_file = True,
    ),
    "plugins": attr.label_list(
        doc = "swc compilation plugins, created with swc_plugin rule",
        providers = [[DefaultInfo, SwcPluginConfigInfo]],
    ),
    "out_dir": attr.string(
        doc = """With output_dir=False, output files will have this directory prefix.
        
        With output_dir=True, this is the name of the output directory.""",
    ),
    "root_dir": attr.string(
        doc = "a subdirectory under the input package which should be consider the root directory of all the input files",
    ),
}

_outputs = {
    "js_outs": attr.output_list(doc = """list of expected JavaScript output files.

There should be one for each entry in srcs."""),
    "map_outs": attr.output_list(doc = """list of expected source map output files.

Can be empty, meaning no source maps should be produced.
If non-empty, there should be one for each entry in srcs."""),
}

_SUPPORTED_EXTENSIONS = [".ts", ".mts", ".cts", ".tsx", ".jsx", ".mjs", ".cjs", ".js"]

def _is_supported_src(src):
    i = src.rfind(".")
    return i > 0 and src[i:] in _SUPPORTED_EXTENSIONS

# TODO: aspect_bazel_lib should provide this?
# https://github.com/aspect-build/rules_ts/blob/v2.2.0/ts/private/ts_lib.bzl#L167-L173
def _relative_to_package(path, ctx):
    # TODO: "external/" should only be needed to be removed once
    path = path.removeprefix("external/").removeprefix(ctx.bin_dir.path + "/")
    path = path.removeprefix("external/").removeprefix(ctx.label.workspace_name + "/")
    if ctx.label.package:
        path = path.removeprefix("external/").removeprefix(ctx.label.package + "/")
    return path

# Copied from ts_lib.bzl
# https://github.com/aspect-build/rules_ts/blob/v2.2.0/ts/private/ts_lib.bzl#L193-L229
# TODO: We should probably share code to avoid the implementations diverging and having different bugs
def _replace_ext(f, ext_map):
    cur_ext = f[f.rindex("."):]
    new_ext = ext_map.get(cur_ext)
    if new_ext != None:
        return new_ext
    new_ext = ext_map.get("*")
    if new_ext != None:
        return new_ext
    return None

# https://github.com/aspect-build/rules_ts/blob/v2.2.0/ts/private/ts_lib.bzl#L203-L208
def _to_out_path(f, out_dir, root_dir):
    if root_dir:
        f = f.removeprefix(root_dir + "/")
    if out_dir:
        f = _join(out_dir, f)
    return f

# https://github.com/aspect-build/rules_ts/blob/v2.2.0/ts/private/ts_lib.bzl#L161-L165
def _join(*elements):
    segments = [f for f in elements if f and f != "."]
    if len(segments):
        return "/".join(segments)
    return "."

def _remove_extension(f):
    i = f.rfind(".")
    return f if i <= 0 else f[:-(len(f) - i)]

def _to_js_out(src, out_dir, root_dir, js_outs = []):
    if not _is_supported_src(src):
        return None

    exts = {
        "*": ".js",
        ".mts": ".mjs",
        ".mjs": ".mjs",
        ".cjs": ".cjs",
        ".cts": ".cjs",
    }
    js_out = src[:src.rindex(".")] + _replace_ext(src, exts)
    js_out = _to_out_path(js_out, out_dir, root_dir)

    # Check if a custom out was requested with a potentially different extension
    no_ext = _remove_extension(js_out)
    for maybe_out in js_outs:
        # Initial startswith() check to avoid the expensive _remove_extension()
        if maybe_out.startswith(no_ext) and no_ext == _remove_extension(maybe_out):
            return maybe_out
    return js_out

def _calculate_js_outs(srcs, out_dir, root_dir):
    out = []
    for f in srcs:
        js_out = _to_js_out(f, out_dir, root_dir)
        if js_out and js_out != f:
            out.append(js_out)
    return out

def _to_map_out(src, source_maps, out_dir, root_dir):
    if source_maps == "false" or source_maps == "inline":
        return None
    if not _is_supported_src(src):
        return None
    exts = {
        "*": ".js.map",
        ".mts": ".mjs.map",
        ".cts": ".cjs.map",
        ".mjs": ".mjs.map",
        ".cjs": ".cjs.map",
    }
    map_out = src[:src.rindex(".")] + _replace_ext(src, exts)
    map_out = _to_out_path(map_out, out_dir, root_dir)
    return map_out

def _calculate_map_outs(srcs, source_maps, out_dir, root_dir):
    if source_maps == "false" or source_maps == "inline":
        return []

    out = []
    for f in srcs:
        map_out = _to_map_out(f, source_maps, out_dir, root_dir)
        if map_out:
            out.append(map_out)
    return out

def _calculate_source_file(ctx, src):
    if not (ctx.attr.out_dir or ctx.attr.root_dir):
        return src.basename

    src_pkg = src.dirname[len(ctx.label.package) + 1:] if ctx.label.package else ""
    s = ""

    # out of src subdir
    if src_pkg:
        s = paths.join(s, "/".join([".." for _ in src_pkg.split("/")]))

    # out of the out dir
    if ctx.attr.out_dir:
        s = paths.join(s, "/".join([".." for _ in ctx.attr.out_dir.split("/")]))

    # back into the src dir, including into the root_dir
    return paths.join(s, src_pkg, src.basename)

def _swc_action(ctx, swc_binary, **kwargs):
    ctx.actions.run(
        mnemonic = "SWCCompile",
        progress_message = "Compiling %{label} [swc %{input}]",
        executable = swc_binary,
        **kwargs
    )

def _swc_impl(ctx):
    swc_toolchain = ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"]

    inputs = swc_toolchain.swcinfo.tool_files[:]

    args = ctx.actions.args()
    args.add("compile")

    # Add user specified arguments *before* rule supplied arguments
    args.add_all(ctx.attr.args)

    args.add("--source-maps", ctx.attr.source_maps)

    if ctx.attr.plugins:
        plugin_cache = [ctx.actions.declare_directory("{}_plugin_cache".format(ctx.label.name))]
        plugin_args = ["--config-json", json.encode({
            "jsc": {
                "experimental": {
                    "cacheRoot": plugin_cache[0].path,
                    "plugins": [["./" + p[DefaultInfo].files.to_list()[0].path, json.decode(p[SwcPluginConfigInfo].config)] for p in ctx.attr.plugins],
                },
            },
        })]

        null_file = "NUL" if platform_utils.host_platform_is_windows() else "/dev/null"

        # run swc once with a null input to compile the plugins into the plugin cache
        _swc_action(
            ctx,
            swc_toolchain.swcinfo.swc_binary,
            arguments = ["compile"] + plugin_args + ["--source-maps", "false", "--out-file", null_file, null_file],
            inputs = inputs + ctx.files.plugins,
            outputs = plugin_cache,
        )

        inputs.extend(plugin_cache)
        inputs.extend(ctx.files.plugins)
        args.add_all(plugin_args)

    if ctx.attr.output_dir:
        if len(ctx.attr.srcs) != 1:
            fail("Under output_dir, there must be a single entry in srcs")
        if not ctx.files.srcs[0].is_directory:
            fail("Under output_dir, the srcs must be directories, not files")
        output_dir = ctx.actions.declare_directory(ctx.attr.out_dir if ctx.attr.out_dir else ctx.label.name)

        inputs.extend(ctx.files.srcs)

        output_sources = [output_dir]

        args.add("--out-dir", output_dir.path)

        src_args = ctx.actions.args()
        if ctx.attr.swcrc:
            src_args.add("--config-file", ctx.file.swcrc)
            inputs.append(ctx.file.swcrc)

        _swc_action(
            ctx,
            swc_toolchain.swcinfo.swc_binary,
            inputs = inputs,
            arguments = [
                args,
                src_args,
                ctx.files.srcs[0].path,
            ],
            outputs = output_sources,
        )
    else:
        # Disable sandboxing for the SWC action by default since there is normally only
        # the source and config files as inputs and not complex dependency tree.
        #
        # This may be required for SWC issues with symlinks in the sandbox.
        execution_requirements = {
            "no-sandbox": "1",
        }

        output_sources = []

        js_outs_relative = [_relative_to_package(f.path, ctx) for f in ctx.outputs.js_outs]

        for src in ctx.files.srcs:
            src_args = ctx.actions.args()

            if ctx.attr.source_maps != "false":
                src_args.add("--source-file-name", _calculate_source_file(ctx, src))
                if ctx.attr.source_root:
                    src_args.add("--source-root", ctx.attr.source_root)

            src_path = _relative_to_package(src.path, ctx)

            js_out_path = _to_js_out(src_path, ctx.attr.out_dir, ctx.attr.root_dir, js_outs_relative)
            if not js_out_path:
                # This source file is not a supported src
                continue
            js_out = ctx.actions.declare_file(js_out_path)
            outputs = [js_out]
            map_out_path = _to_map_out(src_path, ctx.attr.source_maps, ctx.attr.out_dir, ctx.attr.root_dir)

            if map_out_path:
                js_map_out = ctx.actions.declare_file(map_out_path)
                outputs.append(js_map_out)

            src_inputs = [src] + inputs

            if ctx.attr.swcrc:
                src_args.add("--config-file", ctx.file.swcrc)
                src_inputs.append(ctx.file.swcrc)

            src_args.add("--out-file", js_out)

            output_sources.extend(outputs)

            _swc_action(
                ctx,
                swc_toolchain.swcinfo.swc_binary,
                inputs = src_inputs,
                arguments = [
                    args,
                    src_args,
                    src.path,
                ],
                outputs = outputs,
                execution_requirements = execution_requirements,
            )

    output_sources_depset = depset(output_sources)

    transitive_sources = js_lib_helpers.gather_transitive_sources(
        sources = output_sources,
        targets = ctx.attr.srcs,
    )

    transitive_types = js_lib_helpers.gather_transitive_types(
        types = [],
        targets = ctx.attr.srcs,
    )

    npm_sources = js_lib_helpers.gather_npm_sources(
        srcs = ctx.attr.srcs,
        deps = [],
    )

    npm_package_store_infos = js_lib_helpers.gather_npm_package_store_infos(
        targets = ctx.attr.srcs + ctx.attr.data,
    )

    runfiles = js_lib_helpers.gather_runfiles(
        ctx = ctx,
        sources = transitive_sources,
        data = ctx.attr.data,
        deps = ctx.attr.srcs,
    )

    return [
        js_info(
            target = ctx.label,
            sources = output_sources_depset,
            types = depset(),  # swc does not emit types directly
            transitive_sources = transitive_sources,
            transitive_types = transitive_types,
            npm_sources = npm_sources,
            npm_package_store_infos = npm_package_store_infos,
        ),
        DefaultInfo(
            files = output_sources_depset,
            runfiles = runfiles,
        ),
    ]

swc = struct(
    implementation = _swc_impl,
    attrs = dict(_attrs, **_outputs),
    toolchains = ["@aspect_rules_swc//swc:toolchain_type"],
    SUPPORTED_EXTENSIONS = _SUPPORTED_EXTENSIONS,
    calculate_js_outs = _calculate_js_outs,
    calculate_map_outs = _calculate_map_outs,
)
