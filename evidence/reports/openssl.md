# OpenSSL: custom allocation, logical lifetimes, and the released proof contract

## Update: focused replay, 1 November 2026

The original source inspection below has since been supplemented by a
[focused Rocq replay](../dossiers/openssl-lifetime/README.txt) against the
unchanged definitions at `98e995d4`. A constructed client reaches an expired
temporary from the initial model state and changes its sign while satisfying
the complete setter preconditions. The artifact includes source hashes,
assumption checks, and successful build and kernel-check records.

This checks the local modeled contracts. It does not demonstrate an invalid
access by the published `bndiv` client, and the full binary agreement
certificates were not replayed. Statements below about missing replay refer
to the original inspection, before this follow-up check.

## Status and how to use this report

This report consolidates the completed source/specification inspections. It does not claim a new comprehensive audit or a new Rocq replay. Its central result is a distinction between **positive evidence about the fixed verified clients** and **the absence of a universal certificate relating every machine access to its original logical object and lease**.

No incorrect Rocq theorem, reachable use-after-frame-end, or bad spatial access in the original verified clients was demonstrated. The prior audit found substantive bounds reasoning, balanced frames, nonescaping temporary use, and preservation of outer temporaries. A separate, concrete limitation exists in the reusable `bndiv` validity contract: that predicate can remain true after the documented API lease has expired.

Read this report together with the preserved [original six-page audit, complete extracted text](../dossiers/openssl_allocator_proof_audit.full-text.md). The extraction preserves all six pages' text and page markers, but is not the original PDF byte stream. The dossier's recovery metadata is in the same directory.

Evidence status is separated as follows:

- **Current source inspection:** the exact snippets and definitions described below were read from pinned primary source and are preserved in [selected source snapshots](../source-snapshots/openssl/).
- **Prior completed audit:** richer instruction-level and client-discipline findings are retained from the original 24 October 2026 dossier. They were not re-audited for this handoff.
- **Not established:** independent kernel replay, a complete logical-access trace theorem, and a concrete violating execution of the fixed verified binaries.

## Immutable scope and inventory

| Item | Pinned identity / interpretation |
| --- | --- |
| Proof repository | `theorem-labs/oss-verify-proofs` |
| Proof commit | `98e995d4daced70a0a4aa2c810854b88720735f1` |
| OpenSSL repository | `openssl/openssl` |
| OpenSSL source commit | `47aae188a6bdc65675ea9c2a9e770bef48a5d781` |
| Project manifest | [Local project.yaml](../source-snapshots/openssl/project.yaml) |
| Detailed allocator review | Selected `BN_CTX` paths in `bndiv` and `bignum` |
| Public OpenSSL inventory at this snapshot | 7 harnesses, 12 sanitizer-agreement statements |
| Proof execution status | Source/specification review; not independently replayed with Rocq |

Do not identify this immutable audit commit with whatever commit a release tag or `main` resolves to later. The source/proof inventories and conclusions are snapshot-specific.

| Harness with a released proof | Sanitizer variants proved | Agreement statements |
| --- | --- | ---: |
| `bignum` | ASan; ASan+UBSan | 2 |
| `bndiv` | ASan; UBSan | 2 |
| `ct` | ASan+UBSan | 1 |
| `echconfiglist_parser` | ASan; UBSan | 2 |
| `hashtable` | ASan | 1 |
| `pem` | ASan+UBSan | 1 |
| `punycode` | ASan; UBSan; ASan+UBSan | 3 |
| **Total** | **5 ASan + 3 UBSan + 4 combined** | **12** |

These are project inventory counts. They are not seven audited `BN_CTX` clients or twelve independent allocator-lifetime audits. Other OpenSSL harnesses were checked for inventory/build scope in the original audit, not given the same allocator-path inspection.

The public agreement theorem concerns the fixed compiled harness under its modeled inputs, machine semantics, allocation/system-call assumptions, and memory-budget premise. It is not an arbitrary-client OpenSSL theorem. For the common theorem and the full corpus inventory, consult the accompanying release/context report and pinned proof repository documentation.

## What the allocator does

`BN_CTX` manages temporary `BIGNUM` objects. It groups headers into pool items, tracks the used prefix, and supports nested start/end frames. A `BIGNUM`'s digit buffer is distinct from its pooled header; reasoning about digit-buffer growth must not be conflated with moving or freeing a pooled header.

Pinned implementation: [crypto/bn/bn_ctx.c](../source-snapshots/openssl/upstream/crypto/bn/bn_ctx.c), from the OpenSSL commit above.

| Source location | Observation |
| --- | --- |
| Lines 15–29 | `BN_CTX_POOL_SIZE` is 16; a `BN_POOL_ITEM` contains 16 `BIGNUM` values. |
| Lines 199–215 | `BN_CTX_end` restores frame usage, calling `BN_POOL_release` when appropriate. |
| Lines 315–351 | `BN_POOL_get` allocates a backing pool item when needed, otherwise returns an existing slot. |
| Lines 354–367 | `BN_POOL_release` reduces pool usage and adjusts pool traversal state; it does not free the pool item. |

The [pinned API documentation](../source-snapshots/openssl/upstream/doc/man3/BN_CTX_start.pod), lines 29–32, explicitly invalidates pointers obtained from `BN_CTX_get` when `BN_CTX_end` is called. The [official HTML documentation](https://docs.openssl.org/3.0/man3/BN_CTX_start/) states the same rule.

A minimal API sequence illustrating the distinction is:

~~~c
BN_CTX_start(ctx);
BIGNUM *t = BN_CTX_get(ctx);
/* use t while its frame is active */
BN_CTX_end(ctx);
/* t's API lease has expired, although backing storage can remain */
~~~

A client that subsequently uses `t` violates that API lifetime contract. This is a **logical use after release**. Do not claim that `BN_CTX_end` necessarily ends a C-language allocation's lifetime by executing system `free`; retained physical storage is the point of the example. Other OpenSSL interfaces create ordinary standalone `BIGNUM` objects, so `BN_CTX` is not the only way to obtain one.

## Positive evidence in the fixed client models

The original dossier's temporal audit traced the modeled frame-owning callsites. It found no use of a temporary after its owning frame ended.

### bndiv

The modeled division sequence is `BN_CTX_start`, obtain `tmp`, `snum`, and `sdiv`, perform the arithmetic, then `BN_CTX_end` as its last fixed-top action. The multiplication model similarly finishes using its scratch temporary before ending its frame. Subsequent correction operates on ordinary outputs, rather than reopening a released pool reference.

The specialized model supports one 16-header pool bundle, at most three simultaneously used temporary slots, and the corresponding frame-index storage. This reflects the verified client's discipline; it is not a claim about all possible `BN_CTX` clients or arbitrary nesting.

The prior audit additionally checked that machine-wrapper arguments on this path are nonpool references, digit expansion precedes taking the current loop buffer pointers, and owned digit buffers are separated. The relevant earlier evidence names include `W_fuzzA`, `BnModel`, and `BnSpecs`; the complete wrapper file path was not re-established for this handoff.

### bignum

The larger `bignum` development contains explicit liveness reasoning:

~~~coq
Definition live (r : bnref) (s : ST) : Prop :=
  (r < NFIX + gx_used (st_ctx s))%nat.
~~~

This is [BgInv.v, line 120](../source-snapshots/openssl/proof/bignum/Spec/BgInv.v). The reference representation uses natural-number slots: [BgState.v, lines 11–25](../source-snapshots/openssl/proof/bignum/Spec/BgState.v) defines `bnref := nat` and `RPool i := NFIX + i`.

The original audit traced 15 textual frame starts and 16 textual ends; the extra end belongs to mutually exclusive exits of one function. It reports that arithmetic cores use `bn_live`, callers establish liveness, exponentiation-table references remain in an active outer frame, and result/scratch roles are tracked. Preservation lemmas restore the used count/frame stack and retain the earlier leased prefix. A failed abstract guard is a branch the verification must exclude, not an added runtime sanitizer check.

These facts support the fixed clients' discipline. The lack of generation tags in a representation is not, by itself, evidence that the fixed client misuses a stale reference. A source-dependent invariant may establish nonescape without runtime generations.

### Instruction-level spatial evidence from the original dossier

| Audited operation | Positive evidence retained from the earlier audit |
| --- | --- |
| Multiply words | Exact source length and destination extent; one-element tail iterations and four-element unrolled iterations; explicit 32-byte bounds and read/store facts. |
| Copy a `BIGNUM` | Separate headers, disjointness where required, copy size `8 * source_top`, represented source bytes, destination capacity after expansion, and exact memcpy block/range facts. |
| Convert input bytes | Individual input bytes obtained from the known list; output limb indices bounded by the represented array; top-correction reads justified by `nth_error`. |
| Expand the digit buffer | Distinguishes unchanged capacity from strict growth; allocates separate ordinary-heap storage, copies significant limbs within bounds, frees old storage, and reconstructs the header/array representation. |

The original report names `AW_mul_words`, `W_copyAF`, `W_bin2bnA`, and `W_expandAF`. Their complete repository paths were not re-resolved here; do not invent paths from these abbreviated module names. The earlier report is preserved as evidence, while the portable snapshot set is deliberately selective.

## A concrete limitation of bndiv's reusable contract

The following definitions were independently checked at the pinned proof commit in the current session.

In [BnInv.v, lines 45–46](../source-snapshots/openssl/proof/bndiv/Spec/BnInv.v):

~~~coq
Definition valid_ref (r : bnref) (s : LS) : Prop :=
  match r with
  | RPool i => (i < 3)%nat /\ cx_vals (ls_ctx s) <> []
  | _ => True
  end.
~~~

This tests neither the active used-prefix bound nor the frame in which a reference was leased. It contains no identity for successive leases of the same slot.

In [BnModel.v, lines 368–380](../source-snapshots/openssl/proof/bndiv/Spec/BnModel.v), the modeled `BN_CTX_end` reduces usage and removes the frame, but preserves `cx_vals`. In [BnSpecs.v, lines 326–329](../source-snapshots/openssl/proof/bndiv/Spec/BnSpecs.v), `BN_CTX_end_spec` preserves the modeled values `getbn r` for all references and the same owned-block set.

Therefore, for a successful frame end, this `valid_ref` predicate remains true for a pool reference even when its documented API lease expires. For example, after obtaining `RPool 0` in a fresh frame and then ending that frame, the pool is still nonempty and `0 < 3` is still true.

The reusable `BN_set_negative_spec` in the same file, lines 416–420, requires `st_ok`, `own`, and `valid_ref`, without requiring an active lease. The abstract getter/setter representation therefore does not automatically reject that expired reference.

**What this establishes:** `valid_ref` cannot be interpreted as “this reference's API lease is currently live.” It gives a direct counterexample to that interpretation of the reusable contract.

**What it does not establish:** a use-after-end in the original `bndiv` execution, a false end-to-end Rocq theorem, or a kernel-checked counterexample. The fixed client does not perform the post-end sequence in this logical witness.

### Do not conflate valid_ref with valid_refm

The original dossier also discusses a lower-level `valid_refm` predicate based on the retained values' length. That is a different symbol from the `valid_ref` above, whose current inspected definition uses `i < 3`. Both can fail to express lease expiration, but their definitions must not be silently merged.

The original audit drafted an unchecked definitional witness around a one-frame context with 16 retained slots and one used slot: end the frame, observe retained physical validity, access the slot, then start/get again and receive the same slot identity. No Rocq-checked witness file was recovered or independently checked in this handoff.

## Why endpoint framing is not an all-access property

The original audit examined the distinction between memory before/after a routine and all the intermediate accesses. Its example framing condition was:

~~~text
munch W m m' :=
  for every address x outside W, m'(x) = m(x)
~~~

If address `a` is readable, the abstract effect `ELoad 64 a (fun _ => EDone c)` can leave the same final core and memory as `EDone c`. A read of another accessible object can therefore be invisible to an endpoint-only framing predicate. A write followed by restoration can likewise preserve final memory.

This is a countermodel to an implication between specifications; it is not an extra instruction found in the released binary. Concrete instruction/loop invariants can supply the missing access-specific reasoning, and the audited multiplication/copy routines contain examples of exactly such reasoning.

The prior evidence names are `Lib/MState` (effect interpreter), `Lib/Frame` (`munch`), `BnIfaceA` (postcondition), and `StepFast` (cell-based loads). Full paths and a compiled formal counterexample were not re-established in this handoff.

## Consolidated property assessment

“Not supplied as a universal contract” below must not be read as “the fixed client violates the property.”

| Property | Assessment retained from the completed audit |
| --- | --- |
| 1. Bounds of suballocations | Substantial instruction-level bounds, header/limb layouts, disjointness, and copy-range evidence. No complete entire-binary logical-object access certificate was derived. |
| 2. Use after internal release | Fixed client discipline supported; no expired use found. Reusable primitives are not a universal expired-reference detector. |
| 3. Custom double release | Balanced frames and owned standard frees are represented. No arbitrary per-slot `pool_free(p)` API is exercised. |
| 4. Bulk clear/reset/frame-end UAF | `BN_CTX_end` is the relevant invalidation. Caller/frame invariants keep the inspected modeled uses within the owning frames. |
| 5. Shrink followed by old-tail access | Not the operation on this path: pooled headers have fixed size, and requesting fewer digit words does not shrink existing capacity. |
| 6. Moving reallocation | Ordinary digit-buffer growth is explicitly allocate/copy/free/update. Do not describe it as moving pooled headers or retaining old resized storage. |
| 7. Stale use after same-slot reuse | No escaped stale reference found in the fixed models. Slot identities alone do not name successive API leases. |
| 8. Stale free of a new occupant | No per-slot free API exercised; ordinary frees require current ownership. No generic stale-handle deallocation theorem supplied. |
| 9. Invalid or wrong-pool free | Scoped ownership checks on standard frees. Arbitrary interior-pointer, wrong-pool, wrong-family, and sized custom frees are not jointly verified as a general API. |
| 10. Other invalidations | Specific frame/context operations covered; arbitrary cache, transaction, or rewind histories remain outside these clients. Earlier audit reports context destruction in `bignum`; `bndiv` retains its initialized context. |
| 11. Allocator-internal defects | Significant capacity, slot separation, usage/frame, ownership, and accounting invariants. No arbitrary-client allocator-API theorem. |
| 12. Logical leaks | Earlier audit reports empty modeled ownership on `bignum` return (`fuzz_one_gwp`) and exact accounting of retained allocations in `bndiv`. No general OpenSSL-wide leak theorem; runtime leak detection is off in the audited build. |
| 13. Jump across a redzone into another live object | No universal pointer-origin relation in the exported theorem. Specific layout/arithmetic proofs can nevertheless exclude individual bad jumps. |
| 14. Cross-field access | Concrete layout/value reasoning exists. A compiler can legitimately combine adjacent field accesses, so naive source-field bounds are not automatically the correct machine-level rule. |
| 15. Logical length versus capacity | `top` is significant-word count; `dmax` is capacity. Spare-capacity access may be intentional, so `index < top` is not a universal memory-safety requirement. |
| 16. Destruction with retained storage | C++ destruction is not directly applicable to this C pool. API lease expiration is the relevant analogue; no general source-language lifetime/provenance theorem is supplied. |
| 17. Uninstrumented accesses | Still part of machine execution and potentially directly reasoned about. “Uninstrumented” does not mean “unverified.” |
| Initialization/residual data | No general definedness, noninterference, or zeroization theorem. Numerical state tracking is not equivalent to these guarantees. |
| Alignment and size arithmetic | Enabled sanitizer checks and specific arithmetic arguments apply where proved. The original audit reports that unsigned-overflow and implicit-conversion checks are not generally enabled. |
| Data races | Outside the single-threaded execution model. |

The runtime/build-specific statements in this matrix are inherited from the preserved prior audit; they were not newly rebuilt or tested in this handoff.

## Other OpenSSL harness gotchas retained from the dossier

- The `pem` proof's audited build fixes the secure heap to the disabled state and follows ordinary allocation fallback. It must not be advertised as verification of the secure buddy allocator.
- The `hashtable` driver repeats one selected payload, not an arbitrary sequence of independently chosen insertions and deletions.
- These are prior scope findings, not new allocator audits of those harnesses. The exact leaf symbols behind those two build/client findings were not re-resolved for this handoff.

## Reproduction map and remaining work

The [source manifest](../source-snapshots/openssl/manifest.json) maps every saved file to its repository, exact commit, repository-relative path, SHA-256, and size. In particular:

| Local saved proof | Pinned repository-relative source |
| --- | --- |
| `proof/bndiv/Spec/BnModel.v` | `proofs/openssl/bndiv/lib/Spec/BnModel.v` |
| `proof/bndiv/Spec/BnInv.v` | `proofs/openssl/bndiv/lib/Spec/BnInv.v` |
| `proof/bndiv/Spec/BnSpecs.v` | `proofs/openssl/bndiv/lib/Spec/BnSpecs.v` |
| `proof/bignum/Spec/BgInv.v` | `proofs/openssl/bignum/lib/Spec/BgInv.v` |
| `proof/bignum/Spec/BgState.v` | `proofs/openssl/bignum/lib/Spec/BgState.v` |

The earlier dossier reports a historical mirror of 301 `bndiv` proof files (6.6 MB) checked against Git blob hashes and 59 selected `bignum` modules, with a spatial review over 14 modules. Those numbers describe that earlier audit; they do not describe the 11-file selected OpenSSL snapshot delivered here.

A stronger result would state object bounds and lease expiration explicitly, and relate every relevant concrete memory access to the authorizing object/lease. Ghost identities and a static nonescape proof can suffice; runtime generation checks are not mandatory. This work has not been done by this audit, and it should remain a future proof obligation rather than an asserted bug.

