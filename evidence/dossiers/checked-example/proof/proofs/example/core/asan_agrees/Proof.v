From OssFuzzTheorems.example.core Require Statements.
From OssFuzzTheorems.Proofs.example.core.lib Require Theorems.

Theorem asan_agrees_holds : OssFuzzTheorems.example.core.Statements.asan_agrees.
Proof. exact OssFuzzTheorems.Proofs.example.core.lib.Theorems.strong_universal_error_free_core_asan. Qed.
