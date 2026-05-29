# Github Actions Container Images

[![Test and Publish](https://github.com/jclaveau/github-action-container-images/actions/workflows/test-and-publish.yml/badge.svg)](https://github.com/jclaveau/github-action-container-images/actions/workflows/test-and-publish.yml)

Prebuilt container images for GitHub Actions that **speed up CI** by shipping common dependencies
preinstalled, while mimicking the default `ubuntu-latest` environment (so `docker compose` and friends
just work). Use one as a job [`container:`](https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/run-jobs-in-a-container).

## Goals
- [ ] Prepare images with installed dependencies to speed up CI
- [ ] Provide an environment similar to the default `ubuntu-latest` (allowing `docker compose`)

## The big picture

Images are layered — each builds on the previous — and every layer above the base ships in two
**flavors**, `-dood` and `-dind`:

```
ubuntu-gha-tools            GitHub ubuntu-latest mimic (users, env, OS tools)
  └─ docker  (internal)     + Docker Engine & Compose
       ├─ dood              shares the host daemon (mounted socket)
       └─ dind              boots its own inner daemon
            then:  node  →  pnpm  →  playwright      (each in both -dood and -dind)
```

Variant images are named `<os>-<mode>[-<layer>]` (`os` ∈ {`ubuntu`}, `mode` ∈ {`dood`,`dind`}). Each
layer is documented on its own:

| Image | What it adds | Docs |
| --- | --- | --- |
| `ubuntu-gha-tools` | GitHub `ubuntu-latest` mimic (users, env, OS tools) | [README](ubuntu-gha-tools/README.md) |
| `ubuntu-dood` / `ubuntu-dind` | + Docker Engine & Compose (the two flavors) | [dood](dood/README.md) · [dind](dind/README.md) |
| `…-node` | + Node, npm, node-gyp build tools | [README](node/README.md) |
| `…-pnpm` | + pnpm | [README](pnpm/README.md) |
| `…-playwright` | + Playwright | [README](playwright/README.md) |

(The `docker` layer is an internal, unpublished base — see [docker/README.md](docker/README.md).)

Each push to `main` runs the full test suite and, **only if every test passes**, publishes `latest`
plus a **version-pinned** tag capturing the OS + tool minors, e.g.
`ubuntu-dood-playwright:ubuntu24.04-node22.12-pnpm9.15-pw1.50`.

## The two flavors

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

See [dood/README.md](dood/README.md) and [dind/README.md](dind/README.md) for the runtime details and
`docker compose` usage examples.

## Todo
- Check [the issues](https://github.com/jclaveau/github-action-container-images/issues)

## License

MIT
