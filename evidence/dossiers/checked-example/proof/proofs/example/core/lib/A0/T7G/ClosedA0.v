(* example/core: pupnp's A0/T7G/ClosedA0.v, with the harness contract taken without IC (see GlueInst.v). *)
(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith List.
From LinuxProcessSemantics.EquivalenceDefinition Require Import Equivalence.
From LinuxProcessSemantics.LinuxProcessSem Require Import Run.
From OssFuzzTheorems.Proofs.example.core.lib.Top Require Import ShapeP0.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7 Require Import A0Prog.
From OssFuzzTheorems.Proofs.example.core.lib.A0.AW Require PZDef H_fuzz.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7G Require FinalA0 GlueInst.

Theorem fuzzhttp_asan_error_free : strong_universal_error_free_T_scfg (mkSpuriousCfg false true true true true true) imgP0 imgA0.
Proof.
  apply FinalA0.fuzzhttp_asan_error_free_final.
  apply (GlueInst.INST_of_FZ PZDef.PZ).
  intros HC HG FI AI J AC ASL AMS.
  exact (@H_fuzz.fuzz_one_spec_A HC HG FI AI J AC ASL AMS).
Qed.

