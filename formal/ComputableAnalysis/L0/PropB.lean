/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import Mathlib.Computability.PartrecCode
import Mathlib.Computability.RE
import Mathlib.Computability.Halting
import ComputableAnalysis.L0.Bridge

/-!
# L0 — Pour-El & Richards Proposition B: recursively inseparable r.e. pair

P-R's **Proposition B** (Ch. 0.2:35):

> There exists a pair of subsets `A, B ⊆ ℕ` such that
>   (a) A and B are recursively enumerable;
>   (b) A ∩ B = ∅;
>   (c) There is no recursive set C with A ⊆ C and B ⊆ ℕ ∖ C.

This statement is NOT in Mathlib by any name (verified June 2026 via GitHub code
search). This file provides it, using the standard textbook construction (Soare,
*Recursively Enumerable Sets and Degrees*, II.4):

  insepA := { e : Nat.Partrec.Code | e.eval (encode e) = Part.some 0 }
  insepB := { e : Nat.Partrec.Code | e.eval (encode e) = Part.some 1 }

Both are r.e. (universal evaluation with a specified halting value), disjoint
(`0 ≠ 1`), and inseparable (a recursive separator would yield a fixed-point
contradiction via the recursion theorem).

The hard step is (c): the no-separator clause. The standard argument uses the
recursion theorem to construct a code `e` such that, given (an encoding of)
itself, `e.eval (encode e)` outputs the negation of its separator's verdict —
contradiction. The Mathlib infrastructure for this lives in
`Mathlib.Computability.PartrecCode` (the universal `Code.eval`, `evaln`, and the
related fixed-point machinery).

For now the four theorems below are sorried with detailed TODO sketches; the
*definitions* are concrete (per the project's sorry-policy), and `prop_B`
assembles them into the headline statement so downstream layers can cite it.

ref: `literature/papers/PourEl-Richards-0.2.prerequisites.md:35`
-/

namespace ComputableAnalysis.L0

open Nat.Partrec

/-- One half of an inseparable pair: codes that, run on (the encoding of) themselves,
halt with output `0`. -/
def insepA : Set Code :=
  { e | e.eval (Encodable.encode e) = Part.some 0 }

/-- The other half: codes that, run on themselves, halt with output `1`. -/
def insepB : Set Code :=
  { e | e.eval (Encodable.encode e) = Part.some 1 }

theorem insepA_re : IsRecursivelyEnumerable insepA := by
  -- TODO(/formalize L0/PropB): prove `(· ∈ insepA)` is REPred.
  -- Steps:
  --   1. `fun (e, n) => e.eval n : Code × ℕ →. ℕ` is `Partrec₂` (Mathlib has this).
  --   2. Diagonalize: `fun e => e.eval (encode e) : Code →. ℕ` is `Partrec`.
  --   3. Compose with the decidable test `_ = 0` to get REPred.
  -- Key Mathlib lemma: `Nat.Partrec.Code.eval_partrec` (or similarly named).
  sorry

theorem insepB_re : IsRecursivelyEnumerable insepB := by
  -- TODO(/formalize L0/PropB): symmetric to `insepA_re` with the value `1`.
  sorry

theorem insepA_insepB_disjoint : insepA ∩ insepB = ∅ := by
  -- TODO(/formalize L0/PropB): pointwise.
  -- If e ∈ insepA ∩ insepB then `Part.some 0 = e.eval (encode e) = Part.some 1`,
  -- hence `0 = 1` via `Part.some_injective` — contradiction by `Nat.zero_ne_one`.
  sorry

theorem insepA_insepB_no_separator :
    ¬ ∃ (C : Set Code), IsRecursiveSet C ∧ insepA ⊆ C ∧ insepB ⊆ Cᶜ := by
  -- TODO(/formalize L0/PropB): the substantive content of Prop B.
  -- Sketch (recursion-theorem / fixed-point argument):
  --   Assume separator C with `IsRecursiveSet C`, `insepA ⊆ C`, `insepB ⊆ Cᶜ`.
  --   By the recursion theorem, build a code `e₀` such that
  --     e₀.eval (encode e₀) = if e₀ ∈ C then Part.some 1 else Part.some 0.
  --   Case e₀ ∈ C: then e₀.eval (encode e₀) = Part.some 1, so e₀ ∈ insepB ⊆ Cᶜ — ⊥.
  --   Case e₀ ∉ C: then e₀.eval (encode e₀) = Part.some 0, so e₀ ∈ insepA ⊆ C  — ⊥.
  -- Mathlib's recursion theorem: search `Nat.Partrec.Code.fixed_point` /
  -- `Computable.fixed_point` (the latter may not exist; the construction is in
  -- `Mathlib.Computability.Halting` or `.PartrecCode`).
  sorry

/-- **Pour-El & Richards, Proposition B** (Ch. 0.2:35).

There exists a recursively inseparable pair of r.e. sets. -/
theorem prop_B :
    ∃ (α : Type) (_inst : Primcodable α) (A B : Set α),
      IsRecursivelyEnumerable A ∧ IsRecursivelyEnumerable B ∧
      A ∩ B = ∅ ∧
      ¬ ∃ (C : Set α), IsRecursiveSet C ∧ A ⊆ C ∧ B ⊆ Cᶜ :=
  ⟨Code, inferInstance, insepA, insepB,
    insepA_re, insepB_re, insepA_insepB_disjoint, insepA_insepB_no_separator⟩

#check @insepA
#check @insepB
#check @prop_B

end ComputableAnalysis.L0
