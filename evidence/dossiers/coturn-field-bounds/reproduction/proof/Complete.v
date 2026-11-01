From Stdlib Require Import ZArith List Bool Lia.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import PropExec.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VLinalg VState VLogic VGamma VStepMemSound VState2 VGamma2 VCert VCert2.
From CoturnFieldAudit Require Import WitnessData Certificate Rank Support Model Pure Regions Ambient Structural Flags.
Import ListNotations. Open Scope Z_scope.
#[local] Existing Instance PropExec.fx0.

From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
 Require Import VDriver2 VGenv_asan VGenv_both.
Open Scope Z_scope.

Lemma asan_gamma1 SEGS :
 gamma SEGS (p1 asan_P) (ev1 asan_E) (zpatch asan_P asan_E asan_mem asan_mem)
  (v1 asan_A) asan_nu asan_regs asan_mem.
Proof.
 unfold gamma. split;[exact (proj1 asan_environment)|].
 split;[apply asan_MC|]. split;[apply gamma_fix2_fix,asan_fixed|].
 split;[apply asan_sat|].
 split;[exact (proj1 asan_side_defs)|].
 split;[exact (proj1 (proj2 asan_side_defs))|].
 split;[exact (proj2 (proj2 asan_side_defs))|].
 split;[apply asan_registers|]. split;[apply asan_slots|].
 split;[apply asan_globs|]. split;[apply asan_nulls|apply asan_below].
Qed.
Lemma asan_gamma2 SEGS :
 gamma2 SEGS asan_P asan_E asan_mem asan_A asan_nu asan_regs asan_mem.
Proof.
 unfold gamma2. split;[apply asan_gamma1|].
 split;[apply asan_environment|]. split;[apply asan_ambient_memory|].
 split;[apply asan_fixed|]. split;[apply asan_divdefs|].
 split;[apply asan_all_regions|]. split;[apply asan_live|].
 split;[apply asan_below2|]. split;[apply asan_globs2|].
 split;[apply asan_flags|apply asan_memo].
Qed.

(* The complete original gamma2 predicate, with the original unit parameters,
   including the original static tables and loaded-state constructor. *)
Theorem asan_complete_original_invariant SEGS :
 gamma2 SEGS asan_full_P asan_E asan_mem
  (load_cstate2 asan_full_P asan_case 0x8d348 [])
  asan_nu asan_regs asan_mem.
Proof.
 change (gamma2 SEGS asan_full_P asan_E asan_mem asan_A asan_nu asan_regs asan_mem).
 rewrite <- gamma_params_exact. exact (asan_gamma2 SEGS).
Qed.
Definition asan_buffer : Z := e_sp0 (ev1 asan_E) + (-1326956).
Definition asan_destination (regs : bvmap 5 word) : word := (getr regs 14 + getr regs 18)%bv.
Lemma asan_destination_word : asan_destination asan_regs = wordZ (asan_buffer-1).
Proof. apply bv_eq. vm_compute. reflexivity. Qed.

(* Countermodel to a field lower-bound entailment, not an input execution.
   The existential unit is selected directly from the published certificate. *)
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
Proof.
 pose proof asan_unit_settings_from_certificate as HM.
 destruct (find (fun u => Z.eqb (u_vid (u1 u)) 752) asan_decoded) as [U|] eqn:HU;
   [|discriminate].
 cbn in HM. assert (HS : unit_settings U = unit_settings asan_U) by congruence.
 pose proof (unit_params_settings (genv_asan true) U asan_U HS) as HP.
 exists U,asan_nu,asan_regs,asan_mem.
 split;[reflexivity|]. split;[apply asan_case_is_in_certificate|].
 split;[apply asan_rank_is_in_certificate|].
 split;[rewrite HP;apply asan_complete_original_invariant|].
 split;[apply asan_rank_nonnegative|].
 split;[closed|]. split;[closed|]. split.
 - rewrite asan_destination_word. apply (store_one SEGSA asan_mem (asan_buffer-1) (Z_to_bv 8 0)). vm_compute. reflexivity.
 - apply read_one. vm_compute. reflexivity.
Qed.
Print Assumptions asan_decoded_case_admits_buf_minus_one.

Lemma both_gamma1 SEGS :
 gamma SEGS (p1 both_P) (ev1 both_E) (zpatch both_P both_E both_mem both_mem)
  (v1 both_A) both_nu both_regs both_mem.
Proof.
 unfold gamma. split;[exact (proj1 both_environment)|].
 split;[apply both_MC|]. split;[apply gamma_fix2_fix,both_fixed|].
 split;[apply both_sat|].
 split;[exact (proj1 both_side_defs)|].
 split;[exact (proj1 (proj2 both_side_defs))|].
 split;[exact (proj2 (proj2 both_side_defs))|].
 split;[apply both_registers|]. split;[apply both_slots|].
 split;[apply both_globs|]. split;[apply both_nulls|apply both_below].
Qed.
Lemma both_gamma2 SEGS :
 gamma2 SEGS both_P both_E both_mem both_A both_nu both_regs both_mem.
Proof.
 unfold gamma2. split;[apply both_gamma1|].
 split;[apply both_environment|]. split;[apply both_ambient_memory|].
 split;[apply both_fixed|]. split;[apply both_divdefs|].
 split;[apply both_all_regions|]. split;[apply both_live|].
 split;[apply both_below2|]. split;[apply both_globs2|].
 split;[apply both_flags|apply both_memo].
Qed.

(* The complete original gamma2 predicate, with the original unit parameters,
   including the original static tables and loaded-state constructor. *)
Theorem both_complete_original_invariant SEGS :
 gamma2 SEGS both_full_P both_E both_mem
  (load_cstate2 both_full_P both_case 0x8c93c [])
  both_nu both_regs both_mem.
Proof.
 change (gamma2 SEGS both_full_P both_E both_mem both_A both_nu both_regs both_mem).
 rewrite <- gamma_params_exact. exact (both_gamma2 SEGS).
Qed.
Definition both_buffer : Z := e_sp0 (ev1 both_E) + (-1327020).
Definition both_destination (regs : bvmap 5 word) : word := getr regs 25.
Lemma both_destination_word : both_destination both_regs = wordZ (both_buffer-1).
Proof. apply bv_eq. vm_compute. reflexivity. Qed.

(* Countermodel to a field lower-bound entailment, not an input execution.
   The existential unit is selected directly from the published certificate. *)
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
Proof.
 pose proof both_unit_settings_from_certificate as HM.
 destruct (find (fun u => Z.eqb (u_vid (u1 u)) 845) both_decoded) as [U|] eqn:HU;
   [|discriminate].
 cbn in HM. assert (HS : unit_settings U = unit_settings both_U) by congruence.
 pose proof (unit_params_settings (genv_both true) U both_U HS) as HP.
 exists U,both_nu,both_regs,both_mem.
 split;[reflexivity|]. split;[apply both_case_is_in_certificate|].
 split;[apply both_rank_is_in_certificate|].
 split;[rewrite HP;apply both_complete_original_invariant|].
 split;[apply both_rank_nonnegative|].
 split;[closed|]. split;[closed|]. split.
 - rewrite both_destination_word. apply (store_one SEGSB both_mem (both_buffer-1) (Z_to_bv 8 0)). vm_compute. reflexivity.
 - apply read_one. vm_compute. reflexivity.
Qed.
Print Assumptions both_decoded_case_admits_buf_minus_one.

