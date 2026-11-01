# Open questions and evidence needed

These questions record the unresolved issues from the initial source review.
The [claim index](README.md) identifies the later checked results and their
limits. Use that index when assessing the current evidence.

## Q01. Can the stronger access property be extracted from the existing proofs?

**Known:** local bounds, allocation, ownership, and lifetime-discipline facts exist. The exported agreement theorem does not directly state the authorizing-object property proposed in the paper.

**Missing:** a complete derivation, over all relevant reachable accesses in a specified harness, connecting the accessed byte interval to the original logical allocation and its still-valid authorization.

**Evidence needed:** a formal statement defining access events, reference origins, allocation/lifetime events and authorized ranges; a derivation from the existing invariants through machine-step simulation; explicit treatment of runtime calls and compiler-introduced accesses. A proof may use ghost identities or fixed-client nonescape arguments. Runtime tags are not compulsory.

**Editorial consequence:** say the stronger property is not established by this review. Do not say it is impossible to derive, or absent from every part of the development. Relevant claims: C017, C022, C027, C035, C047.

## Q02. Do any actual verified binaries reach the illustrative violations?

**Known:** none of these audits produced such a trace. The generic pool example stipulates a contract. The msgpack toy state concerns a predicate implication. OpenSSL's reusable predicate can survive API invalidation, but the fixed client was not shown to use it afterward.

**Evidence needed:** a concrete input or admitted initial state satisfying all theorem premises, an execution of the exact binary, the precise access and logical object contract it violates, and a justification of reachability. A proof-level counterexample must satisfy the entire relevant invariant conjunction rather than an isolated weakened predicate.

**Editorial consequence:** no claim of an exploitable vulnerability, unsound Rocq proof, or verified binary containing a demonstrated use-after-free. Relevant claims: C023, C034, C048.

## Q03. Independent replay of the initial corpus

**Known:** the publisher marks the recorded results proved. The original dossiers identify Rocq 9.2.0, the repository's checker workflow and its dependency/checker pins.

**Missing:** logs from an independent replay performed by this investigation.

**Evidence needed:** exact audit checkout, matching binary assets and full hashes, pinned LPS and checker image, documented `oft` workflow, successful proof compilation/export checks, and allowed-assumption output. If an optional `rocqchk` pass is run, record that separately. Retain resource limits and failures without treating a tooling failure as a theorem refutation.

**Editorial consequence:** use “published theorem” rather than “we kernel-checked.” Relevant claim: C046.

## Q04. Binary provenance and independent rebuilds

**Known:** published fingerprints for msgpack's four builds and simdjson `fuzz_parser`'s four builds are retained in the dossiers and reports. They were transcribed, not recomputed locally.

**Missing:** a complete ELF hash manifest for every reviewed project's harness/variant, fresh downloads matching those hashes, and independent reproducible rebuild records.

**Evidence needed:** release asset identity, build recipe, toolchain image, source and patch set, output hashes, and a comparison with the published images. Keep source snapshots distinct from binary snapshots.

**Editorial consequence:** avoid suggesting that this portable bundle can rebuild or replay the whole corpus offline. It includes selected textual evidence, not complete binaries or a full checkout.

## Q05. Later public releases and current status

**Known:** captured release notes for `v2026.10.1` and `v2026.10.2` add proofs and describe model/budget limits. The source audit remains fixed at `98e995d4`.

**Missing:** a comparable allocator-contract audit of later proof revisions and any still newer release after the capture date.

**Evidence needed:** exact later revisions, a meaningful diff of the relevant theorem/contract/source definitions, changed binaries, and checks focused on whether the property under discussion changed. Inventory growth alone does not answer that question.

**Editorial consequence:** date the corpus figures. The claim that the initial snapshot has no termination results must not become a claim about all current releases. Relevant claims: C004, C009, C044, C045.

## Q06. Memory-budget premises

**Known:** the plain/target budgets differ; agreement is conditional on the relevant budget premise. Later notes say the released agreement results have not discharged that premise.

**Evidence needed:** a theorem establishing budget sufficiency over the admitted input domain, or a carefully specified behavior for budget exhaustion; precise treatment of forced allocation refusal, address-range exhaustion, and environmental refusal policies.

**Editorial consequence:** input size and memory consumption must remain separate. Do not infer universal out-of-memory safety from a small-input bound. Relevant claim: C007.

## Q07. msgpack's original-suballocation property

**Known:** allocation construction remembers requested sizes and proves fit/freshness; `tree_wf` can express chunk containment/readability without original request history. The weak-predicate toy example does not satisfy a proved full reachable-state derivation.

**Evidence needed:** trace the requested-size relation through G4/G2B construction, active container invariants, transition to a completed tree, `mem_pk`/packing reads and copies, and teardown. Either derive the full desired origin-sensitive bound or identify a precise abstraction loss that defeats that derivation.

**Editorial consequence:** retain the positive lemmas and the predicate-local qualification together. Relevant claims: C022, C023.

## Q08. msgpack clear, construction rollback, and longer client histories

**Known:** the source contains `zone::clear` and construction rollback; the fixed unpack/pack harness does not carry references through a clear/reuse cycle. Its normal `sbuffer` growth is standard realloc.

**Evidence needed:** a new, explicitly specified client that exercises valid clear/reuse histories, defines which handles are invalidated, and separates intentional misuse examples from admitted well-formed clients. Relevant proofs must then cover those histories.

**Editorial consequence:** such work would extend scope; it would not retroactively prove the existing harness unsafe. Do not invent individual-zone-object realloc or free operations. Relevant claim: C024.

## Q09. simdjson's proof-chain coverage and exact theorem symbols

**Known:** the dossiers preserve variant-specific DOM and On-Demand connections and some exact exported names. Not every top-level symbol for all ten harnesses and 24 result instances was transcribed.

**Evidence needed:** the exact per-harness `Statements.v`, result wrapper, `Theorems.v` export and dependency connection for any additional named theorem. Retain variant-specific premises, especially for ASan and combined variants.

**Editorial consequence:** do not mechanically invent theorem names from harness names. The exact DOM facts found for `fuzz_dump` do not imply a combined result when that variant lacks a published proof in the audited snapshot. Relevant claims: C026–C028.

## Q10. simdjson parser reuse, On-Demand rewind, and view lifetime

**Known:** the DOM next-parse/destruction invalidation rule is documented. The reviewed client sequences do not retain old views across parser reuse. The earlier dossier marks rewind sequences unexercised.

**Evidence needed:** exact API documentation and implementation for each proposed On-Demand rewind scenario, which views are invalidated, a specified longer client sequence, and proof of its safety obligations.

**Editorial consequence:** do not claim every rewind invalidates every view in exactly the same way. The blog can illustrate the documented DOM reparse case with a clear API-misuse label. Relevant claims: C029, C030.

## Q11. simdjson output semantics and intermediate accesses

**Known:** record-layout and decoder-output bounds exist; final-memory frame conditions do not alone constrain every intermediate access. The inspected contract does not equate all output bytes to a JSON semantic decoder.

**Evidence needed:** a content relation to a JSON specification, and an event-level access argument if the intended claim concerns all intermediate reads/writes. Separate decoder scratch permission from the final returned string-view interval.

**Editorial consequence:** a bounded-but-wrong payload or restore-after-write illustration is a contract countermodel, not an observed program behavior. Relevant claims: C018, C028, C031.

## Q12. OpenSSL logical leases versus current-slot validity

**Known:** `bndiv`'s `valid_ref` uses `i<3` and nonempty storage; the original dossier's different `valid_refm` checks a retained range. The modeled frame end preserves storage. `bignum` separately guards current liveness, and the fixed clients show nonescape/frame discipline.

**Evidence needed:** a full original-lease property, a proof relating every relevant primitive and machine access to it, or a complete actual counterexample under all premises. A proposed Rocq witness for predicate reduction should be checked if described as kernel-checked.

**Editorial consequence:** preserve the difference among `valid_ref`, `valid_refm`, and `live`; none may be substituted for another. A current used-prefix guard does not by itself distinguish old and new leases at the same slot. Relevant claims: C033–C036.

## Q13. Exact OpenSSL provenance for subsidiary scope claims

**Known:** the full earlier dossier records that `pem` follows the disabled secure-heap fallback and that the `hashtable` driver repeats one selected payload. It also names specific spatial proof leaves.

**Missing in the portable selected snapshots:** every exact supporting exclusion symbol, full statement export, and low-level leaf file for these subsidiary claims.

**Evidence needed:** retrieve the already identified pinned files/symbols if these claims become central blog examples. This is targeted evidence completion, not grounds to announce that the secure buddy allocator has been audited.

**Editorial consequence:** keep them labeled inherited dossier findings with precise scope. Relevant claims: C036, C037.

## Q14. pupnp cached-node reuse

**Known:** the inspected allocation contracts assume an empty cache; return and destruction contracts track backing blocks, cache membership and uniqueness.

**Evidence needed:** a specified client that allocates from a populated cache, a corresponding allocation lemma, and a logical ownership/lifetime relation across repeated node leases. For an invalid-return claim, account for the existing `NoDup` precondition instead of ignoring it.

**Editorial consequence:** cache/release reasoning exists. The unresolved issue is a broader reuse-sensitive contract, not demonstrated stale-node misuse in `FuzzHttp`. Relevant claims: C039, C040.

## Q15. Allocator annotations and build substitutions

**Known:** the reports preserve build facts already recorded, including simdjson's patch and OpenSSL's secure-heap exclusion. The restored prior survey also reports ASan poisoning/redzones in zstd's workspace and corrects the Varnish workspace interpretation because the reviewed build uses `ENABLE_WORKSPACE_EMULATOR` with `malloc`/`free`. The latter two are inherited findings, not fresh primary-source confirmations. Their recovery record is [README.md](source-snapshots/prior-conversations/README.md) (SRC13).

**Evidence needed:** exact configuration/preprocessor flags, call paths, any custom poison/unpoison or container annotations, allocator shims, and corresponding compiled paths for a specific claim. For the recovered zstd and Varnish findings, the immediate missing evidence is the original primary source/build citation, not another generic explanation of how allocators work. Some reports explicitly leave a full annotation census unperformed.

**Editorial consequence:** use conditional language for ordinary ASan. Preserve the reported annotations and substitutions in the broader project table; do not assert that all identified allocators are unannotated or active in the verified configuration. Keep the inherited-evidence label visible. Relevant claims: C013, C019, C041, C052, C055.

## Q16. Boost.JSON harness relevance

**Known:** the pinned submodule contains `monotonic_resource`; the inspected harness calls default `parse(sv, ec)`. The recovered earlier survey separately identifies parser `value_stack` temporary storage. That finding should survive alongside the directly checked optional-resource source, with its inherited status preserved.

**Evidence needed:** trace actual storage-resource selection and compiled calls under the verified build, distinguishing optional monotonic/static resources from `value_stack` temporary storage; then inspect the relevant proof if that path is reached. Recover the prior primary links for the inherited temporary-storage observation if making it a central claim.

**Editorial consequence:** include Boost.JSON in the broader twelve-project survey with separate direct-source and inherited-detail labels. Do not call it a fifth detailed allocator proof case study, and do not infer that default parsing has no internal allocation merely because the harness passes no explicit monotonic resource. Relevant claims: C041, C051.

## Q17. Restored survey findings and an exhaustive census

**Known:** the restored survey tracks twelve projects: the four detailed cases, Boost.JSON, and seven further projects with recovered prior findings: libpcap, Leptonica, Mbed TLS, zstd, Speex, tinyobjloader, and Varnish. Their project-wide initial inventories sum to 40 harnesses and 90 agreement statements. Those are inventory totals, not counts of allocator guarantees. The [additional-projects report](reports/additional-projects.md) and [prior-conversation recovery](source-snapshots/prior-conversations/README.md) preserve the details.

The recovered findings contain more information than a list of speculative names: libpcap's `newchunk`/`freechunks` arena was reported unused by `fuzz_pcap`; Leptonica's optional `pms` manager uninstalled; Mbed TLS's buffer allocator uninitialized by `fuzz_pkcs7`; zstd's workspace annotated with ASan poisoning/redzones but of unresolved target relevance; Speex's `PUSH`/`ALLOC` configuration unconfirmed; tinyobjloader's bump arena asserted to be exercised by `fuzz_tobj_c`; and Varnish's original workspace claim corrected by the emulator configuration.

**Evidence needed:** the original primary-source URLs for the seven recovered findings were not recoverable. Recover those precise earlier citations or reconstruct only the relevant source/build/call-path link when a stronger publication claim requires it. For a full new proof audit, also record exact source revision, active configuration, theorem inventory, and supporting contracts. A uniform definition of custom allocation and a complete survey are needed before computing a prevalence percentage.

**Editorial consequence:** show all twelve tracked projects in a broader survey with evidence/status distinctions; retain four as the detailed proof-review count. Label the recovered findings as inherited prior results rather than freshly pinned evidence, but do not discard a previously reported mechanism or exclusion simply because it was not rechecked during packaging. Do not label all twelve allocator-verified, or classify an unreviewed member of the 25-project corpus as allocator-free. Relevant claims: C020, C042, C051–C056.

## Q18. PHP context and absent proof claims

**Known:** PHP2Shell is the chronological context. PHP is absent from the initial proved-project README. Earlier discussion recorded wider-catalog PHP binaries/statements without proofs.

**Evidence needed:** the full PHP revision and statement catalog if the blog wants exact unproved PHP counts. No PHP custom-allocator proof audit is supplied here.

**Editorial consequence:** never present PHP2Shell as a counterexample to a proved PHP binary in this corpus. Relevant claim: C043.

## Q19. Initialization, confidentiality, reclamation and concurrency

**Known:** these are distinct contracts. Ownership/cleanup facts and some arithmetic checks exist. The model is single-threaded; leak detection is disabled in the recorded configurations.

**Evidence needed:** explicit definedness, noninterference/zeroization, bounded-retention or reclamation, and concurrent safety specifications, with proofs under suitable assumptions. Eventual reclamation may need progress assumptions.

**Editorial consequence:** avoid silently equating all these properties with spatial/temporal memory safety. A pool's intended bulk policy can make retaining unused capacity correct. Relevant claim: C050.

## Q20. Original files and full offline reproducibility

**Known:** complete extracted text of three earlier dossiers is included. Selected already-fetched source files have provenance manifests. The OpenSSL original PDF layout and binary stream were not materialized.

**Evidence needed:** original artifact bytes if exact document preservation is required, and a complete pinned checkout plus assets if an offline replay package is desired. Neither should be claimed merely because this evidence ZIP is portable.

**Editorial consequence:** the bundle is complete as a writing handoff for the supported claims, but it is not a substitute for a full reproducibility artifact.

## Q21. Can the historical PHP exploit and sanitizer experiments be matched to an identical build?

**Known:** C057 combines two published findings about CVE-2015-2787: an exploit evaluation and an ASan false negative with the allocator shim disabled.

**Not established:** identical source revisions, build options, allocator configurations, inputs, or binaries across those experiments.

**Evidence needed for a stronger same-build claim:** exact manifests and experimental records from both studies, or a separately authorized reproduction. No such reproduction was performed for this paper.

**Editorial consequence:** state the two findings separately. The existing claim needs no assertion that an exploit was run under the exact ASan configuration.
