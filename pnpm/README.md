# pnpm layer — `{ubuntu,alpine}-{dood,dind}-pnpm`

Adds [pnpm](https://pnpm.io) on top of the [node](../node/README.md) layer.

## What it adds
- **pnpm** (pinned by the `PNPM_VERSION` build-arg), with `PNPM_HOME` on `PATH`.

## What it implies
- Built for **both modes and both OSes**: `ubuntu-dood-pnpm`, `alpine-dind-pnpm`, etc. — the same
  Dockerfile serves both (get.pnpm.io ships a musl-static binary that runs on Alpine).
- Inherits Node from the node layer; **slim — no compiler**. For native-addon builds use the sibling
  [`-gyp` variant](../pnpm-gyp/README.md) (`{os}-{mode}-pnpm-gyp`), which is this layer + the node-gyp
  toolchain.
- The version-pinned tag carries the pnpm minor (`…-pnpmX.Y`); the `-gyp` variant adds a `-gyp` suffix
  (`…-pnpmX.Y-gyp`).
