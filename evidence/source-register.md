# Source register

This register covers the shared context, corpus inventory, and property framework. Project-specific reports and the recovered dossiers contain additional file-level proof/source citations. Identifiers beginning SRC are local to this register; dossier identifiers such as S03 or D04 retain their own document-local meanings.

The corpus is pinned to oss-verify-proofs commit **98e995d4daced70a0a4aa2c810854b88720735f1**. Source retrieval and consolidation took place on 29 October 2026, reusing the earlier audits. This handoff does not claim a new Rocq kernel recheck or comprehensive audit of later releases.

## Primary sources

### SRC01 — Anthropic announcement

- Title: *LLMs are making formal software verification feasible at a much larger scale*.
- Date displayed by publisher: 22 October 2026.
- URL: https://www.anthropic.com/research/formal-verification
- Used for: collaboration with Theorem; reported 239 entry points and 123 libraries; proof-generation approach; reported input restriction; explicitly acknowledged model, sanitizer, entry-point, and caller limitations.
- Status: live publisher page, not immutable. No full local copy included.
- Attribution check on 29 October: the main Limitations section says “ASan doesn’t detect all memory safety bugs.” It does not specifically name custom allocators. The paper must attribute only the general limitation to this source; the allocator-specific analysis is ours.
- Interpretation boundary: the opening's “always exit normally” language must not be substituted for the initial public corpus's actual agreement theorem. The pinned README explicitly says no halts theorem was proved there.

### SRC02 — PHP Foundation chronology and PHP2Shell context

- Title: *Today's PHP Security Release, and How We're Strengthening PHP Security*.
- Date displayed: 21 October 2026.
- URL: https://thephp.foundation/blog/2026/10/21/todays-php-security-release-and-how-were-strengthening-php-security/
- Used for: the 21 October coordinated security release; two relevant error-handling/lifetime vulnerabilities; 20 October leaks and pre-announcement.
- Status: live primary source; no full local copy included.
- Interpretation boundary: the announcement followed the coordinated release by one day. It did not follow the first public awareness by exactly one day. PHP2Shell is contextual motivation, not a counterexample to a proved PHP harness.

### SRC03 — Initial corpus README and proof inventory

- Repository: theorem-labs/oss-verify-proofs.
- Revision: 98e995d4daced70a0a4aa2c810854b88720735f1.
- Immutable human-readable URL: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/README.md
- Immutable raw URL: https://raw.githubusercontent.com/theorem-labs/oss-verify-proofs/98e995d4daced70a0a4aa2c810854b88720735f1/README.md
- Local snapshot: [source-snapshots/corpus/README.md](source-snapshots/corpus/README.md).
- Used for: 25 projects; 60 harnesses; 55 ASan, 34 UBSan, and 49 combined agreement statements; exact harness/variant pairs; theorem explanation, budgets, and initial absence of halts results.
- Snapshot method: all 176 numbered lines of the web tool's plain-text retrieval were retained in session memory. The snapshot reconstructs those lines in order after removing the tool's line-number prefixes. It is an archived text extraction, not a byte-for-byte HTTP download with an upstream checksum.
- Derived files: project-inventory.csv and harness-inventory.csv were generated from the 60 table rows. These are results about this revision, not current HEAD.
- Derived subset totals: the twelve tracked survey projects sum to 40 harnesses / 90 agreement statements. Within them, the four detailed-review projects sum to 19 harnesses / 41 statements. These are project-wide inventory sums, not counts of exercised allocator paths or completed allocator-proof audits. The README establishes the counts, not custom-allocator presence; the latter has the different evidence levels recorded in the reports and SRC13.
- Licensing: the README retains the repository's licence description and third-party notice references.

### SRC04 — Initial LPS semantics documentation in the proof corpus

- Revision: 98e995d4daced70a0a4aa2c810854b88720735f1.
- URL: https://github.com/theorem-labs/oss-verify-proofs/blob/98e995d4daced70a0a4aa2c810854b88720735f1/docs/semantics.md
- Raw URL: https://raw.githubusercontent.com/theorem-labs/oss-verify-proofs/98e995d4daced70a0a4aa2c810854b88720735f1/docs/semantics.md
- Used for: modeled process inputs, launches, traces, errors, environment-failure configuration, model restrictions, and pinning of LPS.
- Status: inspected primary document; no separate complete local snapshot was retained by this subtask.

### SRC05 — Pinned LPS scope and assumptions

- Repository: theorem-labs/rocq-linux-process-semantics.
- Revision: f1006fe8178338a499b5e5c41be83006c4edd058.
- URL: https://github.com/theorem-labs/rocq-linux-process-semantics/blob/f1006fe8178338a499b5e5c41be83006c4edd058/SCOPE.md
- Retrieval API: https://api.github.com/repos/theorem-labs/rocq-linux-process-semantics/contents/SCOPE.md?ref=f1006fe8178338a499b5e5c41be83006c4edd058
- Local snapshot: [source-snapshots/corpus/LPS-SCOPE.md](source-snapshots/corpus/LPS-SCOPE.md).
- Used for: Linux v6.18.46 / QEMU-user scope; RV64GC instruction model; single thread, signal, stack, path, filesystem, and external-activity assumptions; generic memory defaults; known precision differences.
- Snapshot method: content field from the successful GitHub connector response, retained without additional research.
- Interpretation boundary: a model's executable syscall checker agreeing with its own specification is not a proof that the specification agrees with Linux.

### SRC06 — Release notes and dated later changes

- Release pages:
  - https://github.com/theorem-labs/oss-verify-proofs/releases/tag/v2026.10.0
  - https://github.com/theorem-labs/oss-verify-proofs/releases/tag/v2026.10.1
  - https://github.com/theorem-labs/oss-verify-proofs/releases/tag/v2026.10.2
- Retrieval API: https://api.github.com/repos/theorem-labs/oss-verify-proofs/releases
- Local extract: [source-snapshots/corpus/release-notes.json](source-snapshots/corpus/release-notes.json).
- API records are authoritative for publication times used here. v2026.10.1 and v2026.10.2 headings say 27 October, while the API records publication on 28 October.
- Used for: initial release totals; subsequent additions of halts results; undischarged budget premises; allocation-layout precision issue; stack-window discrepancy affecting msgpack-c and glaze; confirmation that later counted results do not mean a complete new set of binaries.
- Extract method: retained JSON response filtered to the three release records, preserving tag, URL, created/published/updated timestamps, and complete body. Large asset lists and account metadata were omitted.
- Mutability: GitHub release-note bodies can be updated. This is a dated snapshot, not an immutable file at a code revision. Initial release notes had already been updated on 27 October.
- Interpretation boundary: five later statements listed as known false were not thereby previously proved theorems; do not call them proof-checker contradictions.

### SRC07 — Audit commit identity and relation to the tag

- URL: https://github.com/theorem-labs/oss-verify-proofs/commit/98e995d4daced70a0a4aa2c810854b88720735f1
- Retrieval API: https://api.github.com/repos/theorem-labs/oss-verify-proofs/commits/98e995d4daced70a0a4aa2c810854b88720735f1
- Local extract: [source-snapshots/corpus/audit-commit.json](source-snapshots/corpus/audit-commit.json).
- Used for: exact SHA, parent 8f5f46768858af236a4270f9628e6beed9aa0e72, commit time, and CI-only commit message.
- Extract method: retained API response reduced to SHA, URL, dates, message, and parents. This avoids archiving an unrelated large diff.
- Interpretation boundary: the audit revision is one commit after the initial release tag. There is no evidence here that the tag moved.

### SRC08 — CMASan

- Authors: Junwha Hong, Wonil Jang, Mijung Kim, Lei Yu, Yonghwi Kwon, Yuseok Jeon.
- Title: *CMASan: Custom Memory Allocator-aware Address Sanitizer*.
- Venue: IEEE Symposium on Security and Privacy, 2025, pages 740–757.
- DOI: https://doi.org/10.1109/SP61157.2025.00110
- Author-hosted PDF: https://yonghwi-kwon.github.io/data/cmasan_sp25.pdf
- Used for: ordinary ASan's limited awareness of custom allocation; allocator-aware treatment of alloc/realloc/free/clear; reported 19 previously unknown bugs missed by ASan.
- Interpretation boundary: the 20-row property taxonomy in this handoff is the project's synthesis. It must not be attributed as an exhaustive taxonomy or comprehensive correctness result of CMASan.

## Recovered internal evidence

The following dossiers are prior project analyses. They are evidence records with primary-source links, not independent publications or kernel certificates. Their conclusions should be checked against their cited source excerpts when making a stronger claim.

### SRC09 — msgpack-c dossier

- Local: [dossiers/msgpack_proof_audit.txt](dossiers/msgpack_proof_audit.txt).
- Earlier filename: msgpack_proof_audit.txt.
- Source revision: a5250ecbcae1d34346c7445345774b0abbd651bc, version 8.0.0.
- Proof revision: 98e995d4daced70a0a4aa2c810854b88720735f1.
- Useful preserved facts: source and harness provenance; 64 MiB admitted-file threshold and header; 2/16 GiB source and 512 GiB target budgets; selected chunk and subobject predicates; 17 original checklist rows plus three added categories.
- Positive and negative evidence are both part of the record.

### SRC10 — simdjson dossier

- Local: [dossiers/Simdjson_Proof_Evidence_Dossier.md](dossiers/Simdjson_Proof_Evidence_Dossier.md).
- Source revision: f807de973580fb22cc0db6b3b896716684b0266c, with the release patch recorded in the dossier.
- Proof revision: 98e995d4daced70a0a4aa2c810854b88720735f1.
- Useful preserved facts: ten-harness inventory; selected DOM and on-demand string-arena invariants; parser-view lifetime boundary; 64 MiB driver threshold; target budget; 20-category matrix.
- Interpretation boundary: v2026.10.0 is the proof-corpus release label, not a recorded upstream simdjson version number.

### SRC11 — OpenSSL dossier

- Local: [dossiers/openssl_allocator_proof_audit.full-text.md](dossiers/openssl_allocator_proof_audit.full-text.md).
- Earlier deliverable: openssl_allocator_proof_audit.pdf; this handoff includes its recovered full text.
- Source revision: 47aae188a6bdc65675ea9c2a9e770bef48a5d781.
- Proof revision: 98e995d4daced70a0a4aa2c810854b88720735f1.
- Useful preserved facts: twelve agreement results across seven harnesses; selected bignum/bndiv BN_CTX audit; explicit positive frame/bound evidence; missing universal original-object/current-lease condition.
- Interpretation boundary: the absence of a universal contract is not a discovered reachable OpenSSL vulnerability.

## Project-report pointers

### SRC12 — Boost.JSON source-presence check

- Report: [reports/additional-projects.md](reports/additional-projects.md).
- Proof project manifest: [source-snapshots/boost-json/project.yaml](source-snapshots/boost-json/project.yaml).
- Boost superproject revision: 4daa5786d7c5dad39df0429cb078165b3134a06f.
- Boost.JSON libs/json submodule revision: e93cf9c254619142b9f3cfa9022b93fb1d4e5edb.
- Immutable allocator source: https://github.com/boostorg/json/blob/e93cf9c254619142b9f3cfa9022b93fb1d4e5edb/include/boost/json/impl/monotonic_resource.ipp
- Immutable harness source: https://github.com/boostorg/json/blob/e93cf9c254619142b9f3cfa9022b93fb1d4e5edb/fuzzing/fuzz_parse.cpp
- Source-presence check: confirmed suballocation from backing blocks, no-op individual deallocation, and bulk release in the monotonic allocator.
- Harness relevance: the harness calls default parse(sv, ec). Use of this monotonic allocator by the proved workload was not established.
- Local provenance: [source-snapshots/boost-json/PROVENANCE.md](source-snapshots/boost-json/PROVENANCE.md) and [manifest.json](source-snapshots/boost-json/manifest.json).
- Interpretation boundary: source presence is not proof coverage. The no-op deallocation follows this allocator's intended semantics and is not, by itself, a missed free.
- Recovered additional observation: the earlier survey identified value_stack temporary storage and left execution of optional monotonic/static resources unconfirmed. This observation is inherited under SRC13; it does not expand the direct monotonic-resource check into a completed compiled-path or Rocq proof audit.

The four detailed project reports contain specific Rocq files, definitions, helper lemmas, source excerpts and remaining questions for msgpack-c, simdjson, OpenSSL and pupnp. Their proof-file identifiers are more precise than the shared sources above. The additional-projects report separately preserves the direct Boost.JSON source check and seven inherited source/configuration findings. Use the appropriate evidence level and project report for a project-specific assertion instead of citing only the general README.

The pupnp upstream SHA supplied by the completed project audit is b46bc77ac9ae2ff1351d0f4ce544d97283b6e149. Source commits for unreviewed projects are explicitly “not recorded” in the CSV; no version number has been guessed from a current upstream branch.

## Recovered broader-survey provenance

### SRC13 — Preliminary allocator-survey provenance

The seven inherited survey rows originated in exploratory work on 24–25 October
2026. Their original primary-source links were not recovered. Raw conversation
excerpts and recovery metadata are excluded from this release. These findings
remain preliminary; they are not independent source confirmations or new proofs.

The [additional-projects report](reports/additional-projects.md) preserves the
project-specific findings, harness exclusions, configuration uncertainties,
and Varnish correction. The [provenance note](source-snapshots/prior-conversations/README.md)
explains this evidence limit. Counts of harnesses and agreement statements come
from SRC03's pinned inventory, not from a new allocator audit.

## Snapshot limitations and reproduction

The inventory can be reproduced by reading the 60 “What is proved” rows of the pinned README and counting each comma-separated sanitizer variant. This reproduces the census without fetching current HEAD.

The snapshots preserve retrieved source text and metadata. They do not include every release binary, all generated Rocq files, the checker container, or a new compilation log. Re-running the proofs is a separate operation and should not be inferred from the existence of this handoff. The project's root index and claim register explain which remaining claims need additional proof, source inspection, or an executable witness.


## SRC14 — HushVac exploit evaluation

- Chanyoung Park and Hyungon Moon. *Efficient Use-After-Free Prevention with Opportunistic Page-Level Sweeping*. NDSS 2024. DOI: 10.14722/ndss.2024.24804.
- Primary paper: https://www.ndss-symposium.org/wp-content/uploads/2024-804-paper.pdf
- Relevant location: Table I and section VI.G, printed page 13 / PDF index 12.
- Used for: published evaluation of a public arbitrary-code-execution exploit for PHP 5.5.14 / CVE-2015-2787.
- Qualification: this exploit study is separate from CMASan's sanitizer experiment. No common binary configuration was established and no exploit was reproduced here. See C057 and reports/security-impact.md.

## SRC15 — Original PHP security report for CVE-2015-2787

- Taoguang Chen, PHP security bug 68976, submitted 3 February 2015; tracker records the fix on 17 March 2015.
- Primary disclosure: https://bugs.php.net/bug.php?id=68976
- Used for: the lifetime error, its application-dependent trigger, and the reporter's code-execution assessment.
- Auxiliary vendor advisory: https://ubuntu.com/security/notices/USN-2572-1
- This is a historical example, not evidence of a bug in the audited verification snapshot.
