(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* example/core: regenerated from OUR final start-up hints (StartupHS2Asan.v) by replay/port/gen_mainfacts.py;
   the lemma section below is pupnp's, unchanged. *)
From Stdlib Require Import ZArith List Bool.
From OssFuzzTheorems.Proofs.example.core.lib.ASN Require Import AxSymExec3 AsanPlan MainExport StartupHS2Asan.
Import ListNotations. Import AX2. Import AP.
Open Scope Z_scope.

Definition asan_mem_facts : list mfact := [
  MCell (ZLit 637360) 8 (ZLit 0)
  ; MCell (ZLit 637296) 1 (ZLit 1)
  ; MCell (ZLit 633416) 1 (ZLit 1)
  ; MCell (ZLit 633408) 8 (ZLit 1)
  ; MFill (ZLit 2147530044) 8 249
  ; MCell (ZLit 637312) 8 (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19904))
  ; MCell (ZLit 637304) 8 (ZLit 1)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19912)) 8 (ZLit 0)
  ; MCell (ZLit 637320) 8 (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19904))
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19904)) 8 (ZLit 633312)
  ; MCell (ZLit 1180496) 8 (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19920))
  ; MFill (ZLit 2147527604) 64 249
  ; MCell (ZMul (ZLit 4096) (ZV 471)) 8 (ZLit 12297829379609722881)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 471)) (ZLit 8)) 8 (ZLit 633312)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 471)) (ZLit 16)) 8 (ZLit 633312)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19896)) 8 (ZLit 1)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19888)) 8 (ZLit 4096)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19880)) 8 (ZMul (ZLit 4096) (ZV 471))
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 471)) (ZLit 2147450880)) 512
  ; MWr (ZMul (ZLit 4096) (ZV 471)) 4096
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 471)) (ZLit 24)) 4072
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 471)) (ZLit 24)) 4072
  ; MCell (ZLit 637328) 8 (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19880))
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 453)) (ZLit 24)) 4 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 453)) (ZLit 28)) 4 (ZLit 1)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 454)) (ZLit 8)) 8 (ZLit 250988)
  ; MCell (ZLit 1507300) 1 (ZLit 0)
  ; MCell (ZLit 1507288) 8 (ZMul (ZLit 4096) (ZV 454))
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 454)) (ZLit 2147450880)) 1048576
  ; MZeroC (ZAdd (ZMul (ZLit 512) (ZV 454)) (ZLit 2147450880)) 1048576
  ; MZero (ZAdd (ZMul (ZLit 512) (ZV 454)) (ZLit 2147450880)) 1048576
  ; MWr (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; MCell (ZLit 1507280) 8 (ZLit 8388608)
  ; MRo (ZLit 1507301) 3 (ZLit 0)
  ; MCell (ZLit 5767136) 1 (ZLit 0)
  ; MCell (ZLit 5767144) 8 (ZMul (ZLit 4096) (ZV 453))
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 453)) (ZLit 2147450880)) 131072
  ; MZeroC (ZAdd (ZMul (ZLit 512) (ZV 453)) (ZLit 2147450880)) 131072
  ; MZero (ZAdd (ZMul (ZLit 512) (ZV 453)) (ZLit 2147450880)) 131072
  ; MWr (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; MZeroC (ZMul (ZLit 4096) (ZV 453)) 16
  ; MZero (ZMul (ZLit 4096) (ZV 453)) 16
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 453)) (ZLit 32)) 1048544
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 453)) (ZLit 32)) 1048544
  ; MRo (ZLit 5767137) 3 (ZLit 0)
  ; MCell (ZLit 5767128) 4 (ZLit 1)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 3168)) 1 (ZLit 0)
  ; MCell (ZLit 650714) 1 (ZLit 0)
  ; MCell (ZLit 651584) 8 (ZLit 651648)
  ; MZeroC (ZLit 651688) 5
  ; MZero (ZLit 651688) 5
  ; MCell (ZLit 651680) 8 (ZLit 0)
  ; MCell (ZLit 651752) 1 (ZLit 1)
  ; MCell (ZLit 651672) 8 (ZLit 0)
  ; MCell (ZLit 651664) 8 (ZLit 0)
  ; MCell (ZLit 651656) 4 (ZLit 5)
  ; MCell (ZLit 651648) 8 (ZLit 622488)
  ; MCell (ZLit 6031152) 1 (ZLit 0)
  ; MCell (ZLit 6031153) 1 (ZLit 1)
  ; MCell (ZLit 6030976) 8 (ZLit 6031040)
  ; MZeroC (ZLit 6031080) 38
  ; MZero (ZLit 6031080) 38
  ; MCell (ZLit 6031072) 8 (ZLit 0)
  ; MCell (ZLit 6031144) 1 (ZLit 1)
  ; MCell (ZLit 6031064) 8 (ZLit 0)
  ; MCell (ZLit 6031056) 8 (ZLit 0)
  ; MCell (ZLit 6031048) 4 (ZLit 38)
  ; MCell (ZLit 6031040) 8 (ZLit 632168)
  ; MCell (ZLit 6031154) 2 (ZLit 0)
  ; MCell (ZLit 6231424) 8 (ZLit 10)
  ; MCell (ZLit 6231528) 8 (ZLit 2)
  ; MCell (ZLit 6231560) 8 (ZLit 2)
  ; MCell (ZLit 6231592) 8 (ZLit 2)
  ; MCell (ZLit 6230956) 4 (ZLit 1)
  ; MCell (ZLit 6231856) 1 (ZLit 1)
  ; MCell (ZLit 6230976) 8 (ZLit 97)
  ; MCell (ZLit 6230984) 8 (ZLit 0)
  ; MCell (ZLit 6230952) 4 (ZLit 1)
  ; MCell (ZLit 651888) 8 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 120)) 4 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 112)) 4 (ZLit 2)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 32)) 8 (ZLit 0)
  ; MCell (ZLit 651928) 8 (ZLit 1)
  ; MCell (ZLit 6099088) 8 (ZMul (ZLit 4096) (ZV 377))
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 72)) 8 (ZMul (ZLit 4096) (ZV 377))
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 377)) (ZLit 88)) 8 (ZLit 20)
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 377)) (ZLit 2147450880)) 1446400
  ; MZeroC (ZAdd (ZMul (ZLit 512) (ZV 377)) (ZLit 2147450880)) 1446400
  ; MZero (ZAdd (ZMul (ZLit 512) (ZV 377)) (ZLit 2147450880)) 1446400
  ; MWr (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; MZeroC (ZMul (ZLit 4096) (ZV 377)) 88
  ; MZero (ZMul (ZLit 4096) (ZV 377)) 88
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 377)) (ZLit 96)) 11571104
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 377)) (ZLit 96)) 11571104
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 64)) 8 (ZLit 6099096)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 16)) 8 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 4096) (ZV 10)) (ZMul (ZLit 4096) (ZV 344)))) (ZLit (-8388608)))
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 8)) 8 (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 4096) (ZV 10)) (ZMul (ZLit 4096) (ZV 344))))
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 56)) 8 (ZLit 6101156)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 48)) 8 (ZLit 6100936)
  ; MCell (ZLit 1244808) 1 (ZLit 1)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 310)) (ZLit 32)) 8 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 310)) (ZLit 24)) 8 (ZLit 6099088)
  ; MCell (ZLit 634176) 1 (ZLit 0)
  ; MRo (ZLit 634177) 3 (ZLit 0)
  ; MCell (ZLit 1244728) 8 (ZLit 1)
  ; MCell (ZLit 6099096) 8 (ZMul (ZLit 4096) (ZV 310))
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 310)) (ZLit 2147450880)) 512
  ; MZeroC (ZAdd (ZMul (ZLit 512) (ZV 310)) (ZLit 2147450880)) 512
  ; MZero (ZAdd (ZMul (ZLit 512) (ZV 310)) (ZLit 2147450880)) 512
  ; MWr (ZMul (ZLit 4096) (ZV 310)) 4096
  ; MZeroC (ZMul (ZLit 4096) (ZV 310)) 24
  ; MZero (ZMul (ZLit 4096) (ZV 310)) 24
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 310)) (ZLit 40)) 4056
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 310)) (ZLit 40)) 4056
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 40)) 1 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 32)) 8 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 24)) 8 (ZLit 0)
  ; MCell (ZLit 6098938) 1 (ZLit 1)
  ; MCell (ZLit 6235192) 8 (ZMul (ZLit 4096) (ZV 228))
  ; MCell (ZMul (ZLit 4096) (ZV 227)) 8 (ZMul (ZLit 4096) (ZV 228))
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 152)) 8 (ZMul (ZLit 4096) (ZV 227))
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 116)) 1 (ZLit 1)
  ; MCell (ZLit 651904) 8 (ZLit 1)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 40)) 8 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 16)) 8 (ZLit 0)
  ; MCell (ZLit 651920) 8 (ZLit 1)
  ; MCell (ZLit 651912) 8 (ZLit 1)
  ; MCell (ZMul (ZLit 4096) (ZV 245)) 8 (ZMul (ZLit 4096) (ZV 228))
  ; MCell (ZLit 651952) 8 (ZLit 1)
  ; MCell (ZLit 651944) 8 (ZLit 4096)
  ; MCell (ZLit 651936) 8 (ZMul (ZLit 4096) (ZV 245))
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 245)) (ZLit 2147450880)) 512
  ; MZeroC (ZAdd (ZMul (ZLit 512) (ZV 245)) (ZLit 2147450880)) 512
  ; MZero (ZAdd (ZMul (ZLit 512) (ZV 245)) (ZLit 2147450880)) 512
  ; MWr (ZMul (ZLit 4096) (ZV 245)) 4096
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 245)) (ZLit 8)) 4088
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 245)) (ZLit 8)) 4088
  ; MCell (ZLit 651784) 8 (ZLit 0)
  ; MCell (ZMul (ZLit 4096) (ZV 228)) 8 (ZLit 610888)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 148)) 2 (ZLit 1024)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 144)) 4 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 24)) 4 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 8)) 4 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 48)) 1 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 136)) 8 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 128)) 4 (ZLit 0)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 124)) 4 (ZLit 0)
  ; MCell (ZLit 651808) 8 (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 160))
  ; MFill (ZAdd (ZMul (ZLit 512) (ZV 228)) (ZLit 2147450880)) 8192 254
  ; MCell (ZLit 651800) 8 (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 65536))
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 228)) (ZLit 2147450880)) 8192
  ; MZeroC (ZAdd (ZMul (ZLit 512) (ZV 228)) (ZLit 2147459072)) 0
  ; MZero (ZAdd (ZMul (ZLit 512) (ZV 228)) (ZLit 2147459072)) 0
  ; MWr (ZMul (ZLit 4096) (ZV 228)) 65536
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 12)) 4
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 12)) 4
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 28)) 4
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 28)) 4
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 49)) 63
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 49)) 63
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 117)) 3
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 117)) 3
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 132)) 4
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 132)) 4
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 150)) 2
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 150)) 2
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 160)) 65376
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 160)) 65376
  ; MCell (ZLit 651856) 4 (ZLit 0)
  ; MCell (ZLit 651848) 4 (ZLit 0)
  ; MCell (ZLit 651840) 8 (ZLit 0)
  ; MCell (ZLit 651832) 8 (ZLit 0)
  ; MCell (ZLit 651776) 8 (ZLit 651816)
  ; MCell (ZLit 651760) 1 (ZLit 1)
  ; MCell (ZLit 651828) 4 (ZLit 0)
  ; MCell (ZLit 651824) 4 (ZLit 0)
  ; MCell (ZLit 651816) 8 (ZLit 0)
  ; MCell (ZLit 651860) 4 (ZLit 0)
  ; MCell (ZLit 651852) 4 (ZLit 0)
  ; MCell (ZLit 651768) 8 (ZLit 651864)
  ; MCell (ZLit 651992) 8 (ZLit 0)
  ; MCell (ZLit 651984) 8 (ZLit 0)
  ; MCell (ZLit 651976) 8 (ZLit 0)
  ; MCell (ZLit 651968) 8 (ZLit 0)
  ; MCell (ZLit 651960) 8 (ZLit 0)
  ; MCell (ZLit 652024) 4 (ZLit 0)
  ; MCell (ZLit 652016) 8 (ZLit 0)
  ; MCell (ZLit 652008) 8 (ZLit 0)
  ; MCell (ZLit 652000) 8 (ZLit 0)
  ; MCell (ZLit 651900) 4 (ZLit 0)
  ; MCell (ZLit 651896) 4 (ZLit 0)
  ; MCell (ZLit 651880) 4 (ZLit 0)
  ; MCell (ZLit 651872) 8 (ZLit 18446744073709551615)
  ; MCell (ZLit 651864) 8 (ZLit 375664)
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 227)) (ZLit 2147450880)) 512
  ; MWr (ZMul (ZLit 4096) (ZV 227)) 4096
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 41)) 7
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 41)) 7
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 80)) 3088
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 80)) 3088
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 3169)) 927
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 3169)) 927
  ; MCell (ZLit 1244768) 8 (ZLit 449516)
  ; MCell (ZLit 6230248) 4 (ZLit 1)
  ; MCell (ZLit 6230528) 8 (ZLit 449516)
  ; MCell (ZLit 6230272) 8 (ZLit 545236)
  ; MCell (ZLit 6230256) 8 (ZLit 6230264)
  ; MCell (ZLit 1245080) 1 (ZLit 0)
  ; MCell (ZLit 650712) 1 (ZLit 1)
  ; MCell (ZLit 650713) 1 (ZLit 1)
  ; MCell (ZLit 637112) 8 (ZLit 1099511627776)
  ; MCell (ZLit 637122) 2 (ZLit 2048)
  ; MCell (ZLit 637120) 2 (ZLit 16)
  ; MCell (ZLit 637124) 1 (ZLit 1)
  ; MCell (ZLit 634377) 1 (ZLit 0)
  ; MCell (ZLit 634376) 1 (ZLit 0)
  ; MCell (ZLit 634304) 8 (ZLit 1048576)
  ; MCell (ZLit 634296) 8 (ZLit 241591905)
  ; MCell (ZLit 634288) 8 (ZLit 268435456)
  ; MCell (ZLit 633568) 8 (ZMul (ZLit 4096) (ZV 226))
  ; MCell (ZLit 633592) 8 (ZLit 102775)
  ; MCell (ZLit 633584) 8 (ZLit 8388608)
  ; MCell (ZLit 633576) 8 (ZMul (ZLit 4096) (ZV 226))
  ; MCell (ZLit 633560) 8 (ZLit 4096)
  ; MCell (ZLit 633536) 4 (ZLit 18446744073709551615)
  ; MCell (ZLit 650872) 8 (ZLit 4096)
  ; MCell (ZLit 650864) 8 (ZLit 1)
  ; MWr (ZAdd (ZAdd (ZMul (ZLit 512) (ZV 208)) (ZMul (ZLit (-512)) (ZV 209))) (ZLit 19327328256)) 512
  ; MWr (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 208)) (ZMul (ZLit (-4096)) (ZV 209))) (ZLit 137439019008)) 4096
  ; MZeroC (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 208)) (ZMul (ZLit (-4096)) (ZV 209))) (ZLit 137439019008)) 4096
  ; MZero (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 208)) (ZMul (ZLit (-4096)) (ZV 209))) (ZLit 137439019008)) 4096
  ; MCell (ZLit 633544) 8 (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 208)) (ZMul (ZLit (-4096)) (ZV 209))) (ZLit 137439019008))
  ; MCell (ZLit 633528) 8 (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 208)) (ZMul (ZLit (-4096)) (ZV 209))) (ZLit 65536))
  ; MCell (ZLit 633512) 8 (ZLit 92794)
  ; MCell (ZLit 633504) 8 (ZLit 137439023104)
  ; MCell (ZLit 633496) 8 (ZMul (ZLit 4096) (ZV 208))
  ; MCell (ZLit 633552) 1 (ZLit 0)
  ; MCell (ZLit 1180513) 1 (ZLit 1)
  ; MCell (ZLit 6235136) 4 (ZLit 0)
  ; MCell (ZLit 6234104) 8 (ZLit 338772)
  ; MCell (ZLit 6235128) 4 (ZLit 0)
  ; MCell (ZLit 645476) 4 (ZLit 0)
  ; MCell (ZLit 6099000) 8 (ZLit 6235192)
  ; MCell (ZLit 645472) 1 (ZLit 1)
  ; MCell (ZLit 647416) 8 (ZLit 2147450880)
  ; MCell (ZLit 645434) 1 (ZLit 1)
  ; MCell (ZLit 645432) 1 (ZLit 1)
  ; MCell (ZLit 645436) 4 (ZLit 299)
  ; MCell (ZLit 645448) 8 (ZMul (ZLit 4096) (ZV 207))
  ; MCell (ZLit 645440) 8 (ZLit 645448)
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 207)) (ZLit 2147450880)) 465920
  ; MWr (ZMul (ZLit 4096) (ZV 207)) 3727360
  ; MZeroC (ZMul (ZLit 4096) (ZV 207)) 3727360
  ; MZero (ZMul (ZLit 4096) (ZV 207)) 3727360
  ; MCell (ZLit 645433) 1 (ZLit 1)
  ; MCell (ZLit 1180504) 8 (ZLit 359524)
  ; MCell (ZLit 622544) 8 (ZLit 8)
  ; MCell (ZLit 647424) 4 (ZLit 1)
  ; MCell (ZLit 1244192) 1 (ZLit 0)
  ; MCell (ZLit 622568) 4 (ZLit 2)
  ; MRo (ZLit 1244193) 3 (ZLit 0)
  ; MCell (ZLit 1244688) 8 (ZLit 339288)
  ; MCell (ZLit 1244752) 8 (ZLit 359384)
  ; MCell (ZLit 1244760) 8 (ZLit 359152)
  ; MCell (ZLit 650720) 8 (ZLit 140737488355327)
  ; MCell (ZLit 650748) 4 (ZLit 30)
  ; MCell (ZLit 645468) 1 (ZLit 1)
  ; MCell (ZLit 645464) 4 (ZLit 2)
  ; MCell (ZLit 637254) 1 (ZLit 1)
  ; MCell (ZLit 1244200) 8 (ZLit 1)
  ; MCell (ZLit 1244208) 8 (ZLit 0)
  ; MCell (ZLit 1244216) 8 (ZLit 0)
  ; MCell (ZLit 1244224) 8 (ZLit 81479)
  ; MCell (ZLit 1244232) 8 (ZLit 128849084416)
  ; MCell (ZLit 1244240) 8 (ZLit 0)
  ; MCell (ZLit 1244248) 8 (ZLit 0)
  ; MCell (ZLit 1244256) 8 (ZLit 0)
  ; MCell (ZLit 1244264) 8 (ZLit 0)
  ; MCell (ZLit 1244272) 8 (ZLit 1103823372545)
  ; MCell (ZLit 1244280) 8 (ZLit 4294967296)
  ; MCell (ZLit 1244288) 8 (ZLit 0)
  ; MCell (ZLit 1244296) 8 (ZLit 0)
  ; MCell (ZLit 1244304) 8 (ZLit 0)
  ; MCell (ZLit 1244312) 8 (ZLit 65537)
  ; MCell (ZLit 1244320) 8 (ZLit 18446744073709551615)
  ; MCell (ZLit 1244328) 8 (ZLit 71663)
  ; MCell (ZLit 1244336) 8 (ZLit 256)
  ; MCell (ZLit 1244344) 8 (ZLit 0)
  ; MCell (ZLit 1244352) 8 (ZLit 0)
  ; MCell (ZLit 1244360) 8 (ZLit 0)
  ; MCell (ZLit 1244368) 8 (ZLit 0)
  ; MCell (ZLit 1244376) 8 (ZLit 18446744069414584320)
  ; MCell (ZLit 1244384) 8 (ZLit 1)
  ; MCell (ZLit 1244392) 8 (ZLit 82339)
  ; MCell (ZLit 1244400) 8 (ZLit 81479)
  ; MCell (ZLit 1244408) 8 (ZLit 81479)
  ; MCell (ZLit 1244416) 8 (ZLit 1103823372544)
  ; MCell (ZLit 1244424) 8 (ZLit 0)
  ; MCell (ZLit 1244432) 8 (ZLit 121108)
  ; MCell (ZLit 1244440) 8 (ZLit 72339073309605888)
  ; MCell (ZLit 1244448) 8 (ZLit 72340172838076673)
  ; MCell (ZLit 1244456) 8 (ZLit 16843009)
  ; MCell (ZLit 1244464) 8 (ZLit 1103806595073)
  ; MCell (ZLit 1244472) 8 (ZLit 101104)
  ; MCell (ZLit 1244480) 8 (ZLit 281474976710912)
  ; MCell (ZLit 637184) 4 (ZLit 1024)
  ; MCell (ZLit 637180) 4 (ZLit 256)
  ; MCell (ZLit 1235864) 4 (ZLit 0)
  ; MCell (ZLit 6031176) 2 (ZLit 0)
  ; MCell (ZLit 6031168) 8 (ZLit 81479)
  ; MCell (ZLit 6031160) 2 (ZLit 0)
  ; MCell (ZLit 6030568) 4 (ZLit 1)
  ; MCell (ZLit 6030544) 4 (ZLit 257)
  ; MCell (ZLit 6030536) 8 (ZLit 72340172821233664)
  ; MCell (ZLit 6030532) 4 (ZLit 0)
  ; MCell (ZLit 6030528) 1 (ZLit 0)
  ; MCell (ZLit 6030560) 8 (ZLit 81479)
  ; MCell (ZLit 6030552) 4 (ZLit 1)
  ; MCell (ZLit 6030550) 1 (ZLit 0)
  ; MCell (ZLit 6030548) 2 (ZLit 0)
  ; MCell (ZLit 637266) 1 (ZLit 0)
  ; MCell (ZLit 637196) 1 (ZLit 0)
  ; MCell (ZLit 637280) 8 (ZLit 81479)
  ; MCell (ZLit 637276) 4 (ZLit 2)
  ; MCell (ZLit 637272) 1 (ZLit 1)
  ; MCell (ZLit 637268) 4 (ZLit 0)
  ; MCell (ZLit 637264) 2 (ZLit 1)
  ; MCell (ZLit 637256) 8 (ZLit 72340172838010881)
  ; MRo (ZLit 637248) 6 (ZLit 4294967296)
  ; MCell (ZLit 637255) 1 (ZLit 0)
  ; MCell (ZLit 637220) 4 (ZLit 4096)
  ; MCell (ZLit 637216) 1 (ZLit 0)
  ; MCell (ZLit 637208) 8 (ZLit 85899345936)
  ; MCell (ZLit 637200) 8 (ZLit 72340168526266369)
  ; MCell (ZLit 637192) 4 (ZLit 2048)
  ; MCell (ZLit 637240) 8 (ZLit 0)
  ; MCell (ZLit 637236) 1 (ZLit 1)
  ; MCell (ZLit 637232) 4 (ZLit 85)
  ; MCell (ZLit 637224) 8 (ZLit 816043786240)
  ; MCell (ZLit 637188) 4 (ZLit 16)
  ; MCell (ZLit 637176) 4 (ZLit 4294967295)
  ; MCell (ZLit 637288) 4 (ZLit 65793)
  ; MCell (ZLit 1180488) 8 (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 65536))
  ; MWr (ZAdd (ZMul (ZLit 512) (ZV 78)) (ZLit 2147450880)) 8192
  ; MWr (ZMul (ZLit 4096) (ZV 78)) 65536
  ; MCell (ZLit 1235872) 8 (ZLit 4096)
  ; MCell (ZLit 650744) 1 (ZLit 1)
  ; MWrS (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; MZeroS (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; MWr (ZLit 2147459072) 771584
  ; MZeroC (ZLit 2147459072) 68532
  ; MZero (ZLit 2147459072) 68532
  ; MZeroC (ZLit 2147527668) 2376
  ; MZero (ZLit 2147527668) 2376
  ; MZeroC (ZLit 2147530052) 700604
  ; MZero (ZLit 2147530052) 700604
  ; MCell (ZLit 1235856) 8 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-160)))
  ; MCell (ZLit 622552) 8 (ZLit 131448)
  ; MCell (ZLit 650715) 1 (ZLit 0)
  ; MCell (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-40))) 8 (ZLit 0)
  ; MCell (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-32))) 8 (ZLit 0)
  ; MCell (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-24))) 8 (ZLit 0)
  ; MCell (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-16))) 8 (ZLit 0)
  ; MCell (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8))) 8 (ZLit 0)
  ; MCell (ZLit 6099072) 8 (ZV 45)
  ; MRo (ZLit 6230224) 8 (ZV 45)
  ; MCell (ZLit 6098912) 8 (ZLit 0)
  ; MCell (ZLit 6098904) 8 (ZLit 6098888)
  ; MCell (ZLit 6098896) 8 (ZLit 6098888)
  ; MCell (ZLit 6099008) 8 (ZLit 6099008)
  ; MCell (ZLit 6099040) 8 (ZLit 6230872)
  ; MCell (ZLit 6098920) 4 (ZV 44)
  ; MCell (ZLit 6098928) 4 (ZLit 2)
  ; MCell (ZLit 6230816) 1 (ZLit 1)
  ; MCell (ZLit 6098888) 8 (ZLit 6098888)
  ; MCell (ZLit 6099080) 8 (ZLit 6099120)
  ; MCell (ZLit 6099120) 8 (ZLit 1)
  ; MCell (ZLit 6099128) 8 (ZLit 6101136)
  ; MCell (ZLit 6230848) 8 (ZLit 8)
  ; MCell (ZLit 6230840) 8 (ZLit 248)
  ; MCell (ZLit 6230216) 8 (ZLit 0)
  ; MCell (ZLit 6230200) 8 (ZLit 24)
  ; MCell (ZLit 6230856) 8 (ZLit 1)
  ; MCell (ZLit 6230832) 8 (ZLit 6230176)
  ; MCell (ZLit 6230208) 8 (ZLit 8)
  ; MCell (ZLit 6230192) 8 (ZLit 0)
  ; MCell (ZLit 6230184) 8 (ZLit 606584)
  ; MCell (ZLit 6230808) 8 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 184))
  ; MCell (ZLit 6230864) 8 (ZLit 4096)
  ; MCell (ZLit 6230920) 8 (ZV 9)
  ; MCell (ZLit 6230824) 8 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 24))
  ; MCell (ZLit 6098880) 8 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10))))) (ZLit 16))
  ; MCell (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-48))) 8 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit 8))
  ; MWr (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 8388608
  ; MRo (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) 8 (ZV 1)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit 8)) 8 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 184))
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit 16)) 8 (ZMul (ZLtu (ZLit 1) (ZV 1)) (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZV 3) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10))))))) (ZLit 185)))
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 24)) 8 (ZLit 3)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 32)) 8 (ZLit 65600)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 40)) 8 (ZLit 4)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 48)) 8 (ZLit 56)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 56)) 8 (ZLit 5)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 64)) 8 (ZLit 11)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 72)) 8 (ZLit 16)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 80)) 8 (ZV 9)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 88)) 8 (ZLit 6)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 96)) 8 (ZLit 4096)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 104)) 8 (ZLit 11)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 112)) 8 (ZV 8)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 120)) 8 (ZLit 12)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 128)) 8 (ZV 8)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 136)) 8 (ZLit 23)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 144)) 8 (ZLit 0)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 152)) 8 (ZLit 25)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 160)) 8 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 8) (ZV 4)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10))))))) (ZLit 184))
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 168)) 8 (ZLit 0)
  ; MRo (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))))) (ZLit 176)) 8 (ZLit 0)
  ; MImg 65536 622544
  ; MImg 622560 622568
  ; MImg 622572 633408
  ; MImg 633417 633496
  ; MImg 633520 633528
  ; MImg 633540 633544
  ; MImg 633553 633560
  ; MImg 633600 634176
  ; MImg 634180 634288
  ; MImg 634312 634376
  ; MImg 634378 637112
  ; MImg 637125 637176
  ; MImg 637197 637200
  ; MImg 637217 637220
  ; MImg 637237 637240
  ; MImg 637267 637268
  ; MImg 637273 637276
  ; MImg 637292 637296
  ; MImg 637297 637304
  ; MImg 637336 637360
  ; MImg 637368 637432
  ; MImg 642216 645432
  ; MImg 645435 645436
  ; MImg 645456 645464
  ; MImg 645469 645472
  ; MImg 645473 645476
  ; MImg 645480 647416
  ; MImg 647428 650712
  ; MImg 650716 650720
  ; MImg 650728 650744
  ; MImg 650745 650748
  ; MImg 650752 650864
  ; MImg 650880 651584
  ; MImg 651592 651648
  ; MImg 651660 651664
  ; MImg 651693 651752
  ; MImg 651753 651760
  ; MImg 651761 651768
  ; MImg 651792 651800
  ; MImg 651884 651888
  ; MImg 652028 1180488
  ; MImg 1180512 1180513
  ; MImg 1180514 1235856
  ; MImg 1235868 1235872
  ; MImg 1235880 1235904
  ; MImg 1239999 1240000
  ; MImg 1244095 1244192
  ; MImg 1244196 1244200
  ; MImg 1244488 1244688
  ; MImg 1244696 1244728
  ; MImg 1244736 1244752
  ; MImg 1244776 1244808
  ; MImg 1244809 1245080
  ; MImg 1245081 1507272
  ; MImg 5767132 5767136
  ; MImg 5767140 5767144
  ; MImg 5767152 6030528
  ; MImg 6030529 6030532
  ; MImg 6030551 6030552
  ; MImg 6030556 6030560
  ; MImg 6030572 6030976
  ; MImg 6030984 6031040
  ; MImg 6031052 6031056
  ; MImg 6031118 6031144
  ; MImg 6031145 6031152
  ; MImg 6031156 6031160
  ; MImg 6031162 6031168
  ; MImg 6031178 6098880
  ; MImg 6098924 6098928
  ; MImg 6098932 6098938
  ; MImg 6098939 6099000
  ; MImg 6099016 6099040
  ; MImg 6099048 6099072
  ; MImg 6099104 6099120
  ; MImg 6099136 6230184
  ; MImg 6230232 6230248
  ; MImg 6230252 6230256
  ; MImg 6230264 6230272
  ; MImg 6230280 6230528
  ; MImg 6230536 6230800
  ; MImg 6230817 6230824
  ; MImg 6230872 6230920
  ; MImg 6230928 6230944
  ; MImg 6230960 6230968
  ; MImg 6231024 6231040
  ; MImg 6231048 6231144
  ; MImg 6231152 6231176
  ; MImg 6231184 6231208
  ; MImg 6231216 6231424
  ; MImg 6231432 6231528
  ; MImg 6231536 6231560
  ; MImg 6231568 6231592
  ; MImg 6231600 6231856
  ; MImg 6231857 6231864
  ; MImg 6231872 6234088
  ; MImg 6234096 6234104
  ; MImg 6234112 6235128
  ; MImg 6235132 6235136
  ; MImg 6235140 6235192
  ; MImg 6235200 6238208
  ; MWr (ZLit 610304) 5619920
  ; MWr (ZLit 6230232) 7976
  ; MZeroC (ZLit 637360) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 78)) (ZLit 19912)) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 453)) (ZLit 24)) 4
  ; MZeroC (ZLit 1507300) 1
  ; MZeroC (ZLit 1507301) 3
  ; MZeroC (ZLit 5767136) 1
  ; MZeroC (ZLit 5767137) 3
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 3168)) 1
  ; MZeroC (ZLit 650714) 1
  ; MZeroC (ZLit 651680) 8
  ; MZeroC (ZLit 651672) 8
  ; MZeroC (ZLit 651664) 8
  ; MZeroC (ZLit 6031152) 1
  ; MZeroC (ZLit 6031072) 8
  ; MZeroC (ZLit 6031064) 8
  ; MZeroC (ZLit 6031056) 8
  ; MZeroC (ZLit 6031154) 2
  ; MZeroC (ZLit 6230984) 8
  ; MZeroC (ZLit 651888) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 120)) 4
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 32)) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 310)) (ZLit 32)) 8
  ; MZeroC (ZLit 634176) 1
  ; MZeroC (ZLit 634177) 3
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 40)) 1
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 32)) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 227)) (ZLit 24)) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 40)) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 16)) 8
  ; MZeroC (ZLit 651784) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 144)) 4
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 24)) 4
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 8)) 4
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 48)) 1
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 136)) 8
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 128)) 4
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 228)) (ZLit 124)) 4
  ; MZeroC (ZLit 651856) 4
  ; MZeroC (ZLit 651848) 4
  ; MZeroC (ZLit 651840) 8
  ; MZeroC (ZLit 651832) 8
  ; MZeroC (ZLit 651828) 4
  ; MZeroC (ZLit 651824) 4
  ; MZeroC (ZLit 651816) 8
  ; MZeroC (ZLit 651860) 4
  ; MZeroC (ZLit 651852) 4
  ; MZeroC (ZLit 651992) 8
  ; MZeroC (ZLit 651984) 8
  ; MZeroC (ZLit 651976) 8
  ; MZeroC (ZLit 651968) 8
  ; MZeroC (ZLit 651960) 8
  ; MZeroC (ZLit 652024) 4
  ; MZeroC (ZLit 652016) 8
  ; MZeroC (ZLit 652008) 8
  ; MZeroC (ZLit 652000) 8
  ; MZeroC (ZLit 651900) 4
  ; MZeroC (ZLit 651896) 4
  ; MZeroC (ZLit 651880) 4
  ; MZeroC (ZLit 1245080) 1
  ; MZeroC (ZLit 634377) 1
  ; MZeroC (ZLit 634376) 1
  ; MZeroC (ZLit 633552) 1
  ; MZeroC (ZLit 6235136) 4
  ; MZeroC (ZLit 6235128) 4
  ; MZeroC (ZLit 645476) 4
  ; MZeroC (ZLit 1244192) 1
  ; MZeroC (ZLit 1244193) 3
  ; MZeroC (ZLit 1244208) 8
  ; MZeroC (ZLit 1244216) 8
  ; MZeroC (ZLit 1244240) 8
  ; MZeroC (ZLit 1244248) 8
  ; MZeroC (ZLit 1244256) 8
  ; MZeroC (ZLit 1244264) 8
  ; MZeroC (ZLit 1244288) 8
  ; MZeroC (ZLit 1244296) 8
  ; MZeroC (ZLit 1244304) 8
  ; MZeroC (ZLit 1244344) 8
  ; MZeroC (ZLit 1244352) 8
  ; MZeroC (ZLit 1244360) 8
  ; MZeroC (ZLit 1244368) 8
  ; MZeroC (ZLit 1244424) 8
  ; MZeroC (ZLit 1235864) 4
  ; MZeroC (ZLit 6031176) 2
  ; MZeroC (ZLit 6031160) 2
  ; MZeroC (ZLit 6030532) 4
  ; MZeroC (ZLit 6030528) 1
  ; MZeroC (ZLit 6030550) 1
  ; MZeroC (ZLit 6030548) 2
  ; MZeroC (ZLit 637266) 1
  ; MZeroC (ZLit 637196) 1
  ; MZeroC (ZLit 637268) 4
  ; MZeroC (ZLit 637255) 1
  ; MZeroC (ZLit 637216) 1
  ; MZeroC (ZLit 637240) 8
  ; MZeroC (ZLit 650715) 1
  ; MZeroC (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-40))) 8
  ; MZeroC (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-32))) 8
  ; MZeroC (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-24))) 8
  ; MZeroC (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-16))) 8
  ; MZeroC (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8))) 8
  ; MZeroC (ZLit 6098912) 8
  ; MZeroC (ZLit 6230216) 8
  ; MZeroC (ZLit 6230192) 8
].

Definition asan_pure_facts : list pfact := [
  PDisj (ZMul (ZLit 4096) (ZV 471)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 471 1 34359736319
  ; PDisj (ZMul (ZLit 4096) (ZV 471)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 471)) 4096 (ZLit 65536) 6172672
  ; PDisj (ZMul (ZLit 4096) (ZV 471)) 4096 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 454)) 8388608 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 453)) 1048576 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 377)) 11571200 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 471)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 454)) 8388608 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 454 1523 34359734272
  ; PDisj (ZMul (ZLit 4096) (ZV 454)) 8388608 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 454)) 8388608 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 453)) 1048576 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 377)) 11571200 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 454)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 453)) 1048576 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 453 1523 34359736064
  ; PDisj (ZMul (ZLit 4096) (ZV 453)) 1048576 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 453)) 1048576 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 377)) 11571200 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 453)) 1048576
  ; PVar 344 0 1
  ; PRange (ZAdd (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit (-4096)) (ZV 344))) (ZLit 3935)) 0 4095
  ; PVar 452 6238208 2153820160
  ; PVar 397 1 34359736319
  ; PVar 396 1 34359736319
  ; PVar 395 1 34359736319
  ; PVar 394 1523 524277
  ; PDisj (ZMul (ZLit 4096) (ZV 397)) 4096 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 396)) 4096 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 395)) 8192 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 394)) 8192 (ZLit 2147446784) 17592186048512
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 394)) (ZLit 2147450880)) 1024 (ZLit 2147459072) 771584
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 394)) (ZLit 2147450880)) (ZLit 1024) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 397)) (ZLit 2147450880)) 512 (ZLit 2147459072) 771584
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 397)) (ZLit 2147450880)) (ZLit 512) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 395)) (ZLit 2147450880)) 1024 (ZLit 2147459072) 771584
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 395)) (ZLit 2147450880)) (ZLit 1024) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 396)) (ZLit 2147450880)) 512 (ZLit 2147459072) 771584
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 396)) (ZLit 2147450880)) (ZLit 512) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PVar 396 1 34359736319
  ; PDisj (ZMul (ZLit 4096) (ZV 396)) 4096 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 395)) 8192 (ZLit 2147446784) 17592186048512
  ; PVar 394 1523 524277
  ; PVar 344 0 1
  ; PRange (ZAdd (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit (-4096)) (ZV 344))) (ZLit 3935)) 0 4095
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 377)) (ZLit 2147450880)) (ZLit 1446400) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 377)) (ZLit 2147450880)) 1446400 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 377)) 11571200 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 377 1523 34359733495
  ; PDisj (ZMul (ZLit 4096) (ZV 377)) 11571200 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 377)) 11571200 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 377)) 11571200
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 78)) (ZLit 2147450880)) 8192 (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) 512
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 207)) (ZLit 2147450880)) 465920 (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) 512
  ; PDisj (ZAdd (ZAdd (ZMul (ZLit 512) (ZV 208)) (ZMul (ZLit (-512)) (ZV 209))) (ZLit 19327328256)) 512 (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) 512
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 227)) (ZLit 2147450880)) 512 (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) 512
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 228)) (ZLit 2147450880)) 8192 (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) 512
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 245)) (ZLit 2147450880)) 512 (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) 512
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 310)) (ZLit 2147450880)) 512 (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) 512
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) (ZLit 512) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 311)) (ZLit 2147450880)) 512 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 311)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 311 1 34359736319
  ; PDisj (ZMul (ZLit 4096) (ZV 311)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 311)) 4096 (ZLit 65536) 6172672
  ; PDisj (ZMul (ZLit 4096) (ZV 311)) 4096 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZMul (ZLit 4096) (ZV 311)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZMul (ZLit 4096) (ZV 311)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZMul (ZLit 4096) (ZV 311)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZMul (ZLit 4096) (ZV 311)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 311)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 311)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 311)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 311)) 4096
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 310)) (ZLit 2147450880)) (ZLit 512) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 310)) (ZLit 2147450880)) 512 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 310 1 34359736319
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZLit 65536) 6172672
  ; PDisj (ZMul (ZLit 4096) (ZV 310)) 4096 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZMul (ZLit 4096) (ZV 310)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZMul (ZLit 4096) (ZV 310)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZMul (ZLit 4096) (ZV 310)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 310)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 310)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 310)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 310)) 4096
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 245)) (ZLit 2147450880)) (ZLit 512) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 245)) (ZLit 2147450880)) 512 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 245 1 34359736319
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZLit 65536) 6172672
  ; PDisj (ZMul (ZLit 4096) (ZV 245)) 4096 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZMul (ZLit 4096) (ZV 245)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZMul (ZLit 4096) (ZV 245)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 245)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 245)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 245)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 245)) 4096
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 228)) (ZLit 2147450880)) (ZLit 8192) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 228)) (ZLit 2147450880)) 8192 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 228 1523 34359736304
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 228)) 65536 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZMul (ZLit 4096) (ZV 228)) 65536
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 228)) 65536
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 228)) 65536
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 228)) 65536
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 228)) 65536
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 227)) (ZLit 2147450880)) (ZLit 512) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 227)) (ZLit 2147450880)) 512 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 227 1 34359736319
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZLit 65536) 6172672
  ; PDisj (ZMul (ZLit 4096) (ZV 227)) 4096 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZMul (ZLit 4096) (ZV 227)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 227)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 227)) 4096
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 227)) 4096
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 226)) (ZLit 2147450880)) (ZLit 1048576) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 226)) (ZLit 2147450880)) 1048576 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 226 1523 34359734272
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 226)) 8388608 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZMul (ZLit 4096) (ZV 226)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 226)) 8388608
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 226)) 8388608
  ; PVar 209 0 15
  ; PRange (ZAdd (ZMul (ZLit (-4096)) (ZV 209)) (ZAnd (ZMul (ZLit 4096) (ZV 208)) (ZLit 65535))) 0 0
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 208)) (ZLit 2147450880)) (ZLit 17179877888) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 208)) (ZLit 2147450880)) 17179877888 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 208 4295491576 34326181871
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 208)) 137439023104 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZMul (ZLit 4096) (ZV 208)) 137439023104
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 208)) 137439023104
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 207)) (ZLit 2147450880)) (ZLit 465920) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 207)) (ZLit 2147450880)) 465920 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 207 1523 34359735410
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 207)) 3727360 (ZLit 2147446784) 17592186048512
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZMul (ZLit 4096) (ZV 207)) 3727360
  ; PDisjS (ZAdd (ZMul (ZLit 512) (ZV 78)) (ZLit 2147450880)) (ZLit 8192) (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZMul (ZLit 512) (ZV 10))) (ZLit 2146402304)) (ZAdd (ZAdd (ZMul (ZLit (-4096)) (ZV 0)) (ZMul (ZLit (-512)) (ZV 10))) (ZLit 17592187092992))
  ; PDisj (ZAdd (ZMul (ZLit 512) (ZV 78)) (ZLit 2147450880)) 8192 (ZLit 2147459072) 771584
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) (ZLit (-8388608))) 12582912
  ; PVar 78 1523 34359736304
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608))) 140737496743936
  ; PDisj (ZMul (ZLit 4096) (ZV 78)) 65536 (ZLit 2147446784) 17592186048512
  ; PVar 44 1 4194303
  ; PVar 0 4294901760 4294967295
  ; PVar 6 0 255
  ; PVar 10 0 7
  ; PRange (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 8) (ZV 1)) (ZAdd (ZMul (ZLit 8) (ZV 2)) (ZAdd (ZMul (ZLit 8) (ZV 4)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10))))))) (ZLit 200)) 140735340871872 140737488355328
  ; PRange (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZAdd (ZV 1) (ZAdd (ZV 2) (ZAdd (ZV 4) (ZAdd (ZMul (ZLit 2) (ZV 6)) (ZMul (ZLit 512) (ZV 10))))))) 17591917608961 17592186044391
  ; PRange (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit 4096) (ZV 10)))) 140735340871680 140737488355136
  ; PRange (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) 140735340871680 140737488351232
  ; PRange (ZAdd (ZMul (ZLit 4096) (ZV 0)) (ZAdd (ZMul (ZLit 2) (ZV 6)) (ZMul (ZLit 512) (ZV 10)))) 17591917608960 17592186044392
  ; PVar 1 1 1024
  ; PVar 2 0 256
  ; PVar 3 0 131071
  ; PVar 7 0 131071
  ; PVar 8 0 4294967294
  ; PVar 9 0 4194303
  ; PVar 4 0 280000
  ; PVar 5 1523 525811
].

Definition asan_mem_facts_w1 : list mfact := [
  MCell (ZLit 5044304) 4 (ZLit 1)
  ; MCell (ZLit 1507296) 4 (ZLit 3)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 454)) (ZLit 16)) 8 (ZLit 255932)
  ; MCell (ZMul (ZLit 4096) (ZV 454)) 8 (ZLit 2)
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 454)) (ZLit 24)) 8388584
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 454)) (ZLit 24)) 8388584
  ; MCell (ZLit 1507272) 8 (ZLit 3)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 453)) (ZLit 16)) 8 (ZLit 9116173388371279390)
  ; MImg 1507304 5044304
  ; MImg 5044308 5767128
].

Definition asan_mem_facts_w2 : list mfact := [
  MCell (ZLit 5022588) 4 (ZLit 1)
  ; MCell (ZLit 1507296) 4 (ZLit 2)
  ; MCell (ZMul (ZLit 4096) (ZV 454)) 8 (ZLit 1)
  ; MZeroC (ZAdd (ZMul (ZLit 4096) (ZV 454)) (ZLit 16)) 8388592
  ; MZero (ZAdd (ZMul (ZLit 4096) (ZV 454)) (ZLit 16)) 8388592
  ; MCell (ZLit 1507272) 8 (ZLit 2)
  ; MCell (ZAdd (ZMul (ZLit 4096) (ZV 453)) (ZLit 16)) 8 (ZLit 12930139718377351401)
  ; MImg 1507304 5022588
  ; MImg 5022592 5767128
].

Definition asan_pure_facts_w1 : list pfact := [
  PRange (ZAdd (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit (-4096)) (ZV 344))) (ZLit 3935)) 0 4030
].

Definition asan_pure_facts_w2 : list pfact := [
  PRange (ZAdd (ZAdd (ZMul (ZLit 16) (ZV 6)) (ZMul (ZLit (-4096)) (ZV 344))) (ZLit 3935)) 4031 4095
].

Definition asan_vis_app : list (zexp * zexp) := [
  (ZMul (ZLit 4096) (ZV 471), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 454), ZLit 8388608)
  ; (ZMul (ZLit 4096) (ZV 453), ZLit 1048576)
  ; (ZMul (ZLit 4096) (ZV 377), ZLit 11571200)
  ; (ZMul (ZLit 4096) (ZV 310), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 245), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 228), ZLit 65536)
  ; (ZMul (ZLit 4096) (ZV 227), ZLit 4096)
  ; (ZAdd (ZAdd (ZMul (ZLit 4096) (ZV 208)) (ZMul (ZLit (-4096)) (ZV 209))) (ZLit 137439019008), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 207), ZLit 3727360)
  ; (ZMul (ZLit 4096) (ZV 78), ZLit 65536)
  ; (ZLit 65536, ZLit 6172672)
  ; (ZAdd (ZAdd (ZMul (ZLit 32768) (ZV 0)) (ZMul (ZLit 4096) (ZV 10))) (ZLit (-8388608)), ZAdd (ZAdd (ZMul (ZLit (-32768)) (ZV 0)) (ZMul (ZLit (-4096)) (ZV 10))) (ZLit 140737496743936))
].
Definition asan_ghost : list (zexp * zexp) := [
  (ZMul (ZLit 4096) (ZV 311), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 394), ZLit 8192)
  ; (ZAdd (ZMul (ZLit 4096) (ZV 395)) (ZLit 4096), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 396), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 397), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 394), ZLit 8192)
  ; (ZMul (ZLit 4096) (ZV 397), ZLit 4096)
  ; (ZAdd (ZMul (ZLit 4096) (ZV 395)) (ZLit 4096), ZLit 4096)
  ; (ZMul (ZLit 4096) (ZV 396), ZLit 4096)
].
Definition asan_vis : list (zexp * zexp) := asan_vis_app ++ asan_ghost.

Definition asan_ledger : list lentry := [
  LMap (ZMul (ZLit 4096) (ZV 471)) 4096 KRW
  ; LMap (ZMul (ZLit 4096) (ZV 454)) 8388608 KRWLAZY
  ; LMap (ZMul (ZLit 4096) (ZV 453)) 1048576 KRW
  ; LFog 8192
  ; LFog 8192
  ; LMap (ZMul (ZLit 4096) (ZV 377)) 11571200 KRW
  ; LMap (ZMul (ZLit 4096) (ZV 310)) 4096 KRW
  ; LMap (ZMul (ZLit 4096) (ZV 245)) 4096 KRW
  ; LMap (ZMul (ZLit 4096) (ZV 228)) 65536 KRW
  ; LMap (ZMul (ZLit 4096) (ZV 227)) 4096 KRW
  ; LMap (ZMul (ZLit 4096) (ZV 226)) 8388608 KNONELAZY
  ; LMap (ZMul (ZLit 4096) (ZV 208)) 137439023104 KRW
  ; LMap (ZMul (ZLit 4096) (ZV 207)) 3727360 KRW
  ; LMap (ZMul (ZLit 4096) (ZV 78)) 65536 KRW
  ; LMap (ZLit 2201439137792) 15392894357504 KRWLAZY
  ; LMap (ZLit 2415882240) 2199023255552 KNONELAZY
  ; LMap (ZLit 2147446784) 268435456 KRWLAZY
].

Definition asan_totsz : Z := 17729664532480.
Definition asan_ylo : Z := 23387528589312.
Definition asan_eager : Z := 16515072.
Definition asan_abytes : Z := 2460709888.

Lemma asan_mem_facts_justified_w1 :
  forallb (mjustify (s_know (a_ss HS_asan2_1)) (var_ranges (s_know (a_ss HS_asan2_1))) 65536 6238208) (asan_mem_facts ++ asan_mem_facts_w1) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma asan_pure_facts_justified_w1 :
  forallb (pjustify (s_know (a_ss HS_asan2_1)) (var_ranges (s_know (a_ss HS_asan2_1)))) (asan_pure_facts ++ asan_pure_facts_w1) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma asan_vis_justified_w1 :
  vis_match (var_ranges (s_know (a_ss HS_asan2_1))) (a_vis HS_asan2_1) asan_vis_app = true /\ vis_match (var_ranges (s_know (a_ss HS_asan2_1))) (a_ghost HS_asan2_1) asan_ghost = true.
Proof. split; vm_compute; reflexivity. Qed.
Lemma asan_ledger_justified_w1 :
  ledger_xmatch (var_ranges (s_know (a_ss HS_asan2_1))) (a_maps HS_asan2_1) asan_ledger = true.
Proof. vm_compute. reflexivity. Qed.
Lemma asan_consts_w1 : a_totsz HS_asan2_1 = asan_totsz /\ a_ylo HS_asan2_1 = asan_ylo /\ a_eager HS_asan2_1 = asan_eager /\ a_abytes HS_asan2_1 = asan_abytes.
Proof. repeat split; reflexivity. Qed.
Lemma asan_mem_facts_justified_w2 :
  forallb (mjustify (s_know (a_ss HS_asan2_2)) (var_ranges (s_know (a_ss HS_asan2_2))) 65536 6238208) (asan_mem_facts ++ asan_mem_facts_w2) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma asan_pure_facts_justified_w2 :
  forallb (pjustify (s_know (a_ss HS_asan2_2)) (var_ranges (s_know (a_ss HS_asan2_2)))) (asan_pure_facts ++ asan_pure_facts_w2) = true.
Proof. vm_compute. reflexivity. Qed.
Lemma asan_vis_justified_w2 :
  vis_match (var_ranges (s_know (a_ss HS_asan2_2))) (a_vis HS_asan2_2) asan_vis_app = true /\ vis_match (var_ranges (s_know (a_ss HS_asan2_2))) (a_ghost HS_asan2_2) asan_ghost = true.
Proof. split; vm_compute; reflexivity. Qed.
Lemma asan_ledger_justified_w2 :
  ledger_xmatch (var_ranges (s_know (a_ss HS_asan2_2))) (a_maps HS_asan2_2) asan_ledger = true.
Proof. vm_compute. reflexivity. Qed.
Lemma asan_consts_w2 : a_totsz HS_asan2_2 = asan_totsz /\ a_ylo HS_asan2_2 = asan_ylo /\ a_eager HS_asan2_2 = asan_eager /\ a_abytes HS_asan2_2 = asan_abytes.
Proof. repeat split; reflexivity. Qed.
