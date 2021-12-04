# Bazel rules for swc

## Installation

Include this in your WORKSPACE file:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
http_archive(
    name = "aspect_rules_swc",
    url = "https://github.com/myorg/rules_swc/archive/0.0.0/rules_swc-0.0.0.tar.gz",
    sha256 = "",
)

load("@aspect_rules_swc//swc:repositories.bzl", "swc_rules_dependencies")

# This fetches the rules_swc dependencies, which are:
# - bazel_skylib
# If you want to have a different version of some dependency,
# you should fetch it *before* calling this.
# Alternatively, you can skip calling this function, so long as you've
# already fetched these dependencies.
rules_swc_dependencies()
```

> note, in the above, replace the version and sha256 with the one indicated
> in the release notes for rules_swc
> In the future, our release automation should take care of this.
