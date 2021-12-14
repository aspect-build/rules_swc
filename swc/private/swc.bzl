"Internal implementation details"

load("@bazel_skylib//lib:paths.bzl", "paths")

_attrs = {
    "srcs": attr.label_list(allow_files = True, mandatory = True),
    "args": attr.string_list(),
    "source_maps": attr.string(),
    "output_dir": attr.bool(),
    "data": attr.label_list(default = [], allow_files = True),
    "swcrc": attr.label(allow_single_file = True),
    "swc_cli": attr.label(
        default = "@aspect_rules_swc//swc:cli",
        executable = True,
        cfg = "exec",
    ),
}

_outputs = {
    "js_outs": attr.output_list(),
    "map_outs": attr.output_list(),
}

def _impl(ctx):
    outputs = []
    source_maps = len(ctx.outputs.map_outs) > 0
    binding = ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.binding
    args = ctx.actions.args()

    # Add user specified arguments *before* rule supplied arguments
    args.add_all(ctx.attr.args)

    if ctx.attr.output_dir:
        if len(ctx.attr.srcs) != 1:
            fail("Under output_dir, there must be a single entry in srcs")
        if not ctx.files.srcs[0].is_directory:
            fail("Under output_dir, the srcs must be directories, not files")
        out = ctx.actions.declare_file(ctx.label.name)
        outputs.append(out)
        args.add_all([
            ctx.files.srcs[0].path,
            "--out-dir",
            out.path,
            "--no-swcrc",
            "-q",
        ])

        ctx.actions.run(
            inputs = ctx.files.srcs + ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.tool_files,
            arguments = [args],
            outputs = [out],
            env = {
                # Our patch for @swc/core uses this environment variable to locate the rust binding
                "SWC_BINARY_PATH": binding,
            },
            executable = ctx.executable.swc_cli,
            progress_message = "Transpiling with swc %s" % ctx.label,
        )

    else:
        outputs.extend(ctx.outputs.js_outs)
        outputs.extend(ctx.outputs.map_outs)
        for src in ctx.files.srcs:
            js_out = ctx.actions.declare_file(paths.replace_extension(src.basename, ".js"), sibling = src)
            outs = [js_out]
            if source_maps:
                outs.append(ctx.actions.declare_file(paths.replace_extension(src.basename, ".js.map"), sibling = src))

            # Pass in the swcrc config if it is set; if it is
            # then source paths are expected to be relative to the swcrc directory
            src_path = src.path
            if ctx.file.swcrc:
                swcrc_path = ctx.file.swcrc.path
                swcrc_directory = paths.dirname(swcrc_path)
                args.add_all([
                    "--config-file",
                    swcrc_path,
                ])

                # TODO(greg): determine if this is needed, given that relativize below should provide a correct path
                # if not src_path.startswith(swcrc_directory):
                #     fail("sources must be in swcrc directory or subdirectory if swcrc is specified")
                src_path = paths.relativize(src_path, swcrc_directory)

            args.add_all([
                src_path,
                "--out-file",
                js_out.path,
                "--no-swcrc",
                "-q",
            ])

            ctx.actions.run(
                inputs = [src] + ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.tool_files,
                arguments = [args],
                outputs = outs,
                env = {
                    # Our patch for @swc/core uses this environment variable to locate the rust binding
                    "SWC_BINARY_PATH": binding,
                },
                executable = ctx.executable.swc_cli,
                progress_message = "Transpiling with swc %s [swc %s]" % (
                    ctx.label,
                    src.short_path,
                ),
            )

    providers = [
        DefaultInfo(
            files = depset(outputs),
            runfiles = ctx.runfiles(outputs, transitive_files = depset(ctx.files.data)),
        ),
    ]

    return providers

swc = struct(
    implementation = _impl,
    attrs = dict(_attrs, **_outputs),
    toolchains = ["@aspect_rules_swc//swc:toolchain_type"],
)
