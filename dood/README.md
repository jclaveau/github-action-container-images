# `{ubuntu,alpine}-dood` — Docker-outside-of-Docker

The [`docker`](../docker/README.md) base used with a **shared host daemon**: the `docker` CLI talks to
the host's `/var/run/docker.sock`. GitHub Actions bind-mounts that socket into every container job; with
`docker run` you mount it yourself. See the [`-dood` vs `-dind`](../README.md#the-two-flavors) comparison.

Ships in both OS flavors (`ubuntu-dood`, `alpine-dood`) with identical behavior — the examples below use
`ubuntu-dood`; swap the prefix for the Alpine build.

## What it implies
- **Runtime**: mount the host socket (`-v /var/run/docker.sock:/var/run/docker.sock`); on GHA it's already
  present. Lighter and instant (no daemon to boot).
- **Bind mounts** resolve in the **host** filesystem — container paths like `/__w/<repo>/…` don't exist
  on the host (you get an empty dir / "No such file"), so they need host-path rewriting.
- **Published ports** land on the **host**; reach them via `host.docker.internal`; they can **clash**
  with the host or with other jobs sharing the daemon.
- **Container names / state** are siblings on the shared daemon → cross-job name/state collisions.
- Reuses the host's **layer cache** (fast pulls). Socket access ≈ **root on the host**.
- With **`act`** (local): uses your local Docker, so test containers mix with your own (possible
  name/port clashes).

## Usage — Postgres via `docker compose`

Uses the host daemon (GHA bind-mounts its socket); published ports land on the host, reached via
`host.docker.internal`:

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    container:
      image: jclaveau/ubuntu-dood:latest
      options: --privileged --add-host=host.docker.internal:host-gateway
    steps:
      - uses: actions/checkout@v4
      - run: docker compose -f docker-compose-tests.yaml up -d --wait
      - run: nc -zv host.docker.internal 5432
```
