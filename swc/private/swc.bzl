"Internal implementation details"

load("@aspect_bazel_lib//lib:copy_file.bzl", "copy_file_action")
load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "COPY_FILE_TO_BIN_TOOLCHAINS", "copy_file_to_bin_action")
load("@aspect_bazel_lib//lib:platform_utils.bzl", "platform_utils")
load("@aspect_rules_js//js:libs.bzl", "js_lib_helpers")
load("@aspect_rules_js//js:providers.bzl", "js_info")
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
    "emit_isolated_dts": attr.bool(
        doc = """Emit .d.ts files instead of .js for TypeScript sources

EXPERIMENTAL: this API is undocumented, experimental and may change without notice
""",
        default = False,
    ),
    "default_ext": attr.string(
        doc = """Default extension for output files.

If a source file does not indicate a specific module type, this extension is used.

If unset, extensions will be determined based on the `js_outs` outputs attribute
or source file extensions.""",
    ),
    "allow_js": attr.bool(
        doc = """Allow JavaScript sources to be transpiled.

If False, only TypeScript sources will be transpiled.""",
        default = True,
    ),
}

_outputs = {
    "js_outs": attr.output_list(doc = """list of expected JavaScript output files.

There should be one for each entry in srcs."""),
    "map_outs": attr.output_list(doc = """list of expected source map output files.

Can be empty, meaning no source maps should be produced.
If non-empty, there should be one for each entry in srcs."""),
    "dts_outs": attr.output_list(doc = """list of expected TypeScript declaration files.

Can be empty, meaning no dts files should be produced.
If non-empty, there should be one for each entry in srcs."""),
}

_TYPINGS_EXTS = (".d.ts", ".d.mts", ".d.cts")
_JS_EXTS = (".mjs", ".cjs", ".js", ".jsx")
_TS_EXTS = (".ts", ".mts", ".cts", ".tsx")

def _is_ts_src(src):
    return src.endswith(_TS_EXTS)

def _is_typings_src(src):
    return src.endswith(_TYPINGS_EXTS)

def _is_js_src(src):
    return src.endswith(_JS_EXTS)

def _is_supported_src(src, allow_js):
    return _is_ts_src(src) or (allow_js and _is_js_src(src))

def _is_data_src(src):
    return src.endswith(".json")

# TODO: vendored from rules_ts - bazel_lib should provide this?
# https://github.com/aspect-build/rules_ts/blob/v3.2.1/ts/private/ts_lib.bzl#L194-L200
def _relative_to_package(file, ctx, dir_cache):
    """Package-relative path of a File.

    The directory prefix depends only on the file's directory, so it is cached
    in the caller-provided dir_cache since targets commonly have many files in
    the same directory.
    """
    dirname = file.dirname
    prefix = dir_cache.get(dirname)
    if prefix == None:
        # The trailing "/" makes each prefix strip behave exactly as it does on
        # a full file path, e.g. stripping a directory equal to the package to
        # the empty prefix.
        path = dirname + "/" if dirname else ""
        path = path.removeprefix(ctx.bin_dir.path + "/")
        path = path.removeprefix("external/")
        path = path.removeprefix(ctx.label.workspace_name + "/")
        if ctx.label.package:
            path = path.removeprefix(ctx.label.package + "/")
        prefix = path
        dir_cache[dirname] = prefix
    return prefix + file.basename

# TODO: vendored from rules_ts - bazel_lib should provide this?
# https://github.com/aspect-build/rules_ts/blob/v3.2.1/ts/private/ts_lib.bzl#L220-L226
def _to_out_path(f, out_dir, root_dir):
    f = f[f.find(":") + 1:]
    if root_dir:
        f = f.removeprefix(root_dir + "/")
    if out_dir and out_dir != ".":
        f = out_dir + "/" + f
    return f

def _remove_extension(f):
    i = f.rfind(".")
    return f if i <= 0 else f[:-(len(f) - i)]

# Sources with these extensions dictate the output module type.
# Other sources use default_ext (or ".js").
_JS_OUT_EXTS = {
    ".mts": ".mjs",
    ".mjs": ".mjs",
    ".cjs": ".cjs",
    ".cts": ".cjs",
}

_MAP_OUT_EXTS = {
    ".mts": ".mjs.map",
    ".cts": ".cjs.map",
    ".mjs": ".mjs.map",
    ".cjs": ".cjs.map",
}

# Allow customizing the output extension via the declared js_outs.
# See https://github.com/aspect-build/rules_swc/commit/edc6421cf42a7174bcc38e91b0812abd0bfb0f09
# TODO(3.0): remove this feature in favour of standard logic above.
def _match_custom_js_out(js_out, custom_js_outs):
    alt_js_out = None

    # Check if a custom out was requested with a potentially different extension
    no_ext = _remove_extension(js_out)
    for maybe_out in custom_js_outs:
        # Always use an exact match if it exists
        if maybe_out == js_out:
            return js_out

        # Try to match on a potential output with a different extension
        # Initial startswith() check to avoid the expensive _remove_extension()
        if maybe_out.startswith(no_ext) and no_ext == _remove_extension(maybe_out):
            alt_js_out = maybe_out

    # Return the matched custom out if it exists otherwise fallback to the default
    return alt_js_out or js_out

def _to_outs(default_ext, src, source_maps, emit_isolated_dts, allow_js, out_dir, root_dir, custom_js_outs = None):
    """Calculate the output paths for a src, classifying the src only once.

    Args:
        default_ext: output extension for sources whose extension does not dictate one
        src: package-relative path of the source file
        source_maps: value of the source_maps attribute
        emit_isolated_dts: whether .d.ts outputs are produced
        allow_js: whether .js/.mjs/.cjs sources are transpiled
        out_dir: output directory prefix, if any
        root_dir: input directory to strip, if any
        custom_js_outs: declared js_outs that may override the predicted output
            extension, or None if the override feature is inactive. See _swc_impl.

    Returns:
        None if the src is not transpiled, otherwise a (js_out, map_out, dts_out)
        tuple where map_out and dts_out may be None.
    """
    if not _is_supported_src(src, allow_js) or _is_typings_src(src):
        return None

    ext_index = src.rindex(".")
    out_base = _to_out_path(src[:ext_index], out_dir, root_dir)
    src_ext = src[ext_index:]

    js_out = out_base + _JS_OUT_EXTS.get(src_ext, default_ext if default_ext else ".js")

    if custom_js_outs != None:
        js_out = _match_custom_js_out(js_out, custom_js_outs)

    map_out = None
    if source_maps != "false" and source_maps != "inline":
        map_out = out_base + _MAP_OUT_EXTS.get(src_ext, default_ext + ".map")

    dts_out = out_base + ".d.ts" if emit_isolated_dts else None

    return (js_out, map_out, dts_out)

def _calculate_outs(default_ext, srcs, source_maps, emit_isolated_dts, allow_js, out_dir = None, root_dir = None):
    """Calculate js_outs, map_outs and dts_outs in a single pass over srcs."""
    js_outs = []
    map_outs = []
    dts_outs = []
    for f in srcs:
        outs = _to_outs(default_ext, f, source_maps, emit_isolated_dts, allow_js, out_dir, root_dir)
        if not outs:
            continue
        if outs[0] and outs[0] != f:
            js_outs.append(outs[0])
        if outs[1]:
            map_outs.append(outs[1])
        if outs[2]:
            dts_outs.append(outs[2])
    return js_outs, map_outs, dts_outs

def _calculate_source_file(ctx, src, dirname_cache):
    # "." is equivalent to unset: it changes no output paths, see _to_out_path.
    out_dir = ctx.attr.out_dir if ctx.attr.out_dir != "." else ""
    root_dir = ctx.attr.root_dir if ctx.attr.root_dir != "." else ""
    if not (out_dir or root_dir):
        return src.basename

    # The relative prefix depends only on the src directory; cache it since
    # targets commonly have many srcs in the same directory.
    prefix = dirname_cache.get(src.dirname)
    if prefix == None:
        src_pkg = src.dirname[len(ctx.label.package) + 1:] if ctx.label.package else ""
        segments = []

        # out of src subdir
        if src_pkg:
            src_pkg_depth = len(src_pkg.split("/"))
            root_dir_depth = len(root_dir.split("/")) if root_dir else 0
            segments += [".."] * max(0, src_pkg_depth - root_dir_depth)

        # out of the out dir
        if out_dir:
            segments += [".."] * len(out_dir.split("/"))

        # back into the src dir, including into the root_dir
        if src_pkg:
            segments.append(src_pkg)
        prefix = "/".join(segments)
        dirname_cache[src.dirname] = prefix

    return prefix + "/" + src.basename if prefix else src.basename

def _swc_action(ctx, swc_binary, execution_requirements, **kwargs):
    ctx.actions.run(
        mnemonic = "SWCCompile",
        progress_message = "Compiling %{label} [swc %{input}]",
        executable = swc_binary,
        execution_requirements = execution_requirements,
        **kwargs
    )

def _swc_impl(ctx):
    swc_toolchain = ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"]

    inputs = swc_toolchain.swcinfo.tool_files[:]

    args = ctx.actions.args()
    args.add("compile")

    # The root config file. Config options may be overridden by additional args.
    if ctx.attr.swcrc:
        args.add("--config-file", ctx.file.swcrc)
        inputs.append(ctx.file.swcrc)

    # Add user specified arguments *before* rule supplied arguments
    args.add_all(ctx.attr.args)

    args.add("--source-maps", ctx.attr.source_maps)
    if ctx.attr.source_maps != "false" and ctx.attr.source_root:
        args.add("--source-root", ctx.attr.source_root)

    if ctx.attr.plugins:
        plugin_cache = [ctx.actions.declare_directory("{}_plugin_cache".format(ctx.label.name))]
        plugin_args = ["--config-json", json.encode({
            "jsc": {
                "experimental": {
                    # TODO: .path breaks 'supports-path-mapping'
                    "cacheRoot": plugin_cache[0].path,
                    # TODO: .path breaks 'supports-path-mapping'
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
            execution_requirements = {"supports-path-mapping": "1"},
        )

        inputs.extend(plugin_cache)
        inputs.extend(ctx.files.plugins)
        args.add_all(plugin_args)

    if ctx.attr.emit_isolated_dts:
        args.add_all(["--config-json", json.encode({
            "jsc": {
                "experimental": {
                    "emitIsolatedDts": True,
                },
            },
        })])

    if ctx.attr.output_dir:
        if len(ctx.attr.srcs) != 1:
            fail("Under output_dir, there must be a single entry in srcs")
        if not ctx.files.srcs[0].is_directory:
            fail("Under output_dir, the srcs must be directories, not files")
        output_dir = ctx.actions.declare_directory(ctx.attr.out_dir if ctx.attr.out_dir else ctx.label.name)

        inputs.extend(ctx.files.srcs)

        output_sources = [output_dir]

        args.add_all(["--out-dir", output_dir], expand_directories = False)
        args.add_all([ctx.files.srcs[0]], expand_directories = False)

        _swc_action(
            ctx,
            swc_toolchain.swcinfo.swc_binary,
            inputs = inputs,
            arguments = [args],
            outputs = output_sources,
            execution_requirements = {"supports-path-mapping": "1"},
        )
    else:
        # Disable sandboxing for the SWC action by default since there is normally only
        # the source and config files as inputs and not complex dependency tree.
        #
        # This may be required for SWC issues with symlinks in the sandbox.
        # TODO: investigate removal of no-sandbox and adding of supports-path-mapping once SWC stops resolving
        # symlinks during transpilation, see https://github.com/swc-project/swc/pull/11585
        execution_requirements = {
            "no-sandbox": "1",
        }

        output_sources = []

        # Shared cache of package-relative directory prefixes, see _relative_to_package.
        dir_cache = {}

        # Declared js_outs may override the predicted output extensions, but only
        # when no default_ext is set: with a default_ext the output extension is
        # fully determined by the source extension. Leave None (feature inactive)
        # otherwise, to skip both the computation here and the matching in _to_outs.
        custom_js_outs = None
        if not ctx.attr.default_ext:
            custom_js_outs = [_relative_to_package(f, ctx, dir_cache) for f in ctx.outputs.js_outs]

        # Keep srcs in the same tree as a generated swcrc so SWC's symlink-resolving
        # `jsc.paths` resolver emits clean relative imports. See #325.
        copy_srcs_to_bin = ctx.attr.swcrc and not ctx.file.swcrc.is_source

        source_file_dirname_cache = {}

        for src in ctx.files.srcs:
            src_path = _relative_to_package(src, ctx, dir_cache)

            # This source file is a typings file and not transpiled
            if _is_typings_src(src_path):
                # Copy to the output directory if emitting dts files is enabled
                if ctx.attr.emit_isolated_dts:
                    output_sources.append(src)
                continue

            if _is_data_src(src_path):
                # Copy data to the output directory for behavior similar to tsc
                out_path = _to_out_path(src_path, ctx.attr.out_dir, ctx.attr.root_dir)
                out_file = ctx.actions.declare_file(out_path)
                copy_file_action(
                    ctx = ctx,
                    src = src,
                    dst = out_file,
                )
                output_sources.append(out_file)
                continue

            outs = _to_outs(ctx.attr.default_ext, src_path, ctx.attr.source_maps, ctx.attr.emit_isolated_dts, ctx.attr.allow_js, ctx.attr.out_dir, ctx.attr.root_dir, custom_js_outs)
            if not outs:
                # This source file is not a supported src
                continue
            js_out_path, map_out_path, dts_out_path = outs

            js_out = ctx.actions.declare_file(js_out_path)
            outputs = [js_out]

            if map_out_path:
                js_map_out = ctx.actions.declare_file(map_out_path)
                outputs.append(js_map_out)

            if dts_out_path:
                dts_out = ctx.actions.declare_file(dts_out_path)
                outputs.append(dts_out)

            src_input = copy_file_to_bin_action(ctx, src) if copy_srcs_to_bin else src

            src_args = ctx.actions.args()

            if ctx.attr.source_maps != "false":
                src_args.add("--source-file-name", _calculate_source_file(ctx, src, source_file_dirname_cache))

            src_args.add("--out-file", js_out)
            src_args.add(src_input)

            output_sources.extend(outputs)

            _swc_action(
                ctx,
                swc_toolchain.swcinfo.swc_binary,
                inputs = [src_input] + inputs,
                arguments = [
                    args,
                    src_args,
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
    toolchains = ["@aspect_rules_swc//swc:toolchain_type"] + COPY_FILE_TO_BIN_TOOLCHAINS,
    calculate_outs = _calculate_outs,
)
