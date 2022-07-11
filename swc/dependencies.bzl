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
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "4ef2f746bae7bd7f1ec39dc9b53a9d7e8002f18233ea2c2ee4702bbb5283c7ca",
        strip_prefix = "bazel-lib-1.3.1",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.3.1.tar.gz",
    )

    http_archive(
        name = "aspect_rules_js",
        sha256 = "be39996444ab94de605e21cdcaa9bc4965a96186329d776e400b47fefd540902",
        strip_prefix = "rules_js-1.0.0-rc.0",
        url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v1.0.0-rc.0.tar.gz",
    )

    http_archive(
        name = "rules_nodejs",
        sha256 = "017e2348bb8431156d5cf89b6f502c2e7fcffc568729f74f89e4a12bd8279e90",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.5.2/rules_nodejs-core-5.5.2.tar.gz"],
    )
