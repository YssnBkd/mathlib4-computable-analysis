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
