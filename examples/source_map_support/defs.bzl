"""
Macro wrappers around rules_js's `js_binary` and `js_test` that improve the DX of stack traces by automatically
registering source-map-support and removing the runfiles directory prefix.

Use them wherever you would use rules_js's `js_binary` and `js_test`.
"""

load("@aspect_rules_js//js:defs.bzl", _js_binary = "js_binary", _js_test = "js_test")

def js_binary(data = [], chdir = None, node_options = [], **kwargs):
    rel = "./"
    if chdir:
        rel = rel + "/".join([".." for _ in chdir.split("/")]) + "/"

    _js_binary(
        chdir = chdir,
        data = [
            "//examples:node_modules/source-map-support",
            "//examples/source_map_support:stack-trace-support",
        ] + data,
        node_options = ["--require", rel + "$(rootpath //examples/source_map_support:stack-trace-support)"] + node_options,
        **kwargs
    )

def js_test(data = [], chdir = None, node_options = [], **kwargs):
    rel = "./"
    if chdir:
        rel = rel + "/".join([".." for _ in chdir.split("/")]) + "/"

    _js_test(
        chdir = chdir,
        data = [
            "//examples:node_modules/source-map-support",
            "//examples/source_map_support:stack-trace-support",
        ] + data,
        node_options = ["--require", rel + "$(rootpath //examples/source_map_support:stack-trace-support)"] + node_options,
        **kwargs
    )
