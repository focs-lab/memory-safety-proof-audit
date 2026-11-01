(* Exact statements from reproduction/proof/Complete.v:56-68 and 127-139.
   Definitions and proofs are in the complete standalone reproduction bundle. *)
Theorem asan_decoded_case_admits_buf_minus_one :
 exists U nu regs mem,
  find (fun u => Z.eqb (u_vid (u1 u)) 752) asan_decoded = Some U /\
  select_case asan_decoded 752 0x8d348 = Some asan_case /\
  select_rank asan_decoded 752 0x8d348 = Some asan_rank /\
  gamma2 SEGSA (unit_params2 (genv_asan true) U) asan_E mem
    (load_cstate2 (unit_params2 (genv_asan true) U) asan_case 0x8d348 []) nu regs mem /\
  0 <= eval nu asan_rank /\
  bv_unsigned (asan_destination regs) = asan_buffer-1 /\
  bv_unsigned (asan_destination regs) < asan_buffer /\
  store_ok SEGSA mem (asan_destination regs) 1 = true /\
  rdn SEGSA mem (wordZ (0x7fff8000 + bv_unsigned (asan_destination regs)/8)) 1
    = Some [Z_to_bv 8 0].

Theorem both_decoded_case_admits_buf_minus_one :
 exists U nu regs mem,
  find (fun u => Z.eqb (u_vid (u1 u)) 845) both_decoded = Some U /\
  select_case both_decoded 845 0x8c93c = Some both_case /\
  select_rank both_decoded 845 0x8c93c = Some both_rank /\
  gamma2 SEGSB (unit_params2 (genv_both true) U) both_E mem
    (load_cstate2 (unit_params2 (genv_both true) U) both_case 0x8c93c []) nu regs mem /\
  0 <= eval nu both_rank /\
  bv_unsigned (both_destination regs) = both_buffer-1 /\
  bv_unsigned (both_destination regs) < both_buffer /\
  store_ok SEGSB mem (both_destination regs) 1 = true /\
  rdn SEGSB mem (wordZ (0x7fff8000 + bv_unsigned (both_destination regs)/8)) 1
    = Some [Z_to_bv 8 0].
