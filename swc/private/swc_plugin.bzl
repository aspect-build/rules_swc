"Implementation details for swc_plugin rule"

load("//swc:providers.bzl", "SwcPluginConfigInfo")

_attrs = {
    "srcs": attr.label_list(
        doc = "label for the plugin, either a directory containing a package.json pointing at a wasm file as the main entrypoint, or a wasm file",
        providers = [DefaultInfo],
        mandatory = True,
        allow_files = True,
    ),
    "config": attr.string(
        doc = "configuration object for the plugin, serialized JSON object",
        default = "{}",
    ),
}

def _swc_plugin_impl(ctx):
    return [
        DefaultInfo(
            files = depset(ctx.files.srcs),
        ),
        SwcPluginConfigInfo(
            label = ctx.label,
            config = ctx.attr.config,
        ),
    ]

swc_plugin = struct(
    attrs = _attrs,
    implementation = _swc_plugin_impl,
    provides = [DefaultInfo, SwcPluginConfigInfo],
)
