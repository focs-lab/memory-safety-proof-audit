(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Export STRW_merge STRW_tac.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Export Segs F_memcpy.
