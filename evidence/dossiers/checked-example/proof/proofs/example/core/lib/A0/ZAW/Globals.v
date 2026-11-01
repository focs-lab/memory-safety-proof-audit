(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* example/core: pupnp's A0/ZAW/Globals.v with the table of OUR binary.  core.asan has exactly one instrumented
   global, `handlers` (static const, 2048 bytes + 512 redzone); its descriptor at __start_asan_globals = 0x9a9e0
   (read from the image): beg 0x955a0, size 0x800, size_with_redzone 0xa00, name 0x1474f, module 0x20c5b,
   has_dynamic_init 0, location 0, odr_indicator -1 (local linkage: no ODR check).  pupnp's table has 82. *)
From Stdlib Require Import ZArith List.
Import ListNotations.
Open Scope Z_scope.

Definition A0_GLOBALS : list (Z * Z * Z) := [
  (611744, 2560, 0)].

Definition A0_GLOBALS_FLAG : Z := 633408.

Definition A0_DESCS : list (Z * Z * Z * Z * Z * Z * Z * Z) := [
  (611744, 2048, 2560, 83791, 134235, 0, 0, 18446744073709551615)].
