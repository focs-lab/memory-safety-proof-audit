From Stdlib Require Import ZArith List Bool Lia.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import PropExec.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VLinalg VState VLogic VGamma VStepMemSound VState2 VGamma2 VCert VCert2.
From CoturnFieldAudit Require Import WitnessData Support Model Pure Ambient.
Import ListNotations. Open Scope Z_scope.
#[local] Existing Instance PropExec.fx0.


Lemma asan_unowned_flag_zero a :
 35184372092928 <= a < 35184372125696 -> a <> 35184372092928 -> a <> 35184372109312 ->
 asan_mem (wordZ a) = Some (Z_to_bv 8 0).
Proof.
 intros Ha Hown Hborrow. destruct (Z_lt_ge_dec a 35184372109312).
 - apply (witness_mem_range asan_pristine asan_runs 35184372092929 35184372109312 0);[closed|closed|closed|closed|lia].
 - apply (witness_mem_range asan_pristine asan_runs 35184372109313 35184372125696 0);[closed|closed|closed|closed|lia].
Qed.
Lemma asan_flags : flags_inv asan_P asan_E asan_A asan_nu asan_mem.
Proof.
 intros _ c q Hc Hq Hborrow Hown.
 change (~ In (c,q) [(1,0)]) in Hborrow.
 change (~ In (flag_addr 35184372088832 c q) [35184372092928]) in Hown.
 exists (Z_to_bv 8 0). split;[|closed].
 apply asan_unowned_flag_zero.
 - exact (flags_bound 35184372088832 c q Hc Hq).
 - intro He. apply Hown. left. symmetry. exact He.
 - intro He.
   assert (Haddr : flag_addr 35184372088832 c q = flag_addr 35184372088832 1 0) by exact He.
   destruct (flags_inj 35184372088832 c q 1 0 Hc Hq ltac:(closed) ltac:(closed) Haddr) as [-> ->].
   apply Hborrow. left. reflexivity.
Qed.

Lemma both_unowned_flag_zero a :
 35184372092928 <= a < 35184372125696 -> a <> 35184372092928 -> a <> 35184372109312 ->
 both_mem (wordZ a) = Some (Z_to_bv 8 0).
Proof.
 intros Ha Hown Hborrow. destruct (Z_lt_ge_dec a 35184372109312).
 - apply (witness_mem_range both_pristine both_runs 35184372092929 35184372109312 0);[closed|closed|closed|closed|lia].
 - apply (witness_mem_range both_pristine both_runs 35184372109313 35184372125696 0);[closed|closed|closed|closed|lia].
Qed.
Lemma both_flags : flags_inv both_P both_E both_A both_nu both_mem.
Proof.
 intros _ c q Hc Hq Hborrow Hown.
 change (~ In (c,q) [(1,0)]) in Hborrow.
 change (~ In (flag_addr 35184372088832 c q) [35184372092928]) in Hown.
 exists (Z_to_bv 8 0). split;[|closed].
 apply both_unowned_flag_zero.
 - exact (flags_bound 35184372088832 c q Hc Hq).
 - intro He. apply Hown. left. symmetry. exact He.
 - intro He.
   assert (Haddr : flag_addr 35184372088832 c q = flag_addr 35184372088832 1 0) by exact He.
   destruct (flags_inj 35184372088832 c q 1 0 Hc Hq ltac:(closed) ltac:(closed) Haddr) as [-> ->].
   apply Hborrow. left. reflexivity.
Qed.

