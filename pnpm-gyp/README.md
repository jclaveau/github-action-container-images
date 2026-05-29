# pnpm-gyp layer — `{ubuntu,alpine}-{dood,dind}-pnpm-gyp`

pnpm **plus the node-gyp build toolchain** — the opt-in counterpart to the slim `…-pnpm` images. Built
as a **sibling** of `…-pnpm` (both `FROM` the [node](../node/README.md) layer), so the slim and `-gyp`
chains build in parallel.

## Why it exists
The base [`gha-tools`](../ubuntu-gha-tools/README.md) deliberately drops the C/C++ compiler to keep
every image slim (see its README). Most CI never compiles native code, but some `npm`/`pnpm install`
runs build native addons via **node-gyp** — those use this variant.

## What it adds
- **Ubuntu**: `build-essential` (gcc/g++/make) via `apt`.
- **Alpine**: `build-base` via `apk`.

`python3` (node-gyp's other prerequisite) already comes from the base, so with the compiler back,
`node-gyp` works exactly as it does on GitHub's `ubuntu-latest`.

## What it implies
- Built for **both modes and both OSes**: `ubuntu-dood-pnpm-gyp`, `alpine-dind-pnpm-gyp`, etc.
- It is `…-pnpm` + one toolchain layer, so it shares all of pnpm's layers in the registry.
- The version-pinned tag carries a `-gyp` suffix: `…-pnpmX.Y-gyp`.
- For Playwright **and** native builds in one image, use [`…-playwright-gyp`](../playwright/README.md)
  (the same Playwright layer built on this base).
