<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Repository rules for fetching the swc toolchain.

For typical usage, see the snippets provided in the rules_swc release notes.

### Version matching

To keep the swc version in sync with non-Bazel tooling, use `swc_version_from`.

Currently this only works when a single, pinned version appears, see:
https://github.com/aspect-build/rules_ts/issues/308

For example, `package.json`:

```json
{
  "devDependencies": {
    "@swc/core": "1.3.37"
  }
}
```

Allows this in `WORKSPACE`:

```starlark
swc_register_toolchains(
    name = "swc",
    swc_version_from = "//:package.json",
)
```

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
| <a id="swc_register_toolchains-name"></a>name |  base name for all created repos; we recommend `swc`   |  none |
| <a id="swc_register_toolchains-swc_version"></a>swc_version |  version of the swc project, from https://github.com/swc-project/swc/releases Exactly one of `swc_version` or `swc_version_from` must be set.   |  `None` |
| <a id="swc_register_toolchains-swc_version_from"></a>swc_version_from |  label of a json file (typically `package.json`) which declares an exact `@swc/core` version in a dependencies or devDependencies property. Exactly one of `swc_version` or `swc_version_from` must be set.   |  `None` |
| <a id="swc_register_toolchains-register"></a>register |  whether to call through to native.register_toolchains. Should be True for WORKSPACE users, but false when used under bzlmod extension   |  `True` |
| <a id="swc_register_toolchains-kwargs"></a>kwargs |  passed to each swc_repositories call   |  none |


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
| <a id="swc_repositories-integrity_hashes"></a>integrity_hashes |  A mapping from platform to integrity hash.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="swc_repositories-platform"></a>platform |  -   | String | required |  |
| <a id="swc_repositories-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |
| <a id="swc_repositories-swc_version"></a>swc_version |  Explicit version. If provided, the package.json is not read.   | String | optional |  `""`  |
| <a id="swc_repositories-swc_version_from"></a>swc_version_from |  Location of package.json which has a version for @swc/core.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |


