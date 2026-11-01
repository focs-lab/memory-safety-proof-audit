(* example/core: pupnp's A0/T7G/GlueInst.v without the interceptor bundle IC (icpt_contracts, discharged there by
   IcptIC.IC_all): only pupnp's harness calls interceptors; ours calls none.  Three edits, nothing else.  Also without the fake-stack
   contracts SM0..SM4/F5 (core.asan has no __asan_stack_malloc_k; __asan_set_shadow_f5 is linked but unreachable; see H_fuzz.v). *)
(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType StackLayout State Run.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac Arr Bytes Image Agree Ceiling RunWord InitStack.
From OssFuzzTheorems.Proofs.example.core.lib.Spec Require Import Prelim Stdio.
From OssFuzzTheorems.example.core.images Require Import Asan.
From OssFuzzTheorems.Proofs.example.core.lib.ASN Require Import MainExport MainFactsAsan A0Img MainEntry A0Handoff A0LZ.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAW Require Import Segs Shadow Contracts Globals IcptA0 AllocA0.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAA Require Import ALayout AFakeInst.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7 Require Import RealizeS SeamA0 A0Prog.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7A0 Require Import RDriverA_ctx RDriverA_iface.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7G Require Import GlueKit GlueA0 GlueAllocLay GlueAllocInst.
Import ListNotations.
Open Scope Z_scope.

Section Inst.
  Variable PZ : mem -> Prop.

  Hypothesis FZ_GEN : forall (HC : HasCeiling) (HG : HasGuard) (FI : fs_if) (AI : am_if FI) (J : a0_judg FI AI)
      (AC : am_contracts FI AI J)
      (ASL : forall lo hi, am_static FI AI lo hi -> a0_static lo hi) (AMS : forall lo hi, a0_static lo hi -> am_static FI AI lo hi),
      fuzz_one_stmtA FI AI J PZ.

  #[using="FZ_GEN"] Theorem INST_of_FZ : forall (HC : HasCeiling) (HG : HasGuard) (V : nat -> Z) inp en ms mo,
    valid_input inp -> valid_entry imgA0 en inp -> alloc_ceiling = LO (en_sp en) -> amain_at_V V en inp ms mo ->
    exists (FI : fs_if) (AI : am_if FI),
      (forall lo hi, a0_static lo hi -> am_static FI AI lo hi)
      /\ am_contracts FI AI (JA FI AI)
      /\ fuzz_one_stmtA FI AI (JA FI AI) PZ
      /\ alloc_init_stmt FI AI V (en_sp en) (in_fs inp) mo.
  Proof.
    intros HC HG V inp en ms mo VI VE CEIL AMA.
    destruct (inst_core V inp en ms mo VI VE CEIL AMA) as (AO & AI & AMS & ASL & AC & AINIT).
    exists (FI_B (AL_of V) AO), AI.
    split; [exact AMS|]. split; [exact AC|]. split; [| exact AINIT].
    exact (FZ_GEN HC HG (FI_B (AL_of V) AO) AI (JA (FI_B (AL_of V) AO) AI) AC ASL AMS).
  Qed.
End Inst.
