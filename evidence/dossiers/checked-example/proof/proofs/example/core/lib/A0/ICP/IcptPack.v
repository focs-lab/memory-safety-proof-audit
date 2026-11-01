(* example/core: pupnp's A0/ICP/IcptPack.v, trimmed to the interceptors the driver needs (IcptICS.ics_all); the
   contracts of interceptors only pupnp's harness used are removed (see replay/port/gen_overlay_icpt.py).
   port: donor-derived (addresses are renamed like a donor file's) *)
(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Run.
From LinuxProcessSemantics.Riscv Require Import Prelude Instr Decode DecodeC Sem Fpu.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac ZBridge STRW_tac Image Arr Ceiling.
From OssFuzzTheorems.Proofs.example.core.lib.Spec Require Import StrFun StrFun2.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAW Require Import Segs Shadow Contracts Globals IcptA0.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ICP Require Import IcptKit I_memset_i I_memcpy_i I_read I_fwrite I_printf_front M_sspdefs I_asan_dtor.
Import ListNotations.
Open Scope Z_scope.

Section P.
Context {HC : HasCeiling}.

#[using="Type"] Lemma env_safe_stack : forall lo q, alloc_ceiling <= lo -> env_safe [(lo, q)].
Proof. intros lo q H. pose proof alloc_ceiling_bounds. constructor; [left; cbn; lia| constructor]. Qed.
#[using="Type"] Lemma env_safe_cons_stack : forall A B lo q, env_safe [(A, B)] -> alloc_ceiling <= lo -> env_safe [(A, B); (lo, q)].
Proof. intros A B lo q H1 H2. inversion H1; subst. constructor; [assumption|]. apply env_safe_stack; assumption. Qed.
#[using="Type"] Lemma env_safe_stack_cons : forall A B lo q, env_safe [(A, B)] -> alloc_ceiling <= lo -> env_safe [(lo, q); (A, B)].
Proof. intros A B lo q H1 H2. pose proof alloc_ceiling_bounds. constructor; [left; cbn; lia| assumption]. Qed.

Ltac exs Q := repeat (let x := fresh "x" in destruct Q as [x Q]; exists x).




#[using="Type"] Lemma ic_memset_i_proof : asan_memset_stmt2 A0_memset_i.
Proof.
  intros until junk. intros DST ACC RDB (WIN & W2 & NS) AE ST CLO LO Q64 SEP SAFE MI -> -> -> Hn Hc.
  pose proof alloc_ceiling_bounds as ACB. pose proof (icpt_env_of_asan_env _ AE) as IE. unfold A0_RT_STACK in LO.
  eapply evt_mono.
  { eapply memset_i_spec; try eassumption; try reflexivity; lia. }
  intros ms' Q. unfold imemset_post in Q. unfold asan_memset_post2. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & R). repeat (split; [assumption|]).
  split; [| exact R]. eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_cons_stack; assumption].
Qed.


#[using="Type"] Lemma ic_memcpy_i_proof : asan_memcpy_stmt A0_memcpy_i.
Proof.
  intros until junk. intros DST SRC LEN SEP ACD RDD ACS RDS (WD & WD2 & ND) (WS & WS2 & NS) AE ST CLO LO Q64 SEPD SAFE SEPS MI -> -> -> Hn.
  pose proof alloc_ceiling_bounds as ACB. pose proof (icpt_env_of_asan_env _ AE) as IE. unfold A0_RT_STACK in LO.
  eapply evt_mono.
  { eapply memcpy_i_spec; try eassumption; try reflexivity; lia. }
  intros ms' Q. unfold imemcpy_post in Q. unfold asan_memcpy_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & R). repeat (split; [assumption|]).
  split; [| exact R]. eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_cons_stack; assumption].
Qed.

#[using="Type"] Lemma ic_read_front_proof : read_front_stmt.
Proof.
  intros until lo. intros AE ST CLO LO Q64 MI -> -> ->.
  pose proof alloc_ceiling_bounds as ACB. pose proof (icpt_env_of_asan_env _ AE) as IE.
  eapply evt_mono.
  { eapply read_front_spec; try eassumption; try reflexivity; lia. }
  intros ms' Q. unfold read_front_post0 in Q. unfold read_front_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & R). repeat (split; [assumption|]).
  split; [| exact R]. eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_stack; exact CLO].
Qed.

#[using="Type"] Lemma ic_read_back_proof : read_back_stmt.
Proof.
  intros until junk. intros FRM AE ST CLO LO Q64 CHK RR RC SEP HB MI.
  pose proof alloc_ceiling_bounds as ACB. pose proof (icpt_env_of_asan_env _ AE) as IE. unfold A0_RT_STACK in LO.
  eapply evt_mono.
  { eapply read_back_spec; try eassumption; try lia.
    intros POS. destruct (CHK POS) as (_ & AC & RD & (W & W2 & NS)). repeat (split; [assumption|]). assumption. }
  intros ms' Q. unfold icpt_back_post0 in Q. unfold icpt_back_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST'). repeat (split; [assumption|]).
  eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_stack; exact CLO].
Qed.

#[using="Type"] Lemma ic_fwrite_front_proof : fwrite_front_stmt.
Proof.
  intros until lo. intros AE ST CLO LO Q64 MI -> -> -> ->.
  pose proof alloc_ceiling_bounds as ACB. pose proof (icpt_env_of_asan_env _ AE) as IE.
  eapply evt_mono.
  { eapply fwrite_front_spec; try eassumption; try reflexivity; lia. }
  intros ms' Q. unfold fwrite_front_post0 in Q. unfold fwrite_front_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & R). repeat (split; [assumption|]).
  split; [| exact R]. eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_stack; exact CLO].
Qed.

#[using="Type"] Lemma ic_fwrite_back_proof : fwrite_back_stmt.
Proof.
  intros until junk. intros FRM AE ST CLO LO Q64 HR HS HN CHK SEP HP MI.
  pose proof alloc_ceiling_bounds as ACB. pose proof (icpt_env_of_asan_env _ AE) as IE. unfold A0_RT_STACK in LO.
  eapply evt_mono.
  { eapply fwrite_back_spec; try eassumption; try lia.
    intros POS. destruct (CHK POS) as (AC & RD & (W & W2 & NS)). repeat (split; [assumption|]). assumption. }
  intros ms' Q. unfold icpt_back_post0 in Q. unfold icpt_back_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST'). repeat (split; [assumption|]).
  eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_stack; exact CLO].
Qed.


#[using="Type"] Lemma ic_vprintf_front_proof : vprintf_front_stmt.
Proof.
  intros until argw. intros AE ST CLO LO Q64 MI E0 E1 VA SEPV AP0 APM ACCF RDF.
  pose proof alloc_ceiling_bounds as ACB0. pose proof (icpt_env_of_asan_env _ AE) as IE. unfold A0_RT_STACK in LO.
  eapply evt_mono.
  { eapply vprintf_front_spec; try eassumption; lia. }
  intros ms' Q. unfold vprintf_front_post0 in Q. unfold vprintf_front_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & R). repeat (split; [assumption|]).
  split; [| exact R]. eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_stack; exact CLO].
Qed.

#[using="Type"] Lemma ic_vfprintf_front_proof : vfprintf_front_stmt.
Proof.
  intros until argw. intros AE ST CLO LO Q64 MI E0 E1 E2 STRM VA SEPV AP0 APM ACCF RDF.
  pose proof alloc_ceiling_bounds as ACB0. pose proof (icpt_env_of_asan_env _ AE) as IE. unfold A0_RT_STACK in LO.
  eapply evt_mono.
  { eapply vfprintf_front_spec; try eassumption; lia. }
  intros ms' Q. unfold vfprintf_front_post0 in Q. unfold vfprintf_front_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & R). repeat (split; [assumption|]).
  split; [| exact R]. eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_stack; exact CLO].
Qed.

#[using="Type"] Lemma ic_fprintf_s_front_proof : forall fmt flen, fprintf_s_front_stmt fmt flen.
Proof.
  intros fmt flen. intros until sbuf. intros HF AE ST CLO LO Q64 MI E0 E1 E2 STRM ACCF RDF SSTR NOTIN SPOS SEPS ACCS RDS (WINS & W2 & NS).
  pose proof alloc_ceiling_bounds as ACB0. pose proof (icpt_env_of_asan_env _ AE) as IE. unfold A0_RT_STACK in LO.
  eapply evt_mono.
  { eapply fprintf_s_front_spec with (S := S) (sbuf := sbuf); try eassumption; lia. }
  intros ms' Q. unfold fprintf_front_post0 in Q. unfold fprintf_front_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & R). repeat (split; [assumption|]).
  split; [| exact R]. eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_stack; exact CLO].
Qed.

#[using="Type"] Lemma ic_fprintf_u_front_proof : fprintf_u_front_stmt.
Proof.
  intros until lo. intros AE ST CLO LO Q64 MI E0 E1 STRM ACCF RDF.
  pose proof alloc_ceiling_bounds as ACB0. pose proof (icpt_env_of_asan_env _ AE) as IE. unfold A0_RT_STACK in LO.
  eapply evt_mono.
  { eapply fprintf_u_front_spec; try eassumption; lia. }
  intros ms' Q. unfold fprintf_front_post0 in Q. unfold fprintf_front_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & R). repeat (split; [assumption|]).
  split; [| exact R]. eapply asan_env_frame; [exact AE| exact MU| exact WM| apply env_safe_stack; exact CLO].
Qed.


#[using="Type"] Lemma env_safe_errno : forall lo q, alloc_ceiling <= lo -> env_safe [(lo, q); (6099088 - 164, 6099088 - 164 + 4)].
Proof. intros lo q H. pose proof alloc_ceiling_bounds. constructor; [left; cbn; lia|]. constructor; [| constructor]. cbn. lia. Qed.
#[using="Type"] Lemma env_safe_errno_E : forall lo q E, alloc_ceiling <= lo -> 0x5f3000 <= E -> env_safe [(lo, q); (E, E + 8); (6099088 - 164, 6099088 - 164 + 4)].
Proof. intros lo q E H HE. pose proof alloc_ceiling_bounds. constructor; [left; cbn; lia|]. constructor; [left; cbn; lia|]. constructor; [| constructor]. cbn. lia. Qed.







Definition ivl_eqb (a b : ivl) : bool := (fst a =? fst b) && (snd a =? snd b).
#[using="Type"] Lemma outside_in : forall W x a b, outside W x -> In (a, b) W -> ~ (a <= x < b).
Proof.
  induction W as [|[c d] W IH]; intros x a b OUT HIn; [destruct HIn|]. cbn [outside] in OUT. destruct OUT as [O1 O2].
  destruct HIn as [E|HIn]; [inversion E; subst; exact O1| eapply IH; eassumption].
Qed.
#[using="Type"] Lemma sub_fp_incl_b : forall W W' : list ivl, forallb (fun iv => existsb (ivl_eqb iv) W') W = true -> sub_fp W W'.
Proof.
  intros W W' H x OUT. induction W as [|[a b] W IH]; cbn [outside]; [exact I|].
  cbn [forallb] in H. apply andb_true_iff in H. destruct H as [H1 H2]. split; [| apply IH; exact H2].
  apply existsb_exists in H1. destruct H1 as ([a' b'] & HIn & HE). unfold ivl_eqb in HE; cbn [fst snd] in HE.
  apply andb_true_iff in HE. destruct HE as [E1 E2]. apply Z.eqb_eq in E1, E2. subst. eapply outside_in; eassumption.
Qed.
#[using="Type"] Lemma dtor_fp_sub : forall lo q, sub_fp (dtor_Wx lo q) ((lo, q) :: dtor_W).
Proof.
  intros lo q x OUT. unfold dtor_Wx. cbn [outside] in OUT |- *. destruct OUT as [O1 O2]. split; [exact O1|].
  clear O1. revert x O2. change (sub_fp ((633408, 633416) :: (637360, 637368) :: (2147530044, 2147530052) :: WL0) dtor_W).
  apply sub_fp_incl_b. vm_compute. reflexivity.
Qed.
#[using="Type"] Lemma odr_cells_split : forall (m : mem) b0 b1 b2, rw_cells asegs m 6029321 [C1 b0; C1 b1; C1 b2] ->
  forall o, 0x5c0009 <= o < 0x5c000c -> exists c, rw_cells asegs m o [C1 c].
Proof.
  intros m b0 b1 b2 ODR o Ho.
  apply (proj1 (HttpTac.rw_cells_app asegs _ 6029321 [C1 b0] [C1 b1; C1 b2])) in ODR. destruct ODR as [O0 O12].
  cbn [cells_size csize Nat.add] in O12. change (6029321 + Z.of_nat 1) with 6029322 in O12.
  apply (proj1 (HttpTac.rw_cells_app asegs _ 6029322 [C1 b1] [C1 b2])) in O12. destruct O12 as [O1 O2].
  cbn [cells_size csize Nat.add] in O2. change (6029322 + Z.of_nat 1) with 6029323 in O2.
  assert (o = 6029321 \/ o = 6029322 \/ o = 6029323) as [->|[->| ->]] by lia; eexists; eassumption.
Qed.

#[using="Type"] Lemma ic_asan_dtor_proof : asan_dtor_stmt.
Proof.
  intros until lo. intros AE ST CLO LO Q64 MI GSH [bs SHD].
  pose proof alloc_ceiling_bounds as ACB. unfold alloc_floor, alloc_ceiling_max in ACB. unfold A0_RT_STACK in LO.
  pose proof AE as (AG & ((fw & FLAG) & (b0 & b1 & b2 & ODR) & D1 & D3 & D4 & D5 & MTX & DC) & IEz).
  pose proof (icpt_env_of_zaw _ IEz) as IE. pose proof (ie_got_rms _ IE) as D2. unfold env_got_rms in D2.
  assert (LE : LENV m) by (split; [exact IE| unfold dtor_xenv; repeat (split; [assumption|]); assumption]).
  assert (GF : gfacts m 0 0x5c0009 A0_DESCS).
  { apply gfacts_intro; [exact A0_DESCS_ok| rewrite A0_DESCS_globals; exact GSH| eapply odr_cells_split; exact ODR]. }
  eapply evt_mono.
  { eapply asan_dtor_spec with (lo := lo) (fw := fw) (b0 := b0) (b1 := b1) (b2 := b2) (junkD := bs);
      [ exact MI | exact ST | lia | lia | lia | exact LE | exact MTX | exact DC | exact GF | exact SHD | exact ODR | exact FLAG ]. }
  intros ms' Q. unfold dtor_post_x in Q. unfold asan_dtor_post. exs Q.
  destruct Q as (E & MU & WM & MI' & ST' & MTX' & ODR' & FLAG').
  split; [exact E|]. split; [eapply munch_weaken; [apply dtor_fp_sub| exact MU]|]. split; [exact WM|]. split; [exact MI'|]. split; [exact ST'|].
  assert (XB : xband_safe (dtor_Wx lo q)) by (apply dtor_Wx_xband; lia).
  pose proof (LENV_frame_x _ _ _ LE MU WM XB) as [IE' (E1 & E2 & E3 & E4 & E5)].
  destruct AG as (G1 & G2 & G3 & G4). unfold A0_GOT_SHADOW, A0_SHADOW_CELL, A0_GOT_UAR, A0_UAR_CELL in *.
  split; [| split].
  - unfold asan_globals, A0_GOT_SHADOW, A0_SHADOW_CELL, A0_GOT_UAR, A0_UAR_CELL.
    split; [ecfx G1 MU WM XB|]. split; [ecfx G2 MU WM XB|]. split; [ecfx G3 MU WM XB| ecfx G4 MU WM XB].
  - split; [exact FLAG'|]. split; [exact ODR'|]. split; [exact E1|]. split; [exact E3|]. split; [exact E4|]. split; [exact E5|]. split; [exact MTX'|].
    eapply rw_cells_transport; [exact DC| exact MU| exact WM|]. apply xband_disjoint; [exact XB| lia| | |];
      rewrite cells_size_desc; change (length A0_DESCS) with 1%nat; lia.
  - exact IE'.
Qed.


End P.
