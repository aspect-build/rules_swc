<!-- Generated with Stardoc: http://skydoc.bazel.build -->

swc rule

<a id="#swc"></a>

## swc

<pre>
swc(<a href="#swc-name">name</a>, <a href="#swc-srcs">srcs</a>, <a href="#swc-args">args</a>, <a href="#swc-source_maps">source_maps</a>, <a href="#swc-source_map_outputs">source_map_outputs</a>)
</pre>

Execute the swc compiler

**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="swc-name"></a>name |  A name for the target   |  none |
| <a id="swc-srcs"></a>srcs |  srcs   |  <code>None</code> |
| <a id="swc-args"></a>args |  additional use args to pass to swc cli   |  <code>[]</code> |
| <a id="swc-source_maps"></a>source_maps |  If set, the --source-maps argument is passed to the swc cli with the value True/False are automaticaly converted to "true"/"false" string values the cli expects If source_maps is "true" or "both" then source_map_outputs is automatically set to True   |  <code>None</code> |
| <a id="swc-source_map_outputs"></a>source_map_outputs |  if the rule is expected to produce a .js.map file output for each .js file output   |  <code>False</code> |


