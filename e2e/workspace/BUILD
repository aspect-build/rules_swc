load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@aspect_rules_swc//swc:defs.bzl", "swc")

swc(name = "compile")

build_test(
    name = "test",
    targets = [":compile"],
)
