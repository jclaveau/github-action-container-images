# syntax=docker/dockerfile:1
ARG BASE_IMAGE=jclaveau/ubuntu-dood:latest
FROM ${BASE_IMAGE}

# Renovate will update these
ARG NODE_VERSION=22.12.0
ARG PNPM_VERSION=9.15.3


# LABEL maintainer="your-email@example.com"
# LABEL org.opencontainers.image.source="https://github.com/jclaveau/docker-images"
LABEL org.opencontainers.image.description="Node, pnpm and node-gyp build tools in Ubuntu based DinD as Github Actions Container"


# https://github.com/pnpm/pnpm/issues/4495#issuecomment-1317831712
ENV PNPM_HOME="/home/runner/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"


RUN echo "Install PNPM https://pnpm.io/installation#in-a-docker-container" \
    && wget -qO- https://get.pnpm.io/install.sh | PNPM_VERSION=${PNPM_VERSION} ENV="$HOME/.bashrc" SHELL="$(which bash)" bash - \
    \
    \
    && echo "Install Node.js (NodeSource) and node-gyp toolchain (python3, make, g++)" \
    && sudo curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION%%.*}.x | sudo bash - \
    && sudo apt-get install -y nodejs \
    && sudo apt-get install -y --no-install-recommends python3 make g++ \
    && sudo rm -rf /var/lib/apt/lists/*
