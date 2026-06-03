# iter-16

timestamp: 2026-06-03T13:48:23.677859+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: ROUND END (partial close) — DA fix #3 applied (`@[reducible]` on `computabilityStructureCMap_of` resolves the class-type-def warning); `docs/NEXT-SESSION.md` refreshed with full round summary + Action 2 plan for follow-up round `l4-cmap-axiom-linearity-bound` + DA-verified 5-step risk profile; `lake build` green (2532 jobs, 1 sorry-warning); final round status: PARTIAL — 5/6 axiom_linearity fields closed, ~600 lines new Lean, 9 reusable helpers, DA `passes-partial` on the closed parts
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'docs/NEXT-SESSION.md', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md', '.goals/l4-cmap-axiom-linearity-cont/iter-08.md', '.goals/l4-cmap-axiom-linearity-cont/iter-09.md', '.goals/l4-cmap-axiom-linearity-cont/iter-10.md', '.goals/l4-cmap-axiom-linearity-cont/iter-11.md', '.goals/l4-cmap-axiom-linearity-cont/iter-12.md', '.goals/l4-cmap-axiom-linearity-cont/iter-13.md', '.goals/l4-cmap-axiom-linearity-cont/iter-14.md', '.goals/l4-cmap-axiom-linearity-cont/iter-15.md', '.goals/l4-cmap-axiom-linearity-cont/iter-16.md', '.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md', 'claims/l4-cmap-axiom-linearity/axiom_linearity.md']

## What shipped — final wrap

### 1. DA fix #3: reducibility warning RESOLVED

Added `@[reducible]` to `noncomputable def computabilityStructureCMap_of`. Lean's class-type warning at line 420 is gone. Single-file check + full `lake build` both green with only the bound sorry-warning remaining.

### 2. `docs/NEXT-SESSION.md` refreshed (~250 lines)

Complete round summary + Action 2 = `l4-cmap-axiom-linearity-bound` round plan with:
- Slug, mode, calibrated budget (10 iters / 240 min).
- Allow_writes / forbid_writes scoped for the bound round.
- 5 success criteria (C1: 0 sorries; C2: bound concrete; C3: A2/A3 deferred; C4: blueprint `\leanok`; C5: claim file updated).
- DA-required for C2.
- DA-identified 5-step risk profile (Finset.sum_comm highest risk).
- Bound algebra verification (factor-2 slack).
- 4 alternative directions documented.
- 4 pitfalls logged (`@[reducible]` for class-type def, `let` shadowing, `convert using 1` trick, no Mathlib `Primrec.nat_pow`).

## Build status (final)

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:439:31` (the norm bound, `axiom_linearity` body).
- **0 stylistic warnings** (reducibility now resolved).
- `leanblueprint checkdecls` → exit 0.

## Round-end status: PARTIAL

C1: ✗ (1 sorry remaining — norm bound)
C2: ⊕/⊖ DA `passes-partial` (closed parts sound, sorry'd bound flagged)
C3: ✓ (A2 + A3 remain sorry, deferred per criterion's allowed wording)
C4: ✗ (blueprint not `\leanok` since sorry remains)
C5: ✓ (claim file shipped with DA-verified roadmap)

Strict reading: 2 of 5 criteria met (C3, C5). Charitable reading: 3 of 5 met (C2 partial). Round status: **`partial`** per goal-card hard-stop semantics.

## Round deliverables (final tally)

### Lean code shipped (~600 lines new in `ComputableAnalysis/L4/Instances/CMap.lean`)

- **Instance restructure**: `@[reducible] noncomputable def computabilityStructureCMap_of (B : ℕ) (hα_le : |α| ≤ B) (hβ_le : |β| ≤ B)` replaces the parameterless instance.
- **`FinsetSumHelper` namespace** (9 decls, all sorry-free):
  - `addTriple`, `addTriple_b_ne_zero`, `tripleToRat`, `addTriple_correct`, `addTriple_computable` (~150 lines combined): triple-witness add formula.
  - `finsetSum_rat` (~80 lines): closure of `IsComputableSeqRat` under Computable-bounded finset sum.
  - `ite_rat` (~25 lines): closure under Bool conditional.
  - `isComputableSeqRat_doubleApply` (~12 lines) + `isComputableSeqRat_tripleApply` (~16 lines): convert "function-of-pair/triple at Computable indexers" into IsComputableSeqRat.
- **Inner destructures + bound machinery** (~250 lines, all sorry-free):
  - 4 `_a, _b, _s` witness extractions from `hflat_X, hflat_Y, hflat_αR, hflat_βR`.
  - `bound_aX_at_0, bound_aY_at_0, bound_αR_at_0, bound_βR_at_0` Computable.
  - `h_Bpow : Computable (fun j => B^j)` via `Computable.nat_rec`.
  - `bound_x_k, bound_y_k` Computable.
  - `stuff_per_k, bound_max` Computable.
- **A1 witness components** (let-bindings + Computability):
  - `M (n, m) := m + (d n + 1) + bound_max(n) + 2`, with `hM` (~15 lines).
  - `dS, pad_X, pad_Y, aS` let-bindings.
  - `hd_S : Computable dS` via `Computable.nat_rec` (~28 lines).
- **`IsComputableSeqRat (flatten aS)` proof** (~150 lines):
  - 3-deep Nat.unpair decoder chain.
  - Indexer Computability.
  - Closure chain via doubleApply / tripleApply / ite_rat / .mul / .add.
  - The `convert h_r_flat using 1` Pi-app bridge.
  - Final `exact FinsetSumHelper.finsetSum_rat hr' hn'`.

### Documentation shipped

- **C5 claim file** (~150 lines): `claims/l4-cmap-axiom-linearity/axiom_linearity.md`.
- **Blueprint update**: `blueprint/src/L4.tex` theorem text reflects partial state.
- **DA verdict** (~240 lines): `.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md`.
- **NEXT-SESSION refresh** (~250 lines): `docs/NEXT-SESSION.md`.
- **16 iter notes**: `.goals/l4-cmap-axiom-linearity-cont/iter-00.md` through `iter-16.md`.

## Round outcome

**Partial close, ready for follow-up.** The DA-verified soundness of the closed 5/6 components + the well-scoped 200-300-line follow-up round for the norm bound make this a clean partial.

Next session: `/goal l4-cmap-axiom-linearity-bound` (full setup pre-populated in `docs/NEXT-SESSION.md` Action 2).

## Notes for /goal-end

When the user runs `/goal-end` to formally close this round:
- Update `.goals/INDEX.md` row: `7/16 → 16/16, status: partial`.
- Write `.goals/l4-cmap-axiom-linearity-cont/final.md` summarizing the round (this iter-16.md serves as the draft).
- Clear `current-goal.md`.
