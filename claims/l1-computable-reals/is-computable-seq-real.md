---
id: is-computable-seq-real
topic: l1-computable-reals
status: our_construction
lean_target:
  - formal/ComputableAnalysis/L1/ComputableSeqReal.lean
  - formal/ComputableAnalysis/L1/ComputableSeqComplex.lean
created: 2026-06-01
sources:
  - literature/papers/PourEl-Richards-chapt0.md
depends_on: []
referenced_by:
  - claims/l3-computability-structure/axioms.md  # Axiom 1 invokes IsComputableSeqComplex (when K=ℂ); Axiom 3 (Norms) invokes IsComputableSeqReal
---

# L1 — `IsComputableSeqReal`: the L3-facing stub

**Status: `our_construction`.** This is a **stub claim**: it pins down the meaning of "computable sequence of real numbers" so that L3 Axiom 3 (`claims/l3-computability-structure/axioms.md`, A3) has a precise referent. Full L1 elaboration (computable points as the constant-sequence case, closure under field operations, the subfield structure of `ℝ_c`, etc.) is downstream and out of scope for the current goal `l3-computability-structure-axioms`.

## Setup

We work over Mathlib's pre-existing `ℝ` (`Mathlib.Data.Real.Basic`). Per project commitment #3, we define a *predicate* on sequences of reals, not a new type.

## Auxiliary definition: computable sequence of rationals

A sequence `(r_k) : ℕ → ℚ` is a **computable sequence of rationals** if there exist Mathlib-`Computable` functions `a, b, s : ℕ → ℕ` with `b k ≠ 0` for all `k`, such that

```
r_k = (-1)^{s k} · (a k / b k)   for all k.
```

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt0.md:46–50`:
>
> > "Definition 1. A sequence `{r_k}` of rational numbers is computable if there exist three recursive functions `a, b, s` from `ℕ` to `ℕ` such that `b(k) ≠ 0` for all `k` and
> >
> > `r_k = (-1)^{s(k)} · a(k)/b(k)` for all `k`."

A **computable double sequence of rationals** `(r_{n,k}) : ℕ × ℕ → ℚ` is one whose Cantor-paired re-indexing `ℕ → ℚ` is a computable sequence of rationals.

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt0.md:189`:
>
> > "A double sequence will be called computable if it is mapped onto a computable sequence by one of the standard recursive pairing functions from `ℕ × ℕ` onto `ℕ`. Similarly for triple or `q`-fold sequences."

## Definition: `IsComputableSeqReal`

We adopt P-R's **Definition 5a** as the primary form (cleaner because the index `k` *is* the precision parameter, so no separate modulus function is needed):

> `IsComputableSeqReal (x : ℕ → ℝ) : Prop` holds iff there exists a computable double sequence of rationals `(r_{n,k}) : ℕ × ℕ → ℚ` such that
>
> ```
> |r_{n,k} − x_n| ≤ 1 / 2^k     for all n, k.
> ```

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt0.md:203–207`:
>
> > "Definition 5a. A sequence of real numbers `{x_n}` is computable (as a sequence) if there is a computable double sequence of rationals `{r_{n k}}` such that
> >
> > `|r_{n k} − x_n| ≤ 2^{-k}` for all `k` and `n`."

### Equivalence with Definition 5

P-R also gives **Definition 5** (with an explicit recursive modulus `e(n,N)` rather than the index serving as the precision):

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt0.md:200`:
>
> > "Definition 5. A sequence of real numbers `{x_n}` is computable (as a sequence) if there is a computable double sequence of rationals `{r_{n k}}` such that `r_{n k} → x_n` as `k → ∞`, effectively in `k` and `n`."

The two are equivalent — `5a ⇒ 5` is trivial (take `e(n,N) := N`); `5 ⇒ 5a` is proved at `PourEl-Richards-chapt0.md:209–215` by subsequencing: given `5` with modulus `e`, replace `r_{n,k}` by `r'_{n,k} := r_{n, e(n,k)}`.

We adopt 5a because it removes the modulus parameter from the predicate's signature.

## Definition: `IsComputableSeqComplex`

For sequences of complex numbers we use P-R's coordinatewise extension.

> `IsComputableSeqComplex (z : ℕ → ℂ) : Prop` holds iff both `n ↦ (z n).re` and `n ↦ (z n).im` satisfy `IsComputableSeqReal`.

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt0.md:216`:
>
> > "The above definitions extend in the obvious way to complex numbers and to `q`-vectors. Thus a sequence of complex numbers is called computable if its real and imaginary parts are computable sequences. A sequence of `q`-vectors is called computable if each of its components is a computable sequence of real or complex numbers."

This is the L1 predicate that L3 Axiom 1 invokes when the underlying scalar field of a Banach space is `K = ℂ`. (L3 Axiom 3 — norms — always returns `ℝ`, so it only ever references `IsComputableSeqReal`, regardless of whether the underlying Banach space is real or complex.)

A `q`-vector extension `IsComputableSeqVec : (ℕ → Fin q → 𝕜) → Prop` (componentwise) follows from the same source quote but is deferred to a downstream claim — L3 does not need it directly.

## Effective convergence (referenced by L3 Axiom 2)

For completeness — and because L3 Axiom 2 (Limits) reuses the same effective-convergence notion at the Banach-space level — we record P-R's Definition 4:

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt0.md:191–195`:
>
> > "Definition 4. Let `{x_{n k}}` be a double sequence of reals and `{x_n}` a sequence of reals such that, as `k → ∞`, `x_{n k} → x_n` for each `n`. We say that `x_{n k} → x_n` effectively in `k` and `n` if there is a recursive function `e : ℕ × ℕ → ℕ` such that for all `n, N`:
> >
> > `k ≥ e(n, N)` implies `|x_{n k} − x_n| ≤ 2^{-N}`."

This definition is what L3's Axiom 2 (Limits) lifts to a Banach space `X` (replace `|·|` with `‖·‖_X`).

## What this stub is *not*

This is **not** the full L1 layer. The following are intentionally deferred:

- `IsComputableReal : ℝ → Prop` (constant-sequence case) — a future L1 milestone.
- Closure under arithmetic (sum, product, reciprocal where nonzero, …) — proved in P-R Ch. 0, but downstream of this stub.
- The countable-subfield theorem — downstream.
- The equivalence with Definition 5 is *stated* here but not proved; the proof in Ch. 0:209 is short and can be discharged when L1 is elaborated.
- Effective sign-decidability (P-R Proposition 0, `chapt0.md:64`) — separate downstream claim.

## Why this stub is sufficient for the L3 axioms goal

L3 Axiom 3 says: "if `(x_n)` is a computable sequence in `X`, then `n ↦ ‖x_n‖_X` is a computable sequence of reals." The phrase "computable sequence of reals" is the predicate `IsComputableSeqReal` defined above. That is the totality of the L1 → L3 reach-down. No further L1 content is needed to make the L3 axioms well-formed.

## Dependencies

| Layer | Artifact | Why |
|---|---|---|
| L0 | `Mathlib.Computability.Partrec` (`Computable`) | "recursive functions `a, b, s : ℕ → ℕ`" in Definition 1 |
| L0 | `Mathlib.Data.Nat.Pairing` (`Nat.pair` / `Nat.unpair`) | "computable double sequence of rationals" decoding |
| Mathlib | `Mathlib.Data.Real.Basic` (`ℝ`) | The type we predicate over |
| Mathlib | `Mathlib.Data.Rat.Defs` (`ℚ`) | Rational approximants |
