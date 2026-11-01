(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From stdpp Require Import gmap.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Run.
From LinuxProcessSemantics.Riscv Require Import Prelude Instr Decode DecodeC Sem Fpu.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac Image ZBridge SysStep SFModel ITree Nodes Decode Arr.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import F_syscalls MallocRep F_malloc_free F_malloc_fast MallocTree MallocKit_A.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import MallocKit_AB.
From OssFuzzTheorems.Proofs.example.core.lib.Spec Require Import STree Malloc MallocCtrl Monad Prog.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import Malloc_fp MallocKit_A2.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import MallocKit_A3 ASlot_W1.
Import ListNotations.
Open Scope Z_scope.

Local Ltac Z.euclidean_division_equations_cleanup ::= idtac.

Section ENTRY.
Context {HCEIL : HasCeiling}.
Variables (st : mstate) (m : mem) (sc lo : Z).
Hypothesis SC : 0 <= sc < 48.
Hypothesis CLO : alloc_ceiling <= lo.
Hypothesis AMS : forall g, active st sc = Some g -> meta_slot st g.
End ENTRY.