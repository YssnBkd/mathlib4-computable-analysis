---
id: axioms
topic: l3-computability-structure
status: our_construction
lean_target: formal/L3/ComputabilityStructure.lean
created: 2026-06-01
sources:
  - literature/papers/PourEl-Richards-chapt2.md
depends_on:
  - claims/l1-computable-reals/is-computable-seq-real.md
related_intuition:
  - intuition/l3-computability-structure.md
---

# Computability structure on a Banach space — the three axioms

**Status: `our_construction`.** This claim defines a notion (the L3 `ComputabilityStructure` typeclass) that we adopt for the project. The substance is transcribed verbatim from Pour-El & Richards, Ch. 2 §1; the formal shape (predicate over sequences, three axiom-fields, non-vacuity clause) is *our* choice of formalization for Mathlib, hence the `our_construction` status rather than `cited_result`.

## Setup

Let `X` be a Banach space over a scalar field `K` (real or complex; P-R treats both via *mutatis mutandis* — Ch. 2:49).

A **computability structure** on `X` is the data of a predicate

```
IsComputableSeq : (ℕ → X) → Prop
```

on sequences of vectors in `X`, satisfying the four conditions (A1)–(A3) and (NV) below.

A point `x : X` is **computable** if the constant sequence `(x, x, x, …)` is in `IsComputableSeq`. (P-R Ch. 2:55.)

A **computable double sequence** in `X` is a sequence `(ℕ × ℕ → X)` whose Cantor-pairing-composed re-indexing `ℕ → X` lies in `IsComputableSeq`. (P-R Ch. 2:53.)

## Auxiliary definition — effective convergence

A computable double sequence `(x_{n,k}) : ℕ × ℕ → X` **converges effectively in k and n** to a sequence `(x_n) : ℕ → X` if there exists a recursive function `e : ℕ × ℕ → ℕ` such that for all `n`, `N`, and all `k ≥ e(n, N)`,

```
‖x_{n,k} − x_n‖_X ≤ 1 / 2^N.
```

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt2.md:58–64`:
>
> > "Definition. The double sequence `{x_{n k}}` converges to the sequence `{x_n}` as `k → ∞`, effectively in `k` and `n`, if there exists a recursive function `e` such that
> >
> > `‖x_{n k} − x_n‖ ≤ 1/2^N`
> >
> > for all `k ≥ e(n, N)`."

## Axiom 1 — Linear Forms

If `(x_n)` and `(y_n)` are computable sequences in `X`, `(α_{n,k})` and `(β_{n,k})` are computable double sequences of scalars in `K`, and `d : ℕ → ℕ` is recursive, then the sequence

```
s_n := Σ_{k=0}^{d(n)} (α_{n,k} · x_k + β_{n,k} · y_k)
```

is in `IsComputableSeq`.

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt2.md:66–72`:
>
> > "Axiom 1 (Linear Forms). Let `{x_n}` and `{y_n}` be computable sequences in `X`, let `{α_{n k}}` and `{β_{n k}}` be computable double sequences of real or complex numbers, and let `d : ℕ → ℕ` be a recursive function. Then the sequence
> >
> > `s_n = Σ_{k=0}^{d(n)} (α_{n k} x_k + β_{n k} y_k)`
> >
> > is computable in `X`."

## Axiom 2 — Limits

If `(x_{n,k})` is a computable double sequence in `X` converging effectively (in `k` and `n`) to `(x_n)`, then `(x_n)` is in `IsComputableSeq`.

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt2.md:73`:
>
> > "Axiom 2 (Limits). Let `{x_{n k}}` be a computable double sequence in `X` such that `{x_{n k}}` converges to `{x_n}` as `k → ∞`, effectively in `k` and `n`. Then `{x_n}` is a computable sequence in `X`."

## Axiom 3 — Norms

If `(x_n)` is in `IsComputableSeq`, then the real-valued sequence `n ↦ ‖x_n‖_X` is a *computable sequence of real numbers* in the L1 sense (see `claims/l1-computable-reals/is-computable-seq-real.md`).

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt2.md:75`:
>
> > "Axiom 3 (Norms). If `{x_n}` is a computable sequence in `X`, then the norms `{‖x_n‖}` form a computable sequence of real numbers."

## (NV) — Non-vacuity

At least one computable sequence in `X` exists; equivalently, the constant zero sequence `(0, 0, 0, …)` is in `IsComputableSeq`.

The equivalence is modulo Axiom 1:

- **Forward** (`∃ x. IsComputableSeq x ⇒ zero_seq`). Take any computable sequence `x` (the existence assumption). Apply Axiom 1 with `(x_n), (y_n) := x, x`, `α_{n,k} = β_{n,k} = 0`, and `d(n) = 0`. The resulting sequence `s_n = Σ_{k=0}^{0} (0 · x_k + 0 · x_k) = 0` is the constant zero sequence, and Axiom 1 declares it computable.
- **Reverse** (`zero_seq ⇒ ∃ x. IsComputableSeq x`). Trivial: the zero sequence is the existential witness.

This equivalence justifies stating the non-vacuity clause as the structure-field `zero_seq : IsComputableSeq (fun _ => 0)` in our Lean typeclass design (cleaner than an unbounded existential).

> *Verbatim source* — `literature/papers/PourEl-Richards-chapt2.md:77`:
>
> > "We assume that at least one computable sequence in `X` exists, whence the sequence `{0, 0, 0, …}` is computable."

## Formalization remarks (non-axiomatic)

These notes are *commentary* on how (A1)–(A3) + (NV) will land in Lean 4 / Mathlib. They are **not** part of the axiom statement; they are recorded here so the downstream typeclass design has a single point of reference.

- **The predicate `IsComputableSeq` is primitive.** Mathlib's `Computable : (α → β) → Prop` requires `[Primcodable α] [Primcodable β]`, which a general Banach space is not. We therefore make `IsComputableSeq` a structure-field of the `ComputabilityStructure` typeclass — not derived from `Computable`. Axioms (A1)–(A3) connect it to Mathlib's `Computable` only on the *scalar* / *integer* / *index* sides.
- **"Computable double sequence" decoding.** Per P-R Ch. 2:53, a double sequence is computable iff its Cantor-pair re-indexing is. In Lean: `IsComputableSeq2 (f : ℕ × ℕ → X) := IsComputableSeq (f ∘ Nat.unpair)`. The `Nat.pair` / `Nat.unpair` machinery is already in Mathlib (project commitment #5).

  *Note on choice of pairing function.* P-R writes "one of the standard recursive pairing functions" (Ch. 2:53) — existentially over the choice of pairing. We commit to `Nat.pair` (the Cantor pairing in `Mathlib.Data.Nat.Pairing`). This commitment is immaterial: any two standard recursive pairings of `ℕ × ℕ` onto `ℕ` differ by a recursive bijection of `ℕ`, and closure under such re-indexing follows from Axiom 1 together with the Composition Property derived at P-R Ch. 2:82–97. A downstream lemma will discharge "the choice of pairing does not affect the predicate" formally.
- **"Computable sequence of scalars" decoding.** For `K = ℝ`: defer to L1's `IsComputableSeqReal`. For `K = ℂ`: defer to L1's `IsComputableSeqComplex`, defined coordinatewise (a complex sequence is computable iff its real and imaginary part sequences are L1-computable). **Both predicates live in `claims/l1-computable-reals/is-computable-seq-real.md`**, so Axiom 1's scalar quantifier has a precise referent for both `K = ℝ` and `K = ℂ`. P-R's *mutatis mutandis* (Ch. 2:49) is honoured by this two-predicate split. (Note: Axiom 3 always returns `ℝ`, since norms are real-valued; so Axiom 3 only ever invokes `IsComputableSeqReal` regardless of the underlying field.)
- **"Recursive function `ℕ → ℕ`" decoding.** Mathlib's `Computable` (total computable functions). *Not* `Nat.Partrec`, which admits partial functions — P-R's recursive functions in Ch. 2 §1 are total. No new construction needed.
- **Axiom 3 is the cross-layer reach-down.** It mentions L1's "computable sequence of reals" without re-defining it. This is the *only* L1 → L3 dependency. Hence the stub claim at `claims/l1-computable-reals/is-computable-seq-real.md` is on the critical path.
- **(NV) is best modelled as a structure-field.** In Lean: `zero_seq : IsComputableSeq (fun _ => 0)`. This is cleaner than an unbounded existential and gives the user a named handle.
- **Effective separability is NOT one of the axioms.** It is a downstream property (existence of an effective generating set) — a Banach space with a computability structure *may* be effectively separable. We will introduce it as a separate predicate / typeclass extension at L4, not as a field of `ComputabilityStructure`. (P-R Ch. 2:25, 120.)

  *Important rationale note.* Without effective separability, the axioms admit non-equivalent computability structures on the same Banach space — P-R Ch. 2:338–368 (Examples 3, 4) exhibits explicit "ad hoc" structures distinct from the intrinsic one. The **intrinsic uniqueness** that the project's adoption of P-R is rationalized on (CLAUDE.md commitment #1, supported by the Stability Lemma at Ch. 2:248) is *not* a consequence of (A1)–(A3)+(NV) alone — it requires effective separability. The axioms by themselves yield only the *framework* in which uniqueness becomes statable; the uniqueness theorem itself is L4 work, and the *counterexample* `IsComputableSeq := fun x => ∀ n, x n = 0` (the trivial-everywhere-zero predicate) satisfies all three axioms on any `X` but captures none of P-R's intended content.

## Dependencies

| Layer | Artifact | Why |
|---|---|---|
| L1 | `claims/l1-computable-reals/is-computable-seq-real.md` | Gives meaning to "computable sequence of real numbers" in (A3) |
| L0 | `Mathlib.Computability.Partrec` (`Computable`, `Primrec`) | Index functions `d`, modulus `e`, scalar sequences |
| L0 | `Mathlib.Data.Nat.Pairing` (`Nat.pair` / `Nat.unpair`) | Double-sequence decoding |
| L3 self | `intuition/l3-computability-structure.md` | Mental model and rationale |

## What this claim is *not*

It is not yet the Lean typeclass. The Lean class will be a faithful encoding of this claim — same predicate, same three axiom-fields, same (NV) clause — but the binding to Mathlib's `Computable` will be made precise in `formal/`. That step is deferred per CLAUDE.md Rule 7 (no premature formalization).

It is also not the Stability Lemma, the Effective Density Lemma, nor any instance-construction. Those are downstream:

- Stability Lemma (Ch. 2:248) — proves that, given an effective generating set, the axioms pin down `IsComputableSeq` uniquely. Downstream claim.
- Effective Density Lemma (Ch. 2:204) — establishes that effective generating sets behave like effective bases. Downstream claim.
- Concrete instances on `C[a,b]`, `L^p`, `ℓ^p` — Sections 2–4 of Ch. 2, layer L4.

## Resolutions after C2 round-1 devil's-advocate review

The DA review of this claim (round 1, verdict `unsound`, full text at `.goals/l3-computability-structure-axioms/reviews/C2.md`) raised five weaknesses. All five have been addressed inline above; this section records the resolutions and is preserved for audit.

1. **(NV) equivalence with P-R's clause.** Resolved in the (NV) section above: forward direction via Axiom 1 with zero coefficients, reverse direction trivial witness. The two formulations are equivalent modulo Axiom 1.
2. **Complex scalar case dangling.** Resolved by extending the L1 stub with `IsComputableSeqComplex` (coordinatewise). The L3 "computable sequence of scalars" formalization remark now references both `IsComputableSeqReal` and `IsComputableSeqComplex`.
3. **Pairing-function choice unjustified.** Resolved by the note added to the "computable double sequence" formalization remark: `Nat.pair` is one of several equivalent choices; closure under recursive re-indexing follows from Axiom 1 + the Composition Property.
4. **Stability/uniqueness rationale-gap.** Resolved in the effective-separability formalization remark: intrinsic uniqueness is *not* a consequence of (A1)–(A3)+(NV) alone; it requires effective separability at L4. The trivial-everywhere-zero counterexample is recorded inline.
5. **`d : ℕ → ℕ` decoding gestured at `Nat.Partrec`.** Resolved in the corresponding formalization remark: `Computable` (total), explicitly *not* `Nat.Partrec`.

The three "open questions" originally listed here (scalar-field tightness, NV faithfulness, pairing/A1 friction) mapped to fixes 2, 1, and 3 respectively. They are no longer open.

The claim is now ready for round-2 DA review.
