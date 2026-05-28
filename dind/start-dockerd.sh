#!/usr/bin/env bash
# Boot the inner Docker daemon (true DinD).
#   GHA container job:  - run: start-dockerd      (backgrounds daemon, returns)
#   docker run / act:   ENTRYPOINT runs it, then execs CMD (sleep infinity)
set -euo pipefail

# Empty => dockerd auto-selects (overlay2 where supported).
# Override for portability (act on btrfs/zfs/rootless): DOCKER_STORAGE_DRIVER=vfs|overlay2|fuse-overlayfs
driver=""
[ -n "${DOCKER_STORAGE_DRIVER:-}" ] && driver="--storage-driver=${DOCKER_STORAGE_DRIVER}"

# GHA bind-mounts the HOST socket at /var/run/docker.sock into every container job, so the
# inner daemon listens on its own socket and we point clients at it via DOCKER_HOST.
SOCK="${DIND_SOCK:-/var/run/dind.sock}"

# setsid detaches the daemon so it survives the GHA step shell that launched it.
# sudo lets this work whether invoked as runner (ENTRYPOINT) or root (GHA step).
# Log to /tmp: the redirect is opened by the (non-root) caller, then inherited by sudo dockerd.
setsid bash -c "exec sudo dockerd ${driver} --host=unix://${SOCK} </dev/null >/tmp/dockerd.log 2>&1" &
disown 2>/dev/null || true
export DOCKER_HOST="unix://${SOCK}"

timeout 60 bash -c 'until docker info >/dev/null 2>&1; do sleep 1; done' || {
  echo "dockerd failed to start"
  tail -n 50 /tmp/dockerd.log || true
  exit 1
}

sudo chown root:docker "${SOCK}"
sudo chmod 660 "${SOCK}"

# NB: we deliberately do NOT write DOCKER_HOST to $GITHUB_ENV. The daemon does not survive
# across GHA container-job steps, so a persisted DOCKER_HOST would leak a dead socket into the
# job's post-cleanup (`docker exec ...`) and fail the job. Callers that need it across commands
# must `export DOCKER_HOST=unix://${SOCK}` themselves and use it within the same step.

# ENTRYPOINT mode execs the CMD; GHA step mode (no args) returns cleanly.
# NB: must be an `if`, not `[ ... ] && exec` — the latter's failed test would be the
# script's last command and make a no-args invocation exit 1 (fails the GHA step).
if [ "$#" -gt 0 ]; then
  exec "$@"
fi
