# Selected pupnp source snapshots

These seven files preserve source text already fetched during the completed selected inspection. No new network retrieval or comprehensive proof audit was performed for this handoff.

## Revisions

- Proof repository: `theorem-labs/oss-verify-proofs` at `98e995d4daced70a0a4aa2c810854b88720735f1`.
- Upstream source: `pupnp/pupnp` at `b46bc77ac9ae2ff1351d0f4ce544d97283b6e149`.
- Snapshot assembly date: 29 October 2026.

[manifest.json](manifest.json) provides the relative snapshot paths, original repository paths, pinned URLs, local SHA-256 values, and sizes. `proof/A0/` is the inspected ASan path, `proof/B0/` the corresponding ASan+UBSan path, and `proof/P0/` the plain-binary support. The upstream allocator and harness texts are retained for direct comparison.

This is not a complete buildable Rocq corpus. The hashes verify integrity of the saved text, not an independent proof replay. Copyright/license headers and original export annotations remain in place.

See [the pupnp report](../../reports/pupnp.md) for cached-node uniqueness, cleanup, and the empty-cache allocation precondition. These files support a specification-boundary analysis, not a demonstrated vulnerability.

