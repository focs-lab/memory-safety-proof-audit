# Reproduction guide

Use the [claim index](evidence/README.md) to choose a result. The checks below
serve different purposes. File checks establish that the retained bytes
match their manifests. Proof replays establish the named statements under
their assumptions. Source inspection is needed to interpret those statements.

## Get the release

Clone this repository to obtain the audit files. While the repository is
private, reviewers need GitHub access to clone it and download the archived
proof sources. The upstream `theorem-labs/oss-verify-proofs` repository is public.

Start with Git, Python 3.9 or later, `tar` with gzip support, and `shasum`.
Git must support `sparse-checkout` for the upstream-source recipes.
On Linux, `sha256sum -c FILE` can replace `shasum -a 256 -c FILE`.

```sh
git clone https://github.com/focs-lab/memory-safety-proof-audit.git
cd memory-safety-proof-audit
git rev-parse HEAD
```

Record the printed commit with your results. The checks below use the files
in this clone. They do not need another copy of our working directories.

For the Docker checks, install Docker and start its engine before running
the commands. `docker version` must report both a client and a server.
The images use Linux amd64. An ARM host needs amd64 emulation. Image pulls
need network access; the proof and execution containers run with networking
disabled. The OpenSSL section instead needs the named Rocq tools on `PATH`.
The optional archive download uses an authenticated GitHub CLI (`gh`).

Run each command block from the repository root in a POSIX shell. Commands
that enter another directory use a subshell. Run the blocks in each section
in order, in the same shell. Stop if a command fails.
Other tools are listed where needed. Run Python without `-O`, since
the supplied checkers use assertions.

## Package integrity

First check the released files and the retained coturn evidence. These
commands need no Docker, Rocq, or network access.

```sh
python3 scripts/validate.py
python3 evidence/dossiers/coturn-field-bounds/checks/verify_materials.py
```

The first command should print `PASS`. It checks local documentation links,
citation order, the PDF header, and file hashes. The second should report
`"status": "PASS"`, 75 vendor sources, 11 audit sources, and two literal
Rocq statements. It also checks source excerpts and retained result records.
Neither command runs Rocq or executes a reviewed binary.

Full replays below use fresh directories under `build/`. This preserves
the supplied logs and avoids mixing old compiled objects with a new run.
The [validation record](VALIDATION.md) states which instructions were tested
during this release preparation.

<a id="openssl"></a>
## OpenSSL

This checks **SSL1–SSL2** against the unchanged model definitions. Install
`coqc`, `coqdep`, and `coqchk` from one Rocq installation. The retained run
used Rocq 9.0.0 and OCaml 5.3.0 on arm64 macOS. The official upstream binary
checker uses Rocq 9.2. This focused replay uses the former environment and
does not check the binary agreement certificates.

Verify the bundle, then extract a fresh copy. The second checksum check
covers the files inside it. `verify_sources.py` checks the retained Git tree
chain and the 28 upstream source files.

```sh
(cd evidence/dossiers/openssl-lifetime && shasum -a 256 -c bundle.sha256)
mkdir -p build
audit_ssl_dir=$(mktemp -d "$PWD/build/openssl.XXXXXX")
tar -xzf evidence/dossiers/openssl-lifetime/openssl-independent-replay-2026-11-01.tar.gz \
  -C "$audit_ssl_dir"
audit_ssl_dir="$audit_ssl_dir/openssl-independent-replay-2026-11-01"
(
  cd "$audit_ssl_dir"
  shasum -a 256 -c SHA256SUMS > integrity.log
  python3 verify_sources.py
)
```

Put the chosen Rocq tools on `PATH`. This sets `ROCQ_BIN` explicitly, so the
bundled script does not use its original author's local installation path.

```sh
audit_rocq_bin=$(dirname "$(command -v coqc)")
test -x "$audit_rocq_bin/coqdep"
test -x "$audit_rocq_bin/coqchk"
"$audit_rocq_bin/coqc" --version
(
  cd "$audit_ssl_dir"
  ROCQ_BIN="$audit_rocq_bin" python3 replay.py > replay.log 2>&1
)
```

A successful run exits with code zero. Inspect `replay.log` and
`logs/build-results.json` in the extracted directory. The run compiles
28 upstream modules and four audit modules, then runs `coqchk` on the audit
modules and their dependencies. Every recorded return code should be zero.
The four audit logs contain 23 `Closed under the global context` responses
to assumption queries. A successful `coqchk -silent` log contains its command
and no checker diagnostics. The fresh-clone run took about 95 seconds
on arm64 macOS. Peak memory and disk requirements were not measured.

Read `exp/IndependentWitness.v` with the complete upstream setter contract.
The new client's model execution uses a temporary after frame end. This
does not demonstrate that the published `bndiv` binary does so.

<a id="coturn"></a>
## Coturn

This checks **TURN1–TURN2**. It needs Docker and the pinned Linux amd64 checker
image. An ARM host also needs Docker's amd64 emulation. The retained run
took about 166 seconds after the image was available. Peak memory and disk
requirements were not measured.

Acquire the checker image before the offline run. Authentication may be
needed if the registry requires it.

```sh
audit_checker=ghcr.io/theorem-labs/oss-fuzz-theorems-checker@sha256:cc9ae43a9f4b0dd59d7c8d30727d36e039bfe72a2a9f9c4a99c68e413037e902
docker pull --platform linux/amd64 "$audit_checker"
mkdir -p build
audit_turn_dir=$(mktemp -d "$PWD/build/coturn.XXXXXX")
cp -R evidence/dossiers/coturn-field-bounds/reproduction/. "$audit_turn_dir/"
(
  cd "$audit_turn_dir"
  sh run.sh > replay.log 2>&1
)
```

The runner disables container networking. It checks the vendor and binary
hashes, regenerates static images from the two binaries, and compiles all
88 sources. Static image generation does not execute coturn.

After the command exits successfully, inspect the new `result.json`,
`assumptions.txt`, and `replay.log`. Expect `"status": "PASS"`,
`"checked_sources": 88`, and
`"all_assumptions_in_upstream_allowlist": true`. The two theorem names must
be `asan_decoded_case_admits_buf_minus_one` and
`both_decoded_case_admits_buf_minus_one`. Compare their source hashes with
the [retained result](evidence/dossiers/coturn-field-bounds/reproduction/result.json).
Timestamps and elapsed time will differ.

The result establishes states satisfying the complete selected invariants
with a destination below the array field. It supplies no input reaching
those states and no execution through the write.

<a id="interpreter"></a>
## Interpreter proof

This replays **EX1** for the two supplied binaries. It needs Git, Docker,
Python 3 with pip, and an upstream checkout at the pinned revision.
The latest fresh-clone proof replay is **incomplete**. An eight-job run
exhausted a Docker VM with about 7.65 GiB of memory. A two-job retry was
stopped at the author's request. The commands below include that limit,
but have not completed a full replay. See the
[validation record](VALIDATION.md#fresh-clone).

The earlier retained run took about 22 minutes, excluding downloads.
We have no completed timing or memory bound for the two-job configuration.

Fetch a sparse checkout containing the upstream checker, shared
definitions, and projects. All projects are needed because the checker
validates the release's project counts. Add the supplied proof, statement,
registration patch, and binaries. The patch changes project registration;
it does not change the upstream semantics or assumptions allowlist.

```sh
mkdir -p build
audit_example_dir=$(mktemp -d "$PWD/build/interpreter.XXXXXX")
git clone --filter=blob:none --no-checkout \
  https://github.com/theorem-labs/oss-verify-proofs.git "$audit_example_dir/upstream"
git -C "$audit_example_dir/upstream" sparse-checkout init --cone
git -C "$audit_example_dir/upstream" sparse-checkout set theories tools toolchain projects
git -C "$audit_example_dir/upstream" checkout --detach a6839bb9e433b34c0d0710df5280194528877139
test "$(git -C "$audit_example_dir/upstream" rev-parse HEAD)" = \
  a6839bb9e433b34c0d0710df5280194528877139
git -C "$audit_example_dir/upstream" apply \
  "$PWD/evidence/dossiers/checked-example/proof/oss-verify-proofs.patch"
cp -R evidence/dossiers/checked-example/proof/projects/. "$audit_example_dir/upstream/projects/"
mkdir -p "$audit_example_dir/upstream/proofs"
cp -R evidence/dossiers/checked-example/proof/proofs/. "$audit_example_dir/upstream/proofs/"
mkdir -p "$audit_example_dir/upstream/projects/example/bin/core"
cp evidence/dossiers/checked-example/replay/example/out/core.plain \
  evidence/dossiers/checked-example/replay/example/out/core.asan \
  "$audit_example_dir/upstream/projects/example/bin/core/"
```

The checker image needs Python packages that are not included in it.
Fetch the Linux wheels named in the pinned upstream requirements file.
The helper verifies their hashes and unpacks them into a fresh directory.
It also keeps the wheels and their hashes for inspection.

```sh
python3 scripts/prepare_checker_python.py \
  "$audit_example_dir/upstream/tools/oft/requirements.txt" \
  "$audit_example_dir/python-deps"
```

Run the checker with its network disabled and the build cache disabled.
Use two CPUs. The checker sets its build jobs from the CPU affinity mask.
This limits concurrent compilation. It does not establish that a given
memory allocation is sufficient. Docker must provide at least two CPUs
for the command below.
The stack limit is required for the proof terms. Container output stays
in the fresh checkout and log directory.

```sh
audit_checker=ghcr.io/theorem-labs/oss-fuzz-theorems-checker@sha256:cc9ae43a9f4b0dd59d7c8d30727d36e039bfe72a2a9f9c4a99c68e413037e902
docker pull --platform linux/amd64 "$audit_checker"
mkdir -p "$audit_example_dir/logs"
docker run --rm --platform linux/amd64 --network none --ulimit stack=-1:-1 \
  --cpuset-cpus 0-1 \
  --user "$(id -u):$(id -g)" -e HOME=/tmp -e DUNE_CACHE=disabled \
  -e TMPDIR=/audit-logs -v "$audit_example_dir/logs:/audit-logs" \
  -e PYTHONPATH=/python-deps -v "$audit_example_dir/python-deps:/python-deps:ro" \
  -v "$audit_example_dir/upstream:/work" -w /work "$audit_checker" \
  ./oft check example/core --parts statements,proofs \
  > "$audit_example_dir/check.log" 2>&1
```

Expect two binaries with zero hash problems, the statement compiled, the
proof accepted with 15 allowed assumptions, and `2 step(s) passed, 0 failed`.
Compare with the [retained cold log](evidence/dossiers/checked-example/replay/logs/example-check-cold.log).
The theorem concerns the supplied plain and ASan binaries. The debug
binaries are auxiliary inspection inputs.

<a id="interpreter-execution"></a>
## Interpreter execution

This checks **EX2**. The retained traces show the array-boundary overwrite
and handler selection in the exact plain and ASan binaries. We check the
triggering input and a benign control in each binary. Both handlers are
empty, so the trace is needed to distinguish which one ran.

To check the saved evidence, verify its checksums and run the trace checker.
This needs Python and `shasum`; it needs no Docker or network access.

```sh
(
  cd evidence/dossiers/checked-example/execution/retained
  shasum -a 256 -c SHA256SUMS
)
python3 -B evidence/dossiers/checked-example/execution/check_trace.py
```

Expect a JSON result with `"status": "PASS"` and four passing cases.
The checker verifies each copied byte and its address. It then follows the
`op` load, handler-table lookup, indirect call, and return. It compares
logged instructions with the proved ELF files. The debug files supply
symbol names; their relevant code and table bytes must match those ELF files.
Compare the output with the [retained result](evidence/dossiers/checked-example/execution/retained/result.json).

To capture fresh traces, use Docker and the pinned Linux amd64 **runner**
image. This image contains QEMU. The proof replay above uses a different
image containing Rocq. An ARM host also needs Docker's amd64 emulation.

```sh
audit_runner=ghcr.io/theorem-labs/oss-fuzz-theorems-runner@sha256:d197498c0e20de006e61fbe7c3d70ebdd81ad3928468ac45d643b72c716e7af2
docker pull --platform linux/amd64 "$audit_runner"
mkdir -p build
audit_execution_dir=$(mktemp -d "$PWD/build/interpreter-execution.XXXXXX")
sh evidence/dossiers/checked-example/execution/run.sh "$audit_execution_dir"
python3 -B evidence/dossiers/checked-example/execution/check_trace.py \
  --output "$audit_execution_dir"
```

The output directory must be empty at the start. The runner disables
networking and mounts the artifact read-only. It uses an empty guest
environment and limits the container to 2 GiB and two CPUs. This resource
limit does not check the theorem's memory-budget premise.

Each of the four cases runs once with instruction/register logging and
once with syscall logging. Expect eight successful invocations, followed
by `PASS: exact binary pins, 21-byte overwrite, both handler targets, and benign controls`.

| Input | Expected in both binaries |
| --- | --- |
| Triggering input | 21 copied bytes; the last store writes `0xff` at allocation base + 20; `op = 0xff`; `h_admin` is called. |
| Benign control | Five copied bytes; `op = 0`; `h_nop` is called. |

All runs should print `0` and exit with code zero. Instruction runs should
have empty standard error. Syscall logs should record `exit_group(0)`.
The new directory contains the raw logs, `result.json`, `runs.json`,
`environment.json`, and `SHA256SUMS`. Addresses, process IDs, timings,
and trace block identifiers may differ. Inspect the recorded byte values,
relative addresses, and handler targets.

These commands check concrete executions. They do not rerun the agreement
proof. They execute the supplied binaries; rebuilding those binaries from
C still needs regeneration tooling absent from this package.

<a id="source-inspection"></a>
## Source inspection

This route checks **G1, UP1, MSG1, SIMD1, BZ1, and BZ2** by reading the pinned
statements, proof contracts, and harnesses. The claim index links selected
local files and names the symbols to inspect. Use each project's report
for the remaining file locations and hypotheses.

For a complete immutable source copy, follow the
[archive instructions](evidence/source-snapshots/oss-verify-proofs/98e995d4/README.md).
The release assets preserve all 145,602 tracked files at `98e995d4`. Their
download is about 5.1 GB; reassembly and extraction require additional space.
The archive verifier checks SHA-256, Git blob hashes, the root tree, and the
commit object. The archive does not include a complete offline build environment.

Alternatively, obtain the same source revision with Git:

```sh
mkdir -p build
audit_source_dir=$(mktemp -d "$PWD/build/sources.XXXXXX")
git clone --filter=blob:none --no-checkout \
  https://github.com/theorem-labs/oss-verify-proofs.git "$audit_source_dir/upstream"
git -C "$audit_source_dir/upstream" sparse-checkout init --cone
git -C "$audit_source_dir/upstream" sparse-checkout set \
  docs theories index projects/openssl projects/pupnp projects/msgpack-c \
  projects/simdjson projects/bzip2 proofs/openssl proofs/pupnp proofs/msgpack-c \
  proofs/simdjson proofs/bzip2
git -C "$audit_source_dir/upstream" checkout --detach 98e995d4daced70a0a4aa2c810854b88720735f1
test "$(git -C "$audit_source_dir/upstream" rev-parse HEAD)" = \
  98e995d4daced70a0a4aa2c810854b88720735f1
```

Partial clones need network access while fetching missing blobs. Read the
specified definitions with all their premises. For BZ2, compare the
decompression harness's open statements with `index/proofs.tsv`; the absence
of a proof in a selected local excerpt would not establish the coverage claim.
These commands retrieve sources. They do not replay the full proof corpus.

For **SPEC1**, work through the pool accesses using the contract in
Appendices B–C. The [claim index](evidence/README.md#object-contracts) states
the assumptions and identifies the supporting literature. There is no
executable pool experiment in this package.
