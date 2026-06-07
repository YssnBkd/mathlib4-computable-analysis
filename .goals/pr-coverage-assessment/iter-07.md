# iter-07

timestamp: 2026-06-06T11:00:00Z
unmet: [C1 (Ch.1 quick remains), C2, C7]
mode: explore
progress: Ch. 5 deepened — all ~40 landmark items enumerated across §§1-8; 0 done, 4 Mathlib-aliasable, ~32 not started; 6 milestone effort breakdown (M1-M6); Ch. 5 alone = cumulative L1-L4 effort
files_changed:
  - docs/PR-COVERAGE.md (Ch. 5 section deepened from 2-row placeholder to full ~40-row per-section enumeration §§1-8; exec summary updated)
  - .goals/pr-coverage-assessment/iter-07.md (this file)

audit_walk_completed_this_iter:
  - literature/papers/PourEl-Richards-chapt5.md fully read in three chunks
    (lines 1-500, 500-1000, 1000-1415)
  - §1 Spectral Theorem review: 7 SpThms + properties A-J + dμ_{xy} construction +
    bounded normal extension + (T-i)^{-1} proposition (14 items)
  - §2 Preliminaries: Uniformity-in-Exponent Lemma + Corollary + interval setup +
    sequence x_n construction + Pre-step A (effective operational calculus) +
    Pre-step B (triangle functions + trapezoidal + decomposition identity +
    two inequalities) + Pre-step C (CompNorm) (12 items)
  - §3 Heuristics: 3 pedagogical items (Heuristics I, II, definition of A informal)
  - §4 The Algorithm: λ_n construction + lemma (computable) + A construction +
    lemma (r.e.) (4 items)
  - §5 Proof: InEq 1, 2, 3 + Propositions 1, 2, 3, 4 + Eigenvalue Lemma +
    geometric (ooo) lemma (9 items)
  - §6 Normal operators: Theorem 1 + Proposition (T → T*) + 6 modifications listing
    (3 items)
  - §7 Unbounded self-adjoint: 4 items (definition, trivial observation, T^{-1}
    proposition, Unbounded SMT)
  - §8 Converses: Example 1 (iii) + Example 2 (iv) (2 items)

cross_match_results:
  - Done in Lean: 0 items
  - Partial via Mathlib (aliasable): 4 items
    * Spectral-measure properties (Mathlib.Analysis.InnerProductSpace.Spectrum,
      bounded normal only)
    * Operational calculus / continuous functional calculus
      (Mathlib.Topology.ContinuousFunction.FunctionalCalculus)
    * (T-i)^{-1} bounded normal (via Mathlib resolvent set machinery)
    * Operational calculus J for normal (handled by Mathlib's CFC)
  - Not started: ~32 items including all 7 SpThms, Uniformity Lemma,
    Pre-steps A/B/C, InEq 1-3, Propositions 1-4, Eigenvalue Lemma + (ooo) lemma,
    Theorem 1 (Normal), Unbounded reduction, Examples 1+2 (Converses)
  - Pedagogical / n-a: 3 items (Heuristics I, II, informal A definition)
  - Total Ch. 5 landmark items: ~40 (largest in the book)

key_observation_iter_07:
  - Ch. 5 is monolithic: cannot prove Proposition 2 without InEq 3, which
    requires Pre-step B + SpThm 7. Natural formalization decomposes into
    SIX milestones (M1-M6 listed in C1 §Ch. 5 audit verdict):
    * M1: §1 spectral prerequisites surfaced (L-XL)
    * M2: §2 effective operational calculus + triangle machinery (XL)
    * M3: §§4-5 bounded self-adjoint Second Main (XL)
    * M4: §6 normal extension (L)
    * M5: §7 unbounded extension (L)
    * M6: §8 converses, especially Example 2 perturbation argument (XL)
  - Total Ch. 5 effort ≈ cumulative L1+L2+L3+L4 effort the project has
    already invested. This is consistent with P-R's note ("the proof is
    long and arduous").
  - This validates §C5 #5 priority as "First Main statement only" rather
    than full First Main proof: the analogous decomposition for Ch. 3
    (First Main) plus Ch. 5 (Second Main) makes it clear that the L5
    layer is a multi-year campaign in aggregate, not a single round.

sanity_checks_performed:
  - All P-R cites in Ch. 5 table verified by direct read of chapt5.md verbatim
    (lines 1-1415 covered in 3 chunks)
  - Cross-references: Lemma 7 (Ch. 4) cited multiple times in Ch. 5 for
    "computable orthonormal basis exists" — confirms HM1 (Effective Density)
    + §C5 #4 (separable Hilbert) are gates for Ch. 5 formalization too

next_iter_plan:
  - iter-08: Ch. 1 quick reference row (verbatim NOT in corpus per CLAUDE.md;
    the existing placeholder already correctly marks it deferred). Then C2
    citation verification pass — re-open each P-R cite + each Lean ref to
    confirm they grep-pass. This is the audit acceptance check.
  - iter-09: synthesis pass — integrate cross-chapter observations, update
    executive summary to reflect the full enumeration counts, polish C3-C5.
  - iter-10: DA review (C7) invocation on docs/PR-COVERAGE.md.
  - iter-11: revisions per DA verdict.
