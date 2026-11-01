# Context, theorem scope, and allocator-property framework

Prepared on 29 October 2026 for the main paper (up to three pages) and its portable evidence handoff. This document consolidates the investigation already performed; it is not a new comprehensive proof audit. Source identifiers refer to [source-register.md](source-register.md). The corpus counts come from the initial pinned snapshot, not the latest repository head. The revised paper uses shorter sentences, explains theorem scope explicitly, and introduces a concrete allocator example before the formal contract.

## 1. Historical context and the contribution being discussed

Anthropic's announcement, dated 22 October 2026, reports a collaboration with Theorem in which Claude constructed Rocq proofs about compiled RISC-V binaries for 239 OSS-Fuzz entry points across 123 open-source libraries. The achievement is substantial: executable harnesses and sanitizer checks supply a tractable, broadly applicable specification, and the proof assistant checks the resulting arguments. The paper should credit both the scale of the proof construction and the practical value of eliminating covered crashes for all modeled inputs. [SRC01]

The timing can be stated precisely. The PHP Foundation published its account of the PHP2Shell security release on 21 October 2026. Anthropic's announcement followed the next day. PHP2Shell identifiers and a demonstration video had already circulated on 20 October, so “one day after PHP's coordinated disclosure and security release” is preferable to “one day after PHP2Shell was first disclosed” or “discovered.” [SRC01, SRC02]

The PHP Foundation describes two problems: out-of-memory handling that can leave partially initialized internal state, and stale state that can refer to a prior request's released storage. These provide relevant motivation for lifetime and failure-path specifications. They are not evidence that a released Theorem proof contains either PHP bug. The reviewed proof corpus did not contain a proved PHP target. Do not imply that the verification announcement claimed to have eliminated PHP2Shell. [SRC02; prior inventory retained in the parent project]

## 2. What our corpus numbers mean

The audit snapshot is:

- Repository: theorem-labs/oss-verify-proofs.
- Commit: 98e995d4daced70a0a4aa2c810854b88720735f1.
- Commit time: 23 October 2026, 03:53:06 UTC.
- Parent: 8f5f46768858af236a4270f9628e6beed9aa0e72, the target of v2026.10.0.
- The audit commit changes CI job organization; it is one commit after the initial tag.
- Initial tag publication: 22 October 2026, 21:11:04 UTC.

The initial snapshot has 25 projects, 60 proved harnesses, and 138 agreement statements: 55 ASan, 34 UBSan, and 49 combined ASan+UBSan. These numbers were independently recomputed from the pinned README table. A sanitizer variant is a separate agreement statement; it is not a separate project, source version, or entry point. These public counts differ from the broader reported 123-library, 239-entry-point experiment. [SRC03, SRC06, SRC07]

The two CSV inventories enumerate the entire initial public corpus:

- [project-inventory.csv](project-inventory.csv): 25 rows with per-project counts and review depth.
- [harness-inventory.csv](harness-inventory.csv): 60 rows with the exact proved sanitizer variants.

### Review depth and the restored broader survey

The earlier compact handoff displayed the four detailed reviews as though they were the full survey. It also reduced earlier findings to sparse leads and omitted Varnish. The user corrected that undercount. The restored 12-project register preserves the earlier allocator names, harness exclusions, configuration qualifications, and Varnish correction. This is a correction to the presentation of completed work, not a new allocator census.

The review-depth categories are deliberately separate from the corpus counts:

| Category | Projects | Interpretation |
| --- | --- | --- |
| Detailed selected-path proof review | msgpack-c, OpenSSL, pupnp, simdjson | Selected allocator invariants, contracts, harness behavior and theorem scope were inspected. This is not a line-by-line review of every proof in these libraries or a new kernel replay. |
| Direct source-presence check | Boost.JSON | The pinned monotonic allocator source and harness were examined. Its execution by the proved workload and its Rocq allocator contracts were not established. The earlier survey also identified value_stack temporary storage. |
| Inherited prior source/configuration findings | libpcap, Leptonica, Mbed TLS, zstd, Speex, tinyobjloader, Varnish | Earlier findings were recovered from prior conversations. They include reported exclusions and a Varnish correction. Their original primary URLs were not recovered, and they were not independently rechecked for this handoff. |
| Not assessed | Remaining 13 projects | No custom-allocator assessment is recorded here. |

**Proof** means detailed selected-path source review of proof contracts, not a new kernel replay. **Source** means the narrower direct Boost.JSON source-presence check. **Prior** means inherited source/configuration findings recovered from earlier conversations; their original primary URLs were not recovered. The Prior label preserves both positive findings and reported exclusions. It does not certify fresh source confirmation or an exercised custom allocator.

In the table, **H/A** means proved harnesses / sanitizer-agreement statements for the whole project.

| Project | Review status | Project-wide H/A | Allocator finding and configuration boundary |
| --- | --- | ---: | --- |
| msgpack-c | Proof | 1 / 3 | C++ zone allocation; selected unpack/pack proof paths reviewed in detail. |
| simdjson | Proof | 10 / 24 | DOM string arenas and On-Demand output regions; selected layout, traversal and decoder proofs reviewed. |
| OpenSSL | Proof | 7 / 12 | BN_CTX temporary pools; detailed review of bndiv and bignum. |
| pupnp | Proof | 1 / 2 | FreeList node caching in FuzzHttp; backing/cache ownership and selected contracts reviewed. |
| Boost.JSON | Source | 1 / 3 | Pinned monotonic_resource source checked directly. Earlier survey also identified value_stack storage; optional resource use by fuzz_parse is unestablished. |
| libpcap | Prior | 1 / 3 | Earlier survey identified newchunk/freechunks, reported outside fuzz_pcap. |
| Leptonica | Prior | 11 / 29 | Earlier survey identified pmsCreate/pmsCustomAlloc/pmsCustomDealloc; optional manager reported not installed by published harnesses. |
| Mbed TLS | Prior | 1 / 1 | Earlier survey identified memory_buffer_alloc.c, reported not initialized by fuzz_pkcs7. |
| zstd | Prior | 4 / 6 | Earlier survey identified ZSTD_cwksp with ASan poisoning/redzones; relevance to the four proved targets remains unestablished. |
| Speex | Prior | 1 / 2 | Earlier survey identified configuration-dependent PUSH/ALLOC scratch storage; active released-binary selection unconfirmed. |
| tinyobjloader | Prior | 1 / 2 | Earlier survey reported 64-KiB bump blocks and a used cursor, and asserted use by fuzz_tobj_c; not freshly confirmed here. |
| Varnish | Prior | 1 / 3 | Earlier WS_Init/1-KiB workspace interpretation was corrected: the verified build was reported to use ENABLE_WORKSPACE_EMULATOR and malloc/free. |


The 12 tracked projects account for **40 harnesses and 90 agreement results** in the pinned public inventory. The four detailed projects account for **19 harnesses and 41 results** within that broader set. The whole initial corpus remains **25 projects, 60 harnesses and 138 agreement results**. These are project-level inventory sums, not counts of audited allocator paths, verified custom-allocator workloads, or discovered bugs. The initial corpus counts and project totals come from the pinned README [SRC03]. The detailed review evidence is in the four project reports; the direct Boost.JSON check is SRC12. The restored prior findings are SRC13 and are explained in the [additional-projects report](reports/additional-projects.md).

The four detailed projects therefore remain a subset of the broader survey. In particular, the OpenSSL BN_CTX review concerns bignum and bndiv, and the simdjson review inspects selected shared string-arena and decoder invariants rather than every line in ten proofs. Section 7 summarizes those four detailed reviews without replacing the twelve-project register.

A defensible empirical sentence is: “Our broader survey tracks twelve projects. Four received detailed selected-path proof reviews, one received an additional direct source-presence check, and seven retain earlier source/configuration findings.” Neither “only four projects have custom allocators” nor “all twelve proved workloads exercise an unannotated custom allocator” follows.

Boost.JSON's Boost superproject revision is 4daa5786d7c5dad39df0429cb078165b3134a06f and its libs/json submodule revision is e93cf9c254619142b9f3cfa9022b93fb1d4e5edb. Its fuzz_parse harness calls the default parse(sv, ec); execution of optional monotonic/static resources was not established. The recovered value_stack observation remains a narrower inherited finding until its compiled-path and proof correspondence is recovered. [SRC12, SRC13]

The CSV columns allocator_source_presence, allocator_exercised_in_proved_configuration, detailed_proof_review, and candidate_for_followup keep four different questions separate. “Confirmed selected paths” in a project row does not apply to every harness in that project. Harness rows identify the inspected OpenSSL paths and simdjson's non-arena minify/UTF-8 targets separately. The inherited rows preserve source/configuration findings, exclusions and corrections. They are not completed proof audits or missing-guarantee verdicts.

## 3. The published guarantee and its premises

At the audited revision, the public results are agreement theorems between a plain binary and a sanitizer-instrumented binary. Subject to the statement's premises, they establish modeled error freedom and equality of observable behavior. Errors include the relevant sanitizer reports, failed assertions or aborts, modeled faults, and unmodeled execution steps. Observable behavior concerns input/output bytes, exit status, and final file contents. The statement quantifies over modeled process inputs and launches; it is not a report about finitely many executions. [SRC03, SRC04]

The main qualifications are:

| Dimension | Audited scope or premise | Consequence for interpretation |
|---|---|---|
| Machine and OS | LPS model of a Linux process executing a static 64-bit RISC-V binary | Transfer to a real deployment depends on model adequacy. |
| Build | Specific Clang 20.1.8 builds linked against musl; the msgpack provenance records the RV64G compiler target, whereas LPS supports RV64GC semantics | The claim does not automatically transfer to source code, x86/ARM builds, another compiler, or dynamic linking. Compiler target and supported model ISA are distinct. |
| Threads | One thread, no scheduler or shared-memory interleaving; fork-like behavior describes the parent only | No concurrent-client guarantee follows. |
| Signals and external activity | No execution of signal handlers; assumptions restrict other processes and external modification | Relevant asynchronous behaviors may fall outside the model. |
| Input size | The announcement says inputs under 64 MB; the recovered msgpack and simdjson dossiers record a driver that rejects files of 64 MiB or more | The bound applies to the complete admitted file, including a header before the harness payload. Packaging this handoff did not re-audit the driver; its exact interpretation is inherited from the dossiers. |
| Plain-build budget | 2 GiB for ASan/combined agreement and 16 GiB for UBSan agreement | Inputs on which the plain build violates the budget premise are excluded. |
| Target budget | The recovered msgpack and simdjson dossiers record a 512 GiB sanitizer-target budget; LPS also documents source 16 GiB and target 512 GiB defaults | The plain-budget premise and target allowance play different roles. Concrete Shapes.v statements remain authoritative; do not silently extend an inspected budget to every statement form. |
| Allocation refusal | Most initial statements use alloc-forced-only | They are not automatically proofs of robustness to arbitrary injected allocation failures. |
| Reachability | Particular compiled fuzz harnesses | Uncalled APIs, different calling sequences, and arbitrary clients are outside the established harness behavior. |
| Termination | No halts statement is proved in the initial snapshot | Agreement and error freedom do not exclude nontermination. This fact must be dated because later releases add halts proofs. |

The 64 MiB driver threshold is an admitted-file bound, not the program's total allocation budget. The statement can still quantify over process inputs whose files are rejected before the harness executes. The 2/16 GiB premises are different restrictions. Treating them as interchangeable materially changes the theorem. The exact driver and target-budget observations above come from the recovered dossiers [SRC09, SRC10].

Anthropic acknowledges ASan incompleteness, platform mismatch, incomplete entry-point coverage, and possible caller misuse in the main announcement. It does not specifically discuss custom allocators, suballocation boundaries, or internal object lifetimes there. Our analysis explains how custom allocation makes the general ASan limitation relevant to these projects. Do not describe that specific allocator analysis as an acknowledgment by Anthropic. [SRC01; C012]

### Model assumptions versus specification omissions

Two questions must remain separate:

1. Does the machine/OS model adequately represent the deployed execution?
2. Does the property stated over that model express the intended allocator contract?

Even an exact machine model would not automatically give a raw address an application-level lifetime or allocation identity. Conversely, a specification that expresses lifetime safety still needs an adequate model to justify deployment claims.

The generic observation that ASan can miss an error is not sufficient to prove that a particular Rocq development fails to exclude it. Auxiliary lemmas may establish stronger facts than the sanitizer-derived final theorem explicitly advertises. The project audits therefore inspect relevant predicates and contracts rather than infer all coverage from the theorem's title.

## 4. CMASan: what we cite it for

Junwha Hong, Wonil Jang, Mijung Kim, Lei Yu, Yonghwi Kwon, and Yuseok Jeon. “CMASan: Custom Memory Allocator-aware Address Sanitizer.” IEEE Symposium on Security and Privacy, 2025, pages 740–757. DOI: 10.1109/SP61157.2025.00110. [SRC08]

CMASan supports the core claim that ordinary ASan's standard-allocation view can miss errors in objects managed by custom allocators. It discusses custom allocation operations, including allocation, reallocation, free, and bulk clear, and motivates allocator-aware handling of spatial and temporal errors. It reports 19 previously unknown custom-allocator memory bugs missed by ASan. [SRC08]

The desired-property framework below is our synthesis, informed by CMASan and the project's allocator audits. The working taxonomy evolved: the earlier input had 17 numbered questions, and the detailed dossiers preserved those numbers while adding three initially unnumbered categories. This handoff uses P01–P20 to match property-matrix.csv. It is not a claim that CMASan gives an exhaustive 17- or 20-property taxonomy, proves every property below, or eliminates all identity/provenance problems. If the paper says “CMASan gives an exhaustive list of all allocator memory-safety properties,” revise that attribution.

## 5. The central example and the semantic distinction

Suppose a library obtains one backing block and hands out two logical objects within it. If the first occupies bytes [0, 50) and the second [50, 100), an access through the first object's reference to byte 55 crosses its logical boundary while remaining in the same standard allocation. Without appropriate allocator annotations or a stronger property, ordinary ASan may see an accessible address.

The temporal case is independent of crossing a boundary. An internal free, pool return, arena reset, or BN_CTX_end can end an object's logical lifetime while leaving its backing bytes mapped and accessible. Under a contract that revokes references on release, reusing those bytes for another object does not restore the old authorization. This is an object/lease-identity issue, not merely an address-range issue.

These are specification-separating examples. They do not exhibit a reachable bug in any audited harness.

### A useful abstract contract

For exposition, represent a logical allocation by a ghost record

    object = (identity, region, base, current_extent, generation, live)

and associate a client reference with the identity and generation it is authorized to use. A load or store of k bytes beginning at address a should require, among other API-specific obligations:

- the relevant region and object are live;
- the reference denotes the current object generation;
- the accessed interval is contained in the object's current extent;
- the address/length arithmetic does not wrap;
- permissions, alignment, and ownership conditions required by the operation hold.

The identity and generation can be ghost state in a proof. The implementation need not literally store a fat pointer. An alternative ownership or capability semantics may express the same contract.

This contract is intentionally stronger than mere membership of a backing block. It also requires the proof to state how machine-level pointer operations correspond to logical references. Writing down an existential current object containing an address is insufficient: it could associate a stale reference with whichever new object happens to occupy those bytes.

## 6. Desired allocator properties and applicable boundaries

The following checklist records distinct obligations rather than a uniform verdict for every allocator. Some operations do not exist in a given API and should be marked “not applicable.” Others exist but are absent from the harness; that is a coverage boundary, not evidence of a failing execution.

| Property | Desired obligation | Important qualification |
|---|---|---|
| P01. Suballocation bounds | Each access stays within its intended logical object's current extent, including underflow/overflow checks. | Backing-pool membership alone is weaker. Include access into padding, unused space, metadata, or a sibling. |
| P02. Internal use after free | Access requires an active allocation or lease after custom release operations. | Backing bytes can remain allocated. A monotonic arena may have no per-object free. |
| P03. Double free or return | An object cannot be released twice in violation of the API contract. | Idempotent operations have different semantics. |
| P04. Clear, reset, and rewind | Bulk invalidation affects exactly the objects designated by the operation. | Reset may invalidate all objects; rewind may invalidate a suffix or scope. |
| P05. Shrinking reallocation | Access bounds and aliases follow the reduced authorized extent. | The base can remain unchanged while formerly valid bytes become invalid. |
| P06. Moving reallocation | Success transfers contents and ownership as specified and invalidates old references. | Old storage may remain mapped; failure semantics require a separate obligation. |
| P07. Stale references after reuse | A new object at the same address does not revive references to the previous identity/generation. | A map of currently live addresses alone is insufficient. |
| P08. Stale free after reuse | An old reference cannot release a newer object occupying the same address. | Requires provenance or an equivalent ownership argument. |
| P09. Wrong owner, pool, or pointer | Release obeys the allocator's requirements for owner, pool, base/interior pointer, size, and generation. | Null, sized-free, and interior-pointer rules are API-specific. |
| P10. Other invalidation events | Frame exit, parser reuse, replacement, or container invalidation ends the appropriate leases. | BN_CTX_end and retained parser views motivate distinct API-level events. |
| P11. Allocator implementation correctness | Allocation fit, sibling separation, metadata integrity, ownership accounting, and failure atomicity hold. | Parent pools overlap child allocations by design. Cached storage can remain allocator-owned after client release. |
| P12. Leaks and retained resources | Eventual release or bounded retained capacity is established when specified. | Retained capacity is not automatically a leak; leak freedom is a separate property. |
| P13. Jumping over redzones | Access is checked against object identity/extent even if its address lands in another accessible region. | Redzones detect many local overruns, not every arbitrary out-of-object pointer computation. |
| P14. Intra-object and subobject bounds | Field and array-member accesses obey their intended bounds inside a larger object. | Staying inside the enclosing allocation need not satisfy source subobject rules. |
| P15. Logical length versus capacity | Client element reads respect logical length; construction and scratch writes must stay within the regions authorized for those operations. | Payload length, record extent, scratch footprint, and backing capacity are distinct bounds. |
| P16. Source-language lifetime and provenance | The desired C/C++ object lifetime, type, and pointer rules are stated if claimed. | Raw-address safety in a binary model does not automatically imply every source-language rule. |
| P17. Uninstrumented accesses | Reached assembly or uninstrumented code is covered by an adequate semantic property. | Such code can be included in the machine proof while having fewer sanitizer checks; uninstrumented does not mean omitted. |
| P18. Initialization and confidentiality | Reads use values initialized for the current object; sensitive residual data is cleared where required. | Initialization and confidentiality are distinct. Ordinary ASan does not generally establish either. |
| P19. Alignment and arithmetic | Alignment, size computations, offsets, and address arithmetic meet the intended constraints without harmful wraparound. | Requested size, reserved capacity, and current extent must be distinguished. |
| P20. Races and concurrent lifetimes | Allocation, return, reset, and client access obey the required synchronization and lifetime rules across threads. | The audited single-threaded model does not establish these properties. |

### Separation with nested ownership

An allocator owns a backing block while distributing client rights to subranges. A useful invariant distinguishes:

- backing storage owned by the allocator;
- logical objects and their payload extents;
- allocator metadata;
- active client permissions;
- cached or released objects whose bytes remain owned by the allocator.

The parent allocation is not a competing client object. A nested arena can reserve part of a parent pool, then subdivide that reservation again. Spatial safety must respect this hierarchy and the API's permissions at each level.

### Bounds that change over time

A predicate that once established allocation fit does not, by itself, establish every later access against the original object's authorized extent. After shrinking, reset, reuse, or structural mutation, the proof must connect each access to the current relevant state. A proof that checks an offset against a logical array length can be strong evidence for that access; a completed-object predicate that retains only membership in a chunk can discard other needed facts.

### Lifetime without standard free

There are at least three different events:

1. The client loses permission to use an object.
2. The custom allocator makes its storage available for reuse.
3. The backing allocation is returned to the system allocator.

They may occur at different times. A theorem phrased only in terms of system allocation/free events does not automatically connect them. A detailed proof can connect them through ghost state, separation, ownership, or a suitable API contract; the audit question is whether it actually does so for the operations and clients under review.

## 7. What the four detailed reviews within the twelve-project survey support

Section 2 lists all twelve tracked projects and their different evidence levels. This section summarizes only the four detailed proof reviews. The project reports carry their concrete predicates and source excerpts.

| Project | Positive evidence already observed | Remaining boundary or missing general contract |
|---|---|---|
| msgpack-c | Zone allocation fit, selected object layouts, indices, alignment/freshness/non-overlap reasoning, and internal array/map bounds appear in the proofs. | Fresh-zone unpack/pack/destruction does not cover a general clear-and-reuse client protocol. Some completed-object predicates preserve chunk membership/readability rather than the original suballocation extent. No universal access-to-the-original-live-allocation theorem was identified. |
| simdjson | String-arena record layout, headers/terminators, bounded decoder regions, and related structural invariants appear. | Retaining a view across a later parse/reuse is outside the audited harness scenario. Do not manufacture per-string free, wrong-pool free, or per-string realloc requirements for APIs that lack them. |
| OpenSSL | Selected BN_CTX proofs reason about frames, ranges/copies, temporary preservation, and underlying BIGNUM storage. The bignum development additionally uses live-prefix guards and nested-frame preservation. | In bndiv, valid_ref can remain true after BN_CTX_end expires the API lease. This specific reusable predicate is weaker than a current-lease condition; it is not a demonstrated reachable misuse, and it must not be generalized into “bignum has no lifetime reasoning.” |
| pupnp | FreeList invariants distinguish backing blocks from cached nodes; duplicate cached returns and cleanup ownership receive explicit treatment. | The inspected allocation contract requires an empty cache head, so it does not establish general cached-node reuse or generation-sensitive client lifetime safety. |

None of these observations supports “the proofs do not reason about custom allocators at all.” The supported criticism is that selected strong internal invariants coexist with scope restrictions, weaker reusable contracts, and end-to-end properties not established by this review.

No reachable custom-allocator violation accepted by the released proof has been established in this handoff. A compatible toy execution, an under-specified reusable contract, an absent harness operation, and a real reachable bug are four different kinds of evidence.

## 8. Subsequent releases and independent gotchas

These updates were already retrieved while preparing the paper; they are recorded to prevent an undated initial-snapshot statement from becoming misleading. [SRC06]

| Version | Publication recorded by GitHub API (UTC) | Relevant change |
|---|---|---|
| v2026.10.0 | 22 Oct 2026, 21:11:04 | Initial 138 agreement results, 60 harnesses, 25 projects. Notes later updated on 27 Oct. |
| v2026.10.1 | 28 Oct 2026, 09:50:17 | Notes are headed 27 Oct. 202 proved statements, including the first 64 halts proofs; 61 harnesses, 26 projects. |
| v2026.10.2 | 28 Oct 2026, 10:21:32 | Notes are headed 27 Oct. 336 proved statements, including two more halts results. No new binary or source tree; no published statement changes meaning according to the notes. |

### Memory-budget premise

The v2026.10.2 notes state that every proved agreement statement, and every proved halts statement except one, assumes the run stays within its memory budget. They say no theorem yet shows this premise for a released build, and explicitly apply the qualification to the earlier releases. This is a conditional theorem; the undischarged premise must not be silently erased. It does not prove that all theorems are vacuous.

### Allocation-layout precision

The updated v2026.10.0 notes identify 129 alloc-forced-only agreement statements. LPS can choose layouts a real Linux execution would not choose, and thus refuse a large request that Linux would grant. A program's response to this refusal can remove an input from the theorem's premise or conceal a behavioral difference in the modeled equivalence. The maintainers demonstrated the issue on test programs, not a released fuzz target. The proofs still check against their stated model.

### Stack window

The v2026.10.1 notes say the model provides 8 MiB below the initial stack pointer and places the entry image above it, whereas Linux counts the entry image within the total stack limit. The notes identify all three initial msgpack-c agreement proofs, two newly added msgpack halts proofs, and three glaze agreement proofs as depending on near-limit stack availability.

For msgpack-c the cited proof files use storage down to 8,384,512 bytes below the entry stack pointer. The maintainers report no input known to make the program consume that much stack; emulator tests with a much smaller stack were successful. The finding is a model-to-deployment gap, not a newly demonstrated msgpack input causing a crash.

### Scope of later-version conclusions

Later proof additions do not automatically refute the allocator-specification argument, but this handoff does not re-audit their internal invariants. Keep per-project conclusions tied to the inspected snapshot. In particular, “the initial release has no proved halts statement” must not become “the project has no termination proofs.”

## 9. Reuse guidance for the next session

Use the source register and immutable commit links when expanding the appendix. Preserve positive proof evidence beside each limitation. For any proposed stronger statement, identify whether it asserts:

- a limitation of the published theorem;
- a limitation of a specific helper predicate or reusable contract;
- an absent operation or client sequence in the harness;
- a verified fact about a reachable execution;
- or a hypothesis still requiring investigation.

The first three can support a specification-gap paper without the fourth. They should not be presented as the fourth. The remaining work should concentrate on the exact open proof obligations recorded in the project reports, rather than repeat the complete literature search or corpus census.


## 10. Security significance of the specification gap

The user requested a targeted check of whether custom-allocator blind spots can concern exploitable errors. The historical PHP example in [reports/security-impact.md](reports/security-impact.md) and C057 provides complementary exploit and detection evidence. Keep the shim-disabled condition and the separate experimental setups explicit. It supports the security relevance of the class; it is not a demonstrated error in the verified binaries. [SRC08, SRC14, SRC15]

The paper's broader argument is about specification adequacy: proving all encoded checks does not by itself establish an intended property that those checks fail to express. Supporting proof invariants may establish more, so their contribution must be considered independently.
