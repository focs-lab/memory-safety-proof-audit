From Stdlib Require Import ZArith List Bool Lia.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import PropExec.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VLinalg VState VLogic VGamma VStepMemSound VState2 VGamma2 VCert VCert2.
From CoturnFieldAudit Require Import WitnessData Support Model Pure Regions.
Import ListNotations. Open Scope Z_scope.
#[local] Existing Instance PropExec.fx0.


From LinuxProcessSemantics.Riscv Require Import Sem. Open Scope Z_scope.
Ltac register_cases Hin Hnz Hu Hr :=
 lazymatch type of Hin with
 | _ \/ _ =>
  let Hc := fresh "Hcase" in let Ht := fresh "Htail" in
  destruct Hin as [Hc|Ht];
  [rewrite <-Hc in Hu,Hnz,Hr;try contradiction;
   vm_compute in Hr;try discriminate;
   match type of Hr with Some ?v = Some ?e =>
    let He := fresh "Hexpression" in assert (He : e=v) by congruence;rewrite He
   end;
   unfold getr,reg_get,bvmap_get,bv_key,bv_eqb;
   rewrite <-Hu;vm_compute;reflexivity
  |register_cases Ht Hnz Hu Hr]
 | False => contradiction
 end.

Lemma asan_side_defs :
 gamma_conddef asan_nu (v1 asan_A) /\ gamma_moddef asan_nu (v1 asan_A) /\ gamma_valset asan_nu (v1 asan_A).
Proof. repeat split;intros;discriminate. Qed.
Lemma asan_registers : gamma_regs asan_nu (v1 asan_A) asan_regs.
Proof.
 intros r e Hnz Hr.
 pose proof (bv_unsigned_in_range _ r) as Hrange.
 remember (bv_unsigned r) as u eqn:Hu in *.
 change (0<=u<32) in Hrange.
 assert (Hin : In u [0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31]) by (cbn;lia).
 vm_compute in Hin. register_cases Hin Hnz Hu Hr.
Qed.
Lemma asan_slots SEGS : gamma_slots SEGS (p1 asan_P) (ev1 asan_E) asan_nu (v1 asan_A) asan_mem.
Proof.
 intros off w v Hin. finite_in Hin; repeat split;try closed;
 unfold cell_holds; eexists;split;vm_compute;reflexivity.
Qed.
Lemma asan_nulls SEGS : gamma_nul SEGS (p1 asan_P) (ev1 asan_E) (v1 asan_A) asan_mem.
Proof.
 intros lo hi Hin. finite_in Hin;
 exists (-1326954),(Z_to_bv 8 0);repeat split;try closed;vm_compute;reflexivity.
Qed.
Lemma asan_below : state_below (v1 asan_A).
Proof.
 unfold state_below. split;[closed|]. split;[closed|]. split.
 - intros r e Hr. change (pm_get r (pm_of_list (map (fun re : Z*lin => (Z.to_pos (fst re),snd re)) (cs_regs (c1 asan_case)))) = Some e) in Hr.
   apply pm_of_list_get_in in Hr. finite_in Hr;closed.
 - split.
   + intros off w e Hin. finite_in Hin;closed.
   + split;[intros off w e Hin;finite_in Hin|].
     repeat split;intros;discriminate.
Qed.
Lemma asan_below2 : state_below2 asan_A.
Proof.
 unfold state_below2. split;[closed|]. split.
 - intros r Hin. finite_in Hin;repeat split;try closed;
   intros off w e Hc;finite_in Hc;closed.
 - split.
   + intros s Hin. finite_in Hin;closed.
   + split.
     * intros q x m Hq. change (pm_get q (pm_of_list (cs_divdef asan_case)) = Some (x,m)) in Hq.
       apply pm_of_list_get_in in Hq. finite_in Hq;closed.
     * intros a n v Hin. finite_in Hin.
Qed.
Lemma asan_live : live_ok asan_nu asan_A.
Proof.
 unfold live_ok. split.
 - intros s. split.
   + intros Hin. finite_in Hin. exists asan_r5. split.
     * change (In asan_r5 (vs_rgn asan_A)). vm_compute. tauto.
     * split;[reflexivity|exact I].
   + intros [r [Hr [Hbase Hkind]]]. finite_in Hr;cbn in Hkind;try contradiction;
     try subst s;closed.
 - split;[apply NoDup_cons_2;[intros H;inversion H|apply NoDup_nil_2]|]. split.
   + intros r1 r2 H1 H2. finite_in H1;finite_in H2;closed.
   + repeat constructor;closed.
Qed.
Lemma asan_globs SEGS : gamma_globs SEGS (p1 asan_P) asan_nu (v1 asan_A) asan_mem.
Proof. intros a w v Hin. finite_in Hin. Qed.
Lemma asan_globs2 : globs_ok2 asan_P asan_A.
Proof. intros _ a w v Hin. finite_in Hin. Qed.
Lemma asan_memo SEGS : memo_ok SEGS asan_nu asan_mem asan_A.
Proof. intros a n v Hin. finite_in Hin. Qed.

Lemma both_side_defs :
 gamma_conddef both_nu (v1 both_A) /\ gamma_moddef both_nu (v1 both_A) /\ gamma_valset both_nu (v1 both_A).
Proof. repeat split;intros;discriminate. Qed.
Lemma both_registers : gamma_regs both_nu (v1 both_A) both_regs.
Proof.
 intros r e Hnz Hr.
 pose proof (bv_unsigned_in_range _ r) as Hrange.
 remember (bv_unsigned r) as u eqn:Hu in *.
 change (0<=u<32) in Hrange.
 assert (Hin : In u [0;1;2;3;4;5;6;7;8;9;10;11;12;13;14;15;16;17;18;19;20;21;22;23;24;25;26;27;28;29;30;31]) by (cbn;lia).
 vm_compute in Hin. register_cases Hin Hnz Hu Hr.
Qed.
Lemma both_slots SEGS : gamma_slots SEGS (p1 both_P) (ev1 both_E) both_nu (v1 both_A) both_mem.
Proof.
 intros off w v Hin. finite_in Hin; repeat split;try closed;
 unfold cell_holds; eexists;split;vm_compute;reflexivity.
Qed.
Lemma both_nulls SEGS : gamma_nul SEGS (p1 both_P) (ev1 both_E) (v1 both_A) both_mem.
Proof.
 intros lo hi Hin. finite_in Hin;
 exists (-1326954),(Z_to_bv 8 0);repeat split;try closed;vm_compute;reflexivity.
Qed.
Lemma both_below : state_below (v1 both_A).
Proof.
 unfold state_below. split;[closed|]. split;[closed|]. split.
 - intros r e Hr. change (pm_get r (pm_of_list (map (fun re : Z*lin => (Z.to_pos (fst re),snd re)) (cs_regs (c1 both_case)))) = Some e) in Hr.
   apply pm_of_list_get_in in Hr. finite_in Hr;closed.
 - split.
   + intros off w e Hin. finite_in Hin;closed.
   + split;[intros off w e Hin;finite_in Hin|].
     repeat split;intros;discriminate.
Qed.
Lemma both_below2 : state_below2 both_A.
Proof.
 unfold state_below2. split;[closed|]. split.
 - intros r Hin. finite_in Hin;repeat split;try closed;
   intros off w e Hc;finite_in Hc;closed.
 - split.
   + intros s Hin. finite_in Hin;closed.
   + split.
     * intros q x m Hq. change (pm_get q (pm_of_list (cs_divdef both_case)) = Some (x,m)) in Hq.
       apply pm_of_list_get_in in Hq. finite_in Hq;closed.
     * intros a n v Hin. finite_in Hin.
Qed.
Lemma both_live : live_ok both_nu both_A.
Proof.
 unfold live_ok. split.
 - intros s. split.
   + intros Hin. finite_in Hin. exists both_r3. split.
     * change (In both_r3 (vs_rgn both_A)). vm_compute. tauto.
     * split;[reflexivity|exact I].
   + intros [r [Hr [Hbase Hkind]]]. finite_in Hr;cbn in Hkind;try contradiction;
     try subst s;closed.
 - split;[apply NoDup_cons_2;[intros H;inversion H|apply NoDup_nil_2]|]. split.
   + intros r1 r2 H1 H2. finite_in H1;finite_in H2;closed.
   + repeat constructor;closed.
Qed.
Lemma both_globs SEGS : gamma_globs SEGS (p1 both_P) both_nu (v1 both_A) both_mem.
Proof. intros a w v Hin. finite_in Hin. Qed.
Lemma both_globs2 : globs_ok2 both_P both_A.
Proof. intros _ a w v Hin. finite_in Hin. Qed.
Lemma both_memo SEGS : memo_ok SEGS both_nu both_mem both_A.
Proof. intros a n v Hin. finite_in Hin. Qed.

