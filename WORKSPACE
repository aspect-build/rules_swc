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
    name = "default_swc",
    integrity_hashes = {
        "darwin-arm64": "sha512-DuBBKIyk0iUGPmq6RQc7/uOCkGnvB0JDWQbWxA2NGAEcK0ZtI9J0efG9M1/gLIb0QD+d2DVS5Lx7VRIUFTx9lA==",
        "darwin-x64": "sha512-WvDN6tRjQ/p+4gNvT4UVU4VyJLXy6hT4nT6mGgrtftG/9pP5dDPwwtTm86ISfqGUs8/LuZvrr4Nhwdr3j+0uAA==",
        "linux-x64-gnu": "sha512-6eco63idgYWPYrSpDeSE3tgh/4CC0hJz8cAO/M/f3azmCXvI+11isC60ic3UKeZ2QNXz3YbsX6CKAgBPSkkaVA==",
    },
    swc_version = "v1.2.204",
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
