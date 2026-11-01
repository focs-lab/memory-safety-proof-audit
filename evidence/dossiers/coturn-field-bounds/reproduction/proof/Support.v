From Stdlib Require Import ZArith List Bool Lia.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import PropExec CatExec.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VLinalg VState VLogic VGamma VStepMemSound VState2 VGamma2 VCert VCert2.
Import ListNotations.
Open Scope Z_scope.
#[local] Existing Instance PropExec.fx0.

Definition run := (Z * (Z * Z))%type.
Fixpoint lookup_runs (a : Z) (xs : list run) : Z :=
  match xs with
  | [] => 0
  | (lo,(hi,b)) :: tail =>
      if (lo <=? a) && (a <? hi) then b else lookup_runs a tail
  end.

Definition disjointb (lo hi lo' hi' : Z) : bool :=
  (hi <=? lo') || (hi' <=? lo).
Definition runs_valueb (xs : list run) (lo hi b : Z) : bool :=
  forallb (fun r => (snd (snd r) =? b) || disjointb lo hi (fst r) (fst (snd r))) xs
  && ((b =? 0) || existsb (fun r => (snd (snd r) =? b) && (fst r <=? lo) && (hi <=? fst (snd r))) xs).

Lemma lookup_runs_value xs lo hi b :
  runs_valueb xs lo hi b = true ->
  forall a, lo <= a < hi -> lookup_runs a xs = b.
Proof.
  unfold runs_valueb. rewrite andb_true_iff.
  intros [Hagree Hcover] a Ha.
  rewrite forallb_forall in Hagree.
  rewrite orb_true_iff, Z.eqb_eq, existsb_exists in Hcover.
  induction xs as [|[l [h v]] tail IH].
  - cbn in *. destruct Hcover as [->|[r [H _]]]; [reflexivity|contradiction].
  - cbn [lookup_runs]. destruct ((l <=? a) && (a <? h)) eqn:Hhit.
    + specialize (Hagree (l,(h,v)) (or_introl eq_refl)). cbn in Hagree.
      rewrite orb_true_iff, Z.eqb_eq in Hagree.
      destruct Hagree as [->|Hbad]; [reflexivity|].
      unfold disjointb in Hbad. rewrite orb_true_iff, !Z.leb_le in Hbad.
      rewrite andb_true_iff, Z.leb_le, Z.ltb_lt in Hhit. lia.
    + apply IH.
      * intros r Hr. apply Hagree. right. exact Hr.
      * destruct Hcover as [H0|[r [Hr Hc]]]; [left;exact H0|].
        destruct Hr as [<-|Hr].
        -- cbn in Hc. rewrite !andb_true_iff, Z.eqb_eq, !Z.leb_le in Hc.
           rewrite andb_false_iff, Z.leb_gt, Z.ltb_ge in Hhit. lia.
        -- right. exists r. auto.
Qed.

Definition clearb (pristine : list (Z * Z)) (lo hi : Z) : bool :=
  forallb (fun r => disjointb lo hi (fst r) (snd r)) pristine.
Definition pristineb (pristine : list (Z * Z)) (a : Z) : bool :=
  existsb (fun r => (fst r <=? a) && (a <? snd r)) pristine.
Definition witness_mem (pristine : list (Z * Z)) (xs : list run)
    (a : word) : option byte :=
  if pristineb pristine (bv_unsigned a) then None
  else Some (Z_to_bv 8 (lookup_runs (bv_unsigned a) xs)).

Lemma clearb_sound pristine lo hi a :
  clearb pristine lo hi = true -> lo <= a < hi ->
  pristineb pristine a = false.
Proof.
  unfold clearb, pristineb. rewrite forallb_forall.
  intros H Ha. apply Bool.not_true_is_false. intro Hex.
  apply existsb_exists in Hex as [r [Hr Hhit]]. specialize (H r Hr).
  unfold disjointb in H. rewrite orb_true_iff, !Z.leb_le in H.
  apply andb_true_iff in Hhit as [Hlo Hhi].
  apply Z.leb_le in Hlo. apply Z.ltb_lt in Hhi. lia.
Qed.

Lemma witness_mem_range pristine xs lo hi b :
  0 <= lo -> hi <= 2^64 -> clearb pristine lo hi = true ->
  runs_valueb xs lo hi b = true ->
  forall a, lo <= a < hi ->
  witness_mem pristine xs (wordZ a) = Some (Z_to_bv 8 b).
Proof.
  intros Hl Hh Hclear Hval a Ha. unfold witness_mem.
  rewrite u_wordZ by lia.
  rewrite (clearb_sound _ _ _ _ Hclear Ha).
  rewrite (lookup_runs_value _ _ _ _ Hval _ Ha). reflexivity.
Qed.

Lemma witness_mem_defined pristine xs lo hi :
  0 <= lo -> hi <= 2^64 -> clearb pristine lo hi = true ->
  forall a, lo <= a < hi ->
  exists b, witness_mem pristine xs (wordZ a) = Some b.
Proof.
  intros Hl Hh Hclear a Ha. unfold witness_mem.
  rewrite u_wordZ by lia. rewrite (clearb_sound _ _ _ _ Hclear Ha). eauto.
Qed.

Lemma read_one SEGS mem a b :
  mem (wordZ a) = Some b -> rdn SEGS mem (wordZ a) 1 = Some [b].
Proof. intros H. rewrite rdn_1, H. reflexivity. Qed.

Lemma store_one SEGS mem a b :
  mem (wordZ a) = Some b -> store_ok SEGS mem (wordZ a) 1 = true.
Proof. intros H. cbn [store_ok]. unfold wview. rewrite H. reflexivity. Qed.

Lemma witness_readable SEGS pristine xs lo hi :
  0 <= lo -> hi <= 2^64 -> clearb pristine lo hi = true ->
  forall a, lo <= a < hi ->
    (exists b, rdn SEGS (witness_mem pristine xs) (wordZ a) 1 = Some [b]) /\
    store_ok SEGS (witness_mem pristine xs) (wordZ a) 1 = true.
Proof.
  intros Hl Hh Hclear a Ha.
  destruct (witness_mem_defined pristine xs lo hi Hl Hh Hclear a Ha) as [b Hb].
  split; [exists b;apply read_one,Hb|eapply store_one;exact Hb].
Qed.

Lemma witness_run SEGS pristine xs lo hi b :
  0 <= lo -> hi <= 2^64 -> clearb pristine lo hi = true ->
  runs_valueb xs lo hi b = true ->
  run_holds SEGS (witness_mem pristine xs) lo (hi-lo) b.
Proof.
  intros Hl Hh Hclear Hval i Hi. exists (Z_to_bv 8 b). split.
  - apply read_one. apply (witness_mem_range _ _ lo hi b); try assumption; lia.
  - rewrite Z_to_bv_unsigned. change (zwrap 8 b = Z.land b (2^8-1)).
    symmetry. apply land_mask_zwrap. lia.
Qed.

Lemma sat_of_lists nu cs :
  Forall (fun si => in_itv (nu (fst si)) (snd si)) (cs_box cs) ->
  Forall (fun c => eval nu c <= 0) (cs_cons cs) ->
  Forall (fun si => (fst (snd si) | nu (fst si) - snd (snd si))) (cs_cong cs) ->
  sat nu (store_of cs).
Proof.
  intros Hb Hc Hg. unfold sat, store_of; cbn. split; [|split]; auto.
  - intros s i Hsi. apply pm_of_list_get_in in Hsi.
    rewrite Forall_forall in Hb. exact (Hb _ Hsi).
  - intros s m r Hs. apply pm_of_list_get_in in Hs.
    rewrite Forall_forall in Hg. exact (Hg _ Hs).
Qed.

Definition zones_coverb (P : vparams2) (E : venv2) (rw : bool) (lo hi : Z) :=
  existsb (fun z => (zone_lo E z <=? lo) && (hi <=? zone_hi E z))
    (if rw then rw_zones P else vp_fzones P).

Lemma zones_coverb_sound P E rw lo hi :
  zones_coverb P E rw lo hi = true ->
  forall a, lo <= a < hi ->
    (if rw then in_rw_zones P E a else in_any_zone P E a) = true.
Proof.
  unfold zones_coverb. intros H a Ha.
  apply existsb_exists in H as [z [Hz Hb]].
  apply andb_true_iff in Hb as [Hl Hh]. apply Z.leb_le in Hl,Hh.
  destruct rw; cbn in *; unfold in_rw_zones, in_any_zone;
    apply existsb_exists; exists z; split; [exact Hz| |exact Hz|];
    unfold in_zoneb; apply andb_true_iff; split; [apply Z.leb_le|apply Z.ltb_lt|apply Z.leb_le|apply Z.ltb_lt];
    lia.
Qed.

Definition coveredb (rs : list (word * Z)) (lo hi : Z) : bool :=
  existsb (fun r => (bv_unsigned (fst r) <=? lo) &&
                    (hi <=? bv_unsigned (fst r) + snd r)) rs.

Lemma coveredb_sound rs lo hi :
  coveredb rs lo hi = true ->
  forall a, lo <= a < hi -> covered rs a 1.
Proof.
  unfold coveredb. intros H a Ha.
  apply existsb_exists in H as [[base len] [Hin Hc]].
  apply andb_true_iff in Hc as [Hl Hh]. apply Z.leb_le in Hl,Hh.
  exists base,len. cbn in *. repeat split; auto; lia.
Qed.

Lemma witness_pristine_at pristine xs lo hi (a : word) :
  In (lo,hi) pristine -> lo <= bv_unsigned a < hi ->
  witness_mem pristine xs a = None.
Proof.
  intros Hin Ha. unfold witness_mem.
  assert (H : pristineb pristine (bv_unsigned a) = true).
  { unfold pristineb. apply existsb_exists. exists (lo,hi). split; auto.
    cbn. apply andb_true_iff. split; [apply Z.leb_le|apply Z.ltb_lt]; lia. }
  rewrite H. reflexivity.
Qed.

Definition zones_avoidb (P : vparams2) (E : venv2) (lo hi : Z) :=
  forallb (fun z => disjointb lo hi (zone_lo E z) (zone_hi E z)) (rw_zones P).

Lemma zones_avoidb_sound P E lo hi :
  zones_avoidb P E lo hi = true ->
  forall a, lo <= a < hi -> in_rw_zones P E a = false.
Proof.
  unfold zones_avoidb, in_rw_zones. rewrite forallb_forall.
  intros H a Ha. apply Bool.not_true_is_false. intro Hex.
  apply existsb_exists in Hex as [z [Hz Hhit]]. specialize (H z Hz).
  unfold disjointb in H. rewrite orb_true_iff, !Z.leb_le in H.
  unfold in_zoneb in Hhit. rewrite andb_true_iff, Z.leb_le, Z.ltb_lt in Hhit. lia.
Qed.

Definition env_zonesb (P : vparams2) (E : venv2) :=
  forallb (fun z =>
    (0 <=? zone_lo E z) && (zone_lo E z <=? zone_hi E z) && (zone_hi E z <=? 2^64)
    && disjointb (zone_lo E z) (zone_hi E z) (e_sp0 (ev1 E)-vp_frame (p1 P)) (e_sp0 (ev1 E))
    && forallb (fun c => disjointb (zone_lo E z) (zone_hi E z) (fst c) (fst c+snd c)) (vp_fcells (p1 P))
    && (negb (fz_rw z) || disjointb (zone_lo E z) (zone_hi E z) (e_data (ev1 E)) (e_data (ev1 E)+e_size (ev1 E)))
    && forallb (fun r => disjointb (zone_lo E z) (zone_hi E z) (fst r) (snd r)) (vp_pristine (p1 P)))
    (vp_fzones P).

Lemma disjointb_sound lo hi lo' hi' a :
  disjointb lo hi lo' hi' = true -> lo <= a < hi -> ~ (lo' <= a < hi').
Proof. unfold disjointb. rewrite orb_true_iff, !Z.leb_le. lia. Qed.

Lemma env_zonesb_sound P E : env_zonesb P E = true -> env_zones P E.
Proof.
  unfold env_zonesb. rewrite forallb_forall. intros H. unfold env_zones.
  split.
  - intros z Hz. specialize (H z Hz).
    repeat rewrite andb_true_iff in H.
    destruct H as [[[[[[Hlo Hmid] Hhi] Hstack] Hcells] Hdata] Hprist].
    apply Z.leb_le in Hlo,Hmid,Hhi. auto.
  - intros z a Hz Ha. specialize (H z Hz).
    repeat rewrite andb_true_iff in H.
    destruct H as [[[[[[Hlo Hmid] Hhi] Hstack] Hcells] Hdata] Hprist].
    unfold in_zone in Ha.
    split; [eapply disjointb_sound; eauto|]. split.
    + intros c Hc. rewrite forallb_forall in Hcells.
      exact (disjointb_sound _ _ _ _ a (Hcells c Hc) Ha).
    + split.
      * intro Hw. rewrite Hw in Hdata. cbn in Hdata. eapply disjointb_sound; eauto.
      * intros lo hi Hr. rewrite forallb_forall in Hprist.
        exact (disjointb_sound _ _ _ _ a (Hprist (lo,hi) Hr) Ha).
Qed.
