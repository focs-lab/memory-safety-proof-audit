From Stdlib Require Import ZArith List Bool Lia.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import PropExec.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VLinalg VState VLogic VGamma VStepMemSound VState2 VGamma2 VCert VCert2.
From CoturnFieldAudit Require Import WitnessData Support Model Pure.
Import ListNotations. Open Scope Z_scope.
#[local] Existing Instance PropExec.fx0.

Lemma class_member_in_classes P fs (m n:nat) L r :
 (m<n)%nat -> In r (class_regions P fs (Z.of_nat m) L) -> In r (classes_regions P fs n L).
Proof.
 revert m. induction n;intros m Hmn Hr;[lia|].
 change (In r (classes_regions P fs n L ++ class_regions P fs (Z.of_nat n) L)).
 apply in_or_app. destruct (Nat.eq_dec m n) as [->|Hne];[right;exact Hr|].
 left. apply (IHn m);[lia|exact Hr].
Qed.

Definition asan_r0 : vregion := Eval vm_compute in nth 0 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r0_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r0.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
all: unfold rcell_holds; cbv [is_shadow asan_r0 lin_is_const andb vr_kind lc lt].
all: match goal with |- run_holds ?S ?M ?a ?w ?b =>
       let l := eval vm_compute in a in let h := eval vm_compute in (a+w) in
       change (run_holds S (witness_mem asan_pristine asan_runs) l (h-l) b);
       apply witness_run; closed end.
Qed.
Lemma asan_r0_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r0.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (-166920 <= off < 1) in H.
      change (in_any_zone asan_P asan_E (17594065059842+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (17594065059842+off)) 1 = Some [b]).
      split.
      + destruct (Z_lt_ge_dec off (-166912)); [apply (zones_coverb_sound asan_P asan_E false (17594064892922) (17594064892930)); [closed|lia]|]; destruct (Z_lt_ge_dec off 0); [apply (zones_coverb_sound asan_P asan_E false (17594064892930) 17594065059842); [closed|lia]|apply (zones_coverb_sound asan_P asan_E false 17594065059842 (17594065059843)); [closed|lia]].
      + destruct (witness_readable SEGS asan_pristine asan_runs (17594064892922) (17594065059843)
          ltac:(closed) ltac:(closed) ltac:(closed) (17594065059842+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (-166912 <= off < -166010) in H.
all: try (change (-166920 <= off); lia).
all: try (change (off < 1); lia).
all: try (change (in_rw_zones asan_P asan_E (17594065059842+off) = true); apply (zones_coverb_sound asan_P asan_E true (17594064892930) (17594064893832)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem asan_pristine asan_runs) (wordZ (17594065059842+off)) 1 = true); exact (proj2 (witness_readable SEGS asan_pristine asan_runs (17594064892922) (17594065059843) ltac:(closed) ltac:(closed) ltac:(closed) (17594065059842+off) ltac:(lia)))).
all: change (covered (unit_regions2 asan_P asan_E) (17594065059842+off) 1); exists (wordZ 17594064892930),902; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;left; change (In (wordZ 17594064892930,902) [(wordZ 17594064892930,902)]);left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma asan_r0_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r0.
Proof. unfold kind_ok; cbv [asan_r0 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split.
- intros _. repeat split;try reflexivity;closed.
- split;[intro H;discriminate H|]. split;[discriminate|]. intro H. exfalso. apply H. reflexivity.
Qed.
Lemma asan_r0_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r0.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r0 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r0_cells|]. split;[apply asan_r0_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r0_kind].
   Qed.
Definition asan_r1 : vregion := Eval vm_compute in nth 1 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r1_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r1.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma asan_r1_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r1.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 20) in H.
      change (in_any_zone asan_P asan_E (35184373174304+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (35184373174304+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound asan_P asan_E false (35184373174304) (35184373174324)); [closed|lia].
      + destruct (witness_readable SEGS asan_pristine asan_runs (35184373174304) (35184373174324)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184373174304+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
Qed.
Lemma asan_r1_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r1.
Proof. unfold kind_ok; cbv [asan_r1 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split; [closed|]. split.
- exists 1,0. repeat split; closed.
- exists 3. repeat split; try closed. all: intros l h Hin; finite_in Hin.
Qed.
Lemma asan_r1_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r1.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r1 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r1_cells|]. split;[apply asan_r1_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r1_kind].
   Qed.
Definition asan_r2 : vregion := Eval vm_compute in nth 2 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r2_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r2.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma asan_r2_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r2.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 0) in H.
      change (in_any_zone asan_P asan_E (35184373174336+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (35184373174336+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound asan_P asan_E false (35184373174336) (35184373174336)); [closed|lia].
      + destruct (witness_readable SEGS asan_pristine asan_runs (35184373174336) (35184373174336)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184373174336+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
Qed.
Lemma asan_r2_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r2.
Proof. unfold kind_ok; cbv [asan_r2 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split; [closed|]. split.
- exists 1,0. repeat split; closed.
- exists 5. repeat split; try closed. all: intros l h Hin; finite_in Hin.
Qed.
Lemma asan_r2_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r2.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r2 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r2_cells|]. split;[apply asan_r2_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r2_kind].
   Qed.
Definition asan_r3 : vregion := Eval vm_compute in nth 3 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r3_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r3.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
all: unfold rcell_holds; cbv [is_shadow asan_r3 lin_is_const andb vr_kind lc lt].
all: match goal with |- run_holds ?S ?M ?a ?w ?b =>
       let l := eval vm_compute in a in let h := eval vm_compute in (a+w) in
       change (run_holds S (witness_mem asan_pristine asan_runs) l (h-l) b);
       apply witness_run; closed end.
Qed.
Lemma asan_r3_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r3.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 3) in H.
      change (in_any_zone asan_P asan_E (4400194097668+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (4400194097668+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound asan_P asan_E false (4400194097668) (4400194097671)); [closed|lia].
      + destruct (witness_readable SEGS asan_pristine asan_runs (4400194097668) (4400194097671)
          ltac:(closed) ltac:(closed) ltac:(closed) (4400194097668+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
Qed.
Lemma asan_r3_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r3.
Proof. unfold kind_ok; cbv [asan_r3 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split;[intro H;discriminate H|]. split;[intro H;discriminate H|]. split;[discriminate|].
intros _ _ _. exists asan_r1. repeat split;try (solve [exists 1,0;repeat split;closed]);try closed.
all: exists 1,0;repeat split;closed.
Qed.
Lemma asan_r3_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r3.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r3 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r3_cells|]. split;[apply asan_r3_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r3_kind].
   Qed.
Definition asan_r4 : vregion := Eval vm_compute in nth 4 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r4_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r4.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma asan_r4_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r4.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 0) in H.
      change (in_any_zone asan_P asan_E (4400194097672+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (4400194097672+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound asan_P asan_E false (4400194097672) (4400194097672)); [closed|lia].
      + destruct (witness_readable SEGS asan_pristine asan_runs (4400194097672) (4400194097672)
          ltac:(closed) ltac:(closed) ltac:(closed) (4400194097672+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
Qed.
Lemma asan_r4_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r4.
Proof. unfold kind_ok; cbv [asan_r4 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split;[intro H;discriminate H|]. split;[intro H;discriminate H|]. split;[discriminate|].
intros _ _ _. exists asan_r2. repeat split;try (solve [exists 1,0;repeat split;closed]);try closed.
all: exists 1,0;repeat split;closed.
Qed.
Lemma asan_r4_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r4.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r4 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r4_cells|]. split;[apply asan_r4_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r4_kind].
   Qed.
Definition asan_r5 : vregion := Eval vm_compute in nth 5 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r5_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r5.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
all: unfold rcell_holds; cbv [is_shadow asan_r5 lin_is_const andb vr_kind lc lt]; unfold cell_holds;
  eexists; split; vm_compute; reflexivity.
Qed.
Lemma asan_r5_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r5.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 64) in H.
      change (in_any_zone asan_P asan_E (35184372125696+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (35184372125696+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound asan_P asan_E false (35184372125696) (35184372125760)); [closed|lia].
      + destruct (witness_readable SEGS asan_pristine asan_runs (35184372125696) (35184372125760)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184372125696+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (0 <= off < 64) in H.
all: try (change (0 <= off); lia).
all: try (change (off < 64); lia).
all: try (change (in_rw_zones asan_P asan_E (35184372125696+off) = true); apply (zones_coverb_sound asan_P asan_E true (35184372125696) (35184372125760)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem asan_pristine asan_runs) (wordZ (35184372125696+off)) 1 = true); exact (proj2 (witness_readable SEGS asan_pristine asan_runs (35184372125696) (35184372125760) ltac:(closed) ltac:(closed) ltac:(closed) (35184372125696+off) ltac:(lia)))).
all: change (covered (unit_regions2 asan_P asan_E) (35184372125696+off) 1); exists (wordZ 35184372125696),64; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;right;change (In (wordZ 35184372125696,64) ([(wordZ 35184372088832,88);(wordZ 35184372092928,32768)] ++ classes_regions asan_P 35184372088832 5 [(1,0)]));apply in_or_app;right;apply (class_member_in_classes asan_P 35184372088832 0 5 [(1,0)]);[lia|];unfold class_regions;apply in_flat_map;exists 0;split;[apply in_map_iff;exists 0%nat;split;[reflexivity|apply in_seq;split;[apply Nat.le_refl|apply Nat.ltb_lt;vm_compute;reflexivity]]|];left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma asan_r5_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r5.
Proof. unfold kind_ok; cbv [asan_r5 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
repeat split; try closed. exists 0. repeat split; try closed.
exists (Z_to_bv 8 1). split; vm_compute; reflexivity.
Qed.
Lemma asan_r5_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r5.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r5 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r5_cells|]. split;[apply asan_r5_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r5_kind].
   Qed.
Definition asan_r6 : vregion := Eval vm_compute in nth 6 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r6_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r6.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
all: unfold rcell_holds; cbv [is_shadow asan_r6 lin_is_const andb vr_kind lc lt].
all: match goal with |- run_holds ?S ?M ?a ?w ?b =>
       let l := eval vm_compute in a in let h := eval vm_compute in (a+w) in
       change (run_holds S (witness_mem asan_pristine asan_runs) l (h-l) b);
       apply witness_run; closed end.
Qed.
Lemma asan_r6_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r6.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 8) in H.
      change (in_any_zone asan_P asan_E (4400193966592+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (4400193966592+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound asan_P asan_E false (4400193966592) (4400193966600)); [closed|lia].
      + destruct (witness_readable SEGS asan_pristine asan_runs (4400193966592) (4400193966600)
          ltac:(closed) ltac:(closed) ltac:(closed) (4400193966592+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (0 <= off < 8) in H.
all: try (change (0 <= off); lia).
all: try (change (off < 8); lia).
all: try (change (in_rw_zones asan_P asan_E (4400193966592+off) = true); apply (zones_coverb_sound asan_P asan_E true (4400193966592) (4400193966600)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem asan_pristine asan_runs) (wordZ (4400193966592+off)) 1 = true); exact (proj2 (witness_readable SEGS asan_pristine asan_runs (4400193966592) (4400193966600) ltac:(closed) ltac:(closed) ltac:(closed) (4400193966592+off) ltac:(lia)))).
all: change (covered (unit_regions2 asan_P asan_E) (4400193966592+off) 1); exists (wordZ 4400193966592),8; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;right;change (In (wordZ 4400193966592,8) ([(wordZ 35184372088832,88);(wordZ 35184372092928,32768)] ++ classes_regions asan_P 35184372088832 5 [(1,0)]));apply in_or_app;right;apply (class_member_in_classes asan_P 35184372088832 0 5 [(1,0)]);[lia|];unfold class_regions;apply in_flat_map;exists 0;split;[apply in_map_iff;exists 0%nat;split;[reflexivity|apply in_seq;split;[apply Nat.le_refl|apply Nat.ltb_lt;vm_compute;reflexivity]]|];right;left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma asan_r6_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r6.
Proof. unfold kind_ok; cbv [asan_r6 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split;[intro H;discriminate H|]. split;[intro H;discriminate H|]. split;[discriminate|].
intros _ _ _. exists asan_r5. repeat split;try (solve [exists 1,0;repeat split;closed]);try closed.
Qed.
Lemma asan_r6_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r6.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r6 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r6_cells|]. split;[apply asan_r6_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r6_kind].
   Qed.
Definition asan_r7 : vregion := Eval vm_compute in nth 7 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r7_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r7.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma asan_r7_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r7.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 1) in H.
      change (in_any_zone asan_P asan_E (35184372092928+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (35184372092928+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound asan_P asan_E false (35184372092928) (35184372092929)); [closed|lia].
      + destruct (witness_readable SEGS asan_pristine asan_runs (35184372092928) (35184372092929)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184372092928+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (0 <= off < 1) in H.
all: try (change (0 <= off); lia).
all: try (change (off < 1); lia).
all: try (change (in_rw_zones asan_P asan_E (35184372092928+off) = true); apply (zones_coverb_sound asan_P asan_E true (35184372092928) (35184372092929)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem asan_pristine asan_runs) (wordZ (35184372092928+off)) 1 = true); exact (proj2 (witness_readable SEGS asan_pristine asan_runs (35184372092928) (35184372092929) ltac:(closed) ltac:(closed) ltac:(closed) (35184372092928+off) ltac:(lia)))).
all: change (covered (unit_regions2 asan_P asan_E) (35184372092928+off) 1); exists (wordZ 35184372092928),32768; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;right;change (In (wordZ 35184372092928,32768) ([(wordZ 35184372088832,88);(wordZ 35184372092928,32768)] ++ classes_regions asan_P 35184372088832 5 [(1,0)]));apply in_or_app;left;right;left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma asan_r7_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r7.
Proof. unfold kind_ok; cbv [asan_r7 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
repeat split;try reflexivity. exists asan_r5,0,98%positive. repeat split; closed.
Qed.
Lemma asan_r7_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r7.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r7 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r7_cells|]. split;[apply asan_r7_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r7_kind].
   Qed.
Definition asan_r8 : vregion := Eval vm_compute in nth 8 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r8_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r8.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma asan_r8_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r8.
Proof. unfold region_perm_ok.
intros H. discriminate.
Qed.
Lemma asan_r8_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r8.
Proof. unfold kind_ok; cbv [asan_r8 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split;[intro H;discriminate H|]. split;[intros _;reflexivity|]. split;[discriminate|]. intros _ H. exfalso. apply H. reflexivity.
Qed.
Lemma asan_r8_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r8.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r8 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r8_cells|]. split;[apply asan_r8_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r8_kind].
   Qed.
Definition asan_r9 : vregion := Eval vm_compute in nth 9 (vs_rgn asan_A) (SHD asan_P).
Lemma asan_r9_cells SEGS : region_cells_ok SEGS asan_nu asan_mem asan_r9.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma asan_r9_perm SEGS : region_perm_ok SEGS asan_P asan_E asan_nu asan_mem asan_r9.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 88) in H.
      change (in_any_zone asan_P asan_E (35184372088832+off) = true /\ exists b, rdn SEGS asan_mem (wordZ (35184372088832+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound asan_P asan_E false (35184372088832) (35184372088920)); [closed|lia].
      + destruct (witness_readable SEGS asan_pristine asan_runs (35184372088832) (35184372088920)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184372088832+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (0 <= off < 88) in H.
all: try (change (0 <= off); lia).
all: try (change (off < 88); lia).
all: try (change (in_rw_zones asan_P asan_E (35184372088832+off) = true); apply (zones_coverb_sound asan_P asan_E true (35184372088832) (35184372088920)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem asan_pristine asan_runs) (wordZ (35184372088832+off)) 1 = true); exact (proj2 (witness_readable SEGS asan_pristine asan_runs (35184372088832) (35184372088920) ltac:(closed) ltac:(closed) ltac:(closed) (35184372088832+off) ltac:(lia)))).
all: change (covered (unit_regions2 asan_P asan_E) (35184372088832+off) 1); exists (wordZ 35184372088832),88; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;right;change (In (wordZ 35184372088832,88) ([(wordZ 35184372088832,88);(wordZ 35184372092928,32768)] ++ classes_regions asan_P 35184372088832 5 [(1,0)]));apply in_or_app;left;left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma asan_r9_kind SEGS : kind_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r9.
Proof. unfold kind_ok; cbv [asan_r9 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
repeat split;try reflexivity;discriminate.
Qed.
Lemma asan_r9_ok SEGS : region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem asan_r9.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow asan_r9 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply asan_r9_cells|]. split;[apply asan_r9_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply asan_r9_kind].
   Qed.
Lemma asan_all_regions SEGS : forall r, In r (vs_rgn asan_A) -> region_ok SEGS asan_P asan_E asan_nu asan_A asan_mem r.
Proof. intros r Hin. change (In r [asan_r0;asan_r1;asan_r2;asan_r3;asan_r4;asan_r5;asan_r6;asan_r7;asan_r8;asan_r9]) in Hin.
cbn [In] in Hin.
destruct Hin as [<-|Hin]; [apply asan_r0_ok|].
destruct Hin as [<-|Hin]; [apply asan_r1_ok|].
destruct Hin as [<-|Hin]; [apply asan_r2_ok|].
destruct Hin as [<-|Hin]; [apply asan_r3_ok|].
destruct Hin as [<-|Hin]; [apply asan_r4_ok|].
destruct Hin as [<-|Hin]; [apply asan_r5_ok|].
destruct Hin as [<-|Hin]; [apply asan_r6_ok|].
destruct Hin as [<-|Hin]; [apply asan_r7_ok|].
destruct Hin as [<-|Hin]; [apply asan_r8_ok|].
destruct Hin as [<-|Hin]; [apply asan_r9_ok|].
contradiction. Qed.
Definition both_r0 : vregion := Eval vm_compute in nth 0 (vs_rgn both_A) (SHD both_P).
Lemma both_r0_cells SEGS : region_cells_ok SEGS both_nu both_mem both_r0.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
all: unfold rcell_holds; cbv [is_shadow both_r0 lin_is_const andb vr_kind lc lt].
all: match goal with |- run_holds ?S ?M ?a ?w ?b =>
       let l := eval vm_compute in a in let h := eval vm_compute in (a+w) in
       change (run_holds S (witness_mem both_pristine both_runs) l (h-l) b);
       apply witness_run; closed end.
Qed.
Lemma both_r0_perm SEGS : region_perm_ok SEGS both_P both_E both_nu both_mem both_r0.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (-166920 <= off < 1) in H.
      change (in_any_zone both_P both_E (17594065059842+off) = true /\ exists b, rdn SEGS both_mem (wordZ (17594065059842+off)) 1 = Some [b]).
      split.
      + destruct (Z_lt_ge_dec off (-166912)); [apply (zones_coverb_sound both_P both_E false (17594064892922) (17594064892930)); [closed|lia]|]; destruct (Z_lt_ge_dec off 0); [apply (zones_coverb_sound both_P both_E false (17594064892930) 17594065059842); [closed|lia]|apply (zones_coverb_sound both_P both_E false 17594065059842 (17594065059843)); [closed|lia]].
      + destruct (witness_readable SEGS both_pristine both_runs (17594064892922) (17594065059843)
          ltac:(closed) ltac:(closed) ltac:(closed) (17594065059842+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (-166912 <= off < -166006) in H.
all: try (change (-166920 <= off); lia).
all: try (change (off < 1); lia).
all: try (change (in_rw_zones both_P both_E (17594065059842+off) = true); apply (zones_coverb_sound both_P both_E true (17594064892930) (17594064893836)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem both_pristine both_runs) (wordZ (17594065059842+off)) 1 = true); exact (proj2 (witness_readable SEGS both_pristine both_runs (17594064892922) (17594065059843) ltac:(closed) ltac:(closed) ltac:(closed) (17594065059842+off) ltac:(lia)))).
all: change (covered (unit_regions2 both_P both_E) (17594065059842+off) 1); exists (wordZ 17594064892930),906; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;left; change (In (wordZ 17594064892930,906) [(wordZ 17594064892930,906)]);left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma both_r0_kind SEGS : kind_ok SEGS both_P both_E both_nu both_A both_mem both_r0.
Proof. unfold kind_ok; cbv [both_r0 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split.
- intros _. repeat split;try reflexivity;closed.
- split;[intro H;discriminate H|]. split;[discriminate|]. intro H. exfalso. apply H. reflexivity.
Qed.
Lemma both_r0_ok SEGS : region_ok SEGS both_P both_E both_nu both_A both_mem both_r0.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow both_r0 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply both_r0_cells|]. split;[apply both_r0_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply both_r0_kind].
   Qed.
Definition both_r1 : vregion := Eval vm_compute in nth 1 (vs_rgn both_A) (SHD both_P).
Lemma both_r1_cells SEGS : region_cells_ok SEGS both_nu both_mem both_r1.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma both_r1_perm SEGS : region_perm_ok SEGS both_P both_E both_nu both_mem both_r1.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 8) in H.
      change (in_any_zone both_P both_E (35184373174304+off) = true /\ exists b, rdn SEGS both_mem (wordZ (35184373174304+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound both_P both_E false (35184373174304) (35184373174312)); [closed|lia].
      + destruct (witness_readable SEGS both_pristine both_runs (35184373174304) (35184373174312)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184373174304+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
Qed.
Lemma both_r1_kind SEGS : kind_ok SEGS both_P both_E both_nu both_A both_mem both_r1.
Proof. unfold kind_ok; cbv [both_r1 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split; [closed|]. split.
- exists 1,0. repeat split; closed.
- exists 3. repeat split; try closed. all: intros l h Hin; finite_in Hin.
Qed.
Lemma both_r1_ok SEGS : region_ok SEGS both_P both_E both_nu both_A both_mem both_r1.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow both_r1 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply both_r1_cells|]. split;[apply both_r1_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply both_r1_kind].
   Qed.
Definition both_r2 : vregion := Eval vm_compute in nth 2 (vs_rgn both_A) (SHD both_P).
Lemma both_r2_cells SEGS : region_cells_ok SEGS both_nu both_mem both_r2.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
all: unfold rcell_holds; cbv [is_shadow both_r2 lin_is_const andb vr_kind lc lt].
all: match goal with |- run_holds ?S ?M ?a ?w ?b =>
       let l := eval vm_compute in a in let h := eval vm_compute in (a+w) in
       change (run_holds S (witness_mem both_pristine both_runs) l (h-l) b);
       apply witness_run; closed end.
Qed.
Lemma both_r2_perm SEGS : region_perm_ok SEGS both_P both_E both_nu both_mem both_r2.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 1) in H.
      change (in_any_zone both_P both_E (4400194097668+off) = true /\ exists b, rdn SEGS both_mem (wordZ (4400194097668+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound both_P both_E false (4400194097668) (4400194097669)); [closed|lia].
      + destruct (witness_readable SEGS both_pristine both_runs (4400194097668) (4400194097669)
          ltac:(closed) ltac:(closed) ltac:(closed) (4400194097668+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
Qed.
Lemma both_r2_kind SEGS : kind_ok SEGS both_P both_E both_nu both_A both_mem both_r2.
Proof. unfold kind_ok; cbv [both_r2 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split;[intro H;discriminate H|]. split;[intro H;discriminate H|]. split;[discriminate|].
intros _ _ _. exists both_r1. repeat split;try (solve [exists 1,0;repeat split;closed]);try closed.
all: exists 1,0;repeat split;closed.
Qed.
Lemma both_r2_ok SEGS : region_ok SEGS both_P both_E both_nu both_A both_mem both_r2.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow both_r2 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply both_r2_cells|]. split;[apply both_r2_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply both_r2_kind].
   Qed.
Definition both_r3 : vregion := Eval vm_compute in nth 3 (vs_rgn both_A) (SHD both_P).
Lemma both_r3_cells SEGS : region_cells_ok SEGS both_nu both_mem both_r3.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
all: unfold rcell_holds; cbv [is_shadow both_r3 lin_is_const andb vr_kind lc lt]; unfold cell_holds;
  eexists; split; vm_compute; reflexivity.
Qed.
Lemma both_r3_perm SEGS : region_perm_ok SEGS both_P both_E both_nu both_mem both_r3.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 64) in H.
      change (in_any_zone both_P both_E (35184372125696+off) = true /\ exists b, rdn SEGS both_mem (wordZ (35184372125696+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound both_P both_E false (35184372125696) (35184372125760)); [closed|lia].
      + destruct (witness_readable SEGS both_pristine both_runs (35184372125696) (35184372125760)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184372125696+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (0 <= off < 64) in H.
all: try (change (0 <= off); lia).
all: try (change (off < 64); lia).
all: try (change (in_rw_zones both_P both_E (35184372125696+off) = true); apply (zones_coverb_sound both_P both_E true (35184372125696) (35184372125760)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem both_pristine both_runs) (wordZ (35184372125696+off)) 1 = true); exact (proj2 (witness_readable SEGS both_pristine both_runs (35184372125696) (35184372125760) ltac:(closed) ltac:(closed) ltac:(closed) (35184372125696+off) ltac:(lia)))).
all: change (covered (unit_regions2 both_P both_E) (35184372125696+off) 1); exists (wordZ 35184372125696),64; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;right;change (In (wordZ 35184372125696,64) ([(wordZ 35184372088832,88);(wordZ 35184372092928,32768)] ++ classes_regions both_P 35184372088832 5 [(1,0)]));apply in_or_app;right;apply (class_member_in_classes both_P 35184372088832 0 5 [(1,0)]);[lia|];unfold class_regions;apply in_flat_map;exists 0;split;[apply in_map_iff;exists 0%nat;split;[reflexivity|apply in_seq;split;[apply Nat.le_refl|apply Nat.ltb_lt;vm_compute;reflexivity]]|];left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma both_r3_kind SEGS : kind_ok SEGS both_P both_E both_nu both_A both_mem both_r3.
Proof. unfold kind_ok; cbv [both_r3 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
repeat split; try closed. exists 0. repeat split; try closed.
exists (Z_to_bv 8 1). split; vm_compute; reflexivity.
Qed.
Lemma both_r3_ok SEGS : region_ok SEGS both_P both_E both_nu both_A both_mem both_r3.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow both_r3 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply both_r3_cells|]. split;[apply both_r3_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply both_r3_kind].
   Qed.
Definition both_r4 : vregion := Eval vm_compute in nth 4 (vs_rgn both_A) (SHD both_P).
Lemma both_r4_cells SEGS : region_cells_ok SEGS both_nu both_mem both_r4.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
all: unfold rcell_holds; cbv [is_shadow both_r4 lin_is_const andb vr_kind lc lt].
all: match goal with |- run_holds ?S ?M ?a ?w ?b =>
       let l := eval vm_compute in a in let h := eval vm_compute in (a+w) in
       change (run_holds S (witness_mem both_pristine both_runs) l (h-l) b);
       apply witness_run; closed end.
Qed.
Lemma both_r4_perm SEGS : region_perm_ok SEGS both_P both_E both_nu both_mem both_r4.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 8) in H.
      change (in_any_zone both_P both_E (4400193966592+off) = true /\ exists b, rdn SEGS both_mem (wordZ (4400193966592+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound both_P both_E false (4400193966592) (4400193966600)); [closed|lia].
      + destruct (witness_readable SEGS both_pristine both_runs (4400193966592) (4400193966600)
          ltac:(closed) ltac:(closed) ltac:(closed) (4400193966592+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (0 <= off < 8) in H.
all: try (change (0 <= off); lia).
all: try (change (off < 8); lia).
all: try (change (in_rw_zones both_P both_E (4400193966592+off) = true); apply (zones_coverb_sound both_P both_E true (4400193966592) (4400193966600)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem both_pristine both_runs) (wordZ (4400193966592+off)) 1 = true); exact (proj2 (witness_readable SEGS both_pristine both_runs (4400193966592) (4400193966600) ltac:(closed) ltac:(closed) ltac:(closed) (4400193966592+off) ltac:(lia)))).
all: change (covered (unit_regions2 both_P both_E) (4400193966592+off) 1); exists (wordZ 4400193966592),8; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;right;change (In (wordZ 4400193966592,8) ([(wordZ 35184372088832,88);(wordZ 35184372092928,32768)] ++ classes_regions both_P 35184372088832 5 [(1,0)]));apply in_or_app;right;apply (class_member_in_classes both_P 35184372088832 0 5 [(1,0)]);[lia|];unfold class_regions;apply in_flat_map;exists 0;split;[apply in_map_iff;exists 0%nat;split;[reflexivity|apply in_seq;split;[apply Nat.le_refl|apply Nat.ltb_lt;vm_compute;reflexivity]]|];right;left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma both_r4_kind SEGS : kind_ok SEGS both_P both_E both_nu both_A both_mem both_r4.
Proof. unfold kind_ok; cbv [both_r4 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split;[intro H;discriminate H|]. split;[intro H;discriminate H|]. split;[discriminate|].
intros _ _ _. exists both_r3. repeat split;try (solve [exists 1,0;repeat split;closed]);try closed.
Qed.
Lemma both_r4_ok SEGS : region_ok SEGS both_P both_E both_nu both_A both_mem both_r4.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow both_r4 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply both_r4_cells|]. split;[apply both_r4_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply both_r4_kind].
   Qed.
Definition both_r5 : vregion := Eval vm_compute in nth 5 (vs_rgn both_A) (SHD both_P).
Lemma both_r5_cells SEGS : region_cells_ok SEGS both_nu both_mem both_r5.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma both_r5_perm SEGS : region_perm_ok SEGS both_P both_E both_nu both_mem both_r5.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 1) in H.
      change (in_any_zone both_P both_E (35184372092928+off) = true /\ exists b, rdn SEGS both_mem (wordZ (35184372092928+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound both_P both_E false (35184372092928) (35184372092929)); [closed|lia].
      + destruct (witness_readable SEGS both_pristine both_runs (35184372092928) (35184372092929)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184372092928+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (0 <= off < 1) in H.
all: try (change (0 <= off); lia).
all: try (change (off < 1); lia).
all: try (change (in_rw_zones both_P both_E (35184372092928+off) = true); apply (zones_coverb_sound both_P both_E true (35184372092928) (35184372092929)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem both_pristine both_runs) (wordZ (35184372092928+off)) 1 = true); exact (proj2 (witness_readable SEGS both_pristine both_runs (35184372092928) (35184372092929) ltac:(closed) ltac:(closed) ltac:(closed) (35184372092928+off) ltac:(lia)))).
all: change (covered (unit_regions2 both_P both_E) (35184372092928+off) 1); exists (wordZ 35184372092928),32768; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;right;change (In (wordZ 35184372092928,32768) ([(wordZ 35184372088832,88);(wordZ 35184372092928,32768)] ++ classes_regions both_P 35184372088832 5 [(1,0)]));apply in_or_app;left;right;left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma both_r5_kind SEGS : kind_ok SEGS both_P both_E both_nu both_A both_mem both_r5.
Proof. unfold kind_ok; cbv [both_r5 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
repeat split;try reflexivity. exists both_r3,0,98%positive. repeat split; closed.
Qed.
Lemma both_r5_ok SEGS : region_ok SEGS both_P both_E both_nu both_A both_mem both_r5.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow both_r5 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply both_r5_cells|]. split;[apply both_r5_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply both_r5_kind].
   Qed.
Definition both_r6 : vregion := Eval vm_compute in nth 6 (vs_rgn both_A) (SHD both_P).
Lemma both_r6_cells SEGS : region_cells_ok SEGS both_nu both_mem both_r6.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma both_r6_perm SEGS : region_perm_ok SEGS both_P both_E both_nu both_mem both_r6.
Proof. unfold region_perm_ok.
intros H. discriminate.
Qed.
Lemma both_r6_kind SEGS : kind_ok SEGS both_P both_E both_nu both_A both_mem both_r6.
Proof. unfold kind_ok; cbv [both_r6 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
split;[discriminate|]. split;[reflexivity|]. split;[intro H;discriminate H|]. split;[intros _;reflexivity|]. split;[discriminate|]. intros _ H. exfalso. apply H. reflexivity.
Qed.
Lemma both_r6_ok SEGS : region_ok SEGS both_P both_E both_nu both_A both_mem both_r6.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow both_r6 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply both_r6_cells|]. split;[apply both_r6_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply both_r6_kind].
   Qed.
Definition both_r7 : vregion := Eval vm_compute in nth 7 (vs_rgn both_A) (SHD both_P).
Lemma both_r7_cells SEGS : region_cells_ok SEGS both_nu both_mem both_r7.
Proof. unfold region_cells_ok. intros off w v Hin. finite_in Hin; repeat split; try closed.
Qed.
Lemma both_r7_perm SEGS : region_perm_ok SEGS both_P both_E both_nu both_mem both_r7.
Proof. unfold region_perm_ok.
intros _. split.
- intros off H. change (0 <= off < 88) in H.
      change (in_any_zone both_P both_E (35184372088832+off) = true /\ exists b, rdn SEGS both_mem (wordZ (35184372088832+off)) 1 = Some [b]).
      split.
      + apply (zones_coverb_sound both_P both_E false (35184372088832) (35184372088920)); [closed|lia].
      + destruct (witness_readable SEGS both_pristine both_runs (35184372088832) (35184372088920)
          ltac:(closed) ltac:(closed) ltac:(closed) (35184372088832+off) ltac:(lia)) as [Hr _]. exact Hr.
- intros l h off Hin H. finite_in Hin; repeat split.
all: change (0 <= off < 88) in H.
all: try (change (0 <= off); lia).
all: try (change (off < 88); lia).
all: try (change (in_rw_zones both_P both_E (35184372088832+off) = true); apply (zones_coverb_sound both_P both_E true (35184372088832) (35184372088920)); [closed|lia]).
all: try (change (store_ok SEGS (witness_mem both_pristine both_runs) (wordZ (35184372088832+off)) 1 = true); exact (proj2 (witness_readable SEGS both_pristine both_runs (35184372088832) (35184372088920) ltac:(closed) ltac:(closed) ltac:(closed) (35184372088832+off) ltac:(lia)))).
all: change (covered (unit_regions2 both_P both_E) (35184372088832+off) 1); exists (wordZ 35184372088832),88; split; [unfold unit_regions2;apply in_or_app;right;apply in_or_app;right;apply in_or_app;right;change (In (wordZ 35184372088832,88) ([(wordZ 35184372088832,88);(wordZ 35184372092928,32768)] ++ classes_regions both_P 35184372088832 5 [(1,0)]));apply in_or_app;left;left;reflexivity|rewrite u_wordZ by closed;split;lia].
Qed.
Lemma both_r7_kind SEGS : kind_ok SEGS both_P both_E both_nu both_A both_mem both_r7.
Proof. unfold kind_ok; cbv [both_r7 vr_kind vr_base vr_disp vr_lo vr_hi vr_b8].
repeat split;try reflexivity;discriminate.
Qed.
Lemma both_r7_ok SEGS : region_ok SEGS both_P both_E both_nu both_A both_mem both_r7.
Proof. unfold region_ok.
     split;[closed|]. split;[closed|]. split;[closed|]. split.
     - cbv [is_data_shadow both_r7 vr_kind DATA Pos.eqb]. intros H;try discriminate;repeat split;reflexivity.
     - split;[apply both_r7_cells|]. split;[apply both_r7_perm|].
       split;[unfold region_nul_ok;intros l h Hin;finite_in Hin|apply both_r7_kind].
   Qed.
Lemma both_all_regions SEGS : forall r, In r (vs_rgn both_A) -> region_ok SEGS both_P both_E both_nu both_A both_mem r.
Proof. intros r Hin. change (In r [both_r0;both_r1;both_r2;both_r3;both_r4;both_r5;both_r6;both_r7]) in Hin.
cbn [In] in Hin.
destruct Hin as [<-|Hin]; [apply both_r0_ok|].
destruct Hin as [<-|Hin]; [apply both_r1_ok|].
destruct Hin as [<-|Hin]; [apply both_r2_ok|].
destruct Hin as [<-|Hin]; [apply both_r3_ok|].
destruct Hin as [<-|Hin]; [apply both_r4_ok|].
destruct Hin as [<-|Hin]; [apply both_r5_ok|].
destruct Hin as [<-|Hin]; [apply both_r6_ok|].
destruct Hin as [<-|Hin]; [apply both_r7_ok|].
contradiction. Qed.
