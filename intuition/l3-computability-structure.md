---
topic: l3-computability-structure
status: intuition
created: 2026-06-01
related:
  - l1-computable-reals (Axiom 3 depends on it)
  - l4-instances (built on top)
  - l5-main-theorems (entire downstream)
source_anchor: literature/papers/PourEl-Richards-chapt2.md
---

# L3 — Computability structures on a Banach space: mental model

This file captures the *why* of Pour-El & Richards' three-axiom framework — the keystone of the project. It is informal prose. No formal statements (Rule 3); those go in `claims/l3-computability-structure/`.

## The one-sentence picture

A **computability structure** on a Banach space `X` is the data of *which sequences of vectors `(x_n)` in `X` count as computable*, subject to just three axioms that pin computability to the three structural pieces of a Banach space (linearity, completeness, norm) and to nothing else.

It is a *predicate over sequences*, layered onto a pre-existing Banach space — not a new kind of space. This matches our project's architectural commitment #1: we add structure, we do not replace `NormedSpace`.

## Why sequences, not points

The naïve question is "which *points* of `X` are computable?". That isn't enough, because:

1. Analysis is topological, and on a Banach space the topology is given by sequences (convergence, limits, closures). If you can't say what a *computable Cauchy sequence* is, you can't say what an *effective limit* is, and the whole machinery of approximation collapses.
2. Recursion theory itself has the same shape: "computable function `ℕ → ℕ`" really *is* "computable sequence of natural numbers `a(0), a(1), …`". The sequence is primitive; the point (a single value) is the constant case (Ch. 2:55).

So the axiomatised object is `IsComputableSeq : (ℕ → X) → Prop`. A point `x : X` is computable iff `IsComputableSeq (fun _ => x)`. We get points from sequences, not the other way around.

This is also why the L3 typeclass can sit cleanly alongside Mathlib's `NormedSpace` infrastructure: Mathlib's analysis is already sequence-flavoured (`Filter.Tendsto`, `CauchySeq`), so the predicate fits the existing API rather than fighting it.

## Why three axioms — and exactly three

Pour-El & Richards' move (Ch. 2:21) is to ask: what is the minimal interaction needed between "computability" and the structure already present on a Banach space? A Banach space has three structural ingredients:

- **Linearity** — addition and scalar multiplication;
- **Completeness** — limits of Cauchy sequences exist;
- **Norm** — a distance to the origin.

So three axioms:

1. **Linear Forms axiom.** Computable sequences are closed under "computable finite linear combinations". If `(x_n)` and `(y_n)` are computable in `X`, and `(α_{n,k})`, `(β_{n,k})` are computable double sequences of scalars, and `d : ℕ → ℕ` is recursive, then the sequence `s_n = Σ_{k=0..d(n)} (α_{n,k} x_k + β_{n,k} y_k)` is computable. *(Ch. 2:66.)*

2. **Limits axiom.** Computable sequences are closed under *effective* limits. If `(x_{n,k})` is a computable double sequence and converges to `(x_n)` effectively in `k` and `n` (i.e., there is a recursive `e` with `‖x_{n,k} − x_n‖ ≤ 2^{-N}` for `k ≥ e(n,N)`), then `(x_n)` is computable. *(Ch. 2:73.)*

3. **Norm axiom.** If `(x_n)` is a computable sequence in `X`, then the sequence of norms `(‖x_n‖)` is a computable sequence of reals. *(Ch. 2:75.)*

Plus a non-vacuity clause: at least one computable sequence exists, hence the zero sequence is computable (Ch. 2:77). Without this you would have the trivial structure where *nothing* is computable, which satisfies the three axioms vacuously.

## What each axiom rules in

| Axiom | What it gives you |
|---|---|
| Linear Forms | Sub-sequencing along any recursive index (composition property), interleaving two computable sequences (insertion property), and more generally any "rearrangement-by-recursive-bookkeeping". These are derived in Ch. 2:81–114 as corollaries. |
| Limits | The whole game of *effective approximation*: every computable sequence is the effective limit of "simple" sequences (e.g. polynomials with rational coefficients, when the space has such a dense set). This is what makes the Effective Density Lemma (Ch. 2:204) possible. |
| Norm | Forces compatibility between computability and the metric: you can compute distances, so you can talk about "approximating to within 2^{-N}" *uniformly* in the input. Without it, computability would be detached from the analytic structure. |

## What each axiom rules out (the L^∞ counterexample)

Example 2 in Ch. 2 (lines 297–321) is the most illuminating "what could go wrong" picture. Suppose you tried to put a computability structure on `L^∞[0,1]` that obeyed the natural condition (C): *characteristic functions of intervals `[a_n, b_n]` with computable endpoints are computable*. Then via the Linear Forms axiom you can build `χ_{[a_n,b_n]} + χ_{[1/2,1]}`, and via the Norm axiom you must be able to *compute* its `L^∞` norm. But the `L^∞` norm of that sum is `2` if `n ∈ D` and `1` if `n ∉ D`, where `D` is an r.e. nonrecursive set — i.e. you've just computed the characteristic function of `D`, a contradiction.

Lesson: the three axioms are *tight*. They force computability to be compatible with the norm topology, and on spaces whose topology is "too rich" (like `L^∞`, which isn't even separable), no natural computability structure can exist. This is a feature, not a bug — it tells us *exactly which* Banach spaces will host a computability structure (broadly: the separable ones).

## Why three is also enough — the stability lemma

The Stability Lemma (Ch. 2:248) says: if two computability structures `S'`, `S''` on `X` share a common *effective generating set* `(e_n)` (a computable sequence whose linear span is dense in `X`), then `S' = S''`. So once you fix a "natural" dense computable sequence — monomials in `C[a,b]`, trigonometric polynomials, the standard basis of `ℓ^p` — the three axioms pin down the computability structure uniquely.

This is the deepest content of Ch. 2 and the reason the framework is not just one of many possible axiomatisations: in practice (on separable Banach spaces with a standard generating set), the three axioms are both *minimal* (you can't drop any) and *maximal* (you can't add a new one without redundancy). That's how P-R gets to claim that this *is* "the" notion of computability on a Banach space, not merely *a* notion.

For our Mathlib formalisation this matters: it means uniqueness is a theorem to be proved (the Stability Lemma is downstream work), not an instance-design problem. We can have multiple `ComputabilityStructure` instances on the same space without inconsistency — the lemma tells us they agree on what matters.

## Where Axiom 3 reaches down into L1

Axiom 3 mentions "computable sequence of real numbers" without defining it inside Ch. 2 — it imports the L1 notion from Ch. 0. This is the *only* cross-layer dependency of L3, and it is the reason our current goal stubs `claims/l1-computable-reals/is-computable-seq-real.md` (C4): we cannot state L3's third axiom precisely without that L1 term.

The dependency is one-directional: L3 uses L1, L1 has no need for L3.

## Falsification conditions

What would make us *abandon* this framework?

1. **Inconsistency**: if the three axioms together implied a contradiction in every Banach space. Ruled out empirically by the explicit intrinsic structures on `C[a,b]`, `L^p`, `ℓ^p` (Sections 2–4 of Ch. 2).
2. **Failure to discriminate**: if every set-of-sequences satisfying the three axioms were the "intrinsic" one in every case. Ruled out by the ad-hoc structures in Section 7 (Ch. 2:338, 354) — these satisfy the axioms but differ from intrinsic structure. The ad-hoc structures are not nuisance: the Eigenvector Theorem in Ch. 4 *uses* one of them.
3. **Failure to capture intuition**: if on some standard space the framework gave a notion of "computable" that flatly disagreed with the working definition used by analysts (e.g. Grzegorczyk-Lacombe on `C[a,b]`). Section 2 of Ch. 2 (lines 126–151) shows the two agree on `C[a,b]`. Sections 3, 4 do the same for `L^p` and `ℓ^p`.

None of these falsifiers fire. The framework survives.

## Residual unknowns for the Mathlib build

These are the questions we *will* have to resolve in the L3 claim file and downstream:

- **How to encode "computable sequence of vectors" in Lean.** Mathlib's `Computable : (α → β) → Prop` requires `[Primcodable α] [Primcodable β]`. A general Banach space `E` is not `Primcodable`. The honest path is to make `IsComputableSeq : (ℕ → E) → Prop` a *primitive* predicate of the typeclass — not derived from Mathlib's `Computable` — and then state the axioms as conditions relating it to `Computable` on `ℕ`-valued data (the scalar sequences, the index functions `d`, the modulus `e`).

- **Scalars: rational or real?** P-R uses "computable double sequence of real (or complex) numbers" for the coefficients in Axiom 1. In Lean we have a choice: state it for `ℝ` (cleaner, matches P-R) or for `ℚ` (computationally explicit). The Effective Density Lemma will eventually reduce real-coefficient claims to rational-coefficient ones, so the choice is technical, not architectural.

- **Real vs complex.** P-R waves this away as "mutatis mutandis" (Ch. 2:49). In Lean we'll likely parametrise the typeclass by a `NontriviallyNormedField` (or similar) covering both cases.

- **Effective separability is a separate concept.** It's *not* one of the three axioms — it's an additional property a particular `(X, S)` may have (existence of an effective generating set). So our typeclass should not include effective separability; that's a downstream definition.

- **The non-vacuity clause.** Whether to bake "the zero sequence is computable" into the typeclass as an axiom-field, or derive it from a "there exists a computable sequence" existence axiom, is a small design choice with implications for how easy it is to instantiate. Likely cleanest: a single axiom-field `zero_seq : IsComputableSeq (fun _ => 0)`.

## What this intuition file is *not*

It is not a definition, not a theorem, not the typeclass design. Those go in `claims/l3-computability-structure/axioms.md` next (C2/C3), with verbatim line pointers into `literature/papers/PourEl-Richards-chapt2.md`. The intuition here is the rationale that pre-commits us to *those* three axioms and not a fourth.
