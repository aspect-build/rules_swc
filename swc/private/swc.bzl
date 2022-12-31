"Internal implementation details"

load("@aspect_rules_js//js:libs.bzl", "js_lib_helpers")
load("@aspect_rules_js//js:providers.bzl", "js_info")
load("@bazel_skylib//lib:paths.bzl", "paths")

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
        doc = "see https://swc.rs/docs/usage/cli#--source-maps--s",
        values = ["true", "false", "inline", "both"],
        default = "false",
    ),
    "output_dir": attr.bool(
        doc = "whether to produce a directory output rather than individual files",
    ),
    "data": js_lib_helpers.JS_LIBRARY_DATA_ATTR,
    "swcrc": attr.label(
        doc = "label of a configuration file for swc, see https://swc.rs/docs/configuration/swcrc",
        allow_single_file = True,
    ),
    "out_dir": attr.string(
        doc = "base directory for output files",
    ),
    "root_dir": attr.string(
        doc = "a subdirectory under the input package which should be consider the root directory of all the input files",
    ),
}

_outputs = {
    "js_outs": attr.output_list(doc = """list of expected JavaScript output files.

There must be one for each entry in srcs, and in the same order."""),
    "map_outs": attr.output_list(doc = """list of expected source map output files.

Can be empty, meaning no source maps should be produced.
If non-empty, there must be one for each entry in srcs, and in the same order."""),
}

_SUPPORTED_EXTENSIONS = [".ts", ".tsx", ".jsx", ".mjs", ".cjs", ".js"]

def _is_supported_src(src):
    return paths.split_extension(src)[-1] in _SUPPORTED_EXTENSIONS

# TODO: aspect_bazel_lib should provide this?
def _relative_to_package(path, ctx):
    for prefix in (ctx.bin_dir.path, ctx.label.package):
        prefix += "/"
        if path.startswith(prefix):
            path = path[len(prefix):]
    return path

def _strip_root_dir(path, root_dir):
    replace_pattern = root_dir + "/"
    if path.startswith("./"):
        path = path[len("./"):]
    return path.replace(replace_pattern, "", 1)

def _calculate_js_out(src, out_dir = None, root_dir = None, js_outs = []):
    if not _is_supported_src(src):
        return None

    js_out = paths.replace_extension(src, ".js")
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
    map_out = paths.replace_extension(src, ".js.map")
    if root_dir:
        map_out = _strip_root_dir(map_out, root_dir)
    if out_dir:
        map_out = paths.join(out_dir, map_out)
    return map_out

def _calculate_map_outs(srcs, source_maps, out_dir = None, root_dir = None):
    return [f2 for f2 in [_calculate_map_out(f, source_maps, out_dir, root_dir) for f in srcs] if f2]

def _impl(ctx):
    swc_toolchain = ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"]

    inputs = []

    args = ctx.actions.args()
    args.add("compile")

    # Add user specified arguments *before* rule supplied arguments
    args.add_all(ctx.attr.args)

    args.add_all(["--source-maps", ctx.attr.source_maps])

    if ctx.attr.output_dir:
        if len(ctx.attr.srcs) != 1:
            fail("Under output_dir, there must be a single entry in srcs")
        if not ctx.files.srcs[0].is_directory:
            fail("Under output_dir, the srcs must be directories, not files")
        
        inputs.extend(ctx.files.srcs)

        output_dir = ctx.actions.declare_directory(ctx.attr.out_dir if ctx.attr.out_dir else ctx.label.name)
        args.add_all([
            "--out-dir",
            output_dir.path,
        ])
        output_sources = [output_dir]

        if ctx.attr.swcrc:
            src_args.add_all([
                "--config-file",
                ctx.file.swcrc.path,
            ])
            inputs.append(ctx.file.swcrc)

        ctx.actions.run_shell(
            inputs = inputs,
            arguments = [
                args,
                ctx.files.srcs[0].path,
            ],
            outputs = output_sources,
            command = swc_toolchain.swcinfo.swc_binary + " $@",
            mnemonic = "SWCCompile",
            progress_message = "Transpiling with swc %s into %s" % (ctx.label, output_dir.path),
        )
    else:
        output_sources = []

        for src in ctx.files.srcs:
            src_args = ctx.actions.args()
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

                if ctx.attr.source_maps in ["true", "both"]:
                    src_args.add_all([
                        "--source-map-target",
                        js_map_out.path,
                    ])

            inputs = [src]
            inputs.extend(ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.tool_files)

            if ctx.attr.swcrc:
                src_args.add_all([
                    "--config-file",
                    ctx.file.swcrc.path,
                ])
                inputs.append(ctx.file.swcrc)

            src_args.add_all([
                "--out-file",
                js_out.path,
            ])

            output_sources.extend(outputs)

            ctx.actions.run_shell(
                inputs = inputs,
                arguments = [
                    args,
                    src_args,
                    "--filename",
                    src.path,
                ],
                outputs = outputs,
                command = swc_toolchain.swcinfo.swc_binary + " $@ < " + src.path,
                mnemonic = "SWCCompile",
                progress_message = "Transpiling with swc %s [swc %s]" % (
                    ctx.label,
                    src.path,
                ),
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
