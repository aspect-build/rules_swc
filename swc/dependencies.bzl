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
        name = "rules_nodejs",
        sha256 = "8f4a19de1eb16b57ac03a8e9b78344b44473e0e06b0510cec14a81f6adfdfc25",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/4.4.6/rules_nodejs-core-4.4.6.tar.gz"],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "8860aab705fe9f427fbebe388bdfacf8a6b267cb3c0d71ebeaf1dcceedd29193",
        strip_prefix = "bazel-lib-1.3.0",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.3.0.tar.gz",
    )

    http_archive(
        name = "aspect_rules_js",
        sha256 = "1fe40fd2819745ad19b5bec8f97a82087145fc6f145d3c84b0147899bf3490ca",
        strip_prefix = "rules_js-0.13.0",
        url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v0.13.0.tar.gz",
    )
