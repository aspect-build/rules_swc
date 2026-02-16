"extensions for bzlmod"

load("@aspect_tools_telemetry_report//:defs.bzl", "TELEMETRY")  # buildifier: disable=load
load("//swc/private:toolchains_repo.bzl", "PLATFORMS")
load("//swc/private:versions.bzl", "TOOL_VERSIONS")
load(":repositories.bzl", "determine_version", "swc_register_toolchains")

swc_toolchain = tag_class(attrs = {
    "name": attr.string(doc = "Base name for generated repositories"),
    "swc_version": attr.string(doc = "Explicit version of @swc/core. If provided, the package.json is not read."),
    "swc_version_from": attr.label(doc = "Location of package.json which may have a version for @swc/core."),
    "platforms": attr.string_list(doc = "List of platforms to register toolchains for. Defaults to all platforms if not provided.", default = PLATFORMS.keys()),
    "integrity_hashes": attr.string_dict(doc = "A mapping from platform to integrity hash."),
})

default_repository = "swc"

def _toolchain_extension(module_ctx):
    used_facts = {}
    fetched_hashes = None
    reproducible = True

    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != default_repository and not mod.is_root:
                fail("Only the root module may provide a name for the {} toolchain.".format(toolchain.name))

            swc_version = determine_version(module_ctx, toolchain.swc_version, toolchain.swc_version_from)

            integrity_hashes = toolchain.integrity_hashes
            if not integrity_hashes:
                if swc_version in TOOL_VERSIONS:
                    integrity_hashes = TOOL_VERSIONS[swc_version]
                elif hasattr(module_ctx, "facts"):
                    integrity_hashes = module_ctx.facts.get(swc_version, None)
                    if not integrity_hashes:
                        if not fetched_hashes:
                            fetched_hashes = _fetch_versions(module_ctx)
                        if swc_version in fetched_hashes:
                            integrity_hashes = fetched_hashes[swc_version]

                    if integrity_hashes:
                        used_facts[swc_version] = integrity_hashes

            if not integrity_hashes:
                reproducible = False

            if toolchain.name in registrations.keys():
                if toolchain.name == default_repository:
                    # Prioritize the root-most registration of the default toolchain version and
                    # ignore any further registrations (modules are processed breadth-first)
                    continue
                if swc_version == registrations[toolchain.name].swc_version:
                    # No problem to register a matching toolchain twice
                    continue
                fail("Multiple conflicting toolchains declared for name {} ({} and {}".format(
                    toolchain.name,
                    swc_version,
                    registrations[toolchain.name].swc_version,
                ))
            else:
                registrations[toolchain.name] = struct(
                    swc_version = swc_version,
                    platforms = toolchain.platforms,
                    integrity_hashes = integrity_hashes,
                )

    for name, registration in registrations.items():
        swc_register_toolchains(
            name = name,
            swc_version = registration.swc_version,
            platforms = registration.platforms,
            integrity_hashes = registration.integrity_hashes,
            register = False,
        )

    # Support Bazel6: no "reproducible" flag or "facts"
    # Support Bazel7: no "facts"
    if not hasattr(module_ctx, "facts"):
        return None

    return module_ctx.extension_metadata(reproducible = reproducible, facts = used_facts)

swc = module_extension(
    implementation = _toolchain_extension,
    tag_classes = {"toolchain": swc_toolchain},
)

def _fetch_versions(module_ctx):
    result = module_ctx.download(url = ["https://api.github.com/repos/swc-project/swc/releases"], output = "swc_versions.json")
    if not result.success:
        # buildifier: disable=print
        print("ERROR: failed to fetch swc versions via github API: {}".format(result))
        return {}

    data = module_ctx.read("swc_versions.json")

    # If the download failed such as being redirected to a custom registry page, the data may not be valid JSON
    # and can just be ignored with warning.
    if not data or data[0] != "[":
        # buildifier: disable=print
        print("ERROR: failed to read swc versions fetched from github API: {}".format(data))
        return {}

    versions = {}
    for release in json.decode(data):
        tag_name = release.get("tag_name", None)
        if not tag_name:
            continue

        assets = release.get("assets", [])
        hashes = {}
        for asset in assets:
            name = asset.get("name", "").lstrip("swc-").rstrip(".exe")
            if name in PLATFORMS and "digest" in asset:
                hashes[name] = asset["digest"]
        if hashes:
            versions[tag_name] = hashes

    return versions
