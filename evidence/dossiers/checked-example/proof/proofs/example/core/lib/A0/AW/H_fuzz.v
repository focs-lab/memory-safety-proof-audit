(* example/core: the ASan harness contract (replaces pupnp's A0/AW/H_fuzz.v and the 48 other A0/AW files).
   Statement: pupnp's fuzz_one_spec_A (A0/AW/H_fuzz.v:593) with our PZ and without the interceptor bundle IC
   (our harness calls no interceptor; see GlueInst.v), and without pupnp's fake-stack hypotheses SM0..SM4
   (__asan_stack_malloc_k) and F5 (set_shadow_f5): core.asan has no __asan_stack_malloc_k; __asan_set_shadow_f5 is
   linked (0x52740) but only referenced from force_interface_symbols (0x57d5c), which nothing calls; our harness has
   no instrumented stack objects, so the walk reaches neither.  Dropping these hypotheses only removes premises.
   Proof: a walk of core.asan's LLVMFuzzerTestOneInput (0x7e62c, 85 instructions):
     fza_entry  entry -> malloc(21) call               (frame carve, saved registers)
     ac_malloc  block (k, x, 21), shadow block_shadow 21 = [0;0;5]
     fza_body   x->op = 0 (shadow check of x+20: 20 mod 8 = 4 < 5, allowed), fill loop fza_loop
                (per-byte shadow checks of data[i] and x+i, i < min(size, 21)), dispatch fza_disp
                (shadow check of HANDLERS_A + 8*op, table load via PZ, jalr to h_nop / h_admin, both `ret`)
     ac_free    free(x), block list back to LB
     fza_epi    restore frame, ret
   and fuzz_one_postA (a0 = 0, pkeep, RHEAP_A, PZ m', errno, shz, ssp cells). *)
From stdpp Require Import base list.
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Run.
From LinuxProcessSemantics.Riscv Require Import Prelude Instr Decode DecodeC Sem Fpu.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Agree.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac ZBridge STRW_tac Image Arr Ceiling RunWord SysStep.
From OssFuzzTheorems.Proofs.example.core.lib.Top Require Import AllocIF.
From OssFuzzTheorems.Proofs.example.core.lib.Http Require Import HttpTac.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAW Require Import Segs Shadow Contracts ATac IcptA0 AllocA0 ATacAp.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7A0 Require Import ShadowKit F_syscalls RF_mainA_A RDriverA_iface.
From OssFuzzTheorems.Proofs.example.core.lib.A0.AW Require PZDef.
From OssFuzzTheorems.Proofs.example.core.lib.A0.AW Require Import HttpAllocA HApxF AWKit AWAuto.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7G Require GluePZ.

Import ListNotations.
Open Scope Z_scope.
Local Notation wz := (Z_to_bv 64).
Ltac chkbN r APP HS kk SHR Hk :=
  let a := reg_val r in
  lazymatch goal with |- evt _ _ (MS _ _ _ _ _ ?mm _) =>
    destruct (acc_load mm APP a (proj1 HS APP ltac:(lia)) ltac:(shadow_addr_tac)) as (kk & SHR & Hk) end.
Section L.
Context {HC : HasCeiling} {HG : HasGuard}.
Variables (A D k : Z) (data : list byte)
  (RA SP GP TP T1 T2 S2 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6 : word) (F : bvmap 5 word) (fc : bv 32) (m0 : mem).
Hypothesis AK : 0 < A /\ A mod 16 = 0 /\ A + 21 < 2^47.
Hypothesis DK : 0 <= D /\ D mod 16 = 0 /\ D + Z.of_nat (length data) < 2^47.
Hypothesis KL : k <= 21 /\ k <= Z.of_nat (length data).
Hypothesis SEP : D + Z.of_nat (length data) <= A \/ A + 21 <= D.
Variable Q : machine_state -> Prop.
Hypothesis EXIT : forall (m : mem) bs t0 a6 a7, mem_inv asegs m -> munch [(A, A + 21)] m0 m -> wmono asegs m0 m -> shw m A 21 -> shw m D (Z.of_nat (length data)) ->
  u8arr asegs m A bs -> length bs = 21%nat -> bytes_at asegs m D data ->
  evt asegs Q (MS (mkR RA SP GP TP t0 T1 T2 (wz A) (wz (D+k)) (wz (A+20)) (wz (D+k)) (wz (A+k)) (wz (sh (A+20))) (wz 0) (wz (A+k)) a6 a7 S2 (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
      F (wz 0x7e700) fc None m (seg_rom asegs)).
Lemma fza_loop : forall fuel i (m : mem) bs (t0 a6 a7 : word),
  Z.of_nat fuel = k - i -> 0 <= i < k -> mem_inv asegs m -> munch [(A, A + 21)] m0 m -> wmono asegs m0 m -> shw m A 21 -> shw m D (Z.of_nat (length data)) ->
  u8arr asegs m A bs -> length bs = 21%nat -> bytes_at asegs m D data ->
  evt asegs Q (MS (mkR RA SP GP TP t0 T1 T2 (wz A) (wz (D+i)) (wz (A+20)) (wz (D+i)) (wz (A+i)) (wz (sh (A+20))) (wz (k-i)) (wz (A+i)) a6 a7 S2 (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
      F (wz 0x7e6a0) fc None m (seg_rom asegs)).
Proof.
  pose proof AK as (A1 & A16 & A2). pose proof DK as (DD1 & D16 & DD2). pose proof KL as (K21 & KD).
  induction fuel as [|fuel IH]; intros i m bs t0 a6 a7 EF I0 MI MU WM SWA SWD ARR LEN BUF.
  { exfalso; lia. }
  assert (IK : i < k) by lia. assert (ILn : i < Z.of_nat (length data)) by lia.
  zstep. zstep. chkbN 16 (D+i) SWD ks SHRs Hks. 
  assert (SRCJOIN : forall mm a6j a7j, mem_inv asegs mm -> munch [(A, A + 21)] m0 mm -> wmono asegs m0 mm -> shw mm A 21 -> shw mm D (Z.of_nat (length data)) -> u8arr asegs mm A bs -> bytes_at asegs mm D data ->
    evt asegs Q (MS (mkR RA SP GP TP t0 T1 T2 (wz A) (wz (D+i)) (wz (A+20)) (wz (D+i)) (wz (A+i)) (wz (sh (A+20))) (wz (k-i)) (wz (A+i)) a6j a7j S2 (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
        F (wz 0x7e6b0) fc None mm (seg_rom asegs))).
  { clear ks SHRs Hks m MI SWA SWD ARR BUF MU WM a6 a7. intros m a6 a7 MI MU WM SWA SWD ARR BUF.
    zstep. zstep. chkbN 16 (A+i) SWA kd SHRd Hkd.
    destruct (nth_error data (Z.to_nat i)) as [db|] eqn:NB; [| apply nth_error_None in NB; exfalso; lia].
    pose proof (u8ro_read asegs m D data i db (wa (D+i)) BUF NB ltac:(lia) ltac:(f_equal; lia)) as SRCRD.
    pose proof (u8arr_store_ok asegs _ _ _ i (wa (A+i)) ARR ltac:(lia) eq_refl) as SOK.
    assert (FIN : forall (mm : mem) t0f a6f a7f, mem_inv asegs mm -> munch [(A, A + 21)] m0 mm -> wmono asegs m0 mm -> shw mm A 21 -> shw mm D (Z.of_nat (length data)) ->
        u8arr asegs mm A (upd bs (Z.to_nat i) db) -> bytes_at asegs mm D data ->
        evt asegs Q (MS (mkR RA SP GP TP t0f T1 T2 (wz A) (wz (D+i)) (wz (A+20)) (wz (D+i)) (wz (A+i)) (wz (sh (A+20))) (wz (k-i)) (wz (A+i)) a6f a7f S2 (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
            F (wz 0x7e6c8) fc None mm (seg_rom asegs))).
    { intros mm t0f a6f a7f MIf MUf WMf SWAf SWDf ARRf BUFf.
      pose proof (munch_refl [] mm) as MUz. pose proof (wmono_refl asegs mm) as WMz.
      zstep. zstep. zstep. zstep. zstep. step.
      if_cases KC; zify_cond KC.
      - replace (D+i+1) with (D+(i+1)) by lia. replace (A+i+1) with (A+(i+1)) by lia. replace (k-i+-1) with (k-(i+1)) by lia.
        eapply (IH (i+1) mm (upd bs (Z.to_nat i) db) t0f a6f a7f);
          [ lia | lia | exact MIf | exact MUf | exact WMf | exact SWAf | exact SWDf | exact ARRf | rewrite upd_length; exact LEN | exact BUFf ].
      - zstep. replace (A+i+1) with (A+k) by lia. replace (D+i+1) with (D+k) by lia. replace (k-i+-1) with 0 by lia.
        eapply (EXIT mm (upd bs (Z.to_nat i) db) t0f); [ exact MIf | exact MUf | exact WMf | exact SWAf | exact SWDf | exact ARRf | rewrite upd_length; exact LEN | exact BUFf ]. }
    destruct Hkd as [-> | (GD1 & GD2)].
    { step. step. step. lit_branch. step. rewrite le1_zxb.
      pose proof (munch_write1 m (A+i) [db] ltac:(lia) ltac:(cbn; lia)) as MUw.
      pose proof (shw_store m A 21 (A+i) [db] SWA ltac:(lia) ltac:(cbn;lia) ltac:(eapply app_iv_of_win_ok; [exact (shw_win_ok _ _ _ SWA) | lia | cbn; lia])) as SWA2.
      pose proof (shw_store m D (Z.of_nat (length data)) (A+i) [db] SWD ltac:(lia) ltac:(cbn;lia) ltac:(eapply app_iv_of_win_ok; [exact (shw_win_ok _ _ _ SWA) | lia | cbn; lia])) as SWD2.
      pose proof (bytes_at_transport asegs _ m _ D data BUF MUw ltac:(cbn [disjoint_from length]; split; [destruct SEP as [HSe|HSe]; [left|right]; lia | exact I])) as BUF2.
      pose proof (u8arr_write asegs _ _ _ i db ARR ltac:(lia)) as ARR2. clear ARR. store_done.
      eapply FIN; eassumption. }
    { step. rewrite (sxb_small kd) by lia.
      step. step. if_cases GDB; zify_cond GDB; [| exfalso; lia].
      step. step. if_cases GDC; zify_cond GDC; zify_granule GDC; [| exfalso; lia].
      step. rewrite le1_zxb.
      pose proof (munch_write1 m (A+i) [db] ltac:(lia) ltac:(cbn; lia)) as MUw.
      pose proof (shw_store m A 21 (A+i) [db] SWA ltac:(lia) ltac:(cbn;lia) ltac:(eapply app_iv_of_win_ok; [exact (shw_win_ok _ _ _ SWA) | lia | cbn; lia])) as SWA2.
      pose proof (shw_store m D (Z.of_nat (length data)) (A+i) [db] SWD ltac:(lia) ltac:(cbn;lia) ltac:(eapply app_iv_of_win_ok; [exact (shw_win_ok _ _ _ SWA) | lia | cbn; lia])) as SWD2.
      pose proof (bytes_at_transport asegs _ m _ D data BUF MUw ltac:(cbn [disjoint_from length]; split; [destruct SEP as [HSe|HSe]; [left|right]; lia | exact I])) as BUF2.
      pose proof (u8arr_write asegs _ _ _ i db ARR ltac:(lia)) as ARR2. clear ARR. store_done.
      eapply FIN; eassumption. } }
  destruct Hks as [-> | (GS1 & GS2)].

  { step. step. lit_branch. eapply SRCJOIN; eassumption. }
  { step. rewrite (sxb_small ks) by lia.
    step. if_cases GSB; zify_cond GSB; [| exfalso; lia].
    step. step. if_cases GSC; zify_cond GSC; zify_granule GSC; [ exfalso; lia |].
    step. eapply SRCJOIN; eassumption. }
Qed.

Lemma fza_loop0 : forall bs (t0 a6 a7 : word), 0 < k -> mem_inv asegs m0 -> shw m0 A 21 -> shw m0 D (Z.of_nat (length data)) ->
  u8arr asegs m0 A bs -> length bs = 21%nat -> bytes_at asegs m0 D data ->
  evt asegs Q (MS (mkR RA SP GP TP t0 T1 T2 (wz A) (wz D) (wz (A+20)) (wz D) (wz A) (wz (sh (A+20))) (wz k) (wz A) a6 a7 S2 (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
      F (wz 0x7e6a0) fc None m0 (seg_rom asegs)).
Proof.
  intros bs t0 a6 a7 K0 MI SWA SWD ARR LEN BUF.
  pose proof (fza_loop (Z.to_nat k) 0 m0 bs t0 a6 a7 ltac:(lia) ltac:(lia) MI (munch_refl _ m0) (wmono_refl asegs m0) SWA SWD ARR LEN BUF) as LP.
  rewrite !Z.add_0_r, Z.sub_0_r in LP. exact LP.
Qed.
End L.
Section D.
Context {HC : HasCeiling} {HG : HasGuard}.
Lemma fza_disp : forall (Q : machine_state -> Prop) A (b : byte) bs RA SP GP TP T0 T1 T2 S1 A1 A2 A4 A5 A6 A7 S2 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6 (F : bvmap 5 word) fc (m : mem),
  mem_inv asegs m -> shw m A 21 -> PZDef.PZ m -> u8arr asegs m A bs -> nth_error bs 20 = Some b ->
  0 < A -> A mod 16 = 0 -> A + 21 < 2^47 ->
  (forall a1' a2', Q (MS (mkR (wz 0x7e73c) SP GP TP T0 T1 T2 (wz A) S1 (wz A) a1' a2' (wz (sh (A+20))) A4 A5 A6 A7 S2 (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
      F (wz A0_free) fc None m (seg_rom asegs))) ->
  evt asegs Q (MS (mkR RA SP GP TP T0 T1 T2 (wz A) S1 (wz (A+20)) A1 A2 (wz (sh (A+20))) A4 A5 A6 A7 S2 (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
      F (wz 0x7e700) fc None m (seg_rom asegs)).
Proof.
  intros until m. intros MI SWA HPZ ARR NB A1p A16 A2p K.
  pose proof (munch_refl [] m) as MU. pose proof (wmono_refl asegs m) as WM.
  pose proof (u8arr_read asegs m A bs 20 b (wa (A+20)) ARR NB ltac:(lia) eq_refl) as OPRD.
  pose proof (bv_unsigned_in_range _ b) as BR. unfold bv_modulus in BR. cbn in BR.
  set (op := bv_unsigned b) in *.
  assert (DJ : forall a1v a2v, evt asegs Q (MS (mkR RA SP GP TP T0 T1 T2 (wz A) S1 (wz (A+20)) a1v a2v (wz (sh (A+20))) A4 A5 A6 A7 S2 (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
      F (wz 0x7e708) fc None m (seg_rom asegs))).
  { intros a1v a2v.
    zstep. zstep. zstep. zstep. zstep.
    replace (611744 + op ≪ 3) with (611744 + 8 * op) by (rewrite Z.shiftl_mul_pow2 by lia; lia).
    destruct HPZ as [PSH PCT]. pose proof PSH as PSH0. unfold PZDef.HANDLERS_A, PZDef.HANDLERS_BYTES in PSH0.
    zstep. zstep.
    assert (MZ : (611744 + 8 * op) mod 8 = 0) by (replace (611744 + 8 * op) with ((76468 + op) * 8) by lia; apply Z.mod_mul; lia).
    let v := reg_val 11 in
    pose proof (acc_load0 m 611744 2048 (611744 + 8 * op) v (proj1 PSH0) ltac:(lia) ltac:(lia) ltac:(shadow_addr_tac)) as TSH.
    step. step. lit_branch.
    pose proof (PZDef.pz_read m op (conj PSH PCT) BR) as TRD. unfold PZDef.HANDLERS_A in TRD.
    destruct (PZDef.HTAB_entry op BR) as [E|E]; rewrite E in TRD; unfold PZDef.H_NOP, PZDef.H_ADMIN in TRD.
    - zstep. zstep. zstep. zstep. zstep.
      apply evt_done. apply K.
    - zstep. zstep. zstep. zstep. zstep. apply evt_done. apply K. }
  chkbN 13 (A+20) SWA kk SHR Hk. destruct Hk as [-> | (G1 & G2)].
  - step. step. lit_branch. apply DJ.
  - step. rewrite (sxb_small kk) by lia.
    step. if_cases GBN; zify_cond GBN; [| exfalso; lia].
    step. step. if_cases GB; zify_cond GB; zify_granule GB; [| exfalso; lia].
    apply DJ.
Qed.
End D.


Section B.
Context {HC : HasCeiling} {HG : HasGuard}.
Lemma PZ_munch : forall (m m' : mem) A, PZDef.PZ m -> munch [(A, A + 21)] m m' -> app_iv (A, A + 21) -> 0x5f3000 <= A -> PZDef.PZ m'.
Proof.
  intros m m' A [SH CT] MU AI A5. split.
  - eapply shw_frame; [exact SH| exact MU| constructor; [exact AI| constructor]].
  - eapply bytes_at_transport; [exact CT| exact MU|]. rewrite u64s_length, PZDef.HTAB_length.
    cbn [disjoint_from]. unfold PZDef.HANDLERS_A. split; [lia| exact I].
Qed.

Lemma fza_body : forall (Q : machine_state -> Prop) A D n (data junk : list byte) q GP T0 T1 T2 S0 A1 A2 A3 A4 A5 A6 A7 S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6 (F : bvmap 5 word) fc (m : mem),
  mem_inv asegs m -> shw m A 21 -> (n = 0 \/ shw m D n) -> PZDef.PZ m -> u8arr asegs m A junk -> length junk = 21%nat ->
  bytes_at asegs m D data -> Z.of_nat (length data) = n -> 0 <= n <= 2^26 ->
  0x5f3000 <= A -> A mod 16 = 0 -> A + 21 < 2^47 ->
  (n = 0 \/ (0 <= D /\ D mod 16 = 0 /\ D + n < 2^47 /\ (D + n <= A \/ A + 21 <= D))) ->
  (forall (m' : mem) t0' s1' a1' a2' a3' a4' a5' a6' a7', mem_inv asegs m' -> munch [(A, A + 21)] m m' -> wmono asegs m m' ->
     Q (MS (mkR (wz 0x7e73c) (wz q) GP (wz A0_TP) t0' T1 T2 (wz A) s1' (wz A) a1' a2' a3' a4' a5' a6' a7' (wz n) (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
          F (wz A0_free) fc None m' (seg_rom asegs))) ->
  evt asegs Q (MS (mkR (wz 0x7e660) (wz q) GP (wz A0_TP) T0 T1 T2 S0 (wz D) (wz A) A1 A2 A3 A4 A5 A6 A7 (wz n) (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
      F (ret_pc (wz 0x7e660)) fc None m (seg_rom asegs)).
Proof.
  intros until m. intros MI SWA SWDo HPZ ARR LJ BUF DLEN NR A5p A16 A2p DOK K.
  replace (ret_pc (wz 0x7e660)) with (wz 0x7e660) by (symmetry; apply ret_pc_even; [lia| reflexivity]).
  pose proof (munch_refl [(A, A + 21)] m) as MU. pose proof (wmono_refl asegs m) as WM.
  zstep. if_cases K0; zify_cond K0; [exfalso; lia|].
  zstep. zstep. zstep. zstep.
  replace ((A + 20) ≫ 3 + 2147450880) with (sh (A + 20)) by (unfold sh, SHADOW_OFF; rewrite Z.shiftr_div_pow2 by lia; reflexivity).
  assert (AIV : app_iv (A, A + 21)) by (eapply app_iv_of_win_ok; [exact (shw_win_ok _ _ _ SWA)| lia| lia]).
  assert (JOIN : forall a1v a2v, evt asegs Q (MS (mkR (wz 0x7e660) (wz q) GP (wz A0_TP) T0 T1 T2 (wz A) (wz D) (wz (A+20)) a1v a2v (wz (sh (A+20))) A4 A5 A6 A7 (wz n) (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
      F (wz 0x7e67c) fc None m (seg_rom asegs))).
  { intros a1v a2v.
    pose proof (u8arr_store_ok asegs _ _ _ 20 (wa (A+20)) ARR ltac:(lia) eq_refl) as SOK.
    zstep. zstep.
    replace (le1 (wz 0)) with [Z_to_bv 8 0] by reflexivity.
    pose proof (munch_write1 m (A+20) [Z_to_bv 8 0] ltac:(lia) ltac:(cbn; lia)) as MUw.
    pose proof (shw_store m A 21 (A+20) [Z_to_bv 8 0] SWA ltac:(lia) ltac:(cbn;lia) ltac:(eapply app_iv_of_win_ok; [exact (shw_win_ok _ _ _ SWA) | lia | cbn; lia])) as SWA1.
    assert (SWD1 : n = 0 \/ shw (write_to_mem m (wa (A + 20)) [Z_to_bv 8 0]) D n).
    { destruct SWDo as [N0|SD]; [left; exact N0| right].
      exact (shw_store m D n (A+20) [Z_to_bv 8 0] SD ltac:(lia) ltac:(cbn;lia) ltac:(eapply app_iv_of_win_ok; [exact (shw_win_ok _ _ _ SWA) | lia | cbn; lia])). }
    assert (BUF1 : bytes_at asegs (write_to_mem m (wa (A + 20)) [Z_to_bv 8 0]) D data).
    { eapply (bytes_at_transport asegs _ m); [exact BUF| exact MUw|]. cbn [disjoint_from length]. rewrite DLEN.
      split; [| exact I]. destruct DOK as [N0|(_ & _ & _ & [HS|HS])]; [lia| left; lia| right; lia]. }
    pose proof (u8arr_write asegs _ _ _ 20 (Z_to_bv 8 0) ARR ltac:(lia)) as ARR1. clear ARR MUw. store_done.
    pose proof (PZ_munch _ _ A HPZ MU AIV A5p) as HPZ1.
    lazymatch goal with |- evt _ _ (MS _ _ _ _ _ ?m1 _) =>
    assert (J2 : forall kk, (kk = n /\ n < 21 \/ kk = 21 /\ 21 <= n) ->
      evt asegs Q (MS (mkR (wz 0x7e660) (wz q) GP (wz A0_TP) T0 T1 T2 (wz A) (wz D) (wz (A+20)) (wz 21) a2v (wz (sh (A+20))) (wz kk) A5 A6 A7 (wz n) (wz 2147450880) S4 S5 S6 S7 S8 S9 S10 S11 T3 T4 T5 T6)
        F (wz 0x7e690) fc None m1 (seg_rom asegs))) end.
    { intros kk KK.
      pose proof (munch_refl [] m0) as MUz. pose proof (wmono_refl asegs m0) as WMz.
      step. if_cases KZ; zify_cond KZ.
      - destruct (nth_error (upd junk 20 (Z_to_bv 8 0)) 20) as [b|] eqn:NB; [| apply nth_error_None in NB; rewrite upd_length in NB; lia].
        eapply fza_disp; [exact MI| exact SWA1| exact HPZ1| exact ARR1| exact NB| lia| lia| lia|].
        intros a1' a2'. apply K; [exact MI| exact MU| exact WM].
      - destruct DOK as [N0|(DD0 & DD16 & DD2 & DSEP)]; [lia|].
        destruct SWD1 as [N0|SWD1]; [lia|].
        zstep. zstep. zstep.
        eapply (fza_loop0 A D kk data) with (m0 := m0);
          [ lia | rewrite DLEN; lia | lia | rewrite DLEN; exact DSEP | | lia | exact MI | exact SWA1 | rewrite DLEN; exact SWD1 | exact ARR1 | rewrite upd_length; exact LJ | exact BUF1 ].
        intros m' bs t0 a6 a7 MI' MU' WM' SWA' SWD' ARR' LEN' BUF'.
        destruct (nth_error bs 20) as [b|] eqn:NB; [| apply nth_error_None in NB; lia].
        eapply fza_disp; [exact MI'| exact SWA'| exact (PZ_munch _ _ A HPZ1 MU' AIV A5p)| exact ARR'| exact NB| lia| lia| lia|].
        intros a1' a2'. apply K; [exact MI'| exact (munch_trans _ _ _ _ MU MU')| exact (wmono_trans asegs _ _ _ WM WM')]. }
    zstep. step. if_cases KB; zify_cond KB.
    - apply (J2 n). left; lia.
    - zstep. apply (J2 21). right; lia. }
  chkbN 13 (A+20) SWA kk SHR Hk. destruct Hk as [-> | (G1 & G2)].
  - step. step. lit_branch. apply JOIN.
  - step. rewrite (sxb_small kk) by lia.
    step. if_cases GBN; zify_cond GBN; [| exfalso; lia].
    step. step. if_cases GB; zify_cond GB; zify_granule GB; [| exfalso; lia].
    apply JOIN.
Qed.
End B.

Section E2.
Context {HC : HasCeiling}.
Lemma fza_epi : forall (lo : Z) ra (sp : word) gp tp t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 x1 x8 x9 a0x x18 x19 (jk : list byte) (F : bvmap 5 word) fc (m : mem),
  stk asegs m lo (bv_unsigned sp + -48) -> (lo + 48 <= bv_unsigned sp)%Z -> (0 <= lo)%Z -> (bv_unsigned sp < 2^63)%Z -> mem_inv asegs m ->
  rw_cells asegs m (bv_unsigned sp + -48) [CB 8 jk; C8 s3; C8 s2; C8 s1; C8 s0; C8 ra] ->
  evt asegs (fun ms' => ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (wz 0) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6) F (ret_pc ra) fc None m (seg_rom asegs)
      /\ stk asegs m lo (bv_unsigned sp))
    (MS (mkR x1 (wz (bv_unsigned sp + -48)) gp tp t0 t1 t2 x8 x9 a0x a1 a2 a3 a4 a5 a6 a7 x18 x19 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
        F (wz 0x7e73c) fc None m (seg_rom asegs)).
Proof.
  intros until m. intros ST LOQ LO0 SPH MI FR.
  pose proof (munch_refl [] m) as MU. pose proof (wmono_refl asegs m) as WM. pose proof (word_lt64 sp) as SPB.
  zstep. zstep. zstep. zstep. zstep. zstep. zstep.
  zstep.
  eapply stk_release in FR; [| exact ST| lia]. cbn [cells_size csize Nat.add app] in FR.
  replace (bv_unsigned sp + -48 + Z.of_nat 48)%Z with (bv_unsigned sp) in FR by lia.
  apply evt_done. split; [reflexivity| exact FR].
Qed.
End E2.

Section E.
Context {HC : HasCeiling}.
Lemma fza_entry : forall (D n lo : Z) ra sp gp tp t0 t1 t2 s0 s1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 (F : bvmap 5 word) fc (m : mem),
  stk asegs m lo (bv_unsigned sp) -> (lo + 48 <= bv_unsigned sp)%Z -> alloc_ceiling <= lo -> (bv_unsigned sp < 2^63)%Z -> mem_inv asegs m ->
  asan_globals asegs m ->
  evt asegs (fun ms' => exists (m' : mem) (jk : list byte),
      ms' = MS (mkR (wz 0x7e660) (wz (bv_unsigned sp + -48)) gp tp t0 t1 t2 s0 (wz D) (wz 21) (wz 647416) a2 a3 a4 a5 a6 a7 (wz n) (wz 2147450880) s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
               F (wz A0_malloc) fc None m' (seg_rom asegs)
      /\ munch [(bv_unsigned sp + -48, bv_unsigned sp)] m m' /\ wmono asegs m m' /\ mem_inv asegs m' /\ stk asegs m' lo (bv_unsigned sp + -48)
      /\ rw_cells asegs m' (bv_unsigned sp + -48) [CB 8 jk; C8 s3; C8 s2; C8 s1; C8 s0; C8 ra])
    (MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (wz D) (wz n) a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
        F (wz fuzz_entryA) fc None m (seg_rom asegs)).
Proof.
  intros until m. intros ST LOQ CLO SPH MI AG. pose proof alloc_ceiling_bounds as ACB. unfold alloc_floor, alloc_ceiling_max in ACB. unfold fuzz_entryA, A0_malloc.
  destruct AG as (G1 & G2 & G3 & G4). unfold A0_GOT_SHADOW, A0_SHADOW_CELL in G1, G2.
  pose proof (munch_refl [(bv_unsigned sp + -48, bv_unsigned sp)]%Z m) as MU. pose proof (wmono_refl asegs m) as WM.
  pose proof (word_lt64 sp) as SPB.
  zstep. carve_frame 48%nat ST. unfold SHADOW_OFF in G2.
  zstep. zstep. zstep. zstep. zstep.
  zstep. zstep. zstep. zstep. zstep. zstep. zstep.
  apply evt_done. do 2 eexists. split; [reflexivity|]. split; [exact MU|]. split; [exact WM|]. split; [exact MI|]. split; [exact ST| exact FR].
Qed.
End E.

Section T.
Context {HC : HasCeiling} {HG : HasGuard}.
Variable FI : fs_if.
Variable AI : am_if FI.
Variable J : a0_judg FI AI.
Variable AC : am_contracts FI AI J.
Hypothesis ASL : forall lo hi, am_static FI AI lo hi -> a0_static lo hi.
Hypothesis AMS : forall lo hi, a0_static lo hi -> am_static FI AI lo hi.
Local Notation K := (am_K FI AI).
Local Notation BL := (list (block K)).
Local Notation PS := (aps FI AI).

Lemma pkeep_trans' : forall (LB : BL) q m1 m2 m3, pkeep FI AI LB q m1 m2 -> pkeep FI AI LB q m2 m3 -> pkeep FI AI LB q m1 m3.
Proof.
  intros LB q m1 m2 m3 H1 H2 a Ha Hc. destruct (H1 a Ha Hc) as [E1 W1]. destruct (H2 a Ha Hc) as [E2 W2].
  split; [exact (gkeep_trans _ _ _ _ E1 E2)| auto].
Qed.

Lemma pkeep_of_apres : forall (LB LB' : BL) q q' m m', apres FI AI LB' q' m m' -> q' <= q -> (forall b, In b LB -> In b LB') -> pkeep FI AI LB q m m'.
Proof.
  intros LB LB' q q' m m' AP HQ HL a Ha Hc. apply (AP a Ha).
  destruct Hc as [X|[(lo & hi & S1 & S2 & _)|[(b & Hb & R)|(b & Hb & R)]]].
  - left; lia.
  - right; left; exists lo, hi; split; assumption.
  - right; right; left; exists b; split; [apply HL; exact Hb| exact R].
  - do 5 right; exists b; split; [apply HL; exact Hb| exact R].
Qed.

Lemma pkeep_of_munch : forall (LB : BL) q W m m', munch W m m' -> wmono asegs m m' ->
  (forall a, 0 <= a < 2^64 -> pclient FI AI LB q a -> outside W a) -> pkeep FI AI LB q m m'.
Proof.
  intros LB q W m m' MU WM HO a Ha Hc. split; [| intros Hw; apply WM; exact Hw].
  apply gkeep_of_eq. unfold munch in MU. pose proof (MU (wa a)) as E. unfold wa in E. rewrite unsigned_lit in E by lia. unfold wa. apply E.
  apply HO; assumption.
Qed.

Lemma pclient_low : forall s (LB : BL) m q a, RHEAP_A FI AI s LB m -> pclient FI AI LB q a -> q <= a \/ a < alloc_ceiling.
Proof.
  intros s LB m q a HR Hc. pose proof alloc_ceiling_range as ACR. unfold alloc_floor, alloc_ceiling_max in ACR.
  destruct Hc as [X|[(lo & hi & S1 & S2 & _)|[(b & Hb & R)|(b & Hb & R)]]]; [left; exact X| right| right| right].
  - apply ASL in S1. unfold a0_static, sh, SHADOW_OFF in S1. lia.
  - destruct (am_block_range FI AI s LB m b HR Hb) as (B0 & B1 & B2 & B3 & _). lia.
  - destruct (am_block_range FI AI s LB m b HR Hb) as (B0 & B1 & B2 & B3 & _).
    pose proof (block_shadow_length (blk_size b) B2) as BL8. unfold sh, SHADOW_OFF in R. Z.div_mod_to_equations. lia.
Qed.

Lemma pclient_not_blk : forall s (LB LB2 : BL) m q k A n a, RHEAP_A FI AI s LB2 m -> In (k, A, n) LB2 ->
  (forall b, In b LB -> In b LB2 /\ (k, A, n) <> b) -> alloc_ceiling <= q ->
  pclient FI AI LB q a -> ~ (A <= a < A + n).
Proof.
  intros s LB LB2 m q k A n a HR HIN HL QC Hc Ha. pose proof alloc_ceiling_range as ACR. unfold alloc_floor, alloc_ceiling_max in ACR.
  destruct (am_block_range FI AI s LB2 m _ HR HIN) as (A0 & A1 & A2 & A3 & A4 & A5 & _). cbn [blk_addr blk_size fst snd] in *.
  destruct Hc as [X|[(lo & hi & S1 & S2 & _)|[(b & Hb & R)|(b & Hb & R)]]].
  - lia.
  - apply ASL in S1. unfold a0_static, sh, SHADOW_OFF in S1. destruct S1 as [_ S1].
    destruct A5 as [A5|A5]; Z.div_mod_to_equations; lia.
  - destruct (HL b Hb) as [Hb2 NE].
    pose proof (am_blocks_disjoint FI AI s LB2 m _ _ HR HIN Hb2 NE) as X. cbn [blk_addr blk_size fst snd] in X. lia.
  - destruct (HL b Hb) as [Hb2 _]. destruct (am_block_range FI AI s LB2 m b HR Hb2) as (B0 & B1 & B2 & B3 & B4 & _).
    pose proof (block_shadow_length (blk_size b) B2) as BL8. unfold sh, SHADOW_OFF in R.
    destruct A5 as [A5|A5]; Z.div_mod_to_equations; lia.
Qed.

Lemma pz_band_pclient : forall (LB : BL) q a, pz_band a -> pclient FI AI LB q a.
Proof.
  intros LB q a Ha. right; left. unfold pz_band in Ha. unfold A0_ERRNO.
  destruct Ha as [Ha|[Ha|[Ha|[Ha|Ha]]]].
  - exists 0x10000, 0x97e30. split; [apply AMS; unfold a0_static; split; [lia|]; left; lia| lia].
  - exists 0x9a6b8, 0x9a9e0. split; [apply AMS; unfold a0_static; split; [lia|]; right; left; lia| lia].
  - lia.
  - lia.
  - exists 0x7fffa000, 0x800b6600. split; [apply AMS; unfold a0_static; split; [lia|]; do 11 right; left; lia| lia].
Qed.

End T.

Section T2.
Context {HC : HasCeiling} {HG : HasGuard}.
Variable FI : fs_if.
Variable AI : am_if FI.
Variable J : a0_judg FI AI.
Variable AC : am_contracts FI AI J.
Hypothesis ASL : forall lo hi, am_static FI AI lo hi -> a0_static lo hi.
Hypothesis AMS : forall lo hi, a0_static lo hi -> am_static FI AI lo hi.
Local Notation K := (am_K FI AI).
Local Notation BL := (list (block K)).
Local Notation PS := (aps FI AI).

Lemma lb_remove_head : forall (k : K) A n (LB : BL), ~ In k (map blk_id LB) -> lb_remove (am_K_eqb FI AI) k ((k, A, n) :: LB) = LB.
Proof.
  intros k A n LB NIN. unfold lb_remove. rewrite list.filter_cons. destruct (decide _) as [Dc|Dc].
  - exfalso. cbn in Dc. rewrite (proj2 (am_K_eqb_eq FI AI k k) eq_refl) in Dc. exact Dc.
  - clear Dc. induction LB as [|b LB IH]; [reflexivity|]. cbn [map In] in NIN.
    rewrite list.filter_cons. destruct (decide _) as [D2|D2].
    + f_equal. apply IH. tauto.
    + exfalso. apply D2. destruct (am_K_eqb FI AI (blk_id b) k) eqn:E; [apply (am_K_eqb_eq FI AI) in E; tauto| exact I].
Qed.

Theorem fuzz_one_main : fuzz_one_stmtA FI AI J PZDef.PZ.
Proof.
  unfold fuzz_one_stmtA.
  intros ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F fc m s LB st D n lo errv canary data.
  intros BD LEN NR DSRC HR RF FCO AE LBL LBB NSEC ST CLO LO QAL QTOP SHZ SHR SHW1 SHW2 ERRC MI HPZ GS SG TPV -> -> -> RAV FRM.
  pose proof alloc_ceiling_range as ACR. unfold alloc_floor, alloc_ceiling_max in ACR.
  pose proof (am_stack_ok FI AI) as (TK1 & TK2 & TK3 & TK4).
  pose proof (word_lt64 sp) as SPB.
  unfold PARSER_STACK_A in LO.
  assert (TPE : tp = wz A0_TP) by (rewrite TPV; reflexivity). subst tp.
  eapply (aj_evt FI AI J).
  { eapply (fza_entry D n lo); [exact ST| lia| exact CLO| lia| exact MI| exact (asan_env_globals asegs m AE)]. }
  intros ms1 (m1 & jk & -> & MU1 & WM1 & MI1 & ST1 & FR1).
  assert (SPQ : bv_unsigned (wz (bv_unsigned sp + -48)) = bv_unsigned sp + -48) by (apply unsigned_lit; lia).
  assert (HR1 : RHEAP_A FI AI s LB m1).
  { eapply (am_heap_frame FI AI s LB m m1 _ HR MU1 WM1). constructor; [left; cbn [fst]; lia| constructor]. }
  assert (AE1 : asan_env asegs m1).
  { eapply (asan_env_frame asegs m m1 _ AE MU1 WM1). constructor; [left; cbn [fst]; lia| constructor]. }
  assert (RF1 : RFAKE FI st m1).
  { eapply (rfake_blk_write FI AI s LB st m m1 _ HR RF MU1 WM1). constructor; [split; [left; cbn [fst]; lia| cbn; lia]| constructor]. }
  assert (PK1 : pkeep FI AI LB (bv_unsigned sp) m m1).
  { eapply pkeep_of_munch; [exact MU1| exact WM1|]. intros a Ha Hc. cbn [outside]. split; [| exact I].
    destruct (pclient_low FI AI ASL s LB m (bv_unsigned sp) a HR Hc); lia. }
  assert (ERR1 : rw_cells asegs m1 RERRNOA [C4 errv]).
  { apply (rw_cells_transport asegs _ m m1 _ _ ERRC MU1 WM1). unfold RERRNOA.
    cbn [disjoint_from cells_size csize Nat.add]. change (Z.of_nat 4) with 4. split; [left; lia| exact I]. }
  eapply (aj_bind FI AI J).
  { eapply (ac_malloc FI AI J AC) with (lo := lo) (n := 21) (ras := []) (st := st);
      first [ exact HR1 | exact AE1 | exact RF1 | exact MI1 | exact CLO | exact ST1 | reflexivity | lia | idtac ].
    - unfold A0_RT_STACK. lia.
    - Z.div_mod_to_equations. lia.
    - cbn [fpchain]. unfold valid_frame. intros (X & _ & _). rewrite unsigned_lit in X by lia. lia.
    - rewrite unsigned_lit by lia. unfold A0_TRACES. cbn [In]. repeat (first [left; reflexivity | right]).
    - unfold A0_MAXREQ; lia.
    - eapply am_budget_short; [lia| lia| | | unfold FZ_NSEC in NSEC; lia].
      + apply Forall_forall. intros b Hb. destruct (am_block_range FI AI s LB m1 b HR1 Hb) as (_ & _ & X & _). exact X.
      + lia. }
  intros sM LBM ms2 POST.
  destruct POST as (u0 & u1 & u2 & c1 & c2 & c3 & c4 & c5 & c6 & c7 & u3 & u4 & u5 & u6 & m2 & k & A & junk & -> & (MI2 & ST2 & AE2 & RF2 & AP2) & -> & HR2 & CELLS & SHC & WM2 & NS2).
  (* block facts *)
  pose proof (am_blocks_nodup FI AI _ _ _ HR2) as ND. cbn [map blk_id fst snd] in ND. inversion_clear ND as [|x l NIN0 _].
  assert (NIN : ~ In k (map blk_id LB)) by (intro H; apply NIN0; apply list_elem_of_In; exact H).
  destruct (am_block_range FI AI _ _ _ (k, A, 21) HR2 (or_introl eq_refl)) as (A0p & A16 & _ & ACE & A5p & _).
  cbn [blk_addr blk_size fst snd] in A0p, A16, ACE, A5p.
  assert (NEQ : forall b, In b LB -> (k, A, 21) <> b).
  { intros b Hb E. apply NIN. apply in_map_iff. exists b. split; [rewrite <- E; reflexivity| exact Hb]. }
  assert (DISJ : forall b, In b LB -> A + 21 <= blk_addr b \/ blk_addr b + blk_size b <= A).
  { intros b Hb.
    pose proof (am_blocks_disjoint FI AI _ _ _ (k, A, 21) b HR2 (or_introl eq_refl) (or_intror Hb) (NEQ b Hb)) as X.
    cbn [blk_addr blk_size fst snd] in X. lia. }
  assert (DOK : n = 0 \/ (0 <= D /\ D mod 16 = 0 /\ D + n < 2^47 /\ (D + n <= A \/ A + 21 <= D))).
  { destruct DSRC as [[N0 _]|[kD KIN]]; [left; exact N0| right].
    destruct (am_block_range FI AI s LB m _ HR KIN) as (B0 & B16 & _ & B3 & _). cbn [blk_addr blk_size fst snd] in B0, B16, B3.
    pose proof (DISJ _ KIN) as X. cbn [blk_addr blk_size fst snd] in X. repeat split; lia. }
  assert (SWD : n = 0 \/ shw m2 D n).
  { destruct DSRC as [[N0 _]|[kD KIN]]; [left; exact N0| right].
    eapply (block_shw FI AI sM _ m2 (kD, D, n)); [exact HR2| right; exact KIN| cbn; lia| cbn; lia| lia]. }
  assert (SWA : shw m2 A 21).
  { eapply (block_shw FI AI sM _ m2 (k, A, 21)); [exact HR2| left; reflexivity| cbn; lia| cbn; lia| lia]. }
  (* memory relation m -> m2 *)
  assert (PK2 : pkeep FI AI LB (bv_unsigned sp) m1 m2).
  { eapply (pkeep_of_apres FI AI LB LB); [exact AP2| lia| intros b Hb; exact Hb]. }
  pose proof (pkeep_trans' FI AI _ _ _ _ _ PK1 PK2) as PKm2.
  assert (HPZ2 : PZDef.PZ m2).
  { apply (GluePZ.PZ_agree (pclient FI AI LB (bv_unsigned sp)) m m2 (pkeep_agree FI AI LB _ m m2 PKm2)); [| exact HPZ].
    intros a Ha. exact (pz_band_pclient FI AI AMS LB _ a Ha). }
  assert (BUF2 : bytes_at asegs m2 D data).
  { eapply (bytes_at_gagree (pclient FI AI LB (bv_unsigned sp))); [exact (pkeep_agree FI AI LB _ m m2 PKm2)| exact BD|].
    intros a Ha. rewrite LEN in Ha. destruct DSRC as [[N0 _]|[kD KIN]]; [lia|].
    right; right; left. exists (kD, D, n). split; [exact KIN| cbn [blk_addr blk_size fst snd]; lia]. }
  assert (ERRS : aclient_range FI AI LB (bv_unsigned sp + -48) RERRNOA (Z.of_nat (cells_size [C4 errv]))).
  { apply (aclient_range_static FI AI LB _ _ _ 0x5d0fe8 0x5d0ff0); [apply AMS; unfold a0_static; split; [lia|]; do 4 right; left; lia| unfold RERRNOA; lia| unfold RERRNOA; cbn; lia]. }
  pose proof (apres_rw_cells FI AI _ _ m1 m2 _ _ AP2 ERR1 ERRS) as ERR2.
  pose proof (apres_rw_cells FI AI _ _ m1 m2 _ _ AP2 FR1 (aclient_range_above FI AI LB (bv_unsigned sp + -48) (bv_unsigned sp + -48) _ (Z.le_refl _))) as FR2.
  assert (LJ : length junk = 21%nat) by (destruct CELLS as [[Hwf _] _]; cbn in Hwf; tauto).
  pose proof (u8arr_of_rw_cells _ _ _ _ _ CELLS) as ARR.
  (* body *)
  eapply (aj_evt FI AI J
    (fun ms => exists (m3 : mem) (t0' s1' a1' a2' a3' a4' a5' a6' a7' : word),
       ms = MS (mkR (wz 0x7e73c) (wz (bv_unsigned sp + -48)) gp (wz A0_TP) t0' u1 u2 (wz A) s1' (wz A) a1' a2' a3' a4' a5' a6' a7' (wz n) (wz 2147450880) s4 s5 s6 s7 s8 s9 s10 s11 u3 u4 u5 u6)
              F (wz A0_free) fc None m3 (seg_rom asegs)
       /\ mem_inv asegs m3 /\ munch [(A, A + 21)] m2 m3 /\ wmono asegs m2 m3)).
  { eapply (fza_body _ A D n data junk (bv_unsigned sp + -48));
      [exact MI2| exact SWA| exact SWD| exact HPZ2| exact ARR| exact LJ| exact BUF2| exact LEN| exact NR| lia| exact A16| lia| exact DOK|].
    intros m' t0' s1' a1' a2' a3' a4' a5' a6' a7' MI' MU' WM'.
    exists m', t0', s1', a1', a2', a3', a4', a5', a6', a7'. split; [reflexivity|]. split; [exact MI'|]. split; [exact MU'| exact WM']. }
  intros ms3 (m3 & t0' & s1' & b1 & b2 & b3 & b4 & b5 & b6 & b7 & -> & MI3 & MU3 & WM3).
  assert (HR3 : RHEAP_A FI AI sM ((k, A, 21) :: LB) m3).
  { eapply (rheap_blk_write FI AI); [exact HR2| exact MU3| exact WM3|].
    constructor; [| constructor]. right. exists (k, A, 21). split; [left; reflexivity| cbn; lia]. }
  assert (AE3 : asan_env asegs m3).
  { eapply (asan_env_frame asegs m2 m3 _ AE2 MU3 WM3). constructor; [left; cbn [fst]; lia| constructor]. }
  assert (RF3 : RFAKE FI st m3).
  { eapply (rfake_blk_write FI AI sM _ st m2 m3 _ HR2 RF2 MU3 WM3).
    constructor; [split; [right; exists (k, A, 21); split; [left; reflexivity| cbn; lia]| cbn; lia]| constructor]. }
  assert (AGR3 : Agree.agree_on asegs (fun a => outside [(A, A + 21)] a) m2 m3) by (apply Agree.agree_on_of_munch; assumption).
  assert (ST3 : stk asegs m3 lo (bv_unsigned sp + -48)).
  { eapply (Agree.stk_agree asegs); [exact AGR3| exact ST2| intros a Ha; cbn [outside]; split; [lia| exact I]]. }
  pose proof (rw_cells_transport asegs _ m2 m3 _ _ FR2 MU3 WM3) as FR3.
  specialize (FR3 ltac:(cbn [disjoint_from cells_size csize Nat.add]; split; [lia| exact I])).
  pose proof (rw_cells_transport asegs _ m2 m3 _ _ ERR2 MU3 WM3) as ERR3.
  specialize (ERR3 ltac:(unfold RERRNOA; cbn [disjoint_from cells_size csize Nat.add]; split; [lia| exact I])).
  assert (HL : forall b, In b LB -> In b ((k, A, 21) :: LB) /\ (k, A, 21) <> b) by (intros b Hb; split; [right; exact Hb| exact (NEQ b Hb)]).
  assert (PK3 : pkeep FI AI LB (bv_unsigned sp) m2 m3).
  { eapply (pkeep_of_munch FI AI LB _ _ m2 m3 MU3 WM3). intros a Ha Hc. cbn [outside]. split; [| exact I].
    pose proof (pclient_not_blk FI AI ASL sM LB ((k, A, 21) :: LB) m2 (bv_unsigned sp) k A 21 a HR2 (or_introl eq_refl) HL ltac:(lia) Hc). lia. }
  (* free *)
  eapply (aj_bind FI AI J).
  { eapply (ac_free FI AI J AC) with (lo := lo) (k := k) (A := A) (n := 21) (ras := []) (st := st);
      first [ exact HR3 | exact AE3 | exact RF3 | exact MI3 | exact CLO | exact ST3 | reflexivity | (left; reflexivity) | lia | idtac ].
    - unfold A0_RT_STACK. lia.
    - Z.div_mod_to_equations. lia.
    - cbn [fpchain]. unfold valid_frame. intros (X & _ & _). rewrite unsigned_lit in X by lia. lia.
    - rewrite unsigned_lit by lia. unfold A0_TRACES. cbn [In]. repeat (first [left; reflexivity | right]). }
  intros sF LBF ms4 POST.
  destruct POST as (v0 & v1 & v2 & d0 & d1 & d2 & d3 & d4 & d5 & d6 & d7 & v3 & v4 & v5 & v6 & m4 & -> & (MI4 & ST4 & AE4 & RF4 & AP4) & -> & HR4 & NS4).
  rewrite (lb_remove_head k A 21 LB NIN) in AP4, HR4 |- *.
  pose proof (apres_rw_cells FI AI _ _ m3 m4 _ _ AP4 FR3 (aclient_range_above FI AI LB (bv_unsigned sp + -48) (bv_unsigned sp + -48) _ (Z.le_refl _))) as FR4.
  pose proof (apres_rw_cells FI AI _ _ m3 m4 _ _ AP4 ERR3 ERRS) as ERR4.
  assert (PK4 : pkeep FI AI LB (bv_unsigned sp) m3 m4) by (eapply (pkeep_of_apres FI AI LB LB); [exact AP4| lia| intros b Hb; exact Hb]).
  pose proof (pkeep_trans' FI AI _ _ _ _ _ PKm2 (pkeep_trans' FI AI _ _ _ _ _ PK3 PK4)) as PK.
  replace (ret_pc (wz 0x7e73c)) with (wz 0x7e73c) by (symmetry; apply ret_pc_even; [lia| reflexivity]).
  (* epilogue *)
  eapply (aj_evt FI AI J).
  { eapply (fza_epi lo); [exact ST4| lia| lia| lia| exact MI4| exact FR4]. }
  intros ms5 (-> & STF).
  pose proof (pkeep_agree FI AI LB _ m m4 PK) as AG.
  apply (aj_ret FI AI J). unfold fuzz_one_postA.
  eexists _, _, _, _, _, _, _, _, _, _, _, _, _, _, m4, st.
  split; [reflexivity|]. split; [exact MI4|]. split; [exact STF|]. split; [exact AE4|]. split; [exact RF4|].
  split; [exact PK|]. split; [reflexivity|]. split; [exact HR4|].
  split; [intros b Hb; exact Hb|]. split; [intros b Hb; exact Hb|].
  split. { rewrite NS4, NS2. unfold FZ_NSEC. destruct (_ =? 0); lia. }
  split. { apply (GluePZ.PZ_agree (pclient FI AI LB (bv_unsigned sp)) m m4 AG); [| exact HPZ].
           intros a Ha. exact (pz_band_pclient FI AI AMS LB _ a Ha). }
  split; [exists errv; exact ERR4|].
  split.
  { apply (shz_agree (pclient FI AI LB (bv_unsigned sp)) m m4 _ _ AG); [| unfold sh, SHADOW_OFF; Z.div_mod_to_equations; lia| unfold sh, SHADOW_OFF; Z.div_mod_to_equations; lia| exact SHZ].
    intros a Ha. right; left. exists (sh alloc_ceiling - sh alloc_ceiling mod 8), 0x10007fff8000.
    split; [apply AMS; exact a0_static_s6|]. unfold A0_ERRNO. unfold sh, SHADOW_OFF in *. Z.div_mod_to_equations. lia. }
  split.
  { apply (rw_cells_gagree (pclient FI AI LB (bv_unsigned sp)) m m4 _ _ AG GS).
    intros a Ha. right; left. exists 0x10000, 0x97e30. cbn [cells_size csize Nat.add] in Ha. unfold got_ssp in Ha.
    split; [apply AMS; unfold a0_static; split; [lia|]; left; lia| unfold A0_ERRNO; lia]. }
  { apply (rw_cells_gagree (pclient FI AI LB (bv_unsigned sp)) m m4 _ _ AG SG).
    intros a Ha. right; left. exists 0x5f10d0, 0x5f10d8. cbn [cells_size csize Nat.add] in Ha. unfold ssp_guard in Ha.
    split; [apply AMS; unfold a0_static; split; [lia|]; do 5 right; left; lia| unfold A0_ERRNO; lia]. }
Qed.
End T2.


Theorem fuzz_one_spec_A : forall {HC : HasCeiling} {HG : HasGuard} (FI : fs_if) (AI : am_if FI) (J : a0_judg FI AI)
    (AC : am_contracts FI AI J)
    (ASL : forall lo hi, am_static FI AI lo hi -> a0_static lo hi) (AMS : forall lo hi, a0_static lo hi -> am_static FI AI lo hi)
  ,
  fuzz_one_stmtA FI AI J PZDef.PZ.
Proof. intros. eapply fuzz_one_main; eassumption. Qed.
