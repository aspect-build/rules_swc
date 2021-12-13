<!-- Generated with Stardoc: http://skydoc.bazel.build -->

swc rule

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


