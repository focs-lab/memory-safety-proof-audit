(* example/core: pupnp's ASN/StartupPlan2Asan.v with branches r0_1/r1_2 cut after 2 of their 83/83 memset steps (see
   replay/port/gen_overlay_plan2.py): pupnp registers 82 instrumented globals before main, core.asan one.
   port: donor-derived (addresses are renamed like a donor file's) *)
(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith List.
From LinuxProcessSemantics.Riscv Require Import Instr.
From OssFuzzTheorems.Proofs.example.core.lib.ASN Require Import AxSymExec3.
From OssFuzzTheorems.Proofs.example.core.lib.ASN Require Import AsanPlan.
Import ListNotations. Import AX2. Import AP.
Open Scope Z_scope.

Definition startup2_plan_r0_1 : plan :=
  PRun [0x3d4cc]
  (PJoin e_sp0 (-2280) 8
  (PRun []
  (PMmap
  (PSpin  )
  (PRun []
  (PMmap
  (PSpin  )
  (PRun []
  (PX XIMemcpy []
  (PRun []
  (PMmap
  (PSpin  )
  (PRun []
  (PX XIMemcpy []
  (PRun []
  (PX XIMemcpy []
  (PRun []
  (PX XMemset []
  (PRun []
  (PX XMemset []
  (PRun [0x7e18c]
  (PHavoc [5; 6; 7; 14; 15; 16; 17; 28; 29; 30; 31]%nat
  (PHandoff 1  )))))))))))))))))))).

Definition startup2_plan_r1_2 : plan :=
  PRun [0x3d4cc]
  (PJoin e_sp0 (-2280) 8
  (PRun []
  (PMmap
  (PSpin  )
  (PRun []
  (PMmap
  (PSpin  )
  (PRun []
  (PX XIMemcpy []
  (PRun []
  (PMmap
  (PSpin  )
  (PRun []
  (PX XIMemcpy []
  (PRun []
  (PX XIMemcpy []
  (PRun []
  (PX XMemset []
  (PRun []
  (PX XMemset []
  (PRun [0x7e18c]
  (PHavoc [5; 6; 7; 14; 15; 16; 17; 28; 29; 30; 31]%nat
  (PHandoff 2  )))))))))))))))))))).

Definition startup2_plan : plan :=
  PBump 453
  (PSplit (eaddz (esub (escale 16 (EVar 6)) (escale 4096 (EVar 344))) 3935) 4030
  (startup2_plan_r0_1)
  (startup2_plan_r1_2)).

Definition startup2_plan_ranges : list (Z * nat) := [(0x2f984, 102908%nat)]%Z.
