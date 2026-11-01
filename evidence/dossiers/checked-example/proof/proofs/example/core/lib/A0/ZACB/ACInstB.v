(* Copyright 2026 Anthropic PBC *)
(* SPDX-License-Identifier: Apache-2.0 OR MIT *)
(* Modified by Theorem Labs, 2026-10: ported to the binaries of release 2026.10.0 and LPS 2afba80c; the theorem statements are restated in the form this release states them. *)
(* Copied 2026-10-30 into example/core for a replay study: module paths changed (and, with --rename, addresses). *)
(* [comment removed for export] *)
From Stdlib Require Import ZArith NArith List Lia Bool Permutation.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType State Run.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import PropExec MState Mem Exec Tac Arr Bytes ZBridge Frame ITree Nodes Decode Ceiling.
From OssFuzzTheorems.Proofs.example.core.lib.Lib Require Import VmGap.
From OssFuzzTheorems.Proofs.example.core.lib.Http Require Import HttpRep HttpTac.
From OssFuzzTheorems.Proofs.example.core.lib.Top Require Import AllocIF Realize SafeReach Bridge.
From OssFuzzTheorems.Proofs.example.core.lib.ASN Require Import AsanAcct.
From OssFuzzTheorems.Proofs.example.core.lib.LZ Require Import ITreeLZ BridgeLZ NodesLZ NodesLZSound NodesLZMm.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAW Require Import Segs Shadow Contracts AllocA0 ATac.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAA Require Import AEnv ADepot ALayout APrim LJ PEnv APrimSpec APrimSpec2 ASec AQuar AQuarM AHeap F_quar_E F_quar_P F_free_icpt F_free_null F_malloc_icpt F_alloc_A F_alloc_P F_alloc_S1 F_sec_A AMallocP AMallocL8 AAllocL8 AMallocGL8 AAllocSL8 ABudgetL8 ABudgetInst AUsedStatic AVaOfM AHeapPg ALinkSec ALinkAvoid AFsEnv ALedger AHeap2 AHeapB AFreeL8 ALinkPg ALinkVm ALink ALinkPrim ALinkFree ALinkFreeIn AVaOf AHeapLaws AHeapInst APureInv ASecPlace ARoom.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAA Require Import AEnv ADepot ALayout APrim ATacA ACells LJ LJU PEnv APrimSpec APrimSpec2 APrimLem AFrame APrimPop APrimPopR APrimPopLens APrimQ APrimFrame AFrameM APrimDealloc APrimCover ASec ASecD AQuar AQuarM AHeap AFoot F_prim_refill F_prim_cdealloc F_poison F_quar_Ep F_quar_E F_quar_A AQuarR AQuarS AQuarP ATacFix F_quar_M F_quar_DR F_quar_R F_quar_D F_sec_A F_sec_B F_quar_P AQuarT AQuarU F_gct F_depot F_depot_C F_quar_C F_prim_L0 F_hooks F_dealloc F_ialloc F_unwind F_stacktrace F_free_icpt F_free_null F_alloc_env F_alloc_A F_alloc_B F_alloc_C AAllocInv AAllocCarve AAllocEnvF F_alloc_P F_alloc_M F_malloc_icpt F_memcpy ALedger AHeap2 AHeapB AFreeF AFreeZ AFreeL8 AAllocF AMallocP AMallocL8 AAllocL8 AHeapLaws.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAA Require Import ASecPlace ARoom APureInv.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAA Require Import F_malloc_top F_free_top.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZAC Require ACInst.
From OssFuzzTheorems.Proofs.example.core.lib.A0.ZACM Require ACInstM.
From OssFuzzTheorems.Proofs.example.core.lib.A0.T7 Require Import RealizeS A0Prog SeamA0.
Import ListNotations.
Import ITree.Exc.
Open Scope Z_scope.
Section AC.
Context {HC : HasCeiling}.
Variables (AL : alayout) (E : penv) (FI : fs_if) (Bs : vmbase).
Hypothesis AO : alayout_ok AL.
Hypothesis FSBE : FSB FI = al_fsb AL.
Hypothesis SP0S : alloc_ceiling + 2^23 + 184 <= 2^47.
Hypothesis BO : base_ok Bs.
Hypothesis SPACE_EQ : vb_space Bs = al_space AL.
Hypothesis SPACE_AL : al_space AL mod 65536 = 0.
Hypothesis SWIN_LO : 65536 <= SWIN (al_depot AL).

Hypothesis FSEI : forall m, thread_env (al_thread AL) m -> AFsEnv.fs_tls_env (at_thr (al_thread AL)) AFsEnv.A0_DTV AFsEnv.A0_TLSB (al_dtls AL) (al_fsb AL) m -> FSENV FI m.

Notation AIB := (AI_B AL E FI Bs AO FSBE SP0S FSEI).
Notation JB := (JA FI AIB).
Notation kept mo mo' := (m_fds mo' = m_fds mo /\ m_fs mo' = m_fs mo).

Hypothesis REG_BASE : Forall (fun rg => exists e, In e (vb_maps Bs) /\ vlo e <= fst rg /\ fst rg + snd rg <= vhi e) (al_regions AL).
Hypothesis PARR_BASE : exists e, In e (vb_maps Bs) /\ vlo e <= al_parr AL /\ al_parr AL + 2^23 <= vhi e.

Hypothesis VBU : vb_used Bs = 2477224960.
Hypothesis VBG : vb_gapB Bs = 137478443008.
Hypothesis VBN : vb_gapN Bs = 16.

#[using="Type"] Lemma mclean_of_seam : forall (H : word -> bool) (m : mem),
  (forall x, H x = true -> m x = None) -> H_off_segments asegs H -> mclean H m.
Proof. intros H m C O. split; assumption. Qed.

#[using="VBU"] Lemma free_room_ok : ACInst.free_room AL E Bs.
Proof.
  intros s LB m ch n l1 l2 HR EL. cbv zeta.
  destruct (free_link_inputs AL E s LB m ch n l1 l2 (va_of s) HR EL (va_of_linked s)) as (_ & _ & RB & _). cbv zeta in RB.
  exact (room_free AL Bs VBU s (va_of s) ch (pure_inv_of_rheap AL E s LB m HR) eq_refl (rest_le AL E s LB m HR) RB).
Qed.

#[using="VBU"] Lemma malloc_room_prim_ok : ACInstM.malloc_room_prim AL E Bs.
Proof.
  intros s LB m c HR CR C0.
  exact (room_refill AL Bs VBU s (va_of s) c (pure_inv_of_rheap AL E s LB m HR) CR C0 eq_refl (rest_le AL E s LB m HR)).
Qed.

#[using="Type"] Lemma sec_msize_le : forall n, 0 <= n <= A0_MAXREQ -> 65536 < a0_need n -> 0 <= sec_msize (al_sneed n) <= n + 16384.
Proof.
  intros n NR NS. destruct (al_sec_facts n NR NS) as (N1 & _ & ERZ & _ & _ & _ & (rk & NEED & RK & _)).
  unfold sec_msize, rup4k, al_sneed. rewrite ERZ, NEED. unfold A0_MAXREQ in NR. clear - RK N1 NR. Z.div_mod_to_equations. lia.
Qed.

#[using="VBU VBG VBN"] Lemma malloc_room_sec_ok : ACInstM.malloc_room_sec AL E Bs.
Proof.
  intros s LB m n HR NR NS BUD. cbv zeta.
  destruct (budgetZ_sec AL E s LB m n HR NS BUD) as (_ & BC & BB & BN).
  exact (room_sec AL E Bs VBU VBG VBN s LB m n _ HR BC BB BN (sec_msize_le n NR NS) (proj2 NR)).
Qed.





#[using="Type"] Lemma trin_malloc_top : In [PC0_MALLOC] A0_TRACES. Proof. unfold A0_TRACES. repeat first [left; reflexivity | right]. Qed.
#[using="Type"] Lemma trin_free_top : In [PC0_FREE] A0_TRACES. Proof. unfold A0_TRACES. repeat first [left; reflexivity | right]. Qed.

#[using="BO SPACE_EQ SPACE_AL SWIN_LO"] Lemma ac_malloc_top_prim : ACInstM.malloc_room_prim AL E Bs ->
  forall (ra : word) (q : Z) (gp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 : word)
         (F_ : bvmap 5 word) (fc : bv 32) (m : mem) (s : astB) (LB : list (block Z)) (st : fsstate FI) (n lo : Z),
  RHEAP_B AL E s LB m -> asan_env asegs m -> RFAKE FI st m ->
  stk asegs m lo q -> alloc_ceiling <= lo -> lo <= q - 4096 -> q mod 16 = 0 -> at_top (al_thread AL) <= q + 16 -> q <= alloc_ceiling + 8388608 ->
  mem_inv asegs m ->
  0 <= n <= A0_MAXREQ -> budgetZ s LB n -> a0_need n <= 65536 ->
  AJ FI AIB JB (malloc_post_A FI AIB ra q gp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 F_ fc st s LB n lo m)
    (MS (mkR ra (wz q) gp (wz A0_TP) t0 t1 t2 s0 s1 (wz n) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
        F_ (wz A0_malloc) fc None m (seg_rom asegs))
    s LB.
Proof.
  intros ROOM ra q gp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F_ fc m s LB st n lo
         HR AE RF ST CLO LOQ Q16 QTOP QSP MI NR BUD NP.
  set (c := class_of (a0_need n)) in *. set (P := bs_prim s) in *.
  assert (CR : 1 <= c <= 31).
  { unfold c. rewrite class_of_a0. assert (1 <= a0_need n) by (unfold a0_need; assert (8 <= (Z.max n 8 + 7) / 8 * 8) by (Z.div_mod_to_equations; lia);
      assert (0 <= Z.shiftl 16 (a0_rzlog n)) by (apply Z.shiftl_nonneg; lia); lia). pose proof (a0_class_of_range (a0_need n) ltac:(lia)). lia. }
  assert (LEN : length (pr_cls P) = 32%nat) by (destruct (rheap_pinv AL E s LB m HR) as (LEN & _); exact LEN).
  pose proof (budgetZ_prim s LB n ltac:(lia) NP BUD) as CAP. fold c in CAP.
  assert (AS0 : 0 <= ALLOC_STACK) by (vm_compute; discriminate). assert (AS1 : ALLOC_STACK <= 1888) by (vm_compute; discriminate).
  set (v := va_of s). set (v' := mkVA (va_prim v + D_calloc P c) (va_chunks v) (va_nsec v) (va_aux v)).
  cbn [AJ JA].
  eapply (AJA_of_implL FI AIB (mp_tree AL P n)
            (epostL (micpt_post (al_thread AL) gp s6 s7 s8 s9 s10 s11 F_ fc q lo ra unit
                       (ma8_cpost AL E FI AIB unit (fun _ : unit => (fst (cache_alloc P c), bs_sec s)) 0 q s LB st n m) s0 s1 s2 s3 s4 s5 m))
            (fun mo r mo' => r = Ok tt /\ LINK Bs v' mo' /\ kept mo mo')).
  -
    intros CL HOFF. cbn [ms_mem] in CL.
    exact (malloc_walk_top AL E FI AIB AO FSBE unit (mp_tree AL P n) (fun _ : unit => (fst (cache_alloc P c), bs_sec s)) 0 ALLOC_STACK AS0 AS1
             gp s6 s7 s8 s9 s10 s11 F_ fc q lo ra t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 t3 t4 t5 t6 s LB m st n
             HR (mclean_of_seam _ _ CL HOFF) MI AE RF ST CLO LOQ Q16 QTOP QSP NR
             (alloc_prim_L8 AL E FI AIB AO SWIN_LO FSBE (fun lo' hi' X => X) s LB st n [PC0_MALLOC] q lo CLO trin_malloc_top NR NP CAP)).
  -
    intros mo LF VM. cbn [am_vm AI_B] in VM. pose proof (LINK_of_LINKvm Bs _ _ VM) as LK. fold v in LK.
    unfold mp_tree. fold P c. unfold v', D_calloc. destruct (p_cnt (get_cls P c) =? 0) eqn:EC.
    + apply (link_refill Bs AL BO SPACE_EQ SPACE_AL v _ c (get_cls P c)); [exact LK| exact CR| | | |].
      * exact (rheap_wf AL E s LB m HR c CR).
      * exact (rheap_refill_budget AL E s LB m HR c CR).
      * exact (ROOM s LB m c HR CR (proj1 (Z.eqb_eq _ _) EC)).
      * intros mo' LK' KP. split; [reflexivity|]. split; [exact LK'| exact KP].
    + unfold t_none. apply stwf_ret. split; [reflexivity|]. split; [| split; reflexivity].
      assert (EV : forall w : vabs, mkVA (va_prim w + 0) (va_chunks w) (va_nsec w) (va_aux w) = w) by (intros [wa wb wc wd]; cbn; f_equal; lia).
      rewrite EV. exact LK.
  - intros moE r moE' (_ & _ & K1 & K2). split; congruence.
  -
    intros r H' P' msr' moE moE' VM0 QW (-> & LK' & KP). cbn [epostL] in QW.
    destruct (malloc_conv AL E FI AIB unit (fun _ : unit => (fst (cache_alloc P c), bs_sec s)) 0 gp s6 s7 s8 s9 s10 s11 F_ fc q lo ra s0 s1 s2 s3 s4 s5 s LB m st n tt H' msr' QW)
      as (s1' & u0 & u1 & u2 & b1 & b2 & b3 & b4 & b5 & b6 & b7 & u3 & u4 & u5 & u6 & m' & A & junk & EMS & GH & EX & EQ & ENS & ELA & MI' & STK' & AE' & RF' & AP' & HR' & NB & NSH & WMo).
    exists (set_pages s1' P'), ((A, A, n) :: LB).
    split; [cbn [am_ghost AI_B]; rewrite set_pages_ghost; pose proof (f_equal fst GH) as GH1; unfold bs_ghost in GH1; cbn [fst] in GH1; rewrite GH1; reflexivity|].
    split.
    { cbn [am_vm AI_B]. rewrite set_pages_va. apply LINKvm_of_LINK.
      rewrite (malloc_prim_va_of s s1' c CR LEN EX ENS). exact LK'. }
    unfold malloc_post_A. exists u0, u1, u2, b1, b2, b3, b4, b5, b6, b7, u3, u4, u5, u6, m', A, A, junk.
    split; [exact EMS|]. split.
    { unfold alloc_frame_A. split; [exact MI'|]. split; [exact STK'|]. split; [exact AE'|]. split; [exact RF'|].
      apply AP'. intros b Hb. destruct HR as (PLB & _). pose proof (Permutation_in _ PLB Hb) as Hb'.
      apply in_map_iff in Hb' as (r0 & <- & Hr). exists r0. split; [exact Hr|]. split; reflexivity. }
    split; [reflexivity|]. split; [exact (RHEAP_B_set_pages AL E s1' P' _ m' HR')|]. split; [exact NB|]. split; [exact NSH|]. split; [exact WMo|].
    cbn [am_nsec AI_B]. rewrite set_pages_nsec, ENS. rewrite (proj2 (Z.eqb_neq _ _) (a0_cls_prim_nz n ltac:(lia) NP)). reflexivity.
Qed.

#[using="BO SWIN_LO REG_BASE PARR_BASE"] Lemma ac_malloc_top_sec : ACInstM.malloc_room_sec AL E Bs ->
  forall (ra : word) (q : Z) (gp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 : word)
         (F_ : bvmap 5 word) (fc : bv 32) (m : mem) (s : astB) (LB : list (block Z)) (st : fsstate FI) (n lo : Z),
  RHEAP_B AL E s LB m -> asan_env asegs m -> RFAKE FI st m ->
  stk asegs m lo q -> alloc_ceiling <= lo -> lo <= q - 4096 -> q mod 16 = 0 -> at_top (al_thread AL) <= q + 16 -> q <= alloc_ceiling + 8388608 ->
  mem_inv asegs m ->
  0 <= n <= A0_MAXREQ -> budgetZ s LB n -> 65536 < a0_need n ->
  AJ FI AIB JB (malloc_post_A FI AIB ra q gp s0 s1 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 F_ fc st s LB n lo m)
    (MS (mkR ra (wz q) gp (wz A0_TP) t0 t1 t2 s0 s1 (wz n) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
        F_ (wz A0_malloc) fc None m (seg_rom asegs))
    s LB.
Proof.
  intros ROOM ra q gp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F_ fc m s LB st n lo
         HR AE RF ST CLO LOQ Q16 QTOP QSP MI NR BUD NS.
  destruct (budgetZ_sec AL E s LB m n HR NS BUD) as (WMAX & BC & BB & BN).
  destruct (ROOM s LB m n HR NR NS BUD) as (VR & GR). cbv zeta in VR, GR.
  destruct (ACInstM.sec_msize_facts AL n NR NS) as (NM1 & NM2 & NM3 & NML). cbv zeta in NM1, NM2, NM3, NML.
  set (S := bs_sec s) in *. set (size := al_sneed n) in *. set (nm := sec_msize size) in *. set (v := va_of s) in *.
  set (avoid := ACInstM.sec_avoid AL s lo q).
  pose proof HR as (_ & _ & _ & INVB & _). destruct INVB as (_ & _ & RS & _). pose proof RS as ((W0a & W0m & W0b & _) & _). unfold bs_X in W0a, W0m, W0b. cbn [snd] in W0a, W0m, W0b. fold S in W0a, W0m, W0b.
  assert (AS0 : 0 <= ALLOC_STACK) by (vm_compute; discriminate). assert (AS1 : ALLOC_STACK <= 1888) by (vm_compute; discriminate).
  assert (AIN : In (lo, q) avoid) by (left; reflexivity).
  assert (AREG : Forall (fun rg : Z * Z => In (fst rg, fst rg + snd rg) avoid) (al_regions AL)).
  { apply Forall_forall. intros rg Hrg. right. apply in_or_app. left. exact (in_map (fun rg0 : Z * Z => (fst rg0, fst rg0 + snd rg0)) _ rg Hrg). }
  assert (ACH : Forall (fun c => In (sc_beg c, sc_beg c + sc_msize c) avoid) (se_chunks S)).
  { apply Forall_forall. intros c0 Hc0. right. apply in_or_app. right. apply in_map_iff. exists (cpair c0). split; [reflexivity|].
    unfold v, va_of. cbn [va_chunks]. apply in_map. exact Hc0. }
  cbn [AJ JA].
  eapply (AJA_of_implL FI AIB (sec_alloc_tree AL S size avoid)
            (epostL (micpt_post (al_thread AL) gp s6 s7 s8 s9 s10 s11 F_ fc q lo ra Z
                       (ma8_cpost AL E FI AIB Z (fun a : Z => (bs_prim s, sec_alloc S a size)) 1 q s LB st n m) s0 s1 s2 s3 s4 s5 m))
            (fun mo r mo' => exists a, r = Ok a /\ LINK Bs (va_sec_alloc v S a nm) mo' /\ kept mo mo')).
  - intros CL HOFF. cbn [ms_mem] in CL.
    exact (malloc_walk_top AL E FI AIB AO FSBE Z (sec_alloc_tree AL S size avoid) (fun a : Z => (bs_prim s, sec_alloc S a size)) 1 ALLOC_STACK AS0 AS1
             gp s6 s7 s8 s9 s10 s11 F_ fc q lo ra t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 t3 t4 t5 t6 s LB m st n
             HR (mclean_of_seam _ _ CL HOFF) MI AE RF ST CLO LOQ Q16 QTOP QSP NR
             (alloc_sec_L8 AL E FI AIB AO SWIN_LO FSBE (fun lo' hi' X => X) s LB st n [PC0_MALLOC] q lo avoid lo q CLO trin_malloc_top NR NS AIN ltac:(lia) ltac:(lia)
                AREG ACH WMAX BC BB BN)).
  - intros mo LF VM. cbn [am_vm AI_B] in VM. pose proof (LINK_of_LINKvm Bs _ _ VM) as LK. fold v in LK.
    apply (link_sec_alloc Bs AL BO v _ S size avoid); [exact LK| cbv zeta; fold nm; rewrite NML; exact NM1| | | | |].
    + exact (link_avoid_ok Bs v _ lo q (al_regions AL) LK CLO REG_BASE).
    + cbv zeta. fold nm. rewrite NML. exact VR.
    + cbv zeta. fold nm. rewrite NML. exact GR.
    + intros EQN. destruct PARR_BASE as (e & EIN & E1 & E2).
      layout_facts AO 1%nat LP. destruct LP as ((PL1 & _) & PCE & _).
      pose proof (Z.div_mod (se_nres S) 16384 ltac:(lia)) as DM. rewrite W0m in DM.
      assert (STEP : 8 * se_nres S + 131072 <= 8388608) by (clear - EQN WMAX W0a DM; lia). change (2^23) with 8388608 in *.
      split; [exists e; split; [exact EIN| clear - E1 E2 STEP W0a; split; lia]|]. clear - PL1 PCE STEP W0a. repeat split; lia.
    + intros a mo' CS CE LK' KP. exists a. split; [reflexivity|]. cbv zeta in LK'. fold nm in LK'. rewrite NML in LK'. split; [exact LK'| exact KP].
  - intros moE r moE' (a & _ & _ & K1 & K2). split; congruence.
  - intros r H' P' msr' moE moE' VM0 QW (a & -> & LK' & KP). cbn [epostL] in QW.
    destruct (malloc_conv AL E FI AIB Z (fun a0 : Z => (bs_prim s, sec_alloc S a0 size)) 1 gp s6 s7 s8 s9 s10 s11 F_ fc q lo ra s0 s1 s2 s3 s4 s5 s LB m st n a H' msr' QW)
      as (s1' & u0 & u1 & u2 & b1 & b2 & b3 & b4 & b5 & b6 & b7 & u3 & u4 & u5 & u6 & m' & A & junk & EMS & GH & EX & EQ & ENS & ELA & MI' & STK' & AE' & RF' & AP' & HR' & NB & NSH & WMo).
    exists (set_pages s1' P'), ((A, A, n) :: LB).
    split; [cbn [am_ghost AI_B]; rewrite set_pages_ghost; pose proof (f_equal fst GH) as GH1; unfold bs_ghost in GH1; cbn [fst] in GH1; rewrite GH1; reflexivity|].
    split.
    { cbn [am_vm AI_B]. rewrite set_pages_va. apply LINKvm_of_LINK.
      destruct (malloc_sec_va_of s s1' a size W0m W0a EX ENS) as (VP & VC & VN & VA). cbv zeta in VP, VC, VN, VA. fold S nm v in VP, VC, VN, VA.
      pose proof (LINK_perm Bs _ _ _ LK' VC) as LK2. rewrite VP, VN, VA in LK2. exact LK2. }
    unfold malloc_post_A. exists u0, u1, u2, b1, b2, b3, b4, b5, b6, b7, u3, u4, u5, u6, m', A, A, junk.
    split; [exact EMS|]. split.
    { unfold alloc_frame_A. split; [exact MI'|]. split; [exact STK'|]. split; [exact AE'|]. split; [exact RF'|].
      apply AP'. intros b Hb. destruct HR as (PLB & _). pose proof (Permutation_in _ PLB Hb) as Hb'.
      apply in_map_iff in Hb' as (r0 & <- & Hr). exists r0. split; [exact Hr|]. split; reflexivity. }
    split; [reflexivity|]. split; [exact (RHEAP_B_set_pages AL E s1' P' _ m' HR')|]. split; [exact NB|]. split; [exact NSH|]. split; [exact WMo|].
    cbn [am_nsec AI_B]. rewrite set_pages_nsec, ENS. rewrite (a0_cls_sec n NS). reflexivity.
Qed.

#[using="BO SPACE_EQ SPACE_AL SWIN_LO REG_BASE PARR_BASE VBU VBG VBN"] Theorem ac_malloc_top_B : malloc_top_stmt_A FI AIB JB.
Proof.
  pose proof malloc_room_prim_ok as ROOMP. pose proof malloc_room_sec_ok as ROOMS. unfold malloc_top_stmt_A.
  intros ra q gp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F_ fc m s LB st n lo
         HR AE RF ST CLO LOQ Q16 QTOP QSP MI EA0 NR BUD. subst a0. change (2^23) with 8388608 in QSP.
  change (RHEAP_A FI AIB s LB m) with (RHEAP_B AL E s LB m) in HR.
  change (am_stack_top FI AIB) with (at_top (al_thread AL)) in QTOP.
  change (am_budget FI AIB s LB n) with (budgetZ s LB n) in BUD.
  unfold A0_RT_STACK in LOQ.
  destruct (Z_le_gt_dec (a0_need n) 65536) as [NP|NS].
  - exact (ac_malloc_top_prim ROOMP ra q gp t0 t1 t2 s0 s1 (wz n) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F_ fc m s LB st n lo
             HR AE RF ST CLO LOQ Q16 QTOP QSP MI NR BUD NP).
  - exact (ac_malloc_top_sec ROOMS ra q gp t0 t1 t2 s0 s1 (wz n) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F_ fc m s LB st n lo
             HR AE RF ST CLO LOQ Q16 QTOP QSP MI NR BUD ltac:(lia)).
Qed.

#[using="SWIN_LO"] Lemma free_top_walk_at : forall (gp s6 s7 s8 s9 s10 s11 : word) (F_ : bvmap 5 word) (fc : bv 32) (q lo : Z)
    (ra t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 t3 t4 t5 t6 : word) s LB (m : mem) ch n l1 l2,
  RHEAP_B AL E s LB m -> mclean (bs_H s) m -> mem_inv asegs m -> bs_live s = l1 ++ (ch, n) :: l2 ->
  stk asegs m lo q -> alloc_ceiling <= lo -> lo <= q - 4096 -> q mod 16 = 0 -> at_top (al_thread AL) <= q + 16 -> q <= alloc_ceiling + 8388608 ->
    let X := bs_X s in let glob := q_glob (bs_quar s) in let loc := q_loc (bs_quar s) in
    let hrest := flat_map prim_of (map fst (l1 ++ l2)) in
    implA (bs_H s) (ebind (t_enq AL (fst X) loc) (fun _ => t_dorecycle AL (fst (enq_prim (fst X) loc), snd X) (put_todo (fst X) glob loc ch)))
      (ficpt_post AL E gp s6 s7 s8 s9 s10 s11 F_ fc q lo 262144 262728 ra s0 s1 s2 s3 s4 s5 X (bs_H s) m glob loc ch hrest (bs_depot s) (bs_dtotal s) [PC0_FREE])
      (MS (mkR ra (wz q) gp (wz A0_TP) t0 t1 t2 s0 s1 (wz (qc_hdr AL ch + 16)) a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6)
          F_ (wz free_icpt_entry) fc None m (seg_rom asegs)).
Proof.
  intros gp s6 s7 s8 s9 s10 s11 F_ fc q lo ra t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 t3 t4 t5 t6 s LB m ch n l1 l2 HR MC MI EL ST CLO LOQ Q16 QTOP QSP.
  destruct (free_pre_at AL E s LB m ch n l1 l2 HR MI EL) as (INV & HK & WFC & LREP & NSC & _).
  cbv zeta.
  pose proof (rheap_stats AL E s LB m HR) as (CA0 & CM0 & CM1). pose proof (rheap_refill_budget AL E s LB m HR K_BCLASS ltac:(lia)) as RB24.
  destruct HR as (PLB & LOK & AO' & _ & QLG & GC & QCL & MTX & (CST & AFM) & (FWF & QBL & QBG) & RD & DOK & _ & _ & _ & _ & _ & TE2 & HKE & TRE & AENV & (inited & IA) & _).
  pose proof alloc_ceiling_range as ACR. unfold alloc_floor, alloc_ceiling_max in ACR.
  assert (FWF' : Forall qbatch_wf (q_glob (bs_quar s) ++ q_loc (bs_quar s))) by (eapply Permutation_Forall; [apply Permutation_app_comm| exact FWF]).
  assert (LTR : (length [PC0_FREE] <= 30)%nat) by (cbn [length]; lia).
  destruct (depot_room AL _ _ _ [PC0_FREE] DOK LTR SWIN_LO) as (RN & RF & RT).
  eapply (free_top_spec AL E AO' gp s6 s7 s8 s9 s10 s11 F_ fc q lo ltac:(lia) CLO ltac:(unfold FICPT_STACK; exact LOQ) QTOP QSP Q16 262144 262728 eq_refl eq_refl
            ra t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 t3 t4 t5 t6 (bs_X s) (bs_H s) m (q_glob (bs_quar s)) (q_loc (bs_quar s)) ch _ (bs_dtotal s) (bs_depot s) inited);
    [ exact MC | exact ST | exact INV | exact HK | exact WFC | exact LREP | exact NSC | exact QLG | exact GC | exact QCL | exact MTX | exact CST | exact AFM | exact FWF'
    | rewrite qbytes_app; lia
    | exact RB24
    | exact CA0 | exact CM0 | exact CM1
    | apply Forall_app in FWF as [FWL _]; pose proof (qbytes_len _ FWL) as QL; lia
    | exact TE2 | exact HKE | exact TRE | exact IA | exact RD | exact RN | exact RF | exact RT ].
Qed.

#[using="BO SPACE_EQ SPACE_AL SWIN_LO VBU"] Theorem ac_free_top_B : free_top_stmt_A FI AIB JB.
Proof.
  pose proof free_room_ok as ROOM. unfold free_top_stmt_A.
  intros ra q gp t0 t1 t2 s0 s1 a0 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 s6 s7 s8 s9 s10 s11 t3 t4 t5 t6 F_ fc m s LB st k A n lo
         HR HIN AE RF ST CLO LOQ Q16 QTOP QSP MI EA0. subst a0. change (2^23) with 8388608 in QSP. pose proof trin_free_top as TRIN.
  change (RHEAP_A FI AIB s LB m) with (RHEAP_B AL E s LB m) in HR.
  change (am_stack_top FI AIB) with (at_top (al_thread AL)) in QTOP.
  destruct (free_pre AL E s LB m k A n HR MI HIN) as (ch & l1 & l2 & EL & EA & EK & _). subst A k.
  pose proof (free_link_inputs AL E s LB m ch n l1 l2 (va_of s) HR EL (va_of_linked s)) as LIN. cbv zeta in LIN.
  destruct LIN as (OKE & SOK & _ & _).
  destruct (ROOM s LB m ch n l1 l2 HR EL) as (ROOM1 & ROOM2). cbv zeta in ROOM1, ROOM2.
  set (P := bs_prim s) in *. set (glob := q_glob (bs_quar s)) in *. set (loc := q_loc (bs_quar s)) in *.
  set (X1 := (fst (enq_prim P loc), bs_sec s)) in *. set (todo := put_todo P glob loc ch) in *.
  set (v1 := va_enq (va_of s) P loc) in *. set (v' := va_dorecycle v1 X1 todo) in *.
  cbn [AJ JA].
  eapply (AJA_of_implL FI AIB
            (ebind (t_enq AL P loc) (fun _ => t_dorecycle AL X1 todo))
            (epostL (ficpt_post AL E gp s6 s7 s8 s9 s10 s11 F_ fc q lo 262144 262728 ra s0 s1 s2 s3 s4 s5 (bs_X s) (bs_H s) m glob loc ch
                                (flat_map prim_of (map fst (l1 ++ l2))) (bs_depot s) (bs_dtotal s) [PC0_FREE]))
            (fun mo r mo' => r = Ok tt /\ LINK Bs v' mo' /\ kept mo mo')).
  -
    intros CL HOFF. cbn [ms_mem] in CL.
    pose proof (free_top_walk_at gp s6 s7 s8 s9 s10 s11 F_ fc q lo ra t0 t1 t2 s0 s1 a1 a2 a3 a4 a5 a6 a7 s2 s3 s4 s5 t3 t4 t5 t6 s LB m ch n l1 l2
                  HR (mclean_of_seam _ _ CL HOFF) MI EL ST CLO ltac:(unfold A0_RT_STACK in LOQ; exact LOQ) Q16 QTOP QSP) as W. cbv zeta in W.
    exact W.
  -
    intros mo LF VM. cbn [am_vm AI_B] in VM.
    pose proof (LINK_of_LINKvm Bs _ _ VM) as LK.
    apply stwf_ebind. apply (link_enq Bs AL BO SPACE_EQ SPACE_AL (va_of s) _ P loc); [exact LK | |].
    + unfold ok_enq. intros ER. destruct (OKE ER) as (W24 & RB24). split; [exact W24|]. split; [exact RB24| exact (ROOM1 ER)].
    + intros mo1 L1 K1. fold v1 in L1.
      pose proof (vinv_of_LINK Bs _ _ L1) as VI1.
      destruct (room_dorecycle Bs AL todo v1 X1 VI1 SOK) as (_ & _ & _ & OKD).
      apply (link_dorecycle Bs AL BO SPACE_EQ SPACE_AL todo v1 mo1 X1); [exact L1 | apply (OKD 0 ltac:(lia)); rewrite Z.add_0_r; exact ROOM2 |].
      intros mo2 L2 K2. split; [reflexivity|]. split; [exact L2|]. destruct K1 as [K1a K1b]. destruct K2 as [K2a K2b]. split; congruence.
  - intros moE r moE' (_ & _ & K1 & K2). split; congruence.
  -
    intros r H' P' msr' moE moE' VM0 QW (-> & LK' & KP). cbn [epostL] in QW.
    destruct QW as (t0' & t1' & t2' & a0' & a1' & a2' & a3' & a4' & a5' & a6' & a7' & t3' & t4' & t5' & t6' & m' & W & hs' & total' & POST). cbv zeta in POST.
    destruct POST as (EMS & EH & MU & FW & INV' & XLE & STK' & QLG' & GC' & QCL' & MTX' & VNG & NBX & RD' & IA' & DEP).
    pose proof (law_blocks_nodup AL E AO s LB m HR) as NDK. apply NoDup_ListNoDup in NDK.
    pose proof (free_post_core AL E FI AIB FSBE (fun lo' hi' X => X) q lo s LB m ch n l1 l2 [PC0_FREE] st H' m' W hs' total' HR MI AE RF EL NDK CLO
                  ltac:(unfold A0_RT_STACK in LOQ; lia) TRIN) as CORE. cbv zeta in CORE.
    destruct (CORE MU FW INV' QLG' GC' QCL' MTX' VNG NBX RD' (ex_intro _ true IA') DEP) as (MI' & AE' & RF' & AP' & _ & HR').
    clear CORE.
    pose proof (free_va_of AL E s LB m ch n l1 l2 H' hs' total' HR EL) as VAO. cbv zeta in VAO.
    fold P glob loc in VAO, HR'. fold X1 in VAO, HR'. fold todo in VAO, HR'. fold v1 in VAO. fold v' in VAO.
    destruct VAO as (VP & VC & VN & VA).
    set (X' := dorecycle X1 todo) in *.
    exists (mkASB H' P' (fst X') (snd X') (mkAQ (put_loc P loc ch) (put_glob P glob loc ch)) hs' total' (bs_nsec s) (l1 ++ l2) (bs_depot0 s)).
    exists (lb_remove Z.eqb (qc_hdr AL ch + 16) LB).
    split; [reflexivity|]. split.
    + cbn [am_vm AI_B]. apply LINKvm_of_LINK.
      pose proof (LINK_perm Bs _ _ _ LK' VC) as LK2.
      rewrite VP, VN, VA in LK2. exact LK2.
    + unfold free_post_A. exists t0', t1', t2', a0', a1', a2', a3', a4', a5', a6', a7', t3', t4', t5', t6', m'.
      split; [exact EMS|]. split.
      { unfold alloc_frame_A. split; [exact MI'|]. split; [exact STK'|]. split; [exact AE'|]. split; [exact RF'|].
        apply AP'. destruct HR as (PLB & _). rewrite EL in PLB.
        exact (lbrest_desc AL LB l1 (ch, n) l2 PLB NDK). }
      split; [reflexivity|]. split; [exact HR'| reflexivity].
Qed.

Definition AC_B : am_contracts FI AIB JB :=
  {| ac_malloc := ACInstM.ac_malloc_B AL E FI Bs AO FSBE SP0S BO SPACE_EQ SPACE_AL SWIN_LO FSEI REG_BASE PARR_BASE malloc_room_prim_ok malloc_room_sec_ok;
     ac_free := ACInst.ac_free_B AL E FI Bs AO FSBE SP0S BO SPACE_EQ SPACE_AL SWIN_LO FSEI free_room_ok;
     ac_free_null := ACInst.ac_free_null_B AL E FI Bs AO FSBE SP0S FSEI;
     ac_malloc_top := ac_malloc_top_B;
     ac_free_top := ac_free_top_B |}.

End AC.
