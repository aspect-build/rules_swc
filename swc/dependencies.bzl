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
        sha256 = "a2b1b60c51b0193ed1646accf77a28cfd4f4ce1f6c86f32ce11455101be3a9c4",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/4.4.3/rules_nodejs-core-4.4.3.tar.gz"],
    )

    maybe(
        http_archive,
        name = "aspect_bazel_lib",
        sha256 = "7cb2faf813bae1712dcb09b23dd8d68fffd8631a25d54b9ca8ae866ca7debc06",
        urls = ["https://github.com/aspect-build/bazel-lib/releases/download/v0.2.1/bazel_lib-0.2.1.tar.gz"],
    )

    maybe(
        http_archive,
        name = "aspect_rules_js",
        sha256 = "6715942b2c6a9e3ca2a7cdd229111dcf93d4741a35fad039dec7fccd8b9b6f5d",
        strip_prefix = "rules_js-swc",
        # TODO: switch to release after merge
        url = "https://github.com/aspect-build/rules_js/archive/refs/heads/swc.zip",
    )
