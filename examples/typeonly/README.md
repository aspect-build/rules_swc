Can also be reproduced using the swc-binary. Not (yet) reproduced using @swc/cli

```
> ./swc-darwin-x64 compile --source-file-name c.d.ts --config-file swcrc.json --source-maps true --out-file c.js c.d.ts
thread 'main' panicked at 'index out of bounds: the len is 0 but the index is 0', /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/sourcemap-6.2.3/src/types.rs:655:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

```
> ./swc-darwin-x64 compile --source-file-name b.ts --config-file swcrc.json --source-maps true --out-file b.js b.ts 
thread 'main' panicked at 'index out of bounds: the len is 0 but the index is 0', /Users/runner/.cargo/registry/src/index.crates.io-6f17d22bba15001f/sourcemap-6.2.3/src/types.rs:655:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```
