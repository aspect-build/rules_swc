"Internal implementation details"

load("@bazel_skylib//lib:paths.bzl", "paths")
load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "copy_file_to_bin_action")
load("@aspect_rules_js//js:libs.bzl", "js_lib_helpers")
load("@aspect_rules_js//js:providers.bzl", "js_info")

_attrs = {
    "srcs": attr.label_list(
        doc = "source files, typically .ts files in the source tree",
        allow_files = True,
        mandatory = True,
    ),
    "args": attr.string_list(
        doc = "additional arguments to pass to swc cli, see https://swc.rs/docs/usage/cli",
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

def _declare_outputs(ctx, paths):
    return [ctx.actions.declare_file(p) for p in paths]

# TODO: aspect_bazel_lib should provide this?
def _relative_to_package(path, ctx):
    for prefix in (ctx.bin_dir.path, ctx.label.package):
        prefix += "/"
        if path.startswith(prefix):
            path = path[len(prefix):]
    return path

def _calculate_js_outs(srcs, out_dir = None):
    if out_dir == None:
        js_srcs = []
        for src in srcs:
            if paths.split_extension(src)[-1] == ".js":
                js_srcs.append(src)
        if len(js_srcs) > 0:
            fail("Detected swc rule with srcs=[{}, ...] and out_dir=None. Please set out_dir when compiling .js files.".format(", ".join(js_srcs[:3])))

    js_outs = [paths.replace_extension(f, ".js") for f in srcs if _is_supported_src(f)]
    if out_dir != None:
        js_outs = [paths.join(out_dir, f) for f in js_outs]

    return js_outs

def _calculate_map_outs(srcs, source_maps):
    if source_maps in ["false", "inline"]:
        return []
    return [paths.replace_extension(f, ".js.map") for f in srcs if _is_supported_src(f)]

def _impl(ctx):
    binary = ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.swc_binary

    args = ctx.actions.args()
    args.add("compile")

    # Add user specified arguments *before* rule supplied arguments
    args.add_all(ctx.attr.args)
    #args.add_all(["--source-maps", ctx.attr.source_maps])

    output_sources = []

    if ctx.attr.output_dir:
        if len(ctx.attr.srcs) != 1:
            fail("Under output_dir, there must be a single entry in srcs")
        if not ctx.files.srcs[0].is_directory:
            fail("Under output_dir, the srcs must be directories, not files")
        output_dir = ctx.actions.declare_directory(ctx.label.name)

        output_sources = [output_dir]

        args.add_all([
            ctx.files.srcs[0].path,
            "--out-dir",
            output_dir.path,
            #"--no-swcrc",
            #"-q",
        ])

        ctx.actions.run(
            inputs = ctx.files.srcs + ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.tool_files,
            arguments = [args],
            outputs = [output_dir],
            executable = binary,
            progress_message = "Transpiling with swc %s" % ctx.label,
            # sandboxing is unnecessary with swc which takes an explilit list of srcs via args
            execution_requirements = {"no-sandbox": "1"},
        )
    else:
        srcs = [_relative_to_package(src.path, ctx) for src in ctx.files.srcs]

        if len(ctx.attr.js_outs):
            js_outs = ctx.outputs.js_outs
        else:
            js_outs = _declare_outputs(ctx, _calculate_js_outs(srcs, ctx.attr.out_dir))
        if len(ctx.attr.map_outs):
            map_outs = ctx.outputs.map_outs
        else:
            map_outs = _declare_outputs(ctx, _calculate_map_outs(srcs, ctx.attr.source_maps))

        output_sources = js_outs + map_outs

        for i, src in enumerate(ctx.files.srcs):
            src_args = ctx.actions.args()

            js_out = js_outs[i]
            inputs = [src] + ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.tool_files
            outputs = [js_out]
            if map_outs:
                outputs.append(map_outs[i])

            # Pass in the swcrc config if it is set
            if ctx.file.swcrc:
                swcrc_path = ctx.file.swcrc.path
                swcrc_directory = paths.dirname(swcrc_path)
                src_args.add("--config-file", swcrc_path)
                inputs.append(copy_file_to_bin_action(ctx, ctx.file.swcrc))
            else:
                pass
                #src_args.add("--no-swcrc")

            src_args.add_all([
                # src.path,
                "--out-file",
                js_out.path,
                #"-q",
            ])

            ctx.actions.run_shell(
                inputs = inputs,
                arguments = [
                    args,
                    src_args,
                    "-f ",
                    src.path,
                ],
                outputs = outputs,
                # Workaround swc cli bug:
                # https://github.com/swc-project/swc/blob/main/crates/swc_cli/src/commands/compile.rs#L241-L254
                # under Bazel it will think there's no tty and so it always errors here
                # https://github.com/swc-project/swc/blob/main/crates/swc_cli/src/commands/compile.rs#L301
                command = binary + " $@ < " + src.path,
                mnemonic = "SWCTranspile",
                progress_message = "Transpiling with swc %s [swc %s]" % (
                    ctx.label,
                    src.path,
                ),
                execution_requirements = {
                    # sandboxing is unnecessary with swc which takes an explilit list of srcs via args
                    "no-sandbox": "1",
                },
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
    calculate_js_outs = _calculate_js_outs,
    calculate_map_outs = _calculate_map_outs,
)
