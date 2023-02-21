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
        "darwin-arm64": "sha384-uMvEbYqK976Hh84Ev0sVuehadekaB1qsv8bjvXOTs6fvBhBjTr2TH9zUY6/xrRuI",
        "darwin-x64": "sha384-p4CvXYeEinS1fGcklKl7X70+PpKETyBSL9YGofqG+RoJ/RzlhBKO6e/JSN9/6yPf",
        "linux-arm64-gnu": "sha384-DghqoJEVmKj7qPjbviROs/DVfFucAORFSry7Lqqm11Jrol46UnpMq2BiWmovTzPV",
        "linux-x64-gnu": "sha384-PwxqpU1ROBuiGtRdMGaupnNR2NjEUu+loz7rn9mOmf0wSuOmStRNm4SsStfCpgBq",
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
    verify_node_modules_ignored = "//:.bazelignore",
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
