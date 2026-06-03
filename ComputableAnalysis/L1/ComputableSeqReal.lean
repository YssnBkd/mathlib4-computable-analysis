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
- Closure of `IsComputableSeqReal` (real-valued) under arithmetic
- The countable-subfield theorem for `ℝ_c`
- `IsComputableSeqComplex` and `q`-vector extensions
- The equivalence of Definition 5 (with explicit modulus) and Definition 5a

Rational-sequence closure lemmas live in §4 below. Naming convention there
is dot-notation under `namespace IsComputableSeqRat` (so callers write
`h₁.add h₂`); the older `_const` sanity lemma in §3 predates that
convention and is kept at its module-level snake-case name.

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

Witness: `(a, b, s) := (q.num.natAbs, q.den, if q.num < 0 then 1 else 0)`, all
constant (hence `Computable.const _`). The arithmetic identity
`q = (-1)^s · (a/b)` reduces, after rewriting `(q.num.natAbs : ℚ)` via
`Nat.cast_natAbs ∘ Int.cast_abs` to `|((q.num : ℤ) : ℚ)|`, to a sign case-split
that closes by `Rat.num_div_den`. -/
theorem isComputableSeqRat_const (q : ℚ) : IsComputableSeqRat (fun _ => q) := by
  refine ⟨fun _ => q.num.natAbs, fun _ => q.den,
    fun _ => (if q.num < 0 then 1 else 0),
    Computable.const _, Computable.const _, Computable.const _,
    fun _ => q.den_ne_zero, fun _ => ?_⟩
  rw [Nat.cast_natAbs, Int.cast_abs]
  -- Rewrite the bare `q` on the LHS, not the `q`-inside-`q.num`/`q.den` on the RHS.
  conv_lhs => rw [← Rat.num_div_den q]
  by_cases hneg : q.num < 0
  · rw [if_pos hneg, pow_one,
      abs_of_neg (show ((q.num : ℤ) : ℚ) < 0 by exact_mod_cast hneg)]
    ring
  · rw [if_neg hneg, pow_zero, one_mul,
      abs_of_nonneg (show (0 : ℚ) ≤ ((q.num : ℤ) : ℚ) by
        exact_mod_cast (not_lt.mp hneg))]

/-- Sanity: a real-valued constant sequence sitting on a rational is computable.

Witness: the constant double sequence `r (n, k) := q`. Computability of `r`
reduces to `isComputableSeqRat_const q` (the `Nat.unpair`-reindexing is still
constant). The bound `|q − q| = 0 ≤ 1/2^k` is immediate. -/
theorem isComputableSeqReal_const_rat (q : ℚ) :
    IsComputableSeqReal (fun _ => (q : ℝ)) := by
  refine ⟨fun _ => q, isComputableSeqRat_const q, fun _ _ => ?_⟩
  simp

/-! ## §4 — Arithmetic closure of `IsComputableSeqRat`

Closure lemmas packaging the ℕ-level recursion-theoretic witness assembly
P-R uses implicitly throughout Ch. 0 §1. Naming follows Mathlib's
dot-notation convention (`Continuous.add`, `Computable.comp`): the theorems
live in `namespace IsComputableSeqRat` so callers can write `h₁.add h₂`.

ref: `literature/papers/PourEl-Richards-chapt0.md:46` (Definition 1). -/

namespace IsComputableSeqRat

/-- Closure of `IsComputableSeqRat` under pointwise addition.

The new witness `(newA, newB, newS)` is constructed at the ℕ-level via a
4-case dispatch on the sign-parities `(s₁ k % 2, s₂ k % 2)` and the
comparison `a₁ k · b₂ k ≥ a₂ k · b₁ k`. ℕ-truncated subtraction
(`Nat.sub`) handles the sign-cancellation cases. -/
theorem add
    {r₁ r₂ : ℕ → ℚ}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂) :
    IsComputableSeqRat (r₁ + r₂) := by
  obtain ⟨a₁, b₁, s₁, ha₁, hb₁, hs₁, hne₁, heq₁⟩ := h₁
  obtain ⟨a₂, b₂, s₂, ha₂, hb₂, hs₂, hne₂, heq₂⟩ := h₂
  -- Cross-products and ingredients (all Computable):
  --   p₁ k = a₁ k · b₂ k          p₂ k = a₂ k · b₁ k
  --   par₁ k = s₁ k % 2           par₂ k = s₂ k % 2  (parities)
  -- The new witness:
  --   newB k = b₁ k · b₂ k
  --   newA k = if par₁ k = par₂ k then p₁ k + p₂ k
  --            else if p₁ k ≥ p₂ k then p₁ k - p₂ k else p₂ k - p₁ k
  --   newS k = if par₁ k = par₂ k then s₁ k
  --            else if p₁ k ≥ p₂ k then s₁ k else s₂ k
  have hp₁ : Computable (fun k => a₁ k * b₂ k) :=
    Primrec.nat_mul.to_comp.comp ha₁ hb₂
  have hp₂ : Computable (fun k => a₂ k * b₁ k) :=
    Primrec.nat_mul.to_comp.comp ha₂ hb₁
  have hpar₁ : Computable (fun k => s₁ k % 2) :=
    Primrec.nat_mod.to_comp.comp hs₁ (Computable.const 2)
  have hpar₂ : Computable (fun k => s₂ k % 2) :=
    Primrec.nat_mod.to_comp.comp hs₂ (Computable.const 2)
  have hnewB : Computable (fun k => b₁ k * b₂ k) :=
    Primrec.nat_mul.to_comp.comp hb₁ hb₂
  -- Witness construction.
  refine ⟨
    fun k => if s₁ k % 2 = s₂ k % 2 then a₁ k * b₂ k + a₂ k * b₁ k
             else if a₁ k * b₂ k ≥ a₂ k * b₁ k then a₁ k * b₂ k - a₂ k * b₁ k
             else a₂ k * b₁ k - a₁ k * b₂ k,
    fun k => b₁ k * b₂ k,
    fun k => if s₁ k % 2 = s₂ k % 2 then s₁ k
             else if a₁ k * b₂ k ≥ a₂ k * b₁ k then s₁ k else s₂ k,
    ?_, hnewB, ?_, ?_, ?_⟩
  · -- Computable newA. Build the function in `cond` form, then `of_eq` to ite.
    have hbeq_par : Computable (fun k => decide (s₁ k % 2 = s₂ k % 2)) :=
      Primrec.beq.to_comp.comp hpar₁ hpar₂
    have hge : Computable (fun k => decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)) := by
      have : Primrec₂ (fun p q : ℕ => decide (p ≥ q)) :=
        Primrec.nat_le.swap.decide
      exact this.to_comp.comp hp₁ hp₂
    have hsum : Computable (fun k => a₁ k * b₂ k + a₂ k * b₁ k) :=
      Primrec.nat_add.to_comp.comp hp₁ hp₂
    have hsub₁ : Computable (fun k => a₁ k * b₂ k - a₂ k * b₁ k) :=
      Primrec.nat_sub.to_comp.comp hp₁ hp₂
    have hsub₂ : Computable (fun k => a₂ k * b₁ k - a₁ k * b₂ k) :=
      Primrec.nat_sub.to_comp.comp hp₂ hp₁
    have hinner : Computable (fun k =>
        cond (decide (a₁ k * b₂ k ≥ a₂ k * b₁ k))
          (a₁ k * b₂ k - a₂ k * b₁ k)
          (a₂ k * b₁ k - a₁ k * b₂ k)) :=
      Computable.cond hge hsub₁ hsub₂
    have htotal := Computable.cond hbeq_par hsum hinner
    refine htotal.of_eq fun k => ?_
    by_cases hp : s₁ k % 2 = s₂ k % 2
    · simp [hp]
    · by_cases hq : a₁ k * b₂ k ≥ a₂ k * b₁ k
      · simp [hp, hq]
      · simp [hp, hq]
  · -- Computable newS — same pattern as newA.
    have hbeq_par : Computable (fun k => decide (s₁ k % 2 = s₂ k % 2)) :=
      Primrec.beq.to_comp.comp hpar₁ hpar₂
    have hge : Computable (fun k => decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)) := by
      have : Primrec₂ (fun p q : ℕ => decide (p ≥ q)) :=
        Primrec.nat_le.swap.decide
      exact this.to_comp.comp hp₁ hp₂
    have hinner : Computable (fun k =>
        cond (decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)) (s₁ k) (s₂ k)) :=
      Computable.cond hge hs₁ hs₂
    have htotal := Computable.cond hbeq_par hs₁ hinner
    refine htotal.of_eq fun k => ?_
    by_cases hp : s₁ k % 2 = s₂ k % 2
    · simp [hp]
    · by_cases hq : a₁ k * b₂ k ≥ a₂ k * b₁ k
      · simp [hp, hq]
      · simp [hp, hq]
  · -- newB k ≠ 0
    intro k
    exact Nat.mul_ne_zero (hne₁ k) (hne₂ k)
  · -- rational identity: r₁ k + r₂ k = (-1)^{newS k} · (newA k / newB k)
    intro k
    show r₁ k + r₂ k = _
    rw [heq₁ k, heq₂ k]
    have hb₁q : (b₁ k : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (hne₁ k)
    have hb₂q : (b₂ k : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (hne₂ k)
    -- Reduce (-1)^n in ℚ via parity (-1)^n = (-1)^(n % 2).
    have pow_red : ∀ n : ℕ, (-1 : ℚ) ^ n = (-1) ^ (n % 2) := by
      intro n
      conv_lhs => rw [← Nat.div_add_mod n 2, pow_add, pow_mul]
      simp
    -- Case-split on parities of s₁ k, s₂ k.
    rw [pow_red (s₁ k), pow_red (s₂ k)]
    rcases Nat.mod_two_eq_zero_or_one (s₁ k) with h₁ | h₁ <;>
      rcases Nat.mod_two_eq_zero_or_one (s₂ k) with h₂ | h₂
    · -- Both even: same parity, newS = s₁ k (even), newA = a₁·b₂ + a₂·b₁.
      have hsame : s₁ k % 2 = s₂ k % 2 := h₁.trans h₂.symm
      simp only [if_pos hsame]
      rw [pow_red (s₁ k), h₁, h₂]
      push_cast
      field_simp
    · -- s₁ even, s₂ odd: different parity.
      have hne : s₁ k % 2 ≠ s₂ k % 2 := by rw [h₁, h₂]; decide
      simp only [if_neg hne]
      by_cases hpge : a₁ k * b₂ k ≥ a₂ k * b₁ k
      · simp only [if_pos hpge]
        rw [pow_red (s₁ k), h₁, h₂, Nat.cast_sub hpge]
        push_cast
        field_simp
        ring
      · simp only [if_neg hpge]
        have hle : a₁ k * b₂ k ≤ a₂ k * b₁ k := le_of_not_ge hpge
        rw [pow_red (s₂ k), h₁, h₂, Nat.cast_sub hle]
        push_cast
        field_simp
        ring
    · -- s₁ odd, s₂ even: mirror of (even, odd).
      have hne : s₁ k % 2 ≠ s₂ k % 2 := by rw [h₁, h₂]; decide
      simp only [if_neg hne]
      by_cases hpge : a₁ k * b₂ k ≥ a₂ k * b₁ k
      · simp only [if_pos hpge]
        rw [pow_red (s₁ k), h₁, h₂, Nat.cast_sub hpge]
        push_cast
        field_simp
        ring
      · simp only [if_neg hpge]
        have hle : a₁ k * b₂ k ≤ a₂ k * b₁ k := le_of_not_ge hpge
        rw [pow_red (s₂ k), h₁, h₂, Nat.cast_sub hle]
        push_cast
        field_simp
        ring
    · -- Both odd: same parity, newS = s₁ k (odd), newA = a₁·b₂ + a₂·b₁.
      have hsame : s₁ k % 2 = s₂ k % 2 := h₁.trans h₂.symm
      simp only [if_pos hsame]
      rw [pow_red (s₁ k), h₁, h₂]
      push_cast
      field_simp
      ring

/-- Closure of `IsComputableSeqRat` under pointwise multiplication.

The witness is direct: `(newA, newB, newS) := (a₁·a₂, b₁·b₂, s₁+s₂)`.
No truncated subtraction is needed — the sign is additive on the exponent
of `(-1)`, and multiplication distributes through the rational fraction.
The identity reduces to a clean `pow_add` + `field_simp` + `ring` chain. -/
theorem mul
    {r₁ r₂ : ℕ → ℚ}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂) :
    IsComputableSeqRat (r₁ * r₂) := by
  obtain ⟨a₁, b₁, s₁, ha₁, hb₁, hs₁, hne₁, heq₁⟩ := h₁
  obtain ⟨a₂, b₂, s₂, ha₂, hb₂, hs₂, hne₂, heq₂⟩ := h₂
  refine ⟨
    fun k => a₁ k * a₂ k,
    fun k => b₁ k * b₂ k,
    fun k => s₁ k + s₂ k,
    Primrec.nat_mul.to_comp.comp ha₁ ha₂,
    Primrec.nat_mul.to_comp.comp hb₁ hb₂,
    Primrec.nat_add.to_comp.comp hs₁ hs₂,
    fun k => Nat.mul_ne_zero (hne₁ k) (hne₂ k),
    fun k => ?_⟩
  -- Identity: r₁ k · r₂ k = (-1)^{s₁ k + s₂ k} · (a₁ k · a₂ k) / (b₁ k · b₂ k).
  show r₁ k * r₂ k = _
  rw [heq₁ k, heq₂ k]
  have hb₁q : (b₁ k : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (hne₁ k)
  have hb₂q : (b₂ k : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr (hne₂ k)
  rw [pow_add]
  push_cast
  field_simp

/-- Closure of `IsComputableSeqRat` under precomposition with a computable
re-indexing `σ : ℕ → ℕ`. Witness: each ingredient `(a, b, s)` of `r` is
precomposed with `σ`; the recursion-theoretic data structure of
`IsComputableSeqRat` is preserved verbatim. The identity `r (σ k) =
(-1)^{s (σ k)} · (a (σ k) / b (σ k))` is just `heq` evaluated at `σ k`. -/
theorem comp
    {r : ℕ → ℚ} {σ : ℕ → ℕ}
    (h : IsComputableSeqRat r) (hσ : Computable σ) :
    IsComputableSeqRat (r ∘ σ) := by
  obtain ⟨a, b, s, ha, hb, hs, hne, heq⟩ := h
  refine ⟨a ∘ σ, b ∘ σ, s ∘ σ,
    ha.comp hσ, hb.comp hσ, hs.comp hσ,
    fun k => hne _,
    fun k => heq _⟩

end IsComputableSeqRat

/-! ## §5 — Computable real points (`IsComputableReal`)

Per **Pour-El & Richards Ch. 0:58, Definition 3** (the actual point
predicate; Definition 2 at line 50 is the *convergence relation* between
a rational sequence and a real, while Definition 3 packages it into the
existence statement). We adopt the *constant-sequence* form per project
commitment #2 ("sequences are primary, points are derived", P-R intro:7).

The constant-sequence form `IsComputableSeqReal (fun _ => x)` is
equivalent to P-R Definition 3: in the (⇒) direction, the slice
`r_{0, k}` of the double-sequence witness is a single rational sequence
converging effectively to `x` with modulus `e(N) := N`; in the (⇐)
direction, given Def-3 witness `(r_k)` with `|r_k − x| ≤ 2^{-k}`, the
constant double-sequence `r_{n,k} := r_k` works. The formal
`Iff`-statement is deferred (it depends on the Def 5 ↔ Def 5a equivalence
also deferred at §2). -/

/-- **Pour-El & Richards Ch. 0:58, Definition 3.** A real number `x` is
*computable* iff the constant sequence `fun _ => x` is a computable
sequence of reals (P-R intro:7 / project commitment #2: sequences are
primary, points are derived). Definition kept as `def` rather than
`abbrev` so that goal displays read `IsComputableReal x` rather than the
fully-unfolded existential. -/
def IsComputableReal (x : ℝ) : Prop :=
  IsComputableSeqReal (fun _ => x)

namespace IsComputableReal

/-- Every rational is a computable real: the constant sequence at `(q : ℝ)`
is computable by `isComputableSeqReal_const_rat`. -/
theorem ofRat (q : ℚ) : IsComputableReal (q : ℝ) :=
  isComputableSeqReal_const_rat q

/-- Zero is a computable real. Useful as a base case for downstream
arithmetic-closure arguments and for `simp`. -/
theorem zero : IsComputableReal (0 : ℝ) := by
  simpa using ofRat 0

end IsComputableReal

end ComputableAnalysis.L1
