# Declare the local Bazel workspace.
# This is *not* included in the published distribution.
workspace(
    name = "aspect_rules_swc",
)

load(":internal_deps.bzl", "rules_swc_internal_deps")

# Fetch deps needed only locally for development
rules_swc_internal_deps()

load("//swc:repositories.bzl", "rules_swc_dependencies", "swc_register_toolchains")

# Fetch our "runtime" dependencies which users need as well
rules_swc_dependencies()

swc_register_toolchains(
    name = "swc",
    swc_version = "1.2.117",
)

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "node16",
    node_version = "16.9.0",
)

load("@aspect_rules_js//js:npm_import.bzl", "npm_import", "translate_package_lock")

translate_package_lock(
    name = "swc_cli",
    package_lock = "//swc/private:package-lock.json",
)

load("@swc_cli//:repositories.bzl", "npm_repositories")

npm_repositories()

npm_import(
    integrity = "sha512-bR1YGSyKbwguJxyZ3i3Au6+u8eP3SWhikGVWtCTE9sbfjSXuFKABaJiETg52IV3lU/WF6S97bGFdi+4SpyJnLw==",
    package = "@swc/core",
    patches = [
        "@aspect_rules_swc//swc/private:swc_core.patch",
    ],
    version = "1.2.117",
    deps = [
        "@npm__napi-rs_triples-1.1.0",
        "@npm__node-rs_helper-1.2.1",
    ],
)

npm_import(
    integrity = "sha512-R5wEmm8nbuQU0YGGmYVjEc0OHtYsuXdpRG+Ut/3wZ9XAvQWyThN08bTh2cBJgoZxHQUPtvRfeQuxcAgLuiBISg==",
    package = "@node-rs/helper",
    version = "1.2.1",
)

npm_import(
    integrity = "sha512-XQr74QaLeMiqhStEhLn1im9EOMnkypp7MZOwQhGzqp2Weu5eQJbpPxWxixxlYRKWPOmJjsk6qYfYH9kq43yc2w==",
    package = "@napi-rs/triples",
    version = "1.1.0",
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
