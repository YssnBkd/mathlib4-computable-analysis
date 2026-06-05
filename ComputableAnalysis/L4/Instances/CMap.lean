/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import Mathlib.Topology.ContinuousMap.Compact
import Mathlib.Topology.ContinuousMap.Bounded.Normed
import Mathlib.Order.PartialSups
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
  fields; `isComputableSeq_linearCombination` (A1) and `zero_seq` are proved,
  while `isComputableSeq_of_effectiveLimit` (A2) and `isComputableSeqReal_norm`
  (A3) carry `-- TODO(/formalize L4 CMap):` sorries.

ref for axioms 1-3: `literature/papers/PourEl-Richards-chapt2.md:66-77`.
ref for "axiom 1 trivial / axiom 2 = Ch. 0 Thm 4 / axiom 3 = Ch. 0 Thm 7":
`literature/papers/PourEl-Richards-chapt2.md:128-129`.
-/

namespace ComputableAnalysis.L4

open scoped BigOperators
open ComputableAnalysis.L1 ComputableAnalysis.L3

/-! ## §0 — Private helpers for A1 (TODO refactor → L1)

Closure of `IsComputableSeqRat` under finite sums over a Computable-bounded
range. Lives here as a `private`/namespaced helper because L1 is in
`forbid_writes` for the current round (`l4-cmap-axiom-linearity-cont`); will
be lifted to `IsComputableSeqRat.finsetSum` in `ComputableSeqReal.lean` in a
follow-up round (per `docs/NEXT-SESSION.md`'s `l1-rat-finsetsum` plan). -/

namespace FinsetSumHelper

/-- The triple-witness add formula at the ℕ-level, matching the construction
in L1 `IsComputableSeqRat.add` (`ComputableSeqReal.lean:194-200`). Given two
triples `(a, b, s)` representing rationals via `(-1)^s · (a / b)`, returns the
triple representing their sum. -/
def addTriple (t₁ t₂ : ℕ × ℕ × ℕ) : ℕ × ℕ × ℕ :=
  if t₁.2.2 % 2 = t₂.2.2 % 2 then
    (t₁.1 * t₂.2.1 + t₂.1 * t₁.2.1, t₁.2.1 * t₂.2.1, t₁.2.2)
  else if t₁.1 * t₂.2.1 ≥ t₂.1 * t₁.2.1 then
    (t₁.1 * t₂.2.1 - t₂.1 * t₁.2.1, t₁.2.1 * t₂.2.1, t₁.2.2)
  else
    (t₂.1 * t₁.2.1 - t₁.1 * t₂.2.1, t₁.2.1 * t₂.2.1, t₂.2.2)

theorem addTriple_b_ne_zero {t₁ t₂ : ℕ × ℕ × ℕ}
    (hb₁ : t₁.2.1 ≠ 0) (hb₂ : t₂.2.1 ≠ 0) :
    (addTriple t₁ t₂).2.1 ≠ 0 := by
  unfold addTriple
  split_ifs <;> exact Nat.mul_ne_zero hb₁ hb₂

/-- The rational value represented by a triple `(a, b, s)`: `(-1)^s · (a / b)`. -/
def tripleToRat (t : ℕ × ℕ × ℕ) : ℚ :=
  (-1 : ℚ) ^ t.2.2 * ((t.1 : ℚ) / (t.2.1 : ℚ))

theorem addTriple_correct {t₁ t₂ : ℕ × ℕ × ℕ}
    (hb₁ : t₁.2.1 ≠ 0) (hb₂ : t₂.2.1 ≠ 0) :
    tripleToRat (addTriple t₁ t₂) = tripleToRat t₁ + tripleToRat t₂ := by
  obtain ⟨a₁, b₁, s₁⟩ := t₁
  obtain ⟨a₂, b₂, s₂⟩ := t₂
  simp only at hb₁ hb₂
  have hb₁q : (b₁ : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hb₁
  have hb₂q : (b₂ : ℚ) ≠ 0 := Nat.cast_ne_zero.mpr hb₂
  unfold tripleToRat addTriple
  have pow_red : ∀ n : ℕ, (-1 : ℚ) ^ n = (-1) ^ (n % 2) := fun n => by
    conv_lhs => rw [← Nat.div_add_mod n 2, pow_add, pow_mul]
    simp
  rw [pow_red s₁, pow_red s₂]
  rcases Nat.mod_two_eq_zero_or_one s₁ with h₁ | h₁ <;>
    rcases Nat.mod_two_eq_zero_or_one s₂ with h₂ | h₂
  · have hsame : s₁ % 2 = s₂ % 2 := h₁.trans h₂.symm
    simp only [if_pos hsame]
    rw [pow_red s₁, h₁, h₂]; push_cast; field_simp
  · have hne : s₁ % 2 ≠ s₂ % 2 := by rw [h₁, h₂]; decide
    simp only [if_neg hne]
    by_cases hpge : a₁ * b₂ ≥ a₂ * b₁
    · simp only [if_pos hpge]
      rw [pow_red s₁, h₁, h₂, Nat.cast_sub hpge]; push_cast; field_simp; ring
    · simp only [if_neg hpge]
      have hle : a₁ * b₂ ≤ a₂ * b₁ := le_of_not_ge hpge
      rw [pow_red s₂, h₁, h₂, Nat.cast_sub hle]; push_cast; field_simp; ring
  · have hne : s₁ % 2 ≠ s₂ % 2 := by rw [h₁, h₂]; decide
    simp only [if_neg hne]
    by_cases hpge : a₁ * b₂ ≥ a₂ * b₁
    · simp only [if_pos hpge]
      rw [pow_red s₁, h₁, h₂, Nat.cast_sub hpge]; push_cast; field_simp; ring
    · simp only [if_neg hpge]
      have hle : a₁ * b₂ ≤ a₂ * b₁ := le_of_not_ge hpge
      rw [pow_red s₂, h₁, h₂, Nat.cast_sub hle]; push_cast; field_simp; ring
  · have hsame : s₁ % 2 = s₂ % 2 := h₁.trans h₂.symm
    simp only [if_pos hsame]
    rw [pow_red s₁, h₁, h₂]; push_cast; field_simp; ring

theorem addTriple_computable : Computable₂ addTriple := by
  show Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => addTriple t.1 t.2)
  -- Projections.
  have ha₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.1) :=
    Computable.fst.comp Computable.fst
  have hb₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.2.1) :=
    (Computable.fst.comp Computable.snd).comp Computable.fst
  have hs₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.2.2) :=
    (Computable.snd.comp Computable.snd).comp Computable.fst
  have ha₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.1) :=
    Computable.fst.comp Computable.snd
  have hb₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.2.1) :=
    (Computable.fst.comp Computable.snd).comp Computable.snd
  have hs₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.2.2) :=
    (Computable.snd.comp Computable.snd).comp Computable.snd
  -- Cross products.
  have hp₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.1 * t.2.2.1) :=
    Primrec.nat_mul.to_comp.comp ha₁ hb₂
  have hp₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.1 * t.1.2.1) :=
    Primrec.nat_mul.to_comp.comp ha₂ hb₁
  have hnewB : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.2.1 * t.2.2.1) :=
    Primrec.nat_mul.to_comp.comp hb₁ hb₂
  -- Parity and comparison Bools.
  have hpar₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.2.2 % 2) :=
    Primrec.nat_mod.to_comp.comp hs₁ (Computable.const 2)
  have hpar₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.2.2 % 2) :=
    Primrec.nat_mod.to_comp.comp hs₂ (Computable.const 2)
  have hbeq_par : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      decide (t.1.2.2 % 2 = t.2.2.2 % 2)) :=
    Primrec.beq.to_comp.comp hpar₁ hpar₂
  have hge : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      decide (t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1)) := by
    have : Primrec₂ (fun a b : ℕ => decide (a ≥ b)) := Primrec.nat_le.swap.decide
    exact this.to_comp.comp hp₁ hp₂
  -- Sums/diffs of the cross products.
  have hsumA : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      t.1.1 * t.2.2.1 + t.2.1 * t.1.2.1) :=
    Primrec.nat_add.to_comp.comp hp₁ hp₂
  have hsubA1 : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      t.1.1 * t.2.2.1 - t.2.1 * t.1.2.1) :=
    Primrec.nat_sub.to_comp.comp hp₁ hp₂
  have hsubA2 : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      t.2.1 * t.1.2.1 - t.1.1 * t.2.2.1) :=
    Primrec.nat_sub.to_comp.comp hp₂ hp₁
  -- Inner conds.
  have h_innerA : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      bif decide (t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1)
        then t.1.1 * t.2.2.1 - t.2.1 * t.1.2.1
        else t.2.1 * t.1.2.1 - t.1.1 * t.2.2.1) :=
    Computable.cond hge hsubA1 hsubA2
  have h_newA : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      bif decide (t.1.2.2 % 2 = t.2.2.2 % 2)
        then t.1.1 * t.2.2.1 + t.2.1 * t.1.2.1
        else bif decide (t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1)
          then t.1.1 * t.2.2.1 - t.2.1 * t.1.2.1
          else t.2.1 * t.1.2.1 - t.1.1 * t.2.2.1) :=
    Computable.cond hbeq_par hsumA h_innerA
  have h_innerS : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      bif decide (t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1) then t.1.2.2 else t.2.2.2) :=
    Computable.cond hge hs₁ hs₂
  have h_newS : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      bif decide (t.1.2.2 % 2 = t.2.2.2 % 2) then t.1.2.2
        else bif decide (t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1) then t.1.2.2 else t.2.2.2) :=
    Computable.cond hbeq_par hs₁ h_innerS
  -- Bundle as triple.
  have h_triple : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      ((bif decide (t.1.2.2 % 2 = t.2.2.2 % 2)
          then t.1.1 * t.2.2.1 + t.2.1 * t.1.2.1
          else bif decide (t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1)
            then t.1.1 * t.2.2.1 - t.2.1 * t.1.2.1
            else t.2.1 * t.1.2.1 - t.1.1 * t.2.2.1),
       t.1.2.1 * t.2.2.1,
       bif decide (t.1.2.2 % 2 = t.2.2.2 % 2) then t.1.2.2
         else bif decide (t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1) then t.1.2.2 else t.2.2.2)) :=
    h_newA.pair (hnewB.pair h_newS)
  -- of_eq into addTriple's ite form.
  refine h_triple.of_eq fun t => ?_
  unfold addTriple
  by_cases hp : t.1.2.2 % 2 = t.2.2.2 % 2
  · simp [hp]
  · simp only [decide_eq_false (by simpa using hp), Bool.cond_false, if_neg hp]
    by_cases hg : t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1
    · simp [hg]
    · simp [hg]

/-- Closure of `IsComputableSeqRat` under finite sum over a Computable-bounded
range. Given `r : ℕ × ℕ → ℚ` with `IsComputableDoubleSeqRat r` and
`n : ℕ → ℕ` Computable, the sequence `fun k => ∑ j ∈ Finset.range (n k + 1), r (k, j)`
is in `IsComputableSeqRat`.

The witness `(newA, newB, newS) : ℕ → ℕ` is built via `Computable.nat_rec` on
the bound `n k + 1`, with the (a, b, s)-add formula (`addTriple`) as the
recursive step. -/
theorem finsetSum_rat
    {r : ℕ × ℕ → ℚ} (h : IsComputableDoubleSeqRat r)
    {n : ℕ → ℕ} (hn : Computable n) :
    IsComputableSeqRat (fun k => ∑ j ∈ Finset.range (n k + 1), r (k, j)) := by
  obtain ⟨a_r, b_r, s_r, ha_r, hb_r, hs_r, hne_r, heq_r⟩ := h
  -- Witness triple `absTriple k m` = accumulated (a, b, s) after summing
  -- `r (k, 0), …, r (k, m-1)`. The target is `absTriple k (n k).succ`.
  -- Bound uses `.succ` (not `+ 1`) to match `Computable.nat_rec`'s syntactic form;
  -- the two are definitionally equal so the theorem statement (using `n k + 1`) is
  -- unaffected.
  let absTriple : ℕ → ℕ × ℕ × ℕ := fun k =>
    Nat.rec (motive := fun _ => ℕ × ℕ × ℕ)
      ((0, 1, 0) : ℕ × ℕ × ℕ)
      (fun y IH => addTriple IH
        (a_r (Nat.pair k y), b_r (Nat.pair k y), s_r (Nat.pair k y)))
      ((n k).succ)
  -- Computability of absTriple.
  have h_absTriple : Computable absTriple := by
    -- Step function for Computable.nat_rec, made explicit to avoid HO unification.
    have h_step : Computable₂ (fun (k : ℕ) (yih : ℕ × (ℕ × ℕ × ℕ)) =>
        addTriple yih.2
          (a_r (Nat.pair k yih.1), b_r (Nat.pair k yih.1), s_r (Nat.pair k yih.1))) := by
      show Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) =>
        addTriple p.2.2 (a_r (Nat.pair p.1 p.2.1),
                         b_r (Nat.pair p.1 p.2.1),
                         s_r (Nat.pair p.1 p.2.1)))
      have h_k : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) => p.1) := Computable.fst
      have h_y : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) => p.2.1) :=
        Computable.fst.comp Computable.snd
      have h_ih : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) => p.2.2) :=
        Computable.snd.comp Computable.snd
      have h_pair_ky : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) => Nat.pair p.1 p.2.1) :=
        Primrec₂.natPair.to_comp.comp h_k h_y
      have h_t2 : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) =>
          (a_r (Nat.pair p.1 p.2.1),
           b_r (Nat.pair p.1 p.2.1),
           s_r (Nat.pair p.1 p.2.1))) :=
        (ha_r.comp h_pair_ky).pair ((hb_r.comp h_pair_ky).pair (hs_r.comp h_pair_ky))
      exact addTriple_computable.comp h_ih h_t2
    exact Computable.nat_rec (Computable.succ.comp hn)
      (Computable.const ((0, 1, 0) : ℕ × ℕ × ℕ)) h_step
  -- Auxiliary: for any m, the b component is non-zero and the rational value matches.
  have rec_aux : ∀ k m,
      (Nat.rec (motive := fun _ => ℕ × ℕ × ℕ)
        (0, 1, 0)
        (fun y IH => addTriple IH
          (a_r (Nat.pair k y), b_r (Nat.pair k y), s_r (Nat.pair k y)))
        m).2.1 ≠ 0 ∧
      tripleToRat (Nat.rec (motive := fun _ => ℕ × ℕ × ℕ)
        (0, 1, 0)
        (fun y IH => addTriple IH
          (a_r (Nat.pair k y), b_r (Nat.pair k y), s_r (Nat.pair k y)))
        m) = ∑ j ∈ Finset.range m, r (k, j) := by
    intro k m
    induction m with
    | zero =>
      refine ⟨?_, ?_⟩
      · -- Nat.rec ... 0 reduces to (0,1,0); .2.1 = 1 ≠ 0.
        exact Nat.one_ne_zero
      · -- Nat.rec ... 0 = (0,1,0); tripleToRat (0,1,0) = 0; ∑ over range 0 = 0.
        simp [tripleToRat]
    | succ m IH =>
      obtain ⟨ih_b, ih_val⟩ := IH
      refine ⟨?_, ?_⟩
      · -- Nat.rec ... (m+1) reduces to addTriple (Nat.rec ... m) (r-witness m).
        exact addTriple_b_ne_zero ih_b (hne_r (Nat.pair k m))
      · -- Nat.rec ... (m+1) reduces; use addTriple_correct + ih_val + Finset.sum_range_succ.
        rw [Finset.sum_range_succ]
        rw [addTriple_correct ih_b (hne_r (Nat.pair k m)), ih_val]
        congr 1
        -- Goal: tripleToRat (a_r p, b_r p, s_r p) = r (k, m) for p := Nat.pair k m.
        have heq_rkm := heq_r (Nat.pair k m)
        simp only [Nat.unpair_pair] at heq_rkm
        -- heq_rkm : r (k, m) = (-1)^(s_r p) * ((a_r p : ℚ) / (b_r p : ℚ))
        show (-1 : ℚ)^(s_r (Nat.pair k m)) *
            ((a_r (Nat.pair k m) : ℚ) / (b_r (Nat.pair k m) : ℚ)) = r (k, m)
        exact heq_rkm.symm
  refine ⟨fun k => (absTriple k).1, fun k => (absTriple k).2.1, fun k => (absTriple k).2.2,
    Computable.fst.comp h_absTriple,
    (Computable.fst.comp Computable.snd).comp h_absTriple,
    (Computable.snd.comp Computable.snd).comp h_absTriple,
    ?_, ?_⟩
  · intro k
    exact (rec_aux k (n k).succ).1
  · intro k
    have := (rec_aux k (n k).succ).2
    -- this : tripleToRat (Nat.rec ... (n k).succ) = ∑ j ∈ range (n k).succ, r (k, j)
    -- (n k).succ = n k + 1 defeq; absTriple k = Nat.rec ... (n k).succ defeq.
    change ∑ j ∈ Finset.range (n k + 1), r (k, j) = tripleToRat (absTriple k)
    exact this.symm

/-- Convenience: given `IsComputableDoubleSeqRat f` (i.e. flat of `f : ℕ × ℕ → ℚ`
is in IsComputableSeqRat) and two Computable indexers `a, b : ℕ → ℕ`, the
sequence `fun p => f (a p, b p)` is in IsComputableSeqRat. -/
theorem isComputableSeqRat_doubleApply
    {f : ℕ × ℕ → ℚ} (hf : IsComputableDoubleSeqRat f)
    {a b : ℕ → ℕ} (ha : Computable a) (hb : Computable b) :
    IsComputableSeqRat (fun p => f (a p, b p)) := by
  have h_σ : Computable (fun p => Nat.pair (a p) (b p)) :=
    Primrec₂.natPair.to_comp.comp ha hb
  have key : IsComputableSeqRat (fun p => f (Nat.unpair (Nat.pair (a p) (b p)))) :=
    hf.comp h_σ
  have heq : (fun p => f (Nat.unpair (Nat.pair (a p) (b p)))) = (fun p => f (a p, b p)) := by
    funext p; rw [Nat.unpair_pair]
  rwa [heq] at key

/-- Convenience for triple-indexed rational sequences. Given the flatten of
`f : ℕ × ℕ × ℕ → ℚ` (via three Nat.unpair calls) is in IsComputableSeqRat,
and Computable indexers `a, b, c : ℕ → ℕ`, the sequence `fun p => f (a p, b p, c p)`
is in IsComputableSeqRat. -/
theorem isComputableSeqRat_tripleApply
    {f : ℕ × ℕ × ℕ → ℚ}
    (hf : IsComputableSeqRat (fun m =>
      f ((Nat.unpair m).1, (Nat.unpair (Nat.unpair m).2).1, (Nat.unpair (Nat.unpair m).2).2)))
    {a b c : ℕ → ℕ} (ha : Computable a) (hb : Computable b) (hc : Computable c) :
    IsComputableSeqRat (fun p => f (a p, b p, c p)) := by
  have h_bc : Computable (fun p => Nat.pair (b p) (c p)) :=
    Primrec₂.natPair.to_comp.comp hb hc
  have h_σ : Computable (fun p => Nat.pair (a p) (Nat.pair (b p) (c p))) :=
    Primrec₂.natPair.to_comp.comp ha h_bc
  have key := hf.comp h_σ
  -- key has the function-composition form; convert to beta-reduced form.
  convert key using 1
  funext p
  simp [Function.comp, Nat.unpair_pair]

/-- Closure of `IsComputableSeqRat` under `Computable`-Bool conditional with two
`IsComputableSeqRat` branches. The witness is built by Computable-Bool-cond on
each of the (a, b, s) components and a case-split on the rational identity.

TODO(refactor → L1 as `IsComputableSeqRat.ite`): needed for A1's `padcoeff`
construction (zeroing out polynomial coefficients past the per-k degree bound). -/
theorem ite_rat
    {r₁ r₂ : ℕ → ℚ} {c : ℕ → Bool}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂)
    (hc : Computable c) :
    IsComputableSeqRat (fun k => bif c k then r₁ k else r₂ k) := by
  obtain ⟨a₁, b₁, s₁, ha₁, hb₁, hs₁, hne₁, heq₁⟩ := h₁
  obtain ⟨a₂, b₂, s₂, ha₂, hb₂, hs₂, hne₂, heq₂⟩ := h₂
  refine ⟨fun k => bif c k then a₁ k else a₂ k,
    fun k => bif c k then b₁ k else b₂ k,
    fun k => bif c k then s₁ k else s₂ k,
    Computable.cond hc ha₁ ha₂,
    Computable.cond hc hb₁ hb₂,
    Computable.cond hc hs₁ hs₂,
    ?_, ?_⟩
  · intro k
    cases hck : c k with
    | true => simp [hck, hne₁ k]
    | false => simp [hck, hne₂ k]
  · intro k
    cases hck : c k with
    | true => simp [hck, heq₁ k]
    | false => simp [hck, heq₂ k]

end FinsetSumHelper

/-! ## §0a — Private helper for A3 (TODO refactor → L1)

Closure of `IsComputableSeqRat` under finite `Finset.sup'` (max) over a
Computable-bounded range, the max-analogue of `FinsetSumHelper.finsetSum_rat`.
Needed by A3 (`isComputableSeqCMap_norm`): the partial-maximum double sequence
`s_{n,k} = max_{j ≤ k} |pₙₖ(grid j)|` is built by folding a Computable
witness-triple max over `j`.

Lives here (not L1) because L1 is in `forbid_writes` for the active round;
slated for lifting to `IsComputableSeqRat.finsetSup'` in a follow-up L1 round. -/

namespace FinsetMaxHelper

open FinsetSumHelper (tripleToRat)

/-- Boolean discriminator: `maxBool t₁ t₂ = true` iff the rational represented by
`t₁` is `≥` the one represented by `t₂`. Same sign-aware decision tree as
`IsComputableSeqRat.max`'s inline `chooseR1`
(`ComputableAnalysis/L1/ComputableSeqReal.lean:457-465`), specialised to the
witness-triple `(a, b, s) ↦ (-1)^s · (a / b)` encoding. -/
def maxBool (t₁ t₂ : ℕ × ℕ × ℕ) : Bool :=
  bif decide (t₁.2.2 % 2 = t₂.2.2 % 2) then
    (bif decide (t₁.2.2 % 2 = 0) then
      decide (t₁.1 * t₂.2.1 ≥ t₂.1 * t₁.2.1)
    else
      decide (t₁.1 * t₂.2.1 ≤ t₂.1 * t₁.2.1))
  else
    decide (t₁.2.2 % 2 = 0)

/-- Witness-triple max via **wholesale selection**: return whichever input triple
represents the larger rational, unchanged. Returning an input verbatim (rather
than recombining `(a, b, s)` components as in the `add` case) keeps
`maxTriple_b_ne_zero` a one-liner and reduces `maxTriple_correct` to a clean
`⊔`-identity — sidestepping the component-recombination that stalled the iter-04
attempt (`.goals/l4-cmap-axiom3-norm-resig/iter-04.md`). -/
def maxTriple (t₁ t₂ : ℕ × ℕ × ℕ) : ℕ × ℕ × ℕ :=
  bif maxBool t₁ t₂ then t₁ else t₂

theorem maxTriple_b_ne_zero {t₁ t₂ : ℕ × ℕ × ℕ}
    (hb₁ : t₁.2.1 ≠ 0) (hb₂ : t₂.2.1 ≠ 0) :
    (maxTriple t₁ t₂).2.1 ≠ 0 := by
  unfold maxTriple
  cases maxBool t₁ t₂ with
  | true => simpa using hb₁
  | false => simpa using hb₂

/-- Correctness: the represented rational of `maxTriple t₁ t₂` is the lattice
`⊔` (= max) of the two represented rationals. Stated in `⊔` form so it composes
directly with `Finset.sup'_insert` in `finsetMax_rat`'s fold. The proof is a
4-way parity case-split mirroring `IsComputableSeqRat.max`
(`ComputableSeqReal.lean:493-580`); each branch resolves to a single ℚ-inequality
via `div_le_div_iff₀`. -/
theorem maxTriple_correct {t₁ t₂ : ℕ × ℕ × ℕ}
    (hb₁ : t₁.2.1 ≠ 0) (hb₂ : t₂.2.1 ≠ 0) :
    tripleToRat (maxTriple t₁ t₂) = tripleToRat t₁ ⊔ tripleToRat t₂ := by
  obtain ⟨a₁, b₁, s₁⟩ := t₁
  obtain ⟨a₂, b₂, s₂⟩ := t₂
  simp only at hb₁ hb₂
  have hb₁q : (0 : ℚ) < (b₁ : ℚ) := by exact_mod_cast Nat.pos_of_ne_zero hb₁
  have hb₂q : (0 : ℚ) < (b₂ : ℚ) := by exact_mod_cast Nat.pos_of_ne_zero hb₂
  have pow_red : ∀ n : ℕ, (-1 : ℚ) ^ n = (-1) ^ (n % 2) := fun n => by
    conv_lhs => rw [← Nat.div_add_mod n 2, pow_add, pow_mul]
    simp
  have hr1nn : (0 : ℚ) ≤ (a₁ : ℚ) / (b₁ : ℚ) :=
    div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
  have hr2nn : (0 : ℚ) ≤ (a₂ : ℚ) / (b₂ : ℚ) :=
    div_nonneg (Nat.cast_nonneg _) (Nat.cast_nonneg _)
  -- Parity-reduced value forms.
  have hv1 : tripleToRat (a₁, b₁, s₁) = (-1) ^ (s₁ % 2) * ((a₁ : ℚ) / (b₁ : ℚ)) := by
    simp only [tripleToRat]; rw [pow_red s₁]
  have hv2 : tripleToRat (a₂, b₂, s₂) = (-1) ^ (s₂ % 2) * ((a₂ : ℚ) / (b₂ : ℚ)) := by
    simp only [tripleToRat]; rw [pow_red s₂]
  -- `maxBool` in explicit `bif` form (definitional).
  have hch_eq : maxBool (a₁, b₁, s₁) (a₂, b₂, s₂) =
      (bif decide (s₁ % 2 = s₂ % 2) then
        (bif decide (s₁ % 2 = 0) then decide (a₁ * b₂ ≥ a₂ * b₁)
          else decide (a₁ * b₂ ≤ a₂ * b₁))
        else decide (s₁ % 2 = 0)) := rfl
  rcases Nat.mod_two_eq_zero_or_one s₁ with hp1 | hp1 <;>
    rcases Nat.mod_two_eq_zero_or_one s₂ with hp2 | hp2
  · -- both even: `maxBool ↔ a₁·b₂ ≥ a₂·b₁`.
    by_cases hge : a₁ * b₂ ≥ a₂ * b₁
    · have hb : maxBool (a₁, b₁, s₁) (a₂, b₂, s₂) = true := by
        rw [hch_eq]; simp [hp1, hp2, hge]
      have hle : tripleToRat (a₂, b₂, s₂) ≤ tripleToRat (a₁, b₁, s₁) := by
        rw [hv2, hv1, hp1, hp2]; simp only [pow_zero, one_mul]
        rw [div_le_div_iff₀ hb₂q hb₁q]; exact_mod_cast hge
      simp only [maxTriple, hb, cond_true]; exact (sup_eq_left.mpr hle).symm
    · have hlt : a₁ * b₂ < a₂ * b₁ := lt_of_not_ge hge
      have hb : maxBool (a₁, b₁, s₁) (a₂, b₂, s₂) = false := by
        rw [hch_eq]; simp [hp1, hp2, hge]
      have hle : tripleToRat (a₁, b₁, s₁) ≤ tripleToRat (a₂, b₂, s₂) := by
        rw [hv1, hv2, hp1, hp2]; simp only [pow_zero, one_mul]
        rw [div_le_div_iff₀ hb₁q hb₂q]; exact_mod_cast hlt.le
      simp only [maxTriple, hb, cond_false]; exact (sup_eq_right.mpr hle).symm
  · -- s₁ even, s₂ odd: `t₁ ≥ 0 ≥ t₂`, so `maxBool = true`.
    have hb : maxBool (a₁, b₁, s₁) (a₂, b₂, s₂) = true := by
      rw [hch_eq]; simp [hp1, hp2]
    have hle : tripleToRat (a₂, b₂, s₂) ≤ tripleToRat (a₁, b₁, s₁) := by
      rw [hv2, hv1, hp1, hp2]; simp only [pow_zero, pow_one, one_mul, neg_one_mul]; linarith
    simp only [maxTriple, hb, cond_true]; exact (sup_eq_left.mpr hle).symm
  · -- s₁ odd, s₂ even: `t₁ ≤ 0 ≤ t₂`, so `maxBool = false`.
    have hb : maxBool (a₁, b₁, s₁) (a₂, b₂, s₂) = false := by
      rw [hch_eq]; simp [hp1, hp2]
    have hle : tripleToRat (a₁, b₁, s₁) ≤ tripleToRat (a₂, b₂, s₂) := by
      rw [hv1, hv2, hp1, hp2]; simp only [pow_zero, pow_one, one_mul, neg_one_mul]; linarith
    simp only [maxTriple, hb, cond_false]; exact (sup_eq_right.mpr hle).symm
  · -- both odd: `maxBool ↔ a₁·b₂ ≤ a₂·b₁`.
    by_cases hle_case : a₁ * b₂ ≤ a₂ * b₁
    · have hb : maxBool (a₁, b₁, s₁) (a₂, b₂, s₂) = true := by
        rw [hch_eq]; simp [hp1, hp2, hle_case]
      have hle : tripleToRat (a₂, b₂, s₂) ≤ tripleToRat (a₁, b₁, s₁) := by
        rw [hv2, hv1, hp1, hp2]; simp only [pow_one, neg_one_mul]
        have h' : (a₁ : ℚ) / (b₁ : ℚ) ≤ (a₂ : ℚ) / (b₂ : ℚ) := by
          rw [div_le_div_iff₀ hb₁q hb₂q]; exact_mod_cast hle_case
        linarith
      simp only [maxTriple, hb, cond_true]; exact (sup_eq_left.mpr hle).symm
    · have hlt : a₂ * b₁ < a₁ * b₂ := lt_of_not_ge hle_case
      have hb : maxBool (a₁, b₁, s₁) (a₂, b₂, s₂) = false := by
        rw [hch_eq]; simp [hp1, hp2, hle_case]
      have hle : tripleToRat (a₁, b₁, s₁) ≤ tripleToRat (a₂, b₂, s₂) := by
        rw [hv1, hv2, hp1, hp2]; simp only [pow_one, neg_one_mul]
        have h' : (a₂ : ℚ) / (b₂ : ℚ) ≤ (a₁ : ℚ) / (b₁ : ℚ) := by
          rw [div_le_div_iff₀ hb₂q hb₁q]; exact_mod_cast hlt.le
        linarith
      simp only [maxTriple, hb, cond_false]; exact (sup_eq_right.mpr hle).symm

/-- `maxTriple` is `Computable₂`: the wholesale-selection max is a `Computable.cond`
on the sign-aware `maxBool` discriminator, selecting `Prod.fst`/`Prod.snd`. Mirrors
`FinsetSumHelper.addTriple_computable`'s projection-and-`cond` recipe. -/
theorem maxTriple_computable : Computable₂ maxTriple := by
  show Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => maxTriple t.1 t.2)
  -- Projections.
  have ha₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.1) :=
    Computable.fst.comp Computable.fst
  have hb₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.2.1) :=
    (Computable.fst.comp Computable.snd).comp Computable.fst
  have hs₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.2.2) :=
    (Computable.snd.comp Computable.snd).comp Computable.fst
  have ha₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.1) :=
    Computable.fst.comp Computable.snd
  have hb₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.2.1) :=
    (Computable.fst.comp Computable.snd).comp Computable.snd
  have hs₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.2.2) :=
    (Computable.snd.comp Computable.snd).comp Computable.snd
  -- Cross products `a₁·b₂` and `a₂·b₁`.
  have hp₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.1 * t.2.2.1) :=
    Primrec.nat_mul.to_comp.comp ha₁ hb₂
  have hp₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.1 * t.1.2.1) :=
    Primrec.nat_mul.to_comp.comp ha₂ hb₁
  -- Parities and the two equality Bools.
  have hpar₁ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.1.2.2 % 2) :=
    Primrec.nat_mod.to_comp.comp hs₁ (Computable.const 2)
  have hpar₂ : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => t.2.2.2 % 2) :=
    Primrec.nat_mod.to_comp.comp hs₂ (Computable.const 2)
  have hbeq_par : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      decide (t.1.2.2 % 2 = t.2.2.2 % 2)) :=
    Primrec.beq.to_comp.comp hpar₁ hpar₂
  have hpar1_eq0 : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      decide (t.1.2.2 % 2 = 0)) :=
    Primrec.beq.to_comp.comp hpar₁ (Computable.const 0)
  -- Sign-aware comparison Bools.
  have hge : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      decide (t.1.1 * t.2.2.1 ≥ t.2.1 * t.1.2.1)) := by
    have : Primrec₂ (fun a b : ℕ => decide (a ≥ b)) := Primrec.nat_le.swap.decide
    exact this.to_comp.comp hp₁ hp₂
  have hle : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) =>
      decide (t.1.1 * t.2.2.1 ≤ t.2.1 * t.1.2.1)) := by
    have : Primrec₂ (fun a b : ℕ => decide (a ≤ b)) := Primrec.nat_le.decide
    exact this.to_comp.comp hp₁ hp₂
  -- `maxBool` as a nested `cond`, then select fst/snd via `cond`.
  have h_maxbool : Computable (fun t : (ℕ × ℕ × ℕ) × (ℕ × ℕ × ℕ) => maxBool t.1 t.2) :=
    Computable.cond hbeq_par (Computable.cond hpar1_eq0 hge hle) hpar1_eq0
  exact Computable.cond h_maxbool Computable.fst Computable.snd

/-- Closure of `IsComputableSeqRat` under finite `Finset.sup'` (max) over a
`Computable`-bounded range: for `r : ℕ × ℕ → ℚ` with `IsComputableDoubleSeqRat r`
and `n : ℕ → ℕ` `Computable`, the sequence `fun k => max_{j ≤ n k} r (k, j)` (a
`Finset.sup'` over `range (n k + 1)`) is in `IsComputableSeqRat`. Max-analogue of
`FinsetSumHelper.finsetSum_rat`.

The witness is a `Nat.rec` fold of the `Computable` wholesale-max `maxTriple` over
`j`; correctness routes through `partialSups` (`partialSups_zero` / `partialSups_succ`),
then `partialSups_eq_sup'_range` converts to the stated `sup'` form. -/
theorem finsetMax_rat
    {r : ℕ × ℕ → ℚ} (h : IsComputableDoubleSeqRat r)
    {n : ℕ → ℕ} (hn : Computable n) :
    IsComputableSeqRat (fun k => (Finset.range (n k + 1)).sup'
      Finset.nonempty_range_add_one (fun j => r (k, j))) := by
  obtain ⟨a_r, b_r, s_r, ha_r, hb_r, hs_r, hne_r, heq_r⟩ := h
  -- `maxRec k` = max-accumulated witness triple of `r (k, 0), …, r (k, n k)`.
  let maxRec : ℕ → ℕ × ℕ × ℕ := fun k =>
    Nat.rec (motive := fun _ => ℕ × ℕ × ℕ)
      (a_r (Nat.pair k 0), b_r (Nat.pair k 0), s_r (Nat.pair k 0))
      (fun y IH => maxTriple IH
        (a_r (Nat.pair k (y + 1)), b_r (Nat.pair k (y + 1)), s_r (Nat.pair k (y + 1))))
      (n k)
  have h_maxRec : Computable maxRec := by
    have h_step : Computable₂ (fun (k : ℕ) (yih : ℕ × (ℕ × ℕ × ℕ)) =>
        maxTriple yih.2
          (a_r (Nat.pair k (yih.1 + 1)), b_r (Nat.pair k (yih.1 + 1)),
           s_r (Nat.pair k (yih.1 + 1)))) := by
      show Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) =>
        maxTriple p.2.2 (a_r (Nat.pair p.1 (p.2.1 + 1)),
                         b_r (Nat.pair p.1 (p.2.1 + 1)),
                         s_r (Nat.pair p.1 (p.2.1 + 1))))
      have h_k : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) => p.1) := Computable.fst
      have h_y1 : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) => p.2.1 + 1) :=
        Computable.succ.comp (Computable.fst.comp Computable.snd)
      have h_ih : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) => p.2.2) :=
        Computable.snd.comp Computable.snd
      have h_pair : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) => Nat.pair p.1 (p.2.1 + 1)) :=
        Primrec₂.natPair.to_comp.comp h_k h_y1
      have h_t2 : Computable (fun p : ℕ × (ℕ × ℕ × ℕ × ℕ) =>
          (a_r (Nat.pair p.1 (p.2.1 + 1)),
           b_r (Nat.pair p.1 (p.2.1 + 1)),
           s_r (Nat.pair p.1 (p.2.1 + 1)))) :=
        (ha_r.comp h_pair).pair ((hb_r.comp h_pair).pair (hs_r.comp h_pair))
      exact maxTriple_computable.comp h_ih h_t2
    have h_base : Computable (fun k : ℕ =>
        (a_r (Nat.pair k 0), b_r (Nat.pair k 0), s_r (Nat.pair k 0))) := by
      have h_pair0 : Computable (fun k : ℕ => Nat.pair k 0) :=
        Primrec₂.natPair.to_comp.comp Computable.id (Computable.const 0)
      exact (ha_r.comp h_pair0).pair ((hb_r.comp h_pair0).pair (hs_r.comp h_pair0))
    exact Computable.nat_rec hn h_base h_step
  have witness_val : ∀ k j,
      tripleToRat (a_r (Nat.pair k j), b_r (Nat.pair k j), s_r (Nat.pair k j)) = r (k, j) := by
    intro k j
    have hh := heq_r (Nat.pair k j)
    simp only [Nat.unpair_pair] at hh
    simp only [tripleToRat]
    exact hh.symm
  have rec_aux : ∀ k m,
      (Nat.rec (motive := fun _ => ℕ × ℕ × ℕ)
        (a_r (Nat.pair k 0), b_r (Nat.pair k 0), s_r (Nat.pair k 0))
        (fun y IH => maxTriple IH
          (a_r (Nat.pair k (y + 1)), b_r (Nat.pair k (y + 1)), s_r (Nat.pair k (y + 1))))
        m).2.1 ≠ 0 ∧
      tripleToRat (Nat.rec (motive := fun _ => ℕ × ℕ × ℕ)
        (a_r (Nat.pair k 0), b_r (Nat.pair k 0), s_r (Nat.pair k 0))
        (fun y IH => maxTriple IH
          (a_r (Nat.pair k (y + 1)), b_r (Nat.pair k (y + 1)), s_r (Nat.pair k (y + 1))))
        m) = partialSups (fun j => r (k, j)) m := by
    intro k m
    induction m with
    | zero =>
      exact ⟨hne_r (Nat.pair k 0), by rw [partialSups_zero]; exact witness_val k 0⟩
    | succ m IH =>
      obtain ⟨ih_b, ih_val⟩ := IH
      refine ⟨maxTriple_b_ne_zero ih_b (hne_r (Nat.pair k (m + 1))), ?_⟩
      rw [maxTriple_correct ih_b (hne_r (Nat.pair k (m + 1))), ih_val, witness_val k (m + 1)]
      exact (partialSups_succ (fun j => r (k, j)) m).symm
  have key : IsComputableSeqRat (fun k => partialSups (fun j => r (k, j)) (n k)) := by
    refine ⟨fun k => (maxRec k).1, fun k => (maxRec k).2.1, fun k => (maxRec k).2.2,
      Computable.fst.comp h_maxRec,
      (Computable.fst.comp Computable.snd).comp h_maxRec,
      (Computable.snd.comp Computable.snd).comp h_maxRec,
      ?_, ?_⟩
    · intro k
      exact (rec_aux k (n k)).1
    · intro k
      show partialSups (fun j => r (k, j)) (n k) = tripleToRat (maxRec k)
      exact (rec_aux k (n k)).2.symm
  have heq_form : (fun k => partialSups (fun j => r (k, j)) (n k))
      = (fun k => (Finset.range (n k + 1)).sup' Finset.nonempty_range_add_one
          (fun j => r (k, j))) := by
    funext k
    exact partialSups_eq_sup'_range (fun j => r (k, j)) (n k)
  rwa [heq_form] at key

end FinsetMaxHelper

/-! ## §0c — Polynomial-evaluation closure helpers for A3 (TODO refactor → L1)

Closure lemmas for evaluating a polynomial with `IsComputableSeqRat` coefficients
at a `IsComputableSeqRat` rational point. The endpoint is
`polyEvalRat_isComputableDoubleSeqRat`: combining `IsComputableSeqRat`-power,
flat triple-indexed coefficients, and `finsetSum_rat`, the rational value
`(p, k) ↦ Σⱼ a(p, j) · q(p)^j` (`j ∈ range(d(p)+1)`) is `IsComputableDoubleSeqRat`.

Needed by A3 for the partial-max approximant `sNK`: each grid point produces a
rational polynomial evaluation, and the partial max ② is taken over them. -/

namespace PolyEvalHelper

/-- Power closure of `IsComputableSeqRat` with varying exponent: given
`IsComputableSeqRat q`, the doubly-indexed sequence `(k, j) ↦ q k ^ j` is
`IsComputableDoubleSeqRat`. The witness lifts `q`'s triple `(a, b, s)` via
`(a^j, b^j, s·j)` — the rational `(-1)^s · (a/b)` rule extends to powers because
`mul_pow + div_pow + ← pow_mul` distributes the exponent. The `Nat`-level
power `a^j` is `Computable` via `Primrec₂.unpaired'.1 Nat.Primrec.pow`
(there is no top-level `Primrec.nat_pow`; cf. `docs/PITFALLS.md §1`). -/
theorem pow_isComputableDoubleSeqRat
    {q : ℕ → ℚ} (hq : IsComputableSeqRat q) :
    IsComputableDoubleSeqRat (fun pj => q pj.1 ^ pj.2) := by
  obtain ⟨a, b, s, ha, hb, hs, hne, heq⟩ := hq
  change IsComputableSeqRat
    (fun m => q (Nat.unpair m).1 ^ (Nat.unpair m).2)
  have h_fst : Computable (fun m : ℕ => (Nat.unpair m).1) :=
    Computable.fst.comp Computable.unpair
  have h_snd : Computable (fun m : ℕ => (Nat.unpair m).2) :=
    Computable.snd.comp Computable.unpair
  have hpow : Primrec₂ ((· ^ ·) : ℕ → ℕ → ℕ) := Primrec₂.unpaired'.1 Nat.Primrec.pow
  refine ⟨
    fun m => a (Nat.unpair m).1 ^ (Nat.unpair m).2,
    fun m => b (Nat.unpair m).1 ^ (Nat.unpair m).2,
    fun m => s (Nat.unpair m).1 * (Nat.unpair m).2,
    hpow.to_comp.comp (ha.comp h_fst) h_snd,
    hpow.to_comp.comp (hb.comp h_fst) h_snd,
    Primrec.nat_mul.to_comp.comp (hs.comp h_fst) h_snd,
    fun _ => pow_ne_zero _ (hne _), fun m => ?_⟩
  show q (Nat.unpair m).1 ^ (Nat.unpair m).2 =
      (-1 : ℚ) ^ (s (Nat.unpair m).1 * (Nat.unpair m).2) *
        ((a (Nat.unpair m).1 ^ (Nat.unpair m).2 : ℕ) /
         (b (Nat.unpair m).1 ^ (Nat.unpair m).2 : ℕ) : ℚ)
  rw [heq (Nat.unpair m).1, mul_pow, ← pow_mul, div_pow]
  push_cast
  ring

/-- Closure of `IsComputableSeqRat` under "polynomial value at a varying point":
given a triple-indexed coefficient family `a : ℕ × ℕ × ℕ → ℚ` (with flat
`IsComputableSeqRat`), a `Computable` degree bound `d : ℕ × ℕ → ℕ`, `Computable`
indexers `n_idx, K_idx : ℕ → ℕ`, and an `IsComputableSeqRat` evaluation point
`q : ℕ → ℚ`, the sequence
`p ↦ Σⱼ a(n_idx p, K_idx p, j) · (q p)^j`  (`j ∈ range(d(n_idx p, K_idx p) + 1)`)
is `IsComputableSeqRat`. The core A3 step ③ helper: combining
`pow_isComputableDoubleSeqRat`, a triple-reindex of the coefficient family,
`IsComputableSeqRat.mul`, and `FinsetSumHelper.finsetSum_rat`. -/
theorem polyVal_isComputableSeqRat
    {a : ℕ × ℕ × ℕ → ℚ}
    (ha : IsComputableSeqRat (fun m =>
      a ((Nat.unpair m).1, (Nat.unpair (Nat.unpair m).2).1,
         (Nat.unpair (Nat.unpair m).2).2)))
    {d : ℕ × ℕ → ℕ} (hd : Computable d)
    {n_idx K_idx : ℕ → ℕ} (hn : Computable n_idx) (hK : Computable K_idx)
    {q : ℕ → ℚ} (hq : IsComputableSeqRat q) :
    IsComputableSeqRat (fun p => ∑ j ∈ Finset.range (d (n_idx p, K_idx p) + 1),
        a (n_idx p, K_idx p, j) * (q p) ^ j) := by
  -- `r (p, j) := a (n_idx p, K_idx p, j) * (q p) ^ j`. Goal reduces via
  -- `finsetSum_rat` to `IsComputableDoubleSeqRat r` + `Computable bound`.
  set r : ℕ × ℕ → ℚ := fun pj =>
    a (n_idx pj.1, K_idx pj.1, pj.2) * (q pj.1) ^ pj.2 with hr_def
  set bound : ℕ → ℕ := fun p => d (n_idx p, K_idx p) with hbnd_def
  have hbnd : Computable bound := hd.comp (hn.pair hK)
  -- `IsComputableDoubleSeqRat r`: factor `r = r₁ · r₂` (componentwise on flat),
  -- where `r₁ (p, j) := a (n_idx p, K_idx p, j)` and `r₂ (p, j) := (q p)^j`.
  have hr : IsComputableDoubleSeqRat r := by
    have hr2 : IsComputableDoubleSeqRat (fun pj : ℕ × ℕ => q pj.1 ^ pj.2) :=
      pow_isComputableDoubleSeqRat hq
    -- `r₁` via reindex of `a`-flat.
    have hr1 : IsComputableDoubleSeqRat
        (fun pj : ℕ × ℕ => a (n_idx pj.1, K_idx pj.1, pj.2)) := by
      change IsComputableSeqRat
        (fun m => a (n_idx (Nat.unpair m).1, K_idx (Nat.unpair m).1, (Nat.unpair m).2))
      have h_fst : Computable (fun m : ℕ => (Nat.unpair m).1) :=
        Computable.fst.comp Computable.unpair
      have h_snd : Computable (fun m : ℕ => (Nat.unpair m).2) :=
        Computable.snd.comp Computable.unpair
      have h_n : Computable (fun m : ℕ => n_idx (Nat.unpair m).1) := hn.comp h_fst
      have h_K : Computable (fun m : ℕ => K_idx (Nat.unpair m).1) := hK.comp h_fst
      have h_Kj : Computable (fun m : ℕ =>
          Nat.pair (K_idx (Nat.unpair m).1) (Nat.unpair m).2) :=
        Primrec₂.natPair.to_comp.comp h_K h_snd
      have hσ : Computable (fun m : ℕ =>
          Nat.pair (n_idx (Nat.unpair m).1)
            (Nat.pair (K_idx (Nat.unpair m).1) (Nat.unpair m).2)) :=
        Primrec₂.natPair.to_comp.comp h_n h_Kj
      have key : IsComputableSeqRat (fun m =>
          a ((Nat.unpair (Nat.pair (n_idx (Nat.unpair m).1)
                          (Nat.pair (K_idx (Nat.unpair m).1) (Nat.unpair m).2))).1,
             (Nat.unpair (Nat.unpair (Nat.pair (n_idx (Nat.unpair m).1)
                          (Nat.pair (K_idx (Nat.unpair m).1) (Nat.unpair m).2))).2).1,
             (Nat.unpair (Nat.unpair (Nat.pair (n_idx (Nat.unpair m).1)
                          (Nat.pair (K_idx (Nat.unpair m).1) (Nat.unpair m).2))).2).2)) :=
        ha.comp hσ
      convert key using 1
      funext m
      simp [Nat.unpair_pair]
    -- Pointwise product on `ℕ × ℕ → ℚ` via flat `IsComputableSeqRat.mul`.
    show IsComputableSeqRat (fun m => r (Nat.unpair m))
    have hmul : IsComputableSeqRat
        ((fun m => a (n_idx (Nat.unpair m).1, K_idx (Nat.unpair m).1, (Nat.unpair m).2))
         * (fun m => q (Nat.unpair m).1 ^ (Nat.unpair m).2)) :=
      IsComputableSeqRat.mul hr1 hr2
    convert hmul using 1
  -- Apply finsetSum_rat with `r` and `bound`.
  have key := FinsetSumHelper.finsetSum_rat (r := r) hr hbnd
  -- Match the target: pointwise-equal by `r`'s definition (`rfl` after `convert`).
  convert key using 1

/-- Grid-points sequence: given `IsComputableDoubleSeqRat` rational approximants
`αR, βR` of `α, β`, a `Computable` precision selector `m : ℕ × ℕ → ℕ`, and a
`Computable` nonzero grid count `k : ℕ × ℕ → ℕ`, the rational grid
`αR(0, m(n,N)) + (J/k(n,N)) · (βR(0, m(n,N)) − αR(0, m(n,N)))`
viewed as a function of the flat index `p ↔ (n, N, J)` via
`Nat.pair n (Nat.pair N J)` is `IsComputableSeqRat`.

Built stepwise via the L1 closure API: `comp` to reindex `αR, βR`, `sub` for
`βR − αR`, direct witness `(J, k, 0)` for `(J : ℚ)/(k : ℚ)`, `mul` to combine,
`add` for the final sum. A3 step ① helper. -/
theorem gridQ_isComputableSeqRat
    {αR βR : ℕ × ℕ → ℚ}
    (hαR : IsComputableDoubleSeqRat αR) (hβR : IsComputableDoubleSeqRat βR)
    {m k : ℕ × ℕ → ℕ} (hm : Computable m) (hk : Computable k)
    (hk_pos : ∀ p, k p ≠ 0) :
    IsComputableSeqRat (fun p : ℕ =>
      αR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)) +
      (((Nat.unpair (Nat.unpair p).2).2 : ℚ) /
        (k ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1) : ℚ)) *
      (βR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)) -
       αR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)))) := by
  -- Computable projectors out of the flat index `p ↔ (n, N, J)`.
  have h_n : Computable (fun p : ℕ => (Nat.unpair p).1) :=
    Computable.fst.comp Computable.unpair
  have h_NJ : Computable (fun p : ℕ => (Nat.unpair p).2) :=
    Computable.snd.comp Computable.unpair
  have h_N : Computable (fun p : ℕ => (Nat.unpair (Nat.unpair p).2).1) :=
    Computable.fst.comp (Computable.unpair.comp h_NJ)
  have h_J : Computable (fun p : ℕ => (Nat.unpair (Nat.unpair p).2).2) :=
    Computable.snd.comp (Computable.unpair.comp h_NJ)
  have h_nN : Computable (fun p : ℕ => ((Nat.unpair p).1,
      (Nat.unpair (Nat.unpair p).2).1)) := h_n.pair h_N
  have h_k_nN : Computable (fun p : ℕ =>
      k ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)) := hk.comp h_nN
  have h_m_nN : Computable (fun p : ℕ =>
      m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)) := hm.comp h_nN
  -- σ : reindex onto αR-flat to extract `αR(0, m(n_p, N_p))`.
  have h_σ : Computable (fun p : ℕ => Nat.pair 0 (m ((Nat.unpair p).1,
      (Nat.unpair (Nat.unpair p).2).1))) :=
    Primrec₂.natPair.to_comp.comp (Computable.const 0) h_m_nN
  -- αR_seq, βR_seq via comp on the flat forms.
  have hαR_seq : IsComputableSeqRat (fun p : ℕ =>
      αR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1))) := by
    have hflat : IsComputableSeqRat (fun q : ℕ => αR (Nat.unpair q)) := hαR
    have key : IsComputableSeqRat
      ((fun q : ℕ => αR (Nat.unpair q)) ∘
        (fun p : ℕ => Nat.pair 0
          (m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)))) :=
      IsComputableSeqRat.comp hflat h_σ
    convert key using 1
    funext p
    simp [Function.comp, Nat.unpair_pair]
  have hβR_seq : IsComputableSeqRat (fun p : ℕ =>
      βR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1))) := by
    have hflat : IsComputableSeqRat (fun q : ℕ => βR (Nat.unpair q)) := hβR
    have key : IsComputableSeqRat
      ((fun q : ℕ => βR (Nat.unpair q)) ∘
        (fun p : ℕ => Nat.pair 0
          (m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)))) :=
      IsComputableSeqRat.comp hflat h_σ
    convert key using 1
    funext p
    simp [Function.comp, Nat.unpair_pair]
  -- Difference βR − αR (uses L1 `sub`).
  have hdiff_seq : IsComputableSeqRat (fun p : ℕ =>
      βR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)) -
      αR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1))) :=
    IsComputableSeqRat.sub hβR_seq hαR_seq
  -- (J : ℚ) / (k(n, N) : ℚ) via direct witness.
  have hfrac_seq : IsComputableSeqRat (fun p : ℕ =>
      ((Nat.unpair (Nat.unpair p).2).2 : ℚ) /
      (k ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1) : ℚ)) := by
    refine ⟨fun p => (Nat.unpair (Nat.unpair p).2).2,
      fun p => k ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1),
      fun _ => 0,
      h_J, h_k_nN, Computable.const 0,
      fun p => hk_pos _, fun p => ?_⟩
    show ((Nat.unpair (Nat.unpair p).2).2 : ℚ) /
        (k ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1) : ℚ)
      = (-1 : ℚ)^0 * (((Nat.unpair (Nat.unpair p).2).2 : ℕ) /
          (k ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1) : ℕ) : ℚ)
    ring
  -- (J/k) · (βR − αR).
  have hscaled_seq : IsComputableSeqRat (fun p : ℕ =>
      (((Nat.unpair (Nat.unpair p).2).2 : ℚ) /
        (k ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1) : ℚ)) *
      (βR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)) -
       αR (0, m ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)))) :=
    IsComputableSeqRat.mul hfrac_seq hdiff_seq
  -- αR + (J/k)·(βR − αR).
  exact IsComputableSeqRat.add hαR_seq hscaled_seq

end PolyEvalHelper

/-! ## §0b — Pure arithmetic helpers for the A1 norm bound

These lemmas are recursion, Finset, and cast arithmetic facts used by the
`isComputableSeq_linearCombination` (A1) norm-bound proof.
They are fully general (no dependence on `α, β, B`) and could be upstreamed. -/

/-- Lower bound for the `max`-accumulating `Nat.rec`: every `g k` with `k < N`
is `≤` the accumulated maximum `Nat.rec 0 (fun j acc => max acc (g j)) N`. Used
to show the degree bound `dS` and coefficient bound `bound_max` dominate their
per-`k` constituents (`k ≤ d n`). -/
theorem le_natRec_max (g : ℕ → ℕ) (k : ℕ) :
    ∀ N, k < N → g k ≤ Nat.rec (motive := fun _ => ℕ) 0 (fun j acc => max acc (g j)) N := by
  intro N
  induction N with
  | zero => intro hk; exact absurd hk (Nat.not_lt_zero k)
  | succ N ih =>
    intro hk
    rcases (Nat.lt_succ_iff.mp hk).lt_or_eq with h | h
    · exact le_trans (ih h) (le_max_left _ _)
    · subst h; exact le_max_right _ _

/-- Closed form for the additive `Nat.rec`: `Nat.rec c (fun j acc => acc + g j) N`
unfolds to `c + Σ_{j < N} g j`. Used to expose `bound_x_k`/`bound_y_k` as
`1 + Σ_j bound_a·B^j` for the polynomial-norm bound. -/
theorem natRec_add_eq_sum (c : ℕ) (g : ℕ → ℕ) :
    ∀ N, Nat.rec (motive := fun _ => ℕ) c (fun j acc => acc + g j) N
        = c + ∑ j ∈ Finset.range N, g j := by
  intro N
  induction N with
  | zero => simp
  | succ N ih =>
    show Nat.rec (motive := fun _ => ℕ) c (fun j acc => acc + g j) N + g N
        = c + ∑ j ∈ Finset.range (N + 1), g j
    rw [ih, Finset.sum_range_succ]; ring

/-- The real absolute value of a triple-represented rational `(-1)^s · (a / b)`
(`a, b, s : ℕ`, `b ≠ 0`) is bounded by its numerator `a`. This is the bridge
from L1's recursion-theoretic witness data to the ℝ-level coefficient bounds. -/
theorem abs_cast_neg_one_pow_div_le (a b s : ℕ) (hb : b ≠ 0) :
    |(((-1 : ℚ) ^ s * ((a : ℚ) / (b : ℚ))) : ℝ)| ≤ (a : ℝ) := by
  have hb1 : (1 : ℝ) ≤ (b : ℝ) := by exact_mod_cast Nat.one_le_iff_ne_zero.mpr hb
  have ha0 : (0 : ℝ) ≤ (a : ℝ) := Nat.cast_nonneg a
  have key : |(((-1 : ℚ) ^ s * ((a : ℚ) / (b : ℚ))) : ℝ)| = (a : ℝ) / (b : ℝ) := by
    push_cast
    rw [abs_mul, show |(-1 : ℝ) ^ s| = 1 by rw [abs_pow]; norm_num, one_mul,
       abs_div, abs_of_nonneg ha0, abs_of_nonneg (Nat.cast_nonneg b)]
  rw [key]
  exact div_le_self ha0 hb1

/-- Padding a coefficient sequence with zeros above degree `dk` does not change
the polynomial value: extending the summation range from `dk + 1` up to `D + 1`
(with `dk ≤ D`) and masking the extra coefficients to `0` is the identity. Used
to align the per-`k` approximants (each of degree `dX (k, ·)`) onto the common
degree bound `D = dS (n, m)` in the convolution expansion. -/
theorem padcoeff_sum (a : ℕ → ℝ) (dk D : ℕ) (hle : dk ≤ D) (w : ℝ) :
    (∑ j ∈ Finset.range (D + 1), (bif decide (j ≤ dk) then a j else 0) * w ^ j)
    = ∑ j ∈ Finset.range (dk + 1), a j * w ^ j := by
  have hsub : Finset.range (dk + 1) ⊆ Finset.range (D + 1) := by
    intro x hx; rw [Finset.mem_range] at hx ⊢; omega
  rw [(Finset.sum_subset hsub (by
        intro j hjD hjnk
        rw [Finset.mem_range] at hjD hjnk
        rw [show decide (j ≤ dk) = false from decide_eq_false (by omega), cond_false,
            zero_mul])).symm]
  apply Finset.sum_congr rfl
  intro j hj
  rw [Finset.mem_range] at hj
  rw [show decide (j ≤ dk) = true from decide_eq_true (by omega), cond_true]

/-- Per-`k` summand bound: if `xkw` is `ε`-close to `pxkw`, the rational
coefficient `αr` is `ε`-close to the real coefficient `cα`, and `|cα| ≤ Ca`,
`|pxkw| ≤ Px`, then `|cα·xkw − αr·pxkw| ≤ ε·(Ca + Px)`. The algebraic core of
the linearity norm bound: splits the mixed product via
`cα·xkw − αr·pxkw = cα·(xkw − pxkw) + (cα − αr)·pxkw`. -/
theorem perk_bound (cα xkw αr pxkw ε Ca Px : ℝ)
    (hε : 0 ≤ ε) (hCa : 0 ≤ Ca)
    (h1 : |xkw - pxkw| ≤ ε) (h2 : |αr - cα| ≤ ε) (h3 : |cα| ≤ Ca) (h4 : |pxkw| ≤ Px) :
    |cα * xkw - αr * pxkw| ≤ ε * (Ca + Px) := by
  have p1 : |cα| * |xkw - pxkw| ≤ Ca * ε := mul_le_mul h3 h1 (abs_nonneg _) hCa
  have p2 : |cα - αr| * |pxkw| ≤ ε * Px := by
    have h2' : |cα - αr| ≤ ε := by rw [abs_sub_comm]; exact h2
    exact mul_le_mul h2' h4 (abs_nonneg _) hε
  calc |cα * xkw - αr * pxkw|
      = |cα * (xkw - pxkw) + (cα - αr) * pxkw| := by ring_nf
    _ ≤ |cα * (xkw - pxkw)| + |(cα - αr) * pxkw| := abs_add_le _ _
    _ = |cα| * |xkw - pxkw| + |cα - αr| * |pxkw| := by rw [abs_mul, abs_mul]
    _ ≤ Ca * ε + ε * Px := by linarith [p1, p2]
    _ = ε * (Ca + Px) := by ring

/-- Close-out ℕ inequality: `(D + 1) · Bm · 2^m ≤ 2^(m + (D + 1) + Bm + 2)`.
The summation produces `(d n + 1)` copies of a per-`k` bound `Bm`, each scaled by
`2^m` (the `M`-precision factor); the precision `M` is chosen with enough
headroom (`m + (D+1) + Bm + 2`) that the resulting `2^{-M}` defeats the
`(D+1)·Bm` prefactor down to `2^{-m}`. -/
theorem closeout_nat (D Bm m : ℕ) : (D + 1) * Bm * 2 ^ m ≤ 2 ^ (m + (D + 1) + Bm + 2) := by
  have hD : D + 1 ≤ 2 ^ (D + 1) := Nat.lt_two_pow_self.le
  have hB : Bm ≤ 2 ^ Bm := Nat.lt_two_pow_self.le
  calc (D + 1) * Bm * 2 ^ m
      ≤ 2 ^ (D + 1) * 2 ^ Bm * 2 ^ m := Nat.mul_le_mul (Nat.mul_le_mul hD hB) (le_refl _)
    _ = 2 ^ (m + (D + 1) + Bm) := by rw [← pow_add, ← pow_add]; congr 1; omega
    _ ≤ 2 ^ (m + (D + 1) + Bm + 2) := Nat.pow_le_pow_right (by norm_num) (by omega)

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

/-- Pointwise evaluation of `polyApproxCMap`: it is the polynomial sum at `w.val`.
Holds by `rfl` (it is the definitional body of the underlying function). -/
theorem polyApproxCMap_eval (a : ℕ × ℕ × ℕ → ℚ) (d : ℕ × ℕ → ℕ) (n k : ℕ) (w : Set.Icc α β) :
    (polyApproxCMap (α := α) (β := β) a d n k) w
      = ∑ j ∈ Finset.range (d (n, k) + 1), (a (n, k, j) : ℝ) * w.val ^ j := rfl

/-- The convolution-coefficient polynomial (the one `aS` produces) evaluated at `w`
equals the linear combination `Σ_k (αR·p_X + βR·p_Y)(w)` of the per-`k` approximants.
This is the algebraic heart of the linearity construction: it re-associates the
"flattened" degree-`Db` polynomial with coefficients
`Σ_k (αR · padX + βR · padY)` back into the sum over `k` of the original approximants,
using `padcoeff_sum` to undo the zero-padding onto the common degree `Db`. -/
theorem polyApproxCMap_conv_eval
    (aX aY : ℕ × ℕ × ℕ → ℚ) (dX dY : ℕ × ℕ → ℕ) (αR βR : ℕ × ℕ → ℚ)
    (n N dn Db : ℕ)
    (hge : ∀ k, k ≤ dn → dX (k, N) ≤ Db ∧ dY (k, N) ≤ Db)
    (w : Set.Icc α β) :
    (∑ j ∈ Finset.range (Db + 1),
        (((∑ k ∈ Finset.range (dn + 1),
            (αR (Nat.pair n k, N) * (bif decide (j ≤ dX (k, N)) then aX (k, N, j) else 0)
             + βR (Nat.pair n k, N)
               * (bif decide (j ≤ dY (k, N)) then aY (k, N, j) else 0))) : ℚ) : ℝ)
          * w.val ^ j)
      = ∑ k ∈ Finset.range (dn + 1),
          ((αR (Nat.pair n k, N) : ℝ) * (polyApproxCMap (α := α) (β := β) aX dX k N) w
           + (βR (Nat.pair n k, N) : ℝ) * (polyApproxCMap (α := α) (β := β) aY dY k N) w) := by
  have cast_padX : ∀ k j, ((bif decide (j ≤ dX (k, N)) then aX (k, N, j) else 0 : ℚ) : ℝ)
      = bif decide (j ≤ dX (k, N)) then (aX (k, N, j) : ℝ) else 0 := by
    intro k j; cases decide (j ≤ dX (k, N)) <;> simp
  have cast_padY : ∀ k j, ((bif decide (j ≤ dY (k, N)) then aY (k, N, j) else 0 : ℚ) : ℝ)
      = bif decide (j ≤ dY (k, N)) then (aY (k, N, j) : ℝ) else 0 := by
    intro k j; cases decide (j ≤ dY (k, N)) <;> simp
  calc (∑ j ∈ Finset.range (Db + 1),
          (((∑ k ∈ Finset.range (dn + 1),
              (αR (Nat.pair n k, N) * (bif decide (j ≤ dX (k, N)) then aX (k, N, j) else 0)
               + βR (Nat.pair n k, N)
                 * (bif decide (j ≤ dY (k, N)) then aY (k, N, j) else 0))) : ℚ) : ℝ)
            * w.val ^ j)
      = ∑ j ∈ Finset.range (Db + 1), ∑ k ∈ Finset.range (dn + 1),
          ((αR (Nat.pair n k, N) : ℝ) * (bif decide (j ≤ dX (k, N)) then (aX (k, N, j) : ℝ) else 0)
           + (βR (Nat.pair n k, N) : ℝ)
             * (bif decide (j ≤ dY (k, N)) then (aY (k, N, j) : ℝ) else 0))
          * w.val ^ j := by
        apply Finset.sum_congr rfl; intro j _
        rw [Rat.cast_sum, Finset.sum_mul]
        apply Finset.sum_congr rfl; intro k _
        rw [Rat.cast_add, Rat.cast_mul, Rat.cast_mul, cast_padX, cast_padY]
    _ = ∑ k ∈ Finset.range (dn + 1), ∑ j ∈ Finset.range (Db + 1),
          ((αR (Nat.pair n k, N) : ℝ) * (bif decide (j ≤ dX (k, N)) then (aX (k, N, j) : ℝ) else 0)
           + (βR (Nat.pair n k, N) : ℝ)
             * (bif decide (j ≤ dY (k, N)) then (aY (k, N, j) : ℝ) else 0))
          * w.val ^ j := Finset.sum_comm
    _ = ∑ k ∈ Finset.range (dn + 1),
          ((αR (Nat.pair n k, N) : ℝ) * (polyApproxCMap (α := α) (β := β) aX dX k N) w
           + (βR (Nat.pair n k, N) : ℝ) * (polyApproxCMap (α := α) (β := β) aY dY k N) w) := by
        apply Finset.sum_congr rfl; intro k hk
        rw [Finset.mem_range] at hk
        rw [polyApproxCMap_eval, polyApproxCMap_eval,
            ← padcoeff_sum (fun j => (aX (k, N, j) : ℝ)) (dX (k, N)) Db (hge k (by omega)).1 w.val,
            ← padcoeff_sum (fun j => (aY (k, N, j) : ℝ)) (dY (k, N)) Db (hge k (by omega)).2 w.val,
            Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib]
        apply Finset.sum_congr rfl; intro j _
        ring

/-- Uniform-norm bound for a polynomial approximant from per-coefficient bounds
and an interval radius `B ≥ max(|α|, |β|)`: if `|a (k, N, j)| ≤ C j` for all `j`
(with `C j ≥ 0`), then `‖p_{k, N}‖_∞ ≤ Σ_{j ≤ d(k, N)} C j · B^j`. The triangle
inequality over the monomials, with `|x| ≤ B` for `x ∈ [α, β]`. Used to bound
`‖polyApproxCMap aX dX k 0‖` by the `Nat`-valued `bound_x_k k` in the linearity
norm argument. -/
theorem polyApproxCMap_norm_le_sum
    (a : ℕ × ℕ × ℕ → ℚ) (d : ℕ × ℕ → ℕ) (k N B : ℕ)
    (hαB : |α| ≤ (B : ℝ)) (hβB : |β| ≤ (B : ℝ))
    (C : ℕ → ℝ) (hCnn : ∀ j, 0 ≤ C j) (hC : ∀ j, |(a (k, N, j) : ℝ)| ≤ C j) :
    ‖polyApproxCMap (α := α) (β := β) a d k N‖
      ≤ ∑ j ∈ Finset.range (d (k, N) + 1), C j * (B : ℝ) ^ j := by
  have hSnn : (0 : ℝ) ≤ ∑ j ∈ Finset.range (d (k, N) + 1), C j * (B : ℝ) ^ j :=
    Finset.sum_nonneg (fun j _ => mul_nonneg (hCnn j) (by positivity))
  rw [ContinuousMap.norm_le _ hSnn]
  intro v
  rw [Real.norm_eq_abs, polyApproxCMap_eval]
  have hvB : |v.val| ≤ (B : ℝ) := by
    have hv := v.2
    rw [Set.mem_Icc] at hv
    rw [abs_le]
    exact ⟨by linarith [(abs_le.mp hαB).1, hv.1], by linarith [(abs_le.mp hβB).2, hv.2]⟩
  calc |∑ j ∈ Finset.range (d (k, N) + 1), (a (k, N, j) : ℝ) * v.val ^ j|
      ≤ ∑ j ∈ Finset.range (d (k, N) + 1), |(a (k, N, j) : ℝ) * v.val ^ j| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ j ∈ Finset.range (d (k, N) + 1), C j * (B : ℝ) ^ j := by
        apply Finset.sum_le_sum
        intro j _
        rw [abs_mul]
        exact mul_le_mul (hC j)
          (by rw [abs_pow]; exact pow_le_pow_left₀ (abs_nonneg _) hvB j)
          (abs_nonneg _) (hCnn j)

/-- **Pointwise Lipschitz bound for `polyApproxCMap`.** For any two points
`x, y ∈ [α, β]` with `max(|α|, |β|) ≤ B`,
`|pₙₖ(x) − pₙₖ(y)| ≤ (Σⱼ j · |a(n,k,j)| · B^(j−1)) · |x − y|`.

This is A3 outline step ③ (effective uniform continuity of `pₙₖ`). The bound
factors via `Mathlib.Algebra.Order.Ring.Abs.abs_pow_sub_pow_le`:
`|xʲ − yʲ| ≤ |x − y| · j · max(|x|, |y|)^(j−1)`, then dominates
`max(|x|, |y|)^(j−1) ≤ B^(j−1)` and sums by the triangle inequality.

P-R `chapt0:1003-1009` uses the same closed-form Lipschitz bound to derive
the effective-uniform-continuity modulus needed for Theorem 7's grid argument. -/
theorem polyApproxCMap_lipschitz
    (a : ℕ × ℕ × ℕ → ℚ) (d : ℕ × ℕ → ℕ) (n k B : ℕ)
    (hαB : |α| ≤ (B : ℝ)) (hβB : |β| ≤ (B : ℝ)) (x y : Set.Icc α β) :
    |(polyApproxCMap (α := α) (β := β) a d n k) x
        - (polyApproxCMap (α := α) (β := β) a d n k) y|
      ≤ (∑ j ∈ Finset.range (d (n, k) + 1),
          (j : ℝ) * |(a (n, k, j) : ℝ)| * (B : ℝ) ^ (j - 1))
        * |x.val - y.val| := by
  have hxB : |x.val| ≤ (B : ℝ) := by
    have hx := x.2
    rw [Set.mem_Icc] at hx
    rw [abs_le]
    exact ⟨by linarith [(abs_le.mp hαB).1, hx.1], by linarith [(abs_le.mp hβB).2, hx.2]⟩
  have hyB : |y.val| ≤ (B : ℝ) := by
    have hy := y.2
    rw [Set.mem_Icc] at hy
    rw [abs_le]
    exact ⟨by linarith [(abs_le.mp hαB).1, hy.1], by linarith [(abs_le.mp hβB).2, hy.2]⟩
  have hmaxB : max |x.val| |y.val| ≤ (B : ℝ) := max_le hxB hyB
  have hmaxNN : (0 : ℝ) ≤ max |x.val| |y.val| := le_max_of_le_left (abs_nonneg _)
  rw [polyApproxCMap_eval, polyApproxCMap_eval, ← Finset.sum_sub_distrib]
  calc |∑ j ∈ Finset.range (d (n, k) + 1),
          ((a (n, k, j) : ℝ) * x.val ^ j - (a (n, k, j) : ℝ) * y.val ^ j)|
      = |∑ j ∈ Finset.range (d (n, k) + 1),
          (a (n, k, j) : ℝ) * (x.val ^ j - y.val ^ j)| := by
        congr 1
        apply Finset.sum_congr rfl
        intro j _
        ring
    _ ≤ ∑ j ∈ Finset.range (d (n, k) + 1),
          |(a (n, k, j) : ℝ) * (x.val ^ j - y.val ^ j)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ j ∈ Finset.range (d (n, k) + 1),
          (j : ℝ) * |(a (n, k, j) : ℝ)| * (B : ℝ) ^ (j - 1) * |x.val - y.val| := by
        apply Finset.sum_le_sum
        intro j _
        rw [abs_mul]
        have hpow : |x.val ^ j - y.val ^ j|
            ≤ |x.val - y.val| * j * max |x.val| |y.val| ^ (j - 1) :=
          abs_pow_sub_pow_le x.val y.val j
        have hpowB : max |x.val| |y.val| ^ (j - 1) ≤ (B : ℝ) ^ (j - 1) :=
          pow_le_pow_left₀ hmaxNN hmaxB (j - 1)
        have hjnn : (0 : ℝ) ≤ |x.val - y.val| * j :=
          mul_nonneg (abs_nonneg _) (Nat.cast_nonneg _)
        have h1 : |x.val ^ j - y.val ^ j| ≤ |x.val - y.val| * j * (B : ℝ) ^ (j - 1) :=
          hpow.trans (mul_le_mul_of_nonneg_left hpowB hjnn)
        calc |(a (n, k, j) : ℝ)| * |x.val ^ j - y.val ^ j|
            ≤ |(a (n, k, j) : ℝ)| * (|x.val - y.val| * j * (B : ℝ) ^ (j - 1)) :=
              mul_le_mul_of_nonneg_left h1 (abs_nonneg _)
          _ = (j : ℝ) * |(a (n, k, j) : ℝ)| * (B : ℝ) ^ (j - 1) * |x.val - y.val| := by ring
    _ = (∑ j ∈ Finset.range (d (n, k) + 1),
          (j : ℝ) * |(a (n, k, j) : ℝ)| * (B : ℝ) ^ (j - 1)) * |x.val - y.val| := by
        rw [Finset.sum_mul]

/-- **Real-line Lipschitz bound for polynomial expressions.** Variant of
`polyApproxCMap_lipschitz` that takes raw real points `x, y : ℝ` with explicit
absolute-value bound `C` (rather than `Set.Icc α β`-typed points). Used in A3
(see iter-09's three-error bound) at grid points `xQ_J : ℝ` that may lie
slightly outside `[α, β]` — there we take `C := B + 1` to cover both the
interval `[α, β]` (where `|·| ≤ B`) and grid points in
`[α − 2⁻ᵐ, β + 2⁻ᵐ] ⊆ [-(B+1), B+1]`.

The proof is structurally identical to `polyApproxCMap_lipschitz` minus the
`Set.Icc α β` unpacking — both factor via `Algebra.Order.Ring.Abs.abs_pow_sub_pow_le`. -/
theorem polyEval_lipschitz_real
    (a : ℕ × ℕ × ℕ → ℚ) (d : ℕ × ℕ → ℕ) (n k C : ℕ)
    (x y : ℝ) (hxC : |x| ≤ (C : ℝ)) (hyC : |y| ≤ (C : ℝ)) :
    |(∑ j ∈ Finset.range (d (n, k) + 1), (a (n, k, j) : ℝ) * x ^ j)
        - (∑ j ∈ Finset.range (d (n, k) + 1), (a (n, k, j) : ℝ) * y ^ j)|
      ≤ (∑ j ∈ Finset.range (d (n, k) + 1),
          (j : ℝ) * |(a (n, k, j) : ℝ)| * (C : ℝ) ^ (j - 1))
        * |x - y| := by
  have hmaxC : max |x| |y| ≤ (C : ℝ) := max_le hxC hyC
  have hmaxNN : (0 : ℝ) ≤ max |x| |y| := le_max_of_le_left (abs_nonneg _)
  rw [← Finset.sum_sub_distrib]
  calc |∑ j ∈ Finset.range (d (n, k) + 1),
          ((a (n, k, j) : ℝ) * x ^ j - (a (n, k, j) : ℝ) * y ^ j)|
      = |∑ j ∈ Finset.range (d (n, k) + 1),
          (a (n, k, j) : ℝ) * (x ^ j - y ^ j)| := by
        congr 1
        apply Finset.sum_congr rfl
        intro j _
        ring
    _ ≤ ∑ j ∈ Finset.range (d (n, k) + 1),
          |(a (n, k, j) : ℝ) * (x ^ j - y ^ j)| :=
        Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ j ∈ Finset.range (d (n, k) + 1),
          (j : ℝ) * |(a (n, k, j) : ℝ)| * (C : ℝ) ^ (j - 1) * |x - y| := by
        apply Finset.sum_le_sum
        intro j _
        rw [abs_mul]
        have hpow : |x ^ j - y ^ j|
            ≤ |x - y| * j * max |x| |y| ^ (j - 1) :=
          abs_pow_sub_pow_le x y j
        have hpowC : max |x| |y| ^ (j - 1) ≤ (C : ℝ) ^ (j - 1) :=
          pow_le_pow_left₀ hmaxNN hmaxC (j - 1)
        have hjnn : (0 : ℝ) ≤ |x - y| * j :=
          mul_nonneg (abs_nonneg _) (Nat.cast_nonneg _)
        have h1 : |x ^ j - y ^ j| ≤ |x - y| * j * (C : ℝ) ^ (j - 1) :=
          hpow.trans (mul_le_mul_of_nonneg_left hpowC hjnn)
        calc |(a (n, k, j) : ℝ)| * |x ^ j - y ^ j|
            ≤ |(a (n, k, j) : ℝ)| * (|x - y| * j * (C : ℝ) ^ (j - 1)) :=
              mul_le_mul_of_nonneg_left h1 (abs_nonneg _)
          _ = (j : ℝ) * |(a (n, k, j) : ℝ)| * (C : ℝ) ^ (j - 1) * |x - y| := by ring
    _ = (∑ j ∈ Finset.range (d (n, k) + 1),
          (j : ℝ) * |(a (n, k, j) : ℝ)| * (C : ℝ) ^ (j - 1)) * |x - y| := by
        rw [Finset.sum_mul]

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

/-- **C[a,b] computability — Axiom 1 (Linear Forms).** P-R Ch. 2:66-72.

Given a fixed rational bound `B ≥ max(|α|, |β|)`, the C[a,b]-sequence
predicate `IsComputableSeqCMap` is closed under finite linear combinations
with computable rational scalar arrays. This is the A1 instance field of
`computabilityStructureCMap_of` extracted as a named, sorry-free lemma so
that the blueprint's `lem:l4_cmap_axiom1` can `\lean{}`-link directly to
it without inheriting `sorryAx` from the sibling A2/A3 fields (see
`docs/PITFALLS.md §7`).

Proof shape (rounds `l4-cmap-axiom-linearity-cont` and
`l4-cmap-axiom-linearity-bound`): witnesses for the linear combination are
obtained by applying the same finite combination to the witness polynomials
of `x` and `y`. A per-level precision pad
`M(n, m) := m + (d n + 1) + bound_max n + 2` absorbs both the per-summand
norm bound (controlled by `B`) and the arity, turning the polynomial
triangle inequality into the required `1 / 2 ^ m` estimate. -/
theorem isComputableSeqCMap_linearCombination
    (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ)) :
    ∀ (x y : ℕ → C(Set.Icc α β, ℝ))
      (coefα coefβ : ℕ × ℕ → ℝ) (d : ℕ → ℕ),
      IsComputableSeqCMap x → IsComputableSeqCMap y →
      ScalarComputableSeq.IsComputableSeq (fun n => coefα (Nat.unpair n)) →
      ScalarComputableSeq.IsComputableSeq (fun n => coefβ (Nat.unpair n)) →
      Computable d →
      IsComputableSeqCMap
        (fun n => ∑ k ∈ Finset.range (d n + 1),
            (coefα (n, k) • x k + coefβ (n, k) • y k)) := by
  -- Destructure all 5 hypotheses.
  intro x y coefα coefβ d hx hy hcoefα hcoefβ hd
  obtain ⟨aX, dX, hflat_X, hd_X, hbnd_X⟩ := hx
  obtain ⟨aY, dY, hflat_Y, hd_Y, hbnd_Y⟩ := hy
  obtain ⟨αR, hflat_αR, hbnd_αR⟩ := hcoefα
  obtain ⟨βR, hflat_βR, hbnd_βR⟩ := hcoefβ
  -- iter-10: extract inner recursion-theoretic witnesses for the norm-bound work.
  -- Each `_a`/`_b`/`_s` is a Computable ℕ → ℕ function; the `_a` components
  -- serve as ℕ-upper-bounds on `|aX(...)|`, `|αR(...)|` etc. (since for q : ℚ
  -- with q = (-1)^s · (a/b), |q| ≤ a/b ≤ a when b ≥ 1, treating a, b as reals).
  -- Re-introduce the outer hypotheses so iter-09's IsComputableSeqRat proof
  -- still type-checks with the same `hflat_X` etc. names.
  obtain ⟨aX_a, aX_b, aX_s, h_aX_a, h_aX_b, h_aX_s, h_aX_bne, h_aX_eq⟩ := hflat_X
  have hflat_X : IsComputableSeqRat (fun m => aX ((Nat.unpair m).1,
      (Nat.unpair (Nat.unpair m).2).1, (Nat.unpair (Nat.unpair m).2).2)) :=
    ⟨aX_a, aX_b, aX_s, h_aX_a, h_aX_b, h_aX_s, h_aX_bne, h_aX_eq⟩
  obtain ⟨aY_a, aY_b, aY_s, h_aY_a, h_aY_b, h_aY_s, h_aY_bne, h_aY_eq⟩ := hflat_Y
  have hflat_Y : IsComputableSeqRat (fun m => aY ((Nat.unpair m).1,
      (Nat.unpair (Nat.unpair m).2).1, (Nat.unpair (Nat.unpair m).2).2)) :=
    ⟨aY_a, aY_b, aY_s, h_aY_a, h_aY_b, h_aY_s, h_aY_bne, h_aY_eq⟩
  obtain ⟨αR_a, αR_b, αR_s, h_αR_a, h_αR_b, h_αR_s, h_αR_bne, h_αR_eq⟩ := hflat_αR
  have hflat_αR : IsComputableDoubleSeqRat αR :=
    ⟨αR_a, αR_b, αR_s, h_αR_a, h_αR_b, h_αR_s, h_αR_bne, h_αR_eq⟩
  obtain ⟨βR_a, βR_b, βR_s, h_βR_a, h_βR_b, h_βR_s, h_βR_bne, h_βR_eq⟩ := hflat_βR
  have hflat_βR : IsComputableDoubleSeqRat βR :=
    ⟨βR_a, βR_b, βR_s, h_βR_a, h_βR_b, h_βR_s, h_βR_bne, h_βR_eq⟩
  -- iter-11: simple bound helpers via composition of inner-`_a` witnesses
  -- with `Primrec₂.natPair`. These give Computable ℕ-upper-bounds on
  -- |aX(k, 0, j)|, |aY(k, 0, j)|, |αR(Nat.pair n k, 0)|, |βR(Nat.pair n k, 0)|.
  let bound_aX_at_0 : ℕ × ℕ → ℕ := fun kj =>
    aX_a (Nat.pair kj.1 (Nat.pair 0 kj.2))
  have h_bound_aX_at_0 : Computable bound_aX_at_0 := by
    show Computable (fun kj : ℕ × ℕ => aX_a (Nat.pair kj.1 (Nat.pair 0 kj.2)))
    have h_inner : Computable (fun kj : ℕ × ℕ => Nat.pair 0 kj.2) :=
      Primrec₂.natPair.to_comp.comp (Computable.const 0) Computable.snd
    have h_outer : Computable (fun kj : ℕ × ℕ => Nat.pair kj.1 (Nat.pair 0 kj.2)) :=
      Primrec₂.natPair.to_comp.comp Computable.fst h_inner
    exact h_aX_a.comp h_outer
  let bound_aY_at_0 : ℕ × ℕ → ℕ := fun kj =>
    aY_a (Nat.pair kj.1 (Nat.pair 0 kj.2))
  have h_bound_aY_at_0 : Computable bound_aY_at_0 := by
    show Computable (fun kj : ℕ × ℕ => aY_a (Nat.pair kj.1 (Nat.pair 0 kj.2)))
    have h_inner : Computable (fun kj : ℕ × ℕ => Nat.pair 0 kj.2) :=
      Primrec₂.natPair.to_comp.comp (Computable.const 0) Computable.snd
    have h_outer : Computable (fun kj : ℕ × ℕ => Nat.pair kj.1 (Nat.pair 0 kj.2)) :=
      Primrec₂.natPair.to_comp.comp Computable.fst h_inner
    exact h_aY_a.comp h_outer
  let bound_αR_at_0 : ℕ × ℕ → ℕ := fun nk =>
    αR_a (Nat.pair (Nat.pair nk.1 nk.2) 0)
  have h_bound_αR_at_0 : Computable bound_αR_at_0 := by
    show Computable (fun nk : ℕ × ℕ => αR_a (Nat.pair (Nat.pair nk.1 nk.2) 0))
    have h_pair_nk : Computable (fun nk : ℕ × ℕ => Nat.pair nk.1 nk.2) :=
      Primrec₂.natPair.to_comp.comp Computable.fst Computable.snd
    have h_outer : Computable (fun nk : ℕ × ℕ => Nat.pair (Nat.pair nk.1 nk.2) 0) :=
      Primrec₂.natPair.to_comp.comp h_pair_nk (Computable.const 0)
    exact h_αR_a.comp h_outer
  let bound_βR_at_0 : ℕ × ℕ → ℕ := fun nk =>
    βR_a (Nat.pair (Nat.pair nk.1 nk.2) 0)
  have h_bound_βR_at_0 : Computable bound_βR_at_0 := by
    show Computable (fun nk : ℕ × ℕ => βR_a (Nat.pair (Nat.pair nk.1 nk.2) 0))
    have h_pair_nk : Computable (fun nk : ℕ × ℕ => Nat.pair nk.1 nk.2) :=
      Primrec₂.natPair.to_comp.comp Computable.fst Computable.snd
    have h_outer : Computable (fun nk : ℕ × ℕ => Nat.pair (Nat.pair nk.1 nk.2) 0) :=
      Primrec₂.natPair.to_comp.comp h_pair_nk (Computable.const 0)
    exact h_βR_a.comp h_outer
  -- iter-11: B^j as a Computable function of j, via `Computable.nat_rec`.
  have h_Bpow : Computable (fun j : ℕ => B^j) := by
    have hh : Computable₂ (fun (_ : ℕ) (yih : ℕ × ℕ) => yih.2 * B) := by
      show Computable (fun p : ℕ × (ℕ × ℕ) => p.2.2 * B)
      exact Primrec.nat_mul.to_comp.comp (Computable.snd.comp Computable.snd)
        (Computable.const B)
    have h_rec := Computable.nat_rec Computable.id (Computable.const (1 : ℕ)) hh
    refine h_rec.of_eq fun j => ?_
    show Nat.rec 1 (fun y IH => (y, IH).2 * B) j = B^j
    induction j with
    | zero => rfl
    | succ j IH =>
      show Nat.rec 1 (fun y IH' => (y, IH').2 * B) j * B = B^(j + 1)
      rw [IH, pow_succ]
  -- iter-11: bound_x_k via `Computable.nat_rec` on `(dX (k, 0)).succ`.
  -- bound_x_k k := 1 + Σ_j ∈ Finset.range (dX(k, 0) + 1), bound_aX_at_0 (k, j) * B^j.
  let bound_x_k : ℕ → ℕ := fun k =>
    Nat.rec 1 (fun j acc => acc + bound_aX_at_0 (k, j) * B^j) ((dX (k, 0)).succ)
  have h_bound_x_k : Computable bound_x_k := by
    show Computable (fun k : ℕ =>
      Nat.rec (motive := fun _ => ℕ) 1
        (fun j acc => acc + bound_aX_at_0 (k, j) * B^j) ((dX (k, 0)).succ))
    have hf : Computable (fun k : ℕ => (dX (k, 0)).succ) :=
      Computable.succ.comp (hd_X.comp (Computable.id.pair (Computable.const 0)))
    have hh : Computable₂ (fun (k : ℕ) (jacc : ℕ × ℕ) =>
        jacc.2 + bound_aX_at_0 (k, jacc.1) * B^jacc.1) := by
      show Computable (fun p : ℕ × (ℕ × ℕ) =>
          p.2.2 + bound_aX_at_0 (p.1, p.2.1) * B^p.2.1)
      have h_k : Computable (fun p : ℕ × (ℕ × ℕ) => p.1) := Computable.fst
      have h_j : Computable (fun p : ℕ × (ℕ × ℕ) => p.2.1) :=
        Computable.fst.comp Computable.snd
      have h_acc : Computable (fun p : ℕ × (ℕ × ℕ) => p.2.2) :=
        Computable.snd.comp Computable.snd
      have h_pair_kj : Computable (fun p : ℕ × (ℕ × ℕ) => (p.1, p.2.1)) := h_k.pair h_j
      have h_baX : Computable (fun p : ℕ × (ℕ × ℕ) => bound_aX_at_0 (p.1, p.2.1)) :=
        h_bound_aX_at_0.comp h_pair_kj
      have h_Bpow_j : Computable (fun p : ℕ × (ℕ × ℕ) => B^p.2.1) := h_Bpow.comp h_j
      have h_prod : Computable (fun p : ℕ × (ℕ × ℕ) =>
          bound_aX_at_0 (p.1, p.2.1) * B^p.2.1) :=
        Primrec.nat_mul.to_comp.comp h_baX h_Bpow_j
      exact Primrec.nat_add.to_comp.comp h_acc h_prod
    exact Computable.nat_rec hf (Computable.const 1) hh
  -- iter-11: bound_y_k mirrors bound_x_k.
  let bound_y_k : ℕ → ℕ := fun k =>
    Nat.rec 1 (fun j acc => acc + bound_aY_at_0 (k, j) * B^j) ((dY (k, 0)).succ)
  have h_bound_y_k : Computable bound_y_k := by
    show Computable (fun k : ℕ =>
      Nat.rec (motive := fun _ => ℕ) 1
        (fun j acc => acc + bound_aY_at_0 (k, j) * B^j) ((dY (k, 0)).succ))
    have hf : Computable (fun k : ℕ => (dY (k, 0)).succ) :=
      Computable.succ.comp (hd_Y.comp (Computable.id.pair (Computable.const 0)))
    have hh : Computable₂ (fun (k : ℕ) (jacc : ℕ × ℕ) =>
        jacc.2 + bound_aY_at_0 (k, jacc.1) * B^jacc.1) := by
      show Computable (fun p : ℕ × (ℕ × ℕ) =>
          p.2.2 + bound_aY_at_0 (p.1, p.2.1) * B^p.2.1)
      have h_k : Computable (fun p : ℕ × (ℕ × ℕ) => p.1) := Computable.fst
      have h_j : Computable (fun p : ℕ × (ℕ × ℕ) => p.2.1) :=
        Computable.fst.comp Computable.snd
      have h_acc : Computable (fun p : ℕ × (ℕ × ℕ) => p.2.2) :=
        Computable.snd.comp Computable.snd
      have h_pair_kj : Computable (fun p : ℕ × (ℕ × ℕ) => (p.1, p.2.1)) := h_k.pair h_j
      have h_baY : Computable (fun p : ℕ × (ℕ × ℕ) => bound_aY_at_0 (p.1, p.2.1)) :=
        h_bound_aY_at_0.comp h_pair_kj
      have h_Bpow_j : Computable (fun p : ℕ × (ℕ × ℕ) => B^p.2.1) := h_Bpow.comp h_j
      have h_prod : Computable (fun p : ℕ × (ℕ × ℕ) =>
          bound_aY_at_0 (p.1, p.2.1) * B^p.2.1) :=
        Primrec.nat_mul.to_comp.comp h_baY h_Bpow_j
      exact Primrec.nat_add.to_comp.comp h_acc h_prod
    exact Computable.nat_rec hf (Computable.const 1) hh
  -- iter-12: per-k crude rational bound, as a ℕ-upper-bound on
  -- ‖x_k‖_∞ + ‖y_k‖_∞ + |αR(.., 0)| + |βR(.., 0)| + 6 (the 6 absorbs additive constants).
  let stuff_per_k : ℕ × ℕ → ℕ := fun nk =>
    bound_x_k nk.2 + bound_y_k nk.2 + bound_αR_at_0 nk + bound_βR_at_0 nk + 6
  have h_stuff_per_k : Computable stuff_per_k := by
    show Computable (fun nk : ℕ × ℕ =>
      bound_x_k nk.2 + bound_y_k nk.2 + bound_αR_at_0 nk + bound_βR_at_0 nk + 6)
    have h_bx : Computable (fun nk : ℕ × ℕ => bound_x_k nk.2) :=
      h_bound_x_k.comp Computable.snd
    have h_by : Computable (fun nk : ℕ × ℕ => bound_y_k nk.2) :=
      h_bound_y_k.comp Computable.snd
    have h1 := Primrec.nat_add.to_comp.comp h_bx h_by
    have h2 := Primrec.nat_add.to_comp.comp h1 h_bound_αR_at_0
    have h3 := Primrec.nat_add.to_comp.comp h2 h_bound_βR_at_0
    exact Primrec.nat_add.to_comp.comp h3 (Computable.const 6)
  -- iter-12: max over k ∈ Finset.range (d n + 1) of stuff_per_k (n, k), as a ℕ.
  -- Built by Computable.nat_rec on (d n).succ, step is `max acc (stuff_per_k (n, k))`.
  let bound_max : ℕ → ℕ := fun n =>
    Nat.rec 0 (fun k acc => max acc (stuff_per_k (n, k))) ((d n).succ)
  have h_bound_max : Computable bound_max := by
    show Computable (fun n : ℕ =>
      Nat.rec (motive := fun _ => ℕ) 0
        (fun k acc => max acc (stuff_per_k (n, k))) ((d n).succ))
    have hf : Computable (fun n : ℕ => (d n).succ) := Computable.succ.comp hd
    have hh : Computable₂ (fun (n : ℕ) (kacc : ℕ × ℕ) =>
        max kacc.2 (stuff_per_k (n, kacc.1))) := by
      show Computable (fun p : ℕ × (ℕ × ℕ) =>
        max p.2.2 (stuff_per_k (p.1, p.2.1)))
      have h_n : Computable (fun p : ℕ × (ℕ × ℕ) => p.1) := Computable.fst
      have h_k : Computable (fun p : ℕ × (ℕ × ℕ) => p.2.1) :=
        Computable.fst.comp Computable.snd
      have h_acc : Computable (fun p : ℕ × (ℕ × ℕ) => p.2.2) :=
        Computable.snd.comp Computable.snd
      have h_pair_nk : Computable (fun p : ℕ × (ℕ × ℕ) => (p.1, p.2.1)) := h_n.pair h_k
      have h_stuff : Computable (fun p : ℕ × (ℕ × ℕ) => stuff_per_k (p.1, p.2.1)) :=
        h_stuff_per_k.comp h_pair_nk
      exact Primrec.nat_max.to_comp.comp h_acc h_stuff
    exact Computable.nat_rec hf (Computable.const 0) hh
  -- iter-06/12: witness skeleton. Precision pad upgraded (iter-12) to incorporate
  -- bound_max so the norm bound goes through (`M = m + (d n + 1) + bound_max n + 2`).
  let M : ℕ × ℕ → ℕ := fun nm => nm.2 + (d nm.1 + 1) + bound_max nm.1 + 2
  -- Degree bound: max over k ∈ range(d n + 1) of max(dX(k, M), dY(k, M)).
  -- Built by Nat.rec on the upper bound, accumulating max.
  let dS : ℕ × ℕ → ℕ := fun nm =>
    Nat.rec 0 (fun k acc => max acc (max (dX (k, M nm)) (dY (k, M nm))))
      ((d nm.1).succ)
  -- Padcoeff: zeroes the coefficient past the per-k degree bound.
  -- Uses `bif decide` rather than `if` to match the form `ite_rat` produces;
  -- semantically identical to `if ... then ... else 0` since `≤` is decidable on ℕ.
  let pad_X : ℕ × ℕ → ℕ → ℚ := fun km j =>
    bif decide (j ≤ dX km) then aX (km.1, km.2, j) else 0
  let pad_Y : ℕ × ℕ → ℕ → ℚ := fun km j =>
    bif decide (j ≤ dY km) then aY (km.1, km.2, j) else 0
  -- Coefficient triple-sequence aS, expressed as a `Finset.sum` over k.
  -- (Mathematically equivalent to the `Nat.rec` form; `Finset.sum` enables
  -- direct application of `finsetSum_rat` for the IsComputableSeqRat proof.)
  let aS : ℕ × ℕ × ℕ → ℚ := fun nmj =>
    let n := nmj.1; let m := nmj.2.1; let j := nmj.2.2
    ∑ k ∈ Finset.range (d n + 1),
      (αR (Nat.pair n k, M (n, m)) * pad_X (k, M (n, m)) j
       + βR (Nat.pair n k, M (n, m)) * pad_Y (k, M (n, m)) j)
  -- iter-07: prove `Computable M` and `Computable dS`, then refine ⟨aS, dS, ?_, hd_S, ?_⟩.
  -- Computability of M.
  have hM : Computable M := by
    show Computable (fun nm : ℕ × ℕ => nm.2 + (d nm.1 + 1) + bound_max nm.1 + 2)
    have h_dnm : Computable (fun nm : ℕ × ℕ => d nm.1) := hd.comp Computable.fst
    have h_dnm_succ : Computable (fun nm : ℕ × ℕ => d nm.1 + 1) :=
      Computable.succ.comp h_dnm
    have h_bm : Computable (fun nm : ℕ × ℕ => bound_max nm.1) :=
      h_bound_max.comp Computable.fst
    have h_sum1 : Computable (fun nm : ℕ × ℕ => nm.2 + (d nm.1 + 1)) :=
      Primrec.nat_add.to_comp.comp Computable.snd h_dnm_succ
    have h_sum2 : Computable (fun nm : ℕ × ℕ => nm.2 + (d nm.1 + 1) + bound_max nm.1) :=
      Primrec.nat_add.to_comp.comp h_sum1 h_bm
    exact Primrec.nat_add.to_comp.comp h_sum2 (Computable.const 2)
  -- Computability of dS via Computable.nat_rec on (d nm.1).succ.
  have hd_S : Computable dS := by
    show Computable (fun nm : ℕ × ℕ =>
      Nat.rec (motive := fun _ => ℕ) 0
        (fun k acc => max acc (max (dX (k, M nm)) (dY (k, M nm))))
        ((d nm.1).succ))
    have h_step : Computable₂ (fun (nm : ℕ × ℕ) (kacc : ℕ × ℕ) =>
        max kacc.2 (max (dX (kacc.1, M nm)) (dY (kacc.1, M nm)))) := by
      show Computable (fun p : (ℕ × ℕ) × (ℕ × ℕ) =>
        max p.2.2 (max (dX (p.2.1, M p.1)) (dY (p.2.1, M p.1))))
      have h_M : Computable (fun p : (ℕ × ℕ) × (ℕ × ℕ) => M p.1) :=
        hM.comp Computable.fst
      have h_k : Computable (fun p : (ℕ × ℕ) × (ℕ × ℕ) => p.2.1) :=
        Computable.fst.comp Computable.snd
      have h_acc : Computable (fun p : (ℕ × ℕ) × (ℕ × ℕ) => p.2.2) :=
        Computable.snd.comp Computable.snd
      have h_arg_kM : Computable (fun p : (ℕ × ℕ) × (ℕ × ℕ) => (p.2.1, M p.1)) :=
        h_k.pair h_M
      have h_dX_pkM : Computable (fun p : (ℕ × ℕ) × (ℕ × ℕ) => dX (p.2.1, M p.1)) :=
        hd_X.comp h_arg_kM
      have h_dY_pkM : Computable (fun p : (ℕ × ℕ) × (ℕ × ℕ) => dY (p.2.1, M p.1)) :=
        hd_Y.comp h_arg_kM
      have h_innermax : Computable (fun p : (ℕ × ℕ) × (ℕ × ℕ) =>
          max (dX (p.2.1, M p.1)) (dY (p.2.1, M p.1))) :=
        Primrec.nat_max.to_comp.comp h_dX_pkM h_dY_pkM
      exact Primrec.nat_max.to_comp.comp h_acc h_innermax
    exact Computable.nat_rec
      (Computable.succ.comp (hd.comp Computable.fst))
      (Computable.const (0 : ℕ)) h_step
  -- Refine to ⟨aS, dS, ?_, hd_S, ?_⟩; sorry only the remaining norm bound.
  refine ⟨aS, dS, ?_, hd_S, ?_⟩
  · -- IsComputableSeqRat (flatten aS).
    -- Apply `FinsetSumHelper.finsetSum_rat` with:
    --   `n' outer := d (Nat.unpair outer).1`  (sum upper bound, Computable)
    --   `r' (outer, k) := αR·pad_X + βR·pad_Y` with all indices decoded from outer.
    -- Decoding helpers (Computable functions of p : ℕ).
    have h_outer : Computable (fun p : ℕ => (Nat.unpair p).1) :=
      Computable.fst.comp Computable.unpair
    have h_k : Computable (fun p : ℕ => (Nat.unpair p).2) :=
      Computable.snd.comp Computable.unpair
    have h_n : Computable (fun p : ℕ => (Nat.unpair (Nat.unpair p).1).1) :=
      Computable.fst.comp (Computable.unpair.comp h_outer)
    have h_outer2 : Computable (fun p : ℕ => (Nat.unpair (Nat.unpair p).1).2) :=
      Computable.snd.comp (Computable.unpair.comp h_outer)
    have h_m : Computable (fun p : ℕ => (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1) :=
      Computable.fst.comp (Computable.unpair.comp h_outer2)
    have h_j : Computable (fun p : ℕ => (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).2) :=
      Computable.snd.comp (Computable.unpair.comp h_outer2)
    -- Indexers for the closures.
    have h_pair_nk : Computable (fun p : ℕ =>
        Nat.pair ((Nat.unpair (Nat.unpair p).1).1) ((Nat.unpair p).2)) :=
      Primrec₂.natPair.to_comp.comp h_n h_k
    have h_M_nm : Computable (fun p : ℕ => M ((Nat.unpair (Nat.unpair p).1).1,
        (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1)) :=
      hM.comp (h_n.pair h_m)
    have h_dX_km : Computable (fun p : ℕ => dX ((Nat.unpair p).2,
        M ((Nat.unpair (Nat.unpair p).1).1,
           (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1))) :=
      hd_X.comp (h_k.pair h_M_nm)
    have h_dY_km : Computable (fun p : ℕ => dY ((Nat.unpair p).2,
        M ((Nat.unpair (Nat.unpair p).1).1,
           (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1))) :=
      hd_Y.comp (h_k.pair h_M_nm)
    -- αR-term and βR-term via doubleApply.
    have h_αR_term : IsComputableSeqRat (fun p : ℕ =>
        αR (Nat.pair ((Nat.unpair (Nat.unpair p).1).1) ((Nat.unpair p).2),
            M ((Nat.unpair (Nat.unpair p).1).1,
               (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1))) :=
      FinsetSumHelper.isComputableSeqRat_doubleApply hflat_αR h_pair_nk h_M_nm
    have h_βR_term : IsComputableSeqRat (fun p : ℕ =>
        βR (Nat.pair ((Nat.unpair (Nat.unpair p).1).1) ((Nat.unpair p).2),
            M ((Nat.unpair (Nat.unpair p).1).1,
               (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1))) :=
      FinsetSumHelper.isComputableSeqRat_doubleApply hflat_βR h_pair_nk h_M_nm
    -- aX (k, M, j) and aY (k, M, j) via tripleApply.
    have h_aX_kMj : IsComputableSeqRat (fun p : ℕ =>
        aX ((Nat.unpair p).2,
            M ((Nat.unpair (Nat.unpair p).1).1,
               (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1),
            (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).2)) :=
      FinsetSumHelper.isComputableSeqRat_tripleApply hflat_X h_k h_M_nm h_j
    have h_aY_kMj : IsComputableSeqRat (fun p : ℕ =>
        aY ((Nat.unpair p).2,
            M ((Nat.unpair (Nat.unpair p).1).1,
               (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1),
            (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).2)) :=
      FinsetSumHelper.isComputableSeqRat_tripleApply hflat_Y h_k h_M_nm h_j
    -- Conditions for ite_rat.
    have h_cond_X : Computable (fun p : ℕ =>
        decide ((Nat.unpair (Nat.unpair (Nat.unpair p).1).2).2 ≤
          dX ((Nat.unpair p).2,
              M ((Nat.unpair (Nat.unpair p).1).1,
                 (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1)))) := by
      have h_le : Primrec₂ (fun a b : ℕ => decide (a ≤ b)) := Primrec.nat_le.decide
      exact h_le.to_comp.comp h_j h_dX_km
    have h_cond_Y : Computable (fun p : ℕ =>
        decide ((Nat.unpair (Nat.unpair (Nat.unpair p).1).2).2 ≤
          dY ((Nat.unpair p).2,
              M ((Nat.unpair (Nat.unpair p).1).1,
                 (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1)))) := by
      have h_le : Primrec₂ (fun a b : ℕ => decide (a ≤ b)) := Primrec.nat_le.decide
      exact h_le.to_comp.comp h_j h_dY_km
    -- pad_X and pad_Y as IsComputableSeqRat via ite_rat.
    have h_pad_X_seq : IsComputableSeqRat (fun p : ℕ =>
        pad_X ((Nat.unpair p).2,
               M ((Nat.unpair (Nat.unpair p).1).1,
                  (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1))
              (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).2) :=
      FinsetSumHelper.ite_rat h_aX_kMj (isComputableSeqRat_const 0) h_cond_X
    have h_pad_Y_seq : IsComputableSeqRat (fun p : ℕ =>
        pad_Y ((Nat.unpair p).2,
               M ((Nat.unpair (Nat.unpair p).1).1,
                  (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).1))
              (Nat.unpair (Nat.unpair (Nat.unpair p).1).2).2) :=
      FinsetSumHelper.ite_rat h_aY_kMj (isComputableSeqRat_const 0) h_cond_Y
    -- αR · pad_X and βR · pad_Y via .mul.
    have h_αR_padX := h_αR_term.mul h_pad_X_seq
    have h_βR_padY := h_βR_term.mul h_pad_Y_seq
    -- Sum via .add.
    have h_r_flat := h_αR_padX.add h_βR_padY
    -- Computable upper bound for finsetSum_rat.
    have hn' : Computable (fun outer : ℕ => d (Nat.unpair outer).1) :=
      hd.comp (Computable.fst.comp Computable.unpair)
    -- Cast h_r_flat (which has function-level + / *) into IsComputableDoubleSeqRat r'
    -- for an explicit r'. The cast is defeq modulo Pi.add_apply / Pi.mul_apply + beta.
    have hr' : IsComputableDoubleSeqRat (fun pair : ℕ × ℕ =>
        αR (Nat.pair (Nat.unpair pair.1).1 pair.2,
            M ((Nat.unpair pair.1).1, (Nat.unpair (Nat.unpair pair.1).2).1)) *
        pad_X (pair.2, M ((Nat.unpair pair.1).1,
                           (Nat.unpair (Nat.unpair pair.1).2).1))
              (Nat.unpair (Nat.unpair pair.1).2).2 +
        βR (Nat.pair (Nat.unpair pair.1).1 pair.2,
            M ((Nat.unpair pair.1).1, (Nat.unpair (Nat.unpair pair.1).2).1)) *
        pad_Y (pair.2, M ((Nat.unpair pair.1).1,
                           (Nat.unpair (Nat.unpair pair.1).2).1))
              (Nat.unpair (Nat.unpair pair.1).2).2) := by
      show IsComputableSeqRat _
      convert h_r_flat using 1
    -- Construct the witness.
    exact FinsetSumHelper.finsetSum_rat hr' hn'
  · -- iter-14+: norm bound `‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m`
    -- Strategy (full proof deferred to follow-up round `l4-cmap-axiom-linearity-bound`;
    -- see `claims/l4-cmap-axiom-linearity/axiom_linearity.md` for the 6-step outline):
    --   1. Reduce ContinuousMap-norm to pointwise: `‖f - g‖ ≤ ε ↔ ∀ x, |f x - g x| ≤ ε`
    --      (Mathlib: `ContinuousMap.norm_le_iff` for nonempty compact domain, or
    --      `BoundedContinuousFunction.norm_le_iff` after isometric embedding).
    --   2. Polynomial-expansion identity: `polyApproxCMap aS dS n m (x_*) =
    --      Σ_k (αR · polyApproxCMap aX dX k M(n,m) + βR · polyApproxCMap aY dY k M(n,m))(x_*)`
    --      via `Finset.sum_comm` + the padcoeff identity
    --      (Σ_{j ≤ dS} pad_X = polyApprox aX dX k M).
    --   3. Triangle inequality on `Σ_k (coefα·x_k - αR·polyApprox aX dX k M)`.
    --   4. Per-k summand bound via `hbnd_αR`, `hbnd_X`, `bound_x_k`, `bound_αR_at_0`,
    --      and `hα_le`, `hβ_le` to bound `‖x_k‖_∞ ≤ bound_x_k k`.
    --   5. Σ_k bound by `(d n + 1) · bound_max(n)`.
    --   6. Close: `2^M ≥ 4 · (d n + 1) · bound_max(n)` by M's formula.
    --
    intro n m
    refine (ContinuousMap.norm_le _ (by positivity)).mpr (fun w => ?_)
    rw [Real.norm_eq_abs]
    -- Step 2 prep: each summand degree dX k, dY k at precision M(n,m) is ≤ dS(n,m).
    have hge_dS : ∀ k, k ≤ d n →
        dX (k, M (n, m)) ≤ dS (n, m) ∧ dY (k, M (n, m)) ≤ dS (n, m) := by
      intro k hk
      have hrec := le_natRec_max (fun k => max (dX (k, M (n, m))) (dY (k, M (n, m)))) k
        (d n).succ (Nat.lt_succ_of_le hk)
      exact ⟨le_trans (le_max_left _ _) hrec, le_trans (le_max_right _ _) hrec⟩
    -- Step 2: polynomial-expansion identity for the approximant value at w.
    have hPval : (polyApproxCMap aS dS n m) w =
        ∑ k ∈ Finset.range (d n + 1),
          ((αR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aX dX k (M (n, m))) w
            + (βR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aY dY k (M (n, m))) w) := by
      rw [polyApproxCMap_eval]
      exact polyApproxCMap_conv_eval aX aY dX dY αR βR n (M (n, m)) (d n) (dS (n, m)) hge_dS w
    -- LHS combination value at w.
    have hsval : (∑ k ∈ Finset.range (d n + 1),
          (coefα (n, k) • x k + coefβ (n, k) • y k)) w
        = ∑ k ∈ Finset.range (d n + 1),
            (coefα (n, k) * (x k) w + coefβ (n, k) * (y k) w) := by
      simp only [ContinuousMap.coe_sum, Finset.sum_apply, ContinuousMap.add_apply,
        ContinuousMap.smul_apply, smul_eq_mul]
    -- Step 3: combine into a single sum of per-k differences (avoids applying the
    -- ContinuousMap subtraction to `w` directly, which left the term at metavar type).
    rw [ContinuousMap.sub_apply, hsval, hPval, ← Finset.sum_sub_distrib]
    -- Step 5 prep: each `stuff_per_k (n, k)` is dominated by `bound_max n`.
    have hstuff_le : ∀ k ∈ Finset.range (d n + 1),
        (stuff_per_k (n, k) : ℝ) ≤ (bound_max n : ℝ) := by
      intro k hk
      have hrec := le_natRec_max (fun k => stuff_per_k (n, k)) k (d n).succ
        (Finset.mem_range.mp hk)
      exact_mod_cast hrec
    -- Step 4: per-k summand bound `|F_k - G_k| ≤ 2^{-M(n,m)} · stuff_per_k (n, k)`.
    have hperk : ∀ k ∈ Finset.range (d n + 1),
        |(coefα (n, k) * (x k) w + coefβ (n, k) * (y k) w)
          - ((αR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aX dX k (M (n, m))) w
              + (βR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aY dY k (M (n, m))) w)|
          ≤ (1 / 2 ^ (M (n, m))) * (stuff_per_k (n, k) : ℝ) := by
      intro k hk
      have hεpos : (0 : ℝ) ≤ 1 / 2 ^ (M (n, m)) := by positivity
      have hone_le : (1 : ℝ) / 2 ^ (M (n, m)) ≤ 1 := by
        rw [div_le_one (by positivity)]; exact one_le_pow₀ (by norm_num)
      -- ε-closeness of the X-coefficient and X-approximant (orientation as `perk_bound` wants).
      have hclose_X : |(x k) w - (polyApproxCMap aX dX k (M (n, m))) w|
          ≤ 1 / 2 ^ (M (n, m)) := by
        have h := (x k - polyApproxCMap aX dX k (M (n, m))).norm_coe_le_norm w
        rw [ContinuousMap.sub_apply, Real.norm_eq_abs] at h
        exact le_trans h (hbnd_X k (M (n, m)))
      have hαr_close : |(αR (Nat.pair n k, M (n, m)) : ℝ) - coefα (n, k)|
          ≤ 1 / 2 ^ (M (n, m)) := by
        have h := hbnd_αR (Nat.pair n k) (M (n, m)); simpa only [Nat.unpair_pair] using h
      -- |coefα| bound via the precision-0 rational approximant.
      have hcα_bd : |coefα (n, k)| ≤ (↑(bound_αR_at_0 (n, k)) : ℝ) + 1 := by
        have heq := h_αR_eq (Nat.pair (Nat.pair n k) 0)
        simp only [Nat.unpair_pair] at heq
        have habs : |(αR (Nat.pair n k, 0) : ℝ)| ≤ (↑(bound_αR_at_0 (n, k)) : ℝ) := by
          rw [heq]
          exact_mod_cast abs_cast_neg_one_pow_div_le (αR_a (Nat.pair (Nat.pair n k) 0))
            (αR_b (Nat.pair (Nat.pair n k) 0)) (αR_s (Nat.pair (Nat.pair n k) 0))
            (h_αR_bne (Nat.pair (Nat.pair n k) 0))
        have hclose0 := hbnd_αR (Nat.pair n k) 0
        simp only [Nat.unpair_pair, pow_zero, div_one] at hclose0
        have h1 := abs_sub_abs_le_abs_sub (coefα (n, k)) ((αR (Nat.pair n k, 0) : ℝ))
        rw [abs_sub_comm (coefα (n, k)) ((αR (Nat.pair n k, 0) : ℝ))] at h1
        linarith [h1, habs, hclose0]
      -- |polyApproxCMap aX dX k M(n,m)|_w bound:
      -- precision-M ≤ ‖x k‖+1 ≤ ‖poly_0‖+2 ≤ bound_x_k+2.
      have hpXk_bd : |(polyApproxCMap aX dX k (M (n, m))) w| ≤ (↑(bound_x_k k) : ℝ) + 2 := by
        have hpw_le : |(polyApproxCMap aX dX k (M (n, m))) w|
            ≤ ‖polyApproxCMap (α := α) (β := β) aX dX k (M (n, m))‖ := by
          have h := (polyApproxCMap aX dX k (M (n, m))).norm_coe_le_norm w
          rwa [Real.norm_eq_abs] at h
        have hnorm_M : ‖polyApproxCMap (α := α) (β := β) aX dX k (M (n, m))‖ ≤ ‖x k‖ + 1 := by
          have hb := hbnd_X k (M (n, m))
          have hnn := norm_sub_norm_le (polyApproxCMap aX dX k (M (n, m))) (x k)
          rw [norm_sub_rev] at hnn
          linarith [hnn, hb, hone_le]
        have hnorm_xk : ‖x k‖ ≤ ‖polyApproxCMap (α := α) (β := β) aX dX k 0‖ + 1 := by
          have hb := hbnd_X k 0
          rw [pow_zero, div_one] at hb
          have hnn := norm_sub_norm_le (x k) (polyApproxCMap aX dX k 0)
          linarith [hnn, hb]
        have hC : ∀ j, |(aX (k, 0, j) : ℝ)| ≤ (↑(bound_aX_at_0 (k, j)) : ℝ) := by
          intro j
          have heq := h_aX_eq (Nat.pair k (Nat.pair 0 j))
          simp only [Nat.unpair_pair] at heq
          rw [heq]
          exact_mod_cast abs_cast_neg_one_pow_div_le (aX_a (Nat.pair k (Nat.pair 0 j)))
            (aX_b (Nat.pair k (Nat.pair 0 j))) (aX_s (Nat.pair k (Nat.pair 0 j)))
            (h_aX_bne (Nat.pair k (Nat.pair 0 j)))
        have hbx : bound_x_k k
            = 1 + ∑ j ∈ Finset.range (dX (k, 0) + 1), bound_aX_at_0 (k, j) * B ^ j := by
          show Nat.rec 1 (fun j acc => acc + bound_aX_at_0 (k, j) * B ^ j) ((dX (k, 0)).succ)
              = 1 + ∑ j ∈ Finset.range (dX (k, 0) + 1), bound_aX_at_0 (k, j) * B ^ j
          exact natRec_add_eq_sum 1 (fun j => bound_aX_at_0 (k, j) * B ^ j) ((dX (k, 0)).succ)
        have hnorm_p0 : ‖polyApproxCMap (α := α) (β := β) aX dX k 0‖ ≤ (↑(bound_x_k k) : ℝ) := by
          have hmain : ‖polyApproxCMap (α := α) (β := β) aX dX k 0‖
              ≤ ∑ j ∈ Finset.range (dX (k, 0) + 1),
                  (↑(bound_aX_at_0 (k, j)) : ℝ) * (B : ℝ) ^ j :=
            polyApproxCMap_norm_le_sum aX dX k 0 B hα_le hβ_le
              (fun j => (↑(bound_aX_at_0 (k, j)) : ℝ)) (fun _ => by positivity) hC
          have hcast : (↑(bound_x_k k) : ℝ)
              = 1 + ∑ j ∈ Finset.range (dX (k, 0) + 1),
                  (↑(bound_aX_at_0 (k, j)) : ℝ) * (B : ℝ) ^ j := by
            rw [hbx]; push_cast; ring
          rw [hcast]; linarith [hmain]
        calc |(polyApproxCMap aX dX k (M (n, m))) w|
            ≤ ‖polyApproxCMap (α := α) (β := β) aX dX k (M (n, m))‖ := hpw_le
          _ ≤ ‖x k‖ + 1 := hnorm_M
          _ ≤ (‖polyApproxCMap (α := α) (β := β) aX dX k 0‖ + 1) + 1 := by linarith [hnorm_xk]
          _ ≤ ((↑(bound_x_k k) : ℝ) + 1) + 1 := by linarith [hnorm_p0]
          _ = (↑(bound_x_k k) : ℝ) + 2 := by ring
      -- Y-side mirror of the four X-side bounds.
      have hclose_Y : |(y k) w - (polyApproxCMap aY dY k (M (n, m))) w|
          ≤ 1 / 2 ^ (M (n, m)) := by
        have h := (y k - polyApproxCMap aY dY k (M (n, m))).norm_coe_le_norm w
        rw [ContinuousMap.sub_apply, Real.norm_eq_abs] at h
        exact le_trans h (hbnd_Y k (M (n, m)))
      have hβr_close : |(βR (Nat.pair n k, M (n, m)) : ℝ) - coefβ (n, k)|
          ≤ 1 / 2 ^ (M (n, m)) := by
        have h := hbnd_βR (Nat.pair n k) (M (n, m)); simpa only [Nat.unpair_pair] using h
      have hcβ_bd : |coefβ (n, k)| ≤ (↑(bound_βR_at_0 (n, k)) : ℝ) + 1 := by
        have heq := h_βR_eq (Nat.pair (Nat.pair n k) 0)
        simp only [Nat.unpair_pair] at heq
        have habs : |(βR (Nat.pair n k, 0) : ℝ)| ≤ (↑(bound_βR_at_0 (n, k)) : ℝ) := by
          rw [heq]
          exact_mod_cast abs_cast_neg_one_pow_div_le (βR_a (Nat.pair (Nat.pair n k) 0))
            (βR_b (Nat.pair (Nat.pair n k) 0)) (βR_s (Nat.pair (Nat.pair n k) 0))
            (h_βR_bne (Nat.pair (Nat.pair n k) 0))
        have hclose0 := hbnd_βR (Nat.pair n k) 0
        simp only [Nat.unpair_pair, pow_zero, div_one] at hclose0
        have h1 := abs_sub_abs_le_abs_sub (coefβ (n, k)) ((βR (Nat.pair n k, 0) : ℝ))
        rw [abs_sub_comm (coefβ (n, k)) ((βR (Nat.pair n k, 0) : ℝ))] at h1
        linarith [h1, habs, hclose0]
      have hpYk_bd : |(polyApproxCMap aY dY k (M (n, m))) w| ≤ (↑(bound_y_k k) : ℝ) + 2 := by
        have hpw_le : |(polyApproxCMap aY dY k (M (n, m))) w|
            ≤ ‖polyApproxCMap (α := α) (β := β) aY dY k (M (n, m))‖ := by
          have h := (polyApproxCMap aY dY k (M (n, m))).norm_coe_le_norm w
          rwa [Real.norm_eq_abs] at h
        have hnorm_M : ‖polyApproxCMap (α := α) (β := β) aY dY k (M (n, m))‖ ≤ ‖y k‖ + 1 := by
          have hb := hbnd_Y k (M (n, m))
          have hnn := norm_sub_norm_le (polyApproxCMap aY dY k (M (n, m))) (y k)
          rw [norm_sub_rev] at hnn
          linarith [hnn, hb, hone_le]
        have hnorm_yk : ‖y k‖ ≤ ‖polyApproxCMap (α := α) (β := β) aY dY k 0‖ + 1 := by
          have hb := hbnd_Y k 0
          rw [pow_zero, div_one] at hb
          have hnn := norm_sub_norm_le (y k) (polyApproxCMap aY dY k 0)
          linarith [hnn, hb]
        have hC : ∀ j, |(aY (k, 0, j) : ℝ)| ≤ (↑(bound_aY_at_0 (k, j)) : ℝ) := by
          intro j
          have heq := h_aY_eq (Nat.pair k (Nat.pair 0 j))
          simp only [Nat.unpair_pair] at heq
          rw [heq]
          exact_mod_cast abs_cast_neg_one_pow_div_le (aY_a (Nat.pair k (Nat.pair 0 j)))
            (aY_b (Nat.pair k (Nat.pair 0 j))) (aY_s (Nat.pair k (Nat.pair 0 j)))
            (h_aY_bne (Nat.pair k (Nat.pair 0 j)))
        have hby : bound_y_k k
            = 1 + ∑ j ∈ Finset.range (dY (k, 0) + 1), bound_aY_at_0 (k, j) * B ^ j := by
          show Nat.rec 1 (fun j acc => acc + bound_aY_at_0 (k, j) * B ^ j) ((dY (k, 0)).succ)
              = 1 + ∑ j ∈ Finset.range (dY (k, 0) + 1), bound_aY_at_0 (k, j) * B ^ j
          exact natRec_add_eq_sum 1 (fun j => bound_aY_at_0 (k, j) * B ^ j) ((dY (k, 0)).succ)
        have hnorm_p0 : ‖polyApproxCMap (α := α) (β := β) aY dY k 0‖ ≤ (↑(bound_y_k k) : ℝ) := by
          have hmain : ‖polyApproxCMap (α := α) (β := β) aY dY k 0‖
              ≤ ∑ j ∈ Finset.range (dY (k, 0) + 1),
                  (↑(bound_aY_at_0 (k, j)) : ℝ) * (B : ℝ) ^ j :=
            polyApproxCMap_norm_le_sum aY dY k 0 B hα_le hβ_le
              (fun j => (↑(bound_aY_at_0 (k, j)) : ℝ)) (fun _ => by positivity) hC
          have hcast : (↑(bound_y_k k) : ℝ)
              = 1 + ∑ j ∈ Finset.range (dY (k, 0) + 1),
                  (↑(bound_aY_at_0 (k, j)) : ℝ) * (B : ℝ) ^ j := by
            rw [hby]; push_cast; ring
          rw [hcast]; linarith [hmain]
        calc |(polyApproxCMap aY dY k (M (n, m))) w|
            ≤ ‖polyApproxCMap (α := α) (β := β) aY dY k (M (n, m))‖ := hpw_le
          _ ≤ ‖y k‖ + 1 := hnorm_M
          _ ≤ (‖polyApproxCMap (α := α) (β := β) aY dY k 0‖ + 1) + 1 := by linarith [hnorm_yk]
          _ ≤ ((↑(bound_y_k k) : ℝ) + 1) + 1 := by linarith [hnorm_p0]
          _ = (↑(bound_y_k k) : ℝ) + 2 := by ring
      -- Per-k product bounds via `perk_bound`, for X and Y.
      have hX := perk_bound (coefα (n, k)) ((x k) w)
        ((αR (Nat.pair n k, M (n, m)) : ℝ)) ((polyApproxCMap aX dX k (M (n, m))) w)
        (1 / 2 ^ (M (n, m))) ((↑(bound_αR_at_0 (n, k)) : ℝ) + 1) ((↑(bound_x_k k) : ℝ) + 2)
        hεpos (by positivity) hclose_X hαr_close hcα_bd hpXk_bd
      have hY := perk_bound (coefβ (n, k)) ((y k) w)
        ((βR (Nat.pair n k, M (n, m)) : ℝ)) ((polyApproxCMap aY dY k (M (n, m))) w)
        (1 / 2 ^ (M (n, m))) ((↑(bound_βR_at_0 (n, k)) : ℝ) + 1) ((↑(bound_y_k k) : ℝ) + 2)
        hεpos (by positivity) hclose_Y hβr_close hcβ_bd hpYk_bd
      have hstuff_cast : (stuff_per_k (n, k) : ℝ)
          = (↑(bound_x_k k) : ℝ) + ↑(bound_y_k k) + ↑(bound_αR_at_0 (n, k))
            + ↑(bound_βR_at_0 (n, k)) + 6 := by
        show ((bound_x_k k + bound_y_k k + bound_αR_at_0 (n, k) + bound_βR_at_0 (n, k) + 6 : ℕ)
            : ℝ) = (↑(bound_x_k k) : ℝ) + ↑(bound_y_k k) + ↑(bound_αR_at_0 (n, k))
              + ↑(bound_βR_at_0 (n, k)) + 6
        push_cast; ring
      calc |(coefα (n, k) * (x k) w + coefβ (n, k) * (y k) w)
              - ((αR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aX dX k (M (n, m))) w
                  + (βR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aY dY k (M (n, m))) w)|
          = |(coefα (n, k) * (x k) w
                - (αR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aX dX k (M (n, m))) w)
              + (coefβ (n, k) * (y k) w
                - (βR (Nat.pair n k, M (n, m)) : ℝ)
                  * (polyApproxCMap aY dY k (M (n, m))) w)| := by
            congr 1; ring
        _ ≤ |coefα (n, k) * (x k) w
                - (αR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aX dX k (M (n, m))) w|
            + |coefβ (n, k) * (y k) w
                - (βR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aY dY k (M (n, m))) w| :=
            abs_add_le _ _
        _ ≤ (1 / 2 ^ (M (n, m)))
              * (((↑(bound_αR_at_0 (n, k)) : ℝ) + 1) + ((↑(bound_x_k k) : ℝ) + 2))
            + (1 / 2 ^ (M (n, m)))
              * (((↑(bound_βR_at_0 (n, k)) : ℝ) + 1) + ((↑(bound_y_k k) : ℝ) + 2)) :=
            add_le_add hX hY
        _ = (1 / 2 ^ (M (n, m))) * (stuff_per_k (n, k) : ℝ) := by
            rw [hstuff_cast]; ring
    -- Final assembly: triangle ⇒ Σ-bound ⇒ close-out by M's formula.
    calc |∑ k ∈ Finset.range (d n + 1),
            ((coefα (n, k) * (x k) w + coefβ (n, k) * (y k) w)
              - ((αR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aX dX k (M (n, m))) w
                  + (βR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aY dY k (M (n, m))) w))|
        ≤ ∑ k ∈ Finset.range (d n + 1),
            |(coefα (n, k) * (x k) w + coefβ (n, k) * (y k) w)
              - ((αR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aX dX k (M (n, m))) w
                  + (βR (Nat.pair n k, M (n, m)) : ℝ) * (polyApproxCMap aY dY k (M (n, m))) w)| :=
          Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ k ∈ Finset.range (d n + 1), (1 / 2 ^ (M (n, m))) * (stuff_per_k (n, k) : ℝ) :=
          Finset.sum_le_sum hperk
      _ = (1 / 2 ^ (M (n, m))) * ∑ k ∈ Finset.range (d n + 1), (stuff_per_k (n, k) : ℝ) := by
          rw [Finset.mul_sum]
      _ ≤ (1 / 2 ^ (M (n, m))) * ((d n + 1 : ℝ) * (bound_max n : ℝ)) := by
          apply mul_le_mul_of_nonneg_left _ (by positivity)
          calc ∑ k ∈ Finset.range (d n + 1), (stuff_per_k (n, k) : ℝ)
              ≤ ∑ k ∈ Finset.range (d n + 1), (bound_max n : ℝ) := Finset.sum_le_sum hstuff_le
            _ = (d n + 1 : ℝ) * (bound_max n : ℝ) := by
                rw [Finset.sum_const, Finset.card_range, nsmul_eq_mul]; push_cast; ring
      _ ≤ 1 / 2 ^ m := by
          have hmpos : (0 : ℝ) < 2 ^ m := by positivity
          have hMpos : (0 : ℝ) < 2 ^ (M (n, m)) := by positivity
          rw [le_div_iff₀ hmpos, one_div_mul_eq_div, div_mul_eq_mul_div, div_le_one hMpos]
          have hMunfold : (2 : ℝ) ^ (M (n, m)) = 2 ^ (m + (d n + 1) + bound_max n + 2) := rfl
          rw [hMunfold]
          have hkey := closeout_nat (d n) (bound_max n) m
          calc (d n + 1 : ℝ) * (bound_max n : ℝ) * 2 ^ m
              = (((d n + 1) * bound_max n * 2 ^ m : ℕ) : ℝ) := by push_cast; ring
            _ ≤ ((2 ^ (m + (d n + 1) + bound_max n + 2) : ℕ) : ℝ) := by exact_mod_cast hkey
            _ = (2 : ℝ) ^ (m + (d n + 1) + bound_max n + 2) := by push_cast; ring

/-- **C[a,b] computability — Axiom 2 (Effective Limits).** P-R Ch. 0 Theorem 4
(quoted at `literature/papers/PourEl-Richards-chapt0.md:748`):

> "Let `f_{n k}: I^q → ℝ` be a computable double sequence of functions such
> that `f_{n k} → f_n` as `k → ∞`, uniformly in `x`, effectively in `k` and `n`.
> Then `{f_n}` is a computable sequence of functions."

Under our polynomial-form predicate (`IsComputableSeqCMap`): given a computable
double sequence `x : ℕ × ℕ → C([α, β], ℝ)` (i.e. the flatten
`fun n => x (Nat.unpair n)` is in `IsComputableSeqCMap`), an effective modulus
`e : ℕ × ℕ → ℕ` with the property `‖x (n, k) − y n‖ ≤ 1 / 2^N` whenever
`k ≥ e (n, N)`, the diagonalized witness

  `a' (n, N, j) := a (Nat.pair n (e (n, N + 1)), N + 1, j)`,
  `d' (n, N)    := d (Nat.pair n (e (n, N + 1)), N + 1)`

(where `(a, d)` is the witness pair for the flattened double sequence) gives
`polyApproxCMap a' d' n N = polyApproxCMap a d (Nat.pair n (e (n, N+1))) (N+1)`
by definitional unfolding. The norm bound then follows by triangle inequality:
`‖y n − p'_{n,N}‖ ≤ ‖y n − x (n, e (n, N+1))‖ + ‖x (n, e (n, N+1)) − p'_{n,N}‖
                  ≤ 1/2^(N+1) + 1/2^(N+1) = 1/2^N`.

Surfaced as a named, sorry-free lemma so that the blueprint's `lem:l4_cmap_axiom2`
can `\lean{}`-link directly to it without inheriting `sorryAx` from sibling
fields of `computabilityStructureCMap_of` (see `docs/PITFALLS.md §7`).

ref: `literature/papers/PourEl-Richards-chapt0.md:748` (statement),
`literature/papers/PourEl-Richards-chapt2.md:128-129` (axiom 2 = Ch. 0 Thm 4). -/
theorem isComputableSeqCMap_of_effectiveLimit :
    ∀ (x : ℕ × ℕ → C(Set.Icc α β, ℝ)) (y : ℕ → C(Set.Icc α β, ℝ)) (e : ℕ × ℕ → ℕ),
      IsComputableSeqCMap (fun n => x (Nat.unpair n)) →
      Computable e →
      (∀ n N : ℕ, ∀ k : ℕ, k ≥ e (n, N) → ‖x (n, k) - y n‖ ≤ 1 / 2 ^ N) →
      IsComputableSeqCMap y := by
  intro x y e hx he hconv
  obtain ⟨a, d, hflat_a, hd, hbnd⟩ := hx
  -- Diagonalized witness: `a'` and `d'` are obtained by evaluating `(a, d)` at
  -- the precision bumped to `N + 1` and the outer flatten-index pinned at
  -- `Nat.pair n (e (n, N + 1))`. Then `polyApproxCMap a' d' n N` is the same
  -- ContinuousMap as `polyApproxCMap a d (Nat.pair n (e (n, N+1))) (N+1)`
  -- (the underlying body is literally the same polynomial in `x.val`).
  let a' : ℕ × ℕ × ℕ → ℚ := fun nNj =>
    a (Nat.pair nNj.1 (e (nNj.1, nNj.2.1 + 1)), nNj.2.1 + 1, nNj.2.2)
  let d' : ℕ × ℕ → ℕ := fun nN =>
    d (Nat.pair nN.1 (e (nN.1, nN.2 + 1)), nN.2 + 1)
  refine ⟨a', d', ?_, ?_, ?_⟩
  · -- IsComputableSeqRat (flatten a'). Apply `isComputableSeqRat_tripleApply`
    -- with the flatten of `a` as `hf` and Computable indexers.
    -- Decoding helpers for `m : ℕ` (the flat triple index for `a'`):
    --   (Nat.unpair m).1                                 = n
    --   (Nat.unpair (Nat.unpair m).2).1                  = N
    --   (Nat.unpair (Nat.unpair m).2).2                  = j
    -- Target shape per `isComputableSeqRat_tripleApply`:
    --   `fun m => a (A m, B m, C m)` for Computable A, B, C : ℕ → ℕ
    -- where (let `mn := (Nat.unpair m).1`, `mN := (Nat.unpair (Nat.unpair m).2).1`)
    --   A m := Nat.pair mn (e (mn, mN + 1))
    --   B m := mN + 1
    --   C m := (Nat.unpair (Nat.unpair m).2).2
    have h_n : Computable (fun m : ℕ => (Nat.unpair m).1) :=
      Computable.fst.comp Computable.unpair
    have h_inner : Computable (fun m : ℕ => (Nat.unpair m).2) :=
      Computable.snd.comp Computable.unpair
    have h_N : Computable (fun m : ℕ => (Nat.unpair (Nat.unpair m).2).1) :=
      Computable.fst.comp (Computable.unpair.comp h_inner)
    have h_j : Computable (fun m : ℕ => (Nat.unpair (Nat.unpair m).2).2) :=
      Computable.snd.comp (Computable.unpair.comp h_inner)
    have h_Nsucc : Computable (fun m : ℕ => (Nat.unpair (Nat.unpair m).2).1 + 1) :=
      Computable.succ.comp h_N
    have h_e_arg : Computable (fun m : ℕ =>
        ((Nat.unpair m).1, (Nat.unpair (Nat.unpair m).2).1 + 1)) :=
      h_n.pair h_Nsucc
    have h_e : Computable (fun m : ℕ =>
        e ((Nat.unpair m).1, (Nat.unpair (Nat.unpair m).2).1 + 1)) :=
      he.comp h_e_arg
    have h_A : Computable (fun m : ℕ => Nat.pair (Nat.unpair m).1
        (e ((Nat.unpair m).1, (Nat.unpair (Nat.unpair m).2).1 + 1))) :=
      Primrec₂.natPair.to_comp.comp h_n h_e
    -- Apply the tripleApply helper. The result has the `(A m, B m, C m)`
    -- form; the let-bound `a'` unfolds to exactly that (it's a defeq).
    have key : IsComputableSeqRat (fun m : ℕ =>
        a (Nat.pair (Nat.unpair m).1
            (e ((Nat.unpair m).1, (Nat.unpair (Nat.unpair m).2).1 + 1)),
           (Nat.unpair (Nat.unpair m).2).1 + 1,
           (Nat.unpair (Nat.unpair m).2).2)) :=
      FinsetSumHelper.isComputableSeqRat_tripleApply hflat_a h_A h_Nsucc h_j
    -- key already has exactly the flatten shape of `a'`.
    exact key
  · -- Computable d'. Apply `hd` to a Computable function (n, N) →
    -- (Nat.pair n (e (n, N + 1)), N + 1).
    show Computable (fun nN : ℕ × ℕ =>
      d (Nat.pair nN.1 (e (nN.1, nN.2 + 1)), nN.2 + 1))
    have h_Nsucc : Computable (fun nN : ℕ × ℕ => nN.2 + 1) :=
      Computable.succ.comp Computable.snd
    have h_e_arg : Computable (fun nN : ℕ × ℕ => (nN.1, nN.2 + 1)) :=
      Computable.fst.pair h_Nsucc
    have h_e : Computable (fun nN : ℕ × ℕ => e (nN.1, nN.2 + 1)) :=
      he.comp h_e_arg
    have h_outer : Computable (fun nN : ℕ × ℕ =>
        Nat.pair nN.1 (e (nN.1, nN.2 + 1))) :=
      Primrec₂.natPair.to_comp.comp Computable.fst h_e
    have h_d_arg : Computable (fun nN : ℕ × ℕ =>
        (Nat.pair nN.1 (e (nN.1, nN.2 + 1)), nN.2 + 1)) :=
      h_outer.pair h_Nsucc
    exact hd.comp h_d_arg
  · -- Norm bound `‖y n − polyApproxCMap a' d' n N‖ ≤ 1 / 2^N`.
    intro n N
    -- The let-bound a', d' are designed so that the polynomial approximant
    -- equals `polyApproxCMap a d (Nat.pair n (e (n, N+1))) (N+1)`. Pin a
    -- name `m₀` to the flatten-index and `K` to the precision for clarity.
    set m₀ : ℕ := Nat.pair n (e (n, N + 1)) with hm₀
    set K : ℕ := N + 1 with hK
    -- (1) The two polynomial approximants are equal as ContinuousMaps —
    -- coefficient-by-coefficient: `a' (n, N, j) = a (m₀, K, j)`,
    -- `d' (n, N) = d (m₀, K)`. So this is `rfl`-level.
    have hpoly_eq : polyApproxCMap (α := α) (β := β) a' d' n N
        = polyApproxCMap (α := α) (β := β) a d m₀ K := rfl
    -- (2) From the convergence hypothesis at `k = e (n, N + 1) = e (n, K)`:
    -- `‖x (n, e (n, N+1)) − y n‖ ≤ 1 / 2^(N+1)`. Since `K = N + 1`, this is
    -- `1 / 2^(K-shifted-by-one)`, but stated via `hconv`'s `1 / 2^N` form.
    have hk_ge : e (n, N + 1) ≥ e (n, N + 1) := le_refl _
    have h_y_to_x : ‖x (n, e (n, N + 1)) - y n‖ ≤ 1 / 2 ^ (N + 1) :=
      hconv n (N + 1) (e (n, N + 1)) hk_ge
    -- (3) From the predicate's bound, applied at flat-index `m₀` and
    -- precision `K`: `‖x (Nat.unpair m₀) − polyApproxCMap a d m₀ K‖ ≤ 1/2^K`.
    -- `Nat.unpair m₀ = Nat.unpair (Nat.pair n (e (n, N+1))) = (n, e (n, N+1))`,
    -- so the LHS evaluates to `x (n, e (n, N+1))`.
    have h_xunp : x (Nat.unpair m₀) = x (n, e (n, N + 1)) := by
      rw [hm₀, Nat.unpair_pair]
    have h_p_to_x : ‖x (n, e (n, N + 1))
          - polyApproxCMap (α := α) (β := β) a d m₀ K‖ ≤ 1 / 2 ^ K := by
      have hb := hbnd m₀ K
      -- `hb` has surface form `(fun n => x (Nat.unpair n)) m₀ - …`; beta-reduce
      -- then rewrite via `h_xunp` to substitute the unpaired index.
      show ‖x (n, e (n, N + 1)) - polyApproxCMap (α := α) (β := β) a d m₀ K‖ ≤ 1 / 2 ^ K
      rw [← h_xunp]
      exact hb
    -- (4) Triangle inequality. With `K = N + 1` we have `1/2^K + 1/2^K = 1/2^N`.
    have h_triangle :
        ‖y n - polyApproxCMap (α := α) (β := β) a' d' n N‖
          ≤ ‖y n - x (n, e (n, N + 1))‖
            + ‖x (n, e (n, N + 1))
                - polyApproxCMap (α := α) (β := β) a' d' n N‖ := by
      have := norm_add_le
        (y n - x (n, e (n, N + 1)))
        (x (n, e (n, N + 1)) - polyApproxCMap (α := α) (β := β) a' d' n N)
      have hrew :
          (y n - x (n, e (n, N + 1)))
            + (x (n, e (n, N + 1))
                - polyApproxCMap (α := α) (β := β) a' d' n N)
          = y n - polyApproxCMap (α := α) (β := β) a' d' n N := by abel
      rw [hrew] at this
      exact this
    -- Swap `‖y n − x ...‖` for the easier `‖x ... − y n‖` (norm of negation).
    have h_yx_symm : ‖y n - x (n, e (n, N + 1))‖
        = ‖x (n, e (n, N + 1)) - y n‖ := by rw [norm_sub_rev]
    rw [hpoly_eq]
    calc ‖y n - polyApproxCMap (α := α) (β := β) a d m₀ K‖
        ≤ ‖y n - x (n, e (n, N + 1))‖
          + ‖x (n, e (n, N + 1)) - polyApproxCMap (α := α) (β := β) a d m₀ K‖ := by
            have := norm_add_le
              (y n - x (n, e (n, N + 1)))
              (x (n, e (n, N + 1)) - polyApproxCMap (α := α) (β := β) a d m₀ K)
            have hrew :
                (y n - x (n, e (n, N + 1)))
                  + (x (n, e (n, N + 1))
                      - polyApproxCMap (α := α) (β := β) a d m₀ K)
                = y n - polyApproxCMap (α := α) (β := β) a d m₀ K := by abel
            rw [hrew] at this
            exact this
      _ ≤ 1 / 2 ^ (N + 1) + 1 / 2 ^ K := by
          rw [h_yx_symm]
          exact add_le_add h_y_to_x h_p_to_x
      _ = 1 / 2 ^ N := by
          rw [hK]
          have h2pos : (0 : ℝ) < 2 ^ N := by positivity
          field_simp
          ring

set_option maxHeartbeats 1600000 in
/-- **C[a,b] computability — Axiom 3 (Norm).** P-R Ch. 0 Theorem 7 (Maximum
Values), quoted from `literature/papers/PourEl-Richards-chapt0.md:977-983`:

> "Let `Iᵍ` be a computable rectangle in `ℝᵍ`, and let `fₙ : Iᵍ → ℝ` be a
> computable sequence of functions. Then the maximum values
>   `sₙ = max{fₙ(x) : x ∈ Iᵍ}`
> form a computable sequence of real numbers."

P-R's proof (`chapt0.md:984-1012`) takes the 1-D case `[a, b]` and reads off
`sₙ` as the limit of the *partial-maximum* double sequence
`s_{n,k} = max{fₙ(a + (j/k)(b−a)) : 1 ≤ j ≤ k}`, observing:

> "Since `a`, `b` are computable reals, and since `{fₙ}` is sequentially
> computable, the double sequence `{s_{n,k}}` is computable." (P-R `chapt0:992`)

The explicit hypothesis "`a`, `b` are computable reals" in P-R's proof is
encoded here as `(hα_c : IsComputableReal α) (hβ_c : IsComputableReal β)`,
matching P-R Ch. 2:128's phrasing "for recursive reals `a`, `b`". The
rational bound `B` controls the magnitude of `α, β` but not their
approximant data; `hα_c, hβ_c` supply that approximant data (via
`IsComputableReal`'s constant-sequence form, which unfolds to a rational
double-sequence converging effectively to `α` resp. `β`).

## Signature evolution

A prior round (`l4-cmap-surface-axiom1`) surfaced this lemma with the
weaker signature `(B) (hα_le) (hβ_le)` only. That signature is provably
inadequate: take `P` undecidable Σ⁰₁, `ε := if P then 1 else 0`, `α := 0`,
`β := -ε`; then `|α|, |β| ≤ 1` but `‖f n‖ ∈ {0, 1}` depending on `P`
(via empty vs. singleton `Set.Icc α β`), so `(‖f n‖)` is not
`IsComputableSeqReal`. The added `hα_c, hβ_c` hypotheses rule this out.
Full obstruction analysis in git history at commit `a022a88`.

## Proof outline (P-R chapt0:984-1012, six moves)

Given a polynomial-approximant witness `(a, d) : (ℕ × ℕ × ℕ → ℚ) × (ℕ × ℕ → ℕ)`
for `f` (from `IsComputableSeqCMap.hf`) and rational approximant witnesses
`αApprox, βApprox : ℕ × ℕ → ℚ` for `α, β` (from `hα_c, hβ_c`):

① **Grid.** For `n, k`, pick approximant precision `m(n, k)` and form
  rational grid `x_{n, k, j} := αApprox(0, m) + (j/k) · (βApprox(0, m) − αApprox(0, m))`
  for `j = 0, …, k`.

② **Partial max.** Evaluate the polynomial approximant `pₙₖ` at each grid
  point and take the rational max:
  `sₙₖ := max_{j ≤ k} |pₙₖ(x_{n, k, j})|`.
  Closure via `IsComputableSeqRat.{max, abs}` (L1).

③ **Effective uniform continuity of `pₙₖ`.** From the polynomial
  coefficients and the bound `B`, the Lipschitz constant
  `Lip(pₙₖ) ≤ Σ_{j=1}^{d(n,k)} j |a(n,k,j)| Bʲ⁻¹` is Computable.

④ **Combined modulus.** `e(n, N) := M · L(n, N)` matching P-R's
  `chapt0:1003`, with `M ≥ ⌈β − α⌉` and `L(n, N)` the Lipschitz-derived
  per-precision modulus.

⑤ **Three-error decomposition.** `|sₙₖ − ‖f n‖| ≤ 1/2^k_poly +
  endpoint_slack + Lip(pₙₖ)/k`. Choose `k_poly, m` as Computable functions
  of `N` so total error `≤ 2⁻ᴺ` when `k ≥ e(n, N)`.

⑥ **Apply Prop 1.** `(sₙₖ)` is `IsComputableDoubleSeqRat`, `e` is
  `Computable`, the bound holds — apply
  `isComputableSeqReal_of_effectiveConvergence` from L1 §2.5 to conclude.

ref: `literature/papers/PourEl-Richards-chapt0.md:977-1012` (Theorem 7
statement and proof);
`literature/papers/PourEl-Richards-chapt0.md:246-272` (Proposition 1, applied
in step ⑥);
`literature/papers/PourEl-Richards-chapt2.md:128-129` ("axiom 3 = Ch. 0 Thm
7" plus "for recursive reals `a`, `b`"). -/
theorem isComputableSeqCMap_norm
    (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ))
    (hα_c : IsComputableReal α) (hβ_c : IsComputableReal β)
    (hαβ : α ≤ β)
    (f : ℕ → C(Set.Icc α β, ℝ)) (hf : IsComputableSeqCMap (α := α) (β := β) f) :
    IsComputableSeqReal (fun n => ‖f n‖) := by
  -- ① Destructure hypotheses to expose witnesses.
  obtain ⟨a, d, ha_seq, hd, herr⟩ := hf
  obtain ⟨αR, hαR_seq, hαR_err⟩ := hα_c
  obtain ⟨βR, hβR_seq, hβR_err⟩ := hβ_c
  obtain ⟨a_num, a_den, a_sgn, ha_num_c, ha_den_c, ha_sgn_c, ha_den_ne, ha_eq⟩ := ha_seq
  -- ② Modulus engineering. With `K_poly nN := N + 2` (polynomial precision
  -- 2⁻ᴺ⁻²), `Lip_nat nN` an ℕ-valued upper bound on the polynomial Lipschitz
  -- constant `Lip(p_{n, K_poly nN})`, `m_mod nN := Lip_nat + N + 3` controlling
  -- the endpoint-approximant precision (so `Lip · 2⁻ᵐ ≤ 2⁻ᴺ⁻²` with slack for
  -- the degenerate `α' > β'` case), and `k_grid nN := 8 · Lip_nat · (B+1) · 2^N
  -- + 1` controlling the grid spacing (so `Lip · 2(B+1) / k_grid ≤ 2⁻ᴺ⁻²`),
  -- the three errors sum to ≤ 2⁻ᴺ.
  set K_poly : ℕ × ℕ → ℕ := fun p => p.2 + 2 with hK_poly_def
  set Lip_nat : ℕ × ℕ → ℕ := fun p =>
    Nat.rec (motive := fun _ => ℕ) 0
      (fun j acc => acc + j * a_num (Nat.pair p.1 (Nat.pair (K_poly p) j))
                        * (B + 1) ^ (j - 1))
      (d (p.1, K_poly p) + 1)
    with hLip_nat_def
  set m_mod : ℕ × ℕ → ℕ := fun p => Lip_nat p + p.2 + 3 with hm_mod_def
  set k_grid : ℕ × ℕ → ℕ := fun p => 8 * Lip_nat p * (B + 1) * 2 ^ p.2 + 1
    with hk_grid_def
  -- ③ Computability of moduli.
  have hK_poly_c : Computable K_poly :=
    Computable.succ.comp (Computable.succ.comp Computable.snd)
  have hd_Kpoly : Computable (fun p : ℕ × ℕ => d (p.1, K_poly p)) :=
    hd.comp (Computable.fst.pair hK_poly_c)
  have hLip_nat_c : Computable Lip_nat := by
    -- `Lip_nat p` is `Nat.rec 0 step (d (p.1, K_poly p) + 1)`.
    have h_iter : Computable (fun p : ℕ × ℕ => d (p.1, K_poly p) + 1) :=
      Computable.succ.comp hd_Kpoly
    have h_base : Computable (fun _ : ℕ × ℕ => (0 : ℕ)) := Computable.const 0
    have h_pow_prim : Primrec₂ ((· ^ ·) : ℕ → ℕ → ℕ) :=
      Primrec₂.unpaired'.1 Nat.Primrec.pow
    have h_step : Computable₂ (fun (p : ℕ × ℕ) (jacc : ℕ × ℕ) =>
        jacc.2 + jacc.1 * a_num (Nat.pair p.1 (Nat.pair (K_poly p) jacc.1))
                       * (B + 1) ^ (jacc.1 - 1)) := by
      have h_p1 : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ => t.1.1) :=
        Computable.fst.comp Computable.fst
      have h_Kpoly_p : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ => K_poly t.1) :=
        hK_poly_c.comp Computable.fst
      have h_j : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ => t.2.1) :=
        Computable.fst.comp Computable.snd
      have h_acc : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ => t.2.2) :=
        Computable.snd.comp Computable.snd
      have h_pair_Kj : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ =>
          Nat.pair (K_poly t.1) t.2.1) :=
        Primrec₂.natPair.to_comp.comp h_Kpoly_p h_j
      have h_outer_idx : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ =>
          Nat.pair t.1.1 (Nat.pair (K_poly t.1) t.2.1)) :=
        Primrec₂.natPair.to_comp.comp h_p1 h_pair_Kj
      have h_anum_call : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ =>
          a_num (Nat.pair t.1.1 (Nat.pair (K_poly t.1) t.2.1))) :=
        ha_num_c.comp h_outer_idx
      have h_j_anum : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ =>
          t.2.1 * a_num (Nat.pair t.1.1 (Nat.pair (K_poly t.1) t.2.1))) :=
        Primrec.nat_mul.to_comp.comp h_j h_anum_call
      have h_jminus1 : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ => t.2.1 - 1) :=
        Primrec.nat_sub.to_comp.comp h_j (Computable.const 1)
      have h_B_pow : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ =>
          (B + 1) ^ (t.2.1 - 1)) :=
        h_pow_prim.to_comp.comp (Computable.const (B + 1)) h_jminus1
      have h_summand : Computable (fun t : (ℕ × ℕ) × ℕ × ℕ =>
          t.2.1 * a_num (Nat.pair t.1.1 (Nat.pair (K_poly t.1) t.2.1))
                * (B + 1) ^ (t.2.1 - 1)) :=
        Primrec.nat_mul.to_comp.comp h_j_anum h_B_pow
      exact Primrec.nat_add.to_comp.comp h_acc h_summand
    exact Computable.nat_rec h_iter h_base h_step
  have hm_mod_c : Computable m_mod := by
    show Computable (fun p : ℕ × ℕ => Lip_nat p + p.2 + 3)
    have h_sum : Computable (fun p : ℕ × ℕ => Lip_nat p + p.2) :=
      Primrec.nat_add.to_comp.comp hLip_nat_c Computable.snd
    exact Computable.succ.comp (Computable.succ.comp (Computable.succ.comp h_sum))
  have hk_grid_c : Computable k_grid := by
    show Computable (fun p : ℕ × ℕ => 8 * Lip_nat p * (B + 1) * 2 ^ p.2 + 1)
    have h_pow_prim : Primrec₂ ((· ^ ·) : ℕ → ℕ → ℕ) :=
      Primrec₂.unpaired'.1 Nat.Primrec.pow
    have h_2pow : Computable (fun p : ℕ × ℕ => 2 ^ p.2) :=
      h_pow_prim.to_comp.comp (Computable.const 2) Computable.snd
    have h_8Lip : Computable (fun p : ℕ × ℕ => 8 * Lip_nat p) :=
      Primrec.nat_mul.to_comp.comp (Computable.const 8) hLip_nat_c
    have h_8LipB : Computable (fun p : ℕ × ℕ => 8 * Lip_nat p * (B + 1)) :=
      Primrec.nat_mul.to_comp.comp h_8Lip (Computable.const (B + 1))
    have h_prod : Computable (fun p : ℕ × ℕ => 8 * Lip_nat p * (B + 1) * 2 ^ p.2) :=
      Primrec.nat_mul.to_comp.comp h_8LipB h_2pow
    exact Computable.succ.comp h_prod
  have hk_grid_pos : ∀ p, k_grid p ≠ 0 := fun p => by
    show 8 * Lip_nat p * (B + 1) * 2 ^ p.2 + 1 ≠ 0
    omega
  -- ④ Build `gridQ` (rational grid points) via PolyEvalHelper.
  -- We keep the body abstracted behind a `set`-bound symbol so subsequent
  -- equality proofs can match at the symbol level without unfolding the
  -- (very large) lambda body — see the `convert`-timeout in iter-08.
  set gridQ : ℕ → ℚ := fun p =>
      αR (0, m_mod ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)) +
      (((Nat.unpair (Nat.unpair p).2).2 : ℚ) /
        (k_grid ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1) : ℚ)) *
      (βR (0, m_mod ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)) -
       αR (0, m_mod ((Nat.unpair p).1, (Nat.unpair (Nat.unpair p).2).1)))
    with hgridQ_def
  have hgridQ_c : IsComputableSeqRat gridQ :=
    PolyEvalHelper.gridQ_isComputableSeqRat hαR_seq hβR_seq hm_mod_c hk_grid_c
      hk_grid_pos
  -- ⑤ Build `polyVal` (polynomial values at grid points) via PolyEvalHelper.
  set n_idx : ℕ → ℕ := fun p => (Nat.unpair p).1 with hn_idx_def
  set N_idx : ℕ → ℕ := fun p => (Nat.unpair (Nat.unpair p).2).1 with hN_idx_def
  set K_idx : ℕ → ℕ := fun p => K_poly (n_idx p, N_idx p) with hK_idx_def
  have hn_idx_c : Computable n_idx :=
    Computable.fst.comp Computable.unpair
  have hN_idx_c : Computable N_idx :=
    Computable.fst.comp (Computable.unpair.comp (Computable.snd.comp Computable.unpair))
  have hK_idx_c : Computable K_idx :=
    hK_poly_c.comp (hn_idx_c.pair hN_idx_c)
  have ha_seq' : IsComputableSeqRat (fun m =>
      a ((Nat.unpair m).1, (Nat.unpair (Nat.unpair m).2).1,
         (Nat.unpair (Nat.unpair m).2).2)) :=
    ⟨a_num, a_den, a_sgn, ha_num_c, ha_den_c, ha_sgn_c, ha_den_ne, ha_eq⟩
  set polyVal : ℕ → ℚ := fun p =>
      ∑ j ∈ Finset.range (d (n_idx p, K_idx p) + 1),
        a (n_idx p, K_idx p, j) * (gridQ p) ^ j
    with hpolyVal_def
  have hpolyVal_c : IsComputableSeqRat polyVal :=
    PolyEvalHelper.polyVal_isComputableSeqRat ha_seq' hd hn_idx_c hK_idx_c hgridQ_c
  -- ⑥ Absolute value (the `sNK`-style raw entry is `|polyVal p|`).
  set absPolyVal : ℕ → ℚ := fun p => |polyVal p| with habsPolyVal_def
  have habsPolyVal_c : IsComputableSeqRat absPolyVal := hpolyVal_c.abs
  -- ⑦ Reshape `absPolyVal` to a double sequence over `(M, J)` so we can apply
  -- `finsetMax_rat`. The map `σ : ℕ → ℕ` packs `(M, J) ↦ M.1 ∷ (M.2, J)`.
  set σ : ℕ → ℕ := fun N : ℕ =>
    Nat.pair (Nat.unpair (Nat.unpair N).1).1
      (Nat.pair (Nat.unpair (Nat.unpair N).1).2 (Nat.unpair N).2)
    with hσ_def
  have hσ_c : Computable σ := by
    have h_M : Computable (fun N : ℕ => (Nat.unpair N).1) :=
      Computable.fst.comp Computable.unpair
    have h_J : Computable (fun N : ℕ => (Nat.unpair N).2) :=
      Computable.snd.comp Computable.unpair
    have h_M1 : Computable (fun N : ℕ => (Nat.unpair (Nat.unpair N).1).1) :=
      Computable.fst.comp (Computable.unpair.comp h_M)
    have h_M2 : Computable (fun N : ℕ => (Nat.unpair (Nat.unpair N).1).2) :=
      Computable.snd.comp (Computable.unpair.comp h_M)
    have h_M2_J : Computable (fun N : ℕ =>
        Nat.pair (Nat.unpair (Nat.unpair N).1).2 (Nat.unpair N).2) :=
      Primrec₂.natPair.to_comp.comp h_M2 h_J
    exact Primrec₂.natPair.to_comp.comp h_M1 h_M2_J
  have habsPolyVal_σ_c : IsComputableSeqRat (fun N : ℕ => absPolyVal (σ N)) :=
    habsPolyVal_c.comp hσ_c
  -- ⑧ Define `sNK : ℕ × ℕ → ℚ` and prove `IsComputableDoubleSeqRat sNK`.
  -- Conceptually: `sNK (n, N) := max over J ∈ 0..k_grid(n, N) of
  -- |polyEval(n, K_poly(n, N), gridQ(n, N, J))|`. Concretely:
  -- `sNK (n, N) := sup' over J of absPolyVal (σ (Nat.pair (Nat.pair n N) J))`.
  set rEntry : ℕ × ℕ → ℚ :=
      fun MJ => absPolyVal (σ (Nat.pair MJ.1 MJ.2)) with hrEntry_def
  have hrEntry_double : IsComputableDoubleSeqRat rEntry := by
    -- `r (Nat.unpair N) = absPolyVal (σ (Nat.pair (Nat.unpair N).1 (Nat.unpair N).2))
    -- = absPolyVal (σ N)` by `Nat.pair_unpair`. We prove the function-level
    -- equality and rewrite, avoiding the term-explosion in `convert`.
    change IsComputableSeqRat (fun N : ℕ => rEntry (Nat.unpair N))
    have h_eq : (fun N : ℕ => rEntry (Nat.unpair N))
                = (fun N : ℕ => absPolyVal (σ N)) := by
      funext N
      show absPolyVal (σ (Nat.pair (Nat.unpair N).1 (Nat.unpair N).2))
           = absPolyVal (σ N)
      rw [Nat.pair_unpair]
    rw [h_eq]
    exact habsPolyVal_σ_c
  have hk_grid_unpair_c : Computable (fun M : ℕ => k_grid (Nat.unpair M)) :=
    hk_grid_c.comp Computable.unpair
  have hsNK_flat : IsComputableSeqRat (fun M : ℕ =>
      (Finset.range (k_grid (Nat.unpair M) + 1)).sup'
        Finset.nonempty_range_add_one (fun J => rEntry (M, J))) :=
    FinsetMaxHelper.finsetMax_rat hrEntry_double hk_grid_unpair_c
  set sNK : ℕ × ℕ → ℚ := fun nN =>
      (Finset.range (k_grid nN + 1)).sup' Finset.nonempty_range_add_one
        (fun J => rEntry (Nat.pair nN.1 nN.2, J))
    with hsNK_def
  have hsNK_double : IsComputableDoubleSeqRat sNK := by
    change IsComputableSeqRat (fun M : ℕ => sNK (Nat.unpair M))
    have h_eq : (fun M : ℕ => sNK (Nat.unpair M))
                = (fun M : ℕ => (Finset.range (k_grid (Nat.unpair M) + 1)).sup'
                    Finset.nonempty_range_add_one (fun J => rEntry (M, J))) := by
      funext M
      show (Finset.range (k_grid (Nat.unpair M) + 1)).sup'
            Finset.nonempty_range_add_one
              (fun J => rEntry (Nat.pair (Nat.unpair M).1 (Nat.unpair M).2, J))
           = (Finset.range (k_grid (Nat.unpair M) + 1)).sup'
            Finset.nonempty_range_add_one (fun J => rEntry (M, J))
      rw [Nat.pair_unpair]
    rw [h_eq]
    exact hsNK_flat
  -- ⑨ Apply Prop 1 with `e (n, N) := N` (`Computable.snd`).
  refine isComputableSeqReal_of_effectiveConvergence (r := sNK) hsNK_double
    (e := fun p => p.2) Computable.snd ?_
  -- ⑩ Three-error bound (analytic core, Stage 3).
  -- High-level structure: with `e (n, N) := N`, the conclusion
  -- `k ≥ N → |sNK (n, k) - ‖f n‖| ≤ 1/2^N` factors via the cleaner
  -- `|sNK (n, k) - ‖f n‖| ≤ 1/2^k`, then `1/2^k ≤ 1/2^N` by monotonicity.
  -- The core inequality decomposes:
  -- (a) polynomial approx: `|‖p‖ - ‖f n‖| ≤ 1/2^K` via `herr` (`K := k + 2`).
  -- (b) sNK ≈ ‖p‖:         `|sNK - ‖p‖| ≤ 2/2^K` via Lipschitz + grid bounds.
  -- Sum: 3/2^K = 3/2^(k+2) = 3/(4·2^k) ≤ 1/2^k. ✓
  intro n N k hkN
  -- Reduce to the `1/2^k`-bound, then use monotonicity.
  suffices h_core : |((sNK (n, k) : ℝ)) - ‖f n‖| ≤ 1 / 2 ^ k by
    apply h_core.trans
    apply one_div_le_one_div_of_le
    · positivity
    · exact pow_le_pow_right₀ (by norm_num : (1:ℝ) ≤ 2) hkN
  -- ⑩.a Set up local constants. `K := k + 2 = K_poly (n, k)`,
  -- `p := polyApproxCMap a d n K` (the K-th polynomial approximant of f n).
  set K : ℕ := k + 2 with hK_eq
  set p : C(Set.Icc α β, ℝ) := polyApproxCMap (α := α) (β := β) a d n K
    with hp_eq
  -- ⑩.b Polynomial-approximation error: `|‖p‖ - ‖f n‖| ≤ 1/2^K`.
  have h_a : |‖p‖ - ‖f n‖| ≤ 1 / 2 ^ K := by
    calc |‖p‖ - ‖f n‖|
        ≤ ‖p - f n‖ := abs_norm_sub_norm_le _ _
      _ = ‖f n - p‖ := norm_sub_rev _ _
      _ ≤ 1 / 2 ^ K := herr n K
  -- ⑩.c sNK ≈ ‖p‖ (the analytic Lipschitz + grid argument).
  -- Decomposition: (b1) `sNK ≤ ‖p‖ + Lip · 2⁻ᵐ ≤ ‖p‖ + 1/2^K`.
  --                (b2) `‖p‖ ≤ sNK + Lip · ((B+1)/k_grid + 2⁻ᵐ) ≤ sNK + 2/2^K`.
  -- Hence `|sNK - ‖p‖| ≤ 2/2^K`. The Lipschitz argument uses
  -- `polyEval_lipschitz_real` at `C := B + 1` (so it covers grid points which
  -- lie in `[α − 2⁻ᵐ, β + 2⁻ᵐ] ⊆ [-(B+1), B+1]`).
  have h_b : |((sNK (n, k) : ℝ)) - ‖p‖| ≤ 2 / 2 ^ K := by
    -- Local naming.
    set kg : ℕ := k_grid (n, k) with hkg_eq
    set mm : ℕ := m_mod (n, k) with hmm_eq
    set Lip_nℕ : ℕ := Lip_nat (n, k) with hLip_n_eq
    have hkg_form : kg = 8 * Lip_nℕ * (B + 1) * 2 ^ k + 1 := rfl
    have hmm_form : mm = Lip_nℕ + k + 3 := rfl
    -- Endpoint rational approximants as ℝ.
    set α' : ℝ := ((αR (0, mm) : ℚ) : ℝ) with hα'_eq
    set β' : ℝ := ((βR (0, mm) : ℚ) : ℝ) with hβ'_eq
    -- Closeness of approximants.
    have h_2m_pos : (0 : ℝ) < 2 ^ mm := by positivity
    have h_2m_le_one : (1 : ℝ) / 2 ^ mm ≤ 1 := by
      rw [div_le_one h_2m_pos]
      exact one_le_pow₀ (by norm_num : (1:ℝ) ≤ 2)
    have hα'_close : |α' - α| ≤ 1 / 2 ^ mm := by
      simpa using hαR_err 0 mm
    have hβ'_close : |β' - β| ≤ 1 / 2 ^ mm := by
      simpa using hβR_err 0 mm
    -- α', β' bounded by B + 1.
    have h_α'_bound : |α'| ≤ (B : ℝ) + 1 := by
      calc |α'|
          = |α + (α' - α)| := by congr 1; ring
        _ ≤ |α| + |α' - α| := abs_add_le _ _
        _ ≤ (B : ℝ) + 1 := by linarith [hα_le, hα'_close, h_2m_le_one]
    have h_β'_bound : |β'| ≤ (B : ℝ) + 1 := by
      calc |β'|
          = |β + (β' - β)| := by congr 1; ring
        _ ≤ |β| + |β' - β| := abs_add_le _ _
        _ ≤ (B : ℝ) + 1 := by linarith [hβ_le, hβ'_close, h_2m_le_one]
    -- kg positivity.
    have h_kg_pos : 0 < kg := by show 0 < 8 * Lip_nℕ * (B + 1) * 2 ^ k + 1; omega
    have h_kg_real_pos : (0 : ℝ) < (kg : ℝ) := by exact_mod_cast h_kg_pos
    -- Grid point as ℝ: `xQ J := α' + (J/kg)·(β' - α')`.
    -- Stays in the convex hull of {α', β'}, hence has `|·| ≤ B + 1`.
    have h_xQ_bound : ∀ J : ℕ, J ≤ kg →
        |α' + (J : ℝ) / (kg : ℝ) * (β' - α')| ≤ (B : ℝ) + 1 := by
      intro J hJ
      have h_J_real_nn : (0 : ℝ) ≤ (J : ℝ) := Nat.cast_nonneg _
      have h_J_le_kg : (J : ℝ) ≤ (kg : ℝ) := by exact_mod_cast hJ
      have h_ratio_nn : (0 : ℝ) ≤ (J : ℝ) / (kg : ℝ) :=
        div_nonneg h_J_real_nn h_kg_real_pos.le
      have h_ratio_le_one : (J : ℝ) / (kg : ℝ) ≤ 1 := by
        rw [div_le_one h_kg_real_pos]
        exact h_J_le_kg
      -- xQ J is a convex combination: `(1 − J/kg)·α' + (J/kg)·β'`.
      have hxQ_eq : α' + (J : ℝ) / (kg : ℝ) * (β' - α')
          = (1 - (J : ℝ) / (kg : ℝ)) * α' + ((J : ℝ) / (kg : ℝ)) * β' := by ring
      rw [hxQ_eq]
      calc |(1 - (J : ℝ) / (kg : ℝ)) * α' + ((J : ℝ) / (kg : ℝ)) * β'|
          ≤ |(1 - (J : ℝ) / (kg : ℝ)) * α'| + |((J : ℝ) / (kg : ℝ)) * β'| :=
            abs_add_le _ _
        _ = (1 - (J : ℝ) / (kg : ℝ)) * |α'| + ((J : ℝ) / (kg : ℝ)) * |β'| := by
            rw [abs_mul, abs_mul]
            congr 1
            · rw [abs_of_nonneg (by linarith)]
            · rw [abs_of_nonneg h_ratio_nn]
        _ ≤ (1 - (J : ℝ) / (kg : ℝ)) * ((B : ℝ) + 1)
            + ((J : ℝ) / (kg : ℝ)) * ((B : ℝ) + 1) := by
            apply add_le_add
            · exact mul_le_mul_of_nonneg_left h_α'_bound (by linarith)
            · exact mul_le_mul_of_nonneg_left h_β'_bound h_ratio_nn
        _ = (B : ℝ) + 1 := by ring
    -- ⑩.c.1 Symbol for the real-line grid points.
    set xQ : ℕ → ℝ := fun J => α' + (J : ℝ) / (kg : ℝ) * (β' - α') with hxQ_def
    have h_xQ_bnd : ∀ J : ℕ, J ≤ kg → |xQ J| ≤ (B : ℝ) + 1 := h_xQ_bound
    -- ⑩.c.2 Padded-interval bounds. xQ J lives in [min α' β', max α' β'] ⊆
    -- [α - 1/2^mm, β + 1/2^mm] using `hαβ`, `hα'_close`, `hβ'_close`.
    have h_min_αβ' : α - 1 / 2 ^ mm ≤ min α' β' := by
      rcases le_or_gt α' β' with h | h
      · rw [min_eq_left h]; linarith [(abs_le.mp hα'_close).1]
      · rw [min_eq_right h.le]; linarith [(abs_le.mp hβ'_close).1, hαβ]
    have h_max_αβ' : max α' β' ≤ β + 1 / 2 ^ mm := by
      rcases le_or_gt α' β' with h | h
      · rw [max_eq_right h]; linarith [(abs_le.mp hβ'_close).2]
      · rw [max_eq_left h.le]; linarith [(abs_le.mp hα'_close).2, hαβ]
    have h_xQ_in_padded : ∀ J : ℕ, J ≤ kg →
        α - 1 / 2 ^ mm ≤ xQ J ∧ xQ J ≤ β + 1 / 2 ^ mm := by
      intro J hJ
      have h_J_nn : (0 : ℝ) ≤ (J : ℝ) := Nat.cast_nonneg _
      have h_J_le : (J : ℝ) ≤ (kg : ℝ) := by exact_mod_cast hJ
      have h_t_nn : (0 : ℝ) ≤ (J : ℝ) / (kg : ℝ) := div_nonneg h_J_nn h_kg_real_pos.le
      have h_t_le_one : (J : ℝ) / (kg : ℝ) ≤ 1 := by
        rw [div_le_one h_kg_real_pos]; exact h_J_le
      have hxQ_conv : xQ J
          = (1 - (J : ℝ) / (kg : ℝ)) * α' + ((J : ℝ) / (kg : ℝ)) * β' := by
        show α' + (J : ℝ) / (kg : ℝ) * (β' - α') = _
        ring
      have h_min_le : min α' β' ≤ xQ J := by
        rw [hxQ_conv]
        have eq1 : min α' β'
            = (1 - (J : ℝ) / (kg : ℝ)) * (min α' β')
              + ((J : ℝ) / (kg : ℝ)) * (min α' β') := by ring
        rw [eq1]
        apply add_le_add
        · exact mul_le_mul_of_nonneg_left (min_le_left _ _) (by linarith)
        · exact mul_le_mul_of_nonneg_left (min_le_right _ _) h_t_nn
      have h_le_max : xQ J ≤ max α' β' := by
        rw [hxQ_conv]
        have eq2 : max α' β'
            = (1 - (J : ℝ) / (kg : ℝ)) * (max α' β')
              + ((J : ℝ) / (kg : ℝ)) * (max α' β') := by ring
        rw [eq2]
        apply add_le_add
        · exact mul_le_mul_of_nonneg_left (le_max_left _ _) (by linarith)
        · exact mul_le_mul_of_nonneg_left (le_max_right _ _) h_t_nn
      exact ⟨by linarith [h_min_αβ'], by linarith [h_max_αβ']⟩
    -- ⑩.c.3 Clamping bound via `Set.projIcc`. Three-case split on xQ J vs [α, β].
    have h_clamp_close : ∀ J : ℕ, J ≤ kg →
        |xQ J - (Set.projIcc α β hαβ (xQ J)).val| ≤ 1 / 2 ^ mm := by
      intro J hJ
      obtain ⟨h_xQ_lo, h_xQ_hi⟩ := h_xQ_in_padded J hJ
      have h_2m_inv_nn : (0 : ℝ) ≤ 1 / 2 ^ mm := by positivity
      by_cases h1 : xQ J < α
      · have h_eq : (Set.projIcc α β hαβ (xQ J)).val = α := by
          rw [Set.coe_projIcc, max_eq_left]
          calc min β (xQ J) ≤ xQ J := min_le_right _ _
            _ ≤ α := h1.le
        rw [h_eq, abs_of_neg (by linarith)]; linarith
      · push_neg at h1
        by_cases h2 : β < xQ J
        · have h_eq : (Set.projIcc α β hαβ (xQ J)).val = β := by
            rw [Set.coe_projIcc, min_eq_left h2.le, max_eq_right hαβ]
          rw [h_eq, abs_of_pos (by linarith)]; linarith
        · push_neg at h2
          have h_eq : (Set.projIcc α β hαβ (xQ J)).val = xQ J := by
            rw [Set.coe_projIcc, min_eq_right h2, max_eq_right h1]
          rw [h_eq, sub_self, abs_zero]; exact h_2m_inv_nn
    -- ⑩.c.4 Cast/unfold of `rEntry` to the polynomial expression at `xQ J`.
    -- (rEntry (Nat.pair n k, J) : ℝ) = |∑ j (a (n, K, j) : ℝ) · (xQ J)^j|.
    have h_rEntry_eq : ∀ J : ℕ,
        ((rEntry (Nat.pair n k, J) : ℚ) : ℝ)
          = |∑ j ∈ Finset.range (d (n, K) + 1),
              (a (n, K, j) : ℝ) * (xQ J) ^ j| := by
      intro J
      have hσ_app : σ (Nat.pair (Nat.pair n k) J)
          = Nat.pair n (Nat.pair k J) := by
        show Nat.pair (Nat.unpair (Nat.unpair (Nat.pair (Nat.pair n k) J)).1).1
                      (Nat.pair (Nat.unpair (Nat.unpair (Nat.pair (Nat.pair n k) J)).1).2
                                (Nat.unpair (Nat.pair (Nat.pair n k) J)).2)
            = _
        simp only [Nat.unpair_pair]
      have hn_eq : n_idx (Nat.pair n (Nat.pair k J)) = n := by
        show (Nat.unpair (Nat.pair n (Nat.pair k J))).1 = n
        simp [Nat.unpair_pair]
      have hN_eq : N_idx (Nat.pair n (Nat.pair k J)) = k := by
        show (Nat.unpair (Nat.unpair (Nat.pair n (Nat.pair k J))).2).1 = k
        simp [Nat.unpair_pair]
      have hKidx_eq : K_idx (Nat.pair n (Nat.pair k J)) = K := by
        show K_poly (n_idx (Nat.pair n (Nat.pair k J)),
                     N_idx (Nat.pair n (Nat.pair k J))) = K
        rw [hn_eq, hN_eq]
      have h_J_extract : (Nat.unpair (Nat.unpair
            (Nat.pair n (Nat.pair k J))).2).2 = J := by simp [Nat.unpair_pair]
      have h_mmod_eq : m_mod (n_idx (Nat.pair n (Nat.pair k J)),
                              N_idx (Nat.pair n (Nat.pair k J))) = mm := by
        rw [hn_eq, hN_eq]
      have h_kgrid_eq : k_grid (n_idx (Nat.pair n (Nat.pair k J)),
                                N_idx (Nat.pair n (Nat.pair k J))) = kg := by
        rw [hn_eq, hN_eq]
      have h_gridQ_eq : ((gridQ (Nat.pair n (Nat.pair k J)) : ℚ) : ℝ) = xQ J := by
        show ((αR (0, m_mod (n_idx _, N_idx _))
              + ((Nat.unpair (Nat.unpair (Nat.pair n (Nat.pair k J))).2).2 : ℚ)
                / (k_grid (n_idx _, N_idx _) : ℚ)
              * (βR (0, m_mod (n_idx _, N_idx _)) - αR (0, m_mod (n_idx _, N_idx _)))
              : ℚ) : ℝ) = _
        rw [h_mmod_eq, h_kgrid_eq, h_J_extract]
        push_cast
        show ((αR (0, mm) : ℚ) : ℝ) + (J : ℝ) / (kg : ℝ)
              * (((βR (0, mm) : ℚ) : ℝ) - ((αR (0, mm) : ℚ) : ℝ)) = xQ J
        rw [← hα'_eq, ← hβ'_eq]
      show ((absPolyVal (σ (Nat.pair (Nat.pair n k) J)) : ℚ) : ℝ) = _
      rw [hσ_app]
      show ((|polyVal (Nat.pair n (Nat.pair k J))| : ℚ) : ℝ) = _
      rw [Rat.cast_abs]
      congr 1
      show ((∑ j ∈ Finset.range (d (n_idx _, K_idx _) + 1),
              a (n_idx _, K_idx _, j) * gridQ _ ^ j : ℚ) : ℝ) = _
      rw [hn_eq, hKidx_eq]
      push_cast
      refine Finset.sum_congr rfl ?_
      intro j _
      rw [← h_gridQ_eq]
    -- ⑩.c.5 Cast distribution over `Finset.sup'` via `Rat.cast_max`.
    have h_sNK_cast :
        ((sNK (n, k) : ℚ) : ℝ)
          = (Finset.range (kg + 1)).sup' Finset.nonempty_range_add_one
              (fun J => ((rEntry (Nat.pair n k, J) : ℚ) : ℝ)) := by
      show ((((Finset.range (kg + 1)).sup' Finset.nonempty_range_add_one
              (fun J => rEntry (Nat.pair n k, J)) : ℚ) : ℝ)) = _
      exact Finset.apply_sup'_eq_sup'_comp Finset.nonempty_range_add_one
        (fun q : ℚ => (q : ℝ)) (fun x y => Rat.cast_max x y)
    -- ⑩.c.6 Lip_nℕ as a `Finset.range` sum (closed form of the Nat.rec).
    have h_Lip_natrec : ∀ N : ℕ,
        Nat.rec (motive := fun _ => ℕ) 0
          (fun j acc => acc + j * a_num (Nat.pair n (Nat.pair K j))
                            * (B + 1) ^ (j - 1))
          N
        = ∑ j ∈ Finset.range N,
            j * a_num (Nat.pair n (Nat.pair K j)) * (B + 1) ^ (j - 1) := by
      intro N
      induction N with
      | zero => simp
      | succ m IH =>
        show (Nat.rec (motive := fun _ => ℕ) 0 _ m
              + m * a_num (Nat.pair n (Nat.pair K m)) * (B + 1) ^ (m - 1) : ℕ) = _
        rw [IH, Finset.sum_range_succ]
    have h_Lip_nℕ_eq : (Lip_nℕ : ℕ)
        = ∑ j ∈ Finset.range (d (n, K) + 1),
            j * a_num (Nat.pair n (Nat.pair K j)) * (B + 1) ^ (j - 1) :=
      h_Lip_natrec (d (n, K) + 1)
    -- ⑩.c.7 Per-coefficient bound from `ha_eq`.
    have h_a_bnd : ∀ j : ℕ,
        |((a (n, K, j)) : ℝ)|
          ≤ ((a_num (Nat.pair n (Nat.pair K j)) : ℕ) : ℝ) := by
      intro j
      have h_a_q_eq : a (n, K, j)
          = (-1 : ℚ) ^ (a_sgn (Nat.pair n (Nat.pair K j)))
            * ((a_num (Nat.pair n (Nat.pair K j)) : ℚ)
               / (a_den (Nat.pair n (Nat.pair K j)) : ℚ)) := by
        have h := ha_eq (Nat.pair n (Nat.pair K j))
        simpa [Nat.unpair_pair] using h
      have h_den_ne : a_den (Nat.pair n (Nat.pair K j)) ≠ 0 :=
        ha_den_ne (Nat.pair n (Nat.pair K j))
      have h_den_pos_R : (0 : ℝ) < (a_den (Nat.pair n (Nat.pair K j)) : ℝ) := by
        have : (0 : ℕ) < a_den (Nat.pair n (Nat.pair K j)) :=
          Nat.pos_of_ne_zero h_den_ne
        exact_mod_cast this
      have h_den_ge_one_R : (1 : ℝ) ≤ (a_den (Nat.pair n (Nat.pair K j)) : ℝ) := by
        exact_mod_cast Nat.one_le_iff_ne_zero.mpr h_den_ne
      have h_anum_nn_R : (0 : ℝ) ≤ ((a_num (Nat.pair n (Nat.pair K j)) : ℕ) : ℝ) :=
        Nat.cast_nonneg _
      show |((a (n, K, j) : ℚ) : ℝ)| ≤ _
      rw [h_a_q_eq]
      push_cast
      rw [abs_mul, abs_pow]
      have h_neg1 : |(-1 : ℝ)| = 1 := by norm_num
      rw [h_neg1, one_pow, one_mul, abs_div]
      rw [abs_of_nonneg h_anum_nn_R, abs_of_pos h_den_pos_R]
      exact div_le_self h_anum_nn_R h_den_ge_one_R
    -- ⑩.c.8 Polynomial-Lipschitz constant ≤ Lip_nℕ (as ℝ).
    have h_Lip_real_le_nat :
        (∑ j ∈ Finset.range (d (n, K) + 1),
            (j : ℝ) * |((a (n, K, j)) : ℝ)| * ((B : ℝ) + 1) ^ (j - 1))
          ≤ ((Lip_nℕ : ℕ) : ℝ) := by
      rw [h_Lip_nℕ_eq]
      push_cast
      apply Finset.sum_le_sum
      intro j _
      have h_pow_nn : (0 : ℝ) ≤ ((B : ℝ) + 1) ^ (j - 1) := by positivity
      have h_j_nn : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg _
      apply mul_le_mul_of_nonneg_right _ h_pow_nn
      exact mul_le_mul_of_nonneg_left (h_a_bnd j) h_j_nn
    -- ⑩.c.9 Arithmetic: Lip_nℕ · 1/2^mm ≤ 1/2^K.
    have h_Lip_2m_le_K : ((Lip_nℕ : ℕ) : ℝ) * (1 / 2 ^ mm) ≤ 1 / 2 ^ K := by
      have h_2mm_pos : (0 : ℝ) < (2 : ℝ) ^ mm := by positivity
      have h_2K_pos : (0 : ℝ) < (2 : ℝ) ^ K := by positivity
      have h_Lip_lt : (Lip_nℕ : ℕ) < 2 ^ Lip_nℕ := Nat.lt_two_pow_self
      have h_Lip_le_2pow : ((Lip_nℕ : ℕ) : ℝ) ≤ (2 : ℝ) ^ Lip_nℕ := by
        have h1 : ((Lip_nℕ : ℕ) : ℝ) ≤ ((2 ^ Lip_nℕ : ℕ) : ℝ) := by
          exact_mod_cast h_Lip_lt.le
        have h2 : ((2 ^ Lip_nℕ : ℕ) : ℝ) = (2 : ℝ) ^ Lip_nℕ := by push_cast; ring
        linarith
      rw [mul_one_div, div_le_div_iff₀ h_2mm_pos h_2K_pos]
      -- Goal: Lip_nℕ · 2^K ≤ 1 · 2^mm = 2^mm.
      rw [one_mul]
      have h_pow_eq : (2 : ℝ) ^ mm = (2 : ℝ) ^ Lip_nℕ * (2 : ℝ) ^ k * 8 := by
        rw [hmm_form]; ring
      have h_2K_form : (2 : ℝ) ^ K = (2 : ℝ) ^ k * 4 := by rw [hK_eq]; ring
      rw [h_pow_eq, h_2K_form]
      have h_2k_pos : (0 : ℝ) < (2 : ℝ) ^ k := by positivity
      have h_2Lip_pos : (0 : ℝ) < (2 : ℝ) ^ Lip_nℕ := by positivity
      nlinarith [h_Lip_le_2pow, h_2k_pos, h_2Lip_pos]
    -- ⑩.c.10 Arithmetic: Lip_nℕ · 2(B+1)/kg ≤ 1/2^K.
    have h_Lip_BpKg_bound :
        ((Lip_nℕ : ℕ) : ℝ) * (2 * ((B : ℝ) + 1) / (kg : ℝ)) ≤ 1 / 2 ^ K := by
      have h_2K_pos : (0 : ℝ) < (2 : ℝ) ^ K := by positivity
      have h_kg_pos := h_kg_real_pos
      have h_kg_lower : 8 * ((Lip_nℕ : ℕ) : ℝ) * ((B : ℝ) + 1) * 2 ^ k ≤ (kg : ℝ) := by
        have h_eq : (kg : ℝ) = 8 * ((Lip_nℕ : ℕ) : ℝ) * ((B : ℝ) + 1) * 2 ^ k + 1 := by
          have h := hkg_form
          push_cast [h]; ring
        linarith
      rw [show ((Lip_nℕ : ℕ) : ℝ) * (2 * ((B : ℝ) + 1) / (kg : ℝ))
            = (((Lip_nℕ : ℕ) : ℝ) * 2 * ((B : ℝ) + 1)) / (kg : ℝ) from by ring]
      rw [div_le_div_iff₀ h_kg_pos h_2K_pos, one_mul]
      have h_2K_form : (2 : ℝ) ^ K = 4 * 2 ^ k := by rw [hK_eq]; ring
      rw [h_2K_form]
      have h_2k_pos : (0 : ℝ) < (2 : ℝ) ^ k := by positivity
      have h_Lip_nn : (0 : ℝ) ≤ ((Lip_nℕ : ℕ) : ℝ) := Nat.cast_nonneg _
      have h_B_nn : (0 : ℝ) ≤ (B : ℝ) := Nat.cast_nonneg _
      nlinarith [h_kg_lower, h_2k_pos, h_Lip_nn, h_B_nn]
    -- ⑩.c.11 Combined-error bound: Lip_nℕ · (1/2^mm) + Lip_nℕ · 2(B+1)/kg ≤ 2/2^K.
    have h_combined_bound :
        ((Lip_nℕ : ℕ) : ℝ) * (1 / 2 ^ mm)
          + ((Lip_nℕ : ℕ) : ℝ) * (2 * ((B : ℝ) + 1) / (kg : ℝ))
          ≤ 2 / 2 ^ K := by
      have h1 := h_Lip_2m_le_K
      have h2 := h_Lip_BpKg_bound
      have h_2K_pos : (0 : ℝ) < (2 : ℝ) ^ K := by positivity
      have : (1 : ℝ) / 2 ^ K + 1 / 2 ^ K = 2 / 2 ^ K := by ring
      linarith
    -- ⑩.c.12 Direction (b1): `(sNK : ℝ) ≤ ‖p‖ + 1/2^K` via clamping.
    -- For each grid index J ≤ kg, the polynomial value at xQ_J differs from the
    -- value at the clamped point `projIcc α β (xQ_J)` by ≤ Lip · 1/2^mm ≤ 1/2^K;
    -- the latter is bounded by ‖p‖ via `ContinuousMap.norm_coe_le_norm`.
    have h_b1 : ((sNK (n, k) : ℚ) : ℝ) ≤ ‖p‖ + 1 / 2 ^ K := by
      rw [h_sNK_cast]
      apply Finset.sup'_le
      intro J hJ_mem
      have hJ : J ≤ kg := Nat.le_of_lt_succ (Finset.mem_range.mp hJ_mem)
      rw [h_rEntry_eq J]
      set xcJ : Set.Icc α β := Set.projIcc α β hαβ (xQ J) with hxcJ_def
      have h_xcJ_abs : |xcJ.val| ≤ (B : ℝ) := by
        have hx := xcJ.2; rw [Set.mem_Icc] at hx
        rw [abs_le]; refine ⟨?_, ?_⟩
        · linarith [(abs_le.mp hα_le).1, hx.1]
        · linarith [(abs_le.mp hβ_le).2, hx.2]
      have h_xcJ_abs_BP1 : |xcJ.val| ≤ (B : ℝ) + 1 := by linarith
      have h_xQJ_abs_BP1 : |xQ J| ≤ (B : ℝ) + 1 := h_xQ_bnd J hJ
      have h_clamp : |xQ J - xcJ.val| ≤ 1 / 2 ^ mm := h_clamp_close J hJ
      have h_p_at_xcJ :
          (polyApproxCMap (α := α) (β := β) a d n K) xcJ
            = ∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * xcJ.val ^ j :=
        polyApproxCMap_eval a d n K xcJ
      have h_norm_at_xcJ :
          |(polyApproxCMap (α := α) (β := β) a d n K) xcJ| ≤ ‖p‖ := by
        rw [hp_eq]
        have := ContinuousMap.norm_coe_le_norm
          (polyApproxCMap (α := α) (β := β) a d n K) xcJ
        rwa [Real.norm_eq_abs] at this
      have h_lip := polyEval_lipschitz_real a d n K (B + 1)
        (xQ J) xcJ.val
        (show |xQ J| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_xQJ_abs_BP1)
        (show |xcJ.val| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_xcJ_abs_BP1)
      push_cast at h_lip
      have h_xQ_dist_nn : 0 ≤ |xQ J - xcJ.val| := abs_nonneg _
      have h_lip_bnd :
          |∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * (xQ J) ^ j
            - ∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * xcJ.val ^ j|
            ≤ 1 / 2 ^ K := by
        calc |∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * (xQ J) ^ j
                - ∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * xcJ.val ^ j|
            ≤ (∑ j ∈ Finset.range (d (n, K) + 1),
                (j : ℝ) * |((a (n, K, j)) : ℝ)| * ((B : ℝ) + 1) ^ (j - 1))
              * |xQ J - xcJ.val| := h_lip
          _ ≤ ((Lip_nℕ : ℕ) : ℝ) * |xQ J - xcJ.val| := by
              exact mul_le_mul_of_nonneg_right h_Lip_real_le_nat h_xQ_dist_nn
          _ ≤ ((Lip_nℕ : ℕ) : ℝ) * (1 / 2 ^ mm) := by
              apply mul_le_mul_of_nonneg_left h_clamp
              exact Nat.cast_nonneg _
          _ ≤ 1 / 2 ^ K := h_Lip_2m_le_K
      have h_sum_at_xcJ_le_p :
          |∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * xcJ.val ^ j|
            ≤ ‖p‖ := by
        rw [← h_p_at_xcJ]; exact h_norm_at_xcJ
      calc |∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * (xQ J) ^ j|
          = |(∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * xcJ.val ^ j)
              + ((∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * (xQ J) ^ j)
                 - (∑ j ∈ Finset.range (d (n, K) + 1),
                       (a (n, K, j) : ℝ) * xcJ.val ^ j))| := by congr 1; ring
        _ ≤ |∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * xcJ.val ^ j|
              + |(∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * (xQ J) ^ j)
                 - (∑ j ∈ Finset.range (d (n, K) + 1),
                       (a (n, K, j) : ℝ) * xcJ.val ^ j)| := abs_add_le _ _
        _ ≤ ‖p‖ + 1 / 2 ^ K := add_le_add h_sum_at_xcJ_le_p h_lip_bnd
    -- ⑩.c.13 Direction (b2): `‖p‖ ≤ (sNK : ℝ) + 2/2^K` via covering.
    -- Apply `ContinuousMap.norm_le` to reduce to a per-point bound on `|p x|`.
    -- For each `x : Set.Icc α β`, construct `Jstar ≤ kg` such that
    -- `|x.val - xQ Jstar|` is small enough that `polyEval_lipschitz_real` gives
    -- a 2/2^K bound. Two subcases: `α' < β'` (floor-cover) and `α' ≥ β'`
    -- (degenerate, with midpoint case-split on x.val).
    have h_b2 : ‖p‖ ≤ ((sNK (n, k) : ℚ) : ℝ) + 2 / 2 ^ K := by
      have h_sNK_nn : (0 : ℝ) ≤ ((sNK (n, k) : ℚ) : ℝ) := by
        rw [h_sNK_cast]
        have h_0_mem : 0 ∈ Finset.range (kg + 1) := Finset.mem_range.mpr (by omega)
        have h_rEntry_0_nn : (0 : ℝ) ≤ ((rEntry (Nat.pair n k, 0) : ℚ) : ℝ) := by
          rw [h_rEntry_eq 0]; exact abs_nonneg _
        rw [Finset.le_sup'_iff]
        exact ⟨0, h_0_mem, h_rEntry_0_nn⟩
      have h_rhs_nn : (0 : ℝ) ≤ ((sNK (n, k) : ℚ) : ℝ) + 2 / 2 ^ K := by
        have h_2_2K_nn : (0 : ℝ) ≤ 2 / 2 ^ K := by positivity
        linarith
      rw [hp_eq, ContinuousMap.norm_le _ h_rhs_nn]
      intro x
      rw [Real.norm_eq_abs]
      have h_p_eval : (polyApproxCMap (α := α) (β := β) a d n K) x
          = ∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * x.val ^ j :=
        polyApproxCMap_eval a d n K x
      rw [h_p_eval]
      have h_x_abs_BP1 : |x.val| ≤ (B : ℝ) + 1 := by
        have hx_mem := x.2; rw [Set.mem_Icc] at hx_mem
        rw [abs_le]; refine ⟨?_, ?_⟩
        · linarith [(abs_le.mp hα_le).1]
        · linarith [(abs_le.mp hβ_le).2]
      -- The proof closes once we exhibit `Jstar ≤ kg` with a Lipschitz-bounded
      -- distance, after which the triangle-inequality + sup' chain finishes.
      suffices h_cover : ∃ Jstar : ℕ, Jstar ≤ kg ∧
          |(∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * x.val ^ j)
            - (∑ j ∈ Finset.range (d (n, K) + 1),
                  (a (n, K, j) : ℝ) * (xQ Jstar) ^ j)|
            ≤ 2 / 2 ^ K by
        obtain ⟨Jstar, h_Jstar_le_kg, h_lip_bnd⟩ := h_cover
        have h_Jstar_mem : Jstar ∈ Finset.range (kg + 1) :=
          Finset.mem_range.mpr (Nat.lt_succ_of_le h_Jstar_le_kg)
        have h_rEntry_Jstar_le_sup :
            ((rEntry (Nat.pair n k, Jstar) : ℚ) : ℝ)
              ≤ (Finset.range (kg + 1)).sup' Finset.nonempty_range_add_one
                  (fun J => ((rEntry (Nat.pair n k, J) : ℚ) : ℝ)) := by
          rw [Finset.le_sup'_iff]
          exact ⟨Jstar, h_Jstar_mem, le_refl _⟩
        have h_rEntry_Jstar : ((rEntry (Nat.pair n k, Jstar) : ℚ) : ℝ)
            = |∑ j ∈ Finset.range (d (n, K) + 1),
                (a (n, K, j) : ℝ) * (xQ Jstar) ^ j| :=
          h_rEntry_eq Jstar
        calc |∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * x.val ^ j|
            = |(∑ j ∈ Finset.range (d (n, K) + 1),
                  (a (n, K, j) : ℝ) * (xQ Jstar) ^ j)
                + ((∑ j ∈ Finset.range (d (n, K) + 1),
                      (a (n, K, j) : ℝ) * x.val ^ j)
                   - (∑ j ∈ Finset.range (d (n, K) + 1),
                         (a (n, K, j) : ℝ) * (xQ Jstar) ^ j))| := by
              congr 1; ring
          _ ≤ |∑ j ∈ Finset.range (d (n, K) + 1),
                  (a (n, K, j) : ℝ) * (xQ Jstar) ^ j|
                + |(∑ j ∈ Finset.range (d (n, K) + 1),
                      (a (n, K, j) : ℝ) * x.val ^ j)
                   - (∑ j ∈ Finset.range (d (n, K) + 1),
                         (a (n, K, j) : ℝ) * (xQ Jstar) ^ j)| := abs_add_le _ _
          _ ≤ ((sNK (n, k) : ℚ) : ℝ) + 2 / 2 ^ K := by
              rw [h_sNK_cast, ← h_rEntry_Jstar]
              exact add_le_add h_rEntry_Jstar_le_sup h_lip_bnd
      by_cases hαβ' : α' < β'
      · -- Non-degenerate case: clamp x.val to [α', β'] then floor-round.
        set y : ℝ := max α' (min β' x.val) with hy_def
        have h_y_ge_α' : α' ≤ y := le_max_left _ _
        have h_y_le_β' : y ≤ β' := max_le hαβ'.le (min_le_left _ _)
        have h_x_y_close : |x.val - y| ≤ 1 / 2 ^ mm := by
          have hx_lo : α ≤ x.val := (Set.mem_Icc.mp x.2).1
          have hx_hi : x.val ≤ β := (Set.mem_Icc.mp x.2).2
          by_cases h1 : x.val < α'
          · have h_min_x_le_xval : min β' x.val ≤ x.val := min_le_right _ _
            have h_min_lt_α' : min β' x.val < α' := h_min_x_le_xval.trans_lt h1
            have h_y_eq : y = α' := by rw [hy_def, max_eq_left h_min_lt_α'.le]
            rw [h_y_eq, abs_of_neg (by linarith)]
            linarith [(abs_le.mp hα'_close).2]
          · push_neg at h1
            by_cases h2 : β' < x.val
            · have h_min_x : min β' x.val = β' := min_eq_left h2.le
              have h_y_eq : y = β' := by rw [hy_def, h_min_x, max_eq_right hαβ'.le]
              rw [h_y_eq, abs_of_pos (by linarith)]
              linarith [(abs_le.mp hβ'_close).1]
            · push_neg at h2
              have h_min_eq : min β' x.val = x.val := min_eq_right h2
              have h_y_eq : y = x.val := by rw [hy_def, h_min_eq, max_eq_right h1]
              rw [h_y_eq, sub_self, abs_zero]; positivity
        set t : ℝ := (y - α') / (β' - α') with ht_def
        have h_β'_minus_α'_pos : 0 < β' - α' := by linarith
        have h_t_nn : 0 ≤ t := div_nonneg (by linarith) h_β'_minus_α'_pos.le
        have h_t_le_one : t ≤ 1 := by
          rw [ht_def, div_le_one h_β'_minus_α'_pos]
          linarith
        have h_y_eq_α'_plus_t : y = α' + t * (β' - α') := by
          rw [ht_def]; field_simp; ring
        have h_kg_t_nn : 0 ≤ (kg : ℝ) * t := mul_nonneg h_kg_real_pos.le h_t_nn
        set Jstar : ℕ := Nat.floor ((kg : ℝ) * t) with hJstar_def
        have h_Jstar_R_le : (Jstar : ℝ) ≤ (kg : ℝ) * t := Nat.floor_le h_kg_t_nn
        have h_Jstar_lt : (kg : ℝ) * t < (Jstar : ℝ) + 1 := Nat.lt_floor_add_one _
        have h_Jstar_le_kg : Jstar ≤ kg := by
          have h_kgt_le_kg : (kg : ℝ) * t ≤ (kg : ℝ) := by
            have := mul_le_mul_of_nonneg_left h_t_le_one h_kg_real_pos.le
            linarith
          exact_mod_cast h_Jstar_R_le.trans h_kgt_le_kg
        have h_xQ_Jstar_def : xQ Jstar = α' + (Jstar : ℝ) / (kg : ℝ) * (β' - α') :=
          rfl
        have h_t_ge_Jstar_kg : (Jstar : ℝ) / (kg : ℝ) ≤ t := by
          rw [div_le_iff₀ h_kg_real_pos]; linarith
        have h_diff_le : t - (Jstar : ℝ) / (kg : ℝ) ≤ 1 / (kg : ℝ) := by
          rw [sub_le_iff_le_add,
              show (1 : ℝ) / (kg : ℝ) + (Jstar : ℝ) / (kg : ℝ)
                = ((Jstar : ℝ) + 1) / (kg : ℝ) from by ring,
              le_div_iff₀ h_kg_real_pos]
          linarith
        have h_y_minus_xQJstar_nn : 0 ≤ y - xQ Jstar := by
          rw [h_xQ_Jstar_def, h_y_eq_α'_plus_t]
          have : 0 ≤ (t - (Jstar : ℝ) / (kg : ℝ)) * (β' - α') :=
            mul_nonneg (by linarith) (by linarith)
          linarith
        have h_y_minus_xQJstar_le : y - xQ Jstar ≤ (β' - α') / (kg : ℝ) := by
          rw [h_xQ_Jstar_def, h_y_eq_α'_plus_t]
          have h_eq : α' + t * (β' - α') - (α' + (Jstar : ℝ) / (kg : ℝ) * (β' - α'))
                    = (t - (Jstar : ℝ) / (kg : ℝ)) * (β' - α') := by ring
          rw [h_eq]
          calc (t - (Jstar : ℝ) / (kg : ℝ)) * (β' - α')
              ≤ 1 / (kg : ℝ) * (β' - α') :=
                mul_le_mul_of_nonneg_right h_diff_le (by linarith)
            _ = (β' - α') / (kg : ℝ) := by ring
        have h_β'_minus_α'_le : β' - α' ≤ 2 * ((B : ℝ) + 1) := by
          have h1 := (abs_le.mp h_α'_bound).1
          have h2 := (abs_le.mp h_β'_bound).2
          linarith
        have h_β'mα'_kg_le :
            (β' - α') / (kg : ℝ) ≤ 2 * ((B : ℝ) + 1) / (kg : ℝ) := by
          rw [div_le_div_iff₀ h_kg_real_pos h_kg_real_pos]
          exact mul_le_mul_of_nonneg_right h_β'_minus_α'_le h_kg_real_pos.le
        have h_x_xQJstar_close : |x.val - xQ Jstar|
            ≤ 1 / 2 ^ mm + 2 * ((B : ℝ) + 1) / (kg : ℝ) := by
          calc |x.val - xQ Jstar|
              = |(x.val - y) + (y - xQ Jstar)| := by congr 1; ring
            _ ≤ |x.val - y| + |y - xQ Jstar| := abs_add_le _ _
            _ ≤ 1 / 2 ^ mm + (β' - α') / (kg : ℝ) := by
                apply add_le_add h_x_y_close
                rw [abs_of_nonneg h_y_minus_xQJstar_nn]; exact h_y_minus_xQJstar_le
            _ ≤ 1 / 2 ^ mm + 2 * ((B : ℝ) + 1) / (kg : ℝ) := by
                linarith [h_β'mα'_kg_le]
        have h_xQJstar_BP1 : |xQ Jstar| ≤ (B : ℝ) + 1 := h_xQ_bnd Jstar h_Jstar_le_kg
        have h_lip := polyEval_lipschitz_real a d n K (B + 1) x.val (xQ Jstar)
          (show |x.val| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_x_abs_BP1)
          (show |xQ Jstar| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_xQJstar_BP1)
        push_cast at h_lip
        have h_dist_nn : 0 ≤ |x.val - xQ Jstar| := abs_nonneg _
        refine ⟨Jstar, h_Jstar_le_kg, ?_⟩
        calc |(∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * x.val ^ j)
              - (∑ j ∈ Finset.range (d (n, K) + 1),
                    (a (n, K, j) : ℝ) * (xQ Jstar) ^ j)|
            ≤ (∑ j ∈ Finset.range (d (n, K) + 1),
                (j : ℝ) * |((a (n, K, j)) : ℝ)| * ((B : ℝ) + 1) ^ (j - 1))
              * |x.val - xQ Jstar| := h_lip
          _ ≤ ((Lip_nℕ : ℕ) : ℝ) * |x.val - xQ Jstar| := by
              exact mul_le_mul_of_nonneg_right h_Lip_real_le_nat h_dist_nn
          _ ≤ ((Lip_nℕ : ℕ) : ℝ) * (1 / 2 ^ mm + 2 * ((B : ℝ) + 1) / (kg : ℝ)) := by
              exact mul_le_mul_of_nonneg_left h_x_xQJstar_close (Nat.cast_nonneg _)
          _ = ((Lip_nℕ : ℕ) : ℝ) * (1 / 2 ^ mm)
              + ((Lip_nℕ : ℕ) : ℝ) * (2 * ((B : ℝ) + 1) / (kg : ℝ)) := by ring
          _ ≤ 2 / 2 ^ K := h_combined_bound
      · -- Degenerate case: α' ≥ β', forcing β - α ≤ 2/2^mm. Midpoint case-split.
        push_neg at hαβ'
        have h_β_minus_α : β - α ≤ 2 / 2 ^ mm := by
          have h1 := abs_le.mp hα'_close
          have h2 := abs_le.mp hβ'_close
          have h_eq : (2 : ℝ) / 2 ^ mm = 2 * (1 / 2 ^ mm) := by ring
          linarith [h1.1, h1.2, h2.1, h2.2, hαβ', h_eq]
        have h_xQ_0_eq : xQ 0 = α' := by
          show α' + ((0 : ℕ) : ℝ) / (kg : ℝ) * (β' - α') = α'
          rw [Nat.cast_zero]; ring
        have h_xQ_kg_eq : xQ kg = β' := by
          show α' + ((kg : ℕ) : ℝ) / (kg : ℝ) * (β' - α') = β'
          rw [div_self h_kg_real_pos.ne']; ring
        by_cases h_x_mid : x.val ≤ (α + β) / 2
        · -- Pick J* := 0. xQ 0 = α'. |x.val - α'| ≤ 2/2^mm.
          have hx_lo : α ≤ x.val := (Set.mem_Icc.mp x.2).1
          have h_x_α_le : x.val - α ≤ (β - α) / 2 := by linarith
          have h_xα_abs : |x.val - α| ≤ (β - α) / 2 := by
            rw [abs_of_nonneg (by linarith)]; exact h_x_α_le
          have h_x_xQ0 : |x.val - xQ 0| ≤ 2 / 2 ^ mm := by
            rw [h_xQ_0_eq]
            calc |x.val - α'|
                = |(x.val - α) + (α - α')| := by congr 1; ring
              _ ≤ |x.val - α| + |α - α'| := abs_add_le _ _
              _ ≤ (β - α) / 2 + 1 / 2 ^ mm := by
                  apply add_le_add h_xα_abs
                  rw [show α - α' = -(α' - α) from by ring, abs_neg]
                  exact hα'_close
              _ ≤ 1 / 2 ^ mm + 1 / 2 ^ mm := by
                  have h_eq : (2 : ℝ) / 2 ^ mm = 2 * (1 / 2 ^ mm) := by ring
                  linarith [h_β_minus_α, h_eq]
              _ = 2 / 2 ^ mm := by ring
          have h_xQ_0_BP1 : |xQ 0| ≤ (B : ℝ) + 1 := h_xQ_bnd 0 (by omega)
          have h_lip := polyEval_lipschitz_real a d n K (B + 1) x.val (xQ 0)
            (show |x.val| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_x_abs_BP1)
            (show |xQ 0| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_xQ_0_BP1)
          push_cast at h_lip
          have h_dist_nn : 0 ≤ |x.val - xQ 0| := abs_nonneg _
          refine ⟨0, by omega, ?_⟩
          calc |(∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * x.val ^ j)
                - (∑ j ∈ Finset.range (d (n, K) + 1),
                      (a (n, K, j) : ℝ) * (xQ 0) ^ j)|
              ≤ (∑ j ∈ Finset.range (d (n, K) + 1),
                  (j : ℝ) * |((a (n, K, j)) : ℝ)| * ((B : ℝ) + 1) ^ (j - 1))
                * |x.val - xQ 0| := h_lip
            _ ≤ ((Lip_nℕ : ℕ) : ℝ) * |x.val - xQ 0| :=
                mul_le_mul_of_nonneg_right h_Lip_real_le_nat h_dist_nn
            _ ≤ ((Lip_nℕ : ℕ) : ℝ) * (2 / 2 ^ mm) :=
                mul_le_mul_of_nonneg_left h_x_xQ0 (Nat.cast_nonneg _)
            _ = 2 * (((Lip_nℕ : ℕ) : ℝ) * (1 / 2 ^ mm)) := by ring
            _ ≤ 2 * (1 / 2 ^ K) :=
                mul_le_mul_of_nonneg_left h_Lip_2m_le_K (by norm_num)
            _ = 2 / 2 ^ K := by ring
        · push_neg at h_x_mid
          -- Pick J* := kg. xQ kg = β'. |x.val - β'| ≤ 2/2^mm.
          have hx_hi : x.val ≤ β := (Set.mem_Icc.mp x.2).2
          have h_βx_le : β - x.val ≤ (β - α) / 2 := by linarith
          have h_βx_abs : |β - x.val| ≤ (β - α) / 2 := by
            rw [abs_of_nonneg (by linarith)]; exact h_βx_le
          have h_x_xQ_kg : |x.val - xQ kg| ≤ 2 / 2 ^ mm := by
            rw [h_xQ_kg_eq]
            calc |x.val - β'|
                = |-(β - x.val) + (β - β')| := by congr 1; ring
              _ ≤ |-(β - x.val)| + |β - β'| := abs_add_le _ _
              _ = |β - x.val| + |β - β'| := by rw [abs_neg]
              _ ≤ (β - α) / 2 + 1 / 2 ^ mm := by
                  apply add_le_add h_βx_abs
                  rw [show β - β' = -(β' - β) from by ring, abs_neg]
                  exact hβ'_close
              _ ≤ 1 / 2 ^ mm + 1 / 2 ^ mm := by
                  have h_eq : (2 : ℝ) / 2 ^ mm = 2 * (1 / 2 ^ mm) := by ring
                  linarith [h_β_minus_α, h_eq]
              _ = 2 / 2 ^ mm := by ring
          have h_xQ_kg_BP1 : |xQ kg| ≤ (B : ℝ) + 1 := h_xQ_bnd kg (le_refl _)
          have h_lip := polyEval_lipschitz_real a d n K (B + 1) x.val (xQ kg)
            (show |x.val| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_x_abs_BP1)
            (show |xQ kg| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_xQ_kg_BP1)
          push_cast at h_lip
          have h_dist_nn : 0 ≤ |x.val - xQ kg| := abs_nonneg _
          refine ⟨kg, le_refl _, ?_⟩
          calc |(∑ j ∈ Finset.range (d (n, K) + 1), (a (n, K, j) : ℝ) * x.val ^ j)
                - (∑ j ∈ Finset.range (d (n, K) + 1),
                      (a (n, K, j) : ℝ) * (xQ kg) ^ j)|
              ≤ (∑ j ∈ Finset.range (d (n, K) + 1),
                  (j : ℝ) * |((a (n, K, j)) : ℝ)| * ((B : ℝ) + 1) ^ (j - 1))
                * |x.val - xQ kg| := h_lip
            _ ≤ ((Lip_nℕ : ℕ) : ℝ) * |x.val - xQ kg| :=
                mul_le_mul_of_nonneg_right h_Lip_real_le_nat h_dist_nn
            _ ≤ ((Lip_nℕ : ℕ) : ℝ) * (2 / 2 ^ mm) :=
                mul_le_mul_of_nonneg_left h_x_xQ_kg (Nat.cast_nonneg _)
            _ = 2 * (((Lip_nℕ : ℕ) : ℝ) * (1 / 2 ^ mm)) := by ring
            _ ≤ 2 * (1 / 2 ^ K) :=
                mul_le_mul_of_nonneg_left h_Lip_2m_le_K (by norm_num)
            _ = 2 / 2 ^ K := by ring
    -- ⑩.c.14 Combine `h_b1` and `h_b2` via `abs_le`.
    rw [abs_le]
    have h_2K_pos : (0 : ℝ) < (2 : ℝ) ^ K := by positivity
    refine ⟨?_, ?_⟩
    · linarith [h_b2]
    · have h_1_le_2 : (1 : ℝ) / 2 ^ K ≤ 2 / 2 ^ K := by
        rw [div_le_div_iff₀ h_2K_pos h_2K_pos]; linarith
      linarith [h_b1, h_1_le_2]
  -- ⑩.d Combine (a) and (b) via triangle inequality.
  have h_K_eq : (2 : ℝ) ^ K = 4 * 2 ^ k := by
    rw [hK_eq]
    ring
  calc |((sNK (n, k) : ℝ)) - ‖f n‖|
      ≤ |((sNK (n, k) : ℝ)) - ‖p‖| + |‖p‖ - ‖f n‖| :=
        abs_sub_le _ _ _
    _ ≤ 2 / 2 ^ K + 1 / 2 ^ K := add_le_add h_b h_a
    _ = 3 / 2 ^ K := by ring
    _ ≤ 1 / 2 ^ k := by
        rw [h_K_eq]
        have h_pos : (0 : ℝ) < 2 ^ k := by positivity
        rw [div_le_div_iff₀ (by positivity) h_pos]
        linarith

/-- The `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` structure, parameterized over
an explicit rational bound `(B : ℕ)` on `max(|α|, |β|)` **and** computable-real
witnesses for `α, β` (needed by A3 — see `isComputableSeqCMap_norm`).

**Why a `def` taking explicit hypotheses and not an `instance`** (iter-05 of
round `l4-cmap-axiom-linearity-cont`): the polynomial-form A1 proof's
norm-bound argument needs a Computable upper bound on `max(|α|, |β|)`. For
arbitrary `α, β : ℝ` no such bound exists; given a rational bound `B`, the
precision-pad argument goes through. Separately, A3's grid-based maximum
argument needs `α, β` to be *computable reals*, not just bounded — see the
counterexample in `isComputableSeqCMap_norm`'s docstring and P-R Ch. 2:128
("for recursive reals `a, b`"). The previous `noncomputable instance`
(without any hypothesis) was provably unrealizable for arbitrary `α, β` —
see `.goals/l4-cmap-axiom-linearity-cont/iter-04.md`.

The predicate is `IsComputableSeqCMap`; `zero_seq`,
`isComputableSeq_linearCombination` (A1), `isComputableSeq_of_effectiveLimit`
(A2), and `isComputableSeqReal_norm` (A3, via the named
`isComputableSeqCMap_norm`) are all packaged. A3 was closed in round
`l4-cmap-axiom3-norm-resig` via the three-error decomposition (clamping +
floor-cover + midpoint case-split for the degenerate `α' ≥ β'` regime).

ref for axioms 1-3: `literature/papers/PourEl-Richards-chapt2.md:66-77`.
ref for "axiom 1 trivial / axiom 2 = Ch. 0 Thm 4 / axiom 3 = Ch. 0 Thm 7":
`literature/papers/PourEl-Richards-chapt2.md:128-129`. -/
@[reducible] noncomputable def computabilityStructureCMap_of
    (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ))
    (hα_c : IsComputableReal α) (hβ_c : IsComputableReal β)
    (hαβ : α ≤ β) :
    ComputabilityStructure ℝ (C(Set.Icc α β, ℝ)) where
  IsComputableSeq := IsComputableSeqCMap
  isComputableSeq_linearCombination :=
    isComputableSeqCMap_linearCombination B hα_le hβ_le
  isComputableSeq_of_effectiveLimit :=
    isComputableSeqCMap_of_effectiveLimit (α := α) (β := β)
  isComputableSeqReal_norm := fun f hf =>
    isComputableSeqCMap_norm B hα_le hβ_le hα_c hβ_c hαβ f hf
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

end ComputableAnalysis.L4
