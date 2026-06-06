/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import Mathlib.Topology.ContinuousMap.Basic
import Mathlib.Topology.ContinuousMap.Algebra
import Mathlib.Topology.ContinuousMap.Compact
import ComputableAnalysis.L1.ComputableSeqReal

/-!
# L2 — Grzegorczyk–Lacombe computable continuous functions (Definition A)

This file defines `IsGLComputable`, the Pour-El & Richards Ch. 0 §3
**Definition A** of a computable continuous function on a closed bounded
interval `Set.Icc α β ⊆ ℝ`. The verbatim Pour-El & Richards passage
(`literature/papers/PourEl-Richards-chapt0.md:426-435`):

> As noted above, the following definition is due to Grzegorczyk/Lacombe.
>
> **Definition A (Effective evaluation).** Let `I^q ⊆ ℝ^q` be a computable
> rectangle, as described above. A function `f : I^q → ℝ` is computable if:
>
> (i) `f` is sequentially computable, i.e. `f` maps every computable
> sequence of points `x_k ∈ I^q` into a computable sequence `{f(x_k)}` of
> real numbers;
>
> (ii) `f` is effectively uniformly continuous, i.e. there is a recursive
> function `d : ℕ → ℕ` such that for all `x, y ∈ I^q` and all `N`:
>
> `|x − y| ≤ 1/d(N)` implies `|f(x) − f(y)| ≤ 2^{−N}`,
>
> where `|·|` denotes the euclidean norm.

## Scope of this file

This round (`l2-grzegorczyk-lacombe`) formalizes the **one-variable
(`q = 1`), bounded-domain** case. Multivariable (`q ≥ 2`) and unbounded
(`Definitions A'`, `A''` at chapt0:460-497) extensions are deferred.

The predicate is parameterized on `{α β : ℝ}` and lives on
`C(Set.Icc α β, ℝ)` — matching the L4 `CMap` shape so the eventual
Ch. 0 §7 Equivalence Theorem (Def A ⇔ Def B) can land as the bridge
`IsGLComputable f ↔ IsComputableSeqCMap (fun _ => f)` in a later round.

## Design notes

- **Subtype coercion.** `Set.Icc α β` is a `Set ℝ`; `Mathlib`'s `CoeSort`
  makes it usable as the type `↥(Set.Icc α β) = {r : ℝ // α ≤ r ∧ r ≤ β}`.
  An element `x : Set.Icc α β` has underlying real value `(x : ℝ)`.
  Sequential computability of `x : ℕ → Set.Icc α β` is stated as
  `IsComputableSeqReal (fun n => (x n : ℝ))`, matching P-R's "computable
  sequence of points in `I^q`" wording.

- **Degenerate intervals.** For `α > β` the set `Set.Icc α β = ∅`. The
  sequential-computability clause is vacuous (no `x : ℕ → ∅`), and the
  modulus clause is vacuous (no `x y : ∅`). The predicate is then
  vacuously true. Downstream lemmas typically add `hαβ : α ≤ β`.

- **Explicit positivity hypothesis `∀ N, 0 < d N`.** P-R does not write
  positivity in prose, but their classical reading of `1/d(N)` implicitly
  requires `d(N) > 0` (otherwise `1/d(N)` is undefined / infinite). In
  Mathlib's `1/0 = 0` convention the existential `∃ d` would otherwise be
  satisfied by the vacuous witness `d := fun _ => 0` for ANY `f` (the
  antecedent `|x − y| ≤ 0` would force `x = y`, the conclusion would hold
  trivially), collapsing the predicate to the Banach-Mazur definition
  (sequential computability alone, chapt0:520) — strictly weaker than
  Definition A. We therefore encode the implicit P-R positivity
  requirement as an explicit conjunct. *Fixed in iter-06 of round
  `l2-grzegorczyk-lacombe`.*

- **`Computable d`.** P-R says "recursive function `d : ℕ → ℕ`"; we use
  Mathlib's `Computable` (= partial-recursive total) for `ℕ → ℕ`, which is
  the substrate per `CLAUDE.md` commitment #4 ("Substrate is Mathlib's
  `Computable` / `Partrec`").

## References

- `literature/papers/PourEl-Richards-chapt0.md:426-435` — Def A (verbatim)
- `ComputableAnalysis/L1/ComputableSeqReal.lean:106` — `IsComputableSeqReal`
- `ComputableAnalysis/L4/Instances/CMap.lean:1214` — sibling L4 predicate
-/

namespace ComputableAnalysis.L2

open ComputableAnalysis.L1

variable {α β : ℝ}

/-- **Grzegorczyk–Lacombe Definition A** (Pour-El & Richards Ch. 0:427-435).

A continuous function `f : C(Set.Icc α β, ℝ)` is *Grzegorczyk–Lacombe
computable* iff:

- **(i) Sequential computability.** For every input sequence
  `x : ℕ → Set.Icc α β` whose underlying real sequence
  `fun n => (x n : ℝ)` is in `IsComputableSeqReal`, the output sequence
  `fun n => f (x n)` is also in `IsComputableSeqReal`.

- **(ii) Effective uniform continuity.** There exists a `Computable`
  function `d : ℕ → ℕ` with `∀ N, 0 < d N` (an explicit encoding of the
  positivity that P-R's classical `1/d(N)` notation implicitly requires —
  see the Design Notes above) such that for all `N` and all
  `x y : Set.Icc α β`,
  `|(x : ℝ) − (y : ℝ)| ≤ 1 / d N` implies `|f x − f y| ≤ 1 / 2 ^ N`.

ref: `literature/papers/PourEl-Richards-chapt0.md:427-435`. -/
def IsGLComputable (f : C(Set.Icc α β, ℝ)) : Prop :=
  (∀ x : ℕ → Set.Icc α β,
      IsComputableSeqReal (fun n => ((x n : ℝ))) →
      IsComputableSeqReal (fun n => f (x n))) ∧
  ∃ d : ℕ → ℕ, Computable d ∧ (∀ N, 0 < d N) ∧
    ∀ N (x y : Set.Icc α β),
      |((x : ℝ)) - ((y : ℝ))| ≤ (1 : ℝ) / (d N : ℝ) →
      |f x - f y| ≤ (1 : ℝ) / (2 : ℝ) ^ N

/-! ## §1 — Structural closures of `IsGLComputable` -/

/-- **Constant-function GL-computability.**

For any `c : ℝ` that is a computable real, the constant continuous map
`ContinuousMap.const (Set.Icc α β) c : C(Set.Icc α β, ℝ)` is
Grzegorczyk–Lacombe computable in the sense of `IsGLComputable`.

**Proof outline.**

- *Clause (i) — sequential computability.* The output sequence
  `fun n => (ContinuousMap.const _ c) (x n)` reduces definitionally (via
  the `ContinuousMap.const` def and the `FunLike` coercion) to
  `fun _ => c`, which is the unfolding of `IsComputableReal c`. So `hc`
  discharges the goal directly.

- *Clause (ii) — effective uniform continuity.* Any computable modulus
  works since `|c − c| = 0 ≤ 1 / 2 ^ N` for all `N`. We pick the trivial
  witness `d := fun _ => 1`; `Computable.const 1` certifies recursiveness
  (Partrec.lean:271).

ref: `literature/papers/PourEl-Richards-chapt0.md:504` — "It is trivial to
verify that most of the specific continuous functions encountered in
analysis ... are computable over any computable rectangle on which they
are continuous." -/
theorem l2_const_gl {c : ℝ} (hc : IsComputableReal c) :
    IsGLComputable (ContinuousMap.const (Set.Icc α β) c) := by
  refine ⟨fun x _ => ?_, fun _ => 1, Computable.const 1, ?_, ?_⟩
  · -- Clause (i): the output sequence is definitionally `fun _ => c`.
    -- That is precisely `IsComputableReal c = IsComputableSeqReal (fun _ => c)`.
    exact hc
  · -- Positivity: `0 < 1` for the constant modulus witness `fun _ => 1`.
    intro _
    exact Nat.one_pos
  · -- Clause (ii) modulus implication: `|c − c| = 0 ≤ 1/2^N`.
    intro N _ _ _
    simp only [ContinuousMap.const_apply, sub_self, abs_zero]
    positivity

/-- **Coordinate-inclusion GL-computability.**

The coordinate inclusion `(fun x : Set.Icc α β => (x : ℝ)) : C(Set.Icc α β, ℝ)`
— i.e., `Subtype.val` viewed as a `ContinuousMap`, with continuity witnessed
by `continuous_subtype_val` — is Grzegorczyk–Lacombe computable.

**Proof outline.**

- *Clause (i) — sequential computability.* The output sequence
  `fun n => (coordIcc) (x n)` reduces definitionally to `fun n => (x n : ℝ)`,
  which is exactly the hypothesis on the input sequence's computability.

- *Clause (ii) — modulus.* Pick `d N := 2^N`. The antecedent
  `|x − y| ≤ 1 / (2^N : ℕ)` rewrites (via `Nat.cast_pow`, applied by
  `push_cast`) to `|x − y| ≤ 1 / (2 : ℝ)^N`, which IS the conclusion (the
  identity preserves distances). Computability of `fun N => 2^N` is built
  inline via `Computable.nat_rec`, per `docs/PITFALLS.md §1` and the
  proven `h_Bpow` recipe at `ComputableAnalysis/L4/Instances/CMap.lean:1316-1329`
  (the `(y, IH).2`-form step display is handled by `show` per
  `docs/LEAN-IDIOMS.md §2`).

ref: `literature/papers/PourEl-Richards-chapt0.md:504` — "x ± y" and
similar projection/coordinate operators are trivially computable. -/
theorem l2_id_gl :
    IsGLComputable
      (⟨fun x : Set.Icc α β => (x : ℝ), continuous_subtype_val⟩ :
        C(Set.Icc α β, ℝ)) := by
  refine ⟨fun _ hx => ?_, fun N => 2 ^ N, ?_, ?_, ?_⟩
  · -- Clause (i): output at each n reduces to (x n : ℝ); hx is exactly that.
    exact hx
  · -- Computable (fun N => 2 ^ N) via Computable.nat_rec (PITFALLS §1).
    have hh : Computable₂ (fun (_ : ℕ) (yih : ℕ × ℕ) => yih.2 * 2) := by
      show Computable (fun p : ℕ × (ℕ × ℕ) => p.2.2 * 2)
      exact Primrec.nat_mul.to_comp.comp (Computable.snd.comp Computable.snd)
        (Computable.const 2)
    refine (Computable.nat_rec Computable.id (Computable.const (1 : ℕ)) hh).of_eq
      fun N => ?_
    show Nat.rec 1 (fun y IH => (y, IH).2 * 2) N = 2 ^ N
    induction N with
    | zero => rfl
    | succ N IH =>
      show Nat.rec 1 (fun y IH' => (y, IH').2 * 2) N * 2 = 2 ^ (N + 1)
      rw [IH, pow_succ]
  · -- Positivity: `0 < 2^N` for the modulus witness `fun N => 2^N`.
    intro N
    exact Nat.two_pow_pos N
  · -- Clause (ii) modulus implication: the cast bridge
    -- `(2^N : ℕ).cast = (2:ℝ)^N` aligns antecedent and conclusion;
    -- identity preserves distances.
    intro N _ _ hxy
    push_cast at hxy
    exact hxy

/-! ## §2 — Additive structural closures of `IsGLComputable`

Lifts the L1 closure `IsComputableSeqReal.add` (see
`ComputableAnalysis/L1/ComputableSeqReal.lean` §4.5) to the GL-computable
level. -/

/-- **Sum closure for `IsGLComputable`** (P-R Ch. 0 §4, implicit closure under `+`).

If `f` and `g` are `IsGLComputable` (Definition A) on `Set.Icc α β`, so is
`f + g`.

**Proof outline.**

- *Clause (i)*: pointwise sum of L1-computable sequences via the inline
  `isComputableSeqReal_add` helper. The output sequence
  `fun n => (f + g) (x n)` equals `fun n => f (x n) + g (x n)` via
  `ContinuousMap.add_apply`, and the latter is L1-computable.

- *Clause (ii)*: with `df, dg` the moduli of `f, g`, take
  `d_sum N := df (N + 1) * dg (N + 1)`. Positivity of the product follows
  from `Nat.mul_pos` applied to `f, g`'s positivity hypotheses
  (these exist precisely because the iter-06 predicate fix added the
  `∀ N, 0 < d N` conjunct — see Design Notes). `Computable` follows by
  `Primrec.nat_mul.to_comp.comp` of the `Computable.succ`-composed
  moduli.

  For the modulus implication: the hypothesis `|x − y| ≤ 1 / d_sum N`
  implies both `|x − y| ≤ 1 / df (N + 1)` and `|x − y| ≤ 1 / dg (N + 1)`
  (since `df (N + 1)` and `dg (N + 1)` each divide the product, and both
  are positive — so the bound on `1/d_sum N` is at most the bound on
  `1/df (N + 1)`, and similarly for `dg`). Applying `f, g`'s moduli at
  `N + 1` yields `|f x − f y| ≤ 1/2^(N + 1)` and `|g x − g y| ≤ 1/2^(N + 1)`.
  The triangle inequality gives `|(f + g) x − (f + g) y| ≤ 1/2^(N + 1) +
  1/2^(N + 1) = 1/2^N`.

ref: P-R Ch. 0:504 ("`x ± y` is computable over any computable rectangle"). -/
theorem l2_sum_gl
    {f g : C(Set.Icc α β, ℝ)}
    (hf : IsGLComputable f) (hg : IsGLComputable g) :
    IsGLComputable (f + g) := by
  obtain ⟨hf_seq, df, hdf_comp, hdf_pos, hdf_mod⟩ := hf
  obtain ⟨hg_seq, dg, hdg_comp, hdg_pos, hdg_mod⟩ := hg
  refine ⟨fun x hx => ?_, fun N => df (N + 1) * dg (N + 1), ?_, ?_, ?_⟩
  · -- Clause (i): output sequence is pointwise sum, closure via the helper.
    have h_f : IsComputableSeqReal (fun n => f (x n)) := hf_seq x hx
    have h_g : IsComputableSeqReal (fun n => g (x n)) := hg_seq x hx
    have h_eq :
        (fun n => (f + g) (x n)) =
          (fun n => f (x n)) + (fun n => g (x n)) := by
      funext n
      show f (x n) + g (x n) = f (x n) + g (x n)
      rfl
    rw [h_eq]
    exact h_f.add h_g
  · -- `Computable (fun N => df (N + 1) * dg (N + 1))`.
    exact Primrec.nat_mul.to_comp.comp
      (hdf_comp.comp Computable.succ) (hdg_comp.comp Computable.succ)
  · -- Positivity: `∀ N, 0 < df (N + 1) * dg (N + 1)`.
    intro N
    exact Nat.mul_pos (hdf_pos (N + 1)) (hdg_pos (N + 1))
  · -- Modulus implication.
    intro N x y hxy
    have h_df_pos : 0 < df (N + 1) := hdf_pos (N + 1)
    have h_dg_pos : 0 < dg (N + 1) := hdg_pos (N + 1)
    -- Both `df (N + 1)` and `dg (N + 1)` divide the product, both positive.
    have h_df_le_prod : df (N + 1) ≤ df (N + 1) * dg (N + 1) :=
      Nat.le_mul_of_pos_right _ h_dg_pos
    have h_dg_le_prod : dg (N + 1) ≤ df (N + 1) * dg (N + 1) :=
      Nat.le_mul_of_pos_left _ h_df_pos
    -- Hence `1 / d_sum N ≤ 1 / df (N + 1)` and `≤ 1 / dg (N + 1)`.
    have h_xy_le_df :
        |((x : ℝ)) - ((y : ℝ))| ≤ (1 : ℝ) / ((df (N + 1) : ℕ) : ℝ) := by
      refine le_trans hxy ?_
      apply one_div_le_one_div_of_le
      · exact_mod_cast h_df_pos
      · exact_mod_cast h_df_le_prod
    have h_xy_le_dg :
        |((x : ℝ)) - ((y : ℝ))| ≤ (1 : ℝ) / ((dg (N + 1) : ℕ) : ℝ) := by
      refine le_trans hxy ?_
      apply one_div_le_one_div_of_le
      · exact_mod_cast h_dg_pos
      · exact_mod_cast h_dg_le_prod
    -- Apply `f, g` moduli at `N + 1`.
    have hf_bnd : |f x - f y| ≤ (1 : ℝ) / 2 ^ (N + 1) :=
      hdf_mod (N + 1) x y h_xy_le_df
    have hg_bnd : |g x - g y| ≤ (1 : ℝ) / 2 ^ (N + 1) :=
      hdg_mod (N + 1) x y h_xy_le_dg
    -- Triangle inequality + `1/2^(N+1) + 1/2^(N+1) = 1/2^N`.
    have h_eq_sum :
        (f + g) x - (f + g) y = (f x - f y) + (g x - g y) := by
      show (f x + g x) - (f y + g y) = (f x - f y) + (g x - g y)
      ring
    have h_tri :
        |(f + g) x - (f + g) y| ≤ |f x - f y| + |g x - g y| := by
      rw [h_eq_sum]; exact abs_add_le _ _
    have h_2pow :
        (1 : ℝ) / 2 ^ (N + 1) + (1 : ℝ) / 2 ^ (N + 1) = (1 : ℝ) / 2 ^ N := by
      rw [pow_succ]; ring
    linarith

/-! ## §3 — Negation closure of `IsGLComputable`

Lifts the L1 closure `IsComputableSeqReal.neg` (see
`ComputableAnalysis/L1/ComputableSeqReal.lean` §4.5) to the GL-computable
level. -/

/-- **Negation closure for `IsGLComputable`** (P-R Ch. 0 §4, implicit closure under unary `-`).

If `f : C(Set.Icc α β, ℝ)` is `IsGLComputable`, so is `-f`.

**Proof outline.**

- *Clause (i)*: the output sequence `fun n => (-f) (x n)` equals
  `fun n => - (f (x n))` via `ContinuousMap.neg_apply`; the helper
  `isComputableSeqReal_neg` discharges its computability from `hf_seq`'s output.

- *Clause (ii)*: the modulus witness is preserved unchanged from `f`. We have
  `|(-f) x − (-f) y| = |-(f x) − (-(f y))| = |-(f x − f y)| = |f x − f y|`
  via `neg_sub`/`abs_neg`; the hypothesis `hf_mod N x y hxy` discharges the
  conclusion `|f x − f y| ≤ 1/2^N` directly.

ref: P-R Ch. 0:504 ("`x ± y` is computable over any computable rectangle"). -/
theorem l2_neg_gl
    {f : C(Set.Icc α β, ℝ)}
    (hf : IsGLComputable f) :
    IsGLComputable (-f) := by
  obtain ⟨hf_seq, df, hdf_comp, hdf_pos, hdf_mod⟩ := hf
  refine ⟨fun x hx => ?_, df, hdf_comp, hdf_pos, ?_⟩
  · -- Clause (i): output sequence is pointwise negation, closure via the helper.
    have h_f : IsComputableSeqReal (fun n => f (x n)) := hf_seq x hx
    have h_eq :
        (fun n => (-f) (x n)) =
          (fun n => - (f (x n))) := by
      funext n
      show - f (x n) = - f (x n)
      rfl
    rw [h_eq]
    exact h_f.neg
  · -- Modulus implication: `|(-f) x − (-f) y| = |f x − f y|`.
    intro N x y hxy
    have h_eq_neg :
        (-f) x - (-f) y = - (f x - f y) := by
      show (- f x) - (- f y) = - (f x - f y)
      ring
    have h_abs :
        |(-f) x - (-f) y| = |f x - f y| := by
      rw [h_eq_neg, abs_neg]
    rw [h_abs]
    exact hdf_mod N x y hxy

/-! ## §4 — Subtraction closure of `IsGLComputable`

Trivial corollary of `l2_sum_gl` + `l2_neg_gl` via `sub_eq_add_neg`. The
`AddGroup` structure on `C(Set.Icc α β, ℝ)` (via
`Mathlib.Topology.ContinuousMap.Algebra`) makes `f - g = f + (-g)` a one-step
rewrite. -/

/-- **Subtraction closure for `IsGLComputable`** (P-R Ch. 0:504, `x ± y`).

If `f, g : C(Set.Icc α β, ℝ)` are `IsGLComputable`, so is `f - g`.

**Proof.** Rewrite `f - g = f + (-g)` via `sub_eq_add_neg`, then apply
`l2_sum_gl hf (l2_neg_gl hg)`.

ref: P-R Ch. 0:504 ("`x ± y` is computable over any computable rectangle"). -/
theorem l2_sub_gl
    {f g : C(Set.Icc α β, ℝ)}
    (hf : IsGLComputable f) (hg : IsGLComputable g) :
    IsGLComputable (f - g) := by
  rw [sub_eq_add_neg]
  exact l2_sum_gl hf (l2_neg_gl hg)

/-! ## §5 — Scalar-multiplication closure of `IsGLComputable`

Closure under `c • f` for `c : ℝ` a computable real and `f` a GL-computable
continuous function. The modulus design uses a Nat bound `M := Mc 0` on `|c|`
(extracted via `IsComputableSeqReal.bound`) to amplify the input modulus
`df (N + M)`. -/

/-- **Scalar-multiplication closure for `IsGLComputable`** (P-R Ch. 0:504,
implicit closure under `c · f`).

If `c : ℝ` is `IsComputableReal` and `f : C(Set.Icc α β, ℝ)` is
`IsGLComputable`, so is `c • f`.

**Proof outline.**

- *Clause (i)*: `(c • f) (x n) = c • f (x n) = c * f (x n)` by
  `ContinuousMap.smul_apply` + `smul_eq_mul`; closure via
  `IsComputableSeqReal.mul` applied to the constant sequence `fun _ => c`
  (which is `hc` directly via the `IsComputableReal` definition) and
  `hf_seq x hx`.

- *Clause (ii)*: with `M := Mc 0` an upper bound on `|c|` (from
  `hc.bound`), take `d_smul N := df (N + M)`. Then
  `|(c • f) x − (c • f) y| = |c| · |f x − f y| ≤ M · (1/2^(N+M)) = M / (2^N · 2^M) ≤ 1/2^N`,
  using `M ≤ 2^M` (`Nat.lt_two_pow_self`).

ref: P-R Ch. 0:504. -/
theorem l2_smul_gl
    {c : ℝ} (hc : IsComputableReal c)
    {f : C(Set.Icc α β, ℝ)}
    (hf : IsGLComputable f) :
    IsGLComputable (c • f) := by
  obtain ⟨Mc, hMc_comp, hMc_bnd⟩ := hc.bound
  obtain ⟨hf_seq, df, hdf_comp, hdf_pos, hdf_mod⟩ := hf
  set M : ℕ := Mc 0 with hM_def
  refine ⟨fun x hx => ?_, fun N => df (N + M), ?_, ?_, ?_⟩
  · -- Clause (i): IsComputableSeqReal (fun n => (c • f) (x n)).
    have hc_seq : IsComputableSeqReal (fun _ => c) := hc
    have h_f_seq : IsComputableSeqReal (fun n => f (x n)) := hf_seq x hx
    have h_mul : IsComputableSeqReal ((fun _ => c) * (fun n => f (x n))) :=
      hc_seq.mul h_f_seq
    have h_eq :
        (fun n => (c • f) (x n)) = (fun _ => c) * (fun n => f (x n)) := by
      funext n
      show (c • f) (x n) = c * f (x n)
      simp [ContinuousMap.smul_apply, smul_eq_mul]
    rw [h_eq]
    exact h_mul
  · -- Computable d_smul := fun N => df (N + M).
    exact hdf_comp.comp
      (Primrec.nat_add.to_comp.comp Computable.id (Computable.const M))
  · -- Positivity: df (N + M) > 0.
    intro N
    exact hdf_pos (N + M)
  · -- Modulus implication.
    intro N x y hxy
    have h_f_mod : |f x - f y| ≤ (1 : ℝ) / 2 ^ (N + M) := hdf_mod (N + M) x y hxy
    have h_eq : (c • f) x - (c • f) y = c * (f x - f y) := by
      simp only [ContinuousMap.smul_apply, smul_eq_mul]
      ring
    rw [h_eq, abs_mul]
    have h_c_bnd : |c| ≤ (M : ℝ) := hMc_bnd 0
    have h_step :
        |c| * |f x - f y| ≤ (M : ℝ) * (1 / 2 ^ (N + M)) :=
      mul_le_mul h_c_bnd h_f_mod (abs_nonneg _) (Nat.cast_nonneg _)
    have h_final :
        (M : ℝ) * (1 / 2 ^ (N + M)) ≤ 1 / 2 ^ N := by
      rw [pow_add, mul_one_div]
      have h2N_pos : (0 : ℝ) < 2 ^ N := by positivity
      have h2M_pos : (0 : ℝ) < 2 ^ M := by positivity
      have h_denom_pos : (0 : ℝ) < 2 ^ N * 2 ^ M := mul_pos h2N_pos h2M_pos
      rw [div_le_div_iff₀ h_denom_pos h2N_pos]
      have h_M_le_pow : (M : ℝ) ≤ (2 : ℝ) ^ M := by
        have h_nat : M < 2 ^ M := Nat.lt_two_pow_self
        have h_nat_le : M ≤ 2 ^ M := h_nat.le
        exact_mod_cast h_nat_le
      have h2N_nn : (0 : ℝ) ≤ 2 ^ N := le_of_lt h2N_pos
      nlinarith
    linarith

/-! ## §6 — Multiplication closure of `IsGLComputable`

The hardest of the L2 arithmetic closures. Requires uniform bounds
`M_f, M_g : ℕ` on `|f|, |g|` over the compact `Set.Icc α β`, extracted via
`ContinuousMap.norm_coe_le_norm` (compactness from
`compactSpace_Icc`). The modulus is the product
`df (N + 1 + M_g) * dg (N + 1 + M_f)`, with the `+ 1 + M_*` shift exactly
calibrated so each `M / 2^(N+1+M) ≤ 1/2^(N+1)` (via `Nat.lt_two_pow_self`'s
`M ≤ 2^M`), summing to `1/2^N`. -/

/-- **Multiplication closure for `IsGLComputable`** (P-R Ch. 0:504, `x · y`).

If `f, g : C(Set.Icc α β, ℝ)` are `IsGLComputable`, so is `f * g`.

**Proof outline.**

- *Clause (i)*: pointwise product `(fun n => f (x n)) * (fun n => g (x n))`
  is computable by `IsComputableSeqReal.mul`. Convert via
  `ContinuousMap.mul_apply` (def-equal in current Mathlib).

- *Clause (ii)*: with `M_f := ⌈‖f‖⌉₊ + 1`, `M_g := ⌈‖g‖⌉₊ + 1` Nat upper
  bounds on `|f|, |g|` over the compact interval, take
  `d_mul N := df (N + 1 + M_g) * dg (N + 1 + M_f)`. Positivity from
  `Nat.mul_pos`. The implication uses the standard product decomposition
  `f x g x − f y g y = f x · (g x − g y) + g y · (f x − f y)` and bounds
  each term by `M / 2^(N+1+M) ≤ 1/2^(N+1)`.

ref: P-R Ch. 0:504. -/
theorem l2_mul_gl
    {f g : C(Set.Icc α β, ℝ)}
    (hf : IsGLComputable f) (hg : IsGLComputable g) :
    IsGLComputable (f * g) := by
  obtain ⟨hf_seq, df, hdf_comp, hdf_pos, hdf_mod⟩ := hf
  obtain ⟨hg_seq, dg, hdg_comp, hdg_pos, hdg_mod⟩ := hg
  -- Nat upper bounds on |f|, |g| via ContinuousMap.norm on the compact interval.
  set M_f : ℕ := ⌈‖f‖⌉₊ + 1 with hM_f_def
  set M_g : ℕ := ⌈‖g‖⌉₊ + 1 with hM_g_def
  have hM_f_pos : 0 < M_f := by simp [hM_f_def]
  have hM_g_pos : 0 < M_g := by simp [hM_g_def]
  have h_f_bnd : ∀ x : Set.Icc α β, |f x| ≤ (M_f : ℝ) := by
    intro x
    have h1 : |f x| ≤ ‖f‖ := by
      have := f.norm_coe_le_norm x
      simpa [Real.norm_eq_abs] using this
    have h2 : ‖f‖ ≤ (⌈‖f‖⌉₊ : ℝ) := Nat.le_ceil _
    have h3 : ((⌈‖f‖⌉₊ : ℕ) : ℝ) ≤ (M_f : ℝ) := by push_cast [hM_f_def]; linarith
    linarith
  have h_g_bnd : ∀ y : Set.Icc α β, |g y| ≤ (M_g : ℝ) := by
    intro y
    have h1 : |g y| ≤ ‖g‖ := by
      have := g.norm_coe_le_norm y
      simpa [Real.norm_eq_abs] using this
    have h2 : ‖g‖ ≤ (⌈‖g‖⌉₊ : ℝ) := Nat.le_ceil _
    have h3 : ((⌈‖g‖⌉₊ : ℕ) : ℝ) ≤ (M_g : ℝ) := by push_cast [hM_g_def]; linarith
    linarith
  refine ⟨fun x hx => ?_, fun N => df (N + 1 + M_g) * dg (N + 1 + M_f), ?_, ?_, ?_⟩
  · -- Clause (i): IsComputableSeqReal (fun n => (f * g) (x n)).
    have h_f_seq : IsComputableSeqReal (fun n => f (x n)) := hf_seq x hx
    have h_g_seq : IsComputableSeqReal (fun n => g (x n)) := hg_seq x hx
    have h_mul : IsComputableSeqReal ((fun n => f (x n)) * (fun n => g (x n))) :=
      h_f_seq.mul h_g_seq
    have h_eq :
        (fun n => (f * g) (x n)) = (fun n => f (x n)) * (fun n => g (x n)) := by
      funext n
      show (f * g) (x n) = f (x n) * g (x n)
      rfl
    rw [h_eq]
    exact h_mul
  · -- Computable d_mul.
    have h_N_plus_1 : Computable (fun N : ℕ => N + 1) :=
      Primrec.nat_add.to_comp.comp Computable.id (Computable.const 1)
    have h_in_df : Computable (fun N : ℕ => N + 1 + M_g) :=
      Primrec.nat_add.to_comp.comp h_N_plus_1 (Computable.const M_g)
    have h_in_dg : Computable (fun N : ℕ => N + 1 + M_f) :=
      Primrec.nat_add.to_comp.comp h_N_plus_1 (Computable.const M_f)
    have h_df_term : Computable (fun N : ℕ => df (N + 1 + M_g)) :=
      hdf_comp.comp h_in_df
    have h_dg_term : Computable (fun N : ℕ => dg (N + 1 + M_f)) :=
      hdg_comp.comp h_in_dg
    exact Primrec.nat_mul.to_comp.comp h_df_term h_dg_term
  · -- Positivity.
    intro N
    exact Nat.mul_pos (hdf_pos _) (hdg_pos _)
  · -- Modulus implication.
    intro N x y hxy
    have h_df_pos : 0 < df (N + 1 + M_g) := hdf_pos _
    have h_dg_pos : 0 < dg (N + 1 + M_f) := hdg_pos _
    -- Both factors divide the product, both positive.
    have h_df_le_prod : df (N + 1 + M_g) ≤ df (N + 1 + M_g) * dg (N + 1 + M_f) :=
      Nat.le_mul_of_pos_right _ h_dg_pos
    have h_dg_le_prod : dg (N + 1 + M_f) ≤ df (N + 1 + M_g) * dg (N + 1 + M_f) :=
      Nat.le_mul_of_pos_left _ h_df_pos
    -- Hence `1 / d_mul N ≤ 1 / df(...)` and `≤ 1 / dg(...)`.
    have h_xy_le_df :
        |((x : ℝ)) - ((y : ℝ))| ≤ (1 : ℝ) / (df (N + 1 + M_g) : ℝ) := by
      refine le_trans hxy ?_
      apply one_div_le_one_div_of_le
      · exact_mod_cast h_df_pos
      · exact_mod_cast h_df_le_prod
    have h_xy_le_dg :
        |((x : ℝ)) - ((y : ℝ))| ≤ (1 : ℝ) / (dg (N + 1 + M_f) : ℝ) := by
      refine le_trans hxy ?_
      apply one_div_le_one_div_of_le
      · exact_mod_cast h_dg_pos
      · exact_mod_cast h_dg_le_prod
    -- Apply f, g moduli.
    have h_f_mod : |f x - f y| ≤ (1 : ℝ) / 2 ^ (N + 1 + M_g) :=
      hdf_mod (N + 1 + M_g) x y h_xy_le_df
    have h_g_mod : |g x - g y| ≤ (1 : ℝ) / 2 ^ (N + 1 + M_f) :=
      hdg_mod (N + 1 + M_f) x y h_xy_le_dg
    -- Decomposition.
    have h_split :
        (f * g) x - (f * g) y = f x * (g x - g y) + g y * (f x - f y) := by
      show f x * g x - f y * g y = f x * (g x - g y) + g y * (f x - f y)
      ring
    have h_tri :
        |(f * g) x - (f * g) y| ≤ |f x| * |g x - g y| + |g y| * |f x - f y| := by
      rw [h_split]
      calc |f x * (g x - g y) + g y * (f x - f y)|
          ≤ |f x * (g x - g y)| + |g y * (f x - f y)| := abs_add_le _ _
        _ = |f x| * |g x - g y| + |g y| * |f x - f y| := by rw [abs_mul, abs_mul]
    -- Bound each term.
    have h_term_f :
        (M_f : ℝ) * (1 / 2 ^ (N + 1 + M_f)) ≤ 1 / 2 ^ (N + 1) := by
      rw [mul_one_div]
      have hp1 : (0 : ℝ) < 2 ^ (N + 1 + M_f) := by positivity
      have hp2 : (0 : ℝ) < 2 ^ (N + 1) := by positivity
      rw [div_le_div_iff₀ hp1 hp2, one_mul]
      have h_pow_eq :
          (2 : ℝ) ^ (N + 1 + M_f) = 2 ^ (N + 1) * 2 ^ M_f := by
        rw [pow_add]
      rw [h_pow_eq]
      have h_M_f_le : (M_f : ℝ) ≤ (2 : ℝ) ^ M_f := by
        have h_nat : M_f ≤ 2 ^ M_f := Nat.lt_two_pow_self.le
        exact_mod_cast h_nat
      have h_2N1_nn : (0 : ℝ) ≤ 2 ^ (N + 1) := by positivity
      nlinarith
    have h_term_g :
        (M_g : ℝ) * (1 / 2 ^ (N + 1 + M_g)) ≤ 1 / 2 ^ (N + 1) := by
      rw [mul_one_div]
      have hp1 : (0 : ℝ) < 2 ^ (N + 1 + M_g) := by positivity
      have hp2 : (0 : ℝ) < 2 ^ (N + 1) := by positivity
      rw [div_le_div_iff₀ hp1 hp2, one_mul]
      have h_pow_eq :
          (2 : ℝ) ^ (N + 1 + M_g) = 2 ^ (N + 1) * 2 ^ M_g := by
        rw [pow_add]
      rw [h_pow_eq]
      have h_M_g_le : (M_g : ℝ) ≤ (2 : ℝ) ^ M_g := by
        have h_nat : M_g ≤ 2 ^ M_g := Nat.lt_two_pow_self.le
        exact_mod_cast h_nat
      have h_2N1_nn : (0 : ℝ) ≤ 2 ^ (N + 1) := by positivity
      nlinarith
    -- Combine.
    have h_step1 :
        |f x| * |g x - g y| ≤ (M_f : ℝ) * (1 / 2 ^ (N + 1 + M_f)) :=
      mul_le_mul (h_f_bnd x) h_g_mod (abs_nonneg _) (Nat.cast_nonneg _)
    have h_step2 :
        |g y| * |f x - f y| ≤ (M_g : ℝ) * (1 / 2 ^ (N + 1 + M_g)) :=
      mul_le_mul (h_g_bnd y) h_f_mod (abs_nonneg _) (Nat.cast_nonneg _)
    have h_2N1_collapse :
        (1 : ℝ) / 2 ^ (N + 1) + 1 / 2 ^ (N + 1) = 1 / 2 ^ N := by
      rw [pow_succ]; ring
    linarith

end ComputableAnalysis.L2
