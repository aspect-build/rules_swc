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
    fetched_hashes = {}
    reproducible = True

    registrations = {}
    for mod in module_ctx.modules:
        for toolchain in mod.tags.toolchain:
            if toolchain.name != default_repository and not mod.is_root:
                fail("Only the root module may provide a name for the {} toolchain.".format(toolchain.name))

            if (toolchain.swc_version and toolchain.swc_version_from) or (not toolchain.swc_version and not toolchain.swc_version_from):
                fail("Exactly one of 'swc_version' or 'swc_version_from' must be set.")

            swc_version = determine_version(module_ctx, toolchain.swc_version, toolchain.swc_version_from)

            integrity_hashes = toolchain.integrity_hashes
            if not integrity_hashes:
                if swc_version in TOOL_VERSIONS:
                    integrity_hashes = TOOL_VERSIONS[swc_version]
                elif hasattr(module_ctx, "facts"):
                    integrity_hashes = module_ctx.facts.get(swc_version, None)
                    if integrity_hashes and not _is_valid_sri_hashes(integrity_hashes):
                        integrity_hashes = None
                    if not integrity_hashes:
                        if swc_version not in fetched_hashes:
                            fetched_hashes[swc_version] = _fetch_version(module_ctx, swc_version)
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

_BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

def _hex_to_base64(hex_str):
    data = [int(hex_str[i:i + 2], 16) for i in range(0, len(hex_str), 2)]
    result = ""
    n = len(data)
    for i in range(0, n, 3):
        b0 = data[i]
        b1 = data[i + 1] if i + 1 < n else 0
        b2 = data[i + 2] if i + 2 < n else 0
        result += _BASE64_CHARS[b0 >> 2]
        result += _BASE64_CHARS[((b0 & 3) << 4) | (b1 >> 4)]
        result += _BASE64_CHARS[((b1 & 15) << 2) | (b2 >> 6)] if i + 1 < n else "="
        result += _BASE64_CHARS[b2 & 63] if i + 2 < n else "="
    return result

_SRI_HASH_LENGTHS = {
    "sha256-": 44,
    "sha384-": 64,
    "sha512-": 88,
}

def _is_valid_sri_hashes(hashes):
    for v in hashes.values():
        for prefix, b64_len in _SRI_HASH_LENGTHS.items():
            if v.startswith(prefix):
                if len(v) != len(prefix) + b64_len:
                    return False
                break
    return True

def _digest_to_sri(digest):
    """Convert a GitHub asset digest to Bazel SRI format.

    GitHub returns digests as "sha256:hexhash" or bare hex; Bazel needs "sha256-base64hash".
    """
    if digest.startswith("sha256:"):
        return "sha256-" + _hex_to_base64(digest[7:])
    if digest.startswith("sha512:"):
        return "sha512-" + _hex_to_base64(digest[7:])
    if len(digest) == 64:
        return "sha256-" + _hex_to_base64(digest)
    if len(digest) == 128:
        return "sha512-" + _hex_to_base64(digest)
    return None

def _fetch_version(module_ctx, swc_version):
    output = "swc_version_{}.json".format(swc_version)
    result = module_ctx.download(
        url = ["https://api.github.com/repos/swc-project/swc/releases/tags/{}".format(swc_version)],
        output = output,
    )
    if not result.success:
        # buildifier: disable=print
        print("ERROR: failed to fetch swc version {} via github API: {}".format(swc_version, result))
        return {}

    data = module_ctx.read(output)

    # If the download failed such as being redirected to a custom registry page, the data may not be valid JSON
    # and can just be ignored with warning.
    if not data or data[0] != "{":
        # buildifier: disable=print
        print("ERROR: failed to read swc version {} fetched from github API: {}".format(swc_version, data))
        return {}

    hashes = {}
    for asset in json.decode(data).get("assets", []):
        name = asset.get("name", "")
        if name.startswith("swc-"):
            name = name[4:]
        if name.endswith(".exe"):
            name = name[:-4]
        if name in PLATFORMS and "digest" in asset:
            sri = _digest_to_sri(asset["digest"])
            if sri:
                hashes[name] = sri

    return hashes
