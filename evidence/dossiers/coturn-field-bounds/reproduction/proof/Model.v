From Stdlib Require Import ZArith NArith List Bool Lia.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import PropExec.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Asan Require Import FContractAsan.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VLinalg VState VLogic VGamma VState2 VGamma2 VCert VCert2
    VDriver2 VGenv_asan VGenv_both FPA_asan FPA_both.
From CoturnFieldAudit Require Import WitnessData Certificate Support.
Import ListNotations.
Open Scope Z_scope.
#[local] Existing Instance PropExec.fx0.
(* Only these six unit fields affect unit_params2.  The equality below checks
   them against the original, decoded unit, not a handwritten unit identity. *)
Definition unit_settings (U : vunit2) :=
  (u_sp (u1 U), u_wstack (u1 U), u_wglobs (u1 U), u_errno (u1 U),
   u2_wrgn U, u2_fdepth U).
Definition asan_U : vunit2 :=
  mkUnit2 (mkUnit 0x8d0f0 752 (-1328080) (1,4096) (c1 asan_case)
    [] [] asan_wstack [] false (-1328080) [] 1332%N None 752)
    asan_case [] [] [] 64 [].
Definition both_U : vunit2 :=
  mkUnit2 (mkUnit 0x8c638 845 (-1328048) (1,4096) (c1 both_case)
    [] [] both_wstack [] false (-1328048) [] 1220%N None 845)
    both_case [] [] [] 64 [].

Theorem asan_unit_settings_from_certificate :
  option_map unit_settings (find (fun u => Z.eqb (u_vid (u1 u)) 752) asan_decoded)
  = Some (unit_settings asan_U).
Proof. vm_compute. reflexivity. Qed.
Theorem both_unit_settings_from_certificate :
  option_map unit_settings (find (fun u => Z.eqb (u_vid (u1 u)) 845) both_decoded)
  = Some (unit_settings both_U).
Proof. vm_compute. reflexivity. Qed.

Lemma unit_params_settings G U V :
  unit_settings U = unit_settings V -> unit_params2 G U = unit_params2 G V.
Proof.
  unfold unit_settings, unit_params2, unit_wcells2.
  intro H. inversion H. reflexivity.
Qed.

Definition asan_full_P := unit_params2 (genv_asan true) asan_U.
Definition both_full_P := unit_params2 (genv_both true) both_U.

(* gamma2 never inspects these two static-table fields.  The equality below
   proves that discarding them preserves the ENTIRE predicate, definitionally.
   Actual image segments remain the SEGS argument of gamma2 throughout. *)
Definition gamma_params (P : vparams2) : vparams2 :=
  let Q := p1 P in
  mkVP2 (mkVP (vp_frame Q) (vp_wstack Q) (vp_wcells Q) (vp_fcells Q)
    [] (vp_pristine Q) pm_empty (vp_nmax Q) (vp_splo Q) (vp_sphi Q))
    (vp_shoff P) (vp_kcells P) (vp_kruns P) (vp_fzones P) (vp_fs P)
    (vp_datal P) (vp_wrgn P) (vp_fdepth P) (vp_tp P) (vp_imgend P).

Lemma class_regions_gamma P fs cid L :
  class_regions (gamma_params P) fs cid L = class_regions P fs cid L.
Proof. unfold class_regions. reflexivity. Qed.
Lemma classes_regions_gamma P fs n L :
  classes_regions (gamma_params P) fs n L = classes_regions P fs n L.
Proof.
  induction n; cbn [classes_regions]; [reflexivity|].
  rewrite IHn, class_regions_gamma. reflexivity.
Qed.

Lemma gamma_params_exact SEGS P E mem0 A nu regs mem :
  gamma2 SEGS (gamma_params P) E mem0 A nu regs mem =
  gamma2 SEGS P E mem0 A nu regs mem.
Proof.
  unfold gamma2, gamma, region_ok, region_perm_ok, covered,
    unit_regions2, fs_regions.
  rewrite classes_regions_gamma.
  reflexivity.
Qed.

Definition asan_P := Eval lazy in gamma_params asan_full_P.
Definition both_P := Eval lazy in gamma_params both_full_P.
Definition asan_A := Eval lazy in load_cstate2 asan_P asan_case 0x8d348 [].
Definition both_A := Eval lazy in load_cstate2 both_P both_case 0x8c93c [].

Definition make_env (nu : val) : venv2 :=
  mkEnv2 (mkEnv (nu SP0) (nu DATA) (nu SIZE) (nu RA) (nu TP) (nu GP)
    (map (fun i => nu (SREG i)) [0;1;2;3;4;5;6;7;8;9;10;11]))
    (nu FSB) (map (fun i => nu (ASYM2 i)) [0;1;2;3;4;5;6;7]) [(1,0)].
Definition asan_E := Eval vm_compute in make_env asan_nu.
Definition both_E := Eval vm_compute in make_env both_nu.

(* Memory is an explicit overlay: None exactly on the proof's pristine ranges;
   elsewhere zero, with the finitely recorded bytes/runs below superimposed.
   Neither this memory nor the register witness is asserted input-reachable. *)
Definition cell_runs (nu : val) (a w : Z) (e : lin) : list run :=
  flat_map (fun j => let k := Z.of_nat j in
    let b := (eval nu e / 2^(8*k)) mod 256 in
    if b =? 0 then [] else [(a+k,(a+k+1,b))]) (seq 0 (Z.to_nat w)).

Definition state_runs (nu : val) (cs : cstate2) : list run :=
  flat_map (fun c => cell_runs nu (nu SP0 + fst c) (fst (snd c)) (snd (snd c)))
    (cs_slots (c1 cs)) ++
  flat_map (fun r =>
    flat_map (fun c => let a := nu (sr_base r) + sr_disp r + fst c in
      match sr_kind r with
      | SK_shadow _ => let b := Z.land (lc (snd (snd c))) 255 in
                       if b =? 0 then [] else [(a,(a+fst (snd c),b))]
      | _ => cell_runs nu a (fst (snd c)) (snd (snd c))
      end) (sr_cells r)) (cs_rgn cs).

Definition ambient_runs (P : vparams2) (E : venv2) (tsd : Z) : list run :=
  flat_map (fun c => cell_runs (fun _ => 0) (fst c) (fst (snd c)) (lconst (snd (snd c))))
    (vp_kcells P) ++
  filter (fun r => negb (snd (snd r) =? 0)) (vp_kruns P) ++
  flat_map (fun c => cell_runs (fun _ => 0) (fst c) (fst (snd c)) (lconst (snd (snd c))))
    [(vp_tp P,(8,e_fs E)); (e_fs E+88,(8,20));
     (vp_tp P-88,(8,tsd)); (tsd,(8,0x30001000));
     (0x30001000+152,(8,0x30002000));
     (vp_tp P+8,(8,0x30003000)); (0x30003000+24,(8,0x30004000))] ++
  [(flag_addr (e_fs E) 0 0,(flag_addr (e_fs E) 0 0+1,1));
   (flag_addr (e_fs E) 1 0,(flag_addr (e_fs E) 1 0+1,1));
   (vp_shoff P + e_data (ev1 E)/8,(vp_shoff P + e_data (ev1 E)/8+1,1))].

Definition asan_runs := Eval vm_compute in state_runs asan_nu asan_case ++ ambient_runs asan_P asan_E (fa_tsd FPA_asan).
Definition both_runs := Eval vm_compute in state_runs both_nu both_case ++ ambient_runs both_P both_E (fa_tsd FPA_both).
Definition asan_pristine := Eval vm_compute in vp_pristine (p1 asan_P).
Definition both_pristine := Eval vm_compute in vp_pristine (p1 both_P).
Definition asan_mem := witness_mem asan_pristine asan_runs.
Definition both_mem := witness_mem both_pristine both_runs.

Definition make_regs (nu : val) (cs : cstate) : bvmap 5 word :=
  fold_right (fun re m => bvmap_set (Z_to_bv 5 (fst re)) (wordZ (eval nu (snd re))) m)
    bvmap_empty (cs_regs cs).
Definition asan_regs := Eval vm_compute in make_regs asan_nu (c1 asan_case).
Definition both_regs := Eval vm_compute in make_regs both_nu (c1 both_case).
