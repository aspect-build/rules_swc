"""An example macro that abstracts processing of a TypeScript library in your repo.

See explanation in ./BUILD.bazel"""

def my_ts_project(name, srcs = []):
    """TODO: docs

    Args:
        name: name of the resulting target
        srcs: todo
    """

    for src in srcs:
        # Run the swc cli directly with arguments we choose.
        # See https://docs.bazel.build/versions/main/be/general.html#genrule
        # You could use the `swc` rule here instead if it meets your needs, this example uses
        # genrule to have more control over the command line arguments.
        native.genrule(
            name = "run",
            srcs = [src],
            outs = [src.replace(".ts", ".js")],
            cmd = """SWC_BINDING=$(SWC_BINDING) \\
                $(execpath @aspect_rules_swc//swc:cli) \\
                $(location in.ts) \\
                -o $@""",
            toolchains = ["@swc_toolchains//:resolved_toolchain"],
            tools = [
                "@aspect_rules_swc//swc:cli",
                "@swc_toolchains//:resolved_toolchain",
            ],
        )
