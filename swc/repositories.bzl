"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@aspect_rules_js//npm:npm_import.bzl", "npm_import", "npm_translate_lock")
load("//swc/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")
load("//swc/private:versions.bzl", "TOOL_VERSIONS")
load("//swc:cli_repositories.bzl", _cli_repositories = "npm_repositories")

LATEST_VERSION = TOOL_VERSIONS.keys()[0]

_DOC = "Fetch external tools needed for swc toolchain"
_ATTRS = {
    "swc_version": attr.string(mandatory = True, values = TOOL_VERSIONS.keys()),
    "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
}

def _swc_repo_impl(repository_ctx):
    filename = "swc.%s.node" % repository_ctx.attr.platform
    url = "https://github.com/swc-project/swc/releases/download/{0}/{1}".format(
        repository_ctx.attr.swc_version,
        filename,
    )
    repository_ctx.download(
        output = filename,
        url = url,
        integrity = TOOL_VERSIONS[repository_ctx.attr.swc_version][repository_ctx.attr.platform],
    )
    build_content = """#Generated by swc/repositories.bzl
load("@aspect_rules_swc//swc:toolchain.bzl", "swc_toolchain")
swc_toolchain(name = "swc_toolchain", node_binding = "%s")
""" % filename

    # Base BUILD file for this repository
    repository_ctx.file("BUILD.bazel", build_content)

swc_repositories = repository_rule(
    _swc_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def swc_register_toolchains(name, node_repository = "nodejs", register = True, **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "swc_linux_amd64" -
      this repository is lazily fetched when node is needed for that platform.
    - TODO: create a convenience repository for the host platform like "swc_host"
    - create a repository exposing toolchains for each platform like "swc_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.
    Args:
        name: base name for all created repos, like "swc"
        node_repository: what name was given to register_nodejs_toolchains.
        register: whether to call through to native.register_toolchains.
            Should be True for WORKSPACE users, but false when used under bzlmod extension
        **kwargs: passed to each node_repositories call
    """
    for platform in PLATFORMS.keys():
        swc_repositories(
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )
        if register:
            native.register_toolchains("@%s_toolchains//:%s_toolchain" % (name, platform))

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )

    npm_import(
        name = "npm__at_swc_core__1.2.185",
        integrity = "sha512-dDNzDrJ4bzMVWeFWqLJojjv5XZJZ84Zia7kQdJjp+kfOMdEhS+onrAwrk5Q88PlAvbrhY6kQbWD2LZ8JdyEaSQ==",
        root_package = "swc",
        link_workspace = "aspect_rules_swc",
        link_packages = {},
        package = "@swc/core",
        version = "1.2.185",
        transitive_closure = {
            "@swc/core": ["1.2.185"],
        },
    )

    npm_translate_lock(
        name = "swc_cli",
        pnpm_lock = "@aspect_rules_swc//swc:pnpm-lock.yaml",
        link_workspace = "aspect_rules_swc",
    )

    # We ALSO re-declare the results of the previous npm_translate_lock
    # so that users don't have to make an extra load/execution in their WORKSPACE
    _cli_repositories()
