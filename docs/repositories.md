<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Repository rules for fetching the swc toolchain.

For typical usage, see the snippets provided in the rules_swc release notes.


<a id="swc_repositories"></a>

## swc_repositories

<pre>
swc_repositories(<a href="#swc_repositories-name">name</a>, <a href="#swc_repositories-integrity_hashes">integrity_hashes</a>, <a href="#swc_repositories-platform">platform</a>, <a href="#swc_repositories-repo_mapping">repo_mapping</a>, <a href="#swc_repositories-swc_version">swc_version</a>, <a href="#swc_repositories-swc_version_from">swc_version_from</a>)
</pre>

Fetch external dependencies needed to run the SWC cli

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="swc_repositories-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="swc_repositories-integrity_hashes"></a>integrity_hashes |  -   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional | <code>{}</code> |
| <a id="swc_repositories-platform"></a>platform |  -   | String | required |  |
| <a id="swc_repositories-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="swc_repositories-swc_version"></a>swc_version |  Explicit version. If provided, the package.json is not read.   | String | optional | <code>""</code> |
| <a id="swc_repositories-swc_version_from"></a>swc_version_from |  Location of package.json which may have a version for @swc/core.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |


<a id="swc_register_toolchains"></a>

## swc_register_toolchains

<pre>
swc_register_toolchains(<a href="#swc_register_toolchains-name">name</a>, <a href="#swc_register_toolchains-swc_version">swc_version</a>, <a href="#swc_register_toolchains-swc_version_from">swc_version_from</a>, <a href="#swc_register_toolchains-register">register</a>, <a href="#swc_register_toolchains-kwargs">kwargs</a>)
</pre>

Convenience macro for users which does typical setup.

- create a repository for each built-in platform like "swc_linux_amd64"
- create a repository exposing toolchains for each platform like "swc_platforms"
- register a toolchain pointing at each platform
Users can avoid this macro and do these steps themselves, if they want more control.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="swc_register_toolchains-name"></a>name |  base name for all created repos; we recommend <code>swc</code>   |  none |
| <a id="swc_register_toolchains-swc_version"></a>swc_version |  version of the swc project, from https://github.com/swc-project/swc/releases Exactly one of <code>swc_version</code> or <code>swc_version_from</code> must be set.   |  <code>None</code> |
| <a id="swc_register_toolchains-swc_version_from"></a>swc_version_from |  label of a json file (typically <code>package.json</code>) which declares an exact <code>@swc/core</code> version in a dependencies or devDependencies property. Exactly one of <code>swc_version</code> or <code>swc_version_from</code> must be set.   |  <code>None</code> |
| <a id="swc_register_toolchains-register"></a>register |  whether to call through to native.register_toolchains. Should be True for WORKSPACE users, but false when used under bzlmod extension   |  <code>True</code> |
| <a id="swc_register_toolchains-kwargs"></a>kwargs |  passed to each swc_repositories call   |  none |


