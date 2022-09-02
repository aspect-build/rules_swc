<!-- Generated with Stardoc: http://skydoc.bazel.build -->

API for running SWC under Bazel

Simplest usage:

```starlark
load("@aspect_rules_swc//swc:defs.bzl", "swc")

swc(name = "transpile")
```

Known issues:
- import statements improperly transformed when using symlinks: [swc#4057](https://github.com/swc-project/swc/issues/4057)
  See https://github.com/aspect-build/rules_swc/issues/31.
  You can add this to your `.bazelrc` to workaround by disabling sandboxing for SWC actions:
  `build --modify_execution_info=SWCTranspile=+no-sandbox`


<a id="swc_transpiler"></a>

## swc_transpiler

<pre>
swc_transpiler(<a href="#swc_transpiler-name">name</a>, <a href="#swc_transpiler-args">args</a>, <a href="#swc_transpiler-data">data</a>, <a href="#swc_transpiler-js_outs">js_outs</a>, <a href="#swc_transpiler-map_outs">map_outs</a>, <a href="#swc_transpiler-out_dir">out_dir</a>, <a href="#swc_transpiler-output_dir">output_dir</a>, <a href="#swc_transpiler-root_dir">root_dir</a>, <a href="#swc_transpiler-source_maps">source_maps</a>,
               <a href="#swc_transpiler-srcs">srcs</a>, <a href="#swc_transpiler-swc_cli">swc_cli</a>, <a href="#swc_transpiler-swcrc">swcrc</a>)
</pre>

Underlying rule for the `swc` macro.

Most users should just use [swc](#swc) instead.

Use this if you need more control over how the rule is called,
for example to set your own output labels for `js_outs`.

This rule is also suitable for the
[ts_project#transpiler](https://github.com/aspect-build/rules_ts/blob/main/docs/rules.md#ts_project-transpiler)
attribute.


**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="swc_transpiler-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="swc_transpiler-args"></a>args |  Additional arguments to pass to swcx cli (NOT swc!).<br><br>        NB: this is not the same as the CLI arguments for @swc/cli npm package.         For performance, rules_swc does not call a Node.js program wrapping the swc rust binding.         Instead, we directly spawn the (somewhat experimental) native Rust binary shipped inside the         @swc/core npm package, which the swc project calls "swcx"         Tracking issue for feature parity: https://github.com/swc-project/swc/issues/4017   | List of strings | optional | [] |
| <a id="swc_transpiler-data"></a>data |  Runtime dependencies to include in binaries/tests that depend on this target.<br><br>    The transitive npm dependencies, transitive sources, default outputs and runfiles of targets in the <code>data</code> attribute     are added to the runfiles of this taregt. Thery should appear in the '*.runfiles' area of any executable which has     a runtime dependency on this target.<br><br>    If this list contains linked npm packages, npm package store targets or other targets that provide <code>JsInfo</code>,     <code>NpmPackageStoreInfo</code> providers are gathered from <code>JsInfo</code>. This is done directly from the     <code>npm_package_store_deps</code> field of these. For linked npm package targets, the underlying npm_package_store     target(s) that back the links is used.<br><br>    Gathered <code>NpmPackageStoreInfo</code> providers are used downstream as direct dependencies when linking a downstream     <code>npm_package</code> target with <code>npm_link_package</code>.   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="swc_transpiler-js_outs"></a>js_outs |  list of expected JavaScript output files.<br><br>There must be one for each entry in srcs, and in the same order.   | List of labels | optional |  |
| <a id="swc_transpiler-map_outs"></a>map_outs |  list of expected source map output files.<br><br>Can be empty, meaning no source maps should be produced. If non-empty, there must be one for each entry in srcs, and in the same order.   | List of labels | optional |  |
| <a id="swc_transpiler-out_dir"></a>out_dir |  base directory for output files   | String | optional | "" |
| <a id="swc_transpiler-output_dir"></a>output_dir |  whether to produce a directory output rather than individual files   | Boolean | optional | False |
| <a id="swc_transpiler-source_maps"></a>source_maps |  see https://swc.rs/docs/usage/cli#--source-maps--s   | String | optional | "false" |
| <a id="swc_transpiler-srcs"></a>srcs |  source files, typically .ts files in the source tree   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| <a id="swc_transpiler-swcrc"></a>swcrc |  label of a configuration file for swc, see https://swc.rs/docs/configuration/swcrc   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |


<a id="swc"></a>

## swc

<pre>
swc(<a href="#swc-name">name</a>, <a href="#swc-srcs">srcs</a>, <a href="#swc-args">args</a>, <a href="#swc-data">data</a>, <a href="#swc-output_dir">output_dir</a>, <a href="#swc-swcrc">swcrc</a>, <a href="#swc-source_maps">source_maps</a>, <a href="#swc-out_dir">out_dir</a>, <a href="#swc-root_dir">root_dir</a>, <a href="#swc-kwargs">kwargs</a>)
</pre>

Execute the swc compiler

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="swc-name"></a>name |  A name for the target   |  none |
| <a id="swc-srcs"></a>srcs |  source files, typically .ts files in the source tree   |  <code>None</code> |
| <a id="swc-args"></a>args |  additional arguments to pass to swc cli, see https://swc.rs/docs/usage/cli   |  <code>[]</code> |
| <a id="swc-data"></a>data |  runtime dependencies to be propagated in the runfiles   |  <code>[]</code> |
| <a id="swc-output_dir"></a>output_dir |  whether to produce a directory output rather than individual files   |  <code>False</code> |
| <a id="swc-swcrc"></a>swcrc |  label of a configuration file for swc, see https://swc.rs/docs/configuration/swcrc   |  <code>None</code> |
| <a id="swc-source_maps"></a>source_maps |  If set, the --source-maps argument is passed to the swc cli with the value. See https://swc.rs/docs/usage/cli#--source-maps--s True/False are automaticaly converted to "true"/"false" string values the cli expects.   |  <code>False</code> |
| <a id="swc-out_dir"></a>out_dir |  base directory for output files relative to the output directory for this package   |  <code>None</code> |
| <a id="swc-root_dir"></a>root_dir |  a subdirectory under the input package which should be consider the root directory of all the input files   |  <code>None</code> |
| <a id="swc-kwargs"></a>kwargs |  additional named parameters like tags or visibility   |  none |


