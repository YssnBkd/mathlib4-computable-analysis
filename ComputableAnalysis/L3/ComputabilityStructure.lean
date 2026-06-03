/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import Mathlib.Analysis.RCLike.Basic
import Mathlib.Analysis.Normed.Module.Basic
import Mathlib.Computability.Partrec
import Mathlib.Data.Nat.Pairing
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import ComputableAnalysis.L1.ComputableSeqReal

/-!
# L3 — `ComputabilityStructure` typeclass on a Banach space (Pour-El & Richards Ch. 2)

This file defines the architectural keystone of the project: a *computability
structure* on a Banach space `E` over scalar field `𝕜` (real or complex), as
the data of a predicate on sequences `(ℕ → E) → Prop` satisfying three axioms
plus a non-vacuity clause.

The typeclass is **additive** in the Mathlib sense (project commitment #1): we
add structure to Mathlib's pre-existing Banach spaces rather than building a
parallel category of "computable Banach spaces". A given `E` may carry zero,
one, or several `ComputabilityStructure` instances; uniqueness under mild
side-conditions (effective separability) is a separate downstream result
(P-R Ch. 2 Stability Lemma, layer L4).

## Three axioms (P-R Ch. 2 §1)

- **Axiom 1 (Linear Forms)** — closure under finite scalar-linear combinations
  whose coefficients are themselves computable double sequences of scalars and
  whose length is bounded by a recursive function.
- **Axiom 2 (Limits)** — closure under effective limits of computable double
  sequences.
- **Axiom 3 (Norms)** — if `(x_n)` is a computable sequence, then `(‖x_n‖)` is
  a computable sequence of real numbers in the L1 sense.

And a non-vacuity clause:

- **(NV)** — the constant zero sequence is computable; equivalently, at least
  one computable sequence exists.

## Scalar field handling

P-R Ch. 2:49 handles `K = ℝ` and `K = ℂ` via *mutatis mutandis*. In Lean we
parameterize over `[RCLike 𝕜]` (Mathlib's typeclass for "ℝ or ℂ") and abstract
the L1 notion of "computable sequence of scalars" via a small auxiliary
typeclass `ScalarComputableSeq 𝕜`. For `𝕜 = ℝ` we provide the canonical
instance (defer to L1's `IsComputableSeqReal`); for `𝕜 = ℂ` the instance
requires L1's deferred `IsComputableSeqComplex` and is added when that lands.

This deliberately keeps the typeclass field-shape final so that adding the `ℂ`
instance later is a one-liner once L1 ships `IsComputableSeqComplex`.

## Double-sequence decoding

Per `claims/l3-computability-structure/axioms.md`: a computable double sequence
in a type `α` is a function `ℕ × ℕ → α` whose `Nat.unpair`-precomposed reindex
is in the single-sequence predicate. The choice of pairing (max-based vs.
Cantor) is immaterial — see the claim file's "formalization remarks" for the
recursive-bijection argument.

## What this file is NOT

This is the *axiom-statement* file. Out of scope (deferred to L4):

- The Stability Lemma (uniqueness of `IsComputableSeq` under effective
  separability).
- Concrete instances on `C[a, b]`, `L^p`, `ℓ^p`, separable Hilbert.
- Effective separability as a predicate / mixin.

## References

- Pour-El, M.B. & Richards, J.I., *Computability in Analysis and Physics*,
  Cambridge UP 1989, Ch. 2 §1. Verbatim at
  `literature/papers/PourEl-Richards-chapt2.md:49-77`.
- Design doc: `claims/l3-computability-structure/axioms.md` (8 DA rounds clean).
-/

namespace ComputableAnalysis.L3

open scoped BigOperators

/-! ## §1 — Scalar-side predicate (L1 → L3 bridge for the scalar field) -/

/-- A typeclass providing the L1 notion of "computable sequence of scalars"
for a scalar field `𝕜 ∈ {ℝ, ℂ}` (i.e. `RCLike`). For `𝕜 = ℝ` the canonical
instance defers to `ComputableAnalysis.L1.IsComputableSeqReal`. The `𝕜 = ℂ`
instance awaits L1's deferred `IsComputableSeqComplex`. -/
class ScalarComputableSeq (𝕜 : Type*) [RCLike 𝕜] where
  /-- The predicate "`(s_n)` is a computable sequence of scalars in `𝕜`". -/
  IsComputableSeq : (ℕ → 𝕜) → Prop

/-- Canonical instance for `𝕜 = ℝ`: defer to L1's `IsComputableSeqReal`. -/
instance : ScalarComputableSeq ℝ where
  IsComputableSeq := ComputableAnalysis.L1.IsComputableSeqReal

/-! ## §2 — The `ComputabilityStructure` typeclass

This is the L3 keystone. Per CLAUDE.md commitment #1, we add structure to a
Mathlib Banach space rather than define a parallel category. -/

/-- A **computability structure** on a Banach space `E` over `𝕜` (real or
complex), per Pour-El & Richards Ch. 2 §1. The data is a predicate on
sequences `(ℕ → E) → Prop` and proofs of the three axioms plus non-vacuity.

ref: `literature/papers/PourEl-Richards-chapt2.md:49-77`. -/
class ComputabilityStructure
    (𝕜 : Type*) [RCLike 𝕜] [ScalarComputableSeq 𝕜]
    (E : Type*) [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E] where
  /-- The primitive predicate "`(x_n)` is a computable sequence in `E`". -/
  IsComputableSeq : (ℕ → E) → Prop
  /-- **Axiom 1 (Linear Forms).** If `(x_n)` and `(y_n)` are computable
  sequences in `E`, `(α_{n,k})` and `(β_{n,k})` are computable double sequences
  of scalars in `𝕜`, and `d : ℕ → ℕ` is recursive, then the sequence
  `s_n := Σ_{k=0}^{d(n)} (α_{n,k} · x_k + β_{n,k} · y_k)` is in
  `IsComputableSeq`.

  ref: P-R Ch. 2:66-72. -/
  isComputableSeq_linearCombination :
    ∀ (x y : ℕ → E) (α β : ℕ × ℕ → 𝕜) (d : ℕ → ℕ),
      IsComputableSeq x → IsComputableSeq y →
      ScalarComputableSeq.IsComputableSeq (fun n => α (Nat.unpair n)) →
      ScalarComputableSeq.IsComputableSeq (fun n => β (Nat.unpair n)) →
      Computable d →
      IsComputableSeq
        (fun n => ∑ k ∈ Finset.range (d n + 1), (α (n, k) • x k + β (n, k) • y k))
  /-- **Axiom 2 (Limits).** If `(x_{n,k})` is a computable double sequence in
  `E` converging effectively (with modulus `e : ℕ × ℕ → ℕ`) to `(y_n)`, then
  `(y_n)` is in `IsComputableSeq`. The effective-convergence clause says: for
  all `n`, `N` and all `k ≥ e(n, N)`, `‖x_{n,k} − y_n‖ ≤ 1 / 2^N`.

  ref: P-R Ch. 2:58-64, 73. -/
  isComputableSeq_of_effectiveLimit :
    ∀ (x : ℕ × ℕ → E) (y : ℕ → E) (e : ℕ × ℕ → ℕ),
      IsComputableSeq (fun n => x (Nat.unpair n)) →
      Computable e →
      (∀ n N : ℕ, ∀ k : ℕ, k ≥ e (n, N) → ‖x (n, k) - y n‖ ≤ 1 / 2 ^ N) →
      IsComputableSeq y
  /-- **Axiom 3 (Norms).** If `(x_n)` is in `IsComputableSeq`, then the
  real-valued sequence `(‖x_n‖)` is an L1-computable sequence of reals.

  ref: P-R Ch. 2:75. -/
  isComputableSeqReal_norm :
    ∀ (x : ℕ → E), IsComputableSeq x →
      ComputableAnalysis.L1.IsComputableSeqReal (fun n => ‖x n‖)
  /-- **(NV) Non-vacuity.** The constant zero sequence is in `IsComputableSeq`.
  Equivalent to "∃ a computable sequence" modulo Axiom 1 — see the design
  doc's §(NV) for the equivalence argument; we encode the form that gives the
  user a named handle.

  ref: P-R Ch. 2:77. -/
  zero_seq : IsComputableSeq (fun _ => (0 : E))

/-! ## §3 — Derived notions

Once a `ComputabilityStructure` is in scope, two derived notions follow
directly from the predicate. Both are concrete `def`s (no `sorry`), per the
project's sorry policy. -/

variable {𝕜 : Type*} [RCLike 𝕜] [ScalarComputableSeq 𝕜]
variable {E : Type*} [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]
variable [ComputabilityStructure 𝕜 E]

/-- **Computable element** of `E`: the constant sequence `(x, x, …)` is in
`IsComputableSeq`.

ref: P-R Ch. 2:55. -/
def IsComputableElement (x : E) : Prop :=
  ComputabilityStructure.IsComputableSeq (𝕜 := 𝕜) (fun _ => x)

/-- **Computable double sequence** in `E`: the `Nat.unpair`-reindexed
single sequence is in `IsComputableSeq`. Convenience wrapper for the
Axiom 2 / Axiom 1 use sites.

ref: P-R Ch. 2:53. -/
def IsComputableDoubleSeq (x : ℕ × ℕ → E) : Prop :=
  ComputabilityStructure.IsComputableSeq (𝕜 := 𝕜) (fun n => x (Nat.unpair n))

end ComputableAnalysis.L3
