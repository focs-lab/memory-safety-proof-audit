# Memory-safety audit

Paper and supporting evidence about the memory-safety specifications in
the Anthropic–Theorem verification effort.

**Umang Mathur · Prateek Saxena · Tianyu Li · Bo Wang · Diego Meyer · Ruishi Li**<br>
National University of Singapore

## Read

- **[Paper (PDF)](paper/main.pdf): _AI Proved the Code Memory Safe. Or Did It?_**
  The argument, findings, references, and technical appendices.
- **[Claim index](evidence/README.md):** each technical claim, its evidence,
  checking method, and limits.
- **[Reproduction guide](REPRODUCE.md):** commands, prerequisites, expected
  results, and the checks that remain unavailable.
- **[Validation record](VALIDATION.md):** completed checks and their scope.
  The fresh-clone interpreter proof replay remains incomplete.
- **[Preserved proof repository](evidence/source-snapshots/oss-verify-proofs/98e995d4/README.md):**
  the complete `98e995d4` snapshot used for the allocator review, with release downloads,
  checksums, and offline verification instructions.

The paper follows source commit `c0b6cefc1ce16fb02cf1f2a6197a9016bfd5c0f9`
and includes six technical appendices.

The four-project allocator review concerns specifications and selected proof
paths in OpenSSL, msgpack-c, simdjson, and pupnp. The later coturn result gives
Rocq-checked countermodels to an internal field-bound implication. Neither
result establishes a reachable memory-safety violation in a verified binary.
The bzip2 review records a distinct result about internal bounds and harness
coverage. The claim index keeps these investigations separate.

## Use the files

The paper is distributed as a PDF. This repository contains no TeX or HTML files.

To validate the paper and evidence package:

```sh
python3 scripts/validate.py
```

## Reproduce and inspect

The [checked interpreter example](evidence/dossiers/checked-example/README.md)
contains the agreement proof, binaries, inputs, and recorded checker results
used in Appendix A. Both handlers are empty. The
[execution evidence](evidence/dossiers/checked-example/execution/README.md)
includes raw traces for both binaries and both inputs. It also supplies an
offline trace checker and a command to capture new traces. The
[reproduction guide](REPRODUCE.md#interpreter-execution) explains the checks.

The [coturn reproduction bundle](evidence/dossiers/coturn-field-bounds/reproduction/README.txt)
contains proof sources, pinned binary inputs, dependency hashes, and the
recorded checks. Its runner needs Docker and the specified checker image.
The fresh-clone coturn replay passed. The [validation record](VALIDATION.md)
gives the environment, completed checks, and incomplete interpreter replay.

[Source provenance](release-provenance.json) records how the release was
assembled. [Third-party notices](THIRD_PARTY.md) identify the supplied third-party
code. SHA-256 digests are recorded in `MANIFEST.sha256`.
