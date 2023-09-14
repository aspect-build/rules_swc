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

### Other versions

To use an swc version which is not mirrored to rules_swc, use `integrity_hashes`.

For example in `WORKSPACE`:

```starlark
swc_register_toolchains(
    name = "swc",
    integrity_hashes = {
        "darwin-arm64": "sha384-IhP/76Zi5PEfsrGwPJj/CLHu2afxSBO2Fehp/qo4uHVXez08dcfyd9UzrcUI1z1q",
        "darwin-x64": "sha384-s2wH7hzaMbTbIkgPpP5rAYThH/+H+RBQ/5xKbpM4lfwPMS6cNBIpjKVnathrENm/",
        "linux-arm64-gnu": "sha384-iaBhMLrnHTSfXa86AVHM6zHqYbH3Fh1dWwDeH7sW9HKvX2gbQb6LOpWN6Wp4ddud",
        "linux-x64-gnu": "sha384-R/y9mcodpNt8l6DulUCG5JsNMrApP+vOAAh3bTRChh6LQKP0Z3Fwq86ztfObpAH8",
    },
    swc_version = "v1.3.37",
)
```

You can use the [`mirror_releases.sh` script](https://github.com/aspect-build/rules_swc/blob/main/scripts/mirror_releases.sh) to generate the expected shas. For example:
```
&gt; mirror_releases.sh v1.3.50
    "v1.3.50": {
        "darwin-arm64": "sha384-kXrPSxzwUCsB2y0ivQrCrBDULa+N9BwwtKzqo4hIgYmgZgBGP8cXfEWlM18Pe2mT",
        "darwin-x64": "sha384-xRo3yRFsS8w5I7uWG7ZDpDiIhlJVUADpXzCWCNkYEsO4vJGD3izvTCUyWcF6HaRj",
        "linux-arm-gnueabihf": "sha384-WoVw65RR2yq7fZGRpGKGDwyloteD2XjxMkqVDip2BkKuGVZMDjqldivLYx56Nhzq",
        "linux-arm64-gnu": "sha384-f1pB/FU6PVYSW8KIFA799chHgXPeoaH2z8E82Mc2V21pQeJWITasy5h5wPHghZ9i",
        "linux-x64-gnu": "sha384-MdR0sNOSZG4AfCBQFfqSGJ5A9Zi5mMgL7wdIeQpzqjkPICK2uDl5/MgJbO4D3kAM",
        "win32-arm64-msvc": "sha384-PSmCSGrZBoFg8D+S7NqmlVr4HSedlWU2IsF0eci9jUQb+eBJeco3IO4V+IIhCiKw",
        "win32-ia32-msvc": "sha384-HXRGllEV7LnLN/tgB5FfspniKG3y43C1bKIatDQIWk56gekAzm1ntV1W0qAYjz3M",
        "win32-x64-msvc": "sha384-0oZDYXsh1Aeiqt9jA/HcWEM/yMXoC7fQvkPhDjUf0nVimZuPehj4BPWCyiIsrD1s",
    },
```



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
| <a id="swc_repositories-integrity_hashes"></a>integrity_hashes |  A mapping from platform to integrity hash.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional | <code>{}</code> |
| <a id="swc_repositories-platform"></a>platform |  -   | String | required |  |
| <a id="swc_repositories-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="swc_repositories-swc_version"></a>swc_version |  Explicit version. If provided, the package.json is not read.   | String | optional | <code>""</code> |
| <a id="swc_repositories-swc_version_from"></a>swc_version_from |  Location of package.json which has a version for @swc/core.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | <code>None</code> |


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


