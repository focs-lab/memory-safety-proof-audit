(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith List Lia Bool Permutation.
From stdpp Require Import gmap.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType StackLayout State Run.
From LinuxProcessSemantics.Riscv Require Import Prelude Fpu Sem.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac Image ZBridge SysStep ITree Nodes Decode Arr FP Agree Ceiling.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import Segs.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import MallocBlocks MallocTree MallocHINV Malloc_iface.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import InitStack.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import InitMem.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import Startup_lib.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import Segs RMallocRep RMallocTree RMalloc_iface.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import Stdio_base Printf_lib Startup RefImpl Stdio_iface RDriver_kit.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Segs F_memset F_memcpy.
From OssFuzzTheorems.Proofs.example.core.lib.Spec Require Import Prelim STree Malloc Monad Stdio Driver Prog.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import F_atexit.
Import ListNotations.
Import ITree.Exc.
Open Scope Z_scope.
Open Scope mspec_scope.
Local Ltac Z.euclidean_division_equations_cleanup ::= idtac.

Ltac ua := idtac.

Ltac rpc := apply ret_pc_even; [lia| reflexivity].

Section CTX.
  Variables (sp0 : word) (argv envp : list (list byte)) (TID : Z).
  Notation usp0 := (bv_unsigned sp0).
  Notation gpv := (Z_to_bv 64 0x10800).
  Notation tpv := (Z_to_bv 64 RATP).

  Definition LO : Z := usp0 - 8388608.

  Definition MFRAME (mm : mem) (pad : list byte) (s7v s6v s5v s4v : word) : Prop :=
    rw_cells rsegs mm (usp0 + -128)
      [CB 8 pad; C8 s7v; C8 s6v; C8 s5v; C8 s4v; C8 (Z_to_bv 64 (envp_addr sp0 argv)); C8 (Z_to_bv 64 0x125e0);
       C8 (Z_to_bv 64 (argc argv)); C8 (Z_to_bv 64 (usp0 + 8)); C8 (Z_to_bv 64 0x12e58)].

  Definition RSTAT (mm : mem) : Prop :=
    rw_cells rsegs mm 0x2d8e8 [C8 (Z_to_bv 64 0x2d8e8); C8 (Z_to_bv 64 0x2d8e8); C8 (Z_to_bv 64 0x2d8e8); C8 (Z_to_bv 64 0); C4 (Z_to_bv 64 TID)]
    /\ rw_cells rsegs mm 0x4dc10 [C4 (Z_to_bv 64 0)]
    /\ rw_cells rsegs mm 0x1c640 [C8 (Z_to_bv 64 0x1bda8); C8 (Z_to_bv 64 0x1bda0)]
    /\ rw_cells rsegs mm 0x1bda0 [C8 (Z_to_bv 64 0x12550)]
    /\ rw_cells rsegs mm 0x1d8a8 [C1 (Z_to_bv 8 0)]
    /\ rw_cells rsegs mm 0x1c5e8 [C8 (Z_to_bv 64 0x131d4); C8 (Z_to_bv 64 0)]
    /\ rw_cells rsegs mm 0x4e068 [C8 (Z_to_bv 64 0)]
    /\ rw_cells rsegs mm 0x4e058 [C8 (Z_to_bv 64 0)]
    /\ rw_cells rsegs mm 0x1d850 [C8 (Z_to_bv 64 0x1d768)]
    /\ rw_cells rsegs mm 0x1d760 [C8 (Z_to_bv 64 0x1d678)]
    /\ rw_cells rsegs mm 0x1c5f8 [C8 (Z_to_bv 64 0x1c5a8)]
    /\ rw_cells rsegs mm 0x1c5a8 [C8 (Z_to_bv 64 0x1d678)]
    /\ rw_cells rsegs mm 0x1d650 [C8 (Z_to_bv 64 0x1d650)]
    /\ (exists reg : bool, atx_state reg mm).

  Definition rstat_addr (a : Z) : Prop :=
    (0x2d8e8 <= a < 0x2d90c) \/ (0x4dc10 <= a < 0x4dc14) \/ (0x1c640 <= a < 0x1c650) \/ (0x1bda0 <= a < 0x1c5b0)
    \/ (0x1d8a8 <= a < 0x1d8a9) \/ (0x1c5e8 <= a < 0x1c5f8) \/ (0x4e058 <= a < 0x4e060) \/ (0x4e068 <= a < 0x4e070)
    \/ (0x1d850 <= a < 0x1d858) \/ (0x1d760 <= a < 0x1d768) \/ (0x1c5f8 <= a < 0x1c600)
    \/ (0x1d650 <= a < 0x1d658) \/ (0x4d9f0 <= a < 0x4d9f1) \/ (0x4d9f4 <= a < 0x4d9fc) \/ (0x4da00 <= a < 0x4da18) \/ (0x4db10 <= a < 0x4db18) \/ (0x2d8b4 <= a < 0x2d8b5).
Lemma atx_state_addr_rstat : forall a, atx_state_addr a -> rstat_addr a.
Proof. intros a H. unfold atx_state_addr, atx_addr, RAEF_INCB, rstat_addr in *. lia. Qed.

  Ltac tr AG HP A := eapply rw_cells_agree; [exact AG| exact A| intros a Ha; apply HP; unfold rstat_addr; cbn in Ha; lia].

  #[using="Type"] Lemma RSTAT_agree : forall (P : Z -> Prop) m m', agree_on rsegs P m m' -> (forall a, rstat_addr a -> P a) -> RSTAT m -> RSTAT m'.
  Proof.
    intros P m m' AG HP (A1 & A2 & A3 & A4 & A5 & A6 & A7 & A8 & A9 & A10 & A11 & A12 & A13 & [reg A14]). unfold RSTAT.
    split; [tr AG HP A1|]. split; [tr AG HP A2|]. split; [tr AG HP A3|]. split; [tr AG HP A4|].
    split; [tr AG HP A5|]. split; [tr AG HP A6|]. split; [tr AG HP A7|]. split; [tr AG HP A8|].
    split; [tr AG HP A9|]. split; [tr AG HP A10|]. split; [tr AG HP A11|]. split; [tr AG HP A12|]. split; [tr AG HP A13|].
  exists reg. eapply atx_state_agree; [exact AG| intros a Ha; apply HP; apply atx_state_addr_rstat; exact Ha| exact A14].
  Qed.

  #[using="Type"] Lemma RSTAT_heap_pres : forall LB SP m m', rheap_pres LB SP m m' -> RSTAT m -> RSTAT m'.
  Proof.
    intros LB SP m m' HP. apply (RSTAT_agree _ _ _ HP). intros a Ha. right; left.
    unfold rstat_addr, ralloc_static, RLIBC, RCTX, RERRNO, RSSP_GUARD, RGOT_SSP, RVMLOCK in *. lia.
  Qed.

  #[using="Type"] Lemma RSTAT_munch : forall W m m', munch W m m' -> wmono rsegs m m' -> (forall a, rstat_addr a -> outside W a) -> RSTAT m -> RSTAT m'.
  Proof.
    intros W m m' MU WM HW. apply (RSTAT_agree _ _ _ (agree_on_of_munch rsegs _ _ _ MU WM)). intros a Ha. cbn. apply HW. exact Ha.
  Qed.
End CTX.

Definition stdout_addr (a : Z) : Prop := (0x1d768 <= a < 0x1d850) \/ (0x4e080 <= a < 0x4e480).
Definition stderr_addr (a : Z) : Prop := 0x1d678 <= a < 0x1d760.

Lemma stdout_file_agree : forall (P : Z -> Prop) m m' so,
  agree_on rsegs P m m' -> (forall a, stdout_addr a -> P a) -> stdout_file m so -> stdout_file m' so.
Proof.
  intros P m m' so AG HP (flags & mode & tail & bufbytes & F1 & F2 & F3 & F4 & F5 & F6).
  exists flags, mode, tail, bufbytes. split; [| split; [exact F2| split; [| split; [exact F4| split; [exact F5| exact F6]]]]].
  - eapply rw_cells_agree; [exact AG| exact F1|]. intros a Ha. apply HP. left. cbn in Ha. lia.
  - eapply rw_cells_agree; [exact AG| exact F3|]. intros a Ha. apply HP. right. cbn in Ha. lia.
Qed.

Lemma stderr_wfile0_agree : forall (P : Z -> Prop) m m',
  agree_on rsegs P m m' -> (forall a, stderr_addr a -> P a) -> stderr_wfile0 m -> stderr_wfile0 m'.
Proof.
  intros P m m' AG HP (flags & mode & e & wend & tail & F1 & F2 & F3 & F4).
  exists flags, mode, e, wend, tail. split; [| split; [exact F2| split; [exact F3| exact F4]]].
  eapply rw_cells_agree; [exact AG| exact F1|]. intros a Ha. apply HP. unfold stderr_addr. cbn in Ha. lia.
Qed.

Lemma stdout_file_heap_pres : forall LB SP m m' so, rheap_pres LB SP m m' -> stdout_file m so -> stdout_file m' so.
Proof.
  intros LB SP m m' so HP. apply (stdout_file_agree _ _ _ _ HP). intros a Ha. right; left.
  unfold stdout_addr, ralloc_static, RLIBC, RCTX, RERRNO, RSSP_GUARD, RGOT_SSP, RVMLOCK in *. lia.
Qed.
Lemma stderr_wfile0_heap_pres : forall LB SP m m', rheap_pres LB SP m m' -> stderr_wfile0 m -> stderr_wfile0 m'.
Proof.
  intros LB SP m m' HP. apply (stderr_wfile0_agree _ _ _ HP). intros a Ha. right; left.
  unfold stderr_addr, ralloc_static, RLIBC, RCTX, RERRNO, RSSP_GUARD, RGOT_SSP, RVMLOCK in *. lia.
Qed.
Lemma stdout_file_munch : forall W m m' so, munch W m m' -> wmono rsegs m m' -> (forall a, stdout_addr a -> outside W a) -> stdout_file m so -> stdout_file m' so.
Proof. intros W m m' so MU WM HW. apply (stdout_file_agree _ _ _ _ (agree_on_of_munch rsegs _ _ _ MU WM)). intros a Ha. cbn. apply HW. exact Ha. Qed.
Lemma stderr_wfile0_munch : forall W m m', munch W m m' -> wmono rsegs m m' -> (forall a, stderr_addr a -> outside W a) -> stderr_wfile0 m -> stderr_wfile0 m'.
Proof. intros W m m' MU WM HW. apply (stderr_wfile0_agree _ _ _ (agree_on_of_munch rsegs _ _ _ MU WM)). intros a Ha. cbn. apply HW. exact Ha. Qed.

Lemma RHEAP_ssp {HGW : HasGuard} {HCEIL : HasCeiling} : forall s LB m, RHEAP s LB m -> ssp_cells m guard_word.
Proof.
  intros s LB m (st & LB0 & _ & _ & MREP & _). destruct MREP as (_ & _ & (_ & _ & _ & G1 & G2 & _) & _).
  unfold ssp_cells, got_ssp, ssp_guard. unfold RGOT_SSP, RSSP_GUARD in G1, G2. split; [exact G1| exact G2].
Qed.

Section EXITS.
  Context {HGW : HasGuard} {HCEIL : HasCeiling}.
  Variables (sp0 : word) (argv envp : list (list byte)) (TID : Z).
  Notation usp0 := (bv_unsigned sp0).
  Notation gpv := (Z_to_bv 64 0x10800).
  Notation tpv := (Z_to_bv 64 RATP).
  Hypothesis VSP : valid_sp sp0.
  Hypothesis CEIL : alloc_ceiling = LO sp0.
  Hypothesis HT : 0 < TID < 4194304.

  #[using="VSP CEIL"] Lemma sp_facts : 0x7fff80000000 <= usp0 <= 0x800000000000 /\ usp0 mod 16 = 0 /\ alloc_ceiling <= LO sp0 /\ LO sp0 + 8388608 = usp0 /\ 0x4f000 <= LO sp0.
  Proof. destruct VSP as (A & B & C). rewrite CEIL. unfold LO, sp_window_lo, sp_window_hi, stack_max_size in *. repeat split; lia. Qed.

  #[using="HT"] Lemma rat_exit_intro : forall (code : Z) (s : PState) (LB : list block) (SP : Z) (ra t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 : word)
      (F : bvmap 5 word) (fc : bv 32) (m : mem) (lo : Z),
    stk rsegs m lo SP -> lo <= SP - 176 -> 0x4f000 <= lo -> 0 <= SP <= 2^47 ->
    RSTAT TID m -> RHEAP s LB m -> stdout_file m (ps_so s) -> stderr_file m -> mem_inv rsegs m ->
    rat_exit code s (MS (mkR ra (Z_to_bv 64 SP) gpv tpv t0 t1 t2 s0 s1 (Z_to_bv 64 code) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
                        F (Z_to_bv 64 0x132f0) fc None m (seg_rom rsegs)).
  Proof.
    intros until lo. intros ST LOS LOLO SPR (TD & EXL & GF & FA & FIN & GCX & OFL & SIN & SOU & SEU & _ & _ & DSO & AXS) HP SOF SEF MI.
    destruct (RHEAP_libc_head _ _ _ HP) as (cdt & thr & sec & tm1 & LC).
    pose proof (RHEAP_ssp _ _ _ HP) as [G1 G2]. unfold got_ssp, ssp_guard in G1, G2.
    unfold rat_exit. do 33 eexists. exists m, lo, TID, (Z_to_bv 64 0x2d8e8), (Z_to_bv 64 0x2d8e8), (Z_to_bv 64 0x2d8e8), (Z_to_bv 64 0). eexists.
    exists cdt, thr, sec, tm1.
    split; [reflexivity|]. rewrite !unsigned_lit by lia. split; [exact ST|]. split; [exact TD|]. split; [exact EXL|]. split; [exact GF|]. split; [exact FA|].
    split; [exact FIN|]. split; [exact GCX|]. split; [exact LC|]. split; [exact DSO|]. split; [exact AXS|]. split; [exact OFL|]. split; [exact SIN|]. split; [exact SOU|]. split; [exact SEU|].
    split; [exact SOF|]. split; [exact SEF|]. split; [exact G1|]. split; [exact G2|]. split; [exact MI|].
    split; [reflexivity|]. split; [reflexivity|]. split; [exact HT|]. repeat split; lia.
  Qed.

  Definition exit_k_stmt : Prop :=
    forall (A : Type) (code : Z) (s : PState) (Q : A -> PState -> machine_state -> Prop) (ms : machine_state),
      rat_exit code s ms -> implM rsegs (exit_k (io_S ps_so set_so_ps) (A:=A) code) s Q ms.

  #[using="VSP CEIL HT"] Lemma main_return : forall (code : Z) (s : PState) (LB : list block) (x1 t0 t1 t2 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 : word)
      (pad : list byte) (s7v s6v s5v s4v : word) (F : bvmap 5 word) (fc : bv 32) (m : mem),
    MFRAME sp0 argv m pad s7v s6v s5v s4v ->
    stk rsegs m (LO sp0) (usp0 + -128) ->
    RSTAT TID m -> RHEAP s LB m -> stdout_file m (ps_so s) -> stderr_file m -> mem_inv rsegs m ->
    evt rsegs (rat_exit code s)
      (MS (mkR x1 (Z_to_bv 64 (usp0 + -128)) gpv tpv t0 t1 t2 (Z_to_bv 64 code) s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
          F (Z_to_bv 64 0x127dc) fc None m (seg_rom rsegs)).
  Proof.
    intros until m. intros FR ST RS HP SOF SEF MI. pose proof sp_facts as SF. unfold LO in *. unfold MFRAME in FR.
    do 11 zstep. release_frame FR ST (usp0 + -48). zstep.
    replace (ret_pc (Z_to_bv 64 0x12e58)) with (Z_to_bv 64 0x12e58) by (symmetry; rpc).
    zstep.
    apply evt_done. eapply rat_exit_intro; [exact ST| lia| lia| lia| exact RS| exact HP| exact SOF| exact SEF| exact MI].
  Qed.

  #[using="VSP CEIL HT"] Lemma exit2_tail : forall (s : PState) (LB : list block) (x1 t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 : word)
      (F : bvmap 5 word) (fc : bv 32) (m : mem),
    stk rsegs m (LO sp0) (usp0 + -128) ->
    RSTAT TID m -> RHEAP s LB m -> stdout_file m (ps_so s) -> stderr_file m -> mem_inv rsegs m ->
    evt rsegs (rat_exit 2 s)
      (MS (mkR x1 (Z_to_bv 64 (usp0 + -128)) gpv tpv t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
          F (Z_to_bv 64 0x12868) fc None m (seg_rom rsegs)).
  Proof.
    intros until m. intros ST RS HP SOF SEF MI. pose proof sp_facts as SF. unfold LO in *.
    zstep. zstep.
    apply evt_done. eapply rat_exit_intro; [exact ST| lia| lia| lia| exact RS| exact HP| exact SOF| exact SEF| exact MI].
  Qed.
End EXITS.
