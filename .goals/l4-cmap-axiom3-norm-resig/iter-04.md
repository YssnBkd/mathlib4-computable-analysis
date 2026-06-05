---
iter: 4
timestamp: 2026-06-04T03:00:00Z
mode: proof-attempt
unmet: [C4, C5, C6, C7, C8, C9]
files_changed: []
note: |
  Phase 3.1 attempted (`FinsetMaxHelper` with `maxTriple` + correctness +
  `finsetMax_rat` closure) over ~300 lines. Compile attempts revealed
  3 categories of Mathlib drift / Lean parsing issues that were
  successively fixed (renames, `.decide.to_comp`, etc.), but the
  parity-case-split inside `maxTriple_correct` did not close on the
  4-way `rcases`. Reverted FinsetMaxHelper to keep the repo buildable at
  the post-Phase-2 milestone. C1, C2, C3 remain met. Partial-close per
  `feedback_round_pragmatism`.
---

# iter-04 — Phase 3.1 partial attempt → revert + handoff

## What was attempted

Wrote `FinsetMaxHelper` namespace in L4 alongside `FinsetSumHelper` (~300
lines), containing:

- `maxTriple : ℕ × ℕ × ℕ → ℕ × ℕ × ℕ → ℕ × ℕ × ℕ` — witness-triple max via
  `cond chooseR1 t₁ t₂` with the same 3-branch decision tree as
  `IsComputableSeqRat.max`'s inline chooseR1.
- `maxTriple_b_ne_zero` — preserved by either-branch projection. ✓ (built)
- `maxTriple_correct` — `tripleToRat (maxTriple t₁ t₂) = max (tripleToRat t₁)
  (tripleToRat t₂)`. **Did not compile** in the 4-way parity case-split.
- `maxTriple_computable : Computable₂ maxTriple` — needs the
  `Primrec.eq.decide.to_comp.comp` recipe (after correction).
- `finsetMax_rat` — Nat.rec accumulator mirroring `FinsetSumHelper.finsetSum_rat`.

## What was learned (Mathlib drift catalog)

These are real findings from this iter, worth recording for the follow-up
session. **Add to `docs/PITFALLS.md` at round end.**

1. **`Finset.range_succ` does not exist by that name.** Use
   `Finset.range_add_one : range (n + 1) = insert n (range n)` (at
   `.lake/packages/mathlib/Mathlib/Data/Finset/Range.lean:79`).
2. **`Finset.nonempty_range_succ` does not exist.** Use
   `Finset.nonempty_range_add_one` (same file, line 116).
3. **`Primrec.eq` and `Primrec.nat_le` produce `PrimrecRel`, not `Primrec₂`.**
   To compose with `.to_comp`, first promote to `Primrec₂` via `.decide`:
   `Primrec.eq.decide.to_comp` and `Primrec.nat_le.decide.to_comp`. The
   `IsComputableSeqRat.max` proof at L1 line 472-478 uses this idiom.
4. **`IsComputableSeqRat.comp hflat hσ` and the dot-notation siblings fail
   in Lean.** Already known per iter-01's discovery. The fix used in
   Phase 1 (destructure + rebuild) is the only robust workaround. **Do not
   re-attempt** `IsComputableSeqRat.X.something h h'`-style calls.

## The actual blocker

`maxTriple_correct`'s 4-way parity case-split: each branch needs the
following sequence of moves (matching `IsComputableSeqRat.max`'s proof at
L1:493-580):

1. `set chooseR1 with hchooseR1_def` to abstract the bif/cond expression.
2. `have hch_eq : chooseR1 = (bif ...)` — derived from `hchooseR1_def`.
3. Per case `(par₁, par₂)`:
   3a. `have hbk : chooseR1 = true|false := by rw [hch_eq]; simp [hp1, hp2,
       hge_case|hle_case]`.
   3b. `simp only [hbk, cond_true|cond_false]` to substitute.
   3c. `rw [pow_red s₁, pow_red s₂, hp1, hp2]` to reduce (-1)^.
   3d. Establish the cross-product comparison as a ℚ-inequality via
       `div_le_div_iff₀`.
   3e. Close with `rw [max_eq_left ...]` or `rw [max_eq_right ...]`.

My attempts merged steps 3a–3b into a single `simp only` block, which Lean
couldn't propagate through the nested `cond` correctly. The model needs
the explicit `chooseR1 = true|false` lemma as a separate step.

## Why the partial-close

The `maxTriple_correct` proof is ~150 lines of mechanical case-analysis
with subtle simp behavior. Each branch needs ~25 lines, and the simp rule
selection is sensitive to elaboration order. Pushing through in this
conversation (which has already grown long) has diminishing returns vs.
making a clean handoff with these lessons learned.

Per `feedback_round_pragmatism` memory: "partial-close > pushed-too-far
stuck state". The current state is a strong intermediate milestone —
C1, C2, C3 all met sorry-free, with the A3 obstruction obstruction
analysis fully shifted from "signature inadequate" to "structure done,
body to fill in".

## What stays landed

- Phase 1 lemma `isComputableSeqReal_of_effectiveConvergence` in L1 §2.5
  — sorry-free, DA-reviewed sound.
- Phase 2 signature refit on `isComputableSeqCMap_norm` and
  `computabilityStructureCMap_of` — both now take `IsComputableReal α/β`.
- Updated docstrings on both, including a six-move proof outline for A3.
- `current-goal.md` with criteria C1, C2, C3 ticked.

## What's needed for follow-up Phase 3 close

**Phase 3.1** (estimated 1-2 follow-up iters): land `FinsetMaxHelper` with
the `maxTriple_correct` proof following the verbatim model pattern from
`IsComputableSeqRat.max` (L1:441-580). The mechanical work is laid out
above; the model proof is the reliable template.

**Phase 3.2-3.5** (estimated 4-6 follow-up iters): polynomial Lipschitz
bound, A3 witness construction, three-error decomposition, Prop 1
application. The forward warnings from DA's iter-02 verdict still apply
(e.g., `Primrec.nat_pow` not needed because `d(n,N)`'s output absorbs
`2^N`).

## Files changed

(None — revert restored post-Phase-2 state.)

## Verification

- `lake build` — ✓ (0 errors, sole sorry-warning at `CMap.lean:1510` =
  expected A3 sorry).
- `grep -rn "sorry" ComputableAnalysis/ --include="*.lean"` — 1 hit
  (A3 body).

## Criteria delta

- C1, C2, C3 met (unchanged from iter-03).
- C4-C9 unmet — Phase 3 follow-up required.

## Round-level recommendation

Mark this round `partial` and write a focused `NEXT-SESSION.md` detailing
the Phase-3 sub-plan with the lessons-learned encoded. The DA verdict's
forward-warnings + the Mathlib-drift catalog above + the verified model
pattern should make Phase-3 close in 1 focused follow-up conversation
(estimated 8-12 iters, all of which can run faster with the lessons in
hand).
