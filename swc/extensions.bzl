"extensions for bzlmod"

load("@aspect_tools_telemetry_report//:defs.bzl", "TELEMETRY")  # buildifier: disable=load
load(":repositories.bzl", "swc_register_toolchains")

swc_toolchain = tag_class(attrs = {
    "name": attr.string(doc = "Base name for generated repositories"),
    "swc_version": attr.string(doc = "Explicit version of @swc/core. If provided, the package.json is not read."),
    "swc_version_from": attr.label(doc = "Location of package.json which may have a version for @swc/core."),
    "platforms": attr.string_list(doc = "List of platforms to register toolchains for. Defaults to all platforms if not provided."),
})

default_repository = "swc"

def _toolchain_extension(module_ctx):
    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != default_repository and not mod.is_root:
                fail("Only the root module may provide a name for the {} toolchain.".format(toolchain.name))

            if toolchain.name in registrations.keys():
                if toolchain.name == default_repository:
                    # Prioritize the root-most registration of the default toolchain version and
                    # ignore any further registrations (modules are processed breadth-first)
                    continue
                if toolchain.swc_version == registrations[toolchain.name].swc_version and toolchain.swc_version_from == registrations[toolchain.name].swc_version_from:
                    # No problem to register a matching toolchain twice
                    continue
                fail("Multiple conflicting toolchains declared for name {} ({} and {}".format(
                    toolchain.name,
                    toolchain.swc_version,
                    registrations[toolchain.name],
                ))
            else:
                registrations[toolchain.name] = struct(
                    swc_version = toolchain.swc_version,
                    swc_version_from = toolchain.swc_version_from,
                    platforms = toolchain.platforms,
                )

    for name, registration in registrations.items():
        if registration.platforms:
            swc_register_toolchains(
                name = name,
                swc_version = registration.swc_version,
                swc_version_from = registration.swc_version_from,
                platforms = registration.platforms,
                register = False,
            )
        else:
            swc_register_toolchains(
                name = name,
                swc_version = registration.swc_version,
                swc_version_from = registration.swc_version_from,
                register = False,
            )

swc = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"toolchain": swc_toolchain},
)
