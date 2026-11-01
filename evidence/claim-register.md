# Claim register

Prepared 29 October 2026 from the completed investigation. There are 57 stable claim IDs. Read each claim together with its evidence label and qualifications. The companion CSV contains the same records.

Default proof revision: 98e995d4daced70a0a4aa2c810854b88720735f1. Live announcements and release notes are separately dated. An empty source-URL field can identify our proposed specification, our own work record, or an explicitly labeled inherited finding whose original primary-source URLs were not recovered. Inherited survey claims link the retained prior-conversation record (SRC13); that record is not a primary-source verification. Dossier source IDs remain local to their documents. Shared context source IDs are SRC01 onward.

## C001 — Anthropic and Theorem announced their verification effort on 22 October 2026, one day after the coordinated PHP2Shell disclosure and PHP security release.

**Evidence label:** published context.  
**Basis:** direct dates; inferred one-day relation.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Publisher dates and the PHP Foundation chronology establish the two dates.

**Qualifications / unresolved questions.** Leaks and a pre-announcement occurred on 20 October. Do not call 21 October the first discovery or first public awareness. The chronology does not establish that the verification project was a response to PHP2Shell.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://www.anthropic.com/research/formal-verification)
- [Primary source 2](https://thephp.foundation/blog/2026/10/21/todays-php-security-release-and-how-were-strengthening-php-security/)

## C002 — The announcement reports 239 fuzzing entry points across 123 open-source libraries.

**Evidence label:** published context.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The announcement-wide result is larger than the initial public proof subset.

**Qualifications / unresolved questions.** These are publisher-reported figures. The 123-library collection was not independently audited here; libraries and executable clients are different counting units.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://www.anthropic.com/research/formal-verification)

## C003 — At the audited initial snapshot, the public inventory contains 25 projects, 60 harnesses, and 138 agreement results: 55 ASan, 34 UBSan, and 49 combined.

**Evidence label:** published theorem inventory.  
**Basis:** direct inventory; arithmetic independently checked.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The retained README lists each proved harness/variant pair; the CSV tables reproduce its counts.

**Qualifications / unresolved questions.** Counts are for commit 98e995d4, not current HEAD. Variants are not separate upstream versions, and counts do not measure allocator review depth.

**Detailed record:** [project-inventory.csv](project-inventory.csv).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)

## C004 — The audit fixes commit 98e995d4 from 23 October 2026, immediately after the initial v2026.10.0 release tag.

**Evidence label:** published revision metadata.  
**Basis:** direct metadata.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Retained commit metadata gives parent 8f5f46768858af236a4270f9628e6beed9aa0e72 and a CI-only commit message.

**Qualifications / unresolved questions.** Do not call the audit SHA the release tag target. Subsequent release notes have mutable descriptions; their captured metadata is dated in this bundle.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/commit/98e995d4daced70a0a4aa2c810854b88720735f1)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/releases)

## C005 — The audited results concern fixed static RISC-V executables and a modeled Linux process, with single-threaded execution and musl builds.

**Evidence label:** published theorem/model scope.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** README, semantics documentation, and the pinned LPS scope specify the executable/model boundary.

**Qualifications / unresolved questions.** This is not a theorem about arbitrary x86/ARM deployments, dynamic glibc linking, or concurrent clients. RV64G compiler targets and RV64GC model support are separate facts.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/semantics.md)
- [Primary source 3](https://github.com/theorem-labs/rocq-linux-process-semantics/blob/f1006fe8178338a499b5e5c41be83006c4edd058/SCOPE.md)

## C006 — The inspected file-input wrappers reject files of 64 MiB or more before invoking the harness; the wrapper format includes a configuration prefix.

**Evidence label:** published statement; inherited dossier evidence.  
**Basis:** direct in prior source audit.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The msgpack and simdjson dossiers record the concrete file-input threshold and driver format in Statements.v. The announcement uses the shorthand 64 MB.

**Qualifications / unresolved questions.** This bounds accepted file inputs, not all heap usage. The theorem can also cover driver rejections. Do not silently treat the whole file limit as payload length after its header.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/unpack_pack_fuzzer/Statements.v)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_parser/Statements.v)

## C007 — Agreement results condition on the plain run staying within its budget; the recorded budgets are 2 GiB for ASan-bearing comparisons and 16 GiB for UBSan-only comparisons, with a 512 GiB target-side budget.

**Evidence label:** published theorem premise; published limitation.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Shapes.v and prior statement/provenance inspection distinguish source and target budgets. Later release notes say these budget premises have not been discharged for released agreement builds.

**Qualifications / unresolved questions.** Do not infer that every admitted input fits the source budget or that out-of-memory behavior is universally covered. Allocation-failure policies also differ by statement form.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/theories/Shapes.v)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/releases)

## C008 — The agreement proposition combines modeled error freedom with equality of observable behavior sets between specified plain and sanitizer binaries.

**Evidence label:** published theorem.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The initial README explains both components; Shapes.v instantiates LPS error-free agreement forms. Observations include process I/O, exit status, and modeled file contents.

**Qualifications / unresolved questions.** It is stronger than merely equal outputs. It still needs a specification/model connection to establish additional logical-object or functional properties.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/theories/Shapes.v)

## C009 — The initial audited snapshot has no published halts result; later releases add termination proofs.

**Evidence label:** published theorem inventory.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Initial README explicitly separates agreement from halts. v2026.10.1 adds 64 halts statements and v2026.10.2 adds two further halts statements.

**Qualifications / unresolved questions.** A timeless statement that the release has no termination proofs is false after the update. The broader announcement wording about exiting normally must not replace the exact initial public theorem.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/releases)

## C010 — Verifying a fixed harness restricts the client program, while the theorem remains universal over its admitted modeled inputs under its premises.

**Evidence label:** published theorem; scope interpretation.  
**Basis:** direct statement plus interpretation.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The README states universal input quantification and executable scope; harness sources identify the actual caller.

**Qualifications / unresolved questions.** Neither finite testing nor verification of every possible library client is an accurate description.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/statements.md)

## C011 — Modeled error freedom and sanitizer agreement do not automatically establish full library functional correctness.

**Evidence label:** not established by exported claim.  
**Basis:** direct scope; inferred limitation.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The corpus README explicitly disclaims library correctness; the reviewed parser harnesses do not provide a general semantic oracle for MessagePack or JSON.

**Qualifications / unresolved questions.** An individual supporting lemma can still prove a specific functional fact. Do not claim the entire proof corpus contains no functional reasoning.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/unpack_pack_fuzzer/source/unpack_pack_fuzzer.cpp)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_parser/source/fuzz_parser.cpp)

## C012 — Anthropic explicitly acknowledges that ASan misses memory-safety errors and that harness coverage and caller behavior limit the claims.

**Evidence label:** published limitation.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The main announcement Limitations section states each general boundary. A targeted reread on 29 October confirmed that it does not name custom allocators.

**Qualifications / unresolved questions.** The main announcement acknowledges ASan incompleteness in general; it does not specifically discuss custom allocators, suballocation boundaries, or internal object lifetimes. The custom-allocator analysis is ours. Do not attribute that specific analysis to Anthropic. This attribution check concerns the main blog post, not every linked document.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://www.anthropic.com/research/formal-verification)

## C013 — Ordinary ASan may track one live backing allocation without recognizing the client subobjects managed inside it.

**Evidence label:** background mechanism.  
**Basis:** direct background.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The ASan design and CMASan arena/recycler discussion explain standard allocator interception and custom-allocator blind spots.

**Qualifications / unresolved questions.** Manual poisoning, redzones, allocator substitution, and specialized instrumentation can change coverage. Their presence in a particular build must be checked; do not universally say ASan cannot support custom allocators.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://www.usenix.org/conference/atc12/technical-sessions/presentation/serebryany)
- [Primary source 2](https://yonghwi-kwon.github.io/data/cmasan_sp25.pdf)

## C014 — After reused storage is unpoisoned, address-only accessibility checks cannot distinguish an expired reference from a newly issued reference with the same address.

**Evidence label:** analytical illustration.  
**Basis:** inferred from mechanism and stated API contract.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The references have identical observed addresses but distinct stipulated logical allocation identities. The claim follows from what the check observes.

**Qualifications / unresolved questions.** This is a contract-sensitive illustration. It is not a universal claim about C/C++ transparent replacement, nor evidence that a verified client retains an expired reference.

**Detailed record:** [Evidence guide](README.md).

**Sources**

- [Primary source 1](https://yonghwi-kwon.github.io/data/cmasan_sp25.pdf)
- [Primary source 2](https://www.usenix.org/conference/atc12/technical-sessions/presentation/serebryany)

## C015 — CMASan reports 19 previously unknown custom-allocator memory bugs that ordinary ASan missed.

**Evidence label:** published empirical result.  
**Basis:** direct publisher/researcher report.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The CMASan abstract and evaluation report this result, including arena/recycler and clear/reuse examples.

**Qualifications / unresolved questions.** These are CMASan authors results, not bugs discovered by this handoff. Do not transfer their bugs to the audited revisions or binaries.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://yonghwi-kwon.github.io/data/cmasan_sp25.pdf)
- [Primary source 2](https://doi.org/10.1109/SP61157.2025.00110)

## C016 — The 20-category checklist in this bundle is a synthesis for auditing desired guarantees, not an exhaustive specification supplied by CMASan.

**Evidence label:** synthesis; attribution boundary.  
**Basis:** direct dossier provenance; editorial synthesis.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The original dossiers preserve a 17-item supplied checklist and three extensions concerning initialization/residual data, arithmetic/alignment, and races.

**Qualifications / unresolved questions.** CMASan supports particular allocator failure mechanisms and detector design. Other contracts and C/C++ semantic issues require their own arguments.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://yonghwi-kwon.github.io/data/cmasan_sp25.pdf)

## C017 — A client access should be related to an authorizing logical allocation identity, its current extent, and its liveness at the time of access.

**Evidence label:** proposed specification.  
**Basis:** our synthesis.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The paper proposes live(o,t) and containment of the full nonwrapping access interval in the current object interval. The identity must be linked to the reference, not chosen existentially by address.

**Qualifications / unresolved questions.** This is not an already proved theorem. Use time-dependent bounds for resizing and same-layer separation for distinct client allocations; nested backing/suballocations legitimately overlap.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

## C018 — Final-memory preservation alone does not constrain every intermediate read or write.

**Evidence label:** supporting proof definition; analytical countermodel.  
**Basis:** definition inspected; inferred nonimplication.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The simdjson dossier identifies munch in Lib/Frame.v as boundary preservation. A read can leave final memory unchanged; a temporary write followed by restoration can also preserve the relation.

**Qualifications / unresolved questions.** The illustration targets that relation alone. Other invariants and actual control flow may forbid the illustrated access. It is not an extracted binary trace.

**Detailed record:** [reports/simdjson.md](reports/simdjson.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Lib/Frame.v#L68)

## C019 — Uninstrumented runtime code is not automatically outside the machine-level proof.

**Evidence label:** build scope; not established inference.  
**Basis:** direct build evidence; interpretation.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Build documentation identifies sanitizer exclusions, while the proof corpus contains reached runtime instruction reasoning and contracts.

**Qualifications / unresolved questions.** Less instrumentation limits the sanitizer oracle. It does not by itself establish an unchecked assumption about every such function.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/building.md)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/exploring.md)

## C020 — Four projects received detailed selected-path proof review: msgpack-c, simdjson, OpenSSL, and pupnp; their project inventories sum to 19 harnesses and 41 agreements.

**Evidence label:** audit inventory.  
**Basis:** direct inventory; arithmetic.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The initial README and reports support 1/3, 10/24, 7/12, and 1/2 harness/agreement counts. These four are the detailed-proof subset of the restored twelve-project survey recorded in C051.

**Qualifications / unresolved questions.** The four-project count measures detailed selected-path proof review, not the full allocator survey. It is neither an exhaustive allocator census nor 41 complete audits. Boost.JSON has a separate pinned source-presence check; seven additional projects retain inherited source/configuration findings with their reported exclusions and corrections.

**Detailed record:** [project-inventory.csv](project-inventory.csv).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)

## C021 — msgpack-c unpack_pack_fuzzer creates fresh owning state, unpacks with six limits of 1000, packs, catches exceptions, and cleans up local state.

**Evidence label:** outside harness; source scope.  
**Basis:** direct source.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The harness and original dossier trace the fresh-zone owning overload. There is no comparison of output with input or a semantic oracle.

**Qualifications / unresolved questions.** Driver repetition is not retention of a zone pointer across calls. This is the C++ zone workload even though the repository is named msgpack-c.

**Detailed record:** [reports/msgpack-c.md](reports/msgpack-c.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/unpack_pack_fuzzer/source/unpack_pack_fuzzer.cpp)
- [Primary source 2](https://github.com/msgpack/msgpack-c/blob/a5250ecbcae1d34346c7445345774b0abbd651bc/include/msgpack/v3/unpack.hpp#L23-L71)

## C022 — msgpack-c explicitly proves allocation fit, alignment, freshness/non-overlap, requested-size regions, and selected array/map bounds.

**Evidence label:** supporting proof invariant.  
**Basis:** direct inspected lemmas.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Unp/Steps.v supplies zalloc8_fits_ok, zalloc1_fits_ok, zalloc_fresh_ok and separation lemmas; G4.v constructs new_region SZ; G3.v carries NEWSLOT bounds.

**Qualifications / unresolved questions.** These are positive facts. Preserve hypotheses and the selected compiled paths; do not inflate them into a universal original-allocation theorem.

**Detailed record:** [reports/msgpack-c.md](reports/msgpack-c.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Steps.v#L150-L244)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/G4.v#L133-L183)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/G3.v#L315-L340)

## C023 — The completed-tree predicate tree_wf alone does not encode the original allocation request for every payload.

**Evidence label:** demonstrated counterexample to a predicate implication; not established globally.  
**Basis:** manual predicate analysis.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Its OStr/OBin case uses in_zone and readability. The original dossier gives a toy chunk-contained range that exceeds a hypothetical earlier smaller request.

**Qualifications / unresolved questions.** The toy state was not shown reachable, was not proved to satisfy all combined invariants, and was not kernel-checked as a countermodel. Stronger construction facts may exclude it.

**Detailed record:** [reports/msgpack-c.md](reports/msgpack-c.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Inv.v#L13-L27)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Model.v#L105-L136)

## C024 — msgpack zones support clear in the library, but clear-then-retained-use is outside this harness; output sbuffer uses standard realloc separately.

**Evidence label:** outside harness; not applicable.  
**Basis:** direct source; inferred scope.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** cpp11_zone.hpp retains one chunk and resets the bump cursor on clear; sbuffer.hpp expands with standard realloc. The reviewed harness does not perform the clear/reuse sequence.

**Qualifications / unresolved questions.** Do not say msgpack has no clear or no realloc. Do not attribute a per-zone-object moving/shrinking realloc API to this workload.

**Detailed record:** [reports/msgpack-c.md](reports/msgpack-c.md).

**Sources**

- [Primary source 1](https://github.com/msgpack/msgpack-c/blob/a5250ecbcae1d34346c7445345774b0abbd651bc/include/msgpack/v1/detail/cpp11_zone.hpp#L111-L355)
- [Primary source 2](https://github.com/msgpack/msgpack-c/blob/a5250ecbcae1d34346c7445345774b0abbd651bc/include/msgpack/v1/sbuffer.hpp#L27-L135)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/unpack_pack_fuzzer/source/unpack_pack_fuzzer.cpp)

## C025 — The msgpack proof exports three strong_universal_error_free_unpack_pack_fuzzer theorem instances for ASan, UBSan, and both.

**Evidence label:** published theorem.  
**Basis:** direct recorded theorem names.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Theorems.v records suffixes _asan, _ubsan, and _both and instantiates strong_universal_error_free_T_scfg_budgets_abort.

**Qualifications / unresolved questions.** Symbols are preserved from the prior dossier; this handoff did not run Rocq. These are not source-language MessagePack correctness theorems.

**Detailed record:** [reports/msgpack-c.md](reports/msgpack-c.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Theorems.v#L17-L48)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/msgpack-c/unpack_pack_fuzzer/Statements.v)

## C026 — The initial simdjson inventory has ten proved harnesses and 24 agreements: nine ASan, eight UBSan, and seven combined.

**Evidence label:** published theorem inventory.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The inventory and original dossier list exact variants. There are 13 buildable harnesses with statements, not 13 proved harnesses.

**Qualifications / unresolved questions.** One upstream revision plus a recorded patch underlies the variants. Do not call 24 results 24 versions; fuzz_dump has no combined agreement in this snapshot.

**Detailed record:** [reports/simdjson.md](reports/simdjson.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/README.md)

## C027 — simdjson DOM proofs track individual string-record extents, lengths, headers, terminators, and sequential layout within the used prefix.

**Evidence label:** supporting proof invariant.  
**Basis:** direct inspected definitions.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** SjTape.v str_at requires o+l+5<=sn and represents length and terminator. SjTapeTile.v str_rec, tilesS, and tape_wfS thread successive records.

**Qualifications / unresolved questions.** Scoped to the identified proof paths. An ASan blind spot does not erase this stronger internal reasoning.

**Detailed record:** [reports/simdjson.md](reports/simdjson.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/Sj/SjTape.v#L107)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/Sj/SjTapeTile.v#L71)

## C028 — The On-Demand decoder contracts include a bounded output cursor and a permitted output footprint, with variant-specific proof connections.

**Evidence label:** supporting proof invariant.  
**Basis:** direct definitions; inherited proof-chain review.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Od_pstr_kit.v pstr_post_g bounds sbo<=sbo_prime<=sbo+(j-i-1); pstr_spec and ASan-bearing pstra_spec/pstrb_spec connect compiled decoder variants in the original dossier.

**Qualifications / unresolved questions.** The eventual view extent and decoder scratch/output permission differ. The footprint relation alone is not an all-intermediate-access theorem.

**Detailed record:** [reports/simdjson.md](reports/simdjson.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/P/Od_pstr_kit.v#L17)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/P/Od_pstr.v#L119)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/A/Od_pstrA.v#L129)
- [Primary source 4](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/B/Od_pstrB.v#L137)

## C029 — The reviewed simdjson clients do not retain a view across a later parse on the same parser; the documented DOM API invalidates views on reparse/destruction.

**Evidence label:** outside harness; API contract.  
**Basis:** direct API and harness evidence.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The original dossier enumerates the ten proved client sequences and upstream DOM element documentation.

**Qualifications / unresolved questions.** An illustrative stale-view client violates an API contract and is not a demonstrated vulnerability in the verified harness. Exact consequences of every On-Demand rewind remain unresolved.

**Detailed record:** [reports/simdjson.md](reports/simdjson.md).

**Sources**

- [Primary source 1](https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/dom/element.h#L70-L91)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/simdjson/fuzz_parser/source/fuzz_parser.cpp)

## C030 — Individual string free, wrong-pool free, and per-string realloc are not operations of the simdjson arenas inspected here.

**Evidence label:** not applicable.  
**Basis:** direct source; scoped interpretation.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The source descriptions and dossier matrix identify append-style string storage and bulk invalidation/backing-buffer replacement.

**Qualifications / unresolved questions.** Do not mark an operation absent from the interface as a failed safety guarantee. Backing allocations and parser reuse still have lifetime obligations.

**Detailed record:** [reports/simdjson.md](reports/simdjson.md).

**Sources**

- [Primary source 1](https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/dom/document-inl.h#L29)
- [Primary source 2](https://github.com/simdjson/simdjson/blob/f807de973580fb22cc0db6b3b896716684b0266c/include/simdjson/generic/ondemand/parser-inl.h#L24)

## C031 — The inspected simdjson layout/decoder contracts do not by themselves specify the complete decoded JSON value.

**Evidence label:** not established by reviewed contract.  
**Basis:** contract inspection; inferred nonimplication.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The dossier separates bounded record layout and pstr_post_g from equality between decoded bytes and a JSON semantic specification.

**Qualifications / unresolved questions.** This does not say every functional fact is absent from the corpus. A bounded-but-wrong illustrative payload is not an observed parser output.

**Detailed record:** [reports/simdjson.md](reports/simdjson.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/P/Od_pstr_kit.v#L17)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_dump/lib/Sj/SjTapeTile.v#L71)

## C032 — OpenSSL has seven proved harnesses and twelve agreement results in the initial snapshot; detailed allocator reasoning here concerns bndiv and bignum.

**Evidence label:** published theorem inventory; audit scope.  
**Basis:** direct inventory and review record.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The inventory lists bignum, bndiv, ct, echconfiglist_parser, hashtable, pem, and punycode. The original dossier records its selected paths.

**Qualifications / unresolved questions.** Seven harnesses does not mean seven BN_CTX audits. Full binary hashes and exact top-level theorem symbols for every variant were not all recorded.

**Detailed record:** [reports/openssl.md](reports/openssl.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/openssl/README.md)

## C033 — BN_CTX_end expires temporary-pointer API leases while retaining pool backing storage for reuse.

**Evidence label:** API contract; source behavior.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Pinned documentation states the invalidation rule; bn_ctx.c restores usage/frame state without freeing every backing pool item.

**Qualifications / unresolved questions.** This is logical/API invalidation, not necessarily the end of the underlying C allocation lifetime. Ordinary BN_free and digit-buffer frees are separate.

**Detailed record:** [reports/openssl.md](reports/openssl.md).

**Sources**

- [Primary source 1](https://github.com/openssl/openssl/blob/47aae188a6bdc65675ea9c2a9e770bef48a5d781/doc/man3/BN_CTX_start.pod)
- [Primary source 2](https://github.com/openssl/openssl/blob/47aae188a6bdc65675ea9c2a9e770bef48a5d781/crypto/bn/bn_ctx.c)

## C034 — In bndiv, valid_ref for RPool i requires i<3 and a nonempty pool; that predicate can remain true after modeled frame-end expires the lease.

**Evidence label:** supporting proof definition; analytical contract counterexample.  
**Basis:** direct definitions; manual derivation.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** BnInv.v:45-46 defines valid_ref. BnModel.v:368-380 retains cx_vals at BN_CTX_end. BnSpecs.v:416-420 requires valid_ref in the setter specification without an active-lease premise.

**Qualifications / unresolved questions.** This tests predicate adequacy, not reachability in the verified binary. The original dossier also discusses valid_refm, based on retained length; do not merge the definitions.

**Detailed record:** [reports/openssl.md](reports/openssl.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/bndiv/lib/Spec/BnInv.v#L45-L46)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/bndiv/lib/Spec/BnModel.v#L368-L380)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/bndiv/lib/Spec/BnSpecs.v#L416-L420)

## C035 — OpenSSL bignum has explicit liveness guards and preservation of temporaries in still-active outer frames.

**Evidence label:** supporting proof invariant.  
**Basis:** direct liveness definition; inherited guard and callsite review.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** BgInv.v live(r,s) is r<NFIX+gx_used(st_ctx s); BgArith uses bn_live. The earlier temporal audit traced frame-owning model callsites and records no escaped post-end use.

**Qualifications / unresolved questions.** Current-slot liveness is not a universal original-generation theorem. Missing generations alone does not establish an unsafe client.

**Detailed record:** [reports/openssl.md](reports/openssl.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/bignum/lib/Spec/BgInv.v#L120)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/bignum/lib/Spec/BgState.v)

## C036 — Selected OpenSSL instruction proofs establish concrete limb, copy, conversion, and expansion bounds.

**Evidence label:** supporting proof invariant.  
**Basis:** inherited detailed source audit.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The original dossier names AW_mul_words, W_copyAF, W_bin2bnA, and W_expandAF and explains loop ranges, owned arrays, exact copy lengths, and allocate/copy/free.

**Qualifications / unresolved questions.** The dossier retains the leaf module names; their complete repository paths were not re-established for this handoff. The repository directory links are navigation only; the recovered original dossier is the direct retained evidence. Snapshots of every named leaf are not included. Selected positive facts are not an all-instruction access certificate.

**Detailed record:** [reports/openssl.md](reports/openssl.md).

**Sources**

- [Repository navigation 1](https://github.com/theorem-labs/oss-verify-proofs/tree/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/bndiv/)
- [Repository navigation 2](https://github.com/theorem-labs/oss-verify-proofs/tree/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/bignum/)

**Direct retained evidence:** [Original OpenSSL dossier](dossiers/openssl_allocator_proof_audit.full-text.md).

## C037 — The recorded OpenSSL pem proof fixes the secure heap to its disabled state and follows ordinary allocation fallback.

**Evidence label:** configuration exclusion.  
**Basis:** inherited dossier evidence.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The original OpenSSL dossier explicitly identifies this configuration exclusion.

**Qualifications / unresolved questions.** Do not claim the secure buddy allocator was verified. Exact exclusion symbol/path is an open provenance detail if expanded into a major blog claim. The repository directory links are navigation only; the recovered original dossier is the direct retained evidence.

**Detailed record:** [reports/openssl.md](reports/openssl.md).

**Sources**

- [Repository navigation 1](https://github.com/theorem-labs/oss-verify-proofs/tree/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/pem/)
- [Repository navigation 2](https://github.com/theorem-labs/oss-verify-proofs/tree/98e995d4daced70a0a4aa2c810854b88720735f1/projects/openssl/pem/)

**Direct retained evidence:** [Original OpenSSL dossier](dossiers/openssl_allocator_proof_audit.full-text.md).

## C038 — pupnp FuzzHttp has ASan and combined agreement results, and its reviewed client initializes an HTTP parser, appends one input, and destroys the message.

**Evidence label:** published theorem inventory; source scope.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Initial README lists two variants; the pinned harness and FreeList source are included among selected snapshots.

**Qualifications / unresolved questions.** No standalone UBSan agreement is published for this harness in the initial snapshot. General arbitrary allocator histories are not the harness.

**Detailed record:** [reports/pupnp.md](reports/pupnp.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)
- [Primary source 2](https://github.com/pupnp/pupnp/blob/b46bc77ac9ae2ff1351d0f4ce544d97283b6e149/fuzzer/FuzzHttp.c)

## C039 — pupnp proofs distinguish backing blocks from cached nodes and exclude duplicate cached returns under their premises.

**Evidence label:** supporting proof invariant.  
**Basis:** direct inspected lemmas.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** FreeListFree_post_A retains LB when caching and extends FB; it uses NoDup(map blk_id FB_prime). FreeListFree_stmt_A requires uniqueness including the returned node. Destroy removes owned blocks.

**Qualifications / unresolved questions.** This contradicts a blanket claim that internal release or cleanup is ignored. The invariant is scoped to the modeled client and preconditions.

**Detailed record:** [reports/pupnp.md](reports/pupnp.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/pupnp/FuzzHttp/lib/A0/AW/H_freelist.v#L262-L290)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/pupnp/FuzzHttp/lib/A0/AW/H_freelist.v#L427-L437)

## C040 — The pupnp allocation lemma inspected in plain, ASan, and combined proofs assumes an empty freelist cache.

**Evidence label:** outside inspected allocation contract.  
**Basis:** direct.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** FreeListAlloc_stmt_A requires fl_cells 0 fk and invokes malloc for 24 bytes. The P0 and B0 variants have matching empty-head premises.

**Qualifications / unresolved questions.** It does not establish a reused-node generation-sensitive guarantee. This is not evidence that a stale-node access occurs in FuzzHttp.

**Detailed record:** [reports/pupnp.md](reports/pupnp.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/pupnp/FuzzHttp/lib/A0/AW/H_freelist.v#L222-L254)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/pupnp/FuzzHttp/lib/B0/AW/H_freelist.v#L230-L244)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/pupnp/FuzzHttp/lib/P0/H_freelist.v#L450)

## C041 — Boost.JSON contains a monotonic resource in the pinned source, but its exercise in the verified fuzz_parse configuration was not established.

**Evidence label:** source presence only; inherited supplementary finding.  
**Basis:** direct selected-source inspection.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The checked monotonic_resource.ipp advances a cursor within backing blocks; do_deallocate is empty and release frees backing blocks. The checked harness calls default parse(sv,ec). Separately, the recovered prior survey (SRC13; source-snapshots/prior-conversations/README.md) identifies value_stack temporary storage; its source-to-compiled-proof chain was not re-established here.

**Qualifications / unresolved questions.** The directly checked monotonic resource supports a fifth source-presence case, not a fifth detailed proof audit or a claim that this optional resource is exercised. The default parse call does not prove absence of all internal allocation. Keep the inherited value_stack finding separate from the pinned-source check. Superproject and submodule commits differ.

**Detailed record:** [reports/additional-projects.md](reports/additional-projects.md).

**Prior-survey provenance:** [provenance note](source-snapshots/prior-conversations/README.md) (SRC13).

**Sources**

- [Primary source 1](https://github.com/boostorg/json/blob/e93cf9c254619142b9f3cfa9022b93fb1d4e5edb/include/boost/json/impl/monotonic_resource.ipp)
- [Primary source 2](https://github.com/boostorg/json/blob/e93cf9c254619142b9f3cfa9022b93fb1d4e5edb/fuzzing/fuzz_parse.cpp)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/projects/boost-json/project.yaml)

## C042 — Earlier survey findings identify allocator mechanisms or configuration exclusions in libpcap, Leptonica, Mbed TLS, zstd, Speex, tinyobjloader, and Varnish; this handoff retains those findings with their original distinctions.

**Evidence label:** inherited prior survey; not freshly primary-source verified.  
**Basis:** recovered prior assistant findings.  
**Scope:** Inherited October 24–25 2026 survey of the initial released builds; recovered 29 October 2026, without original primary-source URLs.

**Evidence.** SRC13 (source-snapshots/prior-conversations/README.md) restores allocator symbols, reported harness exclusions, configuration dependence, zstd annotations, a positive tinyobjloader reachability assertion, and the Varnish emulator correction. These are richer prior findings than a list of speculative names.

**Qualifications / unresolved questions.** The original supporting primary-source URLs were not recovered. Retention of a prior finding is not a fresh pinned-source verification or Rocq audit; absence of rechecking is also not evidence that the prior identification was refuted. Corpus membership is independently supported by C003. Specific inherited findings are separated in C052–C056.

**Detailed record:** [reports/additional-projects.md](reports/additional-projects.md).

**Prior-survey provenance:** [provenance note](source-snapshots/prior-conversations/README.md) (SRC13).

## C043 — PHP is not among the 25 projects with proofs in the audited initial README.

**Evidence label:** published inventory boundary.  
**Basis:** direct inventory; inherited wider-catalog note.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The complete initial proved-project inventory excludes PHP. Earlier discussion recorded PHP build/statement entries without proved results.

**Qualifications / unresolved questions.** PHP2Shell is context, not a counterexample to a proved PHP result. The inherited six-harness/42-statement details are not a newly rechecked PHP allocator audit.

**Detailed record:** [reports/additional-projects.md](reports/additional-projects.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)

## C044 — Later release notes disclose a modeled stack-window discrepancy affecting the initial msgpack-c agreement proofs.

**Evidence label:** published model limitation.  
**Basis:** direct maintainer disclosure.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Captured v2026.10.1 notes distinguish the modeled stack window from Linux accounting and identify affected results.

**Qualifications / unresolved questions.** Maintainers report no known input forcing the relevant stack usage. This is separate from the allocator argument and is not a demonstrated actual crash.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/releases)

## C045 — Updated initial release notes discuss model-layout/allocation-refusal limitations that can exclude inputs or hide output differences in constructed examples.

**Evidence label:** published model limitation; toy counterexamples.  
**Basis:** direct maintainer disclosure.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The retained notes distinguish constructed examples from released fuzz targets.

**Qualifications / unresolved questions.** Do not transfer a model toy example to a real verified project. It is independent of the custom-allocator predicate observations.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/releases)

## C046 — This investigation did not independently replay Rocq proofs, rebuild or execute release binaries, or produce an actual violating binary trace.

**Evidence label:** review-method record.  
**Basis:** direct record of work performed.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** All three original dossiers record source/specification review; the new reports consolidate that method and selected source rechecks.

**Qualifications / unresolved questions.** Compiling and visually checking the LaTeX paper is document QA, not proof-corpus validation. Published proof status remains publisher status.

**Detailed record:** [Original project dossiers](dossiers/README.md).

## C047 — A universal theorem connecting every relevant machine access to its authorizing original logical object and live lease has not been established by this review.

**Evidence label:** not established by this review.  
**Basis:** scoped negative review conclusion.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The exported proposition, weaker reusable predicates, positive local invariants, and excluded histories are documented separately in the four reports.

**Qualifications / unresolved questions.** This is not proof that no such theorem follows from the full development. The strongest open task is to derive or refute the explicit property with complete evidence.

**Detailed record:** [OPEN-QUESTIONS.md](OPEN-QUESTIONS.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Inv.v#L13-L27)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/openssl/bndiv/lib/Spec/BnInv.v#L45-L46)
- [Primary source 4](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/pupnp/FuzzHttp/lib/A0/AW/H_freelist.v#L222-L254)

## C048 — None of the four project audits demonstrates a reachable custom-allocation memory-safety violation in the exact verified binary.

**Evidence label:** no demonstrated reachable counterexample.  
**Basis:** direct audit-result record.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Reports and complete dossiers distinguish hypothetical API misuse, predicate-level examples, and actual program reachability.

**Qualifications / unresolved questions.** Do not use exploit or failure graphics that imply a vulnerability was reproduced. Literature bugs and later model disclosures have different subjects.

**Detailed record:** [Original project dossiers](dossiers/README.md).

## C049 — Logical invalidation by a custom allocator is not automatically identical to ending a C-language allocation lifetime.

**Evidence label:** terminology; contract interpretation.  
**Basis:** direct example; semantic distinction.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** Backing allocation can remain live while the allocator contract expires client permission, as in the BN_CTX source and API.

**Qualifications / unresolved questions.** State the intended object model and reference/lease semantics. Do not describe every custom lifetime violation as a demonstrated ISO C/C++ lifetime violation.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/openssl/openssl/blob/47aae188a6bdc65675ea9c2a9e770bef48a5d781/crypto/bn/bn_ctx.c)
- [Primary source 2](https://github.com/openssl/openssl/blob/47aae188a6bdc65675ea9c2a9e770bef48a5d781/doc/man3/BN_CTX_start.pod)

## C050 — Backing-allocation ownership and cleanup evidence do not by themselves establish universal leak freedom, initialization, or confidentiality guarantees.

**Evidence label:** supporting invariants; separate contract.  
**Basis:** direct facts; inferred contract boundary.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The original dossiers distinguish cleanup sequences, subset-based live-block predicates, disabled leak detection, and general definedness or zeroization properties.

**Qualifications / unresolved questions.** Retained arena capacity can be intentional. Do not call every retained byte a leak or every uninitialized capacity byte a client memory-safety error.

**Detailed record:** [context-and-properties.md](context-and-properties.md).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/building.md)
- [Primary source 2](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Spec/ModelInv.v#L233)
- [Primary source 3](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/proofs/simdjson/fuzz_ondemand/lib/Spec/KStep.v#L1320)

## C051 — The restored survey tracks twelve projects whose initial-snapshot inventories total 40 harnesses and 90 agreement statements.

**Evidence label:** tracked survey inventory; mixed evidence levels.  
**Basis:** retained survey membership; arithmetic from pinned inventory.  
**Scope:** `98e995d4daced70a0a4aa2c810854b88720735f1` unless the source identifies another revision or date.

**Evidence.** The set is msgpack-c, simdjson, OpenSSL, pupnp, Boost.JSON, libpcap, Leptonica, Mbed TLS, zstd, Speex, tinyobjloader, and Varnish. Membership is documented by the reports and SRC13 (source-snapshots/prior-conversations/README.md). Their counts are summed from the pinned README/CSV inventory: four detailed projects contribute 19/41, Boost.JSON 1/3, and seven additional inherited cases 20/46.

**Qualifications / unresolved questions.** This is a tracked-project count, not twelve confirmed allocator paths, twelve deep proof audits, 90 allocator guarantees, or an exhaustive prevalence estimate. Reported exclusions and Varnish’s substituted configuration remain in the survey. The full proved corpus is still 25 projects, 60 harnesses, and 138 agreement results.

**Detailed record:** [project-inventory.csv](project-inventory.csv).

**Prior-survey provenance:** [provenance note](source-snapshots/prior-conversations/README.md) (SRC13).

**Sources**

- [Primary source 1](https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md)

## C052 — The prior Varnish survey corrected its WS_Init workspace interpretation: the verified esi_parse_fuzzer build was reported to enable ENABLE_WORKSPACE_EMULATOR and use malloc/free.

**Evidence label:** inherited configuration correction.  
**Basis:** recovered prior correction; not freshly verified.  
**Scope:** Inherited October 24–25 2026 survey of the initial released builds; recovered 29 October 2026, without original primary-source URLs.

**Evidence.** SRC13 (source-snapshots/prior-conversations/README.md) records an initial WS_Init/1-KiB workspace claim and the later emulator correction. The additional-projects report preserves both in order to avoid carrying the superseded workload interpretation forward.

**Qualifications / unresolved questions.** Original build flags and emulator source links were not recovered as pinned primary evidence. Do not count this as an unannotated normal-workspace allocator exercised by the verified build, or as a demonstrated proof gap. It is a retained source/configuration-exclusion case.

**Detailed record:** [reports/additional-projects.md](reports/additional-projects.md).

**Prior-survey provenance:** [provenance note](source-snapshots/prior-conversations/README.md) (SRC13).

## C053 — The earlier tinyobjloader survey described 64-KiB bump blocks with a used cursor and asserted that fuzz_tobj_c exercises that allocation path.

**Evidence label:** inherited positive harness-relevance assertion.  
**Basis:** recovered prior assertion; not freshly verified.  
**Scope:** Inherited October 24–25 2026 survey of the initial released builds; recovered 29 October 2026, without original primary-source URLs.

**Evidence.** SRC13 (source-snapshots/prior-conversations/README.md) recovers more than the earlier truncated 64-KiB snippet: it includes the bump-block/cursor description and names fuzz_tobj_c as the relevant target.

**Qualifications / unresolved questions.** The exact implementation symbols, source revision, and complete allocator-to-compiled-harness chain were not independently reconstructed. Retain the positive prior assertion as inherited evidence; do not present it as a new primary confirmation or completed allocator proof audit.

**Detailed record:** [reports/additional-projects.md](reports/additional-projects.md).

**Prior-survey provenance:** [provenance note](source-snapshots/prior-conversations/README.md) (SRC13).

## C054 — The prior survey reported libpcap’s newchunk/freechunks arena unused by fuzz_pcap, Leptonica’s optional pms manager uninstalled by the published harnesses, and Mbed TLS’s buffer allocator uninitialized by fuzz_pkcs7.

**Evidence label:** inherited harness/configuration exclusions.  
**Basis:** recovered prior exclusions; not freshly verified.  
**Scope:** Inherited October 24–25 2026 survey of the initial released builds; recovered 29 October 2026, without original primary-source URLs.

**Evidence.** SRC13 (source-snapshots/prior-conversations/README.md) names newchunk/freechunks, pmsCreate/pmsCustomAlloc/pmsCustomDealloc, and memory_buffer_alloc.c, and records the respective reachability, installation, and initialization exclusions.

**Qualifications / unresolved questions.** These three exclusions have different mechanisms and must not be collapsed into a claim that the source lacks custom allocators. Original pinned call-path/configuration links were not recovered; no fresh exclusion proof or per-harness Leptonica audit was performed. Source presence does not establish that the corresponding allocator is exercised.

**Detailed record:** [reports/additional-projects.md](reports/additional-projects.md).

**Prior-survey provenance:** [provenance note](source-snapshots/prior-conversations/README.md) (SRC13).

## C055 — The prior survey reported ASan poisoning and redzones in zstd’s ZSTD_cwksp workspace, while its relevance to the four proved targets remained unestablished.

**Evidence label:** inherited instrumentation qualification.  
**Basis:** recovered prior source finding and scope limit.  
**Scope:** Inherited October 24–25 2026 survey of the initial released builds; recovered 29 October 2026, without original primary-source URLs.

**Evidence.** SRC13 (source-snapshots/prior-conversations/README.md) identifies the ZSTD_cwksp arena and its ASan annotations separately from the unresolved connection to the four released harnesses.

**Qualifications / unresolved questions.** Original annotation/build source links were not recovered. Do not describe this workspace as uniformly unannotated or invisible to ASan. Annotations alone also do not establish a complete logical-object contract, and this record does not determine which annotated path is present in each proved binary.

**Detailed record:** [reports/additional-projects.md](reports/additional-projects.md).

**Prior-survey provenance:** [provenance note](source-snapshots/prior-conversations/README.md) (SRC13).

## C056 — The prior Speex survey identified PUSH/ALLOC scratch allocation as configuration dependent, with the relevant implementation in the published binary unconfirmed.

**Evidence label:** inherited configuration-dependent finding.  
**Basis:** recovered prior source finding and configuration uncertainty.  
**Scope:** Inherited October 24–25 2026 survey of the initial released builds; recovered 29 October 2026, without original primary-source URLs.

**Evidence.** SRC13 (source-snapshots/prior-conversations/README.md) retains the PUSH/ALLOC mechanism and the explicit uncertainty about selection in the released speex_decode_fuzzer_float configuration.

**Qualifications / unresolved questions.** This is not a claim that every Speex build uses a custom heap arena. Distinguish caller/scratch storage, standard allocation, and logical suballocation; original preprocessor/build evidence and a proof-contract audit remain unavailable.

**Detailed record:** [reports/additional-projects.md](reports/additional-projects.md).

**Prior-survey provenance:** [provenance note](source-snapshots/prior-conversations/README.md) (SRC13).


## C057 — PHP CVE-2015-2787 has published arbitrary-code-execution exploit evidence and a separately reported ASan false negative with the allocator shim disabled.

**Evidence label:** published exploit evaluation; published sanitizer false negative; cross-study synthesis.  
**Basis:** direct findings in separate studies; cross-study synthesis.  
**Scope:** Historical PHP CVE-2015-2787; HushVac PHP 5.5.14; separate CMASan shim-disabled evaluation; not the audited proof-corpus binaries.

**Evidence.** CMASan Table 4 and section 5.5 list this PHP UAF as missed by ASan with the allocator shim disabled. HushVac Table I and section VI.G evaluate a public arbitrary-code-execution PoC for the same CVE on PHP 5.5.14. PHP security report 68976 explains the lifetime error.

**Qualifications / unresolved questions.** Keep the allocator-shim condition. CMASan states that a shim can expose these known bugs to ASan. The exploit and detection studies do not establish identical binaries or build configurations. No experiment was reproduced here, and this is not a vulnerability claim about the verified corpus.

**Detailed record:** [reports/security-impact.md](reports/security-impact.md).

**Sources**

- [Primary source 1](https://yonghwi-kwon.github.io/data/cmasan_sp25.pdf)
- [Primary source 2](https://www.ndss-symposium.org/wp-content/uploads/2024-804-paper.pdf)
- [Primary source 3](https://bugs.php.net/bug.php?id=68976)
