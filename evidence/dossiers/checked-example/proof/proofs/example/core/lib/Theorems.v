(* example/core: the ASan agreement theorem, assembled exactly as pupnp/FuzzHttp's lib/Theorems.v does
   (strong_universal_error_free_fuzzhttp_asan), for our two images. *)
From Stdlib Require Import NArith List.
Require LinuxProcessSemantics.EquivalenceDefinition.Equivalence.
Require OssFuzzTheorems.example.core.images.Plain.
Require OssFuzzTheorems.example.core.images.Asan.
Require OssFuzzTheorems.Proofs.example.core.lib.A0.T7G.ClosedA0.
Require OssFuzzTheorems.Proofs.example.core.lib.Common.SanTop.
Theorem strong_universal_error_free_core_asan :
  LinuxProcessSemantics.EquivalenceDefinition.Equivalence.strong_universal_error_free_T_scfg_budgets
    (LinuxProcessSemantics.LinuxProcessSem.Run.mkSpuriousCfg false true true true true true)
    LinuxProcessSemantics.EquivalenceDefinition.Equivalence.SanitizerBudgets.lim_source
    LinuxProcessSemantics.EquivalenceDefinition.Equivalence.SanitizerBudgets.lim_target
    (LinuxProcessSemantics.LinuxProcessSem.MemImageType.mkImage OssFuzzTheorems.example.core.images.Plain.M.loaded_segments OssFuzzTheorems.example.core.images.Plain.M.init_pc OssFuzzTheorems.example.core.images.Plain.M.phdrs)
    (LinuxProcessSemantics.LinuxProcessSem.MemImageType.mkImage OssFuzzTheorems.example.core.images.Asan.M.loaded_segments OssFuzzTheorems.example.core.images.Asan.M.init_pc OssFuzzTheorems.example.core.images.Asan.M.phdrs).
Proof.
exact (OssFuzzTheorems.Proofs.example.core.lib.Common.SanTop.scfg_pinned_to_sanitizer _ _ _ OssFuzzTheorems.Proofs.example.core.lib.A0.T7G.ClosedA0.fuzzhttp_asan_error_free).
Qed.
