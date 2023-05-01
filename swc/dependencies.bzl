"""Starlark helper to fetch rules_swc dependencies.

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies

Replaced by bzlmod for users of Bazel 6.0 and above.
"""

load("//swc/private:maybe.bzl", http_archive = "maybe_http_archive")

def rules_swc_dependencies():
    http_archive(
        name = "bazel_skylib",
        sha256 = "b8a1527901774180afc798aeb28c4634bdccf19c4d98e7bdd1ce79d1fe9aaad7",
        urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-1.4.1.tar.gz"],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "97fa63d95cc9af006c4c7b2123ddd2a91fb8d273012f17648e6423bae2c69470",
        strip_prefix = "bazel-lib-1.30.2",
        url = "https://github.com/aspect-build/bazel-lib/releases/download/v1.30.2/bazel-lib-v1.30.2.tar.gz",
    )

    http_archive(
        name = "aspect_rules_js",
        sha256 = "2a1e5d4400e2b49f6d36785aa894412670a0babfe7054e733b6a8f23c1b41e26",
        strip_prefix = "rules_js-1.23.1",
        url = "https://github.com/aspect-build/rules_js/releases/download/v1.23.1/rules_js-v1.23.1.tar.gz",
    )
