(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Specs Run.
From LinuxProcessSemantics.Riscv Require Import Prelude Instr Decode DecodeC Sem Fpu.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import Tac ITree Ceiling Nodes SysStep Decode SysMm.
From OssFuzzTheorems.Proofs.example.core.lib.P0 Require Import Segs ImgFacts F_syscalls.
Import ListNotations.
Open Scope bv_scope.
Local Ltac Z.euclidean_division_equations_cleanup ::= idtac.
Local Unset Keyed Unification.

Definition vm_wait_entry : Z := 0x14ebc.
Definition p0munmap_entry : Z := 0x14ff4.
Definition p0mprotect_entry : Z := 0x14fac.
Definition p0mmap_entry : Z := 0x14ec0.

Definition vm_wait_post (ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 : word) (F : bvmap 5 word) (fc : bv 32)
    (lo : Z) (m : word -> option byte) : machine_state -> Prop :=
  fun ms' => exists t0 t1 t2 a0 a1 a2 a3 a4 a5 a6 a7 t3 t4 t5 t6 m',
    ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
             F (ret_pc ra) fc None m' (seg_rom rsegs)
    /\ munch [(bv_unsigned sp - 32, bv_unsigned sp)]%Z m m'
    /\ wmono rsegs m m' /\ mem_inv rsegs m'
    /\ stk rsegs m' lo (bv_unsigned sp).

Lemma vm_wait_spec : forall ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F fc m
    (lo : Z),
  stk rsegs m lo (bv_unsigned sp) ->
  rw_cells rsegs m P0_VMLOCK [C4 (Z_to_bv 64 0)] ->
  mem_inv rsegs m ->
  (lo <= bv_unsigned sp - 32)%Z -> (P0_IMG_HI <= lo)%Z ->
  evt rsegs (vm_wait_post ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 F fc lo m)
      (MS (mkR ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
          F (Z_to_bv 64 0x14ebc) fc None m (seg_rom rsegs)).
Proof.
  intros until lo. intros ST VL MI LO ILO.
  pose proof (munch_refl [(bv_unsigned sp - 32, bv_unsigned sp)]%Z m) as MU.
  pose proof (wmono_refl rsegs m) as WM.
  step.
  unfold vm_wait_post. finish.
Qed.

Definition p0munmap_post (ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 : word) (F : bvmap 5 word) (fc : bv 32)
    (A L : Z) (errv : word) (lo : Z) (m : word -> option byte) (a : range_ans) : machine_state -> Prop :=
  fun ms' => exists t0 t1 t2 a1 a2 a3 a4 a5 a6 a7 t3 t4 t5 t6 m',
    ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (munmap_ret a) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
             F (ret_pc ra) fc None m' (seg_rom rsegs)
    /\ munch [(bv_unsigned sp - 64, bv_unsigned sp); (errno_addr tp, errno_addr tp + 4); (A, A + mmap_len L)]%Z m m'
    /\ (match a with RgDone true => True | _ => wmono rsegs m m' end)
    /\ mem_inv rsegs m'
    /\ stk rsegs m' lo (bv_unsigned sp)
    /\ rw_cells rsegs m' (errno_addr tp) [C4 (rg_errno a errv)]
    /\ rw_cells rsegs m' P0_VMLOCK [C4 (Z_to_bv 64 0)]
    /\ match a with RgErr e => (1 <= e <= 4095)%Z | _ => True end.

Lemma p0munmap_spec {HCEIL : HasCeiling} : forall ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F fc m
    (A L : Z) (errv : word) (lo : Z),
  stk rsegs m lo (bv_unsigned sp) ->
  rw_cells rsegs m (errno_addr tp) [C4 errv] ->
  rw_cells rsegs m P0_VMLOCK [C4 (Z_to_bv 64 0)] ->
  mem_inv rsegs m ->
  a0 = Z_to_bv 64 A -> a1 = Z_to_bv 64 L ->
  (0 < A)%Z -> (A mod 4096 = 0)%Z -> (A + mmap_len L <= alloc_ceiling)%Z -> (0 < L < 2^63)%Z ->
  (lo <= bv_unsigned sp - 64)%Z -> (P0_IMG_HI <= lo)%Z ->
  (errno_addr tp + 4 <= bv_unsigned sp - 64 \/ bv_unsigned sp <= errno_addr tp)%Z ->
  (A + mmap_len L <= lo \/ bv_unsigned sp <= A)%Z ->
  (A + mmap_len L <= errno_addr tp \/ errno_addr tp + 4 <= A)%Z ->
  (errno_addr tp + 4 <= P0_VMLOCK \/ P0_VMLOCK + 4 <= errno_addr tp)%Z ->
  ((A + mmap_len L <= P0_IMG_LO \/ P0_RO_HI <= A) /\ (A + mmap_len L <= 0x1b000 \/ P0_IMG_HI <= A))%Z ->
  (164 <= bv_unsigned tp)%Z ->
  impl rsegs (at_node rsegs) (enode (NMunmap A L) (dec_munmap A L))
       (epost (p0munmap_post ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 F fc A L errv lo m))
       (MS (mkR ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
           F (Z_to_bv 64 0x14ff4) fc None m (seg_rom rsegs)).
Proof.
  intros until lo. intros ST ERR VL MI -> -> A0 AA AL L0 LO ILO SEP1 SEP2 SEP3 SEPE [SEPA1 SEPA2] TP.
  pose proof alloc_ceiling_bounds.
  pose proof (munch_refl [(bv_unsigned sp - 64, bv_unsigned sp); (errno_addr tp, errno_addr tp + 4); (A, A + mmap_len L)]%Z m) as MU.
  pose proof (wmono_refl rsegs m) as WM.
  pose proof (mmap_len_ge L) as ML.
  apply impl_enode.
  carve_frame 32%nat ST.
  do 6 step.
  step. call_sp vm_wait_spec; [exact ST | exact VL | exact MI | lia | lia | ]. rename POST into ST.
  lazymatch goal with H : mem_inv rsegs _ |- _ => rename H into MI end.
  do 3 step.
  step_ecall.
  split. { at_node_solve. all: rewrite ?unsigned_lit by lia; try lia.
           - unfold page_size. exact AA.
           - rewrite w_is0_lit by lia. apply Z.eqb_neq. lia.
           - unfold two_pow_64. fold (mmap_len L). lia. }
  intros rsp ans Hdec. pose proof (dec_munmap_Some _ _ _ _ Hdec) as D. clear Hdec.
  destruct ans as [e|[|]].
  - destruct D as [Hs He]. sys_nret.
    step. call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia | ]. rename PC into ST; rename POST into ERR.
    unfold sysret_val, sysret_errno in *. rewrite errno_of_errno_ret in * by lia.
    do 6 step. release_frame FR ST (bv_unsigned sp).
    unfold p0munmap_post, munmap_ret, rg_errno. finish; lia.
  - rename D into Hs. sys_nret.
    step. call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia | ]. rename PC into ST; rename POST into ERR.
    unfold sysret_val, sysret_errno in *. rewrite errno_of_lit in * by lia.
    step. try rewrite sextw_small by lia. do 5 step. release_frame FR ST (bv_unsigned sp).
    unfold p0munmap_post, munmap_ret, rg_errno. finish; exact I.
  - rename D into Hs. sys_nret.
    step. call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia | ]. rename PC into ST; rename POST into ERR.
    unfold sysret_val, sysret_errno in *. rewrite errno_of_lit in * by lia.
    step. try rewrite sextw_small by lia. do 5 step. release_frame FR ST (bv_unsigned sp).
    unfold p0munmap_post, munmap_ret, rg_errno. finish; exact I.
Qed.

Definition p0mprotect_post (ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 : word) (F : bvmap 5 word) (fc : bv 32)
    (A L : Z) (errv : word) (lo : Z) (m : word -> option byte) (a : range_ans) : machine_state -> Prop :=
  fun ms' => exists t0 t1 t2 a1 a2 a3 a4 a5 a6 a7 t3 t4 t5 t6 m',
    ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (munmap_ret a) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
             F (ret_pc ra) fc None m' (seg_rom rsegs)
    /\ munch [(bv_unsigned sp - 32, bv_unsigned sp); (errno_addr tp, errno_addr tp + 4); (A, A + L)]%Z m m'
    /\ wmono rsegs m m' /\ mem_inv rsegs m'
    /\ stk rsegs m' lo (bv_unsigned sp)
    /\ rw_cells rsegs m' (errno_addr tp) [C4 (rg_errno a errv)]
    /\ rw_cells rsegs m' P0_PAGE_SIZE [C8 (Z_to_bv 64 4096)]
    /\ match a with
       | RgErr e => (1 <= e <= 4095)%Z
       | RgDone true => rw_cells rsegs m' A [CB (Z.to_nat L) (repeat (Z_to_bv 8 0) (Z.to_nat L))]
       | RgDone false => True
       end.

Lemma p0mprotect_spec : forall ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F fc m
    (A L : Z) (errv : word) (lo : Z),
  stk rsegs m lo (bv_unsigned sp) ->
  rw_cells rsegs m (errno_addr tp) [C4 errv] ->
  rw_cells rsegs m P0_PAGE_SIZE [C8 (Z_to_bv 64 4096)] ->
  mem_inv rsegs m ->
  a0 = Z_to_bv 64 A -> a1 = Z_to_bv 64 L -> a2 = Z_to_bv 64 (PROT_READ + PROT_WRITE) ->
  (A mod 4096 = 0)%Z -> (L mod 4096 = 0)%Z -> (0 < A)%Z -> (0 < L)%Z -> (A + L + 4096 <= 2^63)%Z ->
  (lo <= bv_unsigned sp - 32)%Z ->
  (errno_addr tp + 4 <= bv_unsigned sp - 32 \/ bv_unsigned sp <= errno_addr tp)%Z ->
  (A + L <= lo \/ bv_unsigned sp <= A)%Z ->
  (A + L <= errno_addr tp \/ errno_addr tp + 4 <= A)%Z ->
  ((A + L <= P0_IMG_LO \/ P0_RO_HI <= A) /\ (A + L <= 0x1b000 \/ P0_IMG_HI <= A))%Z ->
  (P0_IMG_HI <= lo)%Z -> (errno_addr tp + 4 <= P0_PAGE_SIZE \/ P0_PAGE_SIZE + 8 <= errno_addr tp)%Z ->
  (164 <= bv_unsigned tp)%Z ->
  impl rsegs (at_node rsegs) (enode (NMprotect A L (PROT_READ + PROT_WRITE)) (dec_mprotect A L))
       (epost (p0mprotect_post ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 F fc A L errv lo m))
       (MS (mkR ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
           F (Z_to_bv 64 0x14fac) fc None m (seg_rom rsegs)).
Proof.
  intros until lo. intros ST ERR PG MI -> -> -> AA LA A0 L0 AL LO SEP1 SEP2 SEP3 [SEP4 SEP4'] SLO SEP5 TP.
  pose proof (munch_refl [(bv_unsigned sp - 32, bv_unsigned sp); (errno_addr tp, errno_addr tp + 4); (A, A + L)]%Z m) as MU.
  pose proof (wmono_refl rsegs m) as WM.
  apply impl_enode.
  carve_frame 16%nat ST.
  step. step. step. step.
  do 7 step.
  destruct (rmprotect_args A L AA LA ltac:(lia) ltac:(lia) ltac:(lia)) as [E1 E2]. rewrite E2, E1.
  step. step_ecall.
  split. { at_node_solve. all: rewrite ?unsigned_lit by lia; try lia.
           - unfold page_size. exact AA.
           - rewrite w_is0_lit by lia. apply Z.eqb_neq. lia.
           - unfold two_pow_64. fold (mmap_len L). rewrite (mmap_len_aligned L LA). lia. }
  intros rsp ans Hdec. pose proof (dec_mprotect_Some _ _ _ _ Hdec) as D. clear Hdec.
  rewrite (mmap_len_aligned L LA) in D.
  destruct ans as [e|[|]].
  - destruct D as [Hs He]. sys_nret.
    step. call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia | ]. rename PC into ST; rename POST into ERR.
    unfold sysret_val, sysret_errno in *. rewrite errno_of_errno_ret in * by lia.
    step. step. step. step. release_frame FR ST (bv_unsigned sp).
    unfold p0mprotect_post, munmap_ret, rg_errno. finish; lia.
  - rename D into Hs.
    assert (ROF : forall x : word, (A <= bv_unsigned x < A + L)%Z -> ro_addr rsegs x = false) by (intros x Hx; apply p0_ro_addr_false; lia).
    sys_nret. lazymatch goal with H : mem_inv _ _ |- _ => rename H into MI end.
    step. call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia | ]. rename PC into ST; rename POST into ERR.
    unfold sysret_val, sysret_errno in *. rewrite errno_of_lit in * by lia.
    step. try rewrite sextw_small by lia. step. step. step. release_frame FR ST (bv_unsigned sp).
    unfold p0mprotect_post, munmap_ret, rg_errno. finish.
  - rename D into Hs. sys_nret.
    step. call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia | ]. rename PC into ST; rename POST into ERR.
    unfold sysret_val, sysret_errno in *. rewrite errno_of_lit in * by lia.
    step. try rewrite sextw_small by lia. step. step. step. release_frame FR ST (bv_unsigned sp).
    unfold p0mprotect_post, munmap_ret, rg_errno. finish; exact I.
Qed.

Definition p0mmap_anon_post {HCEIL : HasCeiling} (isnone : bool) (ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 : word) (F : bvmap 5 word) (fc : bv 32)
    (len : Z) (avoid : list (Z * Z)) (errv : word) (lo : Z) (m : word -> option byte) (a : mmap_ans)
    : machine_state -> Prop :=
  fun ms' =>
    match a with
    | MmErr e => exists t0 t1 t2 a1 a2 a3 a4 a5 a6 a7 t3 t4 t5 t6 m',
        ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (Z_to_bv 64 (-1)) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
                 F (ret_pc ra) fc None m' (seg_rom rsegs)
        /\ munch [(bv_unsigned sp - 80, bv_unsigned sp); (errno_addr tp, errno_addr tp + 4)]%Z m m'
        /\ wmono rsegs m m' /\ mem_inv rsegs m'
        /\ stk rsegs m' lo (bv_unsigned sp)
        /\ rw_cells rsegs m' (errno_addr tp) [C4 (Z_to_bv 64 (mmap_fix_errno e))]
        /\ (1 <= e <= 4095)%Z
    | MmOk x =>

        mmap_addr_ok len avoid x = true /\
        ((alloc_ceiling < x + mmap_len len)%Z \/
         exists t0 t1 t2 a1 a2 a3 a4 a5 a6 a7 t3 t4 t5 t6 m2,
         ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (Z_to_bv 64 x) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
                  F (ret_pc ra) fc None (mmap_raw isnone x len m2) (seg_rom rsegs)
         /\ munch [(bv_unsigned sp - 80, bv_unsigned sp)]%Z m m2
         /\ wmono rsegs m m2 /\ mem_inv rsegs m2
         /\ stk rsegs (mmap_raw isnone x len m2) lo (bv_unsigned sp)
         /\ rw_cells rsegs m2 (errno_addr tp) [C4 errv])
    end.

Lemma p0mmap_anon_spec {HCEIL : HasCeiling} : forall (isnone : bool) ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F fc m
    (len : Z) (avoid : list (Z * Z)) (errv : word) (lo : Z),
  let prot := (if isnone then 0 else 3)%Z in
  stk rsegs m lo (bv_unsigned sp) ->
  rw_cells rsegs m (errno_addr tp) [C4 errv] ->
  mem_inv rsegs m ->
  a0 = Z_to_bv 64 0 -> a1 = Z_to_bv 64 len -> a2 = Z_to_bv 64 prot -> a3 = Z_to_bv 64 34 ->
  a4 = Z_to_bv 64 (-1) -> a5 = Z_to_bv 64 0 ->
  (0 < len <= 2^62)%Z ->
  (lo <= bv_unsigned sp - 80)%Z -> (alloc_ceiling <= lo)%Z ->
  (errno_addr tp + 4 <= bv_unsigned sp - 80 \/ bv_unsigned sp <= errno_addr tp)%Z ->
  (164 <= bv_unsigned tp)%Z ->
  impl rsegs (at_node rsegs) (enode (NMmap 0 len prot 34) (if isnone then dec_mmap_none len avoid else dec_mmap len avoid))
       (epost (p0mmap_anon_post isnone ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 F fc len avoid errv lo m))
       (MS (mkR ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
           F (Z_to_bv 64 0x14ec0) fc None m (seg_rom rsegs)).
Proof.
  intros until lo. intros prot ST ERR MI -> -> -> -> -> -> LEN LO CEIL SEP1 TP.
  pose proof (munch_refl [(bv_unsigned sp - 80, bv_unsigned sp); (errno_addr tp, errno_addr tp + 4)]%Z m) as MU.
  pose proof (munch_refl [(bv_unsigned sp - 80, bv_unsigned sp)]%Z m) as MU1.
  pose proof (wmono_refl rsegs m) as WM.
  pose proof alloc_ceiling_bounds.

  assert (SH1 : w_is0 (Z_to_bv 64 len) = false) by (rewrite w_is0_lit by lia; apply Z.eqb_neq; lia).
  assert (SH3 : let P := Z_to_bv 64 prot in let FL := Z_to_bv 64 34 in
      (mmap_modeled_b P FL (Z_to_bv 64 0) = true
       \/ (mmap_modeled_b P FL (Z_to_bv 64 0) = false /\
           mmap_noaccess_b P FL (Z_to_bv 64 0) = true)
       \/ (mmap_modeled_b P FL (Z_to_bv 64 0) = false /\
           mmap_noaccess_b P FL (Z_to_bv 64 0) = false /\
           mmap_fixed_noaccess_b P FL (Z_to_bv 64 0) = true))).
  { destruct isnone; subst prot; [right; left; split; reflexivity | left; reflexivity]. }
  assert (PR : (0 <= prot < 4)%Z) by (destruct isnone; subst prot; lia). clearbody prot.
  apply impl_enode.
  carve_frame 64%nat ST.
  do 8 step.
  step. step. if_cases K0; zify_cond K0. 2:{ exfalso. rewrite ?unsigned_lit in K0 by lia. lia. } clear K0.
  step. step. step. if_cases K1; zify_cond K1. 2:{ exfalso. rewrite ?unsigned_lit in K1 by lia. lia. } clear K1.
  step. step. if_cases K2; zify_cond K2. { exfalso. rewrite ?unsigned_lit in K2 by lia. lia. } clear K2.
  step. step.
  step. step. step_ecall.
  split. { at_node_solve. all: first [exact SH1 | exact SH3 | reflexivity]. }
  intros rsp ans Hdec.
  assert (D : match ans with
              | MmErr e => strip rsp = efferr e /\ (1 <= e <= 4095)%Z
              | MmOk a => strip rsp = (if isnone then mkEffectU (Z_to_bv 64 a) [] [] [(wa a, Z_to_bv 64 (mmap_len len))] [] []
                                 else mkEffect (Z_to_bv 64 a) [] [(wa a, Z_to_bv 64 (mmap_len len))])
                          /\ mmap_addr_ok len avoid a = true
              end).
  { destruct isnone; [pose proof (dec_mmap_none_Some _ _ _ _ Hdec) as D | pose proof (dec_mmap_Some _ _ _ _ Hdec) as D];
      destruct ans; exact D. }
  clear Hdec. destruct ans as [e|x].
  - clear MU1. destruct D as [Hs He]. sys_nret.
    step. step. step.
    rewrite unsigned_errno_ret, zb_lxor_ones, Z.lor_0_l by lia.
    if_cases K; zify_cond K.
    +
      step. call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia | ]. rename PC into ST; rename POST into ERR.
      unfold sysret_val, sysret_errno in *. rewrite errno_of_errno_ret in * by lia.
      do 10 step. release_frame FR ST (bv_unsigned sp).
      unfold p0mmap_anon_post, mmap_fix_errno. replace (e =? 1)%Z with false by (symmetry; apply Z.eqb_neq; lia).
      finish; lia.
    +
      rewrite ?unsigned_lit in K by lia.
      step. step. step. step.
      replace (Z_to_bv 64 18446744073709551604) with (errno_ret 12) by (apply bv_eq; reflexivity).
      step. call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia | ]. rename PC into ST; rename POST into ERR.
      unfold sysret_val, sysret_errno in *. rewrite errno_of_errno_ret in * by lia.
      do 10 step. release_frame FR ST (bv_unsigned sp).
      unfold p0mmap_anon_post, mmap_fix_errno. replace (e =? 1)%Z with true by (symmetry; apply Z.eqb_eq; lia).
      finish; lia.
  - clear MU. destruct D as [Hs Hok]. pose proof (mmap_addr_ok_true _ _ _ Hok) as ((XA & X0 & XCmax) & XAV).

    destruct (Z.lt_ge_cases alloc_ceiling (x + mmap_len len)) as [BAD|XC].
    { apply evt_done. unfold p0mmap_anon_post. split; [exact Hok| left; exact BAD]. }
    pose proof alloc_ceiling_bounds. pose proof (mmap_len_ge len) as ML.
    lazymatch goal with |- context [nret (MSsvc _ _ _ _ _ _ ?mc _) _] => rename mc into m2 end || idtac.
    destruct isnone; sys_nret_raw.
    all: lazymatch goal with |- evt _ _ (MS _ _ _ _ _ ?mm _) =>
           set (m' := mm);
           assert (Hza : (0 <= x < 2^64)%Z) by lia; assert (Hzn : (0 <= mmap_len len < 2^64)%Z) by lia;
           assert (Hzan : (x + mmap_len len <= 2^64)%Z) by lia
         end.
    1: pose proof (rw_cells_unmaps_other rsegs _ x (mmap_len len) Hza Hzn Hzan _ _ FR ltac:(cbn; lia)) as FR';
       pose proof (stk_unmaps_other rsegs _ x (mmap_len len) Hza Hzn Hzan _ _ ST ltac:(lia)) as ST'.
    2: pose proof (rw_cells_zeros_other rsegs _ x (mmap_len len) Hza Hzn Hzan _ _ FR ltac:(cbn; lia)) as FR';
       pose proof (stk_zeros rsegs _ x (mmap_len len) Hza Hzn Hzan _ _ ST) as ST'.
    all: fold m' in FR', ST'; clear FR; rename ST into ST0.
    all: step; step; step.
    all: rewrite zb_lxor_ones, Z.lor_0_l by (rewrite ?unsigned_lit by lia; lia); rewrite ?unsigned_lit by lia.
    all: if_cases K; zify_cond K; rewrite ?land_ones64 in K by lia; [| exfalso; lia].

    all: step; step; step; step; if_cases K1; zify_cond K1; [| exfalso; rewrite ?unsigned_lit in K1 by lia; lia]; step.

    all: do 9 step; release_frame FR' ST' (bv_unsigned sp); step.
    all: apply evt_done; unfold p0mmap_anon_post, mmap_raw; cbv iota; split; [exact Hok|]; right.
    all: do 14 eexists; eexists; split; [subst m'; reflexivity|].
    all: split; [exact MU1|]; split; [exact WM|]; split; [exact MI|]; split; [exact ST'|]; exact ERR.
Qed.

Definition p0mmap_fixed_post {X} (R : X -> word -> bool -> Prop)
    (ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 : word) (F : bvmap 5 word) (fc : bv 32)
    (A L : Z) (errv : word) (lo : Z) (m : word -> option byte) (a : X) : machine_state -> Prop :=
  fun ms' => exists (r : word) (u : bool) t0 t1 t2 a1 a2 a3 a4 a5 a6 a7 t3 t4 t5 t6 m',
    R a r u /\
    ms' = MS (mkR ra sp gp tp t0 t1 t2 s0 s1 (sysret_val r) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
             F (ret_pc ra) fc None m' (seg_rom rsegs)
    /\ munch [(bv_unsigned sp - 96, bv_unsigned sp); (errno_addr tp, errno_addr tp + 4); (A, A + mmap_len L)]%Z m m'
    /\ (u = false -> wmono rsegs m m')
    /\ mem_inv rsegs m'
    /\ stk rsegs m' lo (bv_unsigned sp)
    /\ rw_cells rsegs m' (errno_addr tp) [C4 (sysret_errno r errv)]
    /\ rw_cells rsegs m' P0_VMLOCK [C4 (Z_to_bv 64 0)].

Lemma p0mmap_fixed_spec : forall {X} (dec : resp -> option X) (R : X -> word -> bool -> Prop)
    ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F fc m
    (A L : Z) (errv : word) (lo : Z),
  (forall rsp a, dec rsp = Some a -> exists r u, R a r u /\ strip rsp = fixed_shape A L r u) ->
  stk rsegs m lo (bv_unsigned sp) ->
  rw_cells rsegs m (errno_addr tp) [C4 errv] ->
  rw_cells rsegs m P0_VMLOCK [C4 (Z_to_bv 64 0)] ->
  mem_inv rsegs m ->
  a0 = Z_to_bv 64 A -> a1 = Z_to_bv 64 L -> a2 = Z_to_bv 64 PROT_NONE -> a3 = Z_to_bv 64 50 ->
  a4 = Z_to_bv 64 (-1) -> a5 = Z_to_bv 64 0 ->
  (0 < A)%Z -> (0 < L <= 2^62)%Z -> (A + mmap_len L < 2^64)%Z ->
  (lo <= bv_unsigned sp - 96)%Z -> (P0_IMG_HI <= lo)%Z ->
  (errno_addr tp + 4 <= bv_unsigned sp - 96 \/ bv_unsigned sp <= errno_addr tp)%Z ->
  (A + mmap_len L <= lo \/ bv_unsigned sp <= A)%Z ->
  (A + mmap_len L <= errno_addr tp \/ errno_addr tp + 4 <= A)%Z ->
  (errno_addr tp + 4 <= P0_VMLOCK \/ P0_VMLOCK + 4 <= errno_addr tp)%Z ->
  ((A + mmap_len L <= P0_IMG_LO \/ P0_RO_HI <= A) /\ (A + mmap_len L <= 0x1b000 \/ P0_IMG_HI <= A))%Z ->
  (164 <= bv_unsigned tp)%Z ->
  impl rsegs (at_node rsegs) (enode (NMmap A L PROT_NONE 50) dec)
       (epost (p0mmap_fixed_post R ra sp gp tp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 F fc A L errv lo m))
       (MS (mkR ra sp gp tp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
           F (Z_to_bv 64 0x14ec0) fc None m (seg_rom rsegs)).
Proof.
  intros until lo. intros DEC ST ERR VL MI -> -> -> -> -> -> A0 LEN AL LO ILO SEP1 SEP2 SEP3 SEPE [SEPA1 SEPA2] TP.
  pose proof (munch_refl [(bv_unsigned sp - 96, bv_unsigned sp); (errno_addr tp, errno_addr tp + 4); (A, A + mmap_len L)]%Z m) as MU.
  pose proof (wmono_refl rsegs m) as WM.
  pose proof (mmap_len_ge L) as ML.
  assert (SH1 : w_is0 (Z_to_bv 64 L) = false) by (rewrite w_is0_lit by lia; apply Z.eqb_neq; lia).
  apply impl_enode.
  carve_frame 64%nat ST.
  do 8 step.
  step. step. if_cases K0; zify_cond K0. 2:{ exfalso. rewrite ?unsigned_lit in K0 by lia. lia. } clear K0.
  step. step. step. if_cases K1; zify_cond K1. 2:{ exfalso. rewrite ?unsigned_lit in K1 by lia. lia. } clear K1.
  step. step. if_cases K2; zify_cond K2. 2:{ exfalso. rewrite ?unsigned_lit in K2 by lia. lia. } clear K2.

  set (z0 := Z_to_bv 64 0). set (zm1 := Z_to_bv 64 (-1)). set (z50 := Z_to_bv 64 50).
  set (zA := Z_to_bv 64 A). set (zL := Z_to_bv 64 L). set (zP := Z_to_bv 64 PROT_NONE).
  do 6 step. step.
  call_sp vm_wait_spec; [exact ST | exact VL | exact MI | lia | lia | ]. rename POST into ST.
  lazymatch goal with H : mem_inv rsegs _ |- _ => rename H into MI end.
  do 6 step. step.
  subst z0 zm1 z50 zA zL zP.
  step. step. step_ecall.
  split. { at_node_solve. all: first [exact SH1 | reflexivity | right; right; repeat split; reflexivity]. }
  intros rsp ans Hdec. destruct (DEC rsp ans Hdec) as (r & u & HR & Hs). clear Hdec.
  pose proof (bv_unsigned_in_range 64 r) as RR. change (bv_modulus 64) with (2^64)%Z in RR.
  destruct u; unfold fixed_shape in Hs; cbv iota in Hs.
  all: sys_nret.
  all: step; step; step.
  all: if_cases K; zify_cond K; [| exfalso; apply Z.lor_eq_0_iff in K; lia ].
  all: step; call_sp sysret_spec; [exact ST | exact ERR | exact MI | lia | lia | lia |]; rename PC into ST; rename POST into ERR.
  all: do 10 step; release_frame FR ST (bv_unsigned sp).
  all: unfold p0mmap_fixed_post; apply evt_done; exists r; eexists; do 15 eexists; split; [exact HR|]; split; [reflexivity|].
  all: split; [ eapply munch_weaken; [|exact MU]; intros y; cbn; lia |].
  all: split; [ first [intros; discriminate | intros _; assumption] |].
  all: split; [lazymatch goal with H : mem_inv rsegs ?mm |- mem_inv rsegs ?mm => exact H end|].
  all: split; [lazymatch goal with H : stk rsegs ?mm ?a ?b |- stk rsegs ?mm _ _ => exact H end|].
  all: split; [lazymatch goal with H : rw_cells rsegs ?mm ?a [C4 (sysret_errno _ _)] |- _ => exact H end|].
  all: lazymatch goal with H : rw_cells rsegs ?mm 318636%Z ?c |- _ => exact H end.
Qed.




