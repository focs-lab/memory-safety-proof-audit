# A checked agreement proof with an array-boundary violation

This is the reduced interpreter example cited in Appendix A. The twenty-first
input byte crosses `buf[20]` and overwrites `op` within one heap allocation.
The input can thereby select `h_admin`. Both handlers in this version are
empty: the observation is unintended handler selection, not a privileged
operation.

## Proof evidence

The [statement](proof/projects/example/core/Statements.v) and
[proof](proof/proofs/example/core/asan_agrees/Proof.v) establish `asan_agrees`
for the supplied `core.plain` and `core.asan` binaries, subject to the model
and memory-budget premises. The retained
[cold-run log](replay/logs/example-check-cold.log) and
[final checker log](replay/logs/example-check-56.log) report two successful
steps and 15 permitted axioms. Packaging verified the retained file hashes;
it did not repeat the Rocq build.

The [source](example/example_core.c), complete [proof snapshot](proof/),
[binaries](replay/example/out/), [assumption report](replay/logs/assum-55.full),
and [provenance](provenance.json) are included. Files copied from the source
repository are unchanged and pinned to commit
`6c0b38af5c42556d8836a8360042f05943bb03d9`.

## Execution evidence

The [execution replay](execution/README.md) reruns both proved binaries with
the supplied exploit and benign inputs. The retained instruction and register
traces confirm that the twenty-first byte overwrites `op` with `0xff` and
selects `h_admin` in both binaries. The benign input selects `h_nop`. All
four runs return successfully without an ASan report. The bundle includes
the raw logs, exact commands, binary and input hashes, and an automated
trace checker.

The original [proof report](proof/README.md) recorded the same observation,
but its raw traces were not retained. The new traces were captured on
1 November 2026; the original proof files and checker logs are unchanged.

The [exploit input](replay/example/inputs/core-exploit.bin) contains the
driver's six-byte zero prefix followed by twenty `A` bytes and `0xff`.
The [benign input](replay/example/inputs/core-benign.bin) uses the same prefix
followed by `alice`. Debug binaries are retained alongside the proved binaries
to support inspection of handler addresses. Only `core.plain` and `core.asan`
are the binaries named by the theorem.

## Checking the proof

Use an OSS Verify checkout at
`a6839bb9e433b34c0d0710df5280194528877139`. Copy `proof/projects/` and
`proof/proofs/` into its corresponding directories, apply
`proof/oss-verify-proofs.patch`, and copy `core.plain` and `core.asan` into
`projects/example/bin/core/`. Run
`./oft check example/core --parts statements,proofs` using the upstream
checker image pinned in [provenance.json](provenance.json).

The [original report](proof/README.md) describes the recorded checks and
their assumptions. Its references to regeneration scripts describe the source
repository; those historical scripts and the full toolchain are not bundled.
The copied harness metadata is also historical: `status: open` registers the
statement, while the separate proof unit and checker logs record its proof.
Its placeholder library URL identifies a synthetic example, not a verified
upstream library. Applicable upstream notices are retained in [LICENSES](LICENSES/).
