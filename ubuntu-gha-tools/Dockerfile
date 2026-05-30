# syntax=docker/dockerfile:1
# Canonical's official Ubuntu from AWS ECR Public (NOT Docker Hub) to avoid Docker Hub's pull rate
# limit in CI: the rest of the pipeline builds/pulls via GHCR, so CI does zero Docker Hub pulls.
FROM public.ecr.aws/ubuntu/ubuntu:24.04

# Mimics GitHub's ubuntu-latest VM environment (accounts, env, OS-level tooling) per issue #5.
# Deliberately NO docker and NO language runtimes — those live in the docker/ overlay and the
# node|pnpm|playwright layers, so they stay independently versioned.
LABEL org.opencontainers.image.description="Ubuntu 24.04 mimicking GitHub Actions ubuntu-latest (users, env, OS tools; no docker, no runtimes)"

ENV DEBIAN_FRONTEND=noninteractive

# Static, tool-present env vars from the runner-images spec (issue #5). Heavy-SDK env
# (CONDA / ANDROID_* / JAVA_HOME_* / vcpkg / *WEBDRIVER) is intentionally omitted — those tools
# aren't installed, so advertising the paths would be misleading.
ENV LANG=C.UTF-8 \
    CI=true \
    ImageOS=ubuntu24 \
    RUNNER_TOOL_CACHE=/opt/hostedtoolcache \
    AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

# Deliberately NOT installed (unlike actions/runner-images ubuntu-24.04 — see README):
#  - the C/C++ toolchain (build-essential): ~106 MB compressed dead weight in this shared base since
#    most jobs never compile. Native-addon builds use the `-gyp` variant (e.g. {os}-{mode}-pnpm-gyp).
#  - shellcheck: ~14 MB dev-only shell linter nothing invokes at runtime; `apt install shellcheck` it.
RUN echo "OS-level tools: a curated subset of actions/runner-images ubuntu-24.04 (no runtimes/SDKs)" \
    && apt-get update && apt-get install -y --no-install-recommends \
       apt-utils \
       pkg-config \
       git \
       curl \
       wget \
       ca-certificates \
       gnupg \
       lsb-release \
       software-properties-common \
       locales \
       jq \
       zip \
       unzip \
       xz-utils \
       bzip2 \
       zstd \
       lz4 \
       p7zip-full \
       file \
       tree \
       rsync \
       openssh-client \
       dnsutils \
       net-tools \
       iputils-ping \
       netcat-openbsd \
       parallel \
       brotli \
       time \
       sudo \
       python3 \
       python-is-python3 \
    && rm -rf /var/lib/apt/lists/* \
    \
    && echo "Set the same users as GitHub's ubuntu-latest" \
    && (userdel -r $(getent passwd 1000 | cut -d: -f1) 2>/dev/null || true) \
    && (userdel -r $(getent passwd 1001 | cut -d: -f1) 2>/dev/null || true) \
    && (userdel -r packer 2>/dev/null || true) \
    && (userdel -r runner 2>/dev/null || true) \
    && useradd -m -s /bin/bash -u 1000 -c "Ubuntu" packer \
    && echo "packer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/packer \
    && chmod 0440 /etc/sudoers.d/packer \
    && useradd -m -s /bin/bash -u 1001 -c ",,," runner \
    && echo "%runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/runner \
    && chmod 0440 /etc/sudoers.d/runner \
    && chmod 0775 /home/runner \
    && usermod -aG adm,users,systemd-journal runner \
    \
    && echo "Tool cache dir, as on the hosted runner (RUNNER_TOOL_CACHE)" \
    && mkdir -p /opt/hostedtoolcache \
    && chown -R 1001:1001 /opt/hostedtoolcache \
    && chmod 2775 /opt/hostedtoolcache

USER runner

# Github overrides workdir and entrypoint during `docker create`; this CMD is the only way to set PWD.
CMD ["cd", "$PWD"]
