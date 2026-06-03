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
introduces **NO** new symbols. It documents the P-R ↔ Mathlib correspondence;
the imports above pin the Mathlib modules that supply each named symbol, so this
file compiling is itself a check that those modules resolve.

Downstream layers (L3, L4) use Mathlib's names directly — no aliases needed.

## P-R notion → Mathlib (ref: `literature/papers/PourEl-Richards-0.2.prerequisites.md`)

* **Banach space** (:60): `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]` — a
  conjunction of three typeclasses; there is no single `BanachSpace` class.
* **Hilbert space** (:71): adds `[RCLike 𝕜]`, `[InnerProductSpace 𝕜 E]`, and
  `[CompleteSpace E]` to `[NormedAddCommGroup E]`, with `𝕜 = ℝ` or `ℂ`.
* **`L^p[a, b]`** (:74): `MeasureTheory.Lp ℝ p (volume.restrict (Set.Icc a b))` — the carrier
  is a.e.-equivalence classes; `p : ℝ≥0∞`.
* **`ℓ^p`** (:75): `lp (fun _ : ℕ => 𝕜) p` — lowercase `lp`, takes a *family* of normed groups.
* **`C[a, b]`** with sup norm (:76): `C(Set.Icc a b, ℝ)` — sup-norm instance from
  `Topology.ContinuousMap.Compact`.
* **`Cⁿ[a, b]`** (:77): `ContDiff ℝ n` with `n : WithTop ℕ∞`; use `ContDiffOn` to restrict
  to `Set.Icc a b`.
* **`C^∞[a, b]`** (:78): `ContDiff ℝ ∞` (`∞ : ℕ∞`; needs `open scoped Topology` / `WithTop`).
* **`C₀(ℝ^q)`** (:79): `C₀(EuclideanSpace ℝ (Fin q), ℝ)`, from `ContinuousMap.ZeroAtInfty`.

## Note: P-R writes "the space is complete" inline with each Banach/Hilbert definition

Mathlib expresses completeness via a separate `[CompleteSpace E]` typeclass. The
conjunction `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]` is
exactly P-R's Banach space. The conjunction
`[RCLike 𝕜] [InnerProductSpace 𝕜 E] [CompleteSpace E]` is exactly P-R's Hilbert
space. Compare P-R intro:28 ("we add structure to a preexisting Banach space")
— this is the Mathlib substrate.
-/
