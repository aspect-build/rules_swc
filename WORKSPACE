# Declare the local Bazel workspace.
# This is *not* included in the published distribution.
workspace(name = "aspect_rules_swc")

load(":internal_deps.bzl", "rules_swc_internal_deps")

# Fetch deps needed only locally for development
rules_swc_internal_deps()

load("//swc:dependencies.bzl", "rules_swc_dependencies")

# Fetch our "runtime" dependencies which users need as well
rules_swc_dependencies()

load("//swc:repositories.bzl", "swc_register_toolchains")

swc_register_toolchains(
    name = "swc",
    # Demonstrates how users can choose ANY swc version, not just the ones we mirrored
    integrity_hashes = {
        "darwin-arm64": "sha384-tSMDc6MG2llNW0PoEaWayHSia7YXDWVV+ceaiAl3Ew1xGA3lmfC2wTuKzaJU+16o",
        "darwin-x64": "sha384-e9/dVt6KQTPVyH3y2Oy8J+Bz5XVI0hiK6fwknNsq/yTY+hftJ+SDqDW2YMkfCa3C",
        "linux-arm64-gnu": "sha384-cipAIuV6Sa33feJMftOL56t3yEqr0/E6feFWkBnbIAtlSFsUEcv7LY+M7zLdn7Or",
        "linux-x64-gnu": "sha384-s9hTnWi9jZM2MZJNnCn7Pg19vfSLnf8kCCYAgBN4UM4NFlN8+BpfGHG+jzq6BkaA",
    },
    swc_version_from = "//:package.json",
)

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies", "register_jq_toolchains")

aspect_bazel_lib_dependencies(override_local_config_platform = True)

register_jq_toolchains()

load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = DEFAULT_NODE_VERSION,
)

load("@aspect_rules_js//npm:npm_import.bzl", "npm_translate_lock")

npm_translate_lock(
    name = "npm",
    pnpm_lock = "//examples:pnpm-lock.yaml",
)

load("@npm//:repositories.bzl", "npm_repositories")

npm_repositories()

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

############################################
# Gazelle, for generating bzl_library targets
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.19.3")

gazelle_dependencies()
