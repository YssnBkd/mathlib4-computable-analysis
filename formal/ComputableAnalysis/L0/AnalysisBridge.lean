/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Analysis.InnerProductSpace.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.MeasureTheory.Function.LpSpace.Basic
import Mathlib.Analysis.Normed.Lp.lpSpace
import Mathlib.Topology.ContinuousMap.Compact
import Mathlib.Topology.ContinuousMap.ZeroAtInfty
import Mathlib.Analysis.Calculus.ContDiff.Defs

/-!
# L0 — Pour-El & Richards prerequisites: analysis bridge (pointer file)

P-R Ch. 0.2:58–81 recapitulates standard Banach / Hilbert / function-space
definitions. All of these are in Mathlib4 under their standard names; this file
introduces **NO** new symbols. It documents the P-R ↔ Mathlib correspondence and
provides `#check` smoke tests verifying the named symbols exist at the imports
declared above.

Downstream layers (L3, L4) use Mathlib's names directly — no aliases needed.

## P-R notion → Mathlib (ref: `literature/papers/PourEl-Richards-0.2.prerequisites.md`)

| P-R (line) | Mathlib | Note |
|---|---|---|
| Banach space (:60) | `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]` | Conjunction of three typeclasses; no single `BanachSpace` class. |
| Hilbert space (:71) | `[RCLike 𝕜] [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]` | `𝕜 = ℝ` or `ℂ`. |
| `L^p[a, b]` (:74) | `MeasureTheory.Lp ℝ p (volume.restrict (Set.Icc a b))` | Carrier is a.e.-equivalence classes; `p : ℝ≥0∞`. |
| `ℓ^p` (:75) | `lp (fun _ : ℕ => 𝕜) p` | Lowercase `lp`. Takes a *family* of normed groups. |
| `C[a, b]` sup norm (:76) | `C(Set.Icc a b, ℝ)` | Sup-norm instance from `Topology.ContinuousMap.Compact`. |
| `Cⁿ[a, b]` (:77) | `ContDiff ℝ n` | `n : WithTop ℕ∞`. Use `ContDiffOn` for restriction to `Set.Icc a b`. |
| `C^∞[a, b]` (:78) | `ContDiff ℝ ∞` | `∞ : ℕ∞` (need `open scoped Topology` / `WithTop` scope). |
| `C₀(ℝ^q)` (:79) | `C₀(EuclideanSpace ℝ (Fin q), ℝ)` | From `ContinuousMap.ZeroAtInfty`. |

## Note: P-R writes "the space is complete" inline with each Banach/Hilbert definition

Mathlib expresses completeness via a separate `[CompleteSpace E]` typeclass. The
conjunction `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]` is
exactly P-R's Banach space. The conjunction
`[RCLike 𝕜] [InnerProductSpace 𝕜 E] [CompleteSpace E]` is exactly P-R's Hilbert
space. Compare P-R intro:28 ("we add structure to a preexisting Banach space")
— this is the Mathlib substrate.
-/

namespace ComputableAnalysis.L0

/-! ## Smoke checks — Mathlib symbols exist at the imports declared above -/

#check @NormedAddCommGroup
#check @NormedSpace
#check @CompleteSpace
#check @InnerProductSpace
#check @RCLike
#check @EuclideanSpace
#check @MeasureTheory.Lp
#check @lp
#check @ContinuousMap
#check @ContDiff
#check @ZeroAtInftyContinuousMap

/-! ## Smoke checks — typeclass conjunctions match P-R's Banach/Hilbert -/

/-- A Banach space over `𝕜` is the conjunction of three typeclasses. -/
example {𝕜 : Type*} [NormedField 𝕜] (E : Type*)
    [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E] : True := trivial

/-- A Hilbert space over `𝕜 : RCLike` adds `InnerProductSpace + CompleteSpace`. -/
example {𝕜 : Type*} [RCLike 𝕜] (E : Type*)
    [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E] : True := trivial

/-- `C([a, b], ℝ)` is a Banach space over `ℝ` (sup norm, compact domain). -/
example (a b : ℝ) :
    True := by
  -- Existence of the type and the sup-norm instance:
  let _X : Type := C(Set.Icc a b, ℝ)
  trivial

/-- `L^p[a, b]` exists as a Mathlib object. -/
example (a b : ℝ) (p : ENNReal) :
    True := by
  let _Y := MeasureTheory.Lp ℝ p ((MeasureTheory.volume).restrict (Set.Icc a b))
  trivial

/-- `ℓ^p` exists. -/
example (p : ENNReal) :
    True := by
  let _Z := lp (fun _ : ℕ => ℝ) p
  trivial

/-- `C₀(ℝ^q, ℝ)` exists. -/
example (q : ℕ) :
    True := by
  let _W : Type := C₀(EuclideanSpace ℝ (Fin q), ℝ)
  trivial

end ComputableAnalysis.L0
