# node layer — `{ubuntu,alpine}-{dood,dind}-node`

Adds **Node.js + npm** (slim — no compiler) on top of a [`-dood`](../dood/README.md) /
[`-dind`](../dind/README.md) base.

## What it adds
- **Node.js + npm** — on Ubuntu from NodeSource (the major comes from the `NODE_VERSION` build-arg); on
  Alpine from `apk` (`nodejs npm`, the version Alpine ships for that release).

## What it implies
- Built for **both modes and both OSes**: `ubuntu-dood-node`, `alpine-dind-node`, etc.
- The installed Node **minor floats** (NodeSource/apk serve the latest in that line); the version-pinned
  tag (`…-nodeXX.YY`) reflects what's actually installed.
- **No node-gyp toolchain here.** The base [`gha-tools`](../ubuntu-gha-tools/README.md) no longer ships a
  compiler, so this layer can't build native addons. If your `npm`/`pnpm install` compiles native
  modules, use the [`-gyp` variant](../pnpm-gyp/README.md) (`{os}-{mode}-pnpm-gyp`), which adds
  `build-essential`/`build-base` back.
