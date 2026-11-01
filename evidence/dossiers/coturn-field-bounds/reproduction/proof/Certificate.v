From Stdlib Require Import ZArith List Bool.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VCertDecode2 VCert2 VCert VLinalg
    VCertS_asan_p00 VCertS_asan_p01 VCertS_both_p00 VCertS_both_p01.
From CoturnFieldAudit Require Import WitnessData.
Import ListNotations.
Open Scope Z_scope.

Definition select_case (cert : vcert2) (vid pc : Z) : option cstate2 :=
  match find (fun u => Z.eqb (u_vid (u1 u)) vid) cert with
  | None => None
  | Some u =>
      match find (fun c => Z.eqb (cut2_pc c) pc &&
                         match cut2_ctx c with [] => true | _ => false end)
                 (u2_cuts u) with
      | None => None
      | Some c => nth_error (cut2_states c) 1
      end
  end.

Definition asan_decoded : vcert2 :=
  decode_cert2_d (decode_dict2 cert_asan_dict) cert_asan_s01.
Definition both_decoded : vcert2 :=
  decode_cert2_d (decode_dict2 cert_both_dict) cert_both_s01.

(* These equalities validate every component of each literal, including all
   slots, region/shadow facts, definitions, and interval/congruence constraints.
   The official decoder and original compressed dictionary/chunk are used. *)
Theorem asan_case_is_in_certificate :
  select_case asan_decoded 752 0x8d348 = Some asan_case.
Proof. vm_compute. reflexivity. Qed.

Theorem both_case_is_in_certificate :
  select_case both_decoded 845 0x8c93c = Some both_case.
Proof. vm_compute. reflexivity. Qed.

Print Assumptions asan_case_is_in_certificate.
Print Assumptions both_case_is_in_certificate.
