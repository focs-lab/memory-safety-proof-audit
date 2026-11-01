# Additional projects: confirmed source presence, inherited leads, and counting rules

## Working-note status, 1 November 2026

We removed the preliminary survey from the paper. Its allocator review now
covers four selected case studies: msgpack-c, simdjson, OpenSSL, and pupnp.
We have not completed the proof and harness investigation needed to include
Boost.JSON, tinyobjloader, Varnish, libpcap, Leptonica, Mbed TLS, zstd, or
Speex as further case studies.

We retain the earlier notes below and their source records as exploratory
working material. The twelve-project register records leads considered during the
investigation; it is not a result reported by the current paper. The notes
below preserve the earlier evidence status and should not be read as a
completed audit of the additional projects.

## Purpose and scope

This report preserves **12 tracked projects**, including the broader survey findings from the earlier conversations. The main paper's four detailed case studies are msgpack-c, simdjson, OpenSSL, and pupnp. Boost.JSON additionally received the narrow primary-source presence check described here. Seven further projects have recovered prior-survey findings, including scope exclusions and a correction for Varnish. These are different evidence levels, not twelve completed allocator-proof audits.

The recovered October 24–25 survey details are **prior assistant findings**, not fresh primary-source confirmations. The findings are retained below. Raw conversation-recovery records are excluded from this release; the [provenance note](../source-snapshots/prior-conversations/README.md) explains their limitations. They are not new audits.

The handoff intentionally does not restart the earlier survey or turn a library's optional allocator into a verified workload merely because it exists in the source tree.

## Counts that the evidence supports

| Quantity | Supported interpretation |
| --- | --- |
| 12 tracked projects in the broader discussion | msgpack-c, simdjson, OpenSSL, pupnp, Boost.JSON, libpcap, Leptonica, Mbed TLS, zstd, Speex, tinyobjloader, and Varnish. This is a tracked-project count, not twelve proved custom-allocator workloads. |
| 4 projects audited in depth | msgpack-c, simdjson, OpenSSL, pupnp; see their separate reports. |
| 8 projects beyond the detailed four-project table | Boost.JSON has the additional direct source-presence check; the other seven have recovered prior-survey findings. The latter include reported exclusions and configuration dependence. |
| 19 public harnesses / 41 agreement statements across those four projects | Inventory totals: msgpack 1/3, simdjson 10/24, OpenSSL 7/12, pupnp 1/2. These are not 41 independent allocator audits. |
| At least 5 projects in the released inventory contain custom allocation code | The four case studies plus the narrow Boost.JSON source-presence check. This uses a broad source-presence definition. |
| Number of verified harnesses actually exercising every identified allocator | Not established by this handoff. |
| Total prevalence of custom allocators among all 25 projects at the audit snapshot | Not established by a complete, uniform survey. Do not turn the lower bound into an exhaustive count or a prevalence percentage. |

The four-project count denotes detailed case studies within the twelve-project table. It should not be paraphrased as “only four projects have custom allocators.”

### Complete tracked-project register

| Project | Evidence level | Allocator or storage finding and its scope |
| --- | --- | --- |
| msgpack-c | Detailed selected-path proof review | C++ zone allocation in `unpack_pack_fuzzer`; see the project report for fit/freshness reasoning and the limits of completed-object and longer-history claims. |
| simdjson | Detailed selected-path proof review | DOM string arenas and On-Demand decoder regions; see the project report for record/output-region invariants and client-view lifetime scope. |
| OpenSSL | Detailed selected-path proof review | `BN_CTX` paths in `bndiv` and `bignum`; positive bounds/frame evidence and a reusable-predicate limitation, without a demonstrated violating client trace. |
| pupnp | Detailed selected-path proof review | `FreeList` caching in `FuzzHttp`; backing/cache accounting and an empty-cache allocation contract. |
| Boost.JSON | Direct source-presence check, plus recovered prior-survey detail | `monotonic_resource` is confirmed in the pinned source. Earlier findings also identify `value_stack` temporary storage. Execution of optional monotonic/static resources by the verified harness was not established. |
| libpcap | Recovered prior-survey finding | `newchunk`/`freechunks` arena, reported not used by `fuzz_pcap`. |
| Leptonica | Recovered prior-survey finding | Optional `pmsCreate`/`pmsCustomAlloc`/`pmsCustomDealloc` manager, reported not installed by the published harnesses. |
| Mbed TLS | Recovered prior-survey finding | `memory_buffer_alloc.c` allocator, reported not initialized by `fuzz_pkcs7`. |
| zstd | Recovered prior-survey finding | `ZSTD_cwksp` arena; relevance to the published harnesses remains unresolved. Earlier findings report ASan poisoning/redzones. |
| Speex | Recovered prior-survey finding | `PUSH`/`ALLOC` scratch allocation is configuration dependent; the selected published binary configuration remains unconfirmed. |
| tinyobjloader | Recovered prior-survey finding | 64-KiB bump blocks with a used cursor; earlier analysis asserted use by `fuzz_tobj_c`, without fresh primary confirmation in this handoff. |
| Varnish | Recovered prior-survey finding with an explicit correction | An earlier `WS_Init`/1-KiB workspace claim for `esi_parse_fuzzer` was corrected because the verified build uses `ENABLE_WORKSPACE_EMULATOR`, reported to route allocations through `malloc`/`free`. |

The first four rows summarize completed detailed reports. The remaining rows preserve their stated evidence level; in particular, an inherited assertion that an allocator is excluded from a harness is not a new call-graph result.

All corpus references in this report refer to proof commit `98e995d4daced70a0a4aa2c810854b88720735f1` unless explicitly marked as inherited context. Moving branches/tags and later releases are separate evidence.

## Boost.JSON: source presence confirmed, harness relevance unresolved

### Exact provenance

| Item | Identity |
| --- | --- |
| Proof project | `boost-json` |
| Project manifest | [Saved project.yaml](../source-snapshots/boost-json/project.yaml) |
| Manifest's library repository | `boostorg/boost` |
| Boost superproject commit | `4daa5786d7c5dad39df0429cb078165b3134a06f` |
| `libs/json` submodule repository | `boostorg/json` |
| Submodule commit at that superproject revision | `e93cf9c254619142b9f3cfa9022b93fb1d4e5edb` |
| Harness in the public proof inventory | `fuzz_parse` |
| Agreement variants in that inventory | ASan, UBSan, ASan+UBSan; 1 harness / 3 statements |
| Completed review here | Upstream allocator implementation, harness text, and source-version mapping |
| Not completed | Inspection of the corresponding Rocq allocator contracts or proof that this particular allocator is reached by the harness |

The superproject-to-submodule mapping was obtained from the GitHub contents metadata for `libs/json` at the exact Boost commit. The [snapshot provenance](../source-snapshots/boost-json/PROVENANCE.md) and [manifest](../source-snapshots/boost-json/manifest.json) retain the identities.

### Confirmed custom arena

Saved upstream source:

[include/boost/json/impl/monotonic_resource.ipp](../source-snapshots/boost-json/upstream/include/boost/json/impl/monotonic_resource.ipp)

At the pinned JSON submodule revision:

- Lines 118–146 implement `monotonic_resource::do_allocate`.
- The allocator finds aligned space in the current backing block, advances `head_->p`, and decreases available space.
- When needed it obtains another block from its upstream resource and suballocates within that block.
- Lines 151–156 contain an empty individual `do_deallocate` operation.
- Lines 100–113 implement `release`, including bulk release of allocated backing blocks and restoration of the initial buffer state.

This is enough to establish that the pinned project contains a custom suballocator. A no-op individual deallocation is part of this allocator's intended semantics; it must not automatically be labeled a missed free or a bug.

### What the verified harness text shows

Saved upstream harness:

[fuzzing/fuzz_parse.cpp](../source-snapshots/boost-json/upstream/fuzzing/fuzz_parse.cpp)

It constructs an input `string_view`, calls `parse(sv, ec)` without explicitly supplying a `monotonic_resource`, and returns a predicate on the parsed value. Its fuzzer entry catches exceptions.

The absence of an explicit `monotonic_resource` in this harness is not a complete call-graph analysis. It neither establishes that this arena is exercised nor proves that no custom allocation occurs internally. In particular, the parser also has internal storage code, but this handoff does not make a proof-coverage claim about it.

[include/boost/json/impl/value_stack.ipp](../source-snapshots/boost-json/upstream/include/boost/json/impl/value_stack.ipp) was fetched during this limited exploration and is retained for continuity. It was not matched against the compiled harness or used to derive a Rocq coverage verdict. Treat it as an exploratory source snapshot.

The newly recovered earlier survey specifically identifies **`value_stack` temporary storage** as part of the Boost.JSON allocation discussion. It also distinguishes optional monotonic/static resources from the default harness path: their execution was not confirmed. Preserve this inherited observation alongside the direct source-presence check, rather than reducing the earlier survey to the monotonic allocator alone. The exact temporary-storage-to-compiled-proof chain was not re-established for this handoff.

### Defensible and indefensible wording

**Supported:** “Boost.JSON is an additional project in the released inventory whose pinned source contains a monotonic arena.”

**Not supported by this check:** “The verified Boost.JSON workload uses that arena,” “the arena's lifetime safety was audited,” or “the Boost.JSON proof ignores its allocator.”

Do not add Boost.JSON to the four-row deep-audit table without an explicit status column distinguishing its much narrower evidence.

## Seven additional projects: recovered survey findings and corrections

The earlier compact handoff retained six names with sparse details and omitted Varnish. The recovered conversation material restores the concrete allocator names, reported harness exclusions, configuration issues, and Varnish correction below. **Every finding in this table is inherited from prior assistant output.** No new source fetch, call-graph check, build-configuration analysis, or Rocq audit was undertaken for these seven projects during this handoff.

| Project | Recovered prior-survey finding | Evidence status and remaining qualification |
| --- | --- | --- |
| libpcap | The source contains a `newchunk`/`freechunks` arena; the earlier survey reported that this arena is **not used by `fuzz_pcap`**. | The allocator symbols and reported exclusion are recovered prior findings. The complete pinned source/build/call-path evidence was not newly reconstructed. Do not count this arena as exercised merely because libpcap has a released proof. |
| Leptonica | `pmsCreate`, `pmsCustomAlloc`, and `pmsCustomDealloc` provide an optional manager; the earlier survey reported that it is **not installed by the published harnesses**. | Recovered optional-configuration exclusion. Multiple harness proofs do not establish coverage of an optional pool that those clients do not install. Exact per-harness installation/build evidence was not newly rechecked. |
| Mbed TLS | `memory_buffer_alloc.c` supplies buffer-backed custom allocation; the earlier survey reported that it is **not initialized by `fuzz_pkcs7`**. | Recovered source-presence and initialization-scope finding. Preserve the separation between available allocator code and enabled allocator use. The exact pinned build/configuration chain was not freshly confirmed. |
| zstd | `ZSTD_cwksp` is an arena/workspace mechanism. Its relevance to the published targets remained **unestablished**. The earlier survey also reported **ASan poisoning and redzones** for this workspace. | Recovered candidate with an instrumentation qualification. Do not describe it as an unannotated allocator invisible to ASan, or infer use on every compression/decompression target. Exact compiled configuration and proof correspondence remain unresolved. |
| Speex | The `PUSH`/`ALLOC` scratch-allocation mechanism is **configuration dependent**; selection of the relevant implementation in the published binary was **not confirmed**. | Recovered build-dependent finding. Distinguish scratch/caller-provided storage, standard allocation, and logical suballocation. No particular binary configuration or Rocq contract is newly certified here. |
| tinyobjloader | The earlier survey described **64-KiB bump blocks with a used cursor** and asserted that the path is used by **`fuzz_tobj_c`**. | Recovered positive harness-relevance assertion, not a fresh primary confirmation. The earlier compact handoff had only a truncated 64-KiB snippet; the recovered record restores the additional claimed cursor/harness information. Exact implementation symbols and the complete pinned path were not independently reconstructed. |
| Varnish | The earlier survey initially associated **`WS_Init` and a 1-KiB workspace** with **`esi_parse_fuzzer`**. A subsequent correction reported that the **verified build enables `ENABLE_WORKSPACE_EMULATOR` and uses `malloc`/`free`**. | Recovered correction, which must accompany the original claim. Do not present the normal workspace arena as the allocation mechanism exercised by that verified build. Exact emulator implementation symbols/build evidence were not freshly rechecked. |

This table does not assert that all seven are verified custom-allocator workloads. It contains positive source findings, reported exclusions, configuration-dependent possibilities, and an explicit retraction of an earlier workload interpretation. These distinctions are part of the recovered results and should remain visible in any broader project table.

Full immutable source paths and revisions for these additional allocator findings are not supplied by the selected snapshots in this handoff. The recovered conversation file preserves what was previously said; it is a retrieval record, not an independent primary-source citation. If an inherited exclusion, positive reachability assertion, or Varnish correction becomes a central published claim, recover its exact prior primary evidence before strengthening the wording.

## PHP: preserve the inventory distinction

Prior project records state that the audited corpus included PHP source/build/statement material with **6 target entries, 24 binaries, and 42 statements, but no released proofs**. The recorded PHP source commit begins `1979890d`; the full hash was not recovered in this subtask.

This item is inherited inventory context, not a fresh PHP allocator audit. The accompanying corpus report or recovered inventory should be used for the current handoff's authoritative evidence and exact commit if available.

Three distinctions matter:

1. A project appearing under a `projects/` directory can have statements without completed released proofs.
2. A corpus count of binaries or theorem statements is not a count of proved statements.
3. The PHP2Shell disclosure is historical context for the announcement; it is not evidence that the released verification established PHP's allocator safety or closed those vulnerabilities.

No claim about PHP custom-allocator coverage, the exploitability of a particular PHP bug, or an inspected PHP Rocq proof follows from this record.

## Checklist for extending this evidence later

For each additional project, preserve the following links before adding a definitive row to the paper:

1. Exact upstream revision and allocator implementation.
2. Exact compiled harness and relevant build options.
3. Evidence that the particular allocator and API histories are reachable in that workload.
4. Released proof variants and their theorem premises.
5. Local invariants and caller obligations that positively establish allocator properties.
6. The precise missing end-to-end contract, with any countermodel separated from a reachable binary violation.

A count should state whether it measures tracked projects, source presence, enabled build configurations, exercised harness paths, or detailed proof audits. The present handoff tracks **12 projects**: **four detailed case studies, one additional directly checked source-presence case, and seven additional projects with recovered prior-survey findings**. All twelve belong in a broader inventory with those status distinctions; the four-project table has the narrower purpose of summarizing the detailed proof reviews.

