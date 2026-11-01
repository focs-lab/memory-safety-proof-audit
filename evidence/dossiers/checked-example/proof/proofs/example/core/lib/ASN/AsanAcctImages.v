(* example/core: pupnp's ASN/AsanAcctImages.v for our two images: the asan-ubsan part (the Both_ lemmas) is removed (we
   build no such image) and the image tops are ours (computed from our segment tables). *)
(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.LinuxProcessSem Require Import
  BvBase RiscvSemantics MemImageType State.
From OssFuzzTheorems.example.core.images Require Import Plain.
From OssFuzzTheorems.example.core.images Require Import
  Asan.
From OssFuzzTheorems.Proofs.example.core.lib.ASN Require Import AsanAcct.
Import ListNotations.
Open Scope bv_scope.

Notation Src_0_loaded_segments := Plain_loaded_segments.
Definition Src_0_top : Z := 0x4f000%Z.  (* top of our plain image *)
Lemma Src_0_wx_nowrap : wx_segs_nowrap Src_0_loaded_segments.
Proof. apply wx_segs_nowrap_of_b. vm_compute. reflexivity. Qed.
Lemma Src_0_segs_below : segs_below_b Src_0_loaded_segments Src_0_top = true.
Proof. vm_compute. reflexivity. Qed.
Lemma Src_0_H_off_above : forall H : word -> bool,
  (forall a, H a = true -> (Src_0_top <= bv_unsigned a)%Z) ->
  H_off_segments Src_0_loaded_segments H.
Proof. intros H Ha. exact (H_off_segments_above _ H _ Src_0_segs_below Ha). Qed.
Lemma Src_0_H_off_mkH : forall L A,
  ranges_from_b L Src_0_top = true -> H_off_segments Src_0_loaded_segments (mkH L A).
Proof. intros L A HL. exact (H_off_segments_mkH _ L A _ Src_0_segs_below HL). Qed.

Definition Asan_top : Z := 0x5f3000%Z.  (* top of our ASan image *)
Lemma Asan_wx_nowrap : wx_segs_nowrap Asan_loaded_segments.
Proof. apply wx_segs_nowrap_of_b. vm_compute. reflexivity. Qed.
Lemma Asan_segs_below : segs_below_b Asan_loaded_segments Asan_top = true.
Proof. vm_compute. reflexivity. Qed.
Lemma Asan_H_off_above : forall H : word -> bool,
  (forall a, H a = true -> (Asan_top <= bv_unsigned a)%Z) ->
  H_off_segments Asan_loaded_segments H.
Proof. intros H Ha. exact (H_off_segments_above _ H _ Asan_segs_below Ha). Qed.
Lemma Asan_H_off_mkH : forall L A,
  ranges_from_b L Asan_top = true ->
  H_off_segments Asan_loaded_segments (mkH L A).
Proof. intros L A HL. exact (H_off_segments_mkH _ L A _ Asan_segs_below HL). Qed.
