# Selected Boost.JSON source snapshots

This is a narrow source-presence check. It is not a Rocq allocator-proof audit or a demonstration that the verified harness uses the monotonic resource.

## Exact source mapping

The proof project's manifest at `theorem-labs/oss-verify-proofs@98e995d4daced70a0a4aa2c810854b88720735f1` names:

- Boost superproject: `boostorg/boost@4daa5786d7c5dad39df0429cb078165b3134a06f`.
- At that revision, the GitHub contents metadata for `libs/json` identifies the submodule `boostorg/json@e93cf9c254619142b9f3cfa9022b93fb1d4e5edb`.

The observed metadata endpoint was:

https://api.github.com/repos/boostorg/boost/contents/libs/json?ref=4daa5786d7c5dad39df0429cb078165b3134a06f

The four selected files were already fetched in the completed exploration and were assembled into this portable snapshot on 29 October 2026. [manifest.json](manifest.json) gives their pinned URLs and local hashes.

## Interpretation

- `monotonic_resource.ipp` establishes presence of a custom suballocator in the source.
- `fuzz_parse.cpp` calls `parse(sv, ec)` without explicitly passing a monotonic resource.
- `value_stack.ipp` is retained exploratory source. Its correspondence to the compiled target and Rocq invariants was not audited.
- `project.yaml` provides source/version and target inventory.

No proof files are included for Boost.JSON. The saved source does not resolve allocator reachability in the verified harness. See [additional-projects.md](../../reports/additional-projects.md) for the counting and provenance limits.

