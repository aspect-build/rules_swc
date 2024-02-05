# How to Contribute

## Formatting

Starlark files should be formatted by buildifier.
We suggest using a pre-commit hook to automate this.
First [install pre-commit](https://pre-commit.com/#installation),
then run

```shell
pre-commit install
```

Otherwise later tooling on CI may yell at you about formatting/linting violations.

## Updating BUILD files

Some targets are generated from sources.
Currently this is just the `bzl_library` targets.
Run `aspect configure` to keep them up-to-date.

## Using this as a development dependency of other rules

You'll commonly find that you develop in another WORKSPACE, such as
some other ruleset that depends on rules_swc, or in a nested
WORKSPACE in the integration_tests folder.

To always tell Bazel to use this directory rather than some release
artifact or a version fetched from the internet, run this from this
directory:

```sh
OVERRIDE="--override_repository=rules_swc=$(pwd)/rules_swc"
echo "build $OVERRIDE" >> ~/.bazelrc
echo "query $OVERRIDE" >> ~/.bazelrc
```

This means that any usage of `@rules_swc` on your system will point to this folder.

## Releasing

1. Determine the next release version, following semver (could automate in the future from changelog)
1. Push a tag to the repo, or create one on the GH UI
1. Watch the automation run on GitHub actions
