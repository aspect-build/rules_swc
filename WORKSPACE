# Declare the local Bazel workspace.
# This is *not* included in the published distribution.
workspace(name = "aspect_rules_swc")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

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
        "darwin-arm64": "sha384-t6mE7ugjC2L7oD+y3KE69iQ2yQGMtUQ53CWA8Rr7rlXnGs2sZOXRoX4Fy32jT4YX",
        "darwin-x64": "sha384-HdTY5k0gXRYdUlyYmRzbakrrXEmUtxPl5N4szXqGlySGa2qXsEVH8o/T8sVBq/tz",
        "linux-arm64-gnu": "sha384-CZFkdTRDov52bg8+iET5mRvyQ4A/0daMg0+wRTma+1dfhdV/3Zl1Rm392r1mAhfr",
        "linux-x64-gnu": "sha384-SRCQi073AFgw8Owfp0XUH8hsnjhZjjlXW/sZSQldZprg/FXf9OG1Wk0L61yC7vty",
    },
    swc_version = "v1.3.24",
)

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")

aspect_bazel_lib_dependencies(override_local_config_platform = True)

http_archive(
    name = "aspect_rules_js",
    sha256 = "66ecc9f56300dd63fb86f11cfa1e8affcaa42d5300e2746dba08541916e913fd",
    strip_prefix = "rules_js-1.13.0",
    url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v1.13.0.tar.gz",
)

load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

rules_js_dependencies()

load("@rules_nodejs//nodejs:repositories.bzl", "DEFAULT_NODE_VERSION", "nodejs_register_toolchains")

nodejs_register_toolchains(
    name = "nodejs",
    node_version = DEFAULT_NODE_VERSION,
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
