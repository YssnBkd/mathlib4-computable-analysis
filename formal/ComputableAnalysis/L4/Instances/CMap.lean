/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import Mathlib.Topology.ContinuousMap.Compact
import Mathlib.Topology.ContinuousMap.Bounded.Normed
import ComputableAnalysis.L1.ComputableSeqReal
import ComputableAnalysis.L3.ComputabilityStructure

/-!
# L4 — `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` (Pour-El & Richards Ch. 2 §2)

This file constructs the first concrete instance of the L3 `ComputabilityStructure`
typeclass: continuous real-valued functions on a closed real interval `[α, β]`,
with the sup-norm.

## Predicate

Per Pour-El & Richards Ch. 2:141 (equivalent to the G-L computable-sequence-of-functions
definition of Ch. 0 by the Effective Density Lemma), a sequence `{f_n}` of continuous
functions on `[α, β]` is *computable* iff it is the uniform-norm effective limit of a
computable triple sequence of rational polynomials:

> `p_{n, k}(x) = Σ_{j=0}^{d(n, k)} a_{n, k, j} · x^j`

where `{a_{n,k,j}}` is a computable triple sequence of rationals (L1 sense, flattened
via `Nat.unpair ∘ Nat.unpair`) and `d : ℕ × ℕ → ℕ` is recursive, with
`‖f_n − p_{n,k}‖_∞ ≤ 1 / 2^k` for all `n, k`.

ref: `literature/papers/PourEl-Richards-chapt2.md:141-153`.

## Why this predicate (and not the raw G-L "evaluator + modulus" form)

P-R Ch. 2:128-129 takes the predicate to be "computable sequence of computable
functions in the Ch. 0 sense" and shows A1 is trivial, A2 = Ch. 0 Theorem 4,
A3 = Ch. 0 Theorem 7. We use the *polynomial-approximation* form (2:141), which
is equivalent by the Effective Density Lemma (Ch. 2 §5 Theorem 1) and the
monomial generating set `{x^j}` being a recursively dense linear span in
`C[α, β]`. The polynomial form is closer to L1's existing `IsComputableSeqRat`
witness data, so axiom proofs can route through L1 without inlining a full L2
(Grzegorczyk-Lacombe) stub here.

## Status: **stub**

- `polyApproxCMap` and `IsComputableSeqCMap` have concrete (sorry-free) bodies
  per CLAUDE.md §sorry policy.
- The `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` instance declares all four
  axiom-fields; theorem-body sorries are present for `axiom_linearity`,
  `axiom_limits`, `axiom_norms` with explicit `-- TODO(/formalize L4 CMap):`
  comments. `zero_seq` is proved.

ref for axioms 1-3: `literature/papers/PourEl-Richards-chapt2.md:66-77`.
ref for "axiom 1 trivial / axiom 2 = Ch. 0 Thm 4 / axiom 3 = Ch. 0 Thm 7":
`literature/papers/PourEl-Richards-chapt2.md:128-129`.
-/

namespace ComputableAnalysis.L4

open scoped BigOperators
open ComputableAnalysis.L1 ComputableAnalysis.L3

/-! ## L1 closure helpers (private; TODO: refactor → `ComputableAnalysis.L1`)

These closure lemmas on `IsComputableSeqRat` are stated and proved here
inline because the active goal-frame for `l4-cmap-axiom-linearity` restricts
writes to `L4/Instances/CMap.lean`. The proper home is L1; a follow-up
round should lift these upstream once the L4 axiom proofs that depend on
them have shipped.

ref for the predicate: `literature/papers/PourEl-Richards-chapt0.md:46`
(P-R Ch. 0 Definition 1). -/

/-- **iter-05 — TODO(refactor → L1).** Closure of `IsComputableSeqRat`
under pointwise addition.

The new witness `(newA, newB, newS)` is constructed at the ℕ-level via a
4-case dispatch on the sign-parities `(s₁ k % 2, s₂ k % 2)` and the
comparison `a₁ k · b₂ k ≥ a₂ k · b₁ k`. ℕ-truncated subtraction
(`Nat.sub`) handles the sign-cancellation cases. -/
private theorem isComputableSeqRat_add
    {r₁ r₂ : ℕ → ℚ}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂) :
    IsComputableSeqRat (fun k => r₁ k + r₂ k) := by
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
      try ring
    · -- s₁ even, s₂ odd: different parity.
      have hne : s₁ k % 2 ≠ s₂ k % 2 := by rw [h₁, h₂]; decide
      simp only [if_neg hne]
      by_cases hpge : a₁ k * b₂ k ≥ a₂ k * b₁ k
      · simp only [if_pos hpge]
        rw [pow_red (s₁ k), h₁, h₂, Nat.cast_sub hpge]
        push_cast
        field_simp
        try ring
      · simp only [if_neg hpge]
        have hle : a₁ k * b₂ k ≤ a₂ k * b₁ k := le_of_not_ge hpge
        rw [pow_red (s₂ k), h₁, h₂, Nat.cast_sub hle]
        push_cast
        field_simp
        try ring
    · -- s₁ odd, s₂ even: mirror of (even, odd).
      have hne : s₁ k % 2 ≠ s₂ k % 2 := by rw [h₁, h₂]; decide
      simp only [if_neg hne]
      by_cases hpge : a₁ k * b₂ k ≥ a₂ k * b₁ k
      · simp only [if_pos hpge]
        rw [pow_red (s₁ k), h₁, h₂, Nat.cast_sub hpge]
        push_cast
        field_simp
        try ring
      · simp only [if_neg hpge]
        have hle : a₁ k * b₂ k ≤ a₂ k * b₁ k := le_of_not_ge hpge
        rw [pow_red (s₂ k), h₁, h₂, Nat.cast_sub hle]
        push_cast
        field_simp
        try ring
    · -- Both odd: same parity, newS = s₁ k (odd), newA = a₁·b₂ + a₂·b₁.
      have hsame : s₁ k % 2 = s₂ k % 2 := h₁.trans h₂.symm
      simp only [if_pos hsame]
      rw [pow_red (s₁ k), h₁, h₂]
      push_cast
      field_simp
      try ring

section CMap

variable {α β : ℝ}

/-- The `(n, k)`-th polynomial approximant: `p_{n, k}(x) := Σ_{j=0}^{d(n, k)} a_{n,k,j} · x^j`,
with rational coefficients `a (n, k, j) : ℚ` cast to ℝ, evaluated at `x : Set.Icc α β`.

This is a bona fide continuous map (polynomial in `x.val`). The `noncomputable`
mark is required because the `ℚ → ℝ` cast and the ℝ-valued multiplication are
noncomputable in Mathlib (the field structure on ℝ is itself noncomputable).
This does NOT prevent the *recursion-theoretic* witness (which lives at the
`Computable` / `ℕ → ℚ`-level, not the ℝ-level) from being constructive — see
the predicate's docstring. -/
noncomputable def polyApproxCMap
    (a : ℕ × ℕ × ℕ → ℚ) (d : ℕ × ℕ → ℕ) (n k : ℕ) : C(Set.Icc α β, ℝ) :=
  ContinuousMap.mk
    (fun x => ∑ j ∈ Finset.range (d (n, k) + 1), ((a (n, k, j) : ℝ)) * x.val ^ j)
    (by continuity)

/-- **P-R Ch. 2:141** characterization, used here as definition: a sequence
`f : ℕ → C(Set.Icc α β, ℝ)` of continuous functions on the closed interval
`[α, β]` is *computable* iff it is the uniform-norm effective limit of a
computable triple sequence of rational polynomials.

Concretely: there exist a triple-indexed sequence `a : ℕ × ℕ × ℕ → ℚ` (whose
flatten via `Nat.unpair ∘ Nat.unpair` lands in `IsComputableSeqRat`) and a
recursive bound `d : ℕ × ℕ → ℕ`, such that
`‖f n − polyApproxCMap a d n k‖_∞ ≤ 1 / 2^k` for all `n, k`. -/
def IsComputableSeqCMap (f : ℕ → C(Set.Icc α β, ℝ)) : Prop :=
  ∃ (a : ℕ × ℕ × ℕ → ℚ) (d : ℕ × ℕ → ℕ),
    IsComputableSeqRat (fun m =>
      let p := Nat.unpair m
      let q := Nat.unpair p.2
      a (p.1, q.1, q.2)) ∧
    Computable d ∧
    ∀ n k, ‖f n - polyApproxCMap (α := α) (β := β) a d n k‖ ≤ 1 / 2 ^ k

/-- The `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` instance. The predicate is
`IsComputableSeqCMap`; the axiom-fields are stub-proved (theorem-body sorries
with `-- TODO(/formalize L4 CMap):` per CLAUDE.md §sorry policy), except for
`zero_seq` which is proved directly. -/
noncomputable instance instComputabilityStructureCMap :
    ComputabilityStructure ℝ (C(Set.Icc α β, ℝ)) where
  IsComputableSeq := IsComputableSeqCMap
  axiom_linearity := by
    -- TODO(/formalize L4 CMap): A1 closure under finite scalar linear combinations.
    -- Per P-R Ch. 2:129, A1 is "trivial" for the G-L predicate. Concretely under our
    -- polynomial-approximation characterization: given `x_k, y_k` with rational-polynomial
    -- approximations `p_{k, m}, q_{k, m}` and scalar coefficients `α_{n, k}, β_{n, k} ∈ ℝ`
    -- themselves rational-approximable to precision `2^{-m}`, the linear combination
    -- `Σ_{k=0}^{d(n)} (α_{n, k} · x_k + β_{n, k} · y_k)` is approximated by the polynomial
    -- with rationally-approximated coefficients via `Σ_{k=0}^{d(n)} (αRat_{n,k,m} · p_{k,m} + βRat_{n,k,m} · q_{k,m})`,
    -- whose coefficients form a computable quadruple-sequence (flatten via three Nat.unpair calls).
    -- A 2x-precision pad on `m` accounts for the rational-approximation error in the scalars.
    sorry
  axiom_limits := by
    -- TODO(/formalize L4 CMap): A2 = Ch. 0 Theorem 4 (Pour-El & Richards, "effective limits
    -- of computable sequences of continuous functions are computable"). Under our predicate:
    -- given a computable double sequence `{f_{n, k}}` converging effectively to `{f_n}` with
    -- modulus `e : ℕ × ℕ → ℕ` (so `‖f_{n, k} - f_n‖_∞ ≤ 2^{-N}` for `k ≥ e(n, N)`), the
    -- diagonalized polynomial approximant
    --   `a'_{n, N, j} := a_{n, e(n, N + 1), N + 1, j}, d'_{n, N} := d_{n, e(n, N + 1), N + 1}`
    -- (where `a, d` are the witnesses for the double sequence) approximates `f_n` to precision
    -- `2^{-N+1}` by triangle inequality, and `a', d'` are computable by composition of
    -- recursive functions.
    sorry
  axiom_norms := by
    -- TODO(/formalize L4 CMap): A3 = Ch. 0 Theorem 7 (computable continuous functions have
    -- computable sup-norm). Given `f_n` computable with witness `(a, d)`, the sup-norm
    -- `‖f_n‖_∞ = sup_{x ∈ [α, β]} |f_n(x)|` can be approximated from rational data:
    -- evaluate the polynomial approximants `p_{n, k}` on a fine rational grid
    -- `{α + j · (β - α) / 2^k : j ∈ {0, ..., 2^k}}` (rational since `α, β` are recursive
    -- reals — actually here arbitrary reals; the proof uses approximations to rationals),
    -- take the maximum, and use `‖f_n - p_{n, k}‖_∞ ≤ 2^{-k}` + uniform continuity of `p_{n, k}`
    -- to bound the discretization error. This requires L1 closure under finite `max` and
    -- absolute-value (deferred L1 work).
    sorry
  zero_seq := by
    -- The all-zero polynomial approximant exactly equals the zero continuous map.
    refine ⟨fun _ => 0, fun _ => 0, ?_, Computable.const _, ?_⟩
    · exact isComputableSeqRat_const 0
    · intro n k
      have hpoly : polyApproxCMap (α := α) (β := β) (fun _ => 0) (fun _ => 0) n k = 0 := by
        ext x
        simp [polyApproxCMap]
      show ‖(0 : C(Set.Icc α β, ℝ)) - polyApproxCMap (α := α) (β := β) (fun _ => 0)
        (fun _ => 0) n k‖ ≤ 1 / 2 ^ k
      rw [hpoly, sub_zero, norm_zero]
      positivity

end CMap

/-! ## Smoke checks -/

#check @polyApproxCMap
#check @IsComputableSeqCMap
#check @instComputabilityStructureCMap

end ComputableAnalysis.L4
