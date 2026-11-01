# Claim index

This index connects the paper's technical claims to the evidence needed to
check them. Start with the claim, read the named definition or theorem, then
follow the corresponding check in the [reproduction guide](../REPRODUCE.md).
Each entry states the limit of the conclusion.

Claim IDs remain fixed when the paper changes. Section and appendix numbers
refer to the manuscript present on 1 November 2026. This index does not change
the manuscript. The earlier [claim register](claim-register.md) records the
initial allocator review. Its `C` identifiers are separate from the IDs below.

| ID | Paper location | Claim | Check |
| --- | --- | --- | --- |
| G1 | Section 1; Appendix A | Agreement gives modeled error freedom and equal observable behaviors, under the statement's premises. | [Statement inspection](#agreement) |
| EX1 | Section 2.1; Appendix A | The reduced interpreter has a checked ASan agreement proof. | [Proof replay](#interpreter) |
| EX2 | Section 2.1; Appendix A | In both binaries, the twenty-first byte overwrites `op` and selects `h_admin`. Benign controls select `h_nop`. | [Retained traces and execution replay](#interpreter) |
| SPEC1 | Section 2.2; Appendices B–C | Address accessibility does not establish the bounds and lifetime of the object authorizing an access. | [Contract reasoning](#object-contracts) |
| SSL1 | Section 3.1; Appendix D | The local `bndiv` contracts accept an operation through an expired temporary. | [Model replay](#openssl) |
| SSL2 | Appendix D | The separate `bignum` model has an active-slot liveness guard. | [Definition and model replay](#openssl) |
| TURN1 | Section 3.2; Appendix E | The selected ASan invariant admits a destination one byte before `buf`. | [Countermodel replay](#coturn) |
| TURN2 | Section 3.2; Appendix E | The selected ASan+UBSan invariant admits the same field-bound violation. | [Countermodel replay](#coturn) |
| UP1 | Section 3.3; Appendix D | The inspected `pupnp` allocation lemma requires an empty cache. | [Contract inspection](#allocator-reviews) |
| MSG1 | Section 3.3; Appendix D | The reviewed `msgpack-c` harness omits clear-then-stale-use; its proof has allocation-fit and separation facts. | [Harness and proof inspection](#allocator-reviews) |
| SIMD1 | Section 3.3; Appendix D | The reviewed `simdjson` histories omit reparse-then-stale-use; selected proofs establish string and decoder bounds. | [Harness and proof inspection](#allocator-reviews) |
| BZ1 | Section 3.3; Appendix F | The compression development proves a round trip and bounds the selector-field stores. | [Proof inspection](#bzip2) |
| BZ2 | Section 3.3; Appendix F | The arbitrary-input decompression harness has no completed proof in the reviewed snapshot. | [Coverage inspection](#bzip2) |

The investigations use different inputs. Keep their revisions separate.

| Investigation | Proof revision | Additional identity |
| --- | --- | --- |
| Agreement context, allocator review, OpenSSL, bzip2 | `98e995d4daced70a0a4aa2c810854b88720735f1` | [Complete archive](source-snapshots/oss-verify-proofs/98e995d4/README.md) |
| Coturn | `a6839bb9e433b34c0d0710df5280194528877139` | Source `70ca74e0bd8300e22a179e9a7beead862763ca5c`; [provenance](dossiers/coturn-field-bounds/PROVENANCE.json) |
| Interpreter | `a6839bb9e433b34c0d0710df5280194528877139`, with the supplied registration patch | Example source `6c0b38af5c42556d8836a8360042f05943bb03d9`; [file and binary hashes](dossiers/checked-example/provenance.json) |

<a id="agreement"></a>
## Agreement

**G1.** Read the [pinned corpus description](source-snapshots/corpus/README.md)
and [model scope](source-snapshots/corpus/LPS-SCOPE.md). For a concrete formal
statement, inspect the interpreter's
[`asan_agrees`](dossiers/checked-example/proof/projects/example/core/Statements.v).
It instantiates `agrees_in` with an allocation policy, two memory budgets,
and the two binary images. The underlying definitions are in `theories/Shapes.v`
of the corresponding proof repository. The
[reproduction guide](../REPRODUCE.md#source-inspection) explains how to obtain
the pinned sources.

The conclusion concerns the modeled executions of those binaries. Its
premises include a source memory budget. A bound on input length does not
establish that premise. Agreement also does not require the program to
perform the operation its application intended. The
[scope report](context-and-properties.md) records these distinctions.

<a id="interpreter"></a>
## Interpreter

**EX1.** The top theorem is
[`asan_agrees_holds`](dossiers/checked-example/proof/proofs/example/core/asan_agrees/Proof.v).
It proves the supplied `asan_agrees` statement by applying
`strong_universal_error_free_core_asan`. The statement's images refer to
`core.plain` and `core.asan`. Their hashes are pinned in
[`harness.yaml`](dossiers/checked-example/proof/projects/example/core/harness.yaml).
The [cold-run log](dossiers/checked-example/replay/logs/example-check-cold.log)
records two successful checker steps and 15 allowed assumptions. The
[assumption report](dossiers/checked-example/replay/logs/assum-55.full) lists them.
The additional fresh-clone proof replay is incomplete. The
[validation record](../VALIDATION.md#fresh-clone) records the memory failure
and the stopped retry. The [interpreter proof instructions](../REPRODUCE.md#interpreter)
include the setup corrections and reduced parallelism.

**EX2.** In the [C source](dossiers/checked-example/example/example_core.c),
`fill` can copy 21 bytes into `buf[20]`. The next byte is `op` in the checked
builds. The supplied [triggering input](dossiers/checked-example/replay/example/inputs/core-exploit.bin)
contains the driver's six-byte prefix, twenty `A` bytes, and `0xff`.
The [execution replay](dossiers/checked-example/execution/README.md) runs the
exact plain and ASan binaries with this input and a benign control.
The traces captured on 1 November 2026 show the final copy store at offset
20, the subsequent `op` load, and the call to `h_admin`.
The benign input copies five bytes and reaches `h_nop`.

| Binary | Triggering input | Benign control |
| --- | --- | --- |
| Plain | [`op = 0xff`, `h_admin`](dossiers/checked-example/execution/retained/plain-exploit-instructions.trace) | [`op = 0`, `h_nop`](dossiers/checked-example/execution/retained/plain-benign-instructions.trace) |
| ASan | [`op = 0xff`, `h_admin`](dossiers/checked-example/execution/retained/asan-exploit-instructions.trace) | [`op = 0`, `h_nop`](dossiers/checked-example/execution/retained/asan-benign-instructions.trace) |

The [result](dossiers/checked-example/execution/retained/result.json) records
each store's address and value, with trace-line references for the load and
call. The [environment record](dossiers/checked-example/execution/retained/environment.json)
pins the binaries, inputs, runner, and QEMU executable. The
[trace checker](dossiers/checked-example/execution/check_trace.py) compares
the logged instructions with the supplied ELF files. Follow the
[execution instructions](../REPRODUCE.md#interpreter-execution) to check
the saved traces or capture new ones.

All four cases print `0` and exit successfully. The ASan runs emit no
sanitizer report. Both handlers are empty, so the observed consequence is
handler selection. These are four concrete execution checks, separate from
the agreement proof in EX1. The original proof files and checker logs are
unchanged.

<a id="object-contracts"></a>
## Object contracts

**SPEC1.** Appendices B–C give a contract argument. Two adjacent 50-byte
objects share one accessible 100-byte backing block. The address of `p[50]`
is in the block but outside the object allocated through `p`. After release,
`p` has expired even if the block remains allocated. Reusing the same bytes
for `r` creates a new lifetime; it does not restore the old reference.

Check each access against the stated object identity, bounds, lifetime,
and permissions. The examples assume successful allocations and the stated
pool contract. The unannotated examples also assume no ASan poisoning of
internal boundaries. These are explanatory constructions, not a supplied
pool implementation or a checked end-to-end memory-safety theorem.
The [bibliography in the paper](../paper/main.pdf) identifies the ASan and logical
memory-safety references. The [security report](reports/security-impact.md)
records the separate CMASan and HushVac evidence cited in Appendix B.
Those published experiments were not reproduced here.

<a id="openssl"></a>
## OpenSSL

**SSL1.** First compare the pinned
[API lifetime rule](source-snapshots/openssl/upstream/doc/man3/BN_CTX_start.pod)
with `valid_ref` in [BnInv.v](source-snapshots/openssl/proof/bndiv/Spec/BnInv.v),
`BN_CTX_end` in [BnModel.v](source-snapshots/openssl/proof/bndiv/Spec/BnModel.v),
and `BN_set_negative_spec` in [BnSpecs.v](source-snapshots/openssl/proof/bndiv/Spec/BnSpecs.v).
The model retains the pool values after frame end. The setter requires
`st_ok`, `own`, and `valid_ref`, but no active-frame condition.

The [checked construction](dossiers/openssl-lifetime/IndependentWitness.v)
starts at `ls_init`, obtains a temporary, initializes it to one, ends the
frame, and changes its sign. Read `all_setter_preconditions_after_end`,
`stale_write_accepted_by_exact_setter_spec`, and
`entire_synthetic_client_executes`. Together they establish that the complete
setter preconditions hold and the constructed model operation changes the value.
The [replay bundle](dossiers/openssl-lifetime/README.txt) supplies unchanged
upstream definitions, build scripts, and logs. Follow the
[OpenSSL replay](../REPRODUCE.md#openssl).

**SSL2.** The separate [BgInv.v](source-snapshots/openssl/proof/bignum/Spec/BgInv.v)
defines `live r s` using the active prefix `NFIX + gx_used (st_ctx s)`.
The bundle's `exp/BgStale.v` checks that frame end makes a temporary non-live
and that a later allocation can reuse its positional reference.
The [report](dossiers/openssl-lifetime/REPORT.txt) records the assumptions
and exact replay scope for both SSL1 and SSL2.

The published `bndiv` client uses its temporaries before frame end. SSL1 is
a result about the constructed model client and local contracts. It does
not establish an invalid access by that published client. The replay does
not check the full binary agreement certificates. SSL2 shows stronger
immediate liveness reasoning; it does not establish reference identity
across successive uses of the same slot.

<a id="coturn"></a>
## Coturn

**TURN1 and TURN2.** The final statements are in
[Complete.v](dossiers/coturn-field-bounds/reproduction/proof/Complete.v).

| ID | Theorem | Selected case |
| --- | --- | --- |
| TURN1 | `asan_decoded_case_admits_buf_minus_one` | Unit 752, cut `0x8d348`, case 1, `buf = sp0 - 1326956` |
| TURN2 | `both_decoded_case_admits_buf_minus_one` | Unit 845, cut `0x8c93c`, case 1, `buf = sp0 - 1327020` |

Case indices start at zero. Each theorem selects the case from the original
decoded certificate. It supplies memory and register values satisfying
the complete `gamma2` invariant with the original unit parameters. The
associated rank is nonnegative. The destination is `buf - 1`, the byte
is writable, and its ASan shadow byte is zero.

The [source layout](dossiers/coturn-field-bounds/upstream/coturn/src/apps/common/stun_buffer.h)
and [RV64 layout check](dossiers/coturn-field-bounds/checks/layout-rv64.txt)
identify `buf - 1` as `channel[3]`. The
[provenance record](dossiers/coturn-field-bounds/PROVENANCE.json) connects the
C excerpts and proof locations. The [result](dossiers/coturn-field-bounds/reproduction/result.json)
records 88 compiled sources. Its [assumptions](dossiers/coturn-field-bounds/reproduction/assumptions.txt)
are confined to the supplied upstream allowlist. Follow the
[coturn replay](../REPRODUCE.md#coturn) to rebuild the constructions.

These are countermodels to an implication from selected invariants to a
field bound. They do not establish a harness input reaching either state,
or an execution through the subsequent write. They do not establish a
coturn vulnerability or falsify its agreement theorem.

<a id="allocator-reviews"></a>
## Allocator reviews

**UP1.** In [H_freelist.v](source-snapshots/pupnp/proof/A0/AW/H_freelist.v),
inspect `FreeListAlloc_stmt_A` and its zero cache-head premise. Compare this
with the populated-cache branch of
[FreeList.c](source-snapshots/pupnp/upstream/upnp/src/threadutil/FreeList.c).
The lemma covers fresh allocation. `FreeListFree_post_A` and
`FreeListFree_stmt_A` separately describe return to the cache, including
backing ownership and uniqueness. The [pupnp report](reports/pupnp.md)
maps the corresponding plain and combined variants. This inspection does
not show a stale-node access in `FuzzHttp`.

**MSG1.** Compare the
[unpack/pack harness](source-snapshots/msgpack-c/oss-verify-proofs/98e995d4/projects/msgpack-c/unpack_pack_fuzzer/source/unpack_pack_fuzzer.cpp)
with `clear` in the
[zone implementation](source-snapshots/msgpack-c/msgpack-c/a5250ecb/include/msgpack/v1/detail/cpp11_zone.hpp).
The harness does not clear a zone and then use an old reference. In
[Steps.v](source-snapshots/msgpack-c/oss-verify-proofs/98e995d4/proofs/msgpack-c/unpack_pack_fuzzer/lib/Unp/Steps.v),
inspect `zalloc8_fits_ok`, `zalloc1_fits_ok`, and `zalloc_fresh_ok`.
The [report](reports/msgpack-c.md) explains their hypotheses and the
additional alignment and separation facts. The omitted client sequence
does not invalidate the theorem for the reviewed harness.

**SIMD1.** Start with the view-invalidation rule in
[element.h](source-snapshots/simdjson/simdjson/f807de97/include/simdjson/dom/element.h).
The [simdjson report](reports/simdjson.md) enumerates the ten proved harnesses
and their client sequences. Review each sequence when checking the claim
about retained views; one harness alone cannot establish that scope.
For the positive proof evidence, inspect `str_at` and `str_at_bounds` in
[SjTape.v](source-snapshots/simdjson/oss-verify-proofs/98e995d4/proofs/simdjson/fuzz_dump/lib/Sj/SjTape.v)
and `pstr_post_g` in
[Od_pstr_kit.v](source-snapshots/simdjson/oss-verify-proofs/98e995d4/proofs/simdjson/fuzz_ondemand/lib/P/Od_pstr_kit.v).
The report identifies the variant-specific decoder proofs. Decoder scratch
permissions may exceed the final string view. Compare an access with its
authorized region.

These three entries are source and selected-proof inspections. No fresh
full-corpus replay is claimed. Use the
[source-inspection route](../REPRODUCE.md#source-inspection) for files beyond
the selected local snapshots.

<a id="bzip2"></a>
## Bzip2

**BZ1.** At `98e995d4`, inspect `rt_small` and `b2b_round_trip` in
`proofs/bzip2/bzip2_compress_target/lib/Bz/BzRT.v`. They give the functional
round-trip result under their state and output-space premises. For the
selector bound, read the guard in `BzDBlock.v`, the two branches in
`B0F_dec_U5B.v`, and the loop invariant in `BzDU5.v`. These files are in the
same `Bz/` directory. The guard skips stores whose index is too large.
The [bzip2 report](reports/bzip2.md) gives exact locations and inspection commands.

**BZ2.** Compare the two harness sources under `projects/bzip2/` with
`index/proofs.tsv` and the decompression harness's statement status.
The proved compression harness supplies its compressed output to the
decompressor. The separate `bzip2_decompress_target` supplies input bytes
directly. Its statements remain open at the reviewed revision.
The [complete archive](source-snapshots/oss-verify-proofs/98e995d4/README.md)
contains the proof and harness files needed for both checks.

These are inspections of the published proof and coverage. We do not claim
a fresh bzip2 proof replay. A local bound for the selector loop does not
supply a completed arbitrary-input decompression proof. The coverage limit
does not establish a vulnerability in bzip2.

## Further sources

The [source register](source-register.md) and the paper's
[bibliography in the paper](../paper/main.pdf) identify the announcement, API
documentation, and published studies used for context. They are separate
from our checked constructions. The initial review's
[open questions](OPEN-QUESTIONS.md) retain unresolved scope questions.
Older records describe the state of their own investigation; their statements
about missing replay do not override the later OpenSSL and coturn results.
