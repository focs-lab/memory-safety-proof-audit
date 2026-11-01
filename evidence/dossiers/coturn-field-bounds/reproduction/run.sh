#!/bin/sh
set -eu
task_audit_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
exec docker run --rm --platform linux/amd64 --network none --ulimit stack=-1:-1 \
  --user "$(id -u):$(id -g)" -e HOME=/tmp \
  -v "$task_audit_dir:/audit" -w /audit \
  ghcr.io/theorem-labs/oss-fuzz-theorems-checker@sha256:cc9ae43a9f4b0dd59d7c8d30727d36e039bfe72a2a9f9c4a99c68e413037e902 \
  python3 check_all.py
