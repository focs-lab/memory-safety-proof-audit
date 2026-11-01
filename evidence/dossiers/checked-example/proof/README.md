# Snapshot: `asan_agrees` for example/core (build 56, 2026-10-31)

Copied from `work-repo/` (a sparse clone of oss-verify-proofs, not in this repository).
Layout mirrors their repo, so these folders drop into a checkout of oss-verify-proofs.

- `projects/example/core/Statements.v`: the statement (`asan_agrees := agrees_in
  Env.alloc_forced_only Budgets.Asan.lim_source Budgets.Asan.lim_target Images.plain Images.asan`),
  plus `Images.v`, `images/dune` and `harness.yaml`. The binaries are
  `replay/example/out/core.{plain,asan}`; the harness source is `example/example_core.c`.
- `proofs/example/core/asan_agrees/Proof.v`: the top theorem `asan_agrees_holds` (plus `proof.yaml`).
- `proofs/example/core/lib/`: the proof library (837 modules). Generated from pupnp/FuzzHttp's
  proof by `replay/port/make_port.py` plus the hand-written files in `replay/port/overlay/`.
  `PORT_MANIFEST.tsv` / `PORT_RENAMES.tsv` record the generation.
- `oss-verify-proofs.patch`: the three tracked files of their repo that registering the unit
  touches (`projects/example/project.yaml`, `release.yaml` counts, a `-example-proofs` package in
  `dune-project`). Metadata only: `theories/`, `tools/` and `toolchain/allowed-axioms.txt` are unchanged.

## Status: passes their checker

Their own `./oft check example/core --parts statements,proofs` passes:

```
oft verify-sha: 2 binaries, 0 problem(s)
projects/example/core: statements compiled, each of the 1 listed defined
proofs/example/core/lib: 836 files compiled or taken from dune's cache
proofs/example/core/asan_agrees: proves example/core/asan_agrees; assumptions: 15 axioms, all allowed
oft check: 2 step(s) passed, 0 failed
```

- Cold run (fresh tree without `_build`, `DUNE_CACHE=disabled`, every library file compiled from
  source in their checker image): 21.9 min, `replay/logs/example-check-cold.log`.
- Rerun on build 56 (comment fix only): `replay/logs/example-check-56.log`.
- Our own `Print Assumptions` gives the same 15 axioms: `replay/logs/assum-55.full`.
- No `Admitted`, `admit`, `Axiom` or `Parameter` anywhere in the unit.

Two review-only adversarial reviews found nothing that invalidates the proof (no escape hatches,
every section hypothesis discharged by closed proofs, no ported contract weakened, statement equal
to pupnp's form and to their generator's output, images byte-identical to the ELF segments).

## What the theorem does and does not show

- It shows that both builds are "error-free" (satisfy their statements) and agree on every input under 64 MiB, for a binary
  in which input byte 21 overwrites `op` inside the same 21-byte heap object (ASan's check
  passes: 20 mod 8 = 4 < 5) and `op` then selects the indirect-call target.
- `h_nop` and `h_admin` are both a bare `ret`, so agreement is expected whatever `op` is. That
  the exploit input reaches `h_admin` is shown by qemu traces, not by the theorem.
- `oft check` does not compare a hand-written `Statements.v`/`Images.v` with what `oft generate`
  would produce; this was checked by hand.
- The usual OSS Verify caveats apply (unproved memory-budget premise, LPS stack window, trust in
  `elf-snapshot`).

## How to check it

In a checkout of oss-verify-proofs at `a6839bb9e` (v2026.10.2): copy `projects/` and `proofs/`
from here, `git apply oss-verify-proofs.patch`, copy `replay/example/out/core.{plain,asan}` to
`projects/example/bin/core/`, then run `./oft check example/core --parts statements,proofs` in
their checker image (see `oftenv/README.md`). Regenerate the library: `sh replay/port/regen.sh N`.
