# bzip2 in OSS Verify: Statement vs Proof

As of 2026-10-31 · Umang Mathur

## Purpose and claim

This document gives an independent reader everything needed to check one claim about the published OSS Verify proofs for bzip2. Every statement carries the file and line it rests on, and section 8 lists commands that reproduce each one.

The claim has three parts:

1. **The theorem is allocation-granular.** The proved statement `asan_agrees` forbids sanitizer reports, faults and behavioural divergence between two builds. An intra-object overflow of the CVE-2019-12900 kind (a write past a fixed array into sibling fields of the same `malloc`'d struct) produces none of these, so the theorem would remain true of a binary that contained that bug.
2. **The proof is field-granular anyway.** To refine the binary to its functional model, the proof carves the 64,144-byte `DState` into one cell per field and shows, for every 15-bit selector count, that the compiled loop stores only into `selectorMtf`. That in-bounds fact exists as an internal lemma with a generated file name and stripped comments; the statement, README and harness page never mention it.
3. **The harness that matters is unproved.** Only `bzip2_decompress_target` hands attacker-controlled bytes to the decompressor. It has 15 statements and no proof, at the audited commit and on `main` today.

Nothing here claims a live bug: the corpus pins bzip2 1.0.8, which carries the fix.

## Materials

All line numbers below refer to these exact revisions. Both source trees are public; the hashes let a reader confirm they have the same bytes.

| Item | Where | Revision |
| --- | --- | --- |
| Proof repository | [theorem-labs/oss-verify-proofs](https://github.com/theorem-labs/oss-verify-proofs) | commit `98e995d4daced70a0a4aa2c810854b88720735f1` (2026-10-23, release 2026.10.0; the audited snapshot) |
| Later releases checked for status changes | same repository | tags `v2026.10.1`, `v2026.10.2`; `main` = `a6839bb9e` |
| bzip2 library source | [sourceware.org/git/bzip2](https://sourceware.org/git/bzip2) | commit `f5dfc96063fef2d9c5446d0733867d899ef9b942` (version string `1.0.8, 13-Jul-2019`) |
| Same source, as the corpus shipped it | release asset `bzip2-src.tar.zst` of [v2026.10.0-src](https://github.com/theorem-labs/oss-verify-proofs/releases/tag/v2026.10.0-src) | sha256 `0158ca5f92fd5ef924c6034f87a6d72d5a04a704e03b9944e819f65c9065d3de`; unpacks to `bzip2-src/git/bzip2-f5dfc96063fe/` |
| Build recipe | release asset `recipe.tar.zst` of the same release | sha256 `0339bf3221b15cd39513d46abe99062bac9cce874ed7ba5947753f75b6219ae5`; bzip2 pins under `recipe/targets/bzip2-*/pin` |
| Harness sources | `projects/bzip2/<harness>/source/*.c` in the proof repository | unmodified copies of OSS-Fuzz `projects/bzip2/*.c` at `bd2ce219` |
| Process semantics (LPS) | [theorem-labs/rocq-linux-process-semantics](https://github.com/theorem-labs/rocq-linux-process-semantics) | commit `f1006fe8` (from `release.yaml`) |

Commands:

```bash
git clone https://github.com/theorem-labs/oss-verify-proofs.git
cd oss-verify-proofs && git checkout 98e995d4daced70a0a4aa2c810854b88720735f1

# bzip2 at the pinned commit (either route)
git clone https://sourceware.org/git/bzip2 && cd bzip2 && git checkout f5dfc96063fef2d9c5446d0733867d899ef9b942
# or: the release's own copy
curl -L -O https://github.com/theorem-labs/oss-verify-proofs/releases/download/v2026.10.0-src/bzip2-src.tar.zst
zstd -d bzip2-src.tar.zst && tar xf bzip2-src.tar
```

Paths in later sections are relative to the proof repository root unless they start with `bzip2/`, which means the bzip2 source tree.

## The C code

`DState` is one struct, allocated once, holding two 18,002-byte input-filled arrays directly in front of the Huffman tables and, further along, three pointers.

**The struct.** `bzip2/bzlib_private.h:345–438` (`/*-- Structure holding all the decompression-side stuff. --*/` at 345, `DState;` at 438). Constants: `BZ_MAX_ALPHA_SIZE 258` (115), `BZ_N_GROUPS 6` (121), `BZ_G_SIZE 50` (122), `BZ_MAX_SELECTORS (2 + (900000 / BZ_G_SIZE))` = 18,002 (125). The fields that matter, with their declaration lines and byte offsets:

| Field | Declared at | Offset (bytes) | Size | Ends at |
| --- | --- | --- | --- | --- |
| `UChar selector[18002]` | 402 | 7,884 | 18,002 | 25,886 |
| `UChar selectorMtf[18002]` | 403 | 25,886 | 18,002 | 43,888 |
| `UChar len[6][258]` | 404 | 43,888 | 1,548 | 45,436 |
| `Int32 limit[6][258]` | 406 | 45,436 | 6,192 | 51,628 |
| `Int32 base[6][258]` | 407 | 51,628 | 6,192 | 57,820 |
| `Int32 perm[6][258]` | 408 | 57,820 | 6,192 | 64,012 |
| `Int32 minLens[6]` | 409 | 64,012 | 24 | 64,036 |
| `Int32 save_i` … `save_gMinlen` (21 scalars) | 412–432 | 64,036 | 84 | 64,120 |
| `Int32* save_gLimit`, `save_gBase`, `save_gPerm` | 433–435 | 64,120 | 24 | 64,144 |
| `sizeof(DState)` | | | 64,144 | |

Offsets were computed by compiling `offsetof(DState, f)` against the pinned header on an LP64 target (program in section 8). The proof's own layout arithmetic gives the same numbers (section 6).

**The allocation.** `bzip2/bzlib.c:508`, inside `BZ2_bzDecompressInit` (492): `s = BZALLOC( sizeof(DState) );`. `BZ2_bzBuffToBuffDecompress` (1302), which every harness calls, goes through it. So the whole table is one heap block.

**The selector loop, 1.0.8 (pinned).** `bzip2/decompress.c:286–318`, inside `BZ2_decompress` (106):

```c
/* 289 */ GET_BITS(BZ_X_SELECTOR_2, nSelectors, 15);     /* 15 bits from the stream: 0..32767 */
/* 290 */ if (nSelectors < 1) RETURN(BZ_DATA_ERROR);
/* 291 */ for (i = 0; i < nSelectors; i++) {
/* 292 */    j = 0;
/* 293 */    while (True) {                                /* unary-decode one value j < nGroups <= 6 */
/* 294 */       GET_BIT(BZ_X_SELECTOR_3, uc);
/* 295 */       if (uc == 0) break;
/* 296 */       j++;
/* 297 */       if (j >= nGroups) RETURN(BZ_DATA_ERROR);
/* 298 */    }
/* 302 */    if (i < BZ_MAX_SELECTORS)                     /* guard: 1.0.8 */
/* 303 */      s->selectorMtf[i] = j;
/* 304 */ }
/* 305 */ if (nSelectors > BZ_MAX_SELECTORS)              /* clamp: 1.0.8 */
/* 306 */   nSelectors = BZ_MAX_SELECTORS;
/* 313 */ for (i = 0; i < nSelectors; i++) {              /* undo move-to-front */
/* 314 */    v = s->selectorMtf[i];
/* 318 */    s->selector[i] = tmp;
/* 319 */ }
```

The selectors are read back at `decompress.c:81` (`gSel = s->selector[groupNo]`, in the `GET_MTF_VAL` macro), one per run of 50 symbols; a full 900,000-byte block needs 18,000 of them, hence the array size.

**The same loop in 1.0.6.** Lines 302, 305–306 did not exist. From the mirror `libarchive/bzip2`, tag `bzip2-1.0.6`, `decompress.c`: the count check at 290 is identical, the unguarded store `s->selectorMtf[i] = j;` is at 299, and the undo loop at 307–312 writes `s->selector[i] = tmp;` at 312 for the same unclamped range of `i`. A stream declaring `nSelectors = 32767` therefore writes `selectorMtf[18002..32766]`: 14,765 bytes past the array, through `len`, `limit`, `base` and into `perm`, the last byte at offset 58,652. It then writes `selector[18002..32766]`, which lands inside `selectorMtf` (offsets 25,886–40,650). Every byte stays inside the 64,144-byte block; the pointers begin 5,468 bytes beyond the last written byte.

**The fix history**, from the same mirror and from `bzip2/CHANGES:336–348`:

| Version | Commit | Change |
| --- | --- | --- |
| 1.0.7 (2019-06-27) | `7ed62bf`, Albert Astals Cid, 2019-05-28, "Make sure nSelectors is not out of range" | line 290 becomes `if (nSelectors < 1 \|\| nSelectors > BZ_MAX_SELECTORS) RETURN(BZ_DATA_ERROR);` — reject the stream. Commit message: found "while fuzzying karchive"; assigned CVE-2019-12900 |
| 1.0.8 (2019-07-13) | `812a898`, Mark Wielaard, 2019-07-03, "Accept as many selectors as the file format allows" | replaces the rejection with the guard at 302 and the clamp at 305–306, because real encoders emit more than 18,002 selectors (`CHANGES:345–348`) |

The corpus pins a commit after the 1.0.8 tag: `diff -rq` against the mirror's `bzip2-1.0.8` shows 13 files that differ (`Makefile`, `bzlib.c`, `bzlib.h`, `compress.c`, `bzip2.c`, man pages), while `decompress.c` and `bzlib_private.h` are byte-identical to the tag and `BZ_VERSION` is `"1.0.8, 13-Jul-2019"` (`bzip2/bzlib_private.h:39`). So the verified binary has the guard, and every `decompress.c` line number above also holds for the 1.0.8 release.

## Corpus status

Of the three bzip2 harnesses in the corpus, the one that feeds attacker-controlled bytes to the decompressor is the one with no proof.

| Harness | What reaches `BZ2_decompress` | Source lines | Statements | Proved at `98e995d4` | Proved on `main` (`v2026.10.2`) |
| --- | --- | --- | --- | --- | --- |
| `bzip2_compress_target` | the compressor's own output: compress the input (64), decompress the result (77), then `assert(nOut == size)` (88) and `assert(memcmp(data, outbuf, size) == 0)` (89) | `projects/bzip2/bzip2_compress_target/source/bzip2_compress_target.c:41–91` | 15 | `asan_agrees`, `asan_ubsan_agrees` | + `ubsan_agrees` |
| `bzip2_fd` | the compressor's own output: `BZ2_bzWrite` to a temp file (40), `BZ2_bzRead` it back (55); bytes discarded | `projects/bzip2/bzip2_fd/source/bzip2_fd.c:35–58, 63–96` | 15 | none | none |
| `bzip2_decompress_target` | **the raw input**: `BZ2_bzBuffToBuffDecompress(outbuf, &nOut, data, size, …)` (52) | `projects/bzip2/bzip2_decompress_target/source/bzip2_decompress_target.c:34–60` | 15 | none | none |

Evidence:

- `index/proofs.tsv:8–9` lists the two compress-target proofs and no other bzip2 row.
- `index/harnesses.tsv:88–90`: `bzip2_compress_target … 15 13 2 0 0 0 0`, `bzip2_decompress_target … 15 15 0 0 0 0 0`, `bzip2_fd … 15 15 0 0 0 0 0` (columns: statements, open, proved, false, suspected_false, blocked_by_model, withheld).
- `docs/status.md:78`: `open` means "nobody has proved or refuted it". `withheld` (85) is a separate status, and bzip2 has no withheld statement, so the absence is not a held-back proof.
- `projects/bzip2/bzip2_decompress_target/README.md:26–28` states the three agreement statements for that harness, each marked `open`.
- `git show v2026.10.2:index/harnesses.tsv | grep ^bzip2` gives `bzip2_compress_target 15 12 3`, `bzip2_decompress_target 15 15 0`, `bzip2_fd 15 15 0`.

One inconsistency worth knowing: `projects/bzip2/bzip2_compress_target/README.md:14` says the harness "makes no check of its own beyond not crashing", but the harness asserts the round trip (lines 88–89), and the repository's own `docs/exploring.md:43` says the proof establishes that assertion. The proof is stronger than the harness page admits.

## The theorem statement

The statement has no vocabulary for objects, fields or bounds; it speaks only of errors, traces and a memory budget, and its own comment says memory errors ASan cannot detect are not claimed.

**The definition.** `projects/bzip2/bzip2_compress_target/Statements.v:98–99`:

```coq
Definition asan_agrees : Prop :=
  agrees_in Env.alloc_forced_only Budgets.Asan.lim_source Budgets.Asan.lim_target Images.plain Images.asan.
```

`agrees_in` is defined in `theories/Shapes.v:143–152`:

```coq
Definition agrees_in (env : SpuriousCfg) (lim_plain lim_san : Z) (plain san : Image) : Prop :=
  forall (en_plain en_san : ExecEntry) (inp : ProcInput),
    valid_entry plain en_plain inp ->
    valid_entry san en_san inp ->
    valid_input inp ->
    ~ run_scfg_budget_refused env plain lim_plain en_plain inp ->
    error_free (run_scfg env plain lim_plain en_plain inp)
    /\ error_free (run_scfg env san lim_san en_san inp)
    /\ trace_equiv (bh_traces (run_scfg env plain lim_plain en_plain inp))
                   (bh_traces (run_scfg env san lim_san en_san inp)).
```

`Shapes.v:154–156` proves by `reflexivity` that this is literally LPS's `strong_universal_error_free_T_scfg_budgets`. The three conjuncts are: the plain run reaches no error; the ASan run reaches no error; the two runs have the same observable traces (bytes written, exit status).

**What "error" means.** `README.md:98`: a crash, an invalid memory access, an `abort()` (failed `assert()`, sanitizer report, uncaught C++ exception), a failed UBSan check, or a step LPS does not interpret. Same list at `docs/semantics.md:107–112`. An invalid memory access here is a fault at the process level (an access to an unmapped page), not an access outside a C object.

**The authors' own carve-out.** The comment above the definition, `Statements.v:84–97`, ends:

> Not claimed: anything about inputs on which the plain build needs more than 2 GiB; memory errors ASan does not detect (for example an access that lands inside another live object, or one made in code it does not instrument).

This sentence is a template: `grep -rl "inside another live object" projects/*/*/Statements.v | wc -l` returns 2142, one per harness. Its named example is an overflow that skips a redzone into a *different* allocation. An overflow that stays inside the *same* allocation, the case in this document, is not named but falls under "memory errors ASan does not detect". The sentence appears nowhere in `README.md` or `docs/*.md`; the README's own list of what a proof does not say (`README.md:107–108`) gives "a wrong result or a memory leak" as its examples.

**Consequence.** Take the 1.0.6 loop of section 3 and a stream with 32,767 selectors. In the plain build, 14,765 bytes of `len`/`limit`/`base`/`perm` are overwritten with small integers (each a value below 6). The selectors are read before the tables: `decompress.c:322–335` then fills `len[t][0..alphaSize)` from the stream for every group in use, and `BZ2_hbCreateDecodeTables` (`decompress.c:345`, `huffman.c:170`) rebuilds `limit`, `base` and `perm` from `len`. Wielaard's analysis of the maximal 32,767-selector file found no change in behaviour, and Valgrind reported nothing. No fault, no abort, same output. In the ASan build, the same bytes are written; they lie inside one live allocation, so no shadow byte is poisoned and no report is issued. The three conjuncts of `agrees_in` all hold. The theorem would be true of that binary.

## The Rocq proof

The proof refines both binaries to a functional model of bzip2, and to do so it carves `DState` into one memory cell per field and proves the selector loop in-bounds for every 15-bit count. All paths below are under `proofs/bzip2/bzip2_compress_target/lib/`.

**Scale and form.** The bzip2 proof directory holds 1,998 `.v` files and 743,479 lines. 1,991 of those files contain the marker `(* [comment removed for export] *)`; `BzDBlock.v` alone has 98 such markers. File names are generated (`B0F_dec_U5B.v`, `BzR5cF.v`).

**The model of `DState`.** `Bz/BzDState.v:33` sets `BZ_MAX_SELECTORS : Z := 18002`. `Bz/BzDState.v:111–153` is `Record dst`, the decompressor state, with one field per C field: `d_sel` (146), `d_selMtf` (147), `d_len` (148), `d_limit` (149), `d_base` (150), `d_perm` (151), `d_minLens` (152) and `d_sv : dsv` (153), where `Record dsv` (38–60) holds the saved scalars, `sv_nSelectors` among them (44). `Bz/BzDefs.v:60`: `DSTATE_SIZE : Z := 64144`.

**The functional model of the loop.** `Bz/BzDBlock.v:577–590` transcribes `decompress.c:289–319`, state by state. State 21 reads the count and rejects `< 1` (577–578). State 22 is one iteration of the first loop (579–590); its store is

```coq
let d1 := if i <? BZ_MAX_SELECTORS then d_set_selMtf d (zset (d_selMtf d) i j) else d in   (* line 582 *)
```

which is the 1.0.8 guard, and line 587 is the clamp (`let nSel := if BZ_MAX_SELECTORS <? sv_nSelectors L then BZ_MAX_SELECTORS else sv_nSelectors L`). The model therefore describes the fixed code; it is not a specification written from the file format.

**The field layout in the refinement.** `Bz/GlueCarve.v:238–251` peels the struct's bytes into cells at `S + 7884` (selector), `S + 25886` (selectorMtf), `S + 43888` (len), `S + 45436` (limit), `S + 51628` (base), `S + 57820` (perm), `S + 64012` (minLens), `S + 64036` (the save area). These are the offsets of section 3, derived independently.

**The loop invariant.** `Bz/BzDU5.v:325–328`:

```coq
Definition dinv_L5I (L : dsv) (d : dst) : Prop :=
  alpha_ok L d /\ 2 <= sv_nGroups L <= 6 /\ 1 <= sv_nSelectors L < 32768 /\ 0 <= sv_i L < sv_nSelectors L /\
  0 <= sv_j L < sv_nGroups L /\
  belown (d_selMtf d) (Z.min (sv_i L) 18002) (sv_nGroups L).
```

`belown a n ng` (`BzDU5.v:109`) says the first `n` entries of `a` are in `[0, ng)`. The count is bounded only by its 15-bit width, so the invariant covers streams declaring up to 32,767 selectors. The undo loop's invariant `dinv_HUND` (330–332) uses `Z.min (sv_nSelectors L) 18002`, the clamped count.

**The binary-level lemma.** `Bz/B0F_decCuts5.v:66–84` defines the cut `B0F_cut_L5I`: for every `L : dsv`, `d : dst` and machine memory `m` satisfying the field-cell layout and `dinv_L5I L d` (line 80), running the compiled loop body from its entry refines the model's `drun F 32 L d s`. `Bz/B0F_dec_U5B.v:75–124` proves it (`Lemma B0F_U5_L5I`). Inside:

- line 83 names the memory regions the body may touch: `(S, S + 68)`, `(S + 25886, S + 43888)` — the scalar header and `selectorMtf`, nothing else of `DState`;
- line 90, `if_cases K18`, splits on the compiled guard `i < 18002`;
- lines 92–98, guard false: no store, execution runs to the loop increment at `0xb0a34`;
- lines 99–110, guard true: execution runs to the store at `0xb0d04` (101), and `zb8_sb H (sv_i L)` (103) updates byte `sv_i L` of the `u8arr` cell at `S + 25886`, which requires `0 ≤ sv_i L < 18002`.

The sibling section `Bz/B0F_dec_U5C.v:70–75` states the same bounds as explicit hypotheses: `NS : 1 <= sv_nSelectors L < 32768` and `nsc := Z.min (sv_nSelectors L) 18002`.

Read as a fact about the binary: for any selector count the stream can encode, the compiled loop writes only into `selectorMtf`, never past it. This is the in-bounds property for the CVE-2019-12900 site.

**Where the compressor's bound enters.** The end-to-end theorem is the round trip: `Bz/BzRT.v:238` `b2b_round_trip` (and `rt_small`, 215): decompressing the modelled compressor's output returns `(BZ_OK, length payload, payload)`. The model-level lemmas that drive the decoder over an encoder-produced stream assume the count is in range: `Bz/BzR5cF.v:228` (`sv_nSelectors L <= BZ_MAX_SELECTORS`) and `:494` (`1 <= nS <= BZ_MAX_SELECTORS`), discharged from the compressor-side facts `Bz/BzCFactsSd.v:17` (`1 <= nSel <= 18002`). So the general in-bounds lemma is instantiated, in the proved harness, only on counts that are already in range. `docs/exploring.md:43` is the repository's own description of what this proof shows, including the `memcmp` walk.

**What a 1.0.6 binary would have required.** The cell layout forces the refinement to say which cell each store hits. Without the guard, stores for `i ≥ 18002` would hit the `len`, `limit`, `base` and `perm` cells; the agent would have had to model them there (a different `BzDBlock.v:582` and a different region list at `B0F_dec_U5B.v:83`), and the round-trip argument would be unchanged, since encoder output never reaches those stores. Nothing in `agrees_in` would have blocked that proof. The in-bounds lemma exists because the code has the guard, not because the theorem asked for it.

## The argument

Each step names the evidence it rests on; a reader who rejects a step should be able to say which cited line fails to support it.

1. **`asan_agrees` forbids exactly three things**: an error in the plain run, an error in the ASan run, and a difference in observable traces. (`theories/Shapes.v:143–152`; the error list at `README.md:98`.) It has no clause about C objects, fields or array bounds.
2. **A same-allocation overflow triggers none of the three.** ASan poisons shadow bytes only for redzones around allocations and for freed memory; the ASan build here is plain `-fsanitize=address` with compiler-rt 20 defaults (`docs/building.md:86, 109–135`), so a store inside a live allocation is never reported. The 1.0.6 selector loop's stores all fall inside the 64,144-byte `DState` block (section 3 offsets). The clobbered tables are rebuilt before use (`decompress.c:322–345`), so plain and ASan builds produce the same output. Hence a 1.0.6 binary would satisfy `asan_agrees`.
3. **The authors say as much.** `Statements.v:95–97`, in all 2,142 harnesses: "Not claimed: … memory errors ASan does not detect". This caveat is absent from `README.md` and `docs/`.
4. **The same bug would falsify `ubsan_agrees`.** The UBSan build enables `array-bounds` in trap mode (`docs/building.md:85, 95–98`), and `s->selectorMtf[i]` indexes an array of statically known size, so the UBSan build traps where the plain build continues. This matches the bug's history: found by a fuzzer under UBSan (1.0.7 commit `7ed62bf`), unseen by Valgrind on the maximal file (Wielaard). The two sanitizer statements are therefore not interchangeable, and the ASan-only statement is the weaker one on this bug class. The caveat for the paper: UBSan sees this instance only because the index is syntactically visible; a `memcpy` into the same array would be invisible to both.
5. **The actual proof establishes the in-bounds fact anyway.** `Bz/BzDU5.v:325–328` (`dinv_L5I`, count bounded only by `< 32768`), `Bz/B0F_dec_U5B.v:83, 90–110` (store confined to `(S + 25886, S + 43888)`, both guard branches walked), `Bz/B0F_dec_U5C.v:73–75`. This is a stronger property than the theorem states, proved for every 15-bit count.
6. **It is established as a by-product, not as a specification.** The refinement needs per-field cells (`Bz/GlueCarve.v:238–251`) and so must know which field each store hits. The model transcribes the fixed code including the guard (`Bz/BzDBlock.v:582, 587`). A 1.0.6 binary would have produced a model with the overflow transcribed into the neighbouring cells and the same top-level theorem (section 6, last paragraph).
7. **It is unstated and unaudited.** The fact appears in no `Definition` under `projects/`, in no README, and in `docs/exploring.md:43` only as the round-trip property. It lives in files with generated names, among 743,479 lines, with every explanatory comment replaced by `(* [comment removed for export] *)` (1,991 of 1,998 files).
8. **The harness that matters has no proof.** `bzip2_decompress_target` is the only bzip2 harness that passes attacker-controlled bytes to `BZ2_decompress` (`bzip2_decompress_target.c:52`); its 15 statements are `open` at `98e995d4`, `v2026.10.1` and `v2026.10.2` (`index/harnesses.tsv:89`; `docs/status.md:78`). The proved harness instantiates the general lemma only on compressor output, whose count is at most 18,002 (`Bz/BzCFactsSd.v:17`, `Bz/BzR5cF.v:228, 494`).

**Conclusion.** The statement `asan_agrees` does not entail the absence of intra-object overflows; a CVE-numbered instance of that class, in this very code path, would have left it true. The published proof happens to contain the in-bounds property for the fixed code, but as an internal lemma the statement never asks for, in a form no reader is expected to inspect, and only for a harness in which the relevant branch is never taken on covered inputs. The harness that exercises the branch on adversarial input is unproved.

## Verification checklist

Run from the proof repository root at `98e995d4`. These outputs were checked on 2026-10-31. Row 7 counts only the files present in the checkout. Its whole-corpus total requires the complete `projects/` tree. The sparse checkout in the reproduction guide gives the smaller count shown below. Other mismatches indicate a different revision or an error in this document.

| # | Supports | Command | Expected output |
| --- | --- | --- | --- |
| 1 | revision | `git rev-parse HEAD` | `98e995d4daced70a0a4aa2c810854b88720735f1` |
| 2 | step 8 | `grep -n ^bzip2 index/harnesses.tsv \| cut -f1-7` | `88:…compress_target…15 13 2`, `89:…decompress_target…15 15 0`, `90:…bzip2_fd…15 15 0` |
| 3 | step 8 | `sed -n 8,9p index/proofs.tsv \| cut -f1-3` | two rows, both `bzip2 bzip2_compress_target` (`asan_agrees`, `asan_ubsan_agrees`) |
| 4 | step 8 | `sed -n 78p docs/status.md` | `\| open \| nobody has proved or refuted it \|` |
| 5 | step 8 | `git show v2026.10.2:index/harnesses.tsv \| grep ^bzip2 \| cut -f2,5,6,7` | `compress_target 15 12 3`, `decompress_target 15 15 0`, `fd 15 15 0` |
| 6 | steps 1, 3 | `sed -n 95,99p projects/bzip2/bzip2_compress_target/Statements.v` | the "Not claimed" sentence, then `Definition asan_agrees : Prop := agrees_in …` |
| 7 | step 3 | `grep -rl "inside another live object" projects/*/*/Statements.v \| wc -l` | `2142` with the complete `projects/` tree; `53` with the guide's sparse checkout |
| 8 | step 3 | `grep -rn "ASan does not detect" README.md docs/` | no output; exit code `1` means no match |
| 9 | step 1 | `sed -n 143,152p theories/Shapes.v` | the `agrees_in` definition with `error_free`, `error_free`, `trace_equiv` |
| 10 | step 4 | `sed -n 95,98p docs/building.md` | the UBSan check list, containing `array-bounds` |
| 11 | step 2 | `sed -n 86p docs/building.md; sed -n 133,135p docs/building.md` | `-fsanitize=address` row; "Every other runtime option has its compiler-rt 20 default" |
| 12 | step 6 | `sed -n 33p proofs/bzip2/bzip2_compress_target/lib/Bz/BzDState.v` | `Definition BZ_MAX_SELECTORS : Z := 18002.` |
| 13 | step 6 | `sed -n 582p proofs/bzip2/bzip2_compress_target/lib/Bz/BzDBlock.v` | `let d1 := if i <? BZ_MAX_SELECTORS then d_set_selMtf d (zset (d_selMtf d) i j) else d in` |
| 14 | step 5 | `sed -n 325,328p proofs/bzip2/bzip2_compress_target/lib/Bz/BzDU5.v` | `dinv_L5I` with `1 <= sv_nSelectors L < 32768` and `belown (d_selMtf d) (Z.min (sv_i L) 18002) …` |
| 15 | step 5 | `sed -n 83p proofs/bzip2/bzip2_compress_target/lib/Bz/B0F_dec_U5B.v` | region list containing `(S + 25886, S + 43888)` |
| 16 | step 5 | `sed -n 90p proofs/bzip2/bzip2_compress_target/lib/Bz/B0F_dec_U5B.v` | `brun; if_cases K18; zify_cond_z K18.` |
| 17 | step 5 | `sed -n 101,103p proofs/bzip2/bzip2_compress_target/lib/Bz/B0F_dec_U5B.v` | `brun_to 0xb0d04%Z.` then the `u8arr _ _ (S + 25886)` match and `zb8_sb H (sv_i L)` |
| 18 | step 5 | `sed -n 73,75p proofs/bzip2/bzip2_compress_target/lib/Bz/B0F_dec_U5C.v` | `nsc := (Z.min (sv_nSelectors L) 18002)`, `NG`, `NS : (1 <= sv_nSelectors L < 32768)` |
| 19 | step 6 | `sed -n 60p proofs/bzip2/bzip2_compress_target/lib/Bz/BzDefs.v; grep -c "S + 25886" proofs/bzip2/bzip2_compress_target/lib/Bz/GlueCarve.v` | `DSTATE_SIZE : Z := 64144`; `2` |
| 20 | step 8 | `sed -n 17p proofs/bzip2/bzip2_compress_target/lib/Bz/BzCFactsSd.v` | contains `(1 <= nSel <= 18002)` |
| 21 | step 7 | `find proofs/bzip2 -name '*.v' \| wc -l; grep -rL "comment removed for export" proofs/bzip2 --include='*.v' \| wc -l` | `1998`; `7` (so 1,991 files carry the marker) |
| 22 | step 7 | `sed -n 43p docs/exploring.md` | the bzip2 row: "Decompressing the compressor's output gives back the input…", citing `rt_small` and the `memcmp` walk |

In the bzip2 source tree at `f5dfc960`:

| # | Supports | Command | Expected output |
| --- | --- | --- | --- |
| 23 | section 3 | `sed -n 125p bzlib_private.h` | `#define BZ_MAX_SELECTORS (2 + (900000 / BZ_G_SIZE))` |
| 24 | section 3 | `sed -n 402,409p bzlib_private.h` | `selector`, `selectorMtf`, `len`, (blank), `limit`, `base`, `perm`, `minLens` |
| 25 | section 3 | `sed -n 433,435p bzlib_private.h` | `save_gLimit`, `save_gBase`, `save_gPerm` |
| 26 | section 3 | `sed -n 508p bzlib.c` | `s = BZALLOC( sizeof(DState) );` |
| 27 | section 3 | `sed -n 289,291p decompress.c; sed -n 302,306p decompress.c` | the 15-bit read, `< 1` check, loop head; then the guard, the store, the clamp |
| 28 | section 3 | `sed -n 39p bzlib_private.h` | `#define BZ_VERSION  "1.0.8, 13-Jul-2019"` |
| 29 | section 3 | `sed -n 342,348p CHANGES` | the 1.0.8 entry: "Accept as many selectors as the file format allows. This relaxes the fix for CVE-2019-12900…" |

Offsets (any LP64 host; `clang -w off.c && ./off`), with the two headers copied beside it:

```c
#include <stdio.h>
#include <stddef.h>
#include "bzlib_private.h"
#define P(f) printf("%-12s %6zu %6zu\n", #f, offsetof(DState, f), sizeof(((DState*)0)->f))
int main(void) {
  printf("sizeof(DState) = %zu\n", sizeof(DState));
  P(selector); P(selectorMtf); P(len); P(limit); P(base); P(perm); P(minLens); P(save_i); P(save_gLimit);
  return 0;
}
```

Expected: `64144`; `selector 7884 18002`; `selectorMtf 25886 18002`; `len 43888 1548`; `limit 45436 6192`; `base 51628 6192`; `perm 57820 6192`; `minLens 64012 24`; `save_i 64036 4`; `save_gLimit 64120 8`.

History, in a clone of `github.com/libarchive/bzip2` (a mirror; the pinned commit itself is not in it):

| # | Supports | Command | Expected output |
| --- | --- | --- | --- |
| 30 | section 3 | `git show bzip2-1.0.6:decompress.c \| sed -n 290,291p;  git show bzip2-1.0.6:decompress.c \| sed -n 299p` | `if (nSelectors < 1) RETURN(BZ_DATA_ERROR);`, the loop head, then the unguarded `s->selectorMtf[i] = j;` |
| 31 | section 3 | `git show bzip2-1.0.7:decompress.c \| sed -n 290p` | `if (nSelectors < 1 \|\| nSelectors > BZ_MAX_SELECTORS) RETURN(BZ_DATA_ERROR);` |
| 32 | section 3 | `git log -1 --format='%an %ad %s' --date=short 7ed62bf` | `Albert Astals Cid 2019-05-28 Make sure nSelectors is not out of range` |
| 33 | section 3 | `git log -1 --format='%an %ad %s' --date=short 812a898` | `Mark Wielaard 2019-07-03 Accept as many selectors as the file format allows.` |

## Not claimed, and open points

The argument is about what the theorem can say, not about a defect in the verified binary.

**Not claimed.**

- That the verified bzip2 binary contains the overflow. It pins a post-1.0.8 commit; the guard is at `decompress.c:302` and the proof's model transcribes it (`BzDBlock.v:582`).
- That the compress-target proof is wrong or weak as a proof. It establishes a functional round trip, which is more than the harness page claims, and its decoder lemmas are general in the selector count.
- That the decompress target was never proved anywhere. Anthropic's post of 2026-10-22 reports 239 proved entry points and says some proofs were withheld because they might reveal unpatched bugs; neither the post nor its appendix lists the entry points, and bzip2 is not named in either. The public repository marks the decompress target `open`, not `withheld`. The defensible statement is: unproved in the public release.
- That `ubsan_agrees` is adequate for this bug class in general. It catches the bzip2 instance because the index is a syntactically visible array access; a `memcpy` or pointer-decayed write into the same array (the Varnish `vep->tag` and Speex `excBuf` cases) is invisible to `array-bounds` as well.

**Open points a checker could close.**

- Whether the ASan+UBSan binary still contains an `array-bounds` trap at the store (the dominating guard may let clang fold it). `./oft fetch bzip2` downloads `bzip2_compress_target.asan-ubsan`; disassembling around the plain build's `0xb0d04` (the address `B0F_dec_U5B.v:101` walks to) and its counterpart in the sanitizer build would settle it. It does not affect the argument, which rests on the ASan-only statement.
- The offsets were computed on an x86-64 LP64 host. The proof's own arithmetic (`GlueCarve.v:238–251`, `BzDefs.v:60`) gives the same values for the riscv64 build, which is the stronger confirmation; a reader with a riscv64 cross-compiler can repeat the `offsetof` program with `--target=riscv64-linux-gnu -march=rv64g -mabi=lp64d`.
- The pinned commit `f5dfc960` is not in the `libarchive/bzip2` mirror used for the 1.0.6/1.0.7 history. The release tarball `bzip2-src.tar.zst` is the authoritative copy of the pinned tree; `sourceware.org/git/bzip2` has the full history.

**Sources opened for this document.** [theorem-labs/oss-verify-proofs at 98e995d4](https://github.com/theorem-labs/oss-verify-proofs/tree/98e995d4daced70a0a4aa2c810854b88720735f1) · [release v2026.10.0-src](https://github.com/theorem-labs/oss-verify-proofs/releases/tag/v2026.10.0-src) · [libarchive/bzip2 mirror](https://github.com/libarchive/bzip2) · [the 1.0.7 patch, "Make sure nSelectors is not out of range"](https://src.rrz.uni-hamburg.de/files/sourcemage/codex/test/archive/bzip2/patches/0011-Make-sure-nSelectors-is-not-out-of-range.patch) · [Mark J. Wielaard, "bzip2 and the CVE that wasn't" (2019-08-02)](https://gnu.wildebeest.org/blog/mjw/2019/08/02/bzip2-and-the-cve-that-wasnt/) · [Anthropic, "LLMs are making formal software verification feasible at a much larger scale" (2026-10-22)](https://www.anthropic.com/research/formal-verification) and its [appendix](https://www-cdn.anthropic.com/files/4zrzovbb/website/6867eadf760258fa8b42a504600cd3c036d16358.pdf).
