# docker — internal shared base

[`ubuntu-gha-tools`](../ubuntu-gha-tools/README.md) + Docker Engine & Compose. The common parent of the
`-dood` and `-dind` variants.

## What it adds
- `docker-ce`, `docker-ce-cli`, `containerd.io`, `iptables`, and `docker compose`.
- A `docker` group created at **GitHub's host docker GID** (so the bind-mounted host socket is usable in
  dood mode), with `runner` and `packer` added to it.

## What it implies
- **Not published** — it only ever carries the throwaway `sha-*` build tag and is never promoted. Don't
  pull it directly; use [`ubuntu-dood`](../dood/README.md) or [`ubuntu-dind`](../dind/README.md).
- Ships **no `daemon.json`**: in dood mode the local daemon is unused (host socket), and dind writes its
  own daemon config.
