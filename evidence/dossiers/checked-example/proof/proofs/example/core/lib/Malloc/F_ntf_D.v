(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From stdpp Require Import gmap.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Run.
From LinuxProcessSemantics.Riscv Require Import Prelude Instr Decode DecodeC Sem Fpu.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac Image ZBridge SysStep SFModel Arr.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import F_syscalls MallocRep F_malloc_free MallocTree.
From OssFuzzTheorems.Proofs.example.core.lib.Spec Require Import STree Malloc MallocCtrl.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import MallocKit_B MallocModel_B F_ntf_A F_ntf_B F_ntf_C.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import MallocKit_B3.
Import ListNotations.
Open Scope bv_scope.
Open Scope Z_scope.