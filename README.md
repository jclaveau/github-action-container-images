# WIP: Github Actions Container Images

[![Build and Push Docker Images](https://github.com/jclaveau/github-action-container-images/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/jclaveau/github-action-container-images/actions/workflows/docker-publish.yml)

## Goals
- [ ] Prepare images with installed dependencies to speedup CI
- [ ] Provide an environment similar to the default context `ubuntu-latest` (allowing using `docker compose`)

### Implemented

Each image comes in two flavors:

- **`-dood`** (Docker-outside-of-Docker): the `docker` CLI talks to a shared **host** daemon. Mount the host socket (`-v /var/run/docker.sock:/var/run/docker.sock`). Lighter, but bind mounts from inside resolve against the *host* filesystem.
- **`-dind`** (true Docker-in-Docker): boots its own inner `dockerd` on a dedicated socket (`/var/run/dind.sock`), so bind mounts resolve in the container's own namespace. Needs `--privileged`. In GitHub Actions container jobs the image `ENTRYPOINT` is overridden (and the host socket is bind-mounted), so start the daemon as the first step and point clients at it via the container `--env`:
  ```yaml
  container:
    image: jclaveau/ubuntu-dind:latest
    options: --privileged --env DOCKER_HOST=unix:///var/run/dind.sock
  steps:
    - run: start-dockerd   # boots the inner daemon; it persists across the job's steps
  ```
  Set `DOCKER_HOST` via the container `--env` (not `$GITHUB_ENV` — that would leak to GHA's host-side post-job cleanup and fail it). For `docker run` / `act` the `ENTRYPOINT` boots it automatically. Pick a nested-friendly storage driver with `DOCKER_STORAGE_DRIVER` (`fuse-overlayfs` is fast and works on GitHub-hosted runners; `vfs` is the always-works fallback) — overlay2 is unstable nested.

The variant images are named `<os>-<mode>[-<layer>]` (`os` ∈ {`ubuntu`}, `mode` ∈ {`dood`,`dind`}); they
build on a shared, published `ubuntu-gha-tools` foundation (and an internal, unpublished `ubuntu-docker`):

| Image | Contents |
| --- | --- |
| `ubuntu-gha-tools` | [Ubuntu 24.04](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md) mimicking GitHub's `ubuntu-latest` (users, env, OS-level tools; **no docker, no runtimes**) |
| `ubuntu-dood`, `ubuntu-dind` | + Docker Engine & Compose ([DinD](https://www.docker.com/resources/docker-in-docker-containerized-ci-workflows-dockercon-2023/) tooling); `dood` shares the host daemon, `dind` boots its own |
| `ubuntu-dood-node`, `ubuntu-dind-node` | + Node, npm and node-gyp build tools (python3, make, g++) |
| `ubuntu-dood-pnpm`, `ubuntu-dind-pnpm` | + pnpm |
| `ubuntu-dood-playwright`, `ubuntu-dind-playwright` | + Playwright |

Besides `latest`, each push to `main` also publishes a **version-pinned** tag (OS + the minor of each tool it carries), e.g. `ubuntu-dood-node:ubuntu24.04-node22.12`, `ubuntu-dood-pnpm:ubuntu24.04-node22.12-pnpm9.15`, `ubuntu-dood-playwright:ubuntu24.04-node22.12-pnpm9.15-pw1.50`.

#### `-dood` vs `-dind`

| Aspect | `-dood` (Docker-outside-of-Docker) | `-dind` (true Docker-in-Docker) |
| --- | --- | --- |
| **Usage** | | |
| Docker daemon | Shared **host** daemon | Own inner `dockerd` started per job |
| Socket | Host `/var/run/docker.sock` (GHA bind-mounts it; with `docker run` mount it yourself) | `/var/run/dind.sock` (separate, to avoid the mounted host socket) |
| Required runtime flag | host-socket mount (`-v /var/run/docker.sock:/var/run/docker.sock`) | `--privileged` |
| GHA first step | none — daemon already present | `- run: start-dockerd` (ENTRYPOINT is overridden in container jobs) |
| Client config | default socket | `DOCKER_HOST=unix:///var/run/dind.sock` (set via the container `--env`) |
| Storage driver | the host's | `DOCKER_STORAGE_DRIVER=fuse-overlayfs` (or `vfs` fallback); overlay2 is unstable nested |
| Startup / weight | instant, lighter | ~seconds to boot the daemon, heavier |
| **Effects** | | |
| PWD / bind mounts | sources resolve in the **host** namespace → container paths like `/__w/<repo>/…` don't exist on the host (empty dir / "No such file"); needs host-path rewriting | resolve in the **container's** namespace → `$PWD` / `/__w/…` paths just work |
| Published ports | land on the **host**; reach via `host.docker.internal`; can **conflict** with the host or other jobs sharing the daemon | land on the job container's `localhost`; isolated, no host port conflicts |
| Container names / state | siblings on the shared host daemon → **name/state clashes** and concurrent-job collisions | isolated daemon → no cross-job name/state collisions |
| Image cache | reuses the host's layer cache (fast pulls) | cold per job unless explicitly cached |
| Isolation / security | socket access ≈ control of the host daemon (root-equivalent on the host) | `--privileged` (kernel-level power), but fully isolated state |
| With `act` (local) | uses your local Docker → test containers mix with your own; possible name/port clashes; Docker-Desktop/rootless path quirks | self-contained; if overlay2 nesting fails on your backend set `DOCKER_STORAGE_DRIVER=vfs`; no clashes with your local containers |

#### Example: Postgres via `docker compose` in a job

**`ubuntu-dood`** — uses the host daemon (GHA bind-mounts its socket); published ports land on the host, reached via `host.docker.internal`:

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

**`ubuntu-dind`** — boots its own daemon first; published ports land on the job container, reached via `localhost`:

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

### Todo
- Check [the issues](https://github.com/jclaveau/github-action-container-images/issues)

## License

MIT