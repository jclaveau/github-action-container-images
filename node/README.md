# node layer — `{ubuntu,alpine}-{dood,dind}-node`

Adds Node.js + npm + the node-gyp build toolchain on top of a [`-dood`](../dood/README.md) /
[`-dind`](../dind/README.md) base.

## What it adds
- **Node.js + npm** — on Ubuntu from NodeSource (the major comes from the `NODE_VERSION` build-arg); on
  Alpine from `apk` (`nodejs npm`, the version Alpine ships for that release).
- **node-gyp toolchain**: `python3`, `make`, `g++` — for compiling native addons.

## What it implies
- Built for **both modes and both OSes**: `ubuntu-dood-node`, `alpine-dind-node`, etc.
- The installed Node **minor floats** (NodeSource/apk serve the latest in that line); the version-pinned
  tag (`…-nodeXX.YY`) reflects what's actually installed.
- The toolchain overlaps what [`ubuntu-gha-tools`](../ubuntu-gha-tools/README.md) /
  [`alpine-gha-tools`](../alpine-gha-tools/README.md) already ship (benign).
