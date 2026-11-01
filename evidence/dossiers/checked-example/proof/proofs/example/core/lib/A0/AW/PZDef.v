(* example/core: the harness's static-data predicate PZ (replaces pupnp's A0/AW/PZDef.v).
   Our harness reads only the dispatch table handlers[256] (static const, 2048 bytes at 0x955a0 in core.asan).
   Like pupnp's PZ (which carried its parser tables' shadow AND contents), PZ asserts both that the table bytes
   are ASan-accessible (shw) and their contents (every entry is h_nop 0x7e780 or h_admin 0x7e784), which the
   indirect call handlers[op]() needs to land on a real `ret`. *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Run.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Arr Mem.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAW Require Import Segs Shadow.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7A0 Require Import ShadowKit.
Import ListNotations.
Open Scope Z_scope.

Definition HANDLERS_A : Z := 0x955a0.
Definition HANDLERS_BYTES : Z := 2048.
Definition H_NOP : Z := 0x7e780.
Definition H_ADMIN : Z := 0x7e784.
Definition HTAB : list word := repeat (Z_to_bv 64 H_NOP) 255 ++ [Z_to_bv 64 H_ADMIN].

Definition PZ (m : mem) : Prop :=
  shw m HANDLERS_A HANDLERS_BYTES /\ bytes_at asegs m HANDLERS_A (u64s HTAB).

Lemma HTAB_length : length HTAB = 256%nat.
Proof. unfold HTAB. rewrite length_app, repeat_length. reflexivity. Qed.

Lemma HTAB_entry : forall op, 0 <= op < 256 -> nth (Z.to_nat op) HTAB (Z_to_bv 64 0) = Z_to_bv 64 H_NOP \/ nth (Z.to_nat op) HTAB (Z_to_bv 64 0) = Z_to_bv 64 H_ADMIN.
Proof.
  intros op Hop. unfold HTAB. destruct (Z.eq_dec op 255) as [->|N].
  - right. rewrite app_nth2; rewrite repeat_length; [cbn|lia]. reflexivity.
  - left. rewrite app_nth1 by (rewrite repeat_length; lia). rewrite (nth_indep _ _ (Z_to_bv 64 H_NOP)) by (rewrite repeat_length; lia). apply nth_repeat.
Qed.

Lemma pz_read : forall m op, PZ m -> 0 <= op < 256 ->
  ov_read_bytes asegs m (wa (HANDLERS_A + 8 * op)) 8 = Some (le8 (nth (Z.to_nat op) HTAB (Z_to_bv 64 0))).
Proof.
  intros m op [_ BA] Hop.
  assert (NE : nth_error HTAB (Z.to_nat op) = Some (nth (Z.to_nat op) HTAB (Z_to_bv 64 0))).
  { apply nth_error_nth'. rewrite HTAB_length; lia. }
  destruct (u64s_split HTAB (Z.to_nat op) _ NE) as (pre & post & E & Hlen & Eu & Hlu).
  replace (8 * op) with (Z.of_nat (8 * Z.to_nat op)) by lia.
  rewrite (bytes_at_ov_read asegs m HANDLERS_A (u64s HTAB) (8 * Z.to_nat op) 8 BA).
  2:{ rewrite Eu, !app_length, length_le8, Hlu. lia. }
  rewrite Eu, skipn_app, skipn_all2, Hlu, Nat.sub_diag by lia. rewrite skipn_O, app_nil_l.
  rewrite firstn_app, firstn_all2 by (rewrite length_le8; lia).
  rewrite length_le8, Nat.sub_diag, firstn_O, app_nil_r. reflexivity.
Qed.
