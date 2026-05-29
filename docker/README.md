# docker — internal shared base

[`ubuntu-gha-tools`](../ubuntu-gha-tools/README.md) /
[`alpine-gha-tools`](../alpine-gha-tools/README.md) + Docker Engine & Compose. The common parent of the
`-dood` and `-dind` variants, built per OS (`Dockerfile` / `Dockerfile.alpine`).

## What it adds
- Docker Engine + CLI + Compose + `iptables` — on Ubuntu from docker-ce's apt repo (`docker-ce`,
  `docker-ce-cli`, `containerd.io`); on Alpine from `apk` (`docker`, `docker-cli-compose`).
- A `docker` group created at **GitHub's host docker GID** (so the bind-mounted host socket is usable in
  dood mode), with `runner` and `packer` added to it.

## What it implies
- **Not published** — it only ever carries the throwaway `sha-*` build tag and is never promoted. Don't
  pull it directly; use [`-dood`](../dood/README.md) or [`-dind`](../dind/README.md) (`ubuntu-*` /
  `alpine-*`).
- Ships **no `daemon.json`**: in dood mode the local daemon is unused (host socket), and dind writes its
  own daemon config.
