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
    "data": js_lib_helpers.JS_LIBRARY_DATA_ATTR,
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
    return paths.split_extension(src)[-1] in _SUPPORTED_EXTENSIONS

# TODO: aspect_bazel_lib should provide this?
def _relative_to_package(path, ctx):
    package_path = ctx.label.package
    if ctx.label.workspace_root:
        # If the target label is external (like "@REPO_NAME//some/target")
        # then it will be placed under "external/REPO_NAME/some/target",
        # rather than just "some/target", so take that into account here.
        package_path = ctx.label.workspace_root + "/" + package_path

    for prefix in (ctx.bin_dir.path, package_path):
        prefix += "/"
        if path.startswith(prefix):
            path = path[len(prefix):]
    return path

def _strip_root_dir(path, root_dir):
    replace_pattern = root_dir + "/"
    if path.startswith("./"):
        path = path[len("./"):]
    return path.replace(replace_pattern, "", 1)

# Copied from ts_lib.bzl
# https://github.com/aspect-build/rules_ts/blob/c2a9e1e476c45bb895c4445327471e29bc3e0474/ts/private/ts_lib.bzl
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

def _calculate_js_out(src, out_dir = None, root_dir = None, js_outs = []):
    if not _is_supported_src(src):
        return None

    exts = {
        "*": ".js",
        ".mts": ".mjs",
        ".mjs": ".mjs",
        ".cjs": ".cjs",
        ".cts": ".cjs",
    }
    js_out = paths.replace_extension(src, _replace_ext(src, exts))
    if root_dir:
        js_out = _strip_root_dir(js_out, root_dir)
    if out_dir:
        js_out = paths.join(out_dir, js_out)

    # Check if a custom out was requested with a potentially different extension
    for maybe_out in js_outs:
        no_ext = paths.replace_extension(js_out, "")
        if no_ext == paths.replace_extension(maybe_out, ""):
            js_out = maybe_out
            break
    return js_out

def _calculate_js_outs(srcs, out_dir = None, root_dir = None):
    if out_dir == None:
        js_srcs = []
        for src in srcs:
            if paths.split_extension(src)[-1] == ".js":
                js_srcs.append(src)
        if len(js_srcs) > 0:
            fail("Detected swc rule with srcs=[{}, ...] and out_dir=None. Please set out_dir when compiling .js files.".format(", ".join(js_srcs[:3])))

    return [f2 for f2 in [_calculate_js_out(f, out_dir, root_dir) for f in srcs] if f2]

def _calculate_map_out(src, source_maps, out_dir = None, root_dir = None):
    if source_maps in ["false", "inline"]:
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
    map_out = paths.replace_extension(src, _replace_ext(src, exts))
    if root_dir:
        map_out = _strip_root_dir(map_out, root_dir)
    if out_dir:
        map_out = paths.join(out_dir, map_out)
    return map_out

def _calculate_map_outs(srcs, source_maps, out_dir = None, root_dir = None):
    return [f2 for f2 in [_calculate_map_out(f, source_maps, out_dir, root_dir) for f in srcs] if f2]

def _calculate_source_file(ctx, src):
    if not (ctx.attr.out_dir or ctx.attr.root_dir):
        return src.basename

    src_pkg = src.dirname[len(ctx.label.package)+1:] if ctx.label.package else ""
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
    # Workaround Rust SDK issue on Windows, see https://github.com/aspect-build/rules_swc/issues/141
    if platform_utils.host_platform_is_windows():
        run = ctx.actions.run_shell
        kwargs["command"] = swc_binary + " $@ < /dev/null"
    else:
        run = ctx.actions.run
        kwargs["executable"] = swc_binary
    run(
        mnemonic = "SWCCompile",
        progress_message = "Compiling %{label} [swc %{input}]",
        **kwargs
    )

def _impl(ctx):
    swc_toolchain = ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"]

    inputs = swc_toolchain.swcinfo.tool_files[:]

    args = ctx.actions.args()
    args.add("compile")

    # Add user specified arguments *before* rule supplied arguments
    args.add_all(ctx.attr.args)

    args.add("--source-maps", ctx.attr.source_maps)

    plugin_cache = []
    plugin_args = []
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

        # run swc once with a null input to compile the plugins into the plugin cache
        _swc_action(
            ctx,
            swc_toolchain.swcinfo.swc_binary,
            arguments = ["compile"] + plugin_args + ["--source-maps", "false", "--out-file", "/dev/null", "/dev/null"],
            inputs = inputs + ctx.files.plugins,
            outputs = plugin_cache,
        )

    args.add_all(plugin_args)

    if ctx.attr.output_dir:
        if len(ctx.attr.srcs) != 1:
            fail("Under output_dir, there must be a single entry in srcs")
        if not ctx.files.srcs[0].is_directory:
            fail("Under output_dir, the srcs must be directories, not files")
        output_dir = ctx.actions.declare_directory(ctx.attr.out_dir if ctx.attr.out_dir else ctx.label.name)

        inputs.extend(ctx.files.srcs)
        inputs.extend(ctx.files.plugins)
        inputs.extend(plugin_cache)

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
        output_sources = []

        for src in ctx.files.srcs:
            src_args = ctx.actions.args()
            src_args.add("--source-file-name", _calculate_source_file(ctx, src))
            src_args.add("--source-root", ctx.attr.source_root)

            src_path = _relative_to_package(src.path, ctx)

            js_out_path = _calculate_js_out(src_path, ctx.attr.out_dir, ctx.attr.root_dir, [_relative_to_package(f.path, ctx) for f in ctx.outputs.js_outs])
            if not js_out_path:
                # This source file is not a supported src
                continue
            js_out = ctx.actions.declare_file(js_out_path)
            outputs = [js_out]
            map_out_path = _calculate_map_out(src_path, ctx.attr.source_maps, ctx.attr.out_dir, ctx.attr.root_dir)

            if map_out_path:
                js_map_out = ctx.actions.declare_file(map_out_path)
                outputs.append(js_map_out)

            inputs = [src]
            inputs.extend(ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.tool_files)
            inputs.extend(ctx.files.plugins)
            inputs.extend(plugin_cache)

            if ctx.attr.swcrc:
                src_args.add("--config-file", ctx.file.swcrc)
                inputs.append(ctx.file.swcrc)

            src_args.add("--out-file", js_out)

            output_sources.extend(outputs)

            _swc_action(
                ctx,
                swc_toolchain.swcinfo.swc_binary,
                inputs = inputs,
                arguments = [
                    args,
                    src_args,
                    src.path,
                ],
                outputs = outputs,
            )

    output_sources_depset = depset(output_sources)

    transitive_sources = js_lib_helpers.gather_transitive_sources(
        sources = output_sources_depset,
        targets = ctx.attr.srcs,
    )

    transitive_declarations = js_lib_helpers.gather_transitive_declarations(
        declarations = [],
        targets = ctx.attr.srcs,
    )

    npm_linked_packages = js_lib_helpers.gather_npm_linked_packages(
        srcs = ctx.attr.srcs,
        deps = [],
    )

    npm_package_store_deps = js_lib_helpers.gather_npm_package_store_deps(
        targets = ctx.attr.data,
    )

    runfiles = js_lib_helpers.gather_runfiles(
        ctx = ctx,
        sources = transitive_sources,
        data = ctx.attr.data,
        deps = ctx.attr.srcs,
    )

    return [
        js_info(
            npm_linked_package_files = npm_linked_packages.direct_files,
            npm_linked_packages = npm_linked_packages.direct,
            npm_package_store_deps = npm_package_store_deps,
            sources = output_sources_depset,
            transitive_declarations = transitive_declarations,
            transitive_npm_linked_package_files = npm_linked_packages.transitive_files,
            transitive_npm_linked_packages = npm_linked_packages.transitive,
            transitive_sources = transitive_sources,
        ),
        DefaultInfo(
            files = output_sources_depset,
            runfiles = runfiles,
        ),
    ]

swc = struct(
    implementation = _impl,
    attrs = dict(_attrs, **_outputs),
    toolchains = ["@aspect_rules_swc//swc:toolchain_type"],
    SUPPORTED_EXTENSIONS = _SUPPORTED_EXTENSIONS,
    calculate_js_out = _calculate_js_out,
    calculate_js_outs = _calculate_js_outs,
    calculate_map_outs = _calculate_map_outs,
)
