# Bazel rules for swc

SWC (<https://swc.rs/>) is a fast JavaScript compiler, written in Rust.
It performs the same work as Babel among other things, but is 20x faster.

Many companies are successfully building with rules_swc. If you're getting value from the project, please let us know! Just comment on our [Adoption Discussion](https://github.com/aspect-build/rules_js/discussions/1000).

SWC is a natural fit with Bazel.
Bazel does best when it orchestrates the work of many short-lived compiler processes.
NodeJS is not a good runtime for such tools, because it is an interpreter, and is only fast after the code has been running for a while and is Just-In-Time optimized.
SWC is fast from the beginning since it is compiled to optimized machine code.
This makes it a better choice for most developer workflows than tools like `tsc` or `babel`.

At the same, Bazel is a good fit for SWC too. Instead of waiting for swc plugins,
can already use whatever tools you like, for example you could choose any bundler, such as esbuild.
Bazel's agnostic unix-pipeline-style composition of tools allows you to mix-and-match the best parts of
the JS ecosystem, regardless what language they run on.
With Bazel, you won't need to figure out SWC's plugin infrastructure.
You can have SWC do what it's good at, and not even have it involved with the rest.

_Need help?_ This ruleset has support provided by https://aspect.dev.

## Features

These rules provide a hermetic toolchain that runs the SWC cli, so it doesn't matter what is
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

Follow instructions from the release you wish to use:
<https://github.com/aspect-build/rules_swc/releases>.

## Usage

### From a BUILD file

The simplest usage is with the [swc rule](/docs/swc.md), used to compile TypeScript code to JavaScript in a tight developer loop. Each `.ts` or `.tsx` file is compiled to `bazel-bin/[.../file].js` and available to downstream
tools such as bundlers, which are in their own Bazel rules.

See the example in /examples/simple.

### In a macro

Often the repetition of hand-writing BUILD files needs to be overcome with a Bazel macro.
This composes a few rules together into a common pattern which is shared in your repo.

See the example in /examples/macro.

### In a custom rule

The most advanced usage is to write your own rule that uses the swc toolchain.

This is a good choice if you need to integrate with other Bazel rules via
[Providers](https://docs.bazel.build/versions/main/skylark/rules.html#providers)

You'll basically follow the example of /swc/private/swc.bzl in this repo, by using
the `ctx.actions.run` Starlark API.

- Use `ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.swc_binary` to locate the binary tool to execute
- To pass the relevant files to the action, `inputs` should include
  `ctx.toolchains["@aspect_rules_swc//swc:toolchain_type"].swcinfo.tool_files`

You can load helper functions from the private API like our implementation does,
but note that this may have breaking changes between major releases.

Alternatively you can write a rule from scratch, using the toolchains and
SWC cli provided in aspect_rules_swc.
