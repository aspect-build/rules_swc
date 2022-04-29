load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@aspect_rules_swc//swc:swc.bzl", "swc")

swc(name = "transpile")

build_test(
    name = "test",
    targets = [":transpile"],
)
