# Bazel rules for swc

## Installation

Runfiles need to be enabled in Bazel for the rules to work. On Windows, this is not enabled by default.

Add this to the `.bazelrc` in your project:

```
build --enable_runfiles
```

Next, include this in your WORKSPACE file:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# See the rules_swc releases page for an up-to-date snippet.
_RULES_SWC_VERSION="02b26f90549025fe7f78909ab668404c5cb9aaea"
http_archive(
    name = "aspect_rules_swc",
    url = "https://github.com/aspect-build/rules_swc/archive/%s.zip" % _RULES_SWC_VERSION,
    strip_prefix = "rules_swc-" + _RULES_SWC_VERSION,
    sha256 = "e0c6ae79ac380879a22b186970f41357e89a35df983f3dfb8564f24445f31537",
)

load("@aspect_rules_swc//swc:dependencies.bzl", "rules_swc_dependencies")

# This fetches the rules_swc dependencies.
# If you want to have a different version of some dependency,
# you should fetch it *before* calling this.
# Alternatively, you can skip calling this function, so long as you've
# already fetched all the dependencies.
rules_swc_dependencies()

load("@aspect_rules_swc//swc:repositories.bzl", "swc_register_toolchains")

# This fetches a pre-built Rust-node binding from
# https://github.com/swc-project/swc/releases
# If you'd rather compile it from source, you can use rules_rust, fetch the project,
# then register the toolchain yourself.
swc_register_toolchains(
    name = "swc",
    swc_version = "1.2.117",
)

load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")

# Fetch a NodeJS interpreter, needed to run the swc CLI
nodejs_register_toolchains(
    name = "node16",
    node_version = "16.9.0",
)

load("@swc_cli//:repositories.bzl", _swc_cli_deps = "npm_repositories")

# Fetch the npm packages needed to run @swc/cli
_swc_cli_deps()
```

> note, in the above, replace the version and sha256 with the one indicated
> in the release notes for rules_swc
> In the future, our release automation should take care of this.
