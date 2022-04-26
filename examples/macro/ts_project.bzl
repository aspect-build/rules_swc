"""An example macro that abstracts processing of a TypeScript library in your repo.

See explanation in ./BUILD.bazel"""

load("@aspect_bazel_lib//lib:copy_to_bin.bzl", "copy_to_bin")

def my_ts_project(name, srcs = []):
    """TODO: docs

    Args:
        name: name of the resulting target
        srcs: todo
    """

    for src in srcs:
        # js_binary always runs with a working directory under bazel-out/[arch]/bin
        # so the sources need to be copied there, and all other paths re-relativized.
        copy_to_bin(
            name = "cp_" + src,
            srcs = [src],
        )
        out = src.replace(".ts", ".js")

        # Run the swc cli directly with arguments we choose.
        # See https://docs.bazel.build/versions/main/be/general.html#genrule
        # You could use the `swc` rule here instead if it meets your needs, this example uses
        # genrule to have more control over the command line arguments.
        native.genrule(
            name = "run",
            srcs = ["cp_" + src],
            outs = [out],
            cmd = " ".join([
                "BAZEL_BINDIR=$(BINDIR)",
                "SWC_BINARY_PATH=../../../$(SWC_BINARY_PATH)",
                "$(execpath @aspect_rules_swc//swc:cli)",
                # Avoid using `$@` to reference output, as it has the bindir prefix
                "--out-file {0}/{1}".format(native.package_name(), out),
                "{0}/{1}".format(native.package_name(), src),
            ]),
            toolchains = ["@default_swc_toolchains//:resolved_toolchain"],
            tools = [
                "@aspect_rules_swc//swc:cli",
                "@default_swc_toolchains//:resolved_toolchain",
            ],
        )
