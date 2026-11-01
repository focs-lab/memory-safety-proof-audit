# Selected OpenSSL source snapshots

These files preserve the primary-source text already fetched during the completed inspection. No new comprehensive source audit or Rocq replay was performed when preparing this handoff.

## Revisions

- Proof repository: `theorem-labs/oss-verify-proofs` at `98e995d4daced70a0a4aa2c810854b88720735f1`.
- Upstream source: `openssl/openssl` at `47aae188a6bdc65675ea9c2a9e770bef48a5d781`.
- Snapshot assembly date: 29 October 2026.

## Contents and mapping

[manifest.json](manifest.json) maps each relative snapshot path to its full repository path, pinned source URL, local SHA-256, and byte count. `proof/bndiv/Spec/` contains the concrete validity/end-of-frame/setter contracts. `proof/bignum/Spec/` preserves the independently inspected liveness/reference representation and selected supporting frame/context files. `upstream/` contains the implementation and documented API contract. `project.yaml` records the pinned build/source inventory.

The 11 files are selected evidence, not the original report's much larger historical mirror and not a complete buildable proof checkout. The local SHA-256 values are bundle-integrity checks. They do not represent an independent Rocq check. Original copyright/license and exported-comment annotations are retained in the source bodies.

See [the consolidated OpenSSL report](../../reports/openssl.md) and [the preserved original dossier text](../../dossiers/openssl_allocator_proof_audit.full-text.md) for the distinction between directly inspected snippets, inherited completed audit findings, and unestablished claims.

