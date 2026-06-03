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

/-- The `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` structure, parameterized over an
explicit rational bound `(B : ℕ)` on `max(|α|, |β|)`.

**Why a `def` taking explicit bounds and not an `instance`** (iter-05 of round
`l4-cmap-axiom-linearity-cont`): the polynomial-form A1 proof's norm-bound
argument needs a Computable upper bound on `max(|α|, |β|)`. For arbitrary
`α, β : ℝ` no such bound exists; given a rational bound `B`, the precision-pad
argument goes through. This matches P-R Ch. 2:128 ("for recursive reals a, b").
The previous `noncomputable instance instComputabilityStructureCMap` (without
hypothesis) was provably unrealizable for arbitrary `α, β` — see
`.goals/l4-cmap-axiom-linearity-cont/iter-04.md` for the obstruction analysis.

The predicate is `IsComputableSeqCMap`; `zero_seq` and
`isComputableSeq_linearCombination` (A1) are proved, while
`isComputableSeq_of_effectiveLimit` (A2) and `isComputableSeqReal_norm` (A3)
remain `sorry` (deferred).

ref for axioms 1-3: `literature/papers/PourEl-Richards-chapt2.md:66-77`.
ref for "axiom 1 trivial / axiom 2 = Ch. 0 Thm 4 / axiom 3 = Ch. 0 Thm 7":
`literature/papers/PourEl-Richards-chapt2.md:128-129`. -/
@[reducible] noncomputable def computabilityStructureCMap_of
    (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ)) :
    ComputabilityStructure ℝ (C(Set.Icc α β, ℝ)) where
  IsComputableSeq := IsComputableSeqCMap
  isComputableSeq_linearCombination := by
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
  isComputableSeq_of_effectiveLimit := by
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
  isComputableSeqReal_norm := by
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

end ComputableAnalysis.L4
