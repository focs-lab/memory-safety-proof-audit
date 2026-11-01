(* example/core: the plain harness contract for core.plain's LLVMFuzzerTestOneInput (0x12a80, 44 instructions), closed for
   the plain allocator (replaces pupnp's P0/H_parser_inst.v, H_fuzz_entry.v, H_fuzz_segs.v and the 22 P0/H_* files behind
   them).  Statement: fuzz_one_stmt, as in pupnp (H_fuzz_stmt.v).  Written for this study, in pupnp's proof style.
   fzc_loop: the fill loop, which writes x[0..min(size,21)-1], including x[20] = x->op: every write stays in the 21-byte
   malloc block, which is all this contract needs.  fzc_disp: the load handlers[op] and the jump, with op = 255 going to
   h_admin; the proof treats that branch like any other, because nothing in the statement distinguishes them. *)
From stdpp Require Import base list.
From Stdlib Require Import ZArith NArith List Lia Bool Permutation.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Run Fs.
From LinuxProcessSemantics.Riscv Require Import Prelude Instr Decode DecodeC Sem Fpu.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac ZBridge STRW_tac Image Arr MState Ceiling RunWord.
From OssFuzzTheorems.Proofs.example.core.lib.Top Require Import Realize SafeReach AllocIF SReach AllocSpec.
From OssFuzzTheorems.Proofs.example.core.lib.Http Require Import HttpTac.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Agree.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import Segs H_fuzz_stmt RMallocRep RMalloc_iface RDriver_ctx AllocInst.
Import ListNotations.
Open Scope Z_scope.
Set Printing Width 200.
Local Notation wz := (Z_to_bv 64).
Local Ltac sstep := step; fix_lit_store.



Lemma u64arr_read_ro : forall (m : mem) A ws (i : Z) w a,
  bytes_at rsegs m A (u64s ws) -> nth_error ws (Z.to_nat i) = Some w -> (0 <= i)%Z -> a = wa (A + 8 * i) ->
  ov_read_bytes rsegs m a 8 = Some (le8 w).
Proof.
  intros m A ws i w a Hb Hn Hi ->.
  destruct (u64s_split _ _ _ Hn) as (pre & post & E & Hlen & Eu & Hlu).
  replace (8 * i)%Z with (Z.of_nat (8 * Z.to_nat i))%Z by lia.
  rewrite (bytes_at_ov_read rsegs m A (u64s ws) (8 * Z.to_nat i) 8 Hb).
  2:{ rewrite Eu, !app_length, length_le8, Hlu. lia. }
  rewrite Eu, skipn_app, skipn_all2, Hlu, Nat.sub_diag by lia. rewrite skipn_O, app_nil_l.
  rewrite firstn_app, firstn_all2 by (rewrite length_le8; lia).
  rewrite length_le8, Nat.sub_diag, firstn_O, app_nil_r. reflexivity.
Qed.

Section Loop.
Variables (Q : machine_state -> Prop) (A D k : Z) (data : list byte)
  (RA SP GP TP T0 T1 T2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6 : word) (F : bvmap 5 word) (fc : bv 32) (m0 : mem).
Hypothesis A0 : 0 < A.
Hypothesis AHI : A + 21 < 2^63.
Hypothesis K1 : 1 <= k <= 21.
Hypothesis KL : k <= Z.of_nat (length data).
Hypothesis D0 : 0 <= D.
Hypothesis DHI : D + Z.of_nat (length data) < 2^63.
Hypothesis SEP : D + Z.of_nat (length data) <= A \/ A + 21 <= D.
Hypothesis EXIT : forall (m' : mem) bs' a2, mem_inv rsegs m' -> munch [(A, A + 21)] m0 m' -> wmono rsegs m0 m' ->
  u8arr rsegs m' A bs' -> length bs' = 21%nat -> bytes_at rsegs m' D data ->
  evt rsegs Q (MS (mkR RA SP GP TP T0 T1 T2 (wz A) (wz (D + k)) (wz (A + k)) (wz (A + k)) a2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
         F (wz 0x12ae4) fc None m' (seg_rom rsegs)).
Lemma fzc_loop : forall fuel i (m : mem) bs a2,
  Z.of_nat fuel = k - i -> 0 <= i < k -> mem_inv rsegs m -> munch [(A, A + 21)] m0 m -> wmono rsegs m0 m ->
  u8arr rsegs m A bs -> length bs = 21%nat -> bytes_at rsegs m D data ->
  evt rsegs Q (MS (mkR RA SP GP TP T0 T1 T2 (wz A) (wz (D + i)) (wz (A + k)) (wz (A + i)) a2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
         F (wz 0x12ad0) fc None m (seg_rom rsegs)).
Proof.
  induction fuel as [|fuel IH]; intros i m bs a2 EF I0 MI MU WM ARR LEN BUF; [exfalso; lia|].
  assert (IL : (Z.to_nat i < length data)%nat) by lia.
  destruct (nth_error data (Z.to_nat i)) as [b|] eqn:NB; [|apply nth_error_None in NB; exfalso; lia].
  pose proof (u8ro_read rsegs _ D data i b (wz (D + i)) BUF NB ltac:(lia) eq_refl) as RD.
  pose proof (u8arr_store_ok rsegs _ _ _ i (wa (A + i)) ARR ltac:(rewrite LEN; lia) eq_refl) as SOK.
  zstep. zstep.
  change (wz (bv_unsigned b)) with (zxb b). rewrite le1_zxb.
  pose proof (u8arr_write rsegs _ _ _ i b ARR ltac:(rewrite LEN; lia)) as ARR2. clear ARR. store_done.
  zstep. zstep. zstep.
  if_cases K; zify_cond K.
  - replace (A + i + 1) with (A + (i + 1)) by lia. replace (D + i + 1) with (D + (i + 1)) by lia.
    eapply (IH (i + 1)); try eassumption; try lia. rewrite upd_length. exact LEN.
  - assert (Ei : i + 1 = k) by lia.
    replace (A + i + 1) with (A + k) by lia. replace (D + i + 1) with (D + k) by lia.
    eapply EXIT; try eassumption. rewrite upd_length. exact LEN.
Qed.
End Loop.

Lemma fzc_entry : forall (D n lo : Z) ra sp gp tp t0 t1 t2 s0 s1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 (F : bvmap 5 word) fc m,
  stk rsegs m lo (bv_unsigned sp) -> (lo + 48 <= bv_unsigned sp)%Z -> (0 <= lo)%Z -> (bv_unsigned sp < 2^63)%Z -> mem_inv rsegs m ->
  evt rsegs (fun ms' => exists (m' : mem) (jk : list byte),
      ms' = MS (mkR (wz 0x12aac) (wz (bv_unsigned sp + -48)) gp tp t0 t1 t2 s0 (wz D) (wz 21) (wz n) a2 a3 a4 a5 a6 a7 (wz n) (wz 21) s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
               F (wz 0x13650) fc None m' (seg_rom rsegs)
      /\ munch [(bv_unsigned sp + -48, bv_unsigned sp)] m m' /\ wmono rsegs m m' /\ mem_inv rsegs m' /\ stk rsegs m' lo (bv_unsigned sp + -48)
      /\ rw_cells rsegs m' (bv_unsigned sp + -48) [CB 8 jk; C8 s3; C8 s2; C8 s1; C8 s0; C8 ra])
    (MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (wz D) (wz n) a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
        F (wz fuzz_entry) fc None m (seg_rom rsegs)).
Proof.
  intros until m. intros ST LOQ LO0 SPH MI. unfold fuzz_entry.
  pose proof (munch_refl [(bv_unsigned sp - 48, bv_unsigned sp)]%Z m) as MU. pose proof (wmono_refl rsegs m) as WM.
  pose proof (word_lt64 sp) as SPB.
  replace (bv_unsigned sp - 48)%Z with (bv_unsigned sp + -48)%Z in MU by lia.
  zstep. carve_frame 48%nat ST.
  sstep. sstep. sstep. sstep. sstep.
  zstep. zstep. zstep. zstep. zstep.
  apply evt_done. do 2 eexists. split; [reflexivity|]. split; [exact MU|]. split; [exact WM|]. split; [exact MI|]. split; [exact ST| exact FR].
Qed.

Lemma fzc_epi : forall (lo : Z) ra (sp : word) gp tp t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 x1 x8 x9 a0x x18 x19 (jk : list byte) (F : bvmap 5 word) fc m,
  stk rsegs m lo (bv_unsigned sp + -48) -> (lo + 48 <= bv_unsigned sp)%Z -> (0 <= lo)%Z -> (bv_unsigned sp < 2^63)%Z -> mem_inv rsegs m ->
  rw_cells rsegs m (bv_unsigned sp + -48) [CB 8 jk; C8 s3; C8 s2; C8 s1; C8 s0; C8 ra] ->
  evt rsegs (fun ms' => ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (wz 0) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6) F (ret_pc ra) fc None m (seg_rom rsegs)
      /\ stk rsegs m lo (bv_unsigned sp))
    (MS (mkR x1 (wz (bv_unsigned sp + -48)) gp tp t0 t1 t2 x8 x9 a0x a1 a2 a3 a4 a5 a6 a7 x18 x19 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
        F (wz 0x12b10) fc None m (seg_rom rsegs)).
Proof.
  intros until m. intros ST LOQ LO0 SPH MI FR.
  pose proof (munch_refl [] m) as MU. pose proof (wmono_refl rsegs m) as WM. pose proof (word_lt64 sp) as SPB.
  zstep. zstep. zstep. zstep. zstep. zstep. zstep.
  zstep.
  eapply stk_release in FR; [| exact ST| lia]. cbn [cells_size csize Nat.add app] in FR.
  replace (bv_unsigned sp + -48 + Z.of_nat 48)%Z with (bv_unsigned sp) in FR by lia.
  apply evt_done. split; [reflexivity| exact FR].
Qed.

Definition hpc (op : Z) : Z := if op =? 255 then 0x12b34 else 0x12b30.
Definition HTAB : list word := repeat (wz 0x12b30) 255 ++ [wz 0x12b34].

Lemma bytes_eq_unsigned : forall l l' : list byte, map bv_unsigned l = map bv_unsigned l' -> l = l'.
Proof.
  induction l as [|a l IH]; destruct l' as [|b l']; cbn; intros H; try discriminate; [reflexivity|].
  injection H as H1 H2. f_equal; [apply bv_eq; exact H1 | apply IH; exact H2].
Qed.
Lemma GD_bytes : gd_bytes 0x1bda8 2048 = u64s HTAB.
Proof. apply bytes_eq_unsigned. vm_compute. reflexivity. Qed.

Lemma HTAB_nth : forall op, 0 <= op < 256 -> nth_error HTAB (Z.to_nat op) = Some (wz (hpc op)).
Proof.
  intros op Hop. unfold HTAB, hpc. destruct (Z.eqb_spec op 255) as [->|N].
  - reflexivity.
  - rewrite nth_error_app1 by (rewrite repeat_length; lia). apply nth_error_repeat. lia.
Qed.

Lemma gd_read : forall m op, GD m -> 0 <= op < 256 ->
  ov_read_bytes rsegs m (wa (0x1bda8 + 8 * op)) 8 = Some (le8 (wz (hpc op))).
Proof.
  intros m op G Hop. unfold GD, GD_ranges in G. inversion G as [|x l B _]; subst. cbn [fst snd] in B. rewrite GD_bytes in B.
  eapply (u64arr_read_ro m 0x1bda8 HTAB op); [exact B| apply HTAB_nth; exact Hop| lia| reflexivity].
Qed.

Lemma fzc_disp : forall (Q : machine_state -> Prop) op RA SP GP TP T0 T1 T2 S0 S1 A1 A2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6 (F : bvmap 5 word) fc (m : mem),
  GD m -> mem_inv rsegs m -> 0 <= op < 256 ->
  (forall a0v, Q (MS (mkR (wz 0x12b08) SP GP TP T0 T1 T2 S0 S1 a0v (wz 0x1bda8) A2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6) F (wz 0x12b08) fc None m (seg_rom rsegs))) ->
  evt rsegs Q (MS (mkR RA SP GP TP T0 T1 T2 S0 S1 (wz op) A1 A2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6) F (wz 0x12af0) fc None m (seg_rom rsegs)).
Proof.
  intros until m. intros G MI Hop K.
  pose proof (munch_refl [] m) as MU. pose proof (wmono_refl rsegs m) as WM.
  pose proof (gd_read m op G Hop) as RD.
  zstep. zstep. zstep. zstep.
  replace (114088 + op ≪ 3)%Z with (114088 + 8 * op)%Z by (rewrite Z.shiftl_mul_pow2 by lia; lia).
  zstep.
  unfold hpc in *. destruct (op =? 255).
  - zstep. zstep. apply evt_done. apply K.
  - zstep. zstep. apply evt_done. apply K.
Qed.

Lemma GD_munch : forall (m m' : mem) A, GD m -> munch [(A, A + 21)] m m' -> (A + 21 <= 0x1bda8 \/ 0x1c5a8 <= A) -> GD m'.
Proof.
  intros m m' A G MU H. unfold GD, GD_ranges in *. inversion G as [|x l B _]; subst. cbn [fst snd] in B.
  constructor; [| constructor]. cbn [fst snd]. eapply bytes_at_transport; [exact B| exact MU|].
  assert (LEN : length (gd_bytes 0x1bda8 2048) = 2048%nat) by (rewrite GD_bytes; reflexivity). rewrite LEN.
  cbn [disjoint_from]. split; [lia| exact I].
Qed.

Section Body.
Variables (A D n : Z) (data : list byte)
  (SP GP TP T0 T1 T2 A1x A2x A3 A4 A5 A6 A7 S0x S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6 : word) (F : bvmap 5 word) (fc : bv 32) (m0 : mem).
Hypothesis A0 : 0 < A.
Hypothesis AHI : A + 21 < 2^63.
Hypothesis NR : 0 <= n <= 2^26.
Hypothesis DLEN : Z.of_nat (length data) = n.
Hypothesis D0 : 0 <= D.
Hypothesis DHI : D + n < 2^63.
Hypothesis SEP : D + n <= A \/ A + 21 <= D \/ n = 0.
Hypothesis AIMG : A + 21 <= 0x1bda8 \/ 0x1c5a8 <= A.
Hypothesis G0 : GD m0.

Definition P_body : machine_state -> Prop := fun ms' => exists (m' : mem) s1' a0v a2',
  ms' = MS (mkR (wz 0x12b08) SP GP TP T0 T1 T2 (wz A) s1' a0v (wz 0x1bda8) a2' A3 A4 A5 A6 A7 (wz n) (wz 21) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
         F (wz 0x12b08) fc None m' (seg_rom rsegs)
  /\ mem_inv rsegs m' /\ munch [(A, A + 21)] m0 m' /\ wmono rsegs m0 m'.

Lemma fzc_fill : forall k (m : mem) bs x1 a1 a2,
  k = Z.min n 21 -> mem_inv rsegs m -> munch [(A, A + 21)] m0 m -> wmono rsegs m0 m ->
  u8arr rsegs m A bs -> length bs = 21%nat -> bytes_at rsegs m D data ->
  evt rsegs P_body (MS (mkR x1 SP GP TP T0 T1 T2 (wz A) (wz D) (wz k) a1 a2 A3 A4 A5 A6 A7 (wz n) (wz 21) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
         F (wz 0x12ac4) fc None m (seg_rom rsegs)).
Proof.
  intros k m bs x1 a1 a2 EK MI MU WM ARR LEN BUF.
  zstep. if_cases K0; zify_cond K0.
  - (* n = 0 : the fill loop is skipped, op stays 0 *)
    zstep.
    eapply (fzc_disp P_body 0); [ exact (GD_munch _ _ _ G0 MU AIMG) | exact MI | lia | ].
    intros a0v. exists m, (wz D), a0v, a2. split; [reflexivity|]. split; [exact MI|]. split; [exact MU| exact WM].
  - assert (K1 : 1 <= k <= 21) by lia.
    zstep. zstep.
    assert (EXIT : forall (m' : mem) bs' a2', mem_inv rsegs m' -> munch [(A, A + 21)] m0 m' -> wmono rsegs m0 m' ->
      u8arr rsegs m' A bs' -> length bs' = 21%nat -> bytes_at rsegs m' D data ->
      evt rsegs P_body (MS (mkR x1 SP GP TP T0 T1 T2 (wz A) (wz (D + k)) (wz (A + k)) (wz (A + k)) a2' A3 A4 A5 A6 A7 (wz n) (wz 21) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
         F (wz 0x12ae4) fc None m' (seg_rom rsegs))).
    { clear m bs a2 MI MU WM ARR LEN BUF. intros m bs a2 MI MU WM ARR LEN BUF.
      destruct (nth_error bs 20) as [b|] eqn:NB; [|apply nth_error_None in NB; exfalso; lia].
      pose proof (u8arr_read rsegs _ A bs 20 b (wa (A + 20)) ARR NB ltac:(lia) eq_refl) as RD.
      zstep. zstep.
      eapply (fzc_disp P_body (bv_unsigned b)); [ exact (GD_munch _ _ _ G0 MU AIMG) | exact MI | | ].
      { pose proof (bv_unsigned_in_range 8 b) as R. unfold bv_modulus in R. cbn in R. lia. }
      intros a0v. exists m, (wz (D + k)), a0v, a2. split; [reflexivity|]. split; [exact MI|]. split; [exact MU| exact WM]. }
    assert (L : evt rsegs P_body (MS (mkR x1 SP GP TP T0 T1 T2 (wz A) (wz (D + 0)) (wz (A + k)) (wz (A + 0)) a2 A3 A4 A5 A6 A7 (wz n) (wz 21) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
         F (wz 0x12ad0) fc None m (seg_rom rsegs))).
    { eapply fzc_loop with (fuel := Z.to_nat k); try exact EXIT; try eassumption; try lia. }
    rewrite !Z.add_0_r in L. exact L.
Qed.

Lemma fzc_body : forall (m : mem) bs a1 a2,
  mem_inv rsegs m -> munch [(A, A + 21)] m0 m -> wmono rsegs m0 m ->
  u8arr rsegs m A bs -> length bs = 21%nat -> bytes_at rsegs m D data ->
  evt rsegs P_body (MS (mkR (wz 0x12aac) SP GP TP T0 T1 T2 S0x (wz D) (wz A) a1 a2 A3 A4 A5 A6 A7 (wz n) (wz 21) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
         F (wz 0x12aac) fc None m (seg_rom rsegs)).
Proof.
  intros m bs a1 a2 MI MU WM ARR LEN BUF.
  zstep. if_cases K0; zify_cond K0. { exfalso; lia. }
  pose proof (u8arr_store_ok rsegs _ _ _ 20 (wa (A + 20)) ARR ltac:(rewrite LEN; lia) eq_refl) as SOK.
  zstep. zstep.
  replace (le1 (wz 0)) with [Z_to_bv 8 0] by reflexivity.
  pose proof (u8arr_write rsegs _ _ _ 20 (Z_to_bv 8 0) ARR ltac:(rewrite LEN; lia)) as ARR2. clear ARR. store_done.
  assert (LEN2 : length (upd bs (Z.to_nat 20) (Z_to_bv 8 0)) = 21%nat) by (rewrite upd_length; exact LEN).
  zstep. zstep. if_cases K1; zify_cond K1.
  - eapply (fzc_fill n); try eassumption. lia.
  - zstep. eapply (fzc_fill 21); try eassumption. lia.
Qed.
End Body.

Section Top.
Context {HGW : HasGuard} {HCEIL : HasCeiling}.

Lemma GD_keep : forall (LB : list (block (ai_K rsegs AI_P0))) SP (m m' : mem), GD m -> heap_pres AI_P0 LB SP m m' -> GD m'.
Proof.
  intros LB SP m m' G HP. unfold GD, GD_ranges in *. inversion G as [|x l B _]; subst. cbn [fst snd] in B.
  constructor; [| constructor]. cbn [fst snd]. eapply (bytes_at_agree rsegs (client_addr AI_P0 LB SP)); [exact HP| exact B|].
  assert (LEN : length (gd_bytes 0x1bda8 2048) = 2048%nat) by (rewrite GD_bytes; reflexivity). rewrite LEN.
  intros a Ha. right; left. exists 0x1bda8, 0x1c5a8. split; [| lia].
  cbn [ai_L AI_P0 P0L al_client_static]. unfold p0_client_static, RLIBC, RCTX, RERRNO, RSSP_GUARD, RGOT_SSP, RVMLOCK. repeat split; lia.
Qed.

Lemma hp_of_munch : forall (LB : list (block (ai_K rsegs AI_P0))) SP W (m m' : mem), munch W m m' -> wmono rsegs m m' ->
  (forall a, 0 <= a < 2^64 -> client_addr AI_P0 LB SP a -> outside W a) -> heap_pres AI_P0 LB SP m m'.
Proof. intros LB SP W m m' MU WM H a Ha Hc. exact (agree_on_of_munch rsegs W m m' MU WM a Ha (H a Ha Hc)). Qed.

Lemma hp_weaken : forall (LB LB' : list (block (ai_K rsegs AI_P0))) SP SP' (m m' : mem), heap_pres AI_P0 LB' SP' m m' -> SP' <= SP ->
  (forall b, In b LB -> In b LB') -> heap_pres AI_P0 LB SP m m'.
Proof.
  intros LB LB' SP SP' m m' H HS HI a Ha Hc. apply H; [exact Ha|].
  destruct Hc as [Hc|[Hc|(b & Hb & Hr)]]; [left; lia| right; left; exact Hc| right; right; exists b; split; [apply HI; exact Hb| exact Hr]].
Qed.

Lemma cell8_same : forall (m : mem) A (x y : word), rw_cells rsegs m A [C8 x] -> rw_cells rsegs m A [C8 y] -> x = y.
Proof.
  intros m A x y R1 R2.
  pose proof (rw_cells_readn rsegs m A [C8 x] 0%nat _ 8 R1 eq_refl eq_refl) as E1. pose proof (rw_cells_readn rsegs m A [C8 y] 0%nat _ 8 R2 eq_refl eq_refl) as E2.
  cbn [cbytes] in E1, E2. rewrite E1 in E2.
  apply (f_equal (fun o : option (list byte) => match o with Some l => le_bytes_to_word l | None => Z_to_bv 64 0 end)) in E2.
  cbv beta iota in E2. rewrite !le_bytes_to_word_le8 in E2. exact E2.
Qed.

Lemma fzc_null : forall (lo : Z) ra (sp : word) gp tp t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 x8 x9 x18 x19 (jk : list byte) (F : bvmap 5 word) fc (m : mem),
  stk rsegs m lo (bv_unsigned sp + -48) -> (lo + 48 <= bv_unsigned sp)%Z -> (0 <= lo)%Z -> (bv_unsigned sp < 2^63)%Z -> mem_inv rsegs m ->
  rw_cells rsegs m (bv_unsigned sp + -48) [CB 8 jk; C8 s3; C8 s2; C8 s1; C8 s0; C8 ra] ->
  evt rsegs (fun ms' => ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (wz 0) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6) F (ret_pc ra) fc None m (seg_rom rsegs)
      /\ stk rsegs m lo (bv_unsigned sp))
    (MS (mkR (wz 0x12aac) (wz (bv_unsigned sp + -48)) gp tp t0 t1 t2 x8 x9 (wz 0) a1 a2 a3 a4 a5 a6 a7 x18 x19 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
        F (wz 0x12aac) fc None m (seg_rom rsegs)).
Proof.
  intros until m. intros ST LOQ LO0 SPH MI FR.
  pose proof (munch_refl [] m) as MU. pose proof (wmono_refl rsegs m) as WM.
  zstep. if_cases K0; zify_cond K0; [| exfalso; lia].
  eapply fzc_epi; eassumption.
Qed.

Lemma fzc_free : forall RA SP GP TP T0 T1 T2 A S1 A0x A1 A2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6 (F : bvmap 5 word) fc (m : mem),
  evt rsegs (fun ms' => ms' = MS (mkR (wz 0x12b10) SP GP TP T0 T1 T2 (wz A) S1 (wz A) A1 A2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6) F (wz 0x13510) fc None m (seg_rom rsegs))
    (MS (mkR RA SP GP TP T0 T1 T2 (wz A) S1 A0x A1 A2 A3 A4 A5 A6 A7 S2 S3 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6) F (wz 0x12b08) fc None m (seg_rom rsegs)).
Proof.
  intros until m. pose proof (munch_refl [] m) as MU. pose proof (wmono_refl rsegs m) as WM.
  zstep. zstep. apply evt_done. reflexivity.
Qed.

Lemma ai_K_eqb_refl_P0 : forall k : ai_K rsegs AI_P0, ai_K_eqb rsegs AI_P0 k k = true.
Proof. intros k. apply (ai_K_eqb_eq rsegs AI_P0). reflexivity. Qed.

Theorem fuzz_one_P0_closed : fuzz_one_stmt AI_P0.
Proof.
  unfold fuzz_one_stmt. intros until data. intros BUF DLEN NR DOR HR HE SPB BHI ST CEIL LO SP16 ERR MI G SS1 SS2 -> -> -> FRM.
  unfold PARSER_STACK in LO. pose proof (word_lt64 sp) as SPR.
  pose proof alloc_ceiling_bounds as ACB. unfold alloc_floor, alloc_ceiling_max in ACB.
  assert (CAN0 : canary = guard_word).
  { destruct (RHEAP_ssp _ _ _ HR) as [_ S2]. unfold ssp_guard in *. exact (cell8_same _ _ _ _ SS2 S2). }
  eapply sreach_evt. { eapply fzc_entry; try eassumption; lia. }
  intros ms' (m1 & jk & -> & MU1 & WM1 & MI1 & ST1 & FR1).
  assert (EQS : bv_unsigned (wz (bv_unsigned sp + -48)) = bv_unsigned sp + -48) by (apply unsigned_lit; lia).
  assert (HR1 : AllocIF.RHEAP rsegs AI_P0 s LB m1).
  { eapply (ai_heap_frame rsegs AI_P0); [exact HR| exact MU1| exact WM1|]. constructor; [left; cbn; lia| constructor]. }
  assert (HE1 : AllocIF.RENV rsegs AI_P0 m1 B).
  { eapply (ai_env_frame rsegs AI_P0); [exact HR| exact HE| exact MU1| exact WM1|]. constructor; [left; cbn; lia| constructor]. }
  assert (STAT : forall lo' hi', al_client_static (ai_L rsegs AI_P0) lo' hi' -> hi' <= 0x4f000).
  { intros lo' hi' CS. cbn [ai_L AI_P0 P0L al_client_static] in CS. unfold p0_client_static in CS. lia. }
  assert (HP1 : heap_pres AI_P0 LB (bv_unsigned sp) m m1).
  { eapply hp_of_munch; [exact MU1| exact WM1|]. intros a Ha Hc. cbn [outside]. split; [| exact I].
    destruct Hc as [Hc|[(lo' & hi' & CS & Hr)|(b & Hb & Hr)]]; [lia| pose proof (STAT _ _ CS); lia|].
    destruct (ai_block_range rsegs AI_P0 s LB m b HR Hb) as (_ & _ & _ & B4 & _). lia. }
  pose proof (GD_keep _ _ _ _ G HP1) as G1.
  assert (ERR1 : rw_cells rsegs m1 (al_errno (ai_L rsegs AI_P0)) [C4 errv]).
  { apply (rw_cells_transport rsegs _ m m1 _ _ ERR MU1 WM1). cbn [disjoint_from cells_size csize Nat.add ai_L AI_P0 P0L al_errno]. unfold RERRNO. cbn. lia. }
  eapply sreach_bind.
  { eapply P0_malloc_contract with (n := 21) (lo := lo) (B := B) (errv := errv);
      first [ exact HR1 | exact HE1 | exact CEIL | exact MI1 | exact ERR1 | reflexivity
            | (rewrite EQS; exact ST1) | (rewrite EQS; lia) | (rewrite EQS; cbn; lia) | lia ]. }
  intros s2' LB2 ms2 POST. unfold malloc_post in POST.
  destruct POST as (t0' & t1' & t2' & a0' & a1' & a2' & a3' & a4' & a5' & a6' & a7' & t3' & t4' & t5' & t6' & m2 & -> & (MI2 & ST2 & HE2 & (e2 & ERR2) & HP2) & CASES).
  rewrite EQS in ST2, HP2.
  replace (ret_pc (wz 0x12aac)) with (wz 0x12aac) by (symmetry; apply ret_pc_even; [lia| reflexivity]).
  assert (HP2q : heap_pres AI_P0 LB (bv_unsigned sp) m1 m2) by (eapply hp_weaken; [exact HP2| lia| intros b Hb; exact Hb]).
  assert (FR2 : rw_cells rsegs m2 (bv_unsigned sp + -48) [CB 8 jk; C8 s3; C8 s2; C8 s1; C8 s0; C8 ra]).
  { eapply (rw_cells_agree rsegs (client_addr AI_P0 LB (bv_unsigned sp + -48))); [exact HP2| exact FR1|].
    cbn [cells_size csize Nat.add]. intros a Ha. left. lia. }
  pose proof (GD_keep _ _ _ _ G1 HP2q) as G2.
  destruct CASES as [(-> & -> & HR2)|(k & A & junk & -> & -> & BR & HR2 & CELLS)].
  - (* malloc returned NULL *)
    eapply sreach_evt. { eapply fzc_null with (lo := lo); try eassumption; lia. }
    intros ms' (-> & STF). apply sreach_ret. unfold fuzz_one_post. repeat (lazymatch goal with |- ex _ => eexists end).
    split; [reflexivity|].
    split. { split; [exact MI2|]. split; [exact STF|]. split; [exact HE2|]. split; [exists e2; exact ERR2|]. eapply heap_pres_trans; [exact HP1| exact HP2q]. }
    split; [exact HR2|]. split; [intros b Hb; exact Hb|]. split; [exact G2|].
    rewrite CAN0. destruct (RHEAP_ssp _ _ _ HR2) as [S1 S2]. split; [exact S1| exact S2].
  - (* the fill, the dispatch, free *)
    pose proof (ai_blocks_nodup rsegs AI_P0 _ _ _ HR2) as ND. cbn [map blk_id fst snd] in ND. inversion_clear ND as [|x l NIN _].
    destruct BR as (A1 & A16 & _ & A2 & AW).
    cbn [ai_L AI_P0 P0L al_img] in AW. inversion_clear AW as [|w l W1 AW2]. inversion_clear AW2 as [|w2 l2 W2 _]. cbn [fst snd] in W1, W2.
    assert (IMGH : A + 21 <= 0x10000 \/ 0x4f000 <= A) by lia.
    assert (DISJ : forall b, In b LB -> A + 21 <= blk_addr b \/ blk_addr b + blk_size b <= A).
    { intros b Hb. assert (NE : (k, A, 21) <> b).
      { intros <-. apply NIN. apply list_elem_of_In. apply in_map_iff. exists (k, A, 21). split; [reflexivity| exact Hb]. }
      pose proof (ai_blocks_disjoint rsegs AI_P0 _ _ _ (k, A, 21) b HR2 (or_introl eq_refl) (or_intror Hb) NE) as X.
      cbn [blk_addr blk_size fst snd] in X. lia. }
    assert (DB : n = 0 \/ (D + n <= A \/ A + 21 <= D) /\ 0 <= D /\ D + n <= alloc_ceiling).
    { destruct DOR as [[N0 _]|[kD KIN]]; [left; exact N0| right].
      pose proof (DISJ _ KIN) as X. cbn [blk_addr blk_size fst snd] in X.
      destruct (ai_block_range rsegs AI_P0 s LB m _ HR KIN) as (B1 & _ & _ & B4 & _). cbn [blk_addr blk_size fst snd] in B1, B4. lia. }
    assert (BUF2 : bytes_at rsegs m2 D data).
    { eapply (bytes_at_agree rsegs (client_addr AI_P0 LB (bv_unsigned sp))); [eapply heap_pres_trans; [exact HP1| exact HP2q]| exact BUF|].
      intros a Ha. rewrite DLEN in Ha. destruct DOR as [[N0 _]|[kD KIN]]; [lia|].
      right; right. exists (kD, D, n). split; [exact KIN| cbn [blk_addr blk_size fst snd]; lia]. }
    assert (LJ : length junk = 21%nat) by (destruct CELLS as [[Hwf _] _]; cbn in Hwf; tauto).
    pose proof (u8arr_of_rw_cells _ _ _ _ _ CELLS) as ARR.
    pose proof (munch_refl [(A, A + 21)] m2) as MU3. pose proof (wmono_refl rsegs m2) as WM3.
    assert (D0 : 0 <= D \/ n = 0) by lia.
    eapply sreach_evt.
    { eapply fzc_body with (m0 := m2) (data := data); try eassumption; try lia. }
    intros ms3 (m3 & s1v & a0v & a2v & -> & MI3 & MU3' & WM3').
    assert (OUTS : forall a, alloc_ceiling <= a -> outside [(A, A + 21)] a) by (intros a Ha; cbn [outside]; split; [lia| exact I]).
    assert (BW : Forall (fun iv : Z * Z => fst iv = A /\ snd iv = A + 21) [(A, A + 21)]) by (constructor; [split; reflexivity| constructor]).
    assert (HR3 : AllocIF.RHEAP rsegs AI_P0 s2' ((k, A, 21) :: LB) m3).
    { eapply (ai_heap_frame rsegs AI_P0); [exact HR2| exact MU3'| exact WM3'|].
      constructor; [| constructor]. do 3 right. exists (k, A, 21). split; [left; reflexivity| cbn; lia]. }
    assert (HE3 : AllocIF.RENV rsegs AI_P0 m3 B).
    { eapply (ai_env_frame rsegs AI_P0); [exact HR2| exact HE2| exact MU3'| exact WM3'|].
      constructor; [| constructor]. do 3 right. exists (k, A, 21). split; [left; reflexivity| cbn; lia]. }
    assert (AGR3 : agree_on rsegs (fun a => outside [(A, A + 21)] a) m2 m3) by (apply agree_on_of_munch; assumption).
    assert (ST3 : stk rsegs m3 lo (bv_unsigned sp + -48)).
    { eapply (stk_agree rsegs); [exact AGR3| exact ST2| intros a Ha; apply OUTS; lia]. }
    assert (FR3 : rw_cells rsegs m3 (bv_unsigned sp + -48) [CB 8 jk; C8 s3; C8 s2; C8 s1; C8 s0; C8 ra]).
    { eapply (rw_cells_agree rsegs); [exact AGR3| exact FR2|]. cbn [cells_size csize Nat.add]. intros a Ha; apply OUTS; lia. }
    assert (ERR3 : rw_cells rsegs m3 (al_errno (ai_L rsegs AI_P0)) [C4 e2]).
    { eapply (rw_cells_agree rsegs); [exact AGR3| exact ERR2|]. cbn [cells_size csize Nat.add ai_L AI_P0 P0L al_errno]. unfold RERRNO.
      intros a Ha. cbn [outside]. cbn in Ha. split; [lia| exact I]. }
    assert (HP3 : heap_pres AI_P0 LB (bv_unsigned sp) m2 m3).
    { eapply hp_of_munch; [exact MU3'| exact WM3'|]. intros a Ha Hc. cbn [outside]. split; [| exact I].
      destruct Hc as [Hc|[(lo' & hi' & CS & Hr)|(b & Hb & Hr)]]; [lia| |].
      - cbn [ai_L AI_P0 P0L al_client_static] in CS. unfold p0_client_static in CS. lia.
      - pose proof (DISJ b Hb). lia. }
    pose proof (GD_keep _ _ _ _ G2 HP3) as G3.
    eapply sreach_evt. { apply fzc_free. } intros ms' ->.
    eapply sreach_bind.
    { eapply P0_free_contract with (k := k) (A := A) (n := 21) (lo := lo) (B := B) (errv := e2);
        first [ exact HR3 | exact HE3 | exact CEIL | exact MI3 | exact ERR3 | reflexivity | (left; reflexivity)
              | (rewrite EQS; exact ST3) | (rewrite EQS; lia) | (rewrite EQS; cbn; lia) | lia ]. }
    intros sF LB4 ms4 POST. unfold free_post in POST.
    destruct POST as (u0 & u1 & u2 & c0 & c1 & c2 & c3 & c4 & c5 & c6 & c7 & u3 & u4 & u5 & u6 & m4 & -> & (MI4 & ST4 & HE4 & (e4 & ERR4) & HP4) & -> & HR4).
    rewrite EQS in ST4, HP4.
    replace (ret_pc (wz 0x12b10)) with (wz 0x12b10) by (symmetry; apply ret_pc_even; [lia| reflexivity]).
    assert (LBR : lb_remove (ai_K_eqb rsegs AI_P0) k ((k, A, 21) :: LB) = LB).
    { unfold lb_remove. rewrite filter_cons. destruct (decide _) as [Dc|Dc].
      - exfalso. cbn in Dc. rewrite (proj2 (bptr_eqb_eq k k) eq_refl) in Dc. exact Dc.
      - fold (lb_remove (ai_K_eqb rsegs AI_P0) k LB). apply (lb_remove_notin LB k). intro H. apply NIN. apply list_elem_of_In. exact H. }
    rewrite LBR in HP4, HR4 |- *.
    assert (FR4 : rw_cells rsegs m4 (bv_unsigned sp + -48) [CB 8 jk; C8 s3; C8 s2; C8 s1; C8 s0; C8 ra]).
    { eapply (rw_cells_agree rsegs (client_addr AI_P0 LB (bv_unsigned sp + -48))); [exact HP4| exact FR3|].
      cbn [cells_size csize Nat.add]. intros a Ha. left. lia. }
    assert (HP4q : heap_pres AI_P0 LB (bv_unsigned sp) m3 m4) by (eapply hp_weaken; [exact HP4| lia| intros b Hb; exact Hb]).
    eapply sreach_evt. { eapply fzc_epi with (lo := lo); try eassumption; lia. }
    intros ms' (-> & STF). apply sreach_ret. unfold fuzz_one_post. repeat (lazymatch goal with |- ex _ => eexists end).
    split; [reflexivity|].
    split. { split; [exact MI4|]. split; [exact STF|]. split; [exact HE4|]. split; [exists e4; exact ERR4|].
             eapply heap_pres_trans; [exact HP1|]. eapply heap_pres_trans; [exact HP2q|]. eapply heap_pres_trans; [exact HP3| exact HP4q]. }
    split; [exact HR4|]. split; [intros b Hb; exact Hb|]. split; [exact (GD_keep _ _ _ _ G3 HP4q)|].
    rewrite CAN0. destruct (RHEAP_ssp _ _ _ HR4) as [S1 S2]. split; [exact S1| exact S2].
Qed.
End Top.
