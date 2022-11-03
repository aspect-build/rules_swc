"""Starlark helper to fetch rules_swc dependencies.

Should be replaced by bzlmod for users of Bazel 6.0 and above.
"""

load("//swc/private:maybe.bzl", http_archive = "maybe_http_archive")

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
def rules_swc_dependencies():
    http_archive(
        name = "bazel_skylib",
        sha256 = "74d544d96f4a5bb630d465ca8bbcfe231e3594e5aae57e1edbf17a6eb3ca2506",
        urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.3.0/bazel-skylib-1.3.0.tar.gz"],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "88ac1874c9930c5f01482d25a4f25104a788a178bf1c20053c00322ea7059bd6",
        strip_prefix = "bazel-lib-1.16.0",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.16.0.tar.gz",
    )

    http_archive(
        name = "aspect_rules_js",
        sha256 = "c3b5fd40ec19f3260094321380169abe86dd89e3506c4e44a515a50c1626629b",
        strip_prefix = "rules_js-1.6.6",
        url = "https://github.com/aspect-build/rules_js/archive/refs/tags/v1.6.6.tar.gz",
    )

    http_archive(
        name = "rules_nodejs",
        sha256 = "50adf0b0ff6fc77d6909a790df02eefbbb3bc2b154ece3406361dda49607a7bd",
        urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/5.7.1/rules_nodejs-core-5.7.1.tar.gz"],
    )
