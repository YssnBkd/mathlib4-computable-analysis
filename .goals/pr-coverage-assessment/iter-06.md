# iter-06

timestamp: 2026-06-06T10:30:00Z
unmet: [C1 (Ch.1 quick, Ch.5 quick remain), C2, C7]
mode: explore
progress: Ch. 4 deepened — all ~37 landmark items enumerated across §§1-7; 0 done, 6 Mathlib-aliasable partial, ~32 not started; Lemmas 7/8 surfaced as key shared infrastructure with §C5 #4
files_changed:
  - docs/PR-COVERAGE.md (Ch. 4 section deepened from 6-row placeholder to full ~37-row per-section enumeration §§1-7; exec summary updated)
  - .goals/pr-coverage-assessment/iter-06.md (this file)

audit_walk_completed_this_iter:
  - literature/papers/PourEl-Richards-chapt4.md fully read in two chunks (lines 1-400, 400-787)
  - §1 Closed/adjoint/self-adjoint/normal/spectrum/eigenvalue definitions + Effectively
    Determined operator definition + bounded-effectively-determined corollary (10 items)
  - §2 Second Main Theorem + Theorems 1, 2, 3 (4 items)
  - §3 Discontinuity setup + Theorem 4 (creation/destruction of eigenvalues) (2 items)
  - §4 Theorem 5 (non-normal counterexample) + Lemma 8 cross-ref (2 items)
  - §5 Theorem 6 (Eigenvector Theorem final) + Eigenvector Theorem (preliminary) +
    ad hoc setup + operator T setup + pre-lemma (inner product computability) +
    Lemmas 1, 2, 3, 4, 5 (10 items)
  - §6 Lemma 6 (Effective Independence) + Lemma 7 (Gram-Schmidt → orthonormal basis) +
    Lemma 8 (spectral form) + completion (4 items)
  - §7 Effective Independence Lemma proof + Independence Criterion + isometry def +
    Question + Hilbert-yes / Banach-no example + 3 sub-lemmas (5 items)

cross_match_results:
  - Done in Lean: 0 items
  - Partial via Mathlib (aliasable): 6 items
    * Adjoint (Mathlib: ContinuousLinearMap.adjoint for bounded)
    * Self-adjoint (Mathlib: IsSelfAdjoint for bounded)
    * Normal (Mathlib: IsStarNormal)
    * Spectrum (Mathlib: spectrum)
    * Eigenvalue (Mathlib: Module.End.HasEigenvalue / LinearMap.HasEigenvalue)
    * Isometry (Mathlib: LinearIsometry / LinearIsometryEquiv)
  - Not started: ~32 items, headlined by Second Main + Theorems 1/2/3 (§2),
    Theorem 5 non-normal counterexample (§4), Theorem 6 Eigenvector (§5+§6),
    Lemmas 1-8 (§§5-6 machinery), Effective Independence Lemma + ℓ^1 counter-
    example (§7)
  - Methodological / n-a: 3 items (discontinuity setup commentary, Lemma 8
    cross-ref, isometry question)
  - Total Ch. 4 landmark items: ~37

key_observation_iter_06:
  - Lemma 7 (Gram-Schmidt → computable orthonormal basis from effective generating
    set) and Lemma 8 (spectral form characterization of every effectively separable
    Hilbert computability structure) are CENTRAL shared infrastructure with §C5 #4
    (separable Hilbert ComputabilityStructure instance). Formalizing Lemmas 7+8
    essentially IS formalizing the separable Hilbert instance + its uniqueness
    (the Hilbert direction of the Stability Lemma in disguise). This DOUBLES the
    value of the §C5 #4 priority — it doesn't just provide one more
    ComputabilityStructure instance, it also yields the spectral representation
    theorem and the entire Eigenvector-Theorem transfer machinery (Lemma 8 is
    what lets the §5 preliminary ad hoc form transfer to the §6 final natural
    form in Theorem 6).
  - This observation reinforces the §C5 ranking but suggests an additional honorable
    mention should call out the "Hilbert spectral form" as a discrete sub-goal
    inside the §C5 #4 (separable Hilbert instance) round.

sanity_checks_performed:
  - All P-R cites in Ch. 4 table verified by direct read of chapt4.md verbatim
    (lines 1-787 covered in 2 chunks)
  - Cross-check: Theorem 5's L^2[0,1] construction uses a computable orthonormal
    basis — this aligns with the §C5 #3 (complex-Hilbert) dependency

next_iter_plan:
  - iter-07: read literature/papers/PourEl-Richards-chapt5.md (1415 lines — largest
    single chapter) — Proof of Second Main. Quick-scan; most items are internal
    lemmas to a single theorem.
  - iter-08: C2 citation verification pass — re-open each P-R cite + each Lean ref.
  - iter-09: synthesis pass, executive summary polish, integrate observations
    across chapters.
  - iter-10-11: DA review (C7) + revision.
