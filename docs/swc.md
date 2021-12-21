<!-- Generated with Stardoc: http://skydoc.bazel.build -->

API for running SWC under Bazel

Simplest usage:

```starlark
load("@aspect_rules_swc//swc:swc.bzl", "swc")

swc(name = "transpile")
```


<a id="#swc_rule"></a>

## swc_rule

<pre>
swc_rule(<a href="#swc_rule-name">name</a>, <a href="#swc_rule-args">args</a>, <a href="#swc_rule-data">data</a>, <a href="#swc_rule-js_outs">js_outs</a>, <a href="#swc_rule-map_outs">map_outs</a>, <a href="#swc_rule-output_dir">output_dir</a>, <a href="#swc_rule-srcs">srcs</a>, <a href="#swc_rule-swc_cli">swc_cli</a>, <a href="#swc_rule-swcrc">swcrc</a>)
</pre>

Underlying rule for the `swc` macro.

Most users should just use [swc](#swc) instead.

Use this if you need more control over how the rule is called,
for example to set your own output labels for `js_outs`.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="swc_rule-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/docs/build-ref.html#name">Name</a> | required |  |
| <a id="swc_rule-args"></a>args |  additional arguments to pass to swc cli, see https://swc.rs/docs/usage/cli   | List of strings | optional | [] |
| <a id="swc_rule-data"></a>data |  runtime dependencies propagated to binaries that depend on this   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | optional | [] |
| <a id="swc_rule-js_outs"></a>js_outs |  list of expected JavaScript output files   | List of labels | optional |  |
| <a id="swc_rule-map_outs"></a>map_outs |  list of expected source map output files   | List of labels | optional |  |
| <a id="swc_rule-output_dir"></a>output_dir |  whether to produce a directory output rather than individual files   | Boolean | optional | False |
| <a id="swc_rule-srcs"></a>srcs |  source files, typically .ts files in the source tree   | <a href="https://bazel.build/docs/build-ref.html#labels">List of labels</a> | required |  |
| <a id="swc_rule-swc_cli"></a>swc_cli |  binary that executes the swc CLI   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | @aspect_rules_swc//swc:cli |
| <a id="swc_rule-swcrc"></a>swcrc |  label of a configuration file for swc, see https://swc.rs/docs/configuration/swcrc   | <a href="https://bazel.build/docs/build-ref.html#labels">Label</a> | optional | None |


<a id="#swc"></a>

## swc

<pre>
swc(<a href="#swc-name">name</a>, <a href="#swc-srcs">srcs</a>, <a href="#swc-args">args</a>, <a href="#swc-data">data</a>, <a href="#swc-output_dir">output_dir</a>, <a href="#swc-swcrc">swcrc</a>, <a href="#swc-source_maps">source_maps</a>, <a href="#swc-source_map_outputs">source_map_outputs</a>, <a href="#swc-kwargs">kwargs</a>)
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
| <a id="swc-source_maps"></a>source_maps |  If set, the --source-maps argument is passed to the swc cli with the value. True/False are automaticaly converted to "true"/"false" string values the cli expects. If source_maps is "true" or "both" then source_map_outputs is automatically set to True.   |  <code>None</code> |
| <a id="swc-source_map_outputs"></a>source_map_outputs |  if the rule is expected to produce a .js.map file output for each .js file output   |  <code>False</code> |
| <a id="swc-kwargs"></a>kwargs |  additional named parameters like tags or visibility   |  none |


