#!/bin/sh
set -eu
test "$#" -eq 1 || { echo "Usage: sh run.sh EMPTY_OUTPUT_DIRECTORY" >&2; exit 2; }
audit_execution_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
audit_artifact_dir=$(CDPATH= cd -- "$audit_execution_dir/.." && pwd)
mkdir -p "$1"
audit_output_dir=$(CDPATH= cd -- "$1" && pwd)
audit_runner=ghcr.io/theorem-labs/oss-fuzz-theorems-runner@sha256:d197498c0e20de006e61fbe7c3d70ebdd81ad3928468ac45d643b72c716e7af2
docker run --rm --platform linux/amd64 --network none --read-only \
  --memory 2g --cpus 2 --pids-limit 64 \
  --mount "type=bind,source=$audit_artifact_dir,target=/artifact,readonly" \
  --mount "type=bind,source=$audit_output_dir,target=/output" \
  "$audit_runner" python3 -B /artifact/execution/replay.py
