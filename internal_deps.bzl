"""Our "development" dependencies

Users should *not* need to install these. If users see a load()
statement from these, that's a bug in our distribution.
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

# buildifier: disable=bzl-visibility
load("//swc/private:maybe.bzl", http_archive = "maybe_http_archive")

def rules_swc_internal_deps():
    "Fetch deps needed for local development"

    http_archive(
        name = "io_bazel_rules_go",
        sha256 = "099a9fb96a376ccbbb7d291ed4ecbdfd42f6bc822ab77ae6f1b5cb9e914e94fa",
        urls = ["https://github.com/bazelbuild/rules_go/releases/download/v0.35.0/rules_go-v0.35.0.zip"],
    )

    http_archive(
        name = "bazel_gazelle",
        sha256 = "448e37e0dbf61d6fa8f00aaa12d191745e14f07c31cabfa731f0c8e8a4f41b97",
        urls = ["https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.28.0/bazel-gazelle-v0.28.0.tar.gz"],
    )

    http_archive(
        name = "bazel_skylib_gazelle_plugin",
        sha256 = "0a466b61f331585f06ecdbbf2480b9edf70e067a53f261e0596acd573a7d2dc3",
        urls = ["https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.1/bazel-skylib-gazelle-plugin-1.4.1.tar.gz"],
    )

    http_archive(
        name = "io_bazel_stardoc",
        sha256 = "3fd8fec4ddec3c670bd810904e2e33170bedfe12f90adf943508184be458c8bb",
        urls = ["https://github.com/bazelbuild/stardoc/releases/download/0.5.3/stardoc-0.5.3.tar.gz"],
    )

    # http_archive(
    #     name = "buildifier_prebuilt",
    #     sha256 = "e46c16180bc49487bfd0f1ffa7345364718c57334fa0b5b67cb5f27eba10f309",
    #     strip_prefix = "buildifier-prebuilt-6.1.0",
    #     urls = [
    #         "https://github.com/keith/buildifier-prebuilt/archive/6.1.0.tar.gz",
    #     ],
    # )

    git_repository(
        name = "buildifier_prebuilt",
        remote = "https://github.com/jbedard/buildifier-prebuilt.git",
        commit = "d5326303d222c00f395f31f63ba6df532fd94404",
    )
