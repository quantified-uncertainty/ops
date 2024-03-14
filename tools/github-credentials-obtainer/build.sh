#!/bin/sh

docker buildx build --label org.opencontainers.image.source=https://github.com/quantified-uncertainty/ops -t ghcr.io/quantified-uncertainty/github-credentials-obtainer .
