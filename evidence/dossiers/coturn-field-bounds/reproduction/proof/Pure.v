From Stdlib Require Import ZArith List Bool Lia.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import PropExec.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VLinalg VState VLogic VGamma VStepMemSound VState2 VGamma2 VCert VCert2.
From CoturnFieldAudit Require Import WitnessData Support Model.
Import ListNotations.
Open Scope Z_scope.

Ltac finite_in H :=
  vm_compute in H;
  lazymatch type of H with
  | _ \/ _ =>
      let He := fresh "selected" in let Ht := fresh "later" in
      destruct H as [He|Ht]; [inversion He; subst; try clear He|finite_in Ht]
  | False => contradiction
  end.

Ltac closed :=
  lazymatch goal with
  | |- context[rcell_holds] => fail "Use a memory lemma"
  | |- context[cell_holds] => fail "Use a memory lemma"
  | |- context[run_holds] => fail "Use a memory lemma"
  | |- context[rdn] => fail "Use a memory lemma"
  | |- context[region_cells_ok] => fail "Use a region lemma"
  | |- context[region_perm_ok] => fail "Use a region lemma"
  | |- context[region_nul_ok] => fail "Use a region lemma"
  | |- context[kind_ok] => fail "Use a region lemma"
  | |- _ => vm_compute; intuition congruence
  end.

Lemma asan_sat : sat asan_nu (vs_store (v1 asan_A)).
Proof.
  apply (sat_of_lists asan_nu (c1 asan_case)).
  - apply Forall_forall. intros [s [lo hi]] H. finite_in H; closed.
  - apply Forall_forall. intros c H. finite_in H; closed.
  - apply Forall_forall. intros [s [m r]] H. finite_in H;
      match goal with |- (?d | ?v) => exists (v/d) end; vm_compute; reflexivity.
Qed.
Lemma both_sat : sat both_nu (vs_store (v1 both_A)).
Proof.
  apply (sat_of_lists both_nu (c1 both_case)).
  - apply Forall_forall. intros [s [lo hi]] H. finite_in H; closed.
  - apply Forall_forall. intros c H. finite_in H; closed.
  - apply Forall_forall. intros [s [m r]] H. finite_in H;
      match goal with |- (?d | ?v) => exists (v/d) end; vm_compute; reflexivity.
Qed.

(* Enumerate only the finite fixed-symbol domain, preserving arbitrary fresh
   symbols rather than assuming a finite valuation type. *)
Ltac solve_fix :=
  unfold gamma_fix2, fix_val2, fix_val; intros s z;
  repeat match goal with
  | |- context[Pos.eqb s ?k] =>
      let Hfixed := fresh "Hfixed" in destruct (Pos.eqb s k) eqn:Hfixed;
      [apply Pos.eqb_eq in Hfixed; subst s; cbn; intros X; inversion X; reflexivity|]
  end;
  destruct (Pos.leb 5 s && Pos.leb s 16) eqn:Hs;
  [apply andb_true_iff in Hs as [Hl Hh]; apply Pos.leb_le in Hl; apply Pos.leb_le in Hh;
   assert (Hi : In s [5;6;7;8;9;10;11;12;13;14;15;16]%positive) by (cbn; lia);
   finite_in Hi; cbn; intros X; inversion X; reflexivity|];
  cbn;
  repeat match goal with
  | |- context[Pos.eqb s ?k] =>
      let Hfixed := fresh "Hfixed" in destruct (Pos.eqb s k) eqn:Hfixed;
      [apply Pos.eqb_eq in Hfixed; subst s; cbn; intros X; inversion X; reflexivity|]
  end;
  destruct (Pos.leb 19 s && Pos.leb s 26) eqn:Hs2;
  [apply andb_true_iff in Hs2 as [Hl Hh]; apply Pos.leb_le in Hl; apply Pos.leb_le in Hh;
   assert (Hi : In s [19;20;21;22;23;24;25;26]%positive) by (cbn; lia);
   finite_in Hi; cbn; intros X; inversion X; reflexivity|discriminate].

Lemma asan_fixed : gamma_fix2 asan_E asan_nu.
Proof. solve_fix. Qed.
Lemma both_fixed : gamma_fix2 both_E both_nu.
Proof. solve_fix. Qed.

Lemma asan_divdefs : gamma_divdef asan_nu asan_A.
Proof.
  intros q x m H. change (pm_get q (pm_of_list (cs_divdef asan_case)) = Some (x,m)) in H.
  apply pm_of_list_get_in in H.
  finite_in H; closed.
Qed.
Lemma both_divdefs : gamma_divdef both_nu both_A.
Proof.
  intros q x m H. change (pm_get q (pm_of_list (cs_divdef both_case)) = Some (x,m)) in H.
  apply pm_of_list_get_in in H.
  finite_in H; closed.
Qed.

Lemma asan_rank_nonnegative : 0 <= eval asan_nu asan_rank.
Proof. closed. Qed.
Lemma both_rank_nonnegative : 0 <= eval both_nu both_rank.
Proof. closed. Qed.
