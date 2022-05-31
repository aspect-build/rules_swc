"""Starlark helper to fetch rules_swc dependencies.

Should be replaced by bzlmod for users of Bazel 6.0 and above.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
def rules_swc_dependencies():
    maybe(
        http_archive,
        name = "bazel_skylib",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.1.1/bazel-skylib-1.1.1.tar.gz",
        ],
        sha256 = "c6966ec828da198c5d9adbaa94c05e3a1c7f21bd012a0b29ba8ddbccb2c93b0d",
    )

    maybe(
        http_archive,
        name = "rules_nodejs",
        sha256 = "8f4a19de1eb16b57ac03a8e9b78344b44473e0e06b0510cec14a81f6adfdfc25",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/4.4.6/rules_nodejs-core-4.4.6.tar.gz"],
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "a8b47eeaf3c1bd41c4f4b633ef4c959daf83fdee343379495098b50571d4b3b8",
        strip_prefix = "bazel-lib-0.11.1",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v0.11.1.tar.gz",
    )

    maybe(
        http_archive,
        name = "aspect_rules_js",
        sha256 = "f01010e1f6bd49a8da6f7350c60992b7eb2eb62058cfe7aa6abd9e416bc2158b",
        strip_prefix = "rules_js-0.9.1",
        url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v0.9.1.tar.gz",
    )
