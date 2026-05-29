# `{ubuntu,alpine}-dind` — true Docker-in-Docker

The [`docker`](../docker/README.md) base plus an **inner `dockerd`** that boots on its own socket
`/var/run/dind.sock`, giving the container an isolated daemon. See the
[`-dood` vs `-dind`](../README.md#the-two-flavors) comparison.

Ships in both OS flavors (`ubuntu-dind`, `alpine-dind`) with identical behavior — the examples below use
`ubuntu-dind`; swap the prefix for the Alpine build.

## What it adds
- [`start-dockerd`](./start-dockerd.sh) — launches the inner daemon and points clients at it.
- `fuse-overlayfs` (fast nested copy-on-write) and a log-only `daemon.json`. The `ENTRYPOINT` boots the
  daemon automatically under `docker run` / `act`.

## What it implies
- **Runtime**: `--privileged`. In GHA the image `ENTRYPOINT` is overridden, so run `start-dockerd` as the
  **first step** (the daemon then persists across the job's steps).
- Set **`DOCKER_HOST=unix:///var/run/dind.sock` via the container `--env`** — *not* `$GITHUB_ENV`, which
  would leak it to GHA's host-side post-job cleanup and fail the job.
- Pick a nested-friendly **storage driver** with `DOCKER_STORAGE_DRIVER`: `fuse-overlayfs` is fast and
  works on GitHub-hosted runners; `vfs` is the always-works fallback. overlay2 is unstable nested.
- **Bind mounts** resolve in the **container's** namespace → `$PWD` / `/__w/…` just work. **Published
  ports** land on the job container's `localhost`. State is fully **isolated** (no cross-job clashes).
- Heavier (~seconds to boot); the image cache is cold per job unless explicitly cached.

## Usage — Postgres via `docker compose`

Boots its own daemon first; published ports land on the job container, reached via `localhost`:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: jclaveau/ubuntu-dind:latest
      # DOCKER_HOST via --env (not $GITHUB_ENV) so it never leaks to GHA's host-side cleanup
      options: --privileged --env DOCKER_HOST=unix:///var/run/dind.sock
    env:
      DOCKER_STORAGE_DRIVER: fuse-overlayfs   # fast nested CoW; use vfs if your runner lacks /dev/fuse
    steps:
      - run: start-dockerd            # boots the inner daemon (persists across the steps below)
      - uses: actions/checkout@v4
      - run: docker compose -f docker-compose-tests.yaml up -d --wait
      - run: nc -zv localhost 5432
```
