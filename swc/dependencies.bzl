"""Starlark helper to fetch rules_swc dependencies.

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies

Replaced by bzlmod for users of Bazel 6.0 and above.
"""

load("//swc/private:maybe.bzl", http_archive = "maybe_http_archive")

def rules_swc_dependencies():
    http_archive(
        name = "bazel_skylib",
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
        urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz"],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "ef83252dea2ed8254c27e65124b756fc9476be2b73a7799b7a2a0935937fc573",
        strip_prefix = "bazel-lib-1.24.2",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.24.2.tar.gz",
    )

    http_archive(
        name = "aspect_rules_js",
        sha256 = "2868c450aaa83ec19ee172015c6445264b6422d6d0d61da6af47ec8a159b0e5a",
        strip_prefix = "rules_js-1.17.0",
        url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v1.17.0.tar.gz",
    )
