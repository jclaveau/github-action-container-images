# syntax=docker/dockerfile:1
ARG BASE_IMAGE=jclaveau/ubuntu-dind:latest
FROM ${BASE_IMAGE}

# Renovate will update these
ARG NODE_VERSION=22.12.0
ARG PLAYWRIGHT_VERSION=1.50.1
ARG PNPM_VERSION=9.15.3


# LABEL maintainer="your-email@example.com"
# LABEL org.opencontainers.image.source="https://github.com/jclaveau/docker-images"
LABEL org.opencontainers.image.description="Playwright in Ubuntu based DinD as Github Actions Container"


# https://github.com/pnpm/pnpm/issues/4495#issuecomment-1317831712
ENV PNPM_HOME="/home/runner/.local/share/pnpm"
ENV PATH="${PATH}:${PNPM_HOME}"

# https://playwright.dev/docs/browsers
ENV PLAYWRIGHT_BROWSERS_PATH='/home/runner/playwright-browsers'


RUN echo "Install PNPM https://pnpm.io/installation#in-a-docker-container" \
    && wget -qO- https://get.pnpm.io/install.sh | PNPM_VERSION=${PNPM_VERSION} ENV="$HOME/.bashrc" SHELL="$(which bash)" bash - \
    \
    \
    && echo "Install Node.js" \
    && sudo curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION%%.*}.x | sudo bash - \
    && sudo apt-get install -y nodejs \
    && sudo rm -rf /var/lib/apt/lists/* \
    \
    \
    && echo "Install Playwright globally https://playwright.dev/docs/docker#build-your-own-image" \
    && pnpm install -g playwright@${PLAYWRIGHT_VERSION} \
    && playwright install --with-deps --only-shell

# TODO
# - RUN pnpm env --global 22 https://pnpm.io/cli/env available with v10?
# - use asdf with ni ?



