# Bazel rules for swc

SWC (<https://swc.rs/>) is a fast JS compiler, written in Rust.
It performs the same work as Babel among other things, but is 20x faster.

SWC is a natural fit with Bazel.
Bazel does best when it orchestrates the work of many short-lived compiler processes.
NodeJS is not a good runtime for such tools, because it is an interpreter, and is only fast after the code has been running for a while and is Just-In-Time optimized.
SWC is fast from the beginning since it is compiled to optimized machine code.
This makes it a better choice for most developer workflows than tools like `tsc` or `babel`.

At the same, Bazel is a good fit for SWC too. It has still-developing features like a bundler,
but you might want to use something else as a bundler, like esbuild.
Bazel's agnostic unix-pipeline-style composition of tools allows you to mix-and-match the best parts of
the JS ecosystem, regardless what language they run on.
With Bazel, you won't need to figure out SWC's plugin infrastructure.
You can have SWC do what it's good at, and not even have it involved with the rest.

## Features

These rules provide a hermetic toolchain that runs `@swc/cli`, so it doesn't matter what is
already installed on a developer's machine, they're guaranteed to get the same result.
It caches all the tools using Bazel's downloader.
This means that even when Bazel determines that a repository is invalidated and re-runs the setup
(due to running `bazel sync --configure` for example, or after a `bazel clean --expunge`)
nothing is fetched from the network. Also the downloader can be configured to use corporate policy
like fetching exclusively through Artifactory.

We use a [Bazel toolchain](https://docs.bazel.build/versions/main/toolchains.html) to expose
the SWC compiler to the Bazel actions that run it.
This allows a user to register their own toolchain, for example to build SWC Rust code from source.
By default, we download pre-built binaries from https://github.com/swc-project/swc/releases.
This means we do not run `npm install` or `yarn`.

## Installation

Runfiles need to be enabled in Bazel for the rules to work. On Windows, this is not enabled by default.

Add this to the `.bazelrc` in your project:

```
build --enable_runfiles
```

Next, include this in your WORKSPACE file:

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# See the rules_swc releases page for an up-to-date snippet.
_RULES_SWC_VERSION="391c3748d48e964b9987e614028db9cb9cd35868"
http_archive(
    name = "aspect_rules_swc",
    url = "https://github.com/aspect-build/rules_swc/archive/%s.zip" % _RULES_SWC_VERSION,
    strip_prefix = "rules_swc-" + _RULES_SWC_VERSION,
    sha256 = "174494327d7e715a8d95755c89afa71dd671d9f2d8296f96c772151a02036919",
)

# Fetches the rules_swc dependencies.
# If you want to have a different version of some dependency,
# you should fetch it *before* calling this.
# Alternatively, you can skip calling this function, so long as you've
# already fetched all the dependencies.
load("@aspect_rules_swc//swc:dependencies.bzl", "rules_swc_dependencies")
rules_swc_dependencies()

# Fetches a pre-built Rust-node binding from
# https://github.com/swc-project/swc/releases.
# If you'd rather compile it from source, you can use rules_rust, fetch the project,
# then register the toolchain yourself. (Note, this is not yet documented)
load("@aspect_rules_swc//swc:repositories.bzl", "swc_register_toolchains")
swc_register_toolchains(
    name = "swc",
    swc_version = "v1.2.118",
)

# Fetches a NodeJS interpreter, needed to run the swc CLI.
# You can skip this if you already register a nodejs toolchain.
load("@rules_nodejs//nodejs:repositories.bzl", "nodejs_register_toolchains")
nodejs_register_toolchains(
    name = "node16",
    node_version = "16.9.0",
)

# Fetches the npm packages needed to run @swc/cli
load("@swc_cli//:repositories.bzl", _swc_cli_deps = "npm_repositories")
_swc_cli_deps()
```

> note, in the above, replace the version and sha256 with the one indicated
> in the release notes for rules_swc
> In the future, our release automation should take care of this.

## Usage

### From a BUILD file

The simplest usage is with the [swc rule](/docs/swc.md), used to transpile TypeScript code to JavaScript in a tight developer loop. Each `.ts` or `.tsx` file is compiled to `bazel-bin/path/to/file.js` and available to downstream
tools such as bundlers, which are in their own Bazel rules.

See the example in /examples/simple.

### In a macro

Often the repetition of hand-writing BUILD files needs to be overcome with a Bazel macro.
This composes a few rules together into a common pattern which is shared in your repo.

See the example in /examples/macro

### In a custom rule

The most advanced usage is to write your own rule that uses the swc toolchain.

This is a good choice if you need to integrate with other Bazel rules via
[Providers](https://docs.bazel.build/versions/main/skylark/rules.html#providers)

You'll basically follow the example of /swc/swc.bzl in this repo, by using
the `ctx.actions.run` Starlark API.

- Use `@aspect_rules_swc//swc:cli` as the binary tool to execute
- To get the swc nodejs bindings for Rust, `env` should include
  `"SWC_BINDING": ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.binding`
- To pass the relevant files to the action, `inputs` should include
  `ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.tool_files`

You can load helper functions from the private API like our implementation does,
but note that this may have breaking changes between major releases.

Alternatively you can write a rule from scratch, using the toolchains and
swc cli binary provided in aspect_rules_swc.
