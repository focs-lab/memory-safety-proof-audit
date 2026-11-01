(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From stdpp Require Import gmap.
From OssFuzzTheorems.Proofs.example.core.lib.Spec Require Import STree Malloc MallocCtrl.
From OssFuzzTheorems.Proofs.example.core.lib.Malloc Require Import MallocRep MallocTree MallocFacts_A MallocHINV MallocFacts_AM MallocFacts_AS F_malloc_big.
Open Scope Z_scope.

