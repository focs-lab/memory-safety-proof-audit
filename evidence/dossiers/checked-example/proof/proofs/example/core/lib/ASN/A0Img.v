(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Run.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import PropExec MState Mem Image.
From OssFuzzTheorems.example.core.images Require Export Asan.
Import ListNotations.
Open Scope Z_scope.

Definition asegs : list Segment := Asan.M.loaded_segments.
Definition a_init_pc : N := Asan.M.init_pc.
Definition a_phdrs : PhdrInfo := Asan.M.phdrs.

Lemma a_find_segment_1 : forall z, 0 <= z ->
  find_segment asegs z 1 =
    if (0x10000 <=? z) && (z + 1 <=? 0x2f000) then Some Asan_segment_000
    else if (0x2f000 <=? z) && (z + 1 <=? 0x95000) then Some Asan_segment_001
    else if (0x95000 <=? z) && (z + 1 <=? 0x97000) then Some Asan_segment_002
    else if (0x97000 <=? z) && (z + 1 <=? 0x5f3000) then Some Asan_segment_003
    else None.
Proof. intros z Hz. reflexivity. Qed.

Lemma a_ro_addr : forall a : word,
  ro_addr asegs a = ((0x10000 <=? bv_unsigned a) && (bv_unsigned a <? 0x95000))%bool.
Proof.
  intros a. unfold ro_addr. rewrite a_find_segment_1 by (pose proof (bv_unsigned_in_range 64 a); lia).
  pose proof (bv_unsigned_in_range 64 a) as R.
  destruct (Z.leb_spec0 0x10000 (bv_unsigned a)); destruct (Z.leb_spec0 (bv_unsigned a + 1) 0x2f000);
  destruct (Z.leb_spec0 0x2f000 (bv_unsigned a)); destruct (Z.leb_spec0 (bv_unsigned a + 1) 0x95000);
  destruct (Z.leb_spec0 0x95000 (bv_unsigned a)); destruct (Z.leb_spec0 (bv_unsigned a + 1) 0x97000);
  destruct (Z.leb_spec0 0x97000 (bv_unsigned a)); destruct (Z.leb_spec0 (bv_unsigned a + 1) 0x5f3000);
  destruct (Z.ltb_spec0 (bv_unsigned a) 0x95000); cbn; try reflexivity; lia.
Qed.

Lemma ref_find_segment_none : forall z n, 1 <= n -> (z + n <= 0x10000 \/ 0x5f3000 <= z) ->
  find_segment asegs z n = None.
Proof.
  intros z n Hn Hz. unfold asegs, Asan.M.loaded_segments, Asan_loaded_segments. cbn [find_segment].
  replace (Z.of_N (seg_base Asan_segment_000)) with 0x10000 by (vm_compute; reflexivity).
  replace (Z.of_N (seg_size Asan_segment_000)) with 0x1f000 by (vm_compute; reflexivity).
  replace (Z.of_N (seg_base Asan_segment_001)) with 0x2f000 by (vm_compute; reflexivity).
  replace (Z.of_N (seg_size Asan_segment_001)) with 0x66000 by (vm_compute; reflexivity).
  replace (Z.of_N (seg_base Asan_segment_002)) with 0x95000 by (vm_compute; reflexivity).
  replace (Z.of_N (seg_size Asan_segment_002)) with 0x2000 by (vm_compute; reflexivity).
  replace (Z.of_N (seg_base Asan_segment_003)) with 0x97000 by (vm_compute; reflexivity).
  replace (Z.of_N (seg_size Asan_segment_003)) with 0x55c000 by (vm_compute; reflexivity).
  destruct (Z.leb_spec0 0x10000 z); destruct (Z.leb_spec0 (z + n) (0x10000 + 0x1f000)); cbn [andb]; try lia;
  destruct (Z.leb_spec0 0x2f000 z); destruct (Z.leb_spec0 (z + n) (0x2f000 + 0x66000)); cbn [andb]; try lia;
  destruct (Z.leb_spec0 0x95000 z); destruct (Z.leb_spec0 (z + n) (0x95000 + 0x2000)); cbn [andb]; try lia;
  destruct (Z.leb_spec0 0x97000 z); destruct (Z.leb_spec0 (z + n) (0x97000 + 0x55c000)); cbn [andb]; try lia; reflexivity.
Qed.
