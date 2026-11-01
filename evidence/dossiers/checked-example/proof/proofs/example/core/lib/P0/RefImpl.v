(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.EquivalenceDefinition Require Import Equivalence.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType StackLayout Fs State Run.
From LinuxProcessSemantics.Riscv Require Import Prelude Sem.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import PropExec MState Mem Cells Exec Step Frame Tac ITree Nodes RegsEquiv.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import Segs.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import Startup_A Startup Stdio_base Printf_lib.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import F_atexit.
From OssFuzzTheorems.Proofs.example.core.lib.Spec Require Import Monad Stdio Driver Prog.
Import ListNotations.
Import ITree.Exc.
Open Scope Z_scope.

Local Notation z64 := (Z_to_bv 64 0).

Definition rat_exit (code : Z) (s : PState) (ms : machine_state) : Prop :=
  exists (ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 : word)
         (F : bvmap 5 word) (fc : bv 32) (m : word -> option byte) (lo t : Z) (td0 td1 td2 td3 guard : word)
         (cdt thr sec : byte) (tm1 : word),
    ms = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
            F (Z_to_bv 64 0x132f0) fc None m (seg_rom rsegs)
    /\ stk rsegs m lo (bv_unsigned sp)
    /\ rw_cells rsegs m 0x2d8e8 [C8 td0; C8 td1; C8 td2; C8 td3; C4 (Z_to_bv 64 t)]
    /\ rw_cells rsegs m 0x4dc10 [C4 z64]
    /\ rw_cells rsegs m 0x1c640 [C8 (Z_to_bv 64 0x1bda8); C8 (Z_to_bv 64 0x1bda0)]
    /\ rw_cells rsegs m 0x1bda0 [C8 (Z_to_bv 64 0x12550)]
    /\ rw_cells rsegs m 0x1d8a8 [C1 (Z_to_bv 8 0)]
    /\ rw_cells rsegs m 0x1c5e8 [C8 (Z_to_bv 64 0x131d4); C8 z64]
    /\ rw_cells rsegs m 0x4dc38 [C1 cdt; C1 thr; C1 sec; C1 (Z_to_bv 8 0); C4 tm1]
    /\ rw_cells rsegs m 0x1d650 [C8 (Z_to_bv 64 0x1d650)]
    /\ (exists reg : bool, atx_state reg m)
    /\ rw_cells rsegs m 0x4e068 [C8 z64] /\ rw_cells rsegs m 0x4e058 [C8 z64]
    /\ rw_cells rsegs m 0x1d850 [C8 (Z_to_bv 64 RSTDOUT)] /\ rw_cells rsegs m 0x1d760 [C8 (Z_to_bv 64 RSTDERR)]
    /\ stdout_file m (ps_so s) /\ stderr_file m
    /\ rw_cells rsegs m 0x1c638 [C8 (Z_to_bv 64 0x4dc18)] /\ rw_cells rsegs m 0x4dc18 [C8 guard]
    /\ mem_inv rsegs m
    /\ tp = Z_to_bv 64 0x2d9b0 /\ a0 = Z_to_bv 64 code
    /\ 0 < t < 4194304 /\ lo <= bv_unsigned sp - 176 /\ 0x4f000 <= lo
    /\ bv_unsigned sp <= 2^47.

Lemma rimpl_msys_of_enode : forall {St A} (n : node) (pl : resp -> option A) (Q : A -> machine_state -> Prop) (s : St) ms,
  impl rsegs (at_node rsegs) (enode n pl) (epost Q) ms ->
  impl rsegs (at_node rsegs) (Monad.msys n pl s) (epost (fun p ms' => Q (fst p) ms' /\ snd p = s)) ms.
Proof.
  intros St A n pl Q s ms H. unfold Monad.msys, enode in *. cbn in *.
  eapply evt_mono; [exact H|]. intros ms1 [Hat Hk]. split; [exact Hat|].
  intros rsp. specialize (Hk rsp). destruct (pl rsp) as [a|]; cbn in *; [|exact Hk].
  eapply evt_mono; [exact Hk|]. intros ms2 HQ. cbn. auto.
Qed.

