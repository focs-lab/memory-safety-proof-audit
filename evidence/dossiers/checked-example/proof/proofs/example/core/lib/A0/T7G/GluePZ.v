(* example/core: PZ_agree / PZ_INIT for our PZ = shw m HANDLERS_A 2048 (replaces pupnp's A0/T7G/GluePZ.v), from
   pupnp's generic lemmas in that file (see replay/port/gen_overlay_pz.py).
   port: donor-derived (addresses are renamed like a donor file's) *)
(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From stdpp Require Import base list.
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType StackLayout State Run.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac Arr Bytes Image Agree Ceiling.
From OssFuzzTheorems.example.core.images Require Import Asan.
From OssFuzzTheorems.Proofs.example.core.lib.ASN Require Import MainExport MainFactsAsan A0Img MainEntry A0Handoff.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAW Require Import Segs Shadow Contracts Globals IcptA0 AllocA0.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7A0 Require Import ShadowKit RF_mainA_A.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7G Require Import GlueKit GlueA0_T.
Import ListNotations.
Open Scope Z_scope.
Unset Lia Cache. Unset Nia Cache. Unset Nra Cache.

From OssFuzzTheorems.Proofs.example.core.lib.A0.AW Require Import PZDef.
Section Agree.
Context {HC : HasCeiling}.
Variable P : Z -> Prop.
Variables m m' : mem.
Hypothesis AG : gagree_on P m m'.
Hypothesis HP : forall a, pz_band a -> P a.

#[using="HP"] Lemma HPsh : forall a, 0x7fffa000 <= a < 0x800b6600 -> P a.
Proof. intros a Ha. apply HP. unfold pz_band. lia. Qed.

#[using="P AG HP"] Lemma shw_agree_img : forall A n, shw m A n -> 0x10000 <= A -> A + n <= 0x5f3000 -> shw m' A n.
Proof.
  intros A n (ACC & SR & W) HA HN. split; [| split; [| exact W]].
  - intros a Ha. destruct (ACC a Ha) as (k & BA & HK). exists k. split; [| exact HK].
    eapply bytes_at_gagree; [exact AG| exact BA|]. cbn [length]. intros x Hx. apply HPsh. unfold sh, SHADOW_OFF in *. Z.div_mod_to_equations. lia.
  - intros Hn a Ha. destruct (SR Hn a Ha) as [v Hv]. exists v.
    eapply gagree_mrd; [exact AG| | | exact Hv]; [unfold sh, SHADOW_OFF in *; Z.div_mod_to_equations; lia|].
    apply HPsh. unfold sh, SHADOW_OFF in *. Z.div_mod_to_equations. lia.
Qed.

End Agree.

Definition fact_k (f : mfact) : option (Z * Z) :=
  match f with MCell (ZLit a) 1%nat (ZLit k) => Some (a, k) | _ => None end.
Lemma fact_k_sound : forall V (m : mem) f a k, mfact_ok asegs V m f -> fact_k f = Some (a, k) -> bytes_at asegs m a [Z_to_bv 8 k].
Proof.
  intros V m f a k OK E. destruct f as [e w v|e n|e w v|e n|e n c|lo hi|e n|e n|e n]; cbn [fact_k] in E; try discriminate.
  destruct e as [z0| | | | |]; try discriminate. destruct w as [|[|w]]; try discriminate. destruct v as [k0| | | | |]; try discriminate.
  injection E as <- <-. cbn [mfact_ok zv cellw] in OK. destruct OK as [[_ B] _]. cbn [cells_bytes cbytes] in B. rewrite app_nil_r in B. exact B.
Qed.

Fixpoint acc_chk (l : list mfact) (fuel : nat) (A hi : Z) : bool :=
  if hi <=? A then true else
  match fuel with
  | O => false
  | S fuel' =>
      let gend := Z.min hi (8 * (A / 8) + 8) in
      let x := A / 8 + 0x7fff8000 in
      (cover true l 2 x (x + 1)
       || existsb (fun f => match fact_k f with Some (a, k) => (a =? x) && (0 <? k) && (k <? 8) && ((gend - 1) mod 8 <? k) | None => false end) l)
      && acc_chk l fuel' gend hi
  end.
Lemma acc_chk_sound : forall V (m : mem) l fuel A hi, Forall (mfact_ok asegs V m) l -> 0 <= A -> hi <= 2^61 -> acc_chk l fuel A hi = true ->
  forall a, A <= a < hi -> acc m a.
Proof.
  intros V m l fuel. induction fuel as [|fuel IH]; intros A hi HF HA HH H a Ha; cbn [acc_chk] in H;
    (destruct (Z.leb_spec0 hi A); [lia|]); [discriminate|].
  apply andb_prop in H as [H1 H2].
  set (gend := Z.min hi (8 * (A / 8) + 8)) in *. set (x := A / 8 + 0x7fff8000) in *.
  destruct (Z.lt_ge_cases a gend) as [LT|GE]; [| apply (IH gend hi HF ltac:(subst gend; Z.div_mod_to_equations; lia) HH H2 a); lia].
  assert (SA : sh a = x) by (unfold sh, SHADOW_OFF; subst x gend; Z.div_mod_to_equations; lia).
  apply orb_prop in H1 as [C|E].
  - destruct (cover_sound V m true l 2 x (x + 1) HF C x ltac:(lia)) as [_ Z0]. specialize (Z0 eq_refl).
    exists 0. split; [| left; reflexivity]. rewrite SA. split; [subst x; Z.div_mod_to_equations; lia|]. split; [cbn [length]; subst x; Z.div_mod_to_equations; lia|].
    intros i Hi. cbn [length] in Hi. assert (i = 0%nat) by lia. subst i. rewrite Z.add_0_r. exact Z0.
  - apply existsb_exists in E as (f & Hin & Hf). destruct (fact_k f) as [[a0 k]|] eqn:FK; [| discriminate].
    apply andb_prop in Hf as [Hf K4]. apply andb_prop in Hf as [Hf K3]. apply andb_prop in Hf as [K1 K2].
    apply Z.eqb_eq in K1. apply Z.ltb_lt in K2. apply Z.ltb_lt in K3. apply Z.ltb_lt in K4. subst a0.
    pose proof (fact_k_sound V m f x k (proj1 (Forall_forall _ _) HF f Hin) FK) as B.
    exists k. split; [rewrite SA; exact B|]. right. split; [lia|]. subst gend. Z.div_mod_to_equations. lia.
Qed.

Lemma shw_init : forall V (m : mem) l A n f1 f2, Forall (mfact_ok asegs V m) l -> 0 < n -> 4096 <= A -> A + n <= 0x7fff7000 ->
  acc_chk l f1 A (A + n) = true ->
  cover false l f2 (sh A - sh A mod 8) (sh (A + n - 1) - sh (A + n - 1) mod 8 + 8) = true ->
  shw m A n.
Proof.
  intros V m l A n f1 f2 HF Hn HA HN C1 C2. split; [| split].
  - exact (acc_chk_sound V m l f1 A (A + n) HF ltac:(lia) ltac:(lia) C1).
  - intros _ a Ha. exact (proj1 (cover_sound V m false l f2 _ _ HF C2 a Ha)).
  - split; [lia| left; lia].
Qed.
Ltac shw_lit V m HM A n := apply (shw_init V m _ A n 400%nat 400%nat HM); [lia| lia| lia| vm_compute; reflexivity| vm_compute; reflexivity].
Lemma pz_band_handlers : forall a, 0x85d44 <= a < 0x85d44 + 2048 -> pz_band a.
Proof. intros a Ha. unfold pz_band. left. lia. Qed.

Theorem PZ_agree : forall (P : Z -> Prop) (m m' : mem), gagree_on P m m' -> (forall a, pz_band a -> P a) -> PZ m -> PZ m'.
Proof.
  intros P m m' AG HP [SH CT]. unfold PZ, PZDef.HANDLERS_A, PZDef.HANDLERS_BYTES in *. split.
  - exact (shw_agree_img P m m' AG HP _ _ SH ltac:(lia) ltac:(lia)).
  - eapply (bytes_at_gagree P m m'); [exact AG| exact CT|].
    assert (LL : Z.of_nat (length (u64s PZDef.HTAB)) = 2048) by (rewrite u64s_length, PZDef.HTAB_length; reflexivity).
    rewrite LL. intros a Ha. apply HP. unfold pz_band. left. lia.
Qed.


Theorem PZ_INIT : forall V (m : mem), Forall (mfact_ok asegs V m) asan_mem_facts -> PZ m.
Proof.
  intros V m HM. unfold PZ, PZDef.HANDLERS_A, PZDef.HANDLERS_BYTES. split.
  - apply (shw_init V m _ _ _ 400%nat 400%nat HM); [lia| lia| lia| vm_compute; reflexivity| vm_compute; reflexivity].
  - apply (aimg_bytes V m _ _ (u64s PZDef.HTAB) HM);
      [ vm_compute; reflexivity | vm_compute; reflexivity | lia | rewrite u64s_length, PZDef.HTAB_length; cbn; lia ].
Qed.
