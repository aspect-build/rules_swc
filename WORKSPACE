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
    # Demonstrates how users can choose ANY swc version, not just the ones we mirrored
    integrity_hashes = {
        "darwin-arm64": "sha512-0qn4H9h6otyW3L+sFSCZ7pgp93fxizFIkBscxShjX1160zs4AScnK5hp4kNYfyjxr2tMCIA5WVttfL6NIYp6Uw==",
        "darwin-x64": "sha512-DkJHcGZi3pZkH+jl6QCWcXB00xP9Ntp8btpUuqsiRhtNkbQhTOk+2d8M3AzSJs/p2Jlr3Z24tBIq52q3CQJiCg==",
        "linux-x64-gnu": "sha512-NAgd4ImnWubYKdZE1sQi9hNvsSw8+z3nVm7WrZqhBx3OVQx/XQ2OQxUKIYvTe3LInUDxywX+ifRQ/syR/pFHUQ==",
    },
    swc_version = "1.2.245",
)

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")

aspect_bazel_lib_dependencies(override_local_config_platform = True)

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

go_register_toolchains(version = "1.19.3")

gazelle_dependencies()
