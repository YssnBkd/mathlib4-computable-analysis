/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import Mathlib.Computability.Partrec
import Mathlib.Data.Nat.Pairing
import Mathlib.Data.Rat.Defs
import Mathlib.Data.Rat.Cast.Defs
import Mathlib.Data.Real.Basic
import Mathlib.Analysis.SpecialFunctions.Pow.NNReal

/-!
# L1 — Computable sequences of rationals and reals (Pour-El & Richards Ch. 0)

This file pins down the predicates `IsComputableSeqRat : (ℕ → ℚ) → Prop` and
`IsComputableSeqReal : (ℕ → ℝ) → Prop` that the L3 axioms (`ComputabilityStructure`)
reach down for. Both are *predicates on sequences over Mathlib's pre-existing
types* — no new `ℝ_c` type per project commitment #3.

## Definitions

### `IsComputableSeqRat` (P-R Ch. 0, Definition 1)

> A sequence `{r_k}` of rational numbers is computable if there exist three
> recursive functions `a, b, s` from `ℕ` to `ℕ` such that `b(k) ≠ 0` for all `k` and
>   `r_k = (-1)^{s(k)} · a(k) / b(k)` for all `k`.

ref: `literature/papers/PourEl-Richards-chapt0.md:46`

### Computable double sequences (P-R Ch. 0:189)

> A double sequence will be called computable if it is mapped onto a computable
> sequence by one of the standard recursive pairing functions from `ℕ × ℕ` onto
> `ℕ`.

We use Mathlib's `Nat.unpair : ℕ → ℕ × ℕ` (the inverse of `Nat.pair`) for this
re-indexing — `Nat.pair` is the max-based pairing already integrated with
`Primrec`/`Computable` machinery throughout Mathlib. P-R's specific Cantor
formula (`(x+y)(x+y+1)/2 + x`) is available as `ComputableAnalysis.L0.cantorPair`
for citations referring to it directly; both pairings are recursive bijections,
so all P-R statements transfer.

### `IsComputableSeqReal` (P-R Ch. 0, Definition 5a)

> A sequence of real numbers `{x_n}` is computable (as a sequence) if there is a
> computable double sequence of rationals `{r_{n k}}` such that
>   `|r_{n k} − x_n| ≤ 2^{-k}` for all `k` and `n`.

ref: `literature/papers/PourEl-Richards-chapt0.md:203`

We adopt Definition 5a over 5 because the index `k` serves as both the
approximant index and the precision parameter, removing the need for a separate
recursive modulus `e(n, N)`.

## What this file is NOT

This is the L1 → L3 *interface* file. Out of scope (deferred to downstream
L1 milestones):

- `IsComputableReal : ℝ → Prop` (constant-sequence case)
- Closure of `IsComputableSeqReal` under arithmetic (sum, product, …)
- The countable-subfield theorem for `ℝ_c`
- `IsComputableSeqComplex` and `q`-vector extensions
- The equivalence of Definition 5 (with explicit modulus) and Definition 5a

## References

- Pour-El, M.B. & Richards, J.I., *Computability in Analysis and Physics*,
  Cambridge UP 1989, Ch. 0. Verbatim at `literature/papers/PourEl-Richards-chapt0.md`.
- Design doc: `claims/l1-computable-reals/is-computable-seq-real.md`.
-/

namespace ComputableAnalysis.L1

/-! ## §1 — Computable sequences of rationals -/

/-- **Pour-El & Richards Ch. 0, Definition 1** (line 46): a sequence `r : ℕ → ℚ`
is *computable* iff there exist Mathlib-`Computable` functions
`a, b, s : ℕ → ℕ` with `b k ≠ 0` for all `k`, satisfying
`r k = (-1)^{s k} · (a k / b k)`. -/
def IsComputableSeqRat (r : ℕ → ℚ) : Prop :=
  ∃ a b s : ℕ → ℕ,
    Computable a ∧ Computable b ∧ Computable s ∧
    (∀ k, b k ≠ 0) ∧
    (∀ k, r k = (-1 : ℚ) ^ (s k) * (a k / b k : ℚ))

/-- A computable double sequence of rationals: a sequence `r : ℕ × ℕ → ℚ`
whose re-indexing through `Nat.unpair` is a computable sequence of rationals.

ref: P-R Ch. 0:189. -/
def IsComputableDoubleSeqRat (r : ℕ × ℕ → ℚ) : Prop :=
  IsComputableSeqRat (fun n => r (Nat.unpair n))

/-! ## §2 — Computable sequences of reals -/

/-- **Pour-El & Richards Ch. 0, Definition 5a** (line 203): a sequence
`x : ℕ → ℝ` is *computable* iff there is a computable double sequence of
rationals `(r_{n,k}) : ℕ × ℕ → ℚ` such that
`|r_{n,k} − x_n| ≤ 1 / 2^k` for all `n, k`. -/
def IsComputableSeqReal (x : ℕ → ℝ) : Prop :=
  ∃ r : ℕ × ℕ → ℚ,
    IsComputableDoubleSeqRat r ∧
    ∀ n k, |((r (n, k) : ℝ)) - x n| ≤ 1 / 2 ^ k

/-! ## §3 — Basic sanity lemmas (statements only; proofs are downstream L1 work)

These are deliberately *stated* here so downstream layers can cite them; the
proofs are out of scope for this milestone (the existing L1 design doc records
them as "intentionally deferred"). -/

/-- Sanity: every constant rational sequence is computable.
TODO(/formalize L1): proof — exhibit `a := numerator, b := denominator, s` from
the sign of `q` (or rather, since `(-1)^0 = 1` and `q = q/1`, splitting on
`q ≥ 0`). -/
theorem isComputableSeqRat_const (q : ℚ) : IsComputableSeqRat (fun _ => q) := by
  -- TODO(/formalize L1 ComputableSeqReal): constant sequence — pick a, b, s as
  -- the (signed) numerator/denominator data from `Rat.num` / `Rat.den`,
  -- guarded by `Computable.const`. The arithmetic
  -- `(-1)^{s} · (a / b) = q` follows from the definition of `Rat`.
  sorry

/-- Sanity: a real-valued constant sequence sitting on a rational is computable.
TODO(/formalize L1): proof via `isComputableSeqRat_const` and the constant
double sequence `r (n, k) := q`. -/
theorem isComputableSeqReal_const_rat (q : ℚ) :
    IsComputableSeqReal (fun _ => (q : ℝ)) := by
  -- TODO(/formalize L1 ComputableSeqReal): use the constant double sequence;
  -- the bound `|q - q| = 0 ≤ 1/2^k` is immediate.
  sorry

/-! ## §4 — Smoke checks -/

#check @IsComputableSeqRat
#check @IsComputableDoubleSeqRat
#check @IsComputableSeqReal
#check @isComputableSeqRat_const
#check @isComputableSeqReal_const_rat

end ComputableAnalysis.L1
