# alpine-gha-tools

Alpine 3.21 set up to mirror [`ubuntu-gha-tools`](../ubuntu-gha-tools/README.md) as closely as
musl/Alpine allows — the lightweight foundation for the `alpine-*` flavor of every other image here.

## What it adds
- **Accounts** matching the hosted runner: `runner` (uid 1001) and `packer` (uid 1000), both with
  passwordless `sudo` (via the `shadow` + `sudo` packages, so the user setup is identical to Ubuntu's).
- **Environment**: `LANG=C.UTF-8`, `CI=true`, `ImageOS=alpine3.21`,
  `RUNNER_TOOL_CACHE=/opt/hostedtoolcache` (+ `AGENT_TOOLSDIRECTORY`), and the `/opt/hostedtoolcache` dir.
- **OS-level tools** — the Alpine (`apk`) equivalents of the ubuntu-gha-tools curated set: build-base,
  pkgconf, git, curl, wget, gnupg, jq, zip/unzip, xz/bzip2/zstd/lz4, p7zip, rsync, openssh-client,
  bind-tools, shellcheck, python3, … (see the `Dockerfile` for the full list).
- **Bash sugar** — `bash` + `coreutils` + the same interactive aliases as Ubuntu's default shell
  (`ll`/`la`/`l`, colored `ls`/`grep`), installed via `/etc/skel` so `runner` gets them on `docker run`
  / `act`. CI asserts these are identical to ubuntu-gha-tools.

## What it implies
- **No Docker and no language runtimes** — those are added by the [`docker`](../docker/README.md) overlay
  and the [`node`](../node/README.md) / [`pnpm`](../pnpm/README.md) / [`playwright`](../playwright/README.md)
  layers, so each stays independently versioned.
- **musl, not glibc.** A handful of apt-only packages (`lsb-release`, `software-properties-common`,
  `locales`, `time`) have no Alpine counterpart and are dropped; some downstream layers diverge more
  (notably Playwright, which on Alpine is Chromium-only via the system package).
- In **GitHub Actions container jobs the steps run as root** (uid 0), ignoring the image's `USER runner`.
  The baked accounts/env/aliases matter for `docker run` / `act`, not inside a GHA job.
- Published; tagged `latest` and a version-pinned `alpineXX.YY` (e.g. `alpine3.21`) on each push to main.
