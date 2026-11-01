<PARSED TEXT FOR PAGE: 1 / 6>

OPENSSL / CUSTOM ALLOCATOR PROOF AUDIT                                                                                24 OCT 2026




 OpenSSL custom allocator
 proof audit
 A focused check of logical object bounds, pool lifetimes, and the limits of the released
 machine-level guarantee.

 24 October 2026 | Source and specification review | Immutable release snapshot

 Assessment
 No incorrect Rocq theorem or bad access in the original verified clients was demonstrated.
 The deeper review found substantial positive evidence: concrete machine-loop bounds, explicit buffer
 copy bounds, balanced pool frames, and preservation of outer temporaries across nested calls.

 The release still does not supply a universal logical-object access theorem. The exported
 theorem concerns successful modeled machine executions and sanitizer agreement. The reusable
 primitive contracts can admit API-expired pool references, and final-memory framing is weaker than a
 condition on every intervening access. These are confirmed limits of the contract, not counterexamples
 in the fixed binaries.

   Question                              Result


   Do the fixed big-number models        No such use found. All modeled frame-owning callsites in the audited files were
   use a temporary after its frame       traced. bignum has explicit liveness guards and preservation lemmas; bndiv uses a
   ends?                                 smaller, fixed nonescaping temporary discipline.


   Is there direct bounds                Yes. The audited multiplication leaf, copy, byte-conversion, and expansion proofs
   reasoning beyond ASan?                use array elements, exact ranges, block ownership, and loop invariants.


   Does the current theorem itself       No such universal contract was identified. Endpoint simulation and
   certify every actual access           physical-slot representations do not by themselves imply it. A separate
   against its original object/lease?    access-aware derivation would be required for that stronger certification.



 Scope and verification boundary
 OpenSSL source: 47aae188a6bdc65675ea9c2a9e770bef48a5d781.
 Proof repository: 98e995d4daced70a0a4aa2c810854b88720735f1.

 The public inventory has 12 agreement results over seven OpenSSL harnesses. This detailed audit
 concerns the BN_CTX paths in bndiv and bignum. Other harness inventories/builds were checked for
 scope, not given an equally deep instruction audit. The particular drivers do not explore arbitrary client
 API histories.

 Rocq was unavailable in this environment. The released proofs were not independently replayed. This is a
 source/specification audit, not a new kernel-checked all-access proof. A draft definitional witness discussed below is explicitly
 unchecked.




Source review - no independent Rocq replay                                                                                           1

<PARSED TEXT FOR PAGE: 2 / 6>

OPENSSL / CUSTOM ALLOCATOR PROOF AUDIT                                                                           24 OCT 2026




 1. Pool lifetime discipline in the fixed clients
 bndiv: a small, nonescaping frame protocol
 The modeled division opens one frame, obtains tmp/snum/sdiv, uses them, then calls BN_CTX_end as its
 last fixed-top action. Multiplication similarly uses its recursive scratch temporary before ending its frame.
 The outer postprocessing corrects ordinary outputs RB1-RB5, rather than reopening a released pool
 reference.

 The machine wrapper specifications require the externally supplied bignum references on this path to be
 nonpool. Expansion completes before the arithmetic loops take their current digit-buffer pointers. Distinct
 buffers are separated through the allocation ownership invariant.

 The specialized bndiv model needs one 16-header pool bundle, at most three simultaneous temporary
 slots, and one frame-index allocation. It proves balanced starts/ends and zero temporary usage at rest. It
 does not claim arbitrary BN_CTX growth or arbitrary client nesting.

 Evidence: BnModel: division and multiplication; BnSpecs: frame protocol; W_fuzzA: concrete nonpool arguments.

 bignum: explicit liveness and nested-frame preservation
 This proof is stronger than the earlier bndiv-only inspection suggested. Its model defines live r s := r
 < NFIX + gx_used(ctx). The fixed-top division, multiplication, and squaring cores use bn_live; caller
 specifications establish wrapper inputs are live. A failed guard is an unreachable model branch that the
 proof must exclude; it is not an extra runtime sanitizer check.

 The audit traced all 15 textual frame starts in the arithmetic, Montgomery, and exponentiation models;
 there are 16 textual ends because one function has two mutually exclusive exit branches. Temporary
 lists returned by exponentiation-table construction remain in a still-active outer frame. The swapped
 result/scratch pair in word exponentiation is explicitly tracked. Context-preservation lemmas restore the
 used count and frame stack and preserve the earlier leased prefix.

 The continuations after frame end were also checked: Montgomery setup cleans a fixed RTmod buffer;
 reciprocal computation returns a scalar; reciprocal exponentiation frees fixed reciprocal-context buffers.
 These are not escaped references to the just-released temporary frame.

 Evidence: BgArith: bn_live and guarded arithmetic; BgInv: live; BgExpLoops: table reference invariants; BgExpWord:
 result/scratch roles.

 What this closes, and what it does not
 Positive result: there is a concrete proof-supported explanation for why the fixed client models avoid
 use after frame release or reuse. Missing allocation generations is not evidence that those clients are
 wrong.

 Remaining certification limit: current machine-step simulation does not label every load/store with its
 original lease. Model-level nonescape therefore should not be described as a newly proved universal
 temporal access trace for the complete binary.




Source review - no independent Rocq replay                                                                                2

<PARSED TEXT FOR PAGE: 3 / 6>

OPENSSL / CUSTOM ALLOCATOR PROOF AUDIT                                                                              24 OCT 2026




 2. Bounds reasoning at the instruction level
 The audit examined actual low-level proof routes, rather than treating object representations as
 sufficient evidence. These examples provide positive, code-specific bounds arguments.

   Audited operation            Concrete bounds evidence


   Multiply words               The scalar multiplication leaf requires n=length(source), a source limb-array
                                representation, destination space for 8*n bytes, and permitted aliasing. Tail iterations
                                expose one existing source element; unrolled iterations expose four elements and prove
                                32-byte source/destination bounds. Loads and stores use explicit loop-invariant read/store
                                facts.


   Copy a BIGNUM                Source and destination headers are separately represented and proved disjoint when
                                different. The copy length is exactly 8*source_top; source bytes are exhibited, destination
                                capacity is established after expansion, and the memcpy proof receives exact block
                                membership and range bounds.


   Convert input bytes          The byte-reading loop exposes each input byte from the known list. Output stores prove an
                                index inside the remaining limb array. Top-correction reads first establish an existing limb
                                through nth_error.


   Expand digit buffer          The proof distinguishes unchanged capacity from strict growth. It allocates a disjoint larger
                                ordinary-heap buffer, copies the significant limbs with explicit bounds, frees old digit
                                storage, and reconstructs the updated header/array representation.


 Sources: AW_mul_words; W_copyAF; W_bin2bnA; W_expandAF.

 Why this is not yet a universal logical-access theorem
 Primitive instruction tactics prove a successful read or store using available memory-cell facts at the
 computed address. They do not receive an independent pointer-origin or allocation-lease token. A
 caller/loop invariant can supply precise object bounds, as the examples above do; the primitive step
 relation itself does not impose them universally.

 The framing predicate is relational:

   munch W m m' :=
     forall x outside W, m'(x) = m(x).

 The local effect interpreter gives a precise example: if address a is readable, ELoad 64 a (fun _ =>
 EDone c) returns the same core and memory as EDone c. The read can target a different accessible
 object while leaving final-state predicates unchanged. A write followed by restoration can also preserve
 framing. This is a countermodel to the contract implication, not an instruction found in the original binary.

 The exported agreement theorem and routine postconditions describe machine error freedom, results,
 heap/state representations, ownership/accounting, and preserved memory. Access accounting also
 appears for virtual-memory materialization and budget reasoning, but the inspected uses do not attach
 each access to its original logical subobject and lease.

 Evidence: Lib/MState: effect interpreter; Lib/Frame: munch; BnIfaceA: postcondition; StepFast: cell-based loads.




Source review - no independent Rocq replay                                                                                    3

<PARSED TEXT FOR PAGE: 4 / 6>

OPENSSL / CUSTOM ALLOCATOR PROOF AUDIT                                                                           24 OCT 2026




 3. Assessment against checklist items 1-12
 These verdicts concern the inspected BN_CTX clients. "No general theorem" means the property is not supplied as a
 universal logical-access contract, not that the fixed client violates it.


   Case                           Assessment


   1. Suballocation bounds        Positive instruction-level evidence for audited operations. Separate header/limb
                                  layouts, disjointness, exact copy ranges, and loop bounds are present. No complete
                                  all-access logical-object certificate was derived across the entire binaries.


   2. Internal-release UAF        Fixed client discipline supported. All modeled temporary uses were traced before
                                  their owning frame ends. bignum has liveness guards and nested-frame preservation.
                                  Reusable primitive contracts are not a universal expired-reference detector.


   3. Custom double free          Relevant frame and heap discipline proved. Frame starts/ends are balanced;
                                  ordinary frees consume owned allocations. There is no arbitrary per-slot pool_free(p)
                                  operation on the audited path.


   4. Bulk clear/reset UAF        Same fixed-client result as item 2. BN_CTX_end releases temporaries; caller and
                                  frame invariants keep actual modeled uses within the owning frame.


   5. Shrink then old-tail        Operation absent. Pool headers are fixed-size. A smaller requested digit capacity does
   access                         not shrink the existing allocation.


   6. Moving reallocation         Ordinary digit-buffer growth handled. Allocate/copy/free/update is explicitly
                                  modeled and verified. Pool headers do not move; the retained-old-pool-storage scenario
                                  is not this operation.


   7. Stale same-slot reuse       No escaped stale reference found in the fixed models. Reference lists and pairs
                                  stay in active frames. The reusable reference representation has no identity for
                                  successive leases of one slot.


   8. Stale free of new           No per-slot free API exercised. Frame releases are balanced; ordinary buffer frees
   occupant                       require current ownership. No generic stale-handle deallocation theorem is supplied.


   9. Invalid/wrong-pool free     Scoped ownership checks. Modeled standard frees consume an exact owned
                                  allocation. Arbitrary interior, wrong-pool, wrong-family, and sized custom frees are not
                                  jointly exercised/verified as a general API.


   10. Other invalidations        Specific operations only. Frame release is handled; bignum verifies context
                                  destruction. bndiv retains its initialized context in this driver. Arbitrary
                                  transaction/cache/rewind lifecycles are outside these client models.


   11. Allocator-internal         Substantial scoped invariants. Slot separation, capacities, usage/frame consistency,
   defects                        ownership, and allocation accounting are proved. bignum covers richer bounded pool
                                  structures than bndiv; neither is an arbitrary-client allocator API theorem.


   12. Logical leaks              Positive scoped results. bignum returns with empty modeled ownership; bndiv
                                  preserves exact accounting of retained allocations and releases temporary usage. No
                                  general OpenSSL-wide logical leak theorem; runtime leak detection is off.




Source review - no independent Rocq replay                                                                                   4

<PARSED TEXT FOR PAGE: 5 / 6>

OPENSSL / CUSTOM ALLOCATOR PROOF AUDIT                                                                          24 OCT 2026




 4. Remaining checklist items and distinctions

   Case                           Assessment


   13. Jump over a redzone        No universal pointer-origin theorem. ASan checks the destination. Concrete
                                  arithmetic/layout reasoning may rule out a particular jump, but the top-level theorem
                                  does not independently attach every access to its originating object.


   14. Cross-field access         Layout and value reasoning, not a general field-origin certificate. BIGNUM digits
                                  are separately allocated. Source field boundaries also cannot be mechanically imposed
                                  on every machine access: a compiler may legally combine adjacent field accesses.


   15. Logical                    Contract-specific invariants. top is significant-word count; dmax is allocated capacity.
   length/capacity                Accessing spare capacity can be intentional. Numerical correctness and array capacity
                                  are proved; index<top is not a universal memory-safety rule.


   16. Destruction/storage        C++ destruction example not directly applicable. This is a C pool. API invalidation
   retained                       at BN_CTX_end is the relevant analogue. A general source-language
                                  object-lifetime/provenance theorem is not supplied.


   17. Uninstrumented             Still included in machine execution. Uninstrumented code has fewer sanitizer
   access                         checks, but can be reasoned about directly by the assembly proof. It is not automatically
                                  unverified. Logical object safety needs an additional appropriate relation.


   Uninitialized/residual data    No general initialization or confidentiality theorem. Numerical state tracking is not
                                  an MSan-style definedness property or a noninterference/zeroization proof.


   Alignment/size arithmetic      Enabled checks and specific arithmetic proofs. UBSan alignment and
                                  signed-arithmetic checks apply where that build is proved. Unsigned overflow and
                                  implicit conversion checks are not generally enabled. Not every arithmetic fault is
                                  automatically covered.


   Data races                     Outside the execution model. Single-threaded verification does not establish
                                  concurrent allocation/free or synchronization correctness.



 The other released OpenSSL targets
 The seven harnesses are bignum, bndiv, ct, echconfiglist_parser, hashtable, pem, and punycode. Their
 results must not be read as verification of arbitrary OpenSSL API clients. In particular, the pem proof fixes
 the secure heap to the disabled state and follows ordinary malloc/free fallback; it does not verify the
 secure buddy allocator. The hashtable driver repeats one selected payload, not an arbitrary sequence of
 independently chosen insert/delete operations.

 Common theorem/build scope: statements, building and sanitizer exclusions, OpenSSL inventory. The bignum cleanup result
 is fuzz_one_gwp.




Source review - no independent Rocq replay                                                                                 5

<PARSED TEXT FOR PAGE: 6 / 6>

OPENSSL / CUSTOM ALLOCATOR PROOF AUDIT                                                                             24 OCT 2026




 5. A precise reusable-model limitation
 A manual definitional reduction gives a concrete witness to what the bndiv primitive model does not
 automatically reject. Start from a well-formed one-frame context with 16 retained slots, one used slot,
 and frames=[0].

   Operation/state                       Result in the model


   Before end                            used=pused=1; frame stack=[0]; retained values have length 16.


   BN_CTX_end                            used=pused becomes 0; frame stack becomes empty; retained slot values are
                                         unchanged.


   valid_refm(RPool 0)                   Still true: it checks that index 0 is below the retained values length.


   bget(RPool 0), or primitive           Returns/updates the retained slot rather than rejecting an expired API lease.
   BN_set_negative


   Start and get again                   Returns RPool 0 again; old and new leases have the same reference identity.


 This witnesses a limitation of the reusable primitive model/contract. The actual bndiv client does not
 perform that post-end sequence. A source-level Rocq script for these reductions was drafted during the
 audit, but was not checked by Rocq; no kernel-checked counterexample is claimed.

 The analogous bignum situation is more nuanced: current liveness is represented and some arithmetic
 paths guard it, but lower primitive specifications and physical-slot representation do not universally
 require it. Thus it is inaccurate both to say "OpenSSL has no liveness reasoning" and to say "every
 primitive access requires its original live lease."

 Evidence: bndiv model end/get; bndiv physical validity; bignum reference identity; bignum primitive copy preconditions.

 What a stronger formal certification would require
 First define the intended property precisely: object/suballocation bounds, API lease expiration, and how
 references derived from an old lease are distinguished after reuse. Then relate concrete machine
 accesses to that logical state. One route is an access-aware invariant with ghost lease identities on
 references and derived pointers, checked across all reachable code. Another is a complete
 instruction-access derivation for these fixed clients. Runtime generation checks are not mandatory if a
 static proof supplies the needed relation.

 Audit limits and reproducibility
 All links refer to immutable proof commit 98e995d4daced70a0a4aa2c810854b88720735f1. The audit
 reviewed the common exported theorem form; the BN_CTX models, ownership and frame/liveness
 lemmas; concrete caller/refinement chains; instruction-step and framing machinery; and selected scalar
 multiply, copy, input-conversion, and expansion instruction proofs. The bndiv mirror contains 301 proof
 files (6.6 MB), all verified against pinned Git blob hashes; 59 selected bignum modules were also
 mirrored. These download counts are not claims of line-by-line review. The bignum spatial review
 covered 14 modules, with full reads of the scalar multiply and copy leaves; its temporal review traced all
 frame-owning model callsites.

 No entire-binary access trace was extracted, no new all-access theorem was proved, and no Rocq checker replay was
 performed. No actual bad spatial or temporal execution of the original verified programs was found. The precise conclusions
 are the positive scoped client proofs and the demonstrable limits of the exported and reusable contracts described above.




Source review - no independent Rocq replay                                                                                     6
