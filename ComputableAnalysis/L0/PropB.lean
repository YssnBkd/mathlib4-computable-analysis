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

/-- Auxiliary: the predicate "the diagonal eval halts with value `k`" is r.e.
This is the shared core of `insepA_re` (`k = 0`) and `insepB_re` (`k = 1`).

Strategy: build `g : Code →. ℕ` with `g e = (e.eval (encode e)).bind` of a
decidable kernel `fun n => cond (n == k) (some 0) none`, so
`(g e).Dom ↔ e.eval (encode e) = Part.some k`. Then `Partrec.dom_re` + `REPred.of_eq`. -/
private theorem diag_eval_eq_re (k : ℕ) :
    REPred (fun e : Code => e.eval (Encodable.encode e) = Part.some k) := by
  -- (1) Diagonal eval is `Partrec`.
  have hdiag : Partrec fun e : Code => e.eval (Encodable.encode e) :=
    Code.eval_part.comp Computable.id Computable.encode
  -- (2) Kernel uses `Partrec.cond` on the decidable Bool `n == k`.
  have hbeq : Computable (fun p : Code × ℕ => p.2 == k) :=
    (Primrec₂.comp Primrec.beq Primrec.snd (Primrec.const k)).to_comp
  have hker : Partrec (fun p : Code × ℕ =>
      cond (p.2 == k) (Part.some 0) (Part.none : Part ℕ)) :=
    Partrec.cond hbeq (Computable.const 0).partrec Partrec.none
  -- (3) Bind: `(eval e (encode e)).bind kernel`.
  have hg : Partrec fun e : Code =>
      (e.eval (Encodable.encode e)).bind
        (fun n => cond (n == k) (Part.some 0) Part.none) :=
    hdiag.bind hker
  -- (4) Convert via `dom_re` + `of_eq`. Final equivalence is pure Part calculus.
  refine (hg.dom_re).of_eq fun e => ?_
  rw [Part.bind_dom]
  constructor
  · rintro ⟨h_dom, h_cond⟩
    by_cases hvk : (e.eval (Encodable.encode e)).get h_dom = k
    · have hmem : (e.eval (Encodable.encode e)).get h_dom ∈ e.eval (Encodable.encode e) :=
        Part.get_mem h_dom
      rw [hvk] at hmem
      exact Part.eq_some_iff.mpr hmem
    · exfalso
      have hne : ((e.eval (Encodable.encode e)).get h_dom == k) = false := by
        simpa [beq_iff_eq] using hvk
      rw [hne, Bool.cond_false] at h_cond
      exact Part.not_none_dom h_cond
  · intro hev
    rw [hev]
    refine ⟨trivial, ?_⟩
    simp

theorem insepA_re : IsRecursivelyEnumerable insepA :=
  diag_eval_eq_re 0

theorem insepB_re : IsRecursivelyEnumerable insepB :=
  diag_eval_eq_re 1

theorem insepA_insepB_disjoint : insepA ∩ insepB = ∅ := by
  ext e
  simp only [Set.mem_inter_iff, Set.mem_empty_iff_false, iff_false, not_and]
  -- `e ∈ insepA` and `e ∈ insepB` give two `Part.some` values for the same
  -- partial-recursive evaluation; transitivity yields `Part.some 0 = Part.some 1`.
  intro hA hB
  exact absurd (Part.some_inj.mp (hA.symm.trans hB)) (by decide)

theorem insepA_insepB_no_separator :
    ¬ ∃ (C : Set Code), IsRecursiveSet C ∧ insepA ⊆ C ∧ insepB ⊆ Cᶜ := by
  rintro ⟨C, hC, hA, hB⟩
  -- Classical to get a Decidable instance on `(· ∈ C)`; then extract the Bool indicator.
  classical
  have hC_comp : Computable (fun c : Code => decide (c ∈ C)) := hC.decide
  -- Define `f c n := if c ∈ C then Part.some 1 else Part.some 0` (ignoring `n`).
  -- The recursion theorem will produce a code `e₀` such that `eval e₀ = f e₀`.
  let f : Code → ℕ →. ℕ := fun c _ => if c ∈ C then Part.some 1 else Part.some 0
  have hf : Partrec₂ f := by
    show Partrec fun p : Code × ℕ => f p.1 p.2
    have hdec : Computable (fun p : Code × ℕ => decide (p.1 ∈ C)) :=
      hC_comp.comp Computable.fst
    have hcond : Partrec (fun p : Code × ℕ =>
        (cond (decide (p.1 ∈ C)) (Part.some 1) (Part.some 0) : Part ℕ)) :=
      Partrec.cond hdec (Computable.const 1).partrec (Computable.const 0).partrec
    refine hcond.of_eq fun p => ?_
    by_cases h : p.1 ∈ C <;> simp [f, h]
  -- Apply the recursion theorem (Kleene): get `e₀` with `eval e₀ = f e₀`.
  obtain ⟨e₀, he₀⟩ := Code.fixed_point₂ hf
  -- Specialize to the input `encode e₀`.
  by_cases hC₀ : e₀ ∈ C
  · have h_eval : e₀.eval (Encodable.encode e₀) = Part.some 1 := by
      rw [he₀]; simp [f, hC₀]
    have hmemB : e₀ ∈ insepB := h_eval
    exact (hB hmemB) hC₀
  · have h_eval : e₀.eval (Encodable.encode e₀) = Part.some 0 := by
      rw [he₀]; simp [f, hC₀]
    have hmemA : e₀ ∈ insepA := h_eval
    exact hC₀ (hA hmemA)

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
