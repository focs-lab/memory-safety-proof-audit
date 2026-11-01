# msgpack-c: allocator safety in the initial public verification corpus

**Report assembled:** 29 October 2026.  
**Evidence basis:** the completed source audit prepared on 25 October 2026, with selected primary-file rechecks performed while drafting the paper on 29 October.  
**Original record:** [msgpack_proof_audit.txt](../dossiers/msgpack_proof_audit.txt). That recovered record contains the full earlier audit, its qualifications, and its source register. Its text was recovered through the file service; byte identity with the originally uploaded file is not asserted.

This report consolidates existing evidence for a portable handoff. It is not a new comprehensive audit. No Rocq replay, binary rebuild, execution experiment, or vulnerability reproduction was performed for this report.

## 1. Finding and limits

The published msgpack-c result concerns one compiled C++ unpack-and-pack harness. It establishes modeled error freedom and agreement between particular plain and sanitizer builds under explicit premises. The supporting development also contains substantial reasoning about the custom zone allocator: requested sizes, fit, alignment, freshness, non-overlap, object layouts, payload lengths, and array/map indices.

The source audit did **not** establish a general end-to-end theorem connecting every access to the bounds and lifetime of the original logical suballocation. Some completed-object predicates retain chunk containment and readability without independently retaining the original allocation request. That is a limitation of those predicates considered alone. Stronger construction invariants exist, so it is not evidence that the actual verified program can reach an invalid access.

The most relevant temporal history, clearing a zone while retaining references and then reusing its storage, is absent from the harness. The library does offer clear, but the exercised workload uses a fresh owning zone and destroys it after packing. A hypothetical clear–reuse client is a different program. No reachable custom-allocation violation accepted by the actual proof was identified.

### Evidence labels

| Label | Meaning in this report |
| --- | --- |
| Published theorem | A statement reported as proved in the pinned corpus; source inspection is distinct from an independent checker replay. |
| Positive internal evidence | A particular invariant, contract, or lemma supports a property under its own preconditions. |
| Outside harness | The relevant operation or client history is absent from the fixed client program being verified. |
| Not applicable | The alleged operation is not part of the allocator interface being discussed. |
| Not established | The review does not establish the stronger claim. This does not prove that the claim is false, unprovable, or absent from every file. |
| Predicate countermodel | An analytical state separating two predicates; not necessarily reachable and not necessarily satisfying the full proof invariant. |
| Reached bug | A violating execution from an admitted input under all relevant premises. None was produced here. |

## 2. Exact subject and artifact identities

| Component | Recorded identity |
| --- | --- |
| Proof repository | theorem-labs/oss-verify-proofs |
| Audited proof snapshot | 98e995d4daced70a0a4aa2c810854b88720735f1 |
| Binary release | v2026.10.0 |
| Project | msgpack-c, specifically the C++ zone implementation used by the harness |
| Upstream version | 8.0.0 |
| Upstream commit | a5250ecbcae1d34346c7445345774b0abbd651bc |
| Entry point | projects/msgpack-c/unpack_pack_fuzzer |
| Proof development | proofs/msgpack-c/unpack_pack_fuzzer |
| Compiler / platform | clang 20.1.8; static riscv64 Linux; musl; compiled for RV64G |
| LPS dependency recorded for the release | f1006fe8178338a499b5e5c41be83006c4edd058 |
| Checker version documented by the release | Rocq 9.2.0 |
| Library/harness modifications | Provenance records no library patch and an unmodified upstream fuzz harness |
| Inventory at the audited snapshot | 1 harness, 4 binaries, 15 statements, 3 proved agreement statements |
| Additional API driver | Held from this release; no guarantee about that unavailable driver is asserted |

The public proof files record ports by Theorem Labs to the release binaries. Historical dependency names in file comments do not override the release's current dependency pin. The audited commit and the binary-release tag are separate identifiers: this report does not assert that the tag currently resolves to the audited commit. [S01] [S03] [S23] [S31]

The one upstream version, four build variants, and three proved statements must not be described as three or four versions of msgpack.

### Published binary fingerprints

These hashes and sizes were recorded in the earlier audit from published provenance. They were **not recomputed from downloaded executables** in this work. [S03]

| Build | Bytes | SHA-256 |
| --- | ---: | --- |
| plain | 278176 | 39eb444705613eec7157d8538b94388808e1c49815b394ae3a183400855c4605 |
| UBSan | 284328 | 1d3021dd12abeb78f6ce16f6066d8747e8380908c6b38fa6d37ae024b9f789c2 |
| ASan | 801416 | 132b8f1051e58880fcc02b0043e4183d30e77bf60799d6d6b0940a2e8453b26b |
| ASan + UBSan | 810088 | 65343a2c6dcb3a0423b4ced9643966d0d6de8b8ba873cb593299fb481a3ddbd4 |

## 3. The actual client sequence

The harness attempts the following sequence on each invocation:

1. Call msgpack::unpack on the supplied bytes, with all six unpack_limit fields set to 1000. These bound arrays, maps, strings, binary values, extension values, and nesting depth.
2. Keep the returned object_handle, which owns the zone for the unpacked result.
3. Create an sbuffer and pack the unpacked object into it.
4. Destroy local objects on return or unwind them after an exception.
5. Catch all exceptions and return zero.

The source does not compare the packed bytes with the input, does not unpack the output again, and does not check a semantic MessagePack oracle. Thus the result is not a theorem of MessagePack conformance or serialization round-trip correctness. A useful round-trip theorem would normally compare semantic values, since byte-identical encoding need not be the desired contract. [S01] [S05]

The driver can invoke the callback one to four times. Each invocation creates fresh owning state; it does not return a zone pointer to the driver for use by a later invocation. Physical allocator addresses may repeat, but that fact alone does not produce a retained-reference history. [S02] [S25]

The driver reads a wrapper format containing configuration bytes and an allocation-mask field; the latter is ignored by this harness binary. Files of 64 MiB or more are rejected before the callback is invoked. The complete theorem still quantifies over valid modeled process inputs, including inputs rejected by the driver. “Input limit” should not be confused with sampling a finite test suite. [S02]

## 4. Exported statements and proof symbols

| Public statement | Plain-build budget premise | Sanitizer target budget | Initial-snapshot status |
| --- | --- | --- | --- |
| asan_agrees | No budget refusal at 2 GiB | 512 GiB | Proved |
| ubsan_agrees | No budget refusal at 16 GiB | 512 GiB | Proved |
| asan_ubsan_agrees | No budget refusal at 2 GiB | 512 GiB | Proved |

The source-budget condition is a premise. It is not a proof that every admitted payload stays within the budget. The larger target-side allowance does not assert equal memory consumption in plain and instrumented executions. The environment policy excludes arbitrary memory-allocation refusal, while forced refusal and other modeled environmental failure families remain relevant. [S02] [S06]

The earlier audit records these exact supporting theorem names in lib/Theorems.v:

    strong_universal_error_free_unpack_pack_fuzzer_asan
    strong_universal_error_free_unpack_pack_fuzzer_ubsan
    strong_universal_error_free_unpack_pack_fuzzer_both

They instantiate:

    strong_universal_error_free_T_scfg_budgets_abort

The readable release form is agrees_in_abort_modelled. The public statement combines error freedom for both builds with equality of sets of modeled observable behaviors. It is stronger than “the two return the same result.” The observations are process observations, including input/output and final files, rather than the mathematical meaning of a MessagePack value. [S04] [S06]

These symbol names were preserved from the completed dossier and its pinned source links. The Theorems.v file was not newly fetched for this consolidation. The selected archived primary files described in Section 10 do not comprise the full theorem dependency graph.

### Termination

At the audited snapshot, the halting statements were open. Agreement and modeled error freedom do not themselves exclude every infinite execution. Subsequent releases added halting results; the initial-snapshot finding must not be presented as the current status of the project. The handoff preserves the original audit boundary rather than silently upgrading its conclusions.

## 5. How the custom allocator works

### 5.1 Zones and chunks

The zone obtains larger backing chunks from standard allocation and distributes smaller regions by advancing a pointer. Its model records a zone address, chunk list, current pointer, and remaining capacity. The modeled default chunk has 8192 data bytes and an 8-byte header. An expansion path obtains a new chunk when a request does not fit. [S09] [S10] [S24]

The inspected binary layout uses 24 bytes per msgpack object and 48 bytes per map key/value pair. Strings and binary values use their payload lengths; extension storage additionally contains a type byte. These sizes are properties of the audited build, not portable claims about every C++ ABI. [S09] [S12] [S13]

The distinction motivating the audit is between the backing chunk and the region granted to one object. Adjacent object bytes, metadata, alignment padding, and unused capacity may lie in accessible storage without belonging to that grant.

### 5.2 Clear versus destruction

The upstream chunk_list::clear routine frees chunks until one remains, retains that chunk, resets its free capacity, and resets its allocation cursor. A clear operation can therefore invalidate old logical allocations while retaining some physically allocated storage. The existence of clear is directly visible in the archived upstream source at lines 133–149. [S24]

The harness does not clear a zone and continue to use its former objects. It packs the parsed result and lets ownership clean up afterward. Final destruction releases backing chunks through ordinary deallocation; this is a different lifetime event from resetting an arena while keeping its bytes. [S05] [S24] [S25]

The upstream zone also has finalizer machinery, generic allocate<T>, and a construction-failure rollback. The inspected raw-object unpack path does not exercise arbitrary constructor/finalizer clients. In the proof, zone_at fixes finalizer bookkeeping pointers to zero. This is evidence of a specialized state space, not a theorem about all generic zone clients. [S14] [S24] [S26]

### 5.3 Reallocation that really occurs

The output sbuffer uses standard ::realloc. Standard allocation/free/reallocation contracts occur in the proof assembly. It would be false to say that reallocation is absent from this workload or uniformly ignored. [S21] [S27]

The absent operations are the specific custom-zone scenarios in which a suballocation shrinks in place or moves while its old region remains inside a live pool. Those must not be conflated with sbuffer growth through standard realloc.

## 6. Positive proof evidence

| Property | Inspected mechanism | What it supports | Boundary of the inference |
| --- | --- | --- | --- |
| Allocation fit and alignment | zalloc8_fits_ok, zalloc1_fits_ok, zalloc_fresh_ok in Unp/Steps.v, lines 150–188 | Requested size fits; returned address and advanced pointer are related; appropriate alignment and zone validity are preserved | Under the stated zone/preallocation premises |
| Non-overlap | in_alloc_fresh_disj and zalloc8_fresh/zalloc1_fresh/zalloc_fresh_fresh, lines 208–244 | New granted ranges are disjoint from relevant existing ranges | Does not cover unmodeled custom APIs |
| Requested-size region construction | new_region and g4_apply in Unp/G4.v; g4_sound | The checker introduces a region of the actual requested size and transfers permissions | Requires the soundness/instantiation chain, not only finding a definition |
| Payload allocation size | size_cell and G2B construction checks | Stored payload length is related to allocated storage; extensions account for the type byte | Construction evidence is distinct from a universal historical theorem |
| Aggregate layout | G1 size arithmetic; G3 NEWSLOT | 24-byte object slots and array/map size relationships are bounded by their containers | Build-specific layout; not every C++ subobject rule |
| Traversal and field access | levels_ok, pelem_tree, PkPeek width/offset rules | Traversal selects actual children; selected fields have justified offsets and widths | Does not certify arbitrary client pointer arithmetic |
| Concrete instantiation | Glue/TopHypsSrc.v | Connects the local checker and runtime specifications to the source proof assembly | Not a full independent replay |

The relevant paths are recorded under [S10]–[S13], [S17], [S20], [S21], and [S30].

### 6.1 Allocation geometry is explicit

For example, zalloc8_fits_ok relates the returned address r, requested size size, and successor zone:

    r mod 8 = 0
    z_ptr(z) <= r
    r + size = z_ptr(successor)
    z_ptr(successor) <= current_chunk_end

Freshness lemmas then establish separation from preexisting permitted ranges. These are useful internal allocator facts that are not obtained merely from ASan treating the whole chunk as accessible. [S10]

In G4, successful paths install new_region SZ and attach pointer, fit, and alignment facts. The allocator boundaries are therefore not uniformly erased by the proof. [S11]

### 6.2 Construction is stronger than mere chunk membership

G2B uses size_cell to connect the length field to the requested region before constructing a completed object. G3's NEWSLOT bounds the next 24-byte slot within its aggregate allocation. During unpacking, completed_ok also carries body-range and separation facts. [S12] [S20] [S30]

These observations rule out the simplistic inference that a payload with an arbitrary enlarged length is accepted at construction merely because the whole chunk is readable.

### 6.3 Concrete access checks

The packer checks selected field offsets and access widths according to object tags. The completed packing state also retains tree structure, vector contents, concrete object layouts, and logical indices. Thus the reasoning is richer than an outer-chunk test even in phases whose aggregate predicates are coarser. [S16] [S17]

The instruction-level region checks can reject a derived access whose destination is accessible elsewhere. To turn that local fact into a global provenance theorem, one must additionally show that the chosen abstract region remains connected to the intended originating allocation across all pointer transformations and abstraction changes. This report does not claim to have completed that argument. [S19]

## 7. The remaining abstraction question

### 7.1 What the zone predicates remember

in_zone says that the accessed interval fits within one backing chunk. in_alloc is stronger for the current chunk: it requires the interval to lie in its allocated prefix. For older chunks, the abstraction uses chunk extents, which can include unused tail space. Neither predicate alone maps an address to its original allocation request. [S09]

tree_wf uses in_zone and readability for string/binary payloads. Its relevant shape is:

    bounded_length(n)
    and (p = 0 implies n = 0)
    and (p != 0 implies in_zone(z, p, n) and readable(m, p, n))

A completed tree can therefore be described without an explicit complete history of all requests. The packing client's larger predicate adds other information; tree_wf is not the whole state invariant. [S15] [S16]

### 7.2 The precise predicate countermodel

Consider an abstract zone whose only chunk has 8192 data bytes beginning at nonzero address b, and whose current bump pointer is b+16. Let 32 bytes starting at b be readable. The string object OStr(b,32) satisfies the relevant tree_wf length, chunk-containment, and readability clauses, even though its extent exceeds the current allocated prefix.

This establishes only:

    tree_wf alone does not imply original-suballocation bounds
    or even current-prefix containment for that toy object.

It is an analytical counterexample to an implication between predicates. It was not supplied as a Rocq-checked countermodel, is not known to satisfy every combined invariant, and is not a reached state of the verified unpacker. The stronger construction checks may prevent it from arising. [S15]

### 7.3 What remains unestablished

An end-to-end argument would need to link each relevant access to the construction grant, carry that association through the completed-tree transition, justify every packer read/copy, and retain ownership until the last use. The monotone zone lifecycle may admit a relatively simple proof with no explicit generation tags. No result here establishes that such a theorem is impossible; the review has not extracted it from the full development. [S18] [S21] [S29]

## 8. Coverage matrix for the earlier checklist

The original numbering is retained: 1–17 were the supplied checklist; 18–20 are its additional categories. The checklist is an audit aid, not a claim that all its operations exist in this allocator.

| # | Desired property / scenario | Classification and evidence |
| ---: | --- | --- |
| 1 | Suballocation overflow/underflow | **Positive local evidence; general property not established.** Requested-size regions, fit/freshness, slots and payload lengths are checked. A universal original-allocation trace theorem was not extracted. |
| 2 | Use after internal per-object free | **Outside exercised interface/history.** Zone subobjects are not individually freed before packing. Ordinary chunk teardown is present. |
| 3 | Custom per-object double free | **Outside exercised interface/history.** Do not turn this into a claim that standard frees are omitted. |
| 4 | Use after clear/reset | **Outside harness.** Clear is an actual upstream operation, but clear followed by retained-object use is absent. |
| 5 | Access after custom shrink | **Outside zone usage.** No exercised zone shrink operation was identified. |
| 6 | Access after moving custom realloc | **Outside zone usage.** Standard sbuffer realloc is a separate present operation. |
| 7 | Stale pointer after address reuse | **Outside retained-reference history; general theorem not established.** Driver repetition does not retain old zone pointers. |
| 8 | Stale free releases a newer occupant | **Outside exercised per-object release usage.** The generic recycling-pool history is not this client. |
| 9 | Invalid free / wrong pool / wrong size or family | **Outside exercised custom-free usage.** Concrete backing-block ownership is nevertheless modeled. |
| 10 | Other bulk invalidation | **Outside harness.** Checkpoint, transaction, cache and slab histories should not be invented for this path. |
| 11 | Allocator implementation defects | **Mixed.** Fit, alignment, freshness and bookkeeping have positive proofs; free-list and custom-resize defects presuppose different APIs. |
| 12 | Logical leaks / reclamation | **No exported general guarantee.** Cleanup is modeled and leak detection is disabled. An intended bulk-retention policy is not itself a leak. |
| 13 | Redzone jumping | **Positive local region evidence; general provenance not established.** Addressability alone is weaker than origin-sensitive permission. |
| 14 | Intra-object field overflow | **Selected checks present; general source-subobject theorem not established.** Tag-specific field widths and offsets receive attention. |
| 15 | Logical length versus capacity | **Positive local evidence.** Element lists/indices and payload construction lengths are used, beyond malloc capacity alone. |
| 16 | Object lifetime ends before storage | **No general C++ lifetime theorem established.** Generic construction/finalizers are outside the specialized path. |
| 17 | Uninstrumented accesses | **Instrumentation boundary, not automatic proof exclusion.** Reached driver/runtime instructions can still be modeled and justified. |
| 18 | Uninitialized / residual data / clearing | **No general guarantee established.** Readability is not a history of current-object initialization or an information-flow property. |
| 19 | Alignment and size arithmetic | **Positive inspected evidence, configuration-limited detection.** Relevant calculations are proved; not every arithmetic sanitizer group is enabled. |
| 20 | Data races | **Outside model.** The semantics is single-threaded. |

## 9. Build, model, and interpretation gotchas

- **Sanitizer configuration is fixed.** ASan reports abort silently; allocation failure can return null; leak detection is disabled; arbitrary ASAN_OPTIONS changes are not part of the same artifact. [S03] [S07]
- **UBSan is a selected configuration.** The recorded flags are -fsanitize=undefined -fno-sanitize-recover=all -fsanitize-trap=all -fno-sanitize=function. Enabled groups include alignment, array-bounds, object-size, pointer-overflow and signed-overflow checks. Function, vptr, unsigned-integer-overflow, implicit-conversion, local-bounds, float-divide-by-zero and nullability are not enabled in that recorded configuration. Local proofs can still establish facts beyond those checks. [S07]
- **Uninstrumented does not mean omitted.** The driver and runtime components lack sanitizer checks, but reached machine code remains in the executable being verified. Inspect contracts rather than equating instrumentation coverage with proof coverage. [S07] [S21]
- **Binary and source contracts differ.** The result concerns exact executable images, not a complete C++ abstract machine or a certified compiler translation. Source provenance explains the intended code, but a machine theorem does not automatically settle every provenance, lifetime, dynamic-type, or source undefined-behavior question. [S04] [S08]
- **The model has its own boundary.** The recorded LPS version includes one thread, no execution of signal handlers, an 8 MiB modeled stack, restricted path arguments and a simplified file model. Model-to-Linux fidelity is a separate issue from allocator-aware object safety. [S08] [S32]
- **Subsequent disclosures matter, but do not change this snapshot.** Later release notes identify a stack-window discrepancy affecting initial msgpack agreement proofs and an unproved memory-budget premise. Those disclosures are separate from an observed allocator violation. This report does not re-audit later proofs.
- **A fixed harness can be safe by construction.** Excluding free/reset/reuse histories through control flow can establish temporal safety for that workload without generation tags. Absence of a generation field is not evidence of a loophole.
- **The checklist exceeds CMASan's scope.** Its broader lifecycle, provenance, initialization, leak and allocator-internal categories should not all be attributed to the CMASan paper as an exhaustive taxonomy. [E03]

### Publication-safe wording

> The msgpack-c proof contains explicit suballocation reasoning. The remaining issue is the relationship between its exported harness-specific guarantee, the stronger local invariants, and an end-to-end contract for logical allocation identity and lifetime.

Avoid “ASan misses it, therefore the proof misses it,” “only the outer malloc is checked,” and “a 32-byte read from a 16-byte allocation is reachable.” None follows from the evidence.

## 10. Portable source archive and evidence map

The archive contains six primary files already fetched during the completed review. [SOURCES.json](../source-snapshots/msgpack-c/SOURCES.json) records each pinned URL, repository path, commit, capture date, byte count and local SHA-256.

| Archived file | Role |
| --- | --- |
| [Project README](../source-snapshots/msgpack-c/oss-verify-proofs/98e995d4/projects/msgpack-c/README.md) | Initial inventory, source pin, proof counts |
| [Harness source](../source-snapshots/msgpack-c/oss-verify-proofs/98e995d4/projects/msgpack-c/unpack_pack_fuzzer/source/unpack_pack_fuzzer.cpp) | Actual unpack/pack client sequence |
| [Steps.v](../source-snapshots/msgpack-c/oss-verify-proofs/98e995d4/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Steps.v) | Fit, alignment, freshness, separation |
| [G4.v](../source-snapshots/msgpack-c/oss-verify-proofs/98e995d4/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/G4.v) | Requested-size region construction |
| [Inv.v](../source-snapshots/msgpack-c/oss-verify-proofs/98e995d4/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Inv.v) | Completed-tree predicates and their exact strength |
| [cpp11_zone.hpp](../source-snapshots/msgpack-c/msgpack-c/a5250ecb/include/msgpack/v1/detail/cpp11_zone.hpp) | Upstream chunk allocation, clear, destruction and generic machinery |

These are selected UTF-8 text snapshots, not a complete checkout, executable archive, or replay package. Their local hashes identify the captured text; they do not certify an executable or proof result. The full earlier dossier preserves additional pinned paths and the original reasoning chain.

### Key source navigation

| IDs | Files / purpose |
| --- | --- |
| [S01], [S02], [S04], [S06] | Harness status, statements, supporting theorem exports, readable theorem shape/budgets |
| [S03], [S07], [S22], [S23] | Provenance, build configuration, checking procedure, release pins |
| [S09], [S10], [S11], [S12], [S13] | Model, allocator transitions, requested-size regions, payload checks, aggregate arithmetic |
| [S14], [S15], [S16] | Concrete layouts, tree invariants, packing state |
| [S17], [S18], [S19], [S20], [S21] | Field reads, copy contracts, instruction regions, completed-body facts, instantiation |
| [S24], [S25], [S26], [S27], [S28], [S29], [S30] | Upstream allocation/lifecycle, fresh zone, visitor, sbuffer realloc, teardown, copy-source validity, NEWSLOT |
| [S08], [S32], [E01], [E02], [E03] | Model scope and sanitizer background |

## 11. Outstanding facts and follow-up obligations

The handoff does not supply an independently checked full theorem dependency graph, a replay log, executable bytes, or a new binary hash computation. It does not settle whether a stronger origin-sensitive safety theorem is derivable from the entire development.

To advance the existing investigation, the useful proof obligation is to carry original grant information through allocation, construction, completed-tree abstraction, every packer access, and teardown. A separate broader client would be needed for clear and reuse. Any future claim of a reached defect must provide an admitted input and a trace satisfying the theorem's premises, rather than only a weak intermediate predicate.

The exact compiler and static-ASan build details beyond those reproduced here remain in the linked provenance. A complete initial-snapshot replay should use the pinned release instructions and retain its own commands, hashes, logs and assumption audit. A replay would verify derivability under that environment; specification adequacy still requires the analysis above.

## Pinned references

[S01]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/unpack_pack_fuzzer/README.md#L4-L56
[S02]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/unpack_pack_fuzzer/Statements.v#L3-L121
[S03]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/provenance/PROVENANCE.md#L1
[S04]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Theorems.v#L17-L48
[S05]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/unpack_pack_fuzzer/source/unpack_pack_fuzzer.cpp#L7-L27
[S06]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/theories/Shapes.v#L54-L204
[S07]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/building.md#L71-L179
[S08]: https://github.com/theorem-labs/rocq-linux-process-semantics/blob/f1006fe8178338a499b5e5c41be83006c4edd058/SCOPE.md#L9-L82
[S09]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Model.v#L9-L249
[S10]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Steps.v#L135-L244
[S11]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/G4.v#L136-L183
[S12]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/G2B.v#L29-L155
[S13]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/G1.v#L81-L106
[S14]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Layout.v#L1-L90
[S15]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Inv.v#L13-L27
[S16]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/PkOps.v#L129-L190
[S17]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/PkPeek.v#L111-L145
[S18]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/PkBody.v#L36-L121
[S19]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/FX/Step.v#L914-L938
[S20]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Tree.v#L20-L49
[S21]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Glue/TopHypsSrc.v#L291-L488
[S22]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/checking.md#L10-L101
[S23]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/release.yaml#L1-L20
[S24]: https://github.com/msgpack/msgpack-c/blob/a5250ecbcae1d34346c7445345774b0abbd651bc/include/msgpack/v1/detail/cpp11_zone.hpp#L111-L355
[S25]: https://github.com/msgpack/msgpack-c/blob/a5250ecbcae1d34346c7445345774b0abbd651bc/include/msgpack/v3/unpack.hpp#L23-L71
[S26]: https://github.com/msgpack/msgpack-c/blob/a5250ecbcae1d34346c7445345774b0abbd651bc/include/msgpack/v2/create_object_visitor.hpp#L109-L235
[S27]: https://github.com/msgpack/msgpack-c/blob/a5250ecbcae1d34346c7445345774b0abbd651bc/include/msgpack/v1/sbuffer.hpp#L27-L135
[S28]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Td.v#L24-L106
[S29]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/PkA/PkBodySrc.v#L29-L68
[S30]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/G3.v#L315-L340
[S31]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/README.md#L1-L20
[S32]: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/semantics.md#L3-L77
[E01]: https://github.com/google/sanitizers/wiki/AddressSanitizerAlgorithm
[E02]: https://www.usenix.org/system/files/conference/atc12/atc12-final39.pdf
[E03]: https://yonghwi-kwon.github.io/data/cmasan_sp25.pdf
[E04]: https://clang.llvm.org/docs/MemorySanitizer.html
[E05]: https://clang.llvm.org/docs/UndefinedBehaviorSanitizer.html
[E06]: https://clang.llvm.org/docs/ThreadSanitizer.html
[E07]: https://github.com/google/sanitizers/wiki/AddressSanitizerContainerOverflow
[E08]: https://clang.llvm.org/docs/AddressSanitizer.html
