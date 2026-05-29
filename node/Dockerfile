# syntax=docker/dockerfile:1
ARG BASE_IMAGE=jclaveau/ubuntu-dood:latest
FROM ${BASE_IMAGE}

# Renovate will update this
ARG NODE_VERSION=22.12.0


LABEL org.opencontainers.image.description="Node + npm + node-gyp build tools (python3, make, g++) in Ubuntu based DinD as Github Actions Container"


RUN echo "Install Node.js (NodeSource) and node-gyp toolchain (python3, make, g++)" \
    && sudo curl -fsSL https://deb.nodesource.com/setup_${NODE_VERSION%%.*}.x | sudo bash - \
    && sudo apt-get install -y nodejs \
    && sudo apt-get install -y --no-install-recommends python3 make g++ \
    && sudo rm -rf /var/lib/apt/lists/*
