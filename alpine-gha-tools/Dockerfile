# syntax=docker/dockerfile:1
# Alpine official image mirrored on AWS ECR Public (NOT Docker Hub) to avoid Docker Hub's pull rate
# limit in CI: the rest of the pipeline builds/pulls via GHCR, so CI does zero Docker Hub pulls.
FROM public.ecr.aws/docker/library/alpine:3.21

# Alpine/musl counterpart of ubuntu-gha-tools: the same accounts, env, curated OS tooling and the
# interactive bash sugar (ll/la/l) so the developer environment is identical across both flavors.
# Deliberately NO docker and NO language runtimes — those live in the docker/ overlay and the
# node|pnpm|playwright layers, so they stay independently versioned.
LABEL org.opencontainers.image.description="Alpine 3.21 mirroring the ubuntu-gha-tools dev env (users, env, OS tools, bash sugar; no docker, no runtimes)"

ENV LANG=C.UTF-8 \
    CI=true \
    ImageOS=alpine3.21 \
    RUNNER_TOOL_CACHE=/opt/hostedtoolcache \
    AGENT_TOOLSDIRECTORY=/opt/hostedtoolcache

# `shadow` provides useradd/usermod/userdel so the account setup matches ubuntu-gha-tools verbatim;
# `coreutils` gives GNU ls/etc. so the `ll` family behaves like Ubuntu's (not the busybox applets).
# apt-only packages (apt-utils, lsb-release, software-properties-common, locales) and `time` are
# dropped (N/A on Alpine/musl); python-is-python3 becomes a python->python3 symlink.
# Deliberately NOT installed (mirrors ubuntu-gha-tools — see README): the C/C++ toolchain (build-base,
# ~compressed dead weight; use the `-gyp` variant for native addons) and shellcheck (dev-only linter,
# `apk add shellcheck` it if you lint shell).
RUN echo "OS-level tools: Alpine equivalents of the ubuntu-gha-tools curated set (no runtimes/SDKs)" \
    && apk add --no-cache \
       bash \
       bash-completion \
       coreutils \
       shadow \
       sudo \
       pkgconf \
       git \
       curl \
       wget \
       ca-certificates \
       gnupg \
       jq \
       zip \
       unzip \
       xz \
       bzip2 \
       zstd \
       lz4 \
       p7zip \
       file \
       tree \
       rsync \
       openssh-client \
       bind-tools \
       net-tools \
       iputils \
       netcat-openbsd \
       parallel \
       brotli \
       python3 \
    && ln -sf python3 /usr/bin/python \
    \
    && echo "Interactive bash sugar matching Ubuntu's default skel (.bashrc holds the aliases; .profile" \
    && echo "sources .bashrc for login shells) so ll/la/l work the same in docker run / act" \
    && mkdir -p /etc/skel \
    && printf '%s\n' \
        "alias ls='ls --color=auto'" \
        "alias grep='grep --color=auto'" \
        "alias ll='ls -alF'" \
        "alias la='ls -A'" \
        "alias l='ls -CF'" \
        >> /etc/skel/.bashrc \
    && printf '%s\n' \
        'if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then . "$HOME/.bashrc"; fi' \
        >> /etc/skel/.profile \
    \
    && echo "Set the same users as GitHub's ubuntu-latest (packer 1000, runner 1001) with bash + sudo" \
    && (userdel -r "$(getent passwd 1000 | cut -d: -f1)" 2>/dev/null || true) \
    && (userdel -r "$(getent passwd 1001 | cut -d: -f1)" 2>/dev/null || true) \
    && useradd -m -s /bin/bash -u 1000 -c "Ubuntu" packer \
    && echo "packer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/packer \
    && chmod 0440 /etc/sudoers.d/packer \
    && useradd -m -s /bin/bash -u 1001 -c ",,," runner \
    && echo "%runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/runner \
    && chmod 0440 /etc/sudoers.d/runner \
    && chmod 0775 /home/runner \
    && usermod -aG wheel runner \
    \
    && echo "Tool cache dir, as on the hosted runner (RUNNER_TOOL_CACHE)" \
    && mkdir -p /opt/hostedtoolcache \
    && chown -R 1001:1001 /opt/hostedtoolcache \
    && chmod 2775 /opt/hostedtoolcache

USER runner

# Github overrides workdir and entrypoint during `docker create`; this CMD is the only way to set PWD.
CMD ["cd", "$PWD"]
