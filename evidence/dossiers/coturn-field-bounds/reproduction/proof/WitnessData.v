(* Machine-generated audit literals from the pinned coturn certificate; checked against the original decoder in Certificate.v. *)
From Stdlib Require Import ZArith List.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib Require Import VCert2 VCert VLinalg.
Import ListNotations. Open Scope Z_scope.
Definition asan_case : cstate2 := mkCS2 (mkCS [(1, (mkLin (578316) [])); (2, (mkLin (-1328240) [(1%positive, 1)])); (3, (mkLin (0) [(18%positive, 1)])); (4, (mkLin (6186480) [])); (8, (mkLin (-1328080) [(1%positive, 1)])); (9, (mkLin (-1328240) [(1%positive, 1)])); (10, (mkLin (1024) [])); (11, (mkLin (4) [])); (12, (mkLin (-1326953) [(1%positive, 1)])); (13, (mkLin (65506) [])); (14, (mkLin (-1326956) [(1%positive, 1)])); (18, (mkLin (-1) [])); (19, (mkLin (-1261448) [(1%positive, 1)])); (20, (mkLin (24) [])); (21, (mkLin (2147293199) [(64%positive, 1)])); (22, (mkLin (2147450880) [])); (23, (mkLin (1) [])); (24, (mkLin (20) [])); (25, (mkLin (0) [(96%positive, 1)])); (26, (mkLin (0) [(96%positive, 1)])); (27, (mkLin (2147450880) [(97%positive, 1)]))]
  [(-1328240, (8, (mkLin (-1261448) [(1%positive, 1)]))); (-1328232, (8, (mkLin (0) [(96%positive, 1)]))); (-1328224, (8, (mkLin (0) [(22%positive, 1)]))); (-1328216, (8, (mkLin (18) []))); (-1328192, (8, (mkLin (0) [(96%positive, 1)]))); (-1328184, (8, (mkLin (0) [(16%positive, 1)]))); (-1328176, (8, (mkLin (0) [(15%positive, 1)]))); (-1328168, (8, (mkLin (0) [(14%positive, 1)]))); (-1328160, (8, (mkLin (0) [(13%positive, 1)]))); (-1328152, (8, (mkLin (0) [(12%positive, 1)]))); (-1328144, (8, (mkLin (0) [(11%positive, 1)]))); (-1328136, (8, (mkLin (0) [(10%positive, 1)]))); (-1328128, (8, (mkLin (0) [(9%positive, 1)]))); (-1328120, (8, (mkLin (0) [(8%positive, 1)]))); (-1328112, (8, (mkLin (0) [(7%positive, 1)]))); (-1328104, (8, (mkLin (0) [(6%positive, 1)]))); (-1328096, (8, (mkLin (0) [(5%positive, 1)]))); (-1328088, (8, (mkLin (0) [(4%positive, 1)]))); (-1326955, (1, (mkLin (0) [(29%positive, 1)]))); (-1326954, (1, (mkLin (1024) []))); (-1326953, (1, (mkLin (4) []))); (-1326952, (1, (mkLin (33) []))); (-1326951, (1, (mkLin (18) []))); (-1326950, (1, (mkLin (164) []))); (-1326949, (1, (mkLin (66) []))); (-1326936, (1, (mkLin (0) []))); (-1326935, (1, (mkLin (6) []))); (-1326934, (1, (mkLin (0) []))); (-1326933, (1, (mkLin (0) [(30%positive, 1)]))); (-1261448, (8, (mkLin (0) [(27%positive, 1)])))]
  []
  [(22%positive, ((Some (1)), (Some (140737488355327)))); (24%positive, ((Some (1)), (Some (140737488355327)))); (25%positive, ((Some (2147717641)), (Some (17594332446697)))); (27%positive, ((Some (32)), (Some (100)))); (28%positive, ((Some (13)), (Some (81)))); (29%positive, ((Some (0)), (Some (255)))); (30%positive, ((Some (0)), (Some (63)))); (2%positive, ((Some (1)), (Some (9223372036854775807)))); (66%positive, ((Some (0)), (Some (140737476784128)))); (97%positive, ((Some (4608)), (Some (17592184733688)))); (96%positive, ((Some (36864)), (Some (140737477869504)))); (98%positive, ((Some (4096)), (Some (140737476820991)))); (3%positive, ((Some (1)), (Some (4096)))); (1%positive, ((Some (140735340867584)), (Some (140737488355328))))]
  [(22%positive, (8, 0)); (24%positive, (8, 0)); (2%positive, (16, 0)); (66%positive, (4096, 0)); (96%positive, (64, 0)); (1%positive, (32, 16))]
  [(mkLin (36864) [(66%positive, 1); (96%positive, -1)]); (mkLin (-1085376) [(66%positive, -1); (96%positive, 1)]); (mkLin (4096) [(66%positive, 1); (98%positive, -1)]); (mkLin (-36863) [(66%positive, -1); (98%positive, 1)]); (mkLin (0) [(96%positive, -1); (97%positive, 8)]); (mkLin (0) [(96%positive, 1); (97%positive, -8)]); (mkLin (-19) [(27%positive, 1); (28%positive, -1)])]
  [(-1326954, -1326954)]
  [] [] [] 99%positive)
  [(mkSR 64%positive 2147450880 (SK_shadow 1%positive) (-166920) (1) [(-166912, -166010)] [(-166912, (902, (mkLin (0) []))); (-165870, (17, (mkLin (0) []))); (-157681, (1, (mkLin (0) [])))] [] None); (mkSR 22%positive 0 SK_arg (0) (20) [] [] [] (Some (71%positive))); (mkSR 24%positive 0 SK_arg (0) (0) [] [] [] (Some (73%positive))); (mkSR 71%positive 2147450880 (SK_shadow 22%positive) (0) (3) [] [(0, (3, (mkLin (0) [])))] [] None); (mkSR 73%positive 2147450880 (SK_shadow 24%positive) (0) (0) [] [] [] None); (mkSR 96%positive 0 (SK_fake 0 98%positive) (0) (64) [(0, 64)] [(0, (8, (mkLin (1102416563) []))); (8, (8, (mkLin (92693) []))); (16, (8, (mkLin (577776) []))); (24, (8, (mkLin (-1328240) [(1%positive, 1)]))); (56, (8, (mkLin (0) [(98%positive, 1)])))] [] (Some (97%positive))); (mkSR 97%positive 2147450880 (SK_shadow 96%positive) (0) (8) [(0, 8)] [(0, (4, (mkLin (241) []))); (4, (1, (mkLin (1) []))); (5, (3, (mkLin (243) [])))] [] None); (mkSR 98%positive 0 (SK_flag 96%positive) (0) (1) [(0, 1)] [] [] None)]
  [(71%positive, ((mkLin (0) [(22%positive, 1)]), 8)); (73%positive, ((mkLin (0) [(24%positive, 1)]), 8)); (97%positive, ((mkLin (0) [(96%positive, 1)]), 8))]
  [96%positive].
Definition asan_nu : val := fun s => match s with
  | 1%positive => 140735340871696
  | 2%positive => 4194304
  | 3%positive => 1
  | 4%positive => 582532
  | 17%positive => 6186480
  | 22%positive => 35184373174304
  | 24%positive => 35184373174336
  | 25%positive => 2147717641
  | 27%positive => 32
  | 28%positive => 13
  | 64%positive => 17591917608962
  | 65%positive => 524288
  | 66%positive => 35184372088832
  | 67%positive => 4398046511104
  | 71%positive => 4398046646788
  | 73%positive => 4398046646792
  | 96%positive => 35184372125696
  | 97%positive => 4398046515712
  | 98%positive => 35184372092928
  | _ => 0 end.
Definition asan_rank : lin := (mkLin (12) []).
Definition asan_wstack : list (Z * Z) := [(-1326957, -1326932); (-1326924, -1326828); (-1261448, -1261440)].
Definition both_case : cstate2 := mkCS2 (mkCS [(1, (mkLin (575456) [])); (2, (mkLin (-1328208) [(1%positive, 1)])); (3, (mkLin (0) [(18%positive, 1)])); (4, (mkLin (6179760) [])); (8, (mkLin (-1328048) [(1%positive, 1)])); (9, (mkLin (-1328208) [(1%positive, 1)])); (10, (mkLin (12) [])); (11, (mkLin (20) [])); (12, (mkLin (1) [])); (13, (mkLin (4) [])); (14, (mkLin (11) [])); (15, (mkLin (2147293191) [(64%positive, 1)])); (18, (mkLin (12) [])); (19, (mkLin (-1261512) [(1%positive, 1)])); (20, (mkLin (2147450880) [])); (21, (mkLin (2147450880) [(96%positive, 1)])); (22, (mkLin (-1327020) [(1%positive, 1)])); (23, (mkLin (8) [])); (24, (mkLin (1) [])); (25, (mkLin (-1327021) [(1%positive, 1)])); (26, (mkLin (0) [(97%positive, 1)])); (27, (mkLin (0) [(97%positive, 1)]))]
  [(-1328208, (8, (mkLin (0) []))); (-1328200, (8, (mkLin (18) []))); (-1328192, (8, (mkLin (0) [(22%positive, 1)]))); (-1328184, (8, (mkLin (0) [(97%positive, 1)]))); (-1328160, (8, (mkLin (0) [(97%positive, 1)]))); (-1328152, (8, (mkLin (0) [(16%positive, 1)]))); (-1328144, (8, (mkLin (0) [(15%positive, 1)]))); (-1328136, (8, (mkLin (0) [(14%positive, 1)]))); (-1328128, (8, (mkLin (0) [(13%positive, 1)]))); (-1328120, (8, (mkLin (0) [(12%positive, 1)]))); (-1328112, (8, (mkLin (0) [(11%positive, 1)]))); (-1328104, (8, (mkLin (0) [(10%positive, 1)]))); (-1328096, (8, (mkLin (0) [(9%positive, 1)]))); (-1328088, (8, (mkLin (0) [(8%positive, 1)]))); (-1328080, (8, (mkLin (0) [(7%positive, 1)]))); (-1328072, (8, (mkLin (0) [(6%positive, 1)]))); (-1328064, (8, (mkLin (0) [(5%positive, 1)]))); (-1328056, (8, (mkLin (0) [(4%positive, 1)]))); (-1327019, (1, (mkLin (0) [(29%positive, 1)]))); (-1327018, (1, (mkLin (0) []))); (-1327017, (1, (mkLin (0) [(28%positive, 1)]))); (-1327016, (1, (mkLin (33) []))); (-1327015, (1, (mkLin (18) []))); (-1327014, (1, (mkLin (164) []))); (-1327013, (1, (mkLin (66) []))); (-1261512, (8, (mkLin (0) [(27%positive, 1)])))]
  []
  [(22%positive, ((Some (1)), (Some (140737488355327)))); (27%positive, ((Some (32)), (Some (100)))); (28%positive, ((Some (13)), (Some (81)))); (29%positive, ((Some (0)), (Some (255)))); (2%positive, ((Some (1)), (Some (9223372036854775807)))); (66%positive, ((Some (0)), (Some (140737476784128)))); (96%positive, ((Some (4608)), (Some (17592184733688)))); (97%positive, ((Some (36864)), (Some (140737477869504)))); (98%positive, ((Some (4096)), (Some (140737476820991)))); (3%positive, ((Some (1)), (Some (4096)))); (1%positive, ((Some (140735340867584)), (Some (140737488355328))))]
  [(22%positive, (8, 0)); (2%positive, (16, 0)); (66%positive, (4096, 0)); (97%positive, (64, 0)); (1%positive, (32, 16))]
  [(mkLin (36864) [(66%positive, 1); (97%positive, -1)]); (mkLin (-1085376) [(66%positive, -1); (97%positive, 1)]); (mkLin (4096) [(66%positive, 1); (98%positive, -1)]); (mkLin (-36863) [(66%positive, -1); (98%positive, 1)]); (mkLin (0) [(96%positive, 8); (97%positive, -1)]); (mkLin (0) [(96%positive, -8); (97%positive, 1)]); (mkLin (-19) [(27%positive, 1); (28%positive, -1)])]
  []
  [] [] [] 99%positive)
  [(mkSR 64%positive 2147450880 (SK_shadow 1%positive) (-166920) (1) [(-166912, -166006)] [(-166912, (906, (mkLin (0) []))); (-165878, (2, (mkLin (0) []))); (-165874, (11, (mkLin (0) []))); (-157689, (1, (mkLin (0) [])))] [] None); (mkSR 22%positive 0 SK_arg (0) (8) [] [] [] (Some (71%positive))); (mkSR 71%positive 2147450880 (SK_shadow 22%positive) (0) (1) [] [(0, (1, (mkLin (0) [])))] [] None); (mkSR 97%positive 0 (SK_fake 0 98%positive) (0) (64) [(0, 64)] [(0, (8, (mkLin (1102416563) []))); (8, (8, (mkLin (92745) []))); (16, (8, (mkLin (575032) []))); (24, (8, (mkLin (-1328208) [(1%positive, 1)]))); (56, (8, (mkLin (0) [(98%positive, 1)])))] [] (Some (96%positive))); (mkSR 96%positive 2147450880 (SK_shadow 97%positive) (0) (8) [(0, 8)] [(0, (4, (mkLin (241) []))); (4, (1, (mkLin (1) []))); (5, (3, (mkLin (243) [])))] [] None); (mkSR 98%positive 0 (SK_flag 97%positive) (0) (1) [(0, 1)] [] [] None)]
  [(71%positive, ((mkLin (0) [(22%positive, 1)]), 8)); (96%positive, ((mkLin (0) [(97%positive, 1)]), 8))]
  [97%positive].
Definition both_nu : val := fun s => match s with
  | 1%positive => 140735340871696
  | 2%positive => 4194304
  | 3%positive => 1
  | 4%positive => 579284
  | 17%positive => 6179760
  | 22%positive => 35184373174304
  | 27%positive => 32
  | 28%positive => 13
  | 64%positive => 17591917608962
  | 65%positive => 524288
  | 66%positive => 35184372088832
  | 67%positive => 4398046511104
  | 71%positive => 4398046646788
  | 96%positive => 4398046515712
  | 97%positive => 35184372125696
  | 98%positive => 35184372092928
  | _ => 0 end.
Definition both_rank : lin := (mkLin (14) []).
Definition both_wstack : list (Z * Z) := [(-1327021, -1327008); (-1326988, -1326904); (-1261512, -1261504)].
