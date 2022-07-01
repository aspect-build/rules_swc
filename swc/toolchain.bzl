"""This module implements the language-specific toolchain rule.
"""

SwcInfo = provider(
    doc = "Information about how to invoke the tool executable.",
    fields = {
        "swc_binary": "Path to the native swc cli binary for the target platform.",
        "tool_files": """Files required in runfiles to make the tool executable available.

May be empty if the target_tool_path points to a locally installed tool binary.""",
    },
)

# Avoid using non-normalized paths (workspace/../other_workspace/path)
def _to_manifest_path(ctx, file):
    if file.short_path.startswith("../"):
        return "external/" + file.short_path[3:]
    else:
        return ctx.workspace_name + "/" + file.short_path

def _swc_toolchain_impl(ctx):
    if ctx.attr.swc_binary and ctx.attr.target_tool_path:
        fail("Can only set one of swc_binary or target_tool_path but both were set.")
    if not ctx.attr.swc_binary and not ctx.attr.target_tool_path:
        fail("Must set one of swc_binary or target_tool_path.")

    tool_files = []
    target_tool_path = ctx.attr.target_tool_path

    if ctx.attr.swc_binary:
        tool_files = ctx.attr.swc_binary.files.to_list()
        target_tool_path = _to_manifest_path(ctx, tool_files[0])

    # Make the $(tool_BIN) variable available in places like genrules.
    # See https://docs.bazel.build/versions/main/be/make-variables.html#custom_variables
    template_variables = platform_common.TemplateVariableInfo({
        "SWC_BINARY_PATH": target_tool_path,
    })
    default = DefaultInfo(
        files = depset(tool_files),
        runfiles = ctx.runfiles(files = tool_files),
    )
    swcinfo = SwcInfo(
        swc_binary = target_tool_path,
        tool_files = tool_files,
    )

    # Export all the providers inside our ToolchainInfo
    # so the resolved_toolchain rule can grab and re-export them.
    toolchain_info = platform_common.ToolchainInfo(
        swcinfo = swcinfo,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

swc_toolchain = rule(
    implementation = _swc_toolchain_impl,
    attrs = {
        "swc_binary": attr.label(
            doc = "A hermetically downloaded executable target for the target platform.",
            mandatory = False,
            allow_single_file = True,
        ),
        "target_tool_path": attr.string(
            doc = "Path to an existing executable for the target platform.",
            mandatory = False,
        ),
    },
    doc = """Defines a swc compiler/runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.
""",
)
