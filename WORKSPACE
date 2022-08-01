# Declare the local Bazel workspace.
# This is *not* included in the published distribution.
workspace(name = "aspect_rules_swc")

load(":internal_deps.bzl", "rules_swc_internal_deps")

# Fetch deps needed only locally for development
rules_swc_internal_deps()

load("//swc:dependencies.bzl", "rules_swc_dependencies")

# Fetch our "runtime" dependencies which users need as well
rules_swc_dependencies()

load("//swc:repositories.bzl", "LATEST_VERSION", "swc_register_toolchains")

swc_register_toolchains(
    name = "default_swc",
    swc_version = LATEST_VERSION,
)

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "node16",
    node_version = "16.9.0",
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

############################################
# Gazelle, for generating bzl_library targets
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.17.2")

gazelle_dependencies()

#####
# rust, to compile swc from sources

load("@rules_rust//rust:repositories.bzl", "rules_rust_dependencies", "rust_register_toolchains")

rules_rust_dependencies()

rust_register_toolchains()

load("@rules_rust//crate_universe:repositories.bzl", "crate_universe_dependencies")

crate_universe_dependencies()

load("@rules_rust//crate_universe:defs.bzl", "crates_repository")

crates_repository(
    name = "crate_index",
    cargo_lockfile = "@swc-project_swc//:Cargo.lock",
    manifests = [
        "@swc-project_swc//:Cargo.toml",
        "@swc-project_swc//:crates/binding_core_node/Cargo.toml",
        "@swc-project_swc//:crates/binding_core_wasm/Cargo.toml",
        "@swc-project_swc//:crates/dbg-swc/Cargo.toml",
        "@swc-project_swc//:crates/jsdoc/Cargo.toml",
        "@swc-project_swc//:crates/swc_cli/Cargo.toml",
        "@swc-project_swc//:crates/swc_css/Cargo.toml",
        "@swc-project_swc//:crates/swc_css_lints/Cargo.toml",
        "@swc-project_swc//:crates/swc_css_prefixer/Cargo.toml",
        "@swc-project_swc//:crates/swc_ecma_lints/Cargo.toml",
        "@swc-project_swc//:crates/swc_ecma_quote/Cargo.toml",
        "@swc-project_swc//:crates/swc_ecmascript/Cargo.toml",
        "@swc-project_swc//:crates/swc_estree_compat/Cargo.toml",
        "@swc-project_swc//:crates/swc_html/Cargo.toml",
        "@swc-project_swc//:crates/swc_plugin/Cargo.toml",
        "@swc-project_swc//:crates/swc_plugin_macro/Cargo.toml",
        "@swc-project_swc//:crates/swc_plugin_proxy/Cargo.toml",
        "@swc-project_swc//:crates/swc_plugin_runner/Cargo.toml",
        "@swc-project_swc//:crates/swc_plugin_testing/Cargo.toml",
        "@swc-project_swc//:crates/swc_timer/Cargo.toml",
    ],
)

load("@crate_index//:defs.bzl", "crate_repositories")

crate_repositories()
