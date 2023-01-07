"""Utilities for writing tests

TODO: promote to public API.
"""

load("@aspect_bazel_lib//lib:jq.bzl", "jq")
load("@bazel_skylib//rules:diff_test.bzl", "diff_test")

def matching_paths_test(name, tsconfig = "tsconfig.json", swcrc = ".swcrc"):
    jq(
        name = "_ts_" + name,
        srcs = [tsconfig],
        filter = ".compilerOptions.paths",
    )

    jq(
        name = "_swc_" + name,
        srcs = [swcrc],
        filter = ".jsc.paths",
    )

    diff_test(
        name = name,
        file1 = "_ts_" + name,
        file2 = "_swc_" + name,
        failure_message = "tsconfig compilerOptions.paths don't match swcrc jsc.paths",
    )
