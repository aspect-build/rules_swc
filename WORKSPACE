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
        "darwin-arm64": "sha384-4TRcW8Nb2g/3zQ0T4aS+NSjMbUaIHaGxofkA67CcAQZbeK1uDmjXFh5uJw69ZV07",
        "darwin-x64": "sha384-uh5Pt06OgF/bhQaq09/SO0hNa9x/isZ3O9R+3uwseSdbL7OentceFHZ/zTr9Y+xL",
        "linux-arm64-gnu": "sha384-2uYEohzUAAalEGiD0iEPEDWlR1BCM4q+DhsnIe5saa8B2+igdLzsQrbREimhu5TJ",
        "linux-x64-gnu": "sha384-c46sYs/jCA4OjV7LeWT201dYQDTO76V6sZzdtOiGt+3Gls9n6QG+K4hkpIE+wy0k",
    },
    swc_version = "v1.3.25",
)

load("@aspect_bazel_lib//lib:repositories.bzl", "aspect_bazel_lib_dependencies")

aspect_bazel_lib_dependencies(override_local_config_platform = True)

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
