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

/-! ## §2.5 — Closure under effective convergence (P-R Ch. 0 Proposition 1)

This is the *rational-input specialization* of Pour-El & Richards Ch. 0
Proposition 1 (chapt0:246). The full P-R statement takes a computable double
sequence of *reals* `{x_{n,k}}` and concludes the limit `{x_n}` is a computable
sequence of reals. Here we take a computable double sequence of *rationals*
`(r_{n,k})` with an effective modulus `e` such that `k ≥ e(n, N)` implies
`|r_{n,k} − x_n| ≤ 2⁻ᴺ`, and conclude `IsComputableSeqReal x`.

This is the workhorse form used by the chapter-0 theorems (Th. 5 on integration,
Th. 7 on maxima, the Effective Density Lemma): each constructs a *rational*
approximant double sequence with an effective modulus rather than the full
double-real form. The general-real version follows from this lemma by
extracting Def-5a-witness rationals from each `x_{n,k}` and applying — deferred
to a downstream L1 milestone once `IsComputableDoubleSeqReal` is in scope.

**Bound cleanup**: P-R's general-real Prop 1 (chapt0:268-269) concludes
`|r'_{n,N} − x_n| ≤ 2 · 2⁻ᴺ` because it incurs both the
rational-approximant-of-real error and the convergence-modulus error. Our
rational specialization skips the first term, so the conclusion is the
cleaner `≤ 1 / 2^N` form (= `2⁻ᴺ`), matching `IsComputableSeqReal`'s Def-5a
shape verbatim.

**Convention**: `e : ℕ × ℕ → ℕ` is the *effective*-in-`n` modulus form per
P-R chapt0:220-223 ("`effectively in n` means governed by a recursive
function of `n`"). A uniform-in-`n` corollary `e : ℕ → ℕ` is the trivial
specialization `e (n, N) := e' N` and is not separately stated. -/

/-- **Pour-El & Richards Ch. 0 Proposition 1** (Closure under effective
convergence), rational-input specialization. Quote at
`literature/papers/PourEl-Richards-chapt0.md:246`:

> "Let `{x_{n,k}}` be a computable double sequence of real numbers which
> converges as `k → ∞` to a sequence `{x_n}`, effectively in `k` and `n`.
> Then `{x_n}` is computable."

Concretely: if `(r_{n,k}) : ℕ × ℕ → ℚ` is `IsComputableDoubleSeqRat` and
`e : ℕ × ℕ → ℕ` is `Computable` with `k ≥ e(n, N) → |r_{n,k} − x n| ≤ 2⁻ᴺ`,
then `x : ℕ → ℝ` is `IsComputableSeqReal`.

**Proof** (P-R chapt0:260-272): take the subsequence `r'_{n,k} := r_{n, e(n,k)}`.
By the hypothesis at `N := k` and `k_input := e(n, k)` (so `k_input ≥ e(n, N)`
trivially), `|r'_{n,k} − x n| ≤ 2⁻ᵏ`. The double sequence `r'` is computable
because `r` is and the reindexing `σ m := Nat.pair (Nat.unpair m).1 (e (Nat.unpair m))`
is Computable (composition of `Computable.fst`, `Computable.unpair`, `he`, and
`Primrec₂.natPair.to_comp`). -/
theorem isComputableSeqReal_of_effectiveConvergence
    {r : ℕ × ℕ → ℚ} (hr : IsComputableDoubleSeqRat r)
    {x : ℕ → ℝ}
    {e : ℕ × ℕ → ℕ} (he : Computable e)
    (hconv : ∀ n N k, k ≥ e (n, N) →
      |((r (n, k) : ℝ)) - x n| ≤ (1 : ℝ) / 2 ^ N) :
    IsComputableSeqReal x := by
  -- Diagonalised witness: r' (n, k) := r (n, e (n, k)).
  refine ⟨fun p => r (p.1, e p), ?_, ?_⟩
  · -- Computability of r'. Unfolding `IsComputableDoubleSeqRat r'` gives
    -- `IsComputableSeqRat (fun m => r ((Nat.unpair m).1, e (Nat.unpair m)))`.
    -- Build via `hr.comp hσ` for a Computable reindex `σ : ℕ → ℕ`.
    change IsComputableSeqRat
      (fun m : ℕ => r ((Nat.unpair m).1, e (Nat.unpair m)))
    have h_fst : Computable (fun m : ℕ => (Nat.unpair m).1) :=
      Computable.fst.comp Computable.unpair
    have h_e_unp : Computable (fun m : ℕ => e (Nat.unpair m)) :=
      he.comp Computable.unpair
    have hσ : Computable (fun m : ℕ =>
        Nat.pair (Nat.unpair m).1 (e (Nat.unpair m))) :=
      Primrec₂.natPair.to_comp.comp h_fst h_e_unp
    -- Inline `IsComputableSeqRat.comp`'s body. `IsComputableSeqRat` is a
    -- `def` unfolding to `Exists`; Lean's parser interprets
    -- `IsComputableSeqRat.comp` as `Function.comp` of the predicate (treating
    -- `IsComputableSeqRat` as a term `(ℕ → ℚ) → Prop`). The destructure-then-
    -- rebuild idiom matches the rest of the §4 closure lemmas.
    have hflat : IsComputableSeqRat (fun m : ℕ => r (Nat.unpair m)) := hr
    obtain ⟨a, b, sgn, ha, hb, hsgn, hne, heq⟩ := hflat
    have key : IsComputableSeqRat (fun m : ℕ =>
        r (Nat.unpair (Nat.pair (Nat.unpair m).1 (e (Nat.unpair m))))) := by
      refine ⟨fun m => a (Nat.pair (Nat.unpair m).1 (e (Nat.unpair m))),
              fun m => b (Nat.pair (Nat.unpair m).1 (e (Nat.unpair m))),
              fun m => sgn (Nat.pair (Nat.unpair m).1 (e (Nat.unpair m))),
              ha.comp hσ, hb.comp hσ, hsgn.comp hσ,
              fun m => hne _, fun m => heq _⟩
    convert key using 1
    funext m
    simp [Nat.unpair_pair]
  · -- Bound: `|r' (n, k) − x n| ≤ 1/2^k` from `hconv` at `N := k`, input `e(n, k)`.
    intro n k
    exact hconv n k (e (n, k)) le_rfl

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

/-- Closure of `IsComputableSeqRat` under pointwise negation. Witness: flip
the sign parity by `+1`, keeping `(a, b)`. The identity
`-q = (-1)^{s + 1} · (a/b)` reduces via `pow_succ` + `ring`. -/
theorem neg
    {r : ℕ → ℚ} (h : IsComputableSeqRat r) :
    IsComputableSeqRat (fun k => - r k) := by
  obtain ⟨a, b, s, ha, hb, hs, hne, heq⟩ := h
  refine ⟨a, b, fun k => s k + 1, ha, hb, Computable.succ.comp hs, hne, fun k => ?_⟩
  show -r k = (-1 : ℚ) ^ (s k + 1) * ((a k : ℚ) / (b k : ℚ))
  rw [heq k, pow_succ]
  ring

/-- Closure of `IsComputableSeqRat` under pointwise subtraction. Implemented as
`r₁ + (- r₂)` via `IsComputableSeqRat.add` and `IsComputableSeqRat.neg`. -/
theorem sub
    {r₁ r₂ : ℕ → ℚ}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂) :
    IsComputableSeqRat (fun k => r₁ k - r₂ k) := by
  have hadd : IsComputableSeqRat (r₁ + (fun k => - r₂ k)) :=
    IsComputableSeqRat.add h₁ (IsComputableSeqRat.neg h₂)
  convert hadd using 1
  funext k
  show r₁ k - r₂ k = r₁ k + (- r₂ k)
  ring

/-- Closure of `IsComputableSeqRat` under pointwise binary `max`.

The new witness selects, pointwise, either the `(a₁, b₁, s₁)` triple or
the `(a₂, b₂, s₂)` triple via a Boolean discriminator `chooseR1 k`
which is `true` iff `max (r₁ k) (r₂ k) = r₁ k`. The discriminator is
built recursion-theoretically as a nested `cond` over parities and a
cross-product comparison (see the chooseR1 decision tree in
`.goals/l1-max-abs-closure/iter-02.md`):

- both parities equal and even: `chooseR1 ↔ a₁·b₂ ≥ a₂·b₁`,
- both parities equal and odd:  `chooseR1 ↔ a₁·b₂ ≤ a₂·b₁`,
- different parities:           `chooseR1 ↔ s₁ % 2 = 0` (i.e. r₁ ≥ 0 ≥ r₂).

The rational identity then closes by a 4-way parity case-split,
collapsing the inner `cond` per parity and applying `max_eq_left`
(or `max_eq_right`) against the cross-product comparison, which is
exposed via `div_le_div_iff₀ : a / b ≤ c / d ↔ a · d ≤ c · b` (for
`b, d > 0`). -/
theorem max
    {r₁ r₂ : ℕ → ℚ}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂) :
    IsComputableSeqRat (fun k => Max.max (r₁ k) (r₂ k)) := by
  obtain ⟨a₁, b₁, s₁, ha₁, hb₁, hs₁, hne₁, heq₁⟩ := h₁
  obtain ⟨a₂, b₂, s₂, ha₂, hb₂, hs₂, hne₂, heq₂⟩ := h₂
  -- Computable cross-products and parities.
  have hp₁ : Computable (fun k => a₁ k * b₂ k) :=
    Primrec.nat_mul.to_comp.comp ha₁ hb₂
  have hp₂ : Computable (fun k => a₂ k * b₁ k) :=
    Primrec.nat_mul.to_comp.comp ha₂ hb₁
  have hpar₁ : Computable (fun k => s₁ k % 2) :=
    Primrec.nat_mod.to_comp.comp hs₁ (Computable.const 2)
  have hpar₂ : Computable (fun k => s₂ k % 2) :=
    Primrec.nat_mod.to_comp.comp hs₂ (Computable.const 2)
  -- Boolean discriminator: `chooseR1 k = true` iff `max (r₁ k) (r₂ k) = r₁ k`.
  set chooseR1 : ℕ → Bool := fun k =>
    bif decide (s₁ k % 2 = s₂ k % 2) then
      (bif decide (s₁ k % 2 = 0) then
        decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)
      else
        decide (a₁ k * b₂ k ≤ a₂ k * b₁ k))
    else
      decide (s₁ k % 2 = 0)
    with hchooseR1_def
  -- Computable discriminator: chain of Computable.cond on five primitives.
  have hbeq_par : Computable (fun k => decide (s₁ k % 2 = s₂ k % 2)) :=
    Primrec.beq.to_comp.comp hpar₁ hpar₂
  have hbeq_par1zero : Computable (fun k => decide (s₁ k % 2 = 0)) :=
    Primrec.beq.to_comp.comp hpar₁ (Computable.const 0)
  have hge : Computable (fun k => decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)) := by
    have : Primrec₂ (fun p q : ℕ => decide (p ≥ q)) :=
      Primrec.nat_le.swap.decide
    exact this.to_comp.comp hp₁ hp₂
  have hle : Computable (fun k => decide (a₁ k * b₂ k ≤ a₂ k * b₁ k)) := by
    have : Primrec₂ (fun p q : ℕ => decide (p ≤ q)) :=
      Primrec.nat_le.decide
    exact this.to_comp.comp hp₁ hp₂
  have hchooseR1 : Computable chooseR1 :=
    Computable.cond hbeq_par (Computable.cond hbeq_par1zero hge hle) hbeq_par1zero
  -- Witness: pick (a, b, s) per the discriminator.
  refine ⟨
    fun k => bif chooseR1 k then a₁ k else a₂ k,
    fun k => bif chooseR1 k then b₁ k else b₂ k,
    fun k => bif chooseR1 k then s₁ k else s₂ k,
    Computable.cond hchooseR1 ha₁ ha₂,
    Computable.cond hchooseR1 hb₁ hb₂,
    Computable.cond hchooseR1 hs₁ hs₂,
    ?_, ?_⟩
  · -- newB k ≠ 0
    intro k
    cases hbk : chooseR1 k <;> simp [hbk, hne₁ k, hne₂ k]
  · -- Rational identity: max (r₁ k) (r₂ k) = (-1)^{newS k} · (newA k / newB k).
    intro k
    show Max.max (r₁ k) (r₂ k) = _
    rw [heq₁ k, heq₂ k]
    have hb₁ℚ : (0 : ℚ) < b₁ k := by exact_mod_cast Nat.pos_of_ne_zero (hne₁ k)
    have hb₂ℚ : (0 : ℚ) < b₂ k := by exact_mod_cast Nat.pos_of_ne_zero (hne₂ k)
    -- Reduce (-1)^n in ℚ via parity (-1)^n = (-1)^(n % 2).
    have pow_red : ∀ n : ℕ, (-1 : ℚ) ^ n = (-1) ^ (n % 2) := by
      intro n
      conv_lhs => rw [← Nat.div_add_mod n 2, pow_add, pow_mul]
      simp
    rw [pow_red (s₁ k), pow_red (s₂ k)]
    -- Unfold chooseR1 to its definition once per case, then reduce by
    -- the parity equalities. Each case picks the branch and reduces to
    -- a cross-product comparison or a constant Bool.
    have hch_eq : ∀ k, chooseR1 k =
        (bif decide (s₁ k % 2 = s₂ k % 2) then
          (bif decide (s₁ k % 2 = 0) then
            decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)
          else
            decide (a₁ k * b₂ k ≤ a₂ k * b₁ k))
        else
          decide (s₁ k % 2 = 0)) :=
      fun k => congrFun hchooseR1_def k
    rcases Nat.mod_two_eq_zero_or_one (s₁ k) with hp1 | hp1 <;>
      rcases Nat.mod_two_eq_zero_or_one (s₂ k) with hp2 | hp2
    · -- (par₁=0, par₂=0): both nonneg; chooseR1 ↔ a₁·b₂ ≥ a₂·b₁.
      by_cases hge_case : a₁ k * b₂ k ≥ a₂ k * b₁ k
      · have hbk : chooseR1 k = true := by
          rw [hch_eq k]; simp [hp1, hp2, hge_case]
        simp only [hbk, cond_true]
        rw [pow_red (s₁ k), hp1, hp2]
        have hr2le : (a₂ k : ℚ) / (b₂ k : ℚ) ≤ (a₁ k : ℚ) / (b₁ k : ℚ) := by
          rw [div_le_div_iff₀ hb₂ℚ hb₁ℚ]
          exact_mod_cast hge_case
        rw [max_eq_left (by linarith)]
      · have hlt : a₁ k * b₂ k < a₂ k * b₁ k := lt_of_not_ge hge_case
        have hbk : chooseR1 k = false := by
          rw [hch_eq k]; simp [hp1, hp2, hge_case]
        simp only [hbk, cond_false]
        rw [pow_red (s₂ k), hp1, hp2]
        have hr1le : (a₁ k : ℚ) / (b₁ k : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) := by
          rw [div_le_div_iff₀ hb₁ℚ hb₂ℚ]
          exact_mod_cast hlt.le
        rw [max_eq_right (by linarith)]
    · -- (par₁=0, par₂=1): r₁ ≥ 0 ≥ r₂. chooseR1 = true.
      have hbk : chooseR1 k = true := by
        rw [hch_eq k]; simp [hp1, hp2]
      simp only [hbk, cond_true]
      rw [pow_red (s₁ k), hp1, hp2]
      have hr1nn : (0 : ℚ) ≤ (a₁ k : ℚ) / (b₁ k : ℚ) :=
        div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      have hr2nn : (0 : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) :=
        div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      rw [max_eq_left (show ((-1 : ℚ) ^ (1 : ℕ)) * ((a₂ k : ℚ) / (b₂ k : ℚ)) ≤
        ((-1 : ℚ) ^ (0 : ℕ)) * ((a₁ k : ℚ) / (b₁ k : ℚ)) by
        simp; linarith)]
    · -- (par₁=1, par₂=0): r₁ ≤ 0 ≤ r₂. chooseR1 = false.
      have hbk : chooseR1 k = false := by
        rw [hch_eq k]; simp [hp1, hp2]
      simp only [hbk, cond_false]
      rw [pow_red (s₂ k), hp1, hp2]
      have hr1nn : (0 : ℚ) ≤ (a₁ k : ℚ) / (b₁ k : ℚ) :=
        div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      have hr2nn : (0 : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) :=
        div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      rw [max_eq_right (show ((-1 : ℚ) ^ (1 : ℕ)) * ((a₁ k : ℚ) / (b₁ k : ℚ)) ≤
        ((-1 : ℚ) ^ (0 : ℕ)) * ((a₂ k : ℚ) / (b₂ k : ℚ)) by
        simp; linarith)]
    · -- (par₁=1, par₂=1): both nonpos; chooseR1 ↔ a₁·b₂ ≤ a₂·b₁.
      by_cases hle_case : a₁ k * b₂ k ≤ a₂ k * b₁ k
      · have hbk : chooseR1 k = true := by
          rw [hch_eq k]; simp [hp1, hp2, hle_case]
        simp only [hbk, cond_true]
        rw [pow_red (s₁ k), hp1, hp2]
        have hr1le : (a₁ k : ℚ) / (b₁ k : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) := by
          rw [div_le_div_iff₀ hb₁ℚ hb₂ℚ]
          exact_mod_cast hle_case
        rw [max_eq_left (by linarith)]
      · have hlt : a₂ k * b₁ k < a₁ k * b₂ k := lt_of_not_ge hle_case
        have hbk : chooseR1 k = false := by
          rw [hch_eq k]; simp [hp1, hp2, hle_case]
        simp only [hbk, cond_false]
        rw [pow_red (s₂ k), hp1, hp2]
        have hr2le : (a₂ k : ℚ) / (b₂ k : ℚ) ≤ (a₁ k : ℚ) / (b₁ k : ℚ) := by
          rw [div_le_div_iff₀ hb₂ℚ hb₁ℚ]
          exact_mod_cast hlt.le
        rw [max_eq_right (by linarith)]

/-- Closure of `IsComputableSeqRat` under pointwise binary `min`.

Dual of `.max`. The discriminator `chooseR1 k` is `true` iff
`min (r₁ k) (r₂ k) = r₁ k`. Decision tree:

- both parities equal and even: `chooseR1 ↔ a₁·b₂ ≤ a₂·b₁`,
- both parities equal and odd:  `chooseR1 ↔ a₁·b₂ ≥ a₂·b₁`,
- different parities:           `chooseR1 ↔ s₁ % 2 = 1` (i.e. r₁ ≤ 0 ≤ r₂).

The proof structure is identical to `.max` with `max_eq_left`/`max_eq_right`
swapped for `min_eq_left`/`min_eq_right` and the inner cross-product
comparisons swapped between the two same-parity branches. -/
theorem min
    {r₁ r₂ : ℕ → ℚ}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂) :
    IsComputableSeqRat (fun k => Min.min (r₁ k) (r₂ k)) := by
  obtain ⟨a₁, b₁, s₁, ha₁, hb₁, hs₁, hne₁, heq₁⟩ := h₁
  obtain ⟨a₂, b₂, s₂, ha₂, hb₂, hs₂, hne₂, heq₂⟩ := h₂
  have hp₁ : Computable (fun k => a₁ k * b₂ k) :=
    Primrec.nat_mul.to_comp.comp ha₁ hb₂
  have hp₂ : Computable (fun k => a₂ k * b₁ k) :=
    Primrec.nat_mul.to_comp.comp ha₂ hb₁
  have hpar₁ : Computable (fun k => s₁ k % 2) :=
    Primrec.nat_mod.to_comp.comp hs₁ (Computable.const 2)
  have hpar₂ : Computable (fun k => s₂ k % 2) :=
    Primrec.nat_mod.to_comp.comp hs₂ (Computable.const 2)
  -- Boolean discriminator: `chooseR1 k = true` iff `min (r₁ k) (r₂ k) = r₁ k`.
  set chooseR1 : ℕ → Bool := fun k =>
    bif decide (s₁ k % 2 = s₂ k % 2) then
      (bif decide (s₁ k % 2 = 0) then
        decide (a₁ k * b₂ k ≤ a₂ k * b₁ k)
      else
        decide (a₁ k * b₂ k ≥ a₂ k * b₁ k))
    else
      decide (s₁ k % 2 = 1)
    with hchooseR1_def
  have hbeq_par : Computable (fun k => decide (s₁ k % 2 = s₂ k % 2)) :=
    Primrec.beq.to_comp.comp hpar₁ hpar₂
  have hbeq_par1zero : Computable (fun k => decide (s₁ k % 2 = 0)) :=
    Primrec.beq.to_comp.comp hpar₁ (Computable.const 0)
  have hbeq_par1one : Computable (fun k => decide (s₁ k % 2 = 1)) :=
    Primrec.beq.to_comp.comp hpar₁ (Computable.const 1)
  have hge : Computable (fun k => decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)) := by
    have : Primrec₂ (fun p q : ℕ => decide (p ≥ q)) :=
      Primrec.nat_le.swap.decide
    exact this.to_comp.comp hp₁ hp₂
  have hle : Computable (fun k => decide (a₁ k * b₂ k ≤ a₂ k * b₁ k)) := by
    have : Primrec₂ (fun p q : ℕ => decide (p ≤ q)) :=
      Primrec.nat_le.decide
    exact this.to_comp.comp hp₁ hp₂
  have hchooseR1 : Computable chooseR1 :=
    Computable.cond hbeq_par (Computable.cond hbeq_par1zero hle hge) hbeq_par1one
  refine ⟨
    fun k => bif chooseR1 k then a₁ k else a₂ k,
    fun k => bif chooseR1 k then b₁ k else b₂ k,
    fun k => bif chooseR1 k then s₁ k else s₂ k,
    Computable.cond hchooseR1 ha₁ ha₂,
    Computable.cond hchooseR1 hb₁ hb₂,
    Computable.cond hchooseR1 hs₁ hs₂,
    ?_, ?_⟩
  · intro k
    cases hbk : chooseR1 k <;> simp [hbk, hne₁ k, hne₂ k]
  · intro k
    show Min.min (r₁ k) (r₂ k) = _
    rw [heq₁ k, heq₂ k]
    have hb₁ℚ : (0 : ℚ) < b₁ k := by exact_mod_cast Nat.pos_of_ne_zero (hne₁ k)
    have hb₂ℚ : (0 : ℚ) < b₂ k := by exact_mod_cast Nat.pos_of_ne_zero (hne₂ k)
    have pow_red : ∀ n : ℕ, (-1 : ℚ) ^ n = (-1) ^ (n % 2) := by
      intro n
      conv_lhs => rw [← Nat.div_add_mod n 2, pow_add, pow_mul]
      simp
    rw [pow_red (s₁ k), pow_red (s₂ k)]
    have hch_eq : ∀ k, chooseR1 k =
        (bif decide (s₁ k % 2 = s₂ k % 2) then
          (bif decide (s₁ k % 2 = 0) then
            decide (a₁ k * b₂ k ≤ a₂ k * b₁ k)
          else
            decide (a₁ k * b₂ k ≥ a₂ k * b₁ k))
        else
          decide (s₁ k % 2 = 1)) :=
      fun k => congrFun hchooseR1_def k
    rcases Nat.mod_two_eq_zero_or_one (s₁ k) with hp1 | hp1 <;>
      rcases Nat.mod_two_eq_zero_or_one (s₂ k) with hp2 | hp2
    · -- (par₁=0, par₂=0): both nonneg; chooseR1 ↔ a₁·b₂ ≤ a₂·b₁.
      by_cases hle_case : a₁ k * b₂ k ≤ a₂ k * b₁ k
      · have hbk : chooseR1 k = true := by
          rw [hch_eq k]; simp [hp1, hp2, hle_case]
        simp only [hbk, cond_true]
        rw [pow_red (s₁ k), hp1, hp2]
        have hr1le : (a₁ k : ℚ) / (b₁ k : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) := by
          rw [div_le_div_iff₀ hb₁ℚ hb₂ℚ]
          exact_mod_cast hle_case
        rw [min_eq_left (by linarith)]
      · have hlt : a₂ k * b₁ k < a₁ k * b₂ k := lt_of_not_ge hle_case
        have hbk : chooseR1 k = false := by
          rw [hch_eq k]; simp [hp1, hp2, hle_case]
        simp only [hbk, cond_false]
        rw [pow_red (s₂ k), hp1, hp2]
        have hr2le : (a₂ k : ℚ) / (b₂ k : ℚ) ≤ (a₁ k : ℚ) / (b₁ k : ℚ) := by
          rw [div_le_div_iff₀ hb₂ℚ hb₁ℚ]
          exact_mod_cast hlt.le
        rw [min_eq_right (by linarith)]
    · -- (par₁=0, par₂=1): r₁ ≥ 0 ≥ r₂. chooseR1 = false (r₂ is the min).
      have hbk : chooseR1 k = false := by
        rw [hch_eq k]; simp [hp1, hp2]
      simp only [hbk, cond_false]
      rw [pow_red (s₂ k), hp1, hp2]
      have hr1nn : (0 : ℚ) ≤ (a₁ k : ℚ) / (b₁ k : ℚ) :=
        div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      have hr2nn : (0 : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) :=
        div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      rw [min_eq_right (show ((-1 : ℚ) ^ (1 : ℕ)) * ((a₂ k : ℚ) / (b₂ k : ℚ)) ≤
        ((-1 : ℚ) ^ (0 : ℕ)) * ((a₁ k : ℚ) / (b₁ k : ℚ)) by
        simp; linarith)]
    · -- (par₁=1, par₂=0): r₁ ≤ 0 ≤ r₂. chooseR1 = true (r₁ is the min).
      have hbk : chooseR1 k = true := by
        rw [hch_eq k]; simp [hp1, hp2]
      simp only [hbk, cond_true]
      rw [pow_red (s₁ k), hp1, hp2]
      have hr1nn : (0 : ℚ) ≤ (a₁ k : ℚ) / (b₁ k : ℚ) :=
        div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      have hr2nn : (0 : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) :=
        div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
      rw [min_eq_left (show ((-1 : ℚ) ^ (1 : ℕ)) * ((a₁ k : ℚ) / (b₁ k : ℚ)) ≤
        ((-1 : ℚ) ^ (0 : ℕ)) * ((a₂ k : ℚ) / (b₂ k : ℚ)) by
        simp; linarith)]
    · -- (par₁=1, par₂=1): both nonpos; chooseR1 ↔ a₁·b₂ ≥ a₂·b₁.
      by_cases hge_case : a₁ k * b₂ k ≥ a₂ k * b₁ k
      · have hbk : chooseR1 k = true := by
          rw [hch_eq k]; simp [hp1, hp2, hge_case]
        simp only [hbk, cond_true]
        rw [pow_red (s₁ k), hp1, hp2]
        have hr2le : (a₂ k : ℚ) / (b₂ k : ℚ) ≤ (a₁ k : ℚ) / (b₁ k : ℚ) := by
          rw [div_le_div_iff₀ hb₂ℚ hb₁ℚ]
          exact_mod_cast hge_case
        rw [min_eq_left (by linarith)]
      · have hlt : a₁ k * b₂ k < a₂ k * b₁ k := lt_of_not_ge hge_case
        have hbk : chooseR1 k = false := by
          rw [hch_eq k]; simp [hp1, hp2, hge_case]
        simp only [hbk, cond_false]
        rw [pow_red (s₂ k), hp1, hp2]
        have hr1le : (a₁ k : ℚ) / (b₁ k : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) := by
          rw [div_le_div_iff₀ hb₁ℚ hb₂ℚ]
          exact_mod_cast hlt.le
        rw [min_eq_right (by linarith)]

/-- Closure of `IsComputableSeqRat` under pointwise absolute value.

Witness: keep `(a, b)` unchanged; replace the sign sequence by the constant
zero. The identity reduces to `|(-1 : ℚ)^{s k} · (a k / b k)| = a k / b k`
via `abs_mul`, `abs_pow`, `|(-1 : ℚ)| = 1`, and nonnegativity of the cast
rational `(a k : ℚ) / (b k : ℚ)`. -/
theorem abs {r : ℕ → ℚ} (h : IsComputableSeqRat r) :
    IsComputableSeqRat (fun k => |r k|) := by
  obtain ⟨a, b, s, ha, hb, hs, hne, heq⟩ := h
  refine ⟨a, b, fun _ => 0, ha, hb, Computable.const 0, hne, fun k => ?_⟩
  show |r k| = (-1 : ℚ) ^ (0 : ℕ) * ((a k : ℚ) / (b k : ℚ))
  rw [heq k, abs_mul, abs_pow,
      show |(-1 : ℚ)| = 1 from by norm_num,
      one_pow, one_mul, pow_zero, one_mul,
      abs_of_nonneg (div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _))]

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

/-! ## §4.5 — Arithmetic closure of `IsComputableSeqReal`

Closure lemmas for the real-valued sequence predicate, built by lifting the §4
rational-level closures through `isComputableSeqReal_of_effectiveConvergence`
(§2.5). Naming follows Mathlib's dot-notation convention (`Continuous.add`):
the theorems live in `namespace IsComputableSeqReal` so callers write
`h₁.add h₂`. -/

namespace IsComputableSeqReal

/-- Closure of `IsComputableSeqReal` under pointwise addition.

Witness: take `(ra)` from `ha` and `(rb)` from `hb`, combine as
`r(n,k) := ra(n,k) + rb(n,k)` (via `IsComputableSeqRat.add` on the flattened
forms), with effective modulus `e(n,N) := N + 1`. The bound
`|(ra + rb)(n,k) − (a + b) n| ≤ 1/2^k + 1/2^k = 2/2^k ≤ 1/2^N` for
`k ≥ N + 1` follows from `abs_add_le` and `2 · 2^N ≤ 2^k`.

ref: P-R Ch. 0 Proposition 1 (chapt0:246) — closure under effective limits;
the additive closure is implicit. -/
theorem add
    {a b : ℕ → ℝ}
    (ha : IsComputableSeqReal a) (hb : IsComputableSeqReal b) :
    IsComputableSeqReal (a + b) := by
  obtain ⟨ra, hra, hra_bnd⟩ := ha
  obtain ⟨rb, hrb, hrb_bnd⟩ := hb
  refine isComputableSeqReal_of_effectiveConvergence
    (r := fun p => ra p + rb p) ?_ (e := fun p => p.2 + 1) ?_ ?_
  · -- `IsComputableDoubleSeqRat (fun p => ra p + rb p)` via `.add` on flattened forms.
    have hra_flat : IsComputableSeqRat (fun n => ra (Nat.unpair n)) := hra
    have hrb_flat : IsComputableSeqRat (fun n => rb (Nat.unpair n)) := hrb
    exact hra_flat.add hrb_flat
  · -- `Computable (fun p : ℕ × ℕ => p.2 + 1)`.
    exact Computable.succ.comp Computable.snd
  · -- Convergence bound.
    intro n N k hk
    have h_eq :
        (((ra (n, k) + rb (n, k) : ℚ) : ℝ)) - (a + b) n =
          (((ra (n, k) : ℝ)) - a n) + (((rb (n, k) : ℝ)) - b n) := by
      push_cast
      simp [Pi.add_apply]
      ring
    have h_tri :
        |(((ra (n, k) + rb (n, k) : ℚ) : ℝ)) - (a + b) n| ≤
          |((ra (n, k) : ℝ)) - a n| + |((rb (n, k) : ℝ)) - b n| := by
      rw [h_eq]; exact abs_add_le _ _
    have h_a : |((ra (n, k) : ℝ)) - a n| ≤ (1 : ℝ) / 2 ^ k := hra_bnd n k
    have h_b : |((rb (n, k) : ℝ)) - b n| ≤ (1 : ℝ) / 2 ^ k := hrb_bnd n k
    have h_inv_le : (1 : ℝ) / 2 ^ k + (1 : ℝ) / 2 ^ k ≤ (1 : ℝ) / 2 ^ N := by
      have hk_pos : (0 : ℝ) < 2 ^ k := by positivity
      have hN_pos : (0 : ℝ) < 2 ^ N := by positivity
      have h_pow_le : (2 : ℝ) ^ (N + 1) ≤ 2 ^ k :=
        pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) hk
      rw [pow_succ] at h_pow_le
      rw [show (1 : ℝ) / 2 ^ k + (1 : ℝ) / 2 ^ k = 2 / 2 ^ k from by ring]
      rw [div_le_div_iff₀ hk_pos hN_pos]
      linarith
    linarith

/-- Closure of `IsComputableSeqReal` under pointwise negation.

Witness `r(n,k) := - ra(n,k)` (via `IsComputableSeqRat.neg` on the flattened
form), with the modulus reused unchanged: `|(- ra(n,k) : ℝ) − (- a n)| =
|ra(n,k) − a n| ≤ 1/2^k ≤ 1/2^N` for `k ≥ N`, via `abs_neg`.

ref: P-R Ch. 0 Proposition 1 (chapt0:246) — negation closure implicit. -/
theorem neg
    {a : ℕ → ℝ} (ha : IsComputableSeqReal a) :
    IsComputableSeqReal (fun n => - a n) := by
  obtain ⟨ra, hra, hra_bnd⟩ := ha
  refine isComputableSeqReal_of_effectiveConvergence
    (r := fun p => - ra p) ?_ (e := fun p => p.2) ?_ ?_
  · -- `IsComputableDoubleSeqRat (fun p => - ra p)` via `.neg` on flattened form.
    have hra_flat : IsComputableSeqRat (fun n => ra (Nat.unpair n)) := hra
    exact hra_flat.neg
  · -- `Computable (fun p : ℕ × ℕ => p.2)`.
    exact Computable.snd
  · -- Convergence bound. `|- ra(n,k) − (- a n)| = |ra(n,k) − a n|`.
    intro n N k hk
    have h_eq :
        (((- ra (n, k) : ℚ) : ℝ)) - (- a n) =
          - (((ra (n, k) : ℝ)) - a n) := by
      push_cast
      ring
    have h_abs :
        |(((- ra (n, k) : ℚ) : ℝ)) - (- a n)| = |((ra (n, k) : ℝ)) - a n| := by
      rw [h_eq, abs_neg]
    rw [h_abs]
    have h_pow_le : (2 : ℝ) ^ N ≤ 2 ^ k :=
      pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) hk
    have hN_pos : (0 : ℝ) < 2 ^ N := by positivity
    have hk_pos : (0 : ℝ) < 2 ^ k := by positivity
    have h_inv :
        (1 : ℝ) / 2 ^ k ≤ (1 : ℝ) / 2 ^ N :=
      one_div_le_one_div_of_le hN_pos h_pow_le
    exact le_trans (hra_bnd n k) h_inv

/-- Every computable real sequence has a `Computable` Nat-valued upper bound.

From the `IsComputableSeqRat`-witness `(a_w, b_w, s_w)` of the flattened
double sequence, the value at `Nat.pair n 0` produces the numerator/
denominator of the rational approximation `ry(n, 0)` of `y n` to error `≤ 1`.
Then `|y n| ≤ |ry(n, 0)| + 1 = a_w(Nat.pair n 0)/b_w(Nat.pair n 0) + 1 ≤
a_w(Nat.pair n 0) + 1 ≤ a_w(Nat.pair n 0) + b_w(Nat.pair n 0) + 1 =: M(n)`,
with `M` Computable as a Nat-arithmetic composition. -/
theorem bound {y : ℕ → ℝ} (hy : IsComputableSeqReal y) :
    ∃ M : ℕ → ℕ, Computable M ∧ ∀ n, |y n| ≤ (M n : ℝ) := by
  obtain ⟨ry, hry, hry_bnd⟩ := hy
  obtain ⟨a_w, b_w, s_w, ha_w, hb_w, _hs_w, hne_w, heq_w⟩ := hry
  -- The Computable indexing `n ↦ Nat.pair n 0`.
  have hN_comp : Computable (fun n : ℕ => Nat.pair n 0) :=
    Primrec₂.natPair.to_comp.comp Computable.id (Computable.const 0)
  refine ⟨fun n => a_w (Nat.pair n 0) + b_w (Nat.pair n 0) + 1, ?_, fun n => ?_⟩
  · -- `Computable (fun n => a_w (Nat.pair n 0) + b_w (Nat.pair n 0) + 1)`.
    refine Primrec.nat_add.to_comp.comp ?_ (Computable.const 1)
    exact Primrec.nat_add.to_comp.comp (ha_w.comp hN_comp) (hb_w.comp hN_comp)
  · -- Bound: `|y n| ≤ a_w(Nat.pair n 0) + b_w(Nat.pair n 0) + 1`.
    -- Step (a): `|y n| ≤ |((ry (n, 0) : ℚ) : ℝ)| + 1` (triangle with rational approximant).
    have h_err : |((ry (n, 0) : ℚ) : ℝ) - y n| ≤ 1 := by
      have := hry_bnd n 0
      simpa using this
    have h_yle : |y n| ≤ |((ry (n, 0) : ℚ) : ℝ)| + 1 := by
      have h1 : y n = (y n - ((ry (n, 0) : ℚ) : ℝ)) + ((ry (n, 0) : ℚ) : ℝ) := by ring
      calc |y n|
          = |(y n - ((ry (n, 0) : ℚ) : ℝ)) + ((ry (n, 0) : ℚ) : ℝ)| := by rw [← h1]
        _ ≤ |y n - ((ry (n, 0) : ℚ) : ℝ)| + |((ry (n, 0) : ℚ) : ℝ)| := abs_add_le _ _
        _ = |((ry (n, 0) : ℚ) : ℝ) - y n| + |((ry (n, 0) : ℚ) : ℝ)| := by
            rw [abs_sub_comm]
        _ ≤ 1 + |((ry (n, 0) : ℚ) : ℝ)| := by linarith
        _ = |((ry (n, 0) : ℚ) : ℝ)| + 1 := by ring
    -- Step (b): `|ry(n, 0)|` as a ℚ reduces to `a_w/b_w` via the witness equation,
    -- after `Nat.unpair_pair`-eliminating the `Nat.unpair (Nat.pair n 0)` redex.
    have h_eq : ry (n, 0) = (-1 : ℚ) ^ (s_w (Nat.pair n 0)) *
        ((a_w (Nat.pair n 0) : ℚ) / (b_w (Nat.pair n 0) : ℚ)) := by
      have h := heq_w (Nat.pair n 0)
      simpa [Nat.unpair_pair] using h
    have h_abs_q : |ry (n, 0)| =
        ((a_w (Nat.pair n 0) : ℚ) / (b_w (Nat.pair n 0) : ℚ)) := by
      rw [h_eq, abs_mul, abs_pow,
          show |(-1 : ℚ)| = 1 from by norm_num, one_pow, one_mul,
          abs_of_nonneg (div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _))]
    have h_abs_R : |((ry (n, 0) : ℚ) : ℝ)| =
        (a_w (Nat.pair n 0) : ℝ) / (b_w (Nat.pair n 0) : ℝ) := by
      rw [← Rat.cast_abs, h_abs_q]
      push_cast
      rfl
    -- Step (c): `a_w / b_w ≤ a_w` (as ℝ), since `b_w ≥ 1`.
    have hb_pos : (0 : ℝ) < (b_w (Nat.pair n 0) : ℝ) := by
      exact_mod_cast Nat.pos_of_ne_zero (hne_w _)
    have hb_ge : (1 : ℝ) ≤ (b_w (Nat.pair n 0) : ℝ) := by
      exact_mod_cast Nat.one_le_iff_ne_zero.mpr (hne_w _)
    have h_div_le : (a_w (Nat.pair n 0) : ℝ) / (b_w (Nat.pair n 0) : ℝ) ≤
        (a_w (Nat.pair n 0) : ℝ) := by
      rw [div_le_iff₀ hb_pos]
      have ha_nn : (0 : ℝ) ≤ (a_w (Nat.pair n 0) : ℝ) := Nat.cast_nonneg _
      nlinarith
    -- Step (d): Combine.
    rw [h_abs_R] at h_yle
    push_cast
    linarith

/-- Closure of `IsComputableSeqReal` under pointwise multiplication.

Witness `r(p) := ra(p) * rb(p)` (via `IsComputableSeqRat.mul` on the
flattened forms), with effective modulus
`e(n, N) := N + Ma n + Mb n + 1` where `Ma, Mb` are the Nat upper bounds
from `IsComputableSeqReal.bound`.

**Bound chain.** Decompose
`|ra(n,k) · rb(n,k) − a n · b n| = |R·(S−b n) + b n·(R−a n)|`
(where `R := (ra(n,k) : ℝ)`, `S := (rb(n,k) : ℝ)`); by triangle inequality
and `abs_mul`, this is `≤ |R|·|S−b n| + |b n|·|R−a n| ≤ |R|/2^k + |b n|/2^k`.
Using `|R| ≤ |R − a n| + |a n| ≤ 1/2^k + Ma n ≤ Ma n + 1` and `|b n| ≤ Mb n`,
the total is `≤ (Ma n + Mb n + 1)/2^k`. For `k ≥ N + Ma n + Mb n + 1`,
`2^k ≥ 2^N · 2^(Ma+Mb+1) ≥ 2^N · (Ma + Mb + 1)` (the last step by
`Nat.lt_two_pow_self`), so the bound lands at `≤ 1/2^N`.

ref: P-R Ch. 0 Proposition 1 (chapt0:246); multiplicative closure implicit. -/
theorem mul
    {a b : ℕ → ℝ}
    (ha : IsComputableSeqReal a) (hb : IsComputableSeqReal b) :
    IsComputableSeqReal (a * b) := by
  obtain ⟨Ma, hMa_comp, hMa_bnd⟩ := ha.bound
  obtain ⟨Mb, hMb_comp, hMb_bnd⟩ := hb.bound
  obtain ⟨ra, hra, hra_bnd⟩ := ha
  obtain ⟨rb, hrb, hrb_bnd⟩ := hb
  refine isComputableSeqReal_of_effectiveConvergence
    (r := fun p => ra p * rb p) ?_ (e := fun p => p.2 + Ma p.1 + Mb p.1 + 1) ?_ ?_
  · -- `IsComputableDoubleSeqRat (fun p => ra p * rb p)` via `.mul` on flattened forms.
    have hra_flat : IsComputableSeqRat (fun n => ra (Nat.unpair n)) := hra
    have hrb_flat : IsComputableSeqRat (fun n => rb (Nat.unpair n)) := hrb
    exact hra_flat.mul hrb_flat
  · -- `Computable (fun p : ℕ × ℕ => p.2 + Ma p.1 + Mb p.1 + 1)`.
    have h_Ma_fst : Computable (fun p : ℕ × ℕ => Ma p.1) := hMa_comp.comp Computable.fst
    have h_Mb_fst : Computable (fun p : ℕ × ℕ => Mb p.1) := hMb_comp.comp Computable.fst
    have h1 : Computable (fun p : ℕ × ℕ => p.2 + Ma p.1) :=
      Primrec.nat_add.to_comp.comp Computable.snd h_Ma_fst
    have h2 : Computable (fun p : ℕ × ℕ => p.2 + Ma p.1 + Mb p.1) :=
      Primrec.nat_add.to_comp.comp h1 h_Mb_fst
    exact Primrec.nat_add.to_comp.comp h2 (Computable.const 1)
  · -- Convergence bound.
    intro n N k hk
    -- Cast: `((ra(n,k)·rb(n,k) : ℚ) : ℝ) = R · S` where R, S are the ℝ-casts.
    have h_cast :
        ((ra (n, k) * rb (n, k) : ℚ) : ℝ) =
          ((ra (n, k) : ℚ) : ℝ) * ((rb (n, k) : ℚ) : ℝ) := by push_cast; ring
    rw [h_cast]
    show |((ra (n, k) : ℚ) : ℝ) * ((rb (n, k) : ℚ) : ℝ) - a n * b n| ≤ 1 / 2 ^ N
    -- Abbreviations.
    set R := ((ra (n, k) : ℚ) : ℝ) with hR_def
    set S := ((rb (n, k) : ℚ) : ℝ) with hS_def
    -- Decomposition.
    have h_split :
        R * S - a n * b n = R * (S - b n) + b n * (R - a n) := by ring
    have h_tri :
        |R * S - a n * b n| ≤ |R| * |S - b n| + |b n| * |R - a n| := by
      rw [h_split]
      calc |R * (S - b n) + b n * (R - a n)|
          ≤ |R * (S - b n)| + |b n * (R - a n)| := abs_add_le _ _
        _ = |R| * |S - b n| + |b n| * |R - a n| := by rw [abs_mul, abs_mul]
    -- Witness bounds (precision-on-witness).
    have h_R_err : |R - a n| ≤ (1 : ℝ) / 2 ^ k := hra_bnd n k
    have h_S_err : |S - b n| ≤ (1 : ℝ) / 2 ^ k := hrb_bnd n k
    -- Magnitude bounds.
    have h_b_bnd : |b n| ≤ (Mb n : ℝ) := hMb_bnd n
    have h_a_bnd : |a n| ≤ (Ma n : ℝ) := hMa_bnd n
    -- `|R| ≤ Ma n + 1`.
    have h2k_pos : (0 : ℝ) < 2 ^ k := by positivity
    have h2N_pos : (0 : ℝ) < 2 ^ N := by positivity
    have h_inv : (1 : ℝ) / 2 ^ k ≤ 1 := by
      rw [div_le_one h2k_pos]
      exact one_le_pow₀ (by norm_num : (1 : ℝ) ≤ 2)
    have h_R_bnd : |R| ≤ (Ma n : ℝ) + 1 := by
      have h_R_split : R = (R - a n) + a n := by ring
      have h_R_le : |R| ≤ |R - a n| + |a n| := by
        calc |R| = |(R - a n) + a n| := by rw [← h_R_split]
          _ ≤ |R - a n| + |a n| := abs_add_le _ _
      linarith
    -- Total error `≤ (Ma + Mb + 1) / 2^k`.
    have h_err :
        |R * S - a n * b n| ≤ ((Ma n : ℝ) + (Mb n : ℝ) + 1) / 2 ^ k := by
      have h_RS : |R| * |S - b n| ≤ ((Ma n : ℝ) + 1) * (1 / 2 ^ k) :=
        mul_le_mul h_R_bnd h_S_err (abs_nonneg _) (by linarith)
      have h_bR : |b n| * |R - a n| ≤ (Mb n : ℝ) * (1 / 2 ^ k) :=
        mul_le_mul h_b_bnd h_R_err (abs_nonneg _) (Nat.cast_nonneg _)
      have h_combine :
          ((Ma n : ℝ) + 1) * (1 / 2 ^ k) + (Mb n : ℝ) * (1 / 2 ^ k) =
            ((Ma n : ℝ) + (Mb n : ℝ) + 1) / 2 ^ k := by ring
      linarith
    -- Final: `(Ma + Mb + 1) / 2^k ≤ 1/2^N`.
    have h_final :
        ((Ma n : ℝ) + (Mb n : ℝ) + 1) / 2 ^ k ≤ 1 / 2 ^ N := by
      rw [div_le_div_iff₀ h2k_pos h2N_pos]
      have h_pow_le : (2 : ℝ) ^ (N + Ma n + Mb n + 1) ≤ 2 ^ k :=
        pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 2) hk
      have h_pow_eq :
          (2 : ℝ) ^ (N + Ma n + Mb n + 1) = 2 ^ N * 2 ^ (Ma n + Mb n + 1) := by
        rw [show N + Ma n + Mb n + 1 = N + (Ma n + Mb n + 1) from by ring, pow_add]
      have h_pow_bnd :
          ((Ma n : ℝ) + (Mb n : ℝ) + 1) ≤ (2 : ℝ) ^ (Ma n + Mb n + 1) := by
        have h_nat : Ma n + Mb n + 1 < 2 ^ (Ma n + Mb n + 1) := Nat.lt_two_pow_self
        have h_nat_le : Ma n + Mb n + 1 ≤ 2 ^ (Ma n + Mb n + 1) := h_nat.le
        have h_real : ((Ma n + Mb n + 1 : ℕ) : ℝ) ≤
            ((2 ^ (Ma n + Mb n + 1) : ℕ) : ℝ) := by exact_mod_cast h_nat_le
        push_cast at h_real
        linarith
      have h2N_nn : (0 : ℝ) ≤ 2 ^ N := le_of_lt h2N_pos
      calc ((Ma n : ℝ) + (Mb n : ℝ) + 1) * 2 ^ N
          ≤ (2 : ℝ) ^ (Ma n + Mb n + 1) * 2 ^ N :=
            mul_le_mul_of_nonneg_right h_pow_bnd h2N_nn
        _ = 2 ^ N * 2 ^ (Ma n + Mb n + 1) := by ring
        _ ≤ 2 ^ k := by rw [← h_pow_eq]; exact h_pow_le
        _ = 1 * 2 ^ k := by ring
    linarith

end IsComputableSeqReal

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
