(* Independent audit witness, 2026-11-01. Imports unchanged upstream definitions.
   This is a new synthetic client, not the published bndiv fuzz client. *)
From Stdlib Require Import ZArith List Lia Bool Permutation.
From OssFuzzTheorems.Proofs.openssl.bndiv.lib.Spec Require Import BnBase BnWords BnKara BnModel BnTree BnInv BnSpecs.
Import ListNotations.
Open Scope Z_scope.

Definition ops := tree_ops nat.
Definition one_bn : bignum nat := mkBN (Some 3%nat) [1] 1 false 0.
Definition pool := one_bn :: repeat (bn_nil 0 : bignum nat) 15.
Definition before_end : lstate nat :=
  set_ctx (mkCtx (Some 2%nat) (Some 2%nat) pool 1 16 (Some 1%nat) [0%nat] 32 1 0 false) ls_init.
Definition after_end : lstate nat :=
  set_ctx (mkCtx (Some 2%nat) None pool 0 16 (Some 1%nat) [] 32 0 0 false) ls_init.
Definition owned : blocks := [(3%nat,8); (2%nat,400); (1%nat,128)].
Definition after_write := setbn (RPool 0) (bn_with_neg one_bn true) after_end.

Definition prefix :=
  bbind ops (BN_CTX_start ops) (fun _ =>
  bbind ops (BN_CTX_get ops) (fun t =>
  bbind ops (BN_bin2bn ops [1] t) (fun _ => bret ops t))).
Definition expired_write_client :=
  bbind ops prefix (fun t =>
  bbind ops (BN_CTX_end ops) (fun _ =>
  BN_set_negative ops t true)).

(* Exact successful execution using upstream's own run_tree, with distinct
   allocation identifiers 1, 2, 3 and no free events. *)
Theorem prefix_reaches_before_end :
  run_tree (prefix ls_init) 1 [] =
  ([EvMalloc 128 1; EvMalloc 400 2; EvMalloc 8 3], 4%nat,
   Some (RPool 0, before_end)).
Proof. reflexivity. Qed.

Theorem end_retains_storage :
  BN_CTX_end ops before_end = TRet (tt, after_end).
Proof. reflexivity. Qed.

Lemma one_bn_ok : bn_ok one_bn.
Proof.
  unfold bn_ok, one_bn, bn_dmax, DMAX_MAX. cbn.
  split.
  - constructor; [unfold limb, BW; lia|constructor].
  - repeat split; auto; lia.
Qed.

Lemma pool_ok_witness : pool_ok pool.
Proof.
  right. exists one_bn, (bn_nil 0), (bn_nil 0).
  split; [reflexivity|]. split; [exact one_bn_ok|].
  split; apply bn_ok_nil; auto.
Qed.

Lemma before_st_ok : st_ok before_end.
Proof.
  unfold st_ok, before_end, set_ctx, ls_init; cbn.
  repeat split; try (apply bn_ok_nil; auto).
  all: try exact pool_ok_witness.
Qed.

Lemma after_st_ok : st_ok after_end.
Proof. exact before_st_ok. Qed.

Lemma before_own : own before_end owned.
Proof. apply Permutation_refl. Qed.
Lemma after_own : own after_end owned.
Proof. apply Permutation_refl. Qed.

Lemma before_wf : ctx_wf (ls_ctx before_end).
Proof.
  unfold ctx_wf, before_end; cbn.
  repeat split; auto; try lia; try (right; split; [reflexivity|discriminate]).
  discriminate.
Qed.

Lemma after_rest : ctx_rest (ls_ctx after_end).
Proof.
  unfold ctx_rest, ctx_wf, after_end; cbn.
  repeat split; auto; try lia; try (right; split; [reflexivity|discriminate]).
Qed.

Lemma before_valid : valid_ref (RPool 0) before_end.
Proof. split; [lia|discriminate]. Qed.
Lemma after_valid : valid_ref (RPool 0) after_end.
Proof. split; [lia|discriminate]. Qed.

(* Conjunction of every precondition in BN_CTX_end_spec. *)
Theorem all_end_preconditions :
  st_ok before_end /\ own before_end owned /\
  ctx_wf (ls_ctx before_end) /\ cx_frames (ls_ctx before_end) = [0%nat].
Proof. exact (conj before_st_ok (conj before_own (conj before_wf eq_refl))). Qed.

(* Every precondition in BN_set_negative_spec, with ctx_rest added. *)
Theorem all_setter_preconditions_after_end :
  st_ok after_end /\ own after_end owned /\
  valid_ref (RPool 0) after_end /\ ctx_rest (ls_ctx after_end) /\
  cx_frames (ls_ctx after_end) = [] /\ cx_used (ls_ctx after_end) = 0%nat.
Proof.
  split; [exact after_st_ok|]. split; [exact after_own|].
  split; [exact after_valid|]. split; [exact after_rest|]. split; reflexivity.
Qed.

Theorem stale_write_accepted_by_exact_setter_spec :
  bwp (BN_set_negative ops (RPool 0) true) after_end owned
      (fun _ s X => st_ok s /\ own s X /\
        cx_frames (ls_ctx s) = [] /\ cx_used (ls_ctx s) = 0%nat /\
        bn_neg (getbn (RPool 0) s) = true).
Proof.
  apply BN_set_negative_spec.
  - exact after_st_ok.
  - exact after_own.
  - exact after_valid.
  - cbv zeta. intros Hs Ho. split; [exact Hs|]. split; [exact Ho|].
    repeat split; reflexivity.
Qed.

Theorem stale_write_really_changes_value :
  BN_set_negative ops (RPool 0) true after_end = TRet (tt, after_write) /\
  bn_neg (getbn (RPool 0) after_end) = false /\
  bn_neg (getbn (RPool 0) after_write) = true.
Proof. repeat split; reflexivity. Qed.

Theorem entire_synthetic_client_executes :
  run_tree (expired_write_client ls_init) 1 [] =
  ([EvMalloc 128 1; EvMalloc 400 2; EvMalloc 8 3], 4%nat,
   Some (tt, after_write)).
Proof. reflexivity. Qed.

Theorem nonempty_pool_and_no_active_frame :
  exists (s : lstate nat) X,
    st_ok s /\ own s X /\ ctx_rest (ls_ctx s) /\
    valid_ref (RPool 0) s /\ cx_frames (ls_ctx s) = [] /\ cx_used (ls_ctx s) = 0%nat.
Proof.
  exists after_end, owned. split; [exact after_st_ok|].
  split; [exact after_own|]. split; [exact after_rest|].
  split; [exact after_valid|]. split; reflexivity.
Qed.

Print Assumptions prefix_reaches_before_end.
Print Assumptions end_retains_storage.
Print Assumptions all_end_preconditions.
Print Assumptions all_setter_preconditions_after_end.
Print Assumptions stale_write_accepted_by_exact_setter_spec.
Print Assumptions stale_write_really_changes_value.
Print Assumptions entire_synthetic_client_executes.
Print Assumptions nonempty_pool_and_no_active_frame.
