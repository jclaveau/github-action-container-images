# pnpm layer — `ubuntu-{dood,dind}-pnpm`

Adds [pnpm](https://pnpm.io) on top of the [node](../node/README.md) layer.

## What it adds
- **pnpm** (pinned by the `PNPM_VERSION` build-arg), with `PNPM_HOME` on `PATH`.

## What it implies
- Built for **both modes**: `ubuntu-dood-pnpm` and `ubuntu-dind-pnpm`.
- Inherits Node + the node-gyp toolchain from the node layer.
- The version-pinned tag carries the pnpm minor (`…-pnpmX.Y`).
