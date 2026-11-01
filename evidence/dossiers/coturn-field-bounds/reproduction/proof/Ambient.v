From Stdlib Require Import ZArith List Bool Lia.
From LinuxProcessSemantics.LinuxProcessSem Require Import BvBase RiscvSemantics MemImageType.
From LinuxProcessSemantics.Riscv Require Import Prelude.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import PropExec.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib
  Require Import VLinalg VState VLogic VGamma VStepMemSound VState2 VGamma2 VCert VCert2.
From CoturnFieldAudit Require Import WitnessData Support Model Pure.
Import ListNotations. Open Scope Z_scope.
#[local] Existing Instance PropExec.fx0.


From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib Require Import Frame.
From OssFuzzTheorems.Proofs.coturn.FuzzStunClient.lib.Common Require Import StoreOk.
Open Scope Z_scope.
Lemma byte_lists_same (xs ys:list byte) : map bv_unsigned xs = map bv_unsigned ys -> xs=ys.
Proof.
 revert ys. induction xs as [|x xs IH];intros [|y ys] H;cbn in H;try discriminate;[reflexivity|].
 inversion H. f_equal;[apply bv_eq;assumption|apply IH;assumption].
Qed.
Lemma some_bytes_same (xs ys:list byte) :
 map bv_unsigned xs = map bv_unsigned ys -> Some xs = Some ys.
Proof. intro H. f_equal. apply byte_lists_same,H. Qed.

Definition rt_apartb (P : vparams2) (E : venv2) (a w : Z) :=
  zones_avoidb P E a (a+w) &&
  disjointb a (a+w) (e_sp0 (ev1 E)-vp_frame (p1 P)) (e_sp0 (ev1 E)) &&
  forallb (fun c => disjointb a (a+w) (fst c) (fst c+snd c)) (vp_fcells (p1 P)).
Lemma rt_apartb_sound P E a w : rt_apartb P E a w = true -> rt_apart P E a w.
Proof.
 unfold rt_apartb. rewrite !andb_true_iff. intros [[Hz Hs] Hc] x Hx.
 split; [apply (zones_avoidb_sound _ _ _ _ Hz);exact Hx|].
 split; [eapply disjointb_sound;eauto|].
 intros c H. rewrite forallb_forall in Hc. exact (disjointb_sound _ _ _ _ x (Hc c H) Hx).
Qed.

Ltac solve_rt_cell :=
 unfold rt_cell;split;[closed|];split;[closed|];split;[closed|];
 split;[apply rt_apartb_sound;closed|vm_compute;apply some_bytes_same;vm_compute;reflexivity].

Lemma selfpatch_frame_mod P E mem rs : frame_mod (zpatch P E mem mem) mem rs.
Proof.
 unfold frame_mod, mem_grows, zpatch. split; intros a H;
 destruct (in_rw_zones P E (bv_unsigned a)); auto.
Qed.

Lemma flags_bound fs c p : 0 <= c <= 4 -> 0 <= p < fs_nframes c ->
 fs+4096 <= flag_addr fs c p < fs+36864.
Proof.
 intros Hc Hp. assert (H : In c [0;1;2;3;4]) by (cbn;lia).
 finite_in H;
 match goal with |- _ <= flag_addr fs ?cid p < _ =>
  let n := eval vm_compute in (fs_nframes cid) in
  let q := eval vm_compute in (fs_flags_off cid) in
  change (0<=p<n) in Hp;
  change (fs+4096 <= fs+4096+q+p < fs+36864);lia end.
Qed.
Lemma flags_inj fs c p c' p' :
 0 <= c <= 4 -> 0 <= p < fs_nframes c ->
 0 <= c' <= 4 -> 0 <= p' < fs_nframes c' ->
 flag_addr fs c p = flag_addr fs c' p' -> c=c' /\ p=p'.
Proof.
 intros Hc Hp Hc' Hp' He.
 assert (H : In c [0;1;2;3;4]) by (cbn;lia).
 assert (H' : In c' [0;1;2;3;4]) by (cbn;lia).
 finite_in H; finite_in H';
 match type of He with flag_addr fs ?cid p = flag_addr fs ?cid' p' =>
  let n := eval vm_compute in (fs_nframes cid) in
  let n' := eval vm_compute in (fs_nframes cid') in
  let q := eval vm_compute in (fs_flags_off cid) in
  let q' := eval vm_compute in (fs_flags_off cid') in
  change (0<=p<n) in Hp;change (0<=p'<n') in Hp';
  change (fs+4096+q+p = fs+4096+q'+p') in He;split;lia end.
Qed.

Lemma asan_environment : env_ok2 asan_P asan_E.
Proof.
 unfold env_ok2. split; [unfold env_ok;closed|].
 split; [unfold env_data2;closed|]. split.
 - unfold env_fs.
   assert (Havoid : forall a, 2147975160 <= a < 2147975177 -> in_rw_zones asan_P asan_E a = false).
   { apply zones_avoidb_sound. closed. }
   repeat split; try (solve [intros _ _ a Ha;apply Havoid;exact Ha]);
     try (solve [repeat constructor;closed]); try closed.
   change (NoDup [(1,0)]). apply NoDup_cons_2;[intros H;inversion H|apply NoDup_nil_2].
 - split; [apply env_zonesb_sound;closed|].
   unfold env_kcells. split.
   + intros c x Hin Hx. finite_in Hin;
     match type of Hx with ?lo <= x < ?hi =>
       let l := eval vm_compute in lo in let h := eval vm_compute in hi in
       change (l<=x<h) in Hx;
       split; [apply (zones_avoidb_sound asan_P asan_E l h);[closed|exact Hx]
              |change (~ (140735339536400 <= x < 140735340871696));lia] end.
   + intros c x Hin Hx. finite_in Hin;
     match type of Hx with ?lo <= x < ?hi =>
       let l := eval vm_compute in lo in let h := eval vm_compute in hi in
       change (l<=x<h) in Hx;
       split; [lia|]; split;
       [apply (zones_avoidb_sound asan_P asan_E l h);[closed|exact Hx]
       |change (~ (140735339536400 <= x < 140735340871696));lia] end.
Qed.

Lemma asan_MC SEGS : MC SEGS (p1 asan_P) (ev1 asan_E)
  (zpatch asan_P asan_E asan_mem asan_mem) asan_mem.
Proof.
 unfold MC. split.
 - intros a Ha. change (140735339536400 <= a < 140735340871696) in Ha.
   destruct (witness_readable SEGS asan_pristine asan_runs
      140735339536400 140735340871696 ltac:(closed) ltac:(closed) ltac:(closed) a Ha) as [Hr Hw]. auto.
 - split.
   + intros i Hi. change (0<=i<1) in Hi. assert (i=0) by lia. subst.
     exists (Z_to_bv 8 0). vm_compute. reflexivity.
   + split.
     * intros lo hi a Hin Ha. apply (witness_pristine_at asan_pristine asan_runs lo hi (wordZ a));[exact Hin|].
       assert (Hb : 0<=a<2^64) by (finite_in Hin;lia).
       rewrite u_wordZ by exact Hb. exact Ha.
     * apply selfpatch_frame_mod.
Qed.

Lemma asan_kcells SEGS : kcells_hold SEGS asan_P asan_mem.
Proof.
 intros a w v Hin. finite_in Hin; repeat split; try closed;
 eexists; split; vm_compute; reflexivity.
Qed.
Lemma asan_kruns SEGS : kruns_hold SEGS asan_P asan_mem.
Proof.
 intros lo hi b Hin. finite_in Hin.
 all: split;[closed|];split;[closed|].
 all: intros a Ha;
 match type of Ha with ?l <= a < ?h =>
  let l' := eval vm_compute in l in let h' := eval vm_compute in h in
  change (l'<=a<h') in Ha;
  match goal with |- exists k : byte, _ /\ bv_unsigned k = Z.land ?bv 255 =>
  let b' := eval vm_compute in (Z.land bv 255) in
  exists (Z_to_bv 8 b');split;
  [apply read_one;apply (witness_mem_range asan_pristine asan_runs l' h' b');[closed|closed|closed|closed|exact Ha]|closed]
  end
 end.
Qed.
Lemma asan_zones SEGS : zones_ok SEGS asan_P asan_E asan_mem.
Proof.
 intros z a Hin Ha. finite_in Hin;
 unfold in_zone in Ha;
 match type of Ha with ?lo <= a < ?hi =>
  let l := eval vm_compute in lo in let h := eval vm_compute in hi in
  change (l<=a<h) in Ha;
  destruct (witness_readable SEGS asan_pristine asan_runs l h
   ltac:(closed) ltac:(closed) ltac:(closed) a Ha) as [Hr Hw];auto
 end.
Qed.

Lemma asan_data_shadow SEGS : data_shadow_ok SEGS asan_P asan_E asan_mem.
Proof.
 unfold data_shadow_ok. intros _ _. split.
 - intros g Hg. change (0<=8*g<1) in Hg. assert (g=0) by lia. subst.
   exists (Z_to_bv 8 1). repeat split;try closed;vm_compute;reflexivity.
 - split.
   + intros a Ha _. change (2147975166 <= a < 2147975171) in Ha.
     exact (proj1 (witness_readable SEGS asan_pristine asan_runs 2147975166 2147975171
        ltac:(closed) ltac:(closed) ltac:(closed) a Ha)).
   + intros _ a Ha. change (2147975168 <= a < 2147975176) in Ha.
     exact (proj1 (witness_readable SEGS asan_pristine asan_runs 2147975168 2147975176
        ltac:(closed) ltac:(closed) ltac:(closed) a Ha)).
Qed.
Lemma asan_borrowed_flags SEGS : live_flags_ok SEGS asan_E asan_mem.
Proof.
 intros cp Hin. finite_in Hin. exists (Z_to_bv 8 1). split;vm_compute;reflexivity.
Qed.

Lemma asan_rtctx SEGS : rtctx_ok SEGS asan_P asan_E asan_mem.
Proof.
 unfold rtctx_ok.
 exists (if vp_tp asan_P =? 6186480 then 0x607998 else 0x605f58),
   0x30001000,0x30002000,0x30003000,0x30004000.
 split;[solve_rt_cell|]. split;[solve_rt_cell|]. split;[solve_rt_cell|]. split;[solve_rt_cell|]. split;[solve_rt_cell|].
 split;[closed|]. split;[solve_rt_cell|]. split;[closed|]. split.
 - unfold rt_readable. split;[closed|]. split;[closed|].
   split;[apply rt_apartb_sound;closed|].
   intros i Hi. change (0<=i<16) in Hi.
   exact (proj1 (witness_readable SEGS asan_pristine asan_runs
       805314608 805314624 ltac:(closed) ltac:(closed) ltac:(closed) (805314608+i) ltac:(lia))).
 - split;[solve_rt_cell|]. split;[closed|]. split;[closed|]. split;[solve_rt_cell|closed].
Qed.

Lemma asan_ambient_memory SEGS : MC2 SEGS asan_P asan_E asan_mem asan_mem.
Proof. unfold MC2. split;[apply asan_kcells|]. split;[apply asan_zones|].
 split;[apply asan_data_shadow|]. split;[apply asan_borrowed_flags|]. split;[apply asan_rtctx|apply asan_kruns]. Qed.

Lemma both_environment : env_ok2 both_P both_E.
Proof.
 unfold env_ok2. split; [unfold env_ok;closed|].
 split; [unfold env_data2;closed|]. split.
 - unfold env_fs.
   assert (Havoid : forall a, 2147975160 <= a < 2147975177 -> in_rw_zones both_P both_E a = false).
   { apply zones_avoidb_sound. closed. }
   repeat split; try (solve [intros _ _ a Ha;apply Havoid;exact Ha]);
     try (solve [repeat constructor;closed]); try closed.
   change (NoDup [(1,0)]). apply NoDup_cons_2;[intros H;inversion H|apply NoDup_nil_2].
 - split; [apply env_zonesb_sound;closed|].
   unfold env_kcells. split.
   + intros c x Hin Hx. finite_in Hin;
     match type of Hx with ?lo <= x < ?hi =>
       let l := eval vm_compute in lo in let h := eval vm_compute in hi in
       change (l<=x<h) in Hx;
       split; [apply (zones_avoidb_sound both_P both_E l h);[closed|exact Hx]
              |change (~ (140735339536400 <= x < 140735340871696));lia] end.
   + intros c x Hin Hx. finite_in Hin;
     match type of Hx with ?lo <= x < ?hi =>
       let l := eval vm_compute in lo in let h := eval vm_compute in hi in
       change (l<=x<h) in Hx;
       split; [lia|]; split;
       [apply (zones_avoidb_sound both_P both_E l h);[closed|exact Hx]
       |change (~ (140735339536400 <= x < 140735340871696));lia] end.
Qed.

Lemma both_MC SEGS : MC SEGS (p1 both_P) (ev1 both_E)
  (zpatch both_P both_E both_mem both_mem) both_mem.
Proof.
 unfold MC. split.
 - intros a Ha. change (140735339536400 <= a < 140735340871696) in Ha.
   destruct (witness_readable SEGS both_pristine both_runs
      140735339536400 140735340871696 ltac:(closed) ltac:(closed) ltac:(closed) a Ha) as [Hr Hw]. auto.
 - split.
   + intros i Hi. change (0<=i<1) in Hi. assert (i=0) by lia. subst.
     exists (Z_to_bv 8 0). vm_compute. reflexivity.
   + split.
     * intros lo hi a Hin Ha. apply (witness_pristine_at both_pristine both_runs lo hi (wordZ a));[exact Hin|].
       assert (Hb : 0<=a<2^64) by (finite_in Hin;lia).
       rewrite u_wordZ by exact Hb. exact Ha.
     * apply selfpatch_frame_mod.
Qed.

Lemma both_kcells SEGS : kcells_hold SEGS both_P both_mem.
Proof.
 intros a w v Hin. finite_in Hin; repeat split; try closed;
 eexists; split; vm_compute; reflexivity.
Qed.
Lemma both_kruns SEGS : kruns_hold SEGS both_P both_mem.
Proof.
 intros lo hi b Hin. finite_in Hin.
 all: split;[closed|];split;[closed|].
 all: intros a Ha;
 match type of Ha with ?l <= a < ?h =>
  let l' := eval vm_compute in l in let h' := eval vm_compute in h in
  change (l'<=a<h') in Ha;
  match goal with |- exists k : byte, _ /\ bv_unsigned k = Z.land ?bv 255 =>
  let b' := eval vm_compute in (Z.land bv 255) in
  exists (Z_to_bv 8 b');split;
  [apply read_one;apply (witness_mem_range both_pristine both_runs l' h' b');[closed|closed|closed|closed|exact Ha]|closed]
  end
 end.
Qed.
Lemma both_zones SEGS : zones_ok SEGS both_P both_E both_mem.
Proof.
 intros z a Hin Ha. finite_in Hin;
 unfold in_zone in Ha;
 match type of Ha with ?lo <= a < ?hi =>
  let l := eval vm_compute in lo in let h := eval vm_compute in hi in
  change (l<=a<h) in Ha;
  destruct (witness_readable SEGS both_pristine both_runs l h
   ltac:(closed) ltac:(closed) ltac:(closed) a Ha) as [Hr Hw];auto
 end.
Qed.

Lemma both_data_shadow SEGS : data_shadow_ok SEGS both_P both_E both_mem.
Proof.
 unfold data_shadow_ok. intros _ _. split.
 - intros g Hg. change (0<=8*g<1) in Hg. assert (g=0) by lia. subst.
   exists (Z_to_bv 8 1). repeat split;try closed;vm_compute;reflexivity.
 - split.
   + intros a Ha _. change (2147975166 <= a < 2147975171) in Ha.
     exact (proj1 (witness_readable SEGS both_pristine both_runs 2147975166 2147975171
        ltac:(closed) ltac:(closed) ltac:(closed) a Ha)).
   + intros _ a Ha. change (2147975168 <= a < 2147975176) in Ha.
     exact (proj1 (witness_readable SEGS both_pristine both_runs 2147975168 2147975176
        ltac:(closed) ltac:(closed) ltac:(closed) a Ha)).
Qed.
Lemma both_borrowed_flags SEGS : live_flags_ok SEGS both_E both_mem.
Proof.
 intros cp Hin. finite_in Hin. exists (Z_to_bv 8 1). split;vm_compute;reflexivity.
Qed.

Lemma both_rtctx SEGS : rtctx_ok SEGS both_P both_E both_mem.
Proof.
 unfold rtctx_ok.
 exists (if vp_tp both_P =? 6186480 then 0x607998 else 0x605f58),
   0x30001000,0x30002000,0x30003000,0x30004000.
 split;[solve_rt_cell|]. split;[solve_rt_cell|]. split;[solve_rt_cell|]. split;[solve_rt_cell|]. split;[solve_rt_cell|].
 split;[closed|]. split;[solve_rt_cell|]. split;[closed|]. split.
 - unfold rt_readable. split;[closed|]. split;[closed|].
   split;[apply rt_apartb_sound;closed|].
   intros i Hi. change (0<=i<16) in Hi.
   exact (proj1 (witness_readable SEGS both_pristine both_runs
       805314608 805314624 ltac:(closed) ltac:(closed) ltac:(closed) (805314608+i) ltac:(lia))).
 - split;[solve_rt_cell|]. split;[closed|]. split;[closed|]. split;[solve_rt_cell|closed].
Qed.

Lemma both_ambient_memory SEGS : MC2 SEGS both_P both_E both_mem both_mem.
Proof. unfold MC2. split;[apply both_kcells|]. split;[apply both_zones|].
 split;[apply both_data_shadow|]. split;[apply both_borrowed_flags|]. split;[apply both_rtctx|apply both_kruns]. Qed.

