---
slug: next-session-2026-06-01b
ended: 2026-06-01T21:12:51Z
iterations: 2
outcome: success
---

# Final summary for goal: execute docs/NEXT-SESSION.md — close L1 helper sorries and bring up L4 C[a,b] sup-norm instance

All six success criteria met in 2 iterations (~30 min wall-clock, ~1.5% of the 3600-min
budget). The build is green; L1 reaches `done` status (zero sorries); the first L4
instance ships as `stub` (def/instance bodies sorry-free, three axiom-proofs as
theorem-body sorries with verbatim P-R citations).

## Criteria status

- [x] **C1** (build clean): `cd formal && lake build` → 0 errors, 2532 jobs, **1 declaration
  uses sorry** (the L4 CMap instance, grouping the A1/A2/A3 theorem-body sorries into one
  warning). Sorry baseline at iter-00: 2 (L1/ComputableSeqReal.lean). Sorry count at
  goal-end: 3 (all L4/CMap.lean theorem-body, all TODO-tagged). Net: L1 fully closed,
  L4 introduced with controlled sorries.
- [x] **C2** (L1 sorries closed): Both `isComputableSeqRat_const` and
  `isComputableSeqReal_const_rat` in `formal/ComputableAnalysis/L1/ComputableSeqReal.lean`
  are CLOSED (no `sorry` token, no TODO). Root cause: the prior session's
  conjectured lemma `Int.cast_natAbs` was actually named `Nat.cast_natAbs` (in `_root_`
  namespace, defined in `Mathlib.Algebra.Order.Ring.Int`), and a second step
  `Int.cast_abs` bridges from `↑|n|` (abs in ℤ then cast) to `|↑n|` (cast then abs in ℚ).
  No new import needed — both already transitively in scope.
- [x] **C3** (L4 CMap file + predicate): `formal/ComputableAnalysis/L4/Instances/CMap.lean`
  exists, wired into the umbrella `formal/ComputableAnalysis.lean`. Defines
  `IsComputableSeqCMap : (ℕ → C(Set.Icc α β, ℝ)) → Prop` via the P-R Ch. 2:141
  polynomial-approximation form (equivalent to the G-L Ch. 0 definition by the
  Effective Density Lemma). All `def` / `instance` / `class` / `structure` bodies are
  sorry-free.
- [x] **C4** (L4 instance declared): `noncomputable instance instComputabilityStructureCMap :
  ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` declared with all four axiom-field
  positions present. `zero_seq` is proved (constructive via all-zero coefficient
  rational triple sequence and `isComputableSeqRat_const 0`). A1 / A2 / A3 are
  theorem-body sorries with `-- TODO(/formalize L4 CMap):` markers and explicit
  P-R citation in each TODO comment (P-R Ch. 2:129 for A1 "trivial", Ch. 0 Thm 4
  for A2, Ch. 0 Thm 7 for A3).
- [x] **C5** (build accepts CMap): Full `lake build` runs to completion; the only
  warning is the single grouped "declaration uses sorry" on the L4 instance.
- [x] **C6** (tracker update + Zulip decision): CLAUDE.md milestone tracker updated:
  L1 IsComputableSeqReal row → `done`; L4 CMap row → `stub`. Zulip post decision
  recorded in `docs/zulip-drafts/2026-06-01b-decision.md` per user's `record-only`
  preference (no actual posting).

## Artifacts produced

- `formal/ComputableAnalysis/L1/ComputableSeqReal.lean` — closed both helper sorries;
  proof routes via `rw [Nat.cast_natAbs, Int.cast_abs]` + `conv_lhs => rw [← Rat.num_div_den q]`
  (the `conv_lhs` was the key insight: `rw [← Rat.num_div_den q]` without `conv_lhs`
  rewrites every literal `q` in the goal — including the implicit ones inside
  `q.num`/`q.den` on the RHS — and explodes). Docstrings updated.
- `formal/ComputableAnalysis/L4/Instances/CMap.lean` — NEW file, ~150 lines including
  docstring. Defines `polyApproxCMap` (noncomputable, concrete body) and
  `IsComputableSeqCMap` (concrete body). Declares the
  `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` instance. `zero_seq` proved;
  A1/A2/A3 sorry-stubbed with TODO citations.
- `formal/ComputableAnalysis.lean` — umbrella import extended with the L4 line.
- `CLAUDE.md` — milestone tracker rows L1 (→ `done`) and L4 CMap (→ `stub`) updated.
- `docs/zulip-drafts/2026-06-01b-decision.md` — NEW file recording the
  defer-both-posts decision and a 5-step recipe for when the user is ready to post.
- `.goals/next-session-2026-06-01b/{goal.md, iter-00.md, iter-02.md, final.md}` — goal artifacts.
- `.goals/INDEX.md` — appended `next-session-2026-06-01b` row.

No claims/, proofs/, intuition/, or thinking/ files were produced — this was a Lean-
first execution round; the type-checker is the spec per CLAUDE.md's lean-first policy.

## Devil's-advocate verdicts

None invoked. The goal's frontmatter set `devils_advocate_required_for: []`. The
rationale: this was an execution/formalization round, not a research round —
Lean code that compiles IS its own verification under CLAUDE.md's lean-first policy.
No paper-level mathematical claims were committed mid-run that would warrant DA review.

## Key findings

- **The prior session's diagnosed obstruction was a naming guess, not a missing import.**
  The cast-asymmetry blocker for the L1 helper sorries was attributed to a missing
  `Int.cast_natAbs` lemma. The actual lemma is `Nat.cast_natAbs` (in `_root_`
  namespace, `Mathlib.Algebra.Order.Ring.Int`), already transitively imported.
  Adding a 5-second name-grep would have unblocked the prior session.
- **`rw [← lemma_about_q]` is dangerous when the goal contains `q.num`/`q.den` on the
  RHS.** Lean's `rw` rewrites every literal occurrence of the pattern, including
  the implicit `q`s inside field projections. Use `conv_lhs` (or `nth_rewrite`)
  to target only one side. This cost ~3 min to diagnose and is now documented in
  the closure's docstring.
- **P-R Ch. 2:141 polynomial-approximation form is more tractable than the raw
  G-L "evaluator + modulus" form for an L4 instance, given L2 isn't built yet.**
  The polynomial form's witness data lives at the `ℕ → ℚ` level (via L1's
  `IsComputableSeqRat`), so we route through existing L1 machinery without
  needing to inline an L2 stub. P-R 2:128-129 + 2:141 + the Effective Density Lemma
  (Ch. 2 §5 Thm 1) jointly license the equivalence.
- **`C(Set.Icc α β, ℝ)` auto-inferences all needed Mathlib instances** —
  `NormedAddCommGroup`, `NormedSpace ℝ`, `CompleteSpace` — with zero explicit annotation
  effort. The `noncomputable` mark is required (due to ℝ's noncomputable field structure)
  but does not impede the recursion-theoretic witness from being constructive at the
  rational level.
- **The L4 CMap stub is a useful template for L^p / Hilbert / ℓ^p instances** —
  the same pattern (a triple-rational coefficient witness + a degree-bound + a
  pointwise approximation inequality) generalizes immediately when one swaps the
  generating basis (monomials → step functions → orthonormal basis).
- **Axiom 1 ("trivial" per P-R 2:129) is NOT trivial under our polynomial-approximation
  characterization.** The polynomial form requires explicit rational-approximation of
  the scalar coefficients α/β and a 2x precision pad; bookkeeping is ~80-120 lines
  in Lean. The "trivial" label applies to the G-L predicate (which we deferred).
  A1 / A2 / A3 each merit their own focused goal.

## Open questions

- **Should the L4 CMap predicate use the polynomial form (current choice) or the raw
  G-L "rational evaluator + effective modulus" form once L2 lands?** The two are
  equivalent by P-R Ch. 2:141 + Effective Density, but switching post-hoc would
  invalidate the A1/A2/A3 stubs. Worth a Zulip ping to `#Mathlib4` before
  filling in the axiom proofs.
- **Is `Set.Icc α β` the right domain, or should we parameterize over an arbitrary
  `[CompactSpace X]` topological space?** P-R Ch. 2 is specifically about `C[a, b]`
  but the typeclass structure suggests we could state the instance more generally.
  Defer the decision to when we attempt A3 (norm computability), which is the most
  domain-sensitive axiom.
- **Should `zero_seq`-style "trivial" axioms be auto-derived from a tactic /
  `decide`-style mechanism?** Across L4/L^p/Hilbert/ℓ^p instances, the non-vacuity
  clauses will all be "constant zero is in the predicate". Worth abstracting if we
  see the pattern three times in the next two instances.

## Next-step recommendations

1. **(Highest value)** — Start a new `/goal` targeting **L4 CMap A1 (linearity)**.
   Estimated 80-120 Lean lines + careful rational arithmetic; per P-R Ch. 2:129
   it's a 1-paragraph paper proof, but the polynomial-form Lean encoding requires
   precision bookkeeping. Slug suggestion: `l4-cmap-axiom-linearity`.

2. **(Medium value, lower difficulty)** — Start a new `/goal` targeting **L1 closure
   lemmas** (the L1 row in the tracker for `IsComputableReal` is still `pending`).
   This is the natural prerequisite for A3 (norms) and is independently useful for
   downstream L^p instance work. Slug: `l1-is-computable-real`.

3. **(Communication value)** — Post the two deferred Zulip pitches (`2026-06-01-l0-pitch.md`
   to `#new contributors`; `2026-06-01-l3-pitch.md` to `#Mathlib4`). The L3 pitch in
   particular asks Brattka/Pauly/Schröder for input on the P-R-vs-TTE design tension,
   which would refine A1/A2/A3 attack strategy. Decision still defer-by-user-choice;
   surface this when you have ~30 min for review-and-post bookkeeping.

4. **(Future-proofing)** — Draft a `claims/l4-cmap-instance/equivalence.md` design
   note recording the polynomial-vs-G-L equivalence argument (P-R Ch. 2:141 +
   Effective Density Lemma) so that any future predicate-form refactor has a
   single source-of-truth pointer.
