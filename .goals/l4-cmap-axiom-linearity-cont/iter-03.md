# iter-03

timestamp: 2026-06-03T11:24:02.376373+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: shipped private `_finsetSum_rat` (Computable.nat_rec witness construction) + supporting `addTriple{,_b_ne_zero,_correct,_computable}` + `tripleToRat` in CMap.lean (~200 lines, all sorry-free); `lake build` green (2532 jobs), single sorry-warning still at line 360:23 (axiom_linearity body, iter-04 target)
files_changed: ['.goals/INDEX.md', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', 'ComputableAnalysis/L4/Instances/CMap.lean']

## What shipped (`ComputableAnalysis/L4/Instances/CMap.lean` namespace `FinsetSumHelper`)

| Decl | Type | Lines | Status |
|---|---|---|---|
| `addTriple` | `ℕ × ℕ × ℕ → ℕ × ℕ × ℕ → ℕ × ℕ × ℕ` | def, ~10 | sorry-free |
| `addTriple_b_ne_zero` | `(addTriple t₁ t₂).2.1 ≠ 0` given inputs' b ≠ 0 | theorem, ~5 | sorry-free |
| `tripleToRat` | `(a, b, s) ↦ (-1)^s · (a / b) : ℚ` | def, ~2 | sorry-free |
| `addTriple_correct` | `tripleToRat (addTriple t₁ t₂) = tripleToRat t₁ + tripleToRat t₂` | theorem, ~40 (4 parity cases) | sorry-free |
| `addTriple_computable` | `Computable₂ addTriple` | theorem, ~70 (cond-form + of_eq) | sorry-free |
| `finsetSum_rat` | `IsComputableDoubleSeqRat r → Computable n → IsComputableSeqRat (fun k => ∑ j ∈ Finset.range (n k + 1), r (k, j))` | theorem, ~50 | sorry-free |

Total: ~200 lines under `namespace FinsetSumHelper` inserted between L4's `open` block and `section CMap`.

## Build status

- `lake build` → `Build completed successfully (2532 jobs)`.
- Single sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:360:23` (the `axiom_linearity` body — exactly where it was at iter-00).
- Line number shifted: was 104:23 (iter-00), now 360:23 (iter-03). The ~200-line `FinsetSumHelper` insert before `section CMap` pushed `instComputabilityStructureCMap` down.

## How the witness construction works (for reviewers / iter-04)

The L1 closures (`IsComputableSeqRat.{add,mul,comp}`) handle pointwise closures but NOT closure under finite sums where the upper bound is variable-in-k. For A1's polynomial witness `aˢ(n,m,j) := Σ_{k ≤ d n} ...`, we need the variable-bound closure. The trick:

1. **Inline witness via `Computable.nat_rec`.** `Computable.nat_rec` (`Partrec.lean:584`) gives `Computable (fun k => Nat.rec base step (f k))` when `f, base, step` are Computable. We set:
   - `f := (· + 1) ∘ n` (the bound, via `.succ`),
   - `base := (0, 1, 0) : ℕ × ℕ × ℕ` (witness for the empty sum, value `(-1)^0 · 0/1 = 0`),
   - `step := fun k (y, ih) ↦ addTriple ih (a_r (Nat.pair k y), b_r ..., s_r ...)` (fold in `r (k, y)`'s witness).
2. **The `addTriple` formula at the ℕ-level** ports L1's `IsComputableSeqRat.add` witness construction (4-case parity dispatch + truncated subtraction) into a static function `ℕ × ℕ × ℕ → ℕ × ℕ × ℕ → ℕ × ℕ × ℕ`. Each component (newA, newB, newS) is Computable via cond-form + Primrec arithmetic + `of_eq` to align with the ite form of `addTriple`.
3. **Correctness via two inductions on the bound** in the `rec_aux` block: (a) b ≠ 0 by `addTriple_b_ne_zero` + IH; (b) rational identity by `addTriple_correct` + IH + `Finset.sum_range_succ`.

## Pitfalls hit (for iter-04+ vigilance)

1. **`Computable.const _` typeclass metavar** — must provide explicit type `Computable.const ((0, 1, 0) : ℕ × ℕ × ℕ)` so Lean fixes σ.
2. **Higher-order unification of `Computable.nat_rec`'s step** — `refine Computable.nat_rec ... ?_` could not unify the step function. Fix: prove `Computable₂` of the step as a `have` first, then `exact Computable.nat_rec ... h_step`.
3. **`Nat.succ` vs `n + 1`** — `Computable.succ.comp hn` produces `(n a).succ` syntactically; the goal had `n k + 1`. They're defeq but `refine` doesn't always unify. Resolved by changing `absTriple`'s definition to use `.succ` form.
4. **`rw [Nat.unpair_pair] at heq_rkm` fails through beta-redex** — must use `simp only [Nat.unpair_pair] at heq_rkm` (simp does beta reduction).
5. **`by decide` on `Nat.rec ... 0`** fails (free vars in step block). Use `exact Nat.one_ne_zero` after reducing to `(0,1,0).2.1`.
6. **Final identity equation via `simp [tripleToRat]`** unfolds one side but not the other. Use `change` to force the goal into `tripleToRat (absTriple k)` form, then `exact this.symm`.

## Next iter (iter-04) plan

Now that `_finsetSum_rat` is shipped, the A1 body can be drafted. From `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md`:

1. Destructure the 5 hypotheses (`hx : IsComputableSeqCMap x`, `hy : IsComputableSeqCMap y`, `hα`, `hβ : IsComputableSeqReal (... ∘ Nat.unpair)`, `hd : Computable d`).
2. Extract: `aˣ : ℕ × ℕ × ℕ → ℚ` + `dˣ : ℕ × ℕ → ℕ` from `hx` (similarly `aʸ, dʸ` from `hy`); `αRat, βRat : ℕ × ℕ → ℚ` from `hα, hβ`.
3. Define precision pad `M(n, m)`, new bound `dˢ`, new coefficient triple-sequence `aˢ`.
4. Witness Computability via `_finsetSum_rat` + `IsComputableSeqRat.{add, mul, comp}` + Computable nat-arithmetic.
5. Norm bound (defer to iter-05).

First lake build is expected to fail on the norm bound; that's the iter-04 stopping point.
