"""Starlark helper to fetch rules_swc dependencies.

Should be replaced by bzlmod for users of Bazel 6.0 and above.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
def rules_swc_dependencies():
    http_archive(
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
        ],
        sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "c6b3ab90e04dbf6d7753c1a59d50b73eec2c91ed59396940ddad7975008c0eb9",
        strip_prefix = "bazel-lib-1.9.1",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.9.1.tar.gz",
    )

    http_archive(
        name = "aspect_rules_js",
        sha256 = "d01c514f7471db19cd86d8c15fe95409fca34750969afac2087668761121ee6a",
        strip_prefix = "rules_js-be1ee2e8f65ff9e086487110c1115a5eb4934231",
        url = "https://github.com/aspect-build/rules_js/archive/be1ee2e8f65ff9e086487110c1115a5eb4934231.tar.gz",
    )

    http_archive(
        name = "rules_nodejs",
        sha256 = "017e2348bb8431156d5cf89b6f502c2e7fcffc568729f74f89e4a12bd8279e90",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.5.2/rules_nodejs-core-5.5.2.tar.gz"],
    )
