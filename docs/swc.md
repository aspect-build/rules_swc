<!-- Generated with Stardoc: http://skydoc.bazel.build -->

API for running the SWC cli under Bazel

The simplest usage relies on the `swcrc` attribute automatically discovering `.swcrc`:

```starlark
load("@aspect_rules_swc//swc:defs.bzl", "swc")

swc(
    name = "compile",
    srcs = ["file.ts"],
)
```

<a id="swc_compile"></a>

## swc_compile

<pre>
swc_compile(<a href="#swc_compile-name">name</a>, <a href="#swc_compile-srcs">srcs</a>, <a href="#swc_compile-data">data</a>, <a href="#swc_compile-args">args</a>, <a href="#swc_compile-js_outs">js_outs</a>, <a href="#swc_compile-map_outs">map_outs</a>, <a href="#swc_compile-out_dir">out_dir</a>, <a href="#swc_compile-output_dir">output_dir</a>, <a href="#swc_compile-plugins">plugins</a>, <a href="#swc_compile-root_dir">root_dir</a>,
            <a href="#swc_compile-source_maps">source_maps</a>, <a href="#swc_compile-source_root">source_root</a>, <a href="#swc_compile-swcrc">swcrc</a>)
</pre>

Underlying rule for the `swc` macro.

Most users should use [swc](#swc) instead, as it predicts the output files
and has convenient default values.

Use this if you need more control over how the rule is called,
for example to set your own output labels for `js_outs`.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="swc_compile-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="swc_compile-srcs"></a>srcs |  source files, typically .ts files in the source tree   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="swc_compile-data"></a>data |  Runtime dependencies to include in binaries/tests that depend on this target.<br><br>Follows the same semantics as `js_library` `data` attribute. See https://docs.aspect.build/rulesets/aspect_rules_js/docs/js_library#data for more info.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="swc_compile-args"></a>args |  Additional arguments to pass to swcx cli (NOT swc!).<br><br>NB: this is not the same as the CLI arguments for @swc/cli npm package. For performance, rules_swc does not call a Node.js program wrapping the swc rust binding. Instead, we directly spawn the (somewhat experimental) native Rust binary shipped inside the @swc/core npm package, which the swc project calls "swcx" Tracking issue for feature parity: https://github.com/swc-project/swc/issues/4017   | List of strings | optional |  `[]`  |
| <a id="swc_compile-js_outs"></a>js_outs |  list of expected JavaScript output files.<br><br>There should be one for each entry in srcs.   | List of labels | optional |  `[]`  |
| <a id="swc_compile-map_outs"></a>map_outs |  list of expected source map output files.<br><br>Can be empty, meaning no source maps should be produced. If non-empty, there should be one for each entry in srcs.   | List of labels | optional |  `[]`  |
| <a id="swc_compile-out_dir"></a>out_dir |  With output_dir=False, output files will have this directory prefix.<br><br>With output_dir=True, this is the name of the output directory.   | String | optional |  `""`  |
| <a id="swc_compile-output_dir"></a>output_dir |  Whether to produce a directory output rather than individual files.<br><br>If out_dir is also specified, it is used as the name of the output directory. Otherwise, the directory is named the same as the target.   | Boolean | optional |  `False`  |
| <a id="swc_compile-plugins"></a>plugins |  swc compilation plugins, created with swc_plugin rule   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="swc_compile-root_dir"></a>root_dir |  a subdirectory under the input package which should be consider the root directory of all the input files   | String | optional |  `""`  |
| <a id="swc_compile-source_maps"></a>source_maps |  Create source map files for emitted JavaScript files.<br><br>see https://swc.rs/docs/usage/cli#--source-maps--s   | String | optional |  `"false"`  |
| <a id="swc_compile-source_root"></a>source_root |  Specify the root path for debuggers to find the reference source code.<br><br>see https://swc.rs/docs/usage/cli#--source-root<br><br>If not set, then the directory containing the source file is used.   | String | optional |  `""`  |
| <a id="swc_compile-swcrc"></a>swcrc |  label of a configuration file for swc, see https://swc.rs/docs/configuration/swcrc   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


<a id="swc"></a>

## swc

<pre>
swc(<a href="#swc-name">name</a>, <a href="#swc-srcs">srcs</a>, <a href="#swc-args">args</a>, <a href="#swc-data">data</a>, <a href="#swc-plugins">plugins</a>, <a href="#swc-output_dir">output_dir</a>, <a href="#swc-swcrc">swcrc</a>, <a href="#swc-source_maps">source_maps</a>, <a href="#swc-out_dir">out_dir</a>, <a href="#swc-root_dir">root_dir</a>, <a href="#swc-kwargs">kwargs</a>)
</pre>

Execute the SWC compiler

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="swc-name"></a>name |  A name for this target   |  none |
| <a id="swc-srcs"></a>srcs |  List of labels of TypeScript source files.   |  none |
| <a id="swc-args"></a>args |  Additional options to pass to `swcx` cli, see https://github.com/swc-project/swc/discussions/3859 Note: we do **not** run the [NodeJS wrapper `@swc/cli`](https://swc.rs/docs/usage/cli)   |  `[]` |
| <a id="swc-data"></a>data |  Files needed at runtime by binaries or tests that transitively depend on this target. See https://bazel.build/reference/be/common-definitions#typical-attributes   |  `[]` |
| <a id="swc-plugins"></a>plugins |  List of plugin labels created with `swc_plugin`.   |  `[]` |
| <a id="swc-output_dir"></a>output_dir |  Whether to produce a directory output rather than individual files.<br><br>If `out_dir` is set, then that is used as the name of the output directory. Otherwise, the output directory is named the same as the target.   |  `False` |
| <a id="swc-swcrc"></a>swcrc |  Label of a .swcrc configuration file for the SWC cli, see https://swc.rs/docs/configuration/swcrc Instead of a label, you can pass a dictionary matching the JSON schema. If this attribute isn't specified, and a file `.swcrc` exists in the same folder as this rule, it is used.<br><br>Note that some settings in `.swcrc` also appear in `tsconfig.json`. See the notes in [/docs/tsconfig.md].   |  `None` |
| <a id="swc-source_maps"></a>source_maps |  If set, the --source-maps argument is passed to the SWC cli with the value. See https://swc.rs/docs/usage/cli#--source-maps--s. True/False are automaticaly converted to "true"/"false" string values the cli expects.   |  `False` |
| <a id="swc-out_dir"></a>out_dir |  The base directory for output files relative to the output directory for this package.<br><br>If output_dir is True, then this is used as the name of the output directory.   |  `None` |
| <a id="swc-root_dir"></a>root_dir |  A subdirectory under the input package which should be considered the root directory of all the input files   |  `None` |
| <a id="swc-kwargs"></a>kwargs |  additional keyword arguments passed through to underlying [`swc_compile`](#swc_compile), eg. `visibility`, `tags`   |  none |


<a id="swc_plugin"></a>

## swc_plugin

<pre>
swc_plugin(<a href="#swc_plugin-name">name</a>, <a href="#swc_plugin-srcs">srcs</a>, <a href="#swc_plugin-config">config</a>, <a href="#swc_plugin-kwargs">kwargs</a>)
</pre>

Configure an SWC plugin

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="swc_plugin-name"></a>name |  A name for this target   |  none |
| <a id="swc_plugin-srcs"></a>srcs |  Plugin files. Either a directory containing a package.json pointing at a wasm file as the main entrypoint, or a wasm file. Usually a linked npm package target via rules_js.   |  `[]` |
| <a id="swc_plugin-config"></a>config |  Optional configuration dict for the plugin. This is passed as a JSON object into the `jsc.experimental.plugins` entry for the plugin.   |  `{}` |
| <a id="swc_plugin-kwargs"></a>kwargs |  additional keyword arguments passed through to underlying rule, eg. `visibility`, `tags`   |  none |


