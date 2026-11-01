From Stdlib Require Import ZArith List Bool.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VCert VCert2 VLinalg.
From CoturnFieldAudit Require Import WitnessData Certificate.
Import ListNotations. Open Scope Z_scope.

Definition select_rank (cert : vcert2) (vid pc : Z) : option lin :=
  match find (fun u => Z.eqb (u_vid (u1 u)) vid) cert with
  | None => None
  | Some u =>
      match find (fun c => Z.eqb (cut2_pc c) pc &&
                         match cut2_ctx c with [] => true | _ => false end)
                 (u2_cuts u) with
      | None => None
      | Some c => nth_error (cut2_ranks c) 1
      end
  end.

Theorem asan_rank_is_in_certificate :
  select_rank asan_decoded 752 0x8d348 = Some asan_rank.
Proof. vm_compute. reflexivity. Qed.
Theorem both_rank_is_in_certificate :
  select_rank both_decoded 845 0x8c93c = Some both_rank.
Proof. vm_compute. reflexivity. Qed.
