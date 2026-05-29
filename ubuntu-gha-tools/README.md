# ubuntu-gha-tools

Ubuntu 24.04 set up to mimic GitHub's `ubuntu-latest` runner environment — the shared foundation every
other image in this repo builds on.

## What it adds
- **Accounts** matching the hosted runner: `runner` (uid 1001) and `packer` (uid 1000), both with
  passwordless `sudo`.
- **Environment**: `LANG=C.UTF-8`, `CI=true`, `ImageOS=ubuntu24`,
  `RUNNER_TOOL_CACHE=/opt/hostedtoolcache` (+ `AGENT_TOOLSDIRECTORY`), and the `/opt/hostedtoolcache` dir.
- **OS-level tools** — a curated subset of [`actions/runner-images`](https://github.com/actions/runner-images/blob/main/images/ubuntu/Ubuntu2404-Readme.md):
  build-essential, pkg-config, git, curl, wget, gnupg, jq, zip/unzip, xz/bzip2/zstd/lz4, p7zip, rsync,
  openssh-client, dnsutils, shellcheck, python3, … (see the `Dockerfile` for the full list).

## What it implies
- **No Docker and no language runtimes** — those are added by the [`docker`](../docker/README.md) overlay
  and the [`node`](../node/README.md) / [`pnpm`](../pnpm/README.md) / [`playwright`](../playwright/README.md)
  layers, so each stays independently versioned.
- In **GitHub Actions container jobs the steps run as root** (uid 0), ignoring the image's `USER runner`,
  and GitHub injects its own `RUNNER_TOOL_CACHE`/`ImageOS`. The baked accounts/env matter for
  `docker run` / `act`, not inside a GHA job.
- Published; tagged `latest` and a version-pinned `ubuntuXX.YY` (e.g. `ubuntu24.04`) on each push to main.
