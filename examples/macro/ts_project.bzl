"""An example macro that abstracts processing of a TypeScript library in your repo.

See explanation in ./BUILD.bazel"""

load("@bazel_skylib//rules:write_file.bzl", "write_file")

def my_ts_project(name, srcs = []):
    """TODO: docs

    Args:
        name: name of the resulting target
        srcs: todo
    """

    write_file(
        name = "_{}_config".format(name),
        out = ".swcrc",
        content = [json.encode({
            "jsc": {
                "parser": {
                    "syntax": "typescript",
                },
            },
        })],
    )

    for idx, src in enumerate(srcs):
        # Run the swc rust cli directly with arguments we choose.
        # See https://docs.bazel.build/versions/main/be/general.html#genrule
        # Most users would use the `swc` rule instead, this example uses
        # genrule to have more control over the command line arguments.
        native.genrule(
            name = "run_{}".format(idx),
            srcs = [src],
            outs = [src.replace(".ts", ".js")],
            cmd = "$(SWC_BINARY_PATH) compile --config-file $(location {}) --out-file $@ < $<".format(
                "_{}_config".format(name),
            ),
            toolchains = ["@default_swc_toolchains//:resolved_toolchain"],
            tools = [
                "_{}_config".format(name),
                "@default_swc_toolchains//:resolved_toolchain",
            ],
        )
