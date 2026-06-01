---
criterion: C2
artifact: claims/l3-computability-structure/axioms.md
reviewer: devils-advocate
goal: l3-computability-structure-axioms
date: 2026-06-01
round: 1
verdict: unsound
---

# Devil's-advocate review — C2 (round 1)

## Summary
The claim transcribes Pour-El–Richards Ch. 2 §1 axioms with high verbatim fidelity. However, the (NV) clause as encoded by `zero_seq : IsComputableSeq (fun _ => 0)` is **strictly weaker** than P-R's stated assumption, and the L1 stub `IsComputableSeqReal` does not cover the complex scalar case that Axiom 1 explicitly invokes. These are load-bearing defects for downstream L4/L5 work, so I return `unsound`.

## Verbatim-fidelity audit
- **Effective convergence (lines 36–48 of claim vs. lines 58–64 of source):** Faithful. The claim restates the quantifier order correctly: `∃ e ∀ n, N ∀ k ≥ e(n,N)`. Source has the same. Note however: P-R writes `e` simply as "a recursive function" without explicit signature — the claim correctly infers `e : ℕ × ℕ → ℕ` (matches the analogous Ch. 0 Definition 4).
- **Axiom 1 (claim 50–66 vs. source 66–72):** Faithful in substance. The four ingredients — two computable sequences `(x_n), (y_n)`, two computable double sequences of scalars `(α_{n,k}), (β_{n,k})`, and recursive `d : ℕ → ℕ` — are all retained. Sum `∑_{k=0}^{d(n)}` retained.
- **Axiom 2 (claim 68–74 vs. source 73):** Faithful, terse, correct.
- **Axiom 3 (claim 76–82 vs. source 75):** Faithful.
- **(NV) (claim 84–90 vs. source 77):** Quoted verbatim — but see Weakness #1 below: the *formal model* the claim proposes (`zero_seq`) does not implement what the verbatim says.
- **Double-sequence convention (claim 32 vs. source 53):** Source says "one of the standard recursive pairing functions" (existential over pairings). Claim commits to `Nat.pair`. See Weakness #3.

## Strengths
- Verbatim blocks are quoted with stable line-range pointers; sources resolve.
- The "Formalization remarks" cleanly separates substance (the axioms) from design (the typeclass shape), discharging the `our_construction` rationale.
- The decision to keep `IsComputableSeq` primitive (not derived from Mathlib's `Computable`) is honest: P-R's substrate is sequences of Banach-space points, which carry no `Primcodable` structure in general.
- The deferral of effective separability to L4 matches P-R Ch. 2:25/120.
- The cross-layer reach-down is correctly identified as the unique L1 → L3 dependency.

## Weaknesses

1. **(NV) formalization is strictly weaker than P-R's.** *(Load-bearing.)* P-R Ch. 2:77 reads: "We assume that at least one computable sequence in `X` exists, whence the sequence `{0,0,0,…}` is computable." This is *existence-of-some-sequence* plus a derivation. The claim's `zero_seq : IsComputableSeq (fun _ => 0)` only gives the *conclusion*. The two are equivalent in the presence of Axiom 1, but the claim asserts equivalence ("equivalently") without justification. Fix: state and discharge the equivalence explicitly (forward: A1 with zero coefficients; reverse: trivial witness).

2. **Complex scalar case is dangling.** *(Load-bearing.)* Axiom 1 (claim line 52, source line 66) mentions `(α_{n,k}), (β_{n,k})` as "computable double sequences of real or complex numbers". The claim's formalization remark defers complex to "real and imaginary parts L1-computable". But the L1 stub `claims/l1-computable-reals/is-computable-seq-real.md` defines only `IsComputableSeqReal`. There is **no** `IsComputableSeqComplex` in scope. *Mutatis mutandis* is not a Lean-formalizable verdict. Fix: extend the L1 stub to define `IsComputableSeqComplex` coordinatewise.

3. **Pairing-function commitment unjustified.** *(Cosmetic-to-load-bearing.)* P-R Ch. 2:53 says "one of the standard recursive pairing functions" existentially; claim commits to `Nat.pair`. Any two pairings differ by a recursive bijection — closure under recursive composition (A1 + Composition Property at Ch. 2:82) makes the choice immaterial. But this needs to be *stated*, not absorbed silently.

4. **"Stability Lemma uniqueness" is not delivered by the axioms alone.** *(Architectural.)* The project's commitment to P-R (CLAUDE.md commitment #1) rests on intrinsic uniqueness. The Stability Lemma (Ch. 2:248) requires effective separability. The claim correctly omits effective separability from the axioms but does *not* flag that without it, two distinct structures can coexist on the same `X` (P-R ad hoc Examples 3, 4 at Ch. 2:338–368). Fix: state that intrinsic uniqueness is *not* a consequence of (A1)–(A3)+(NV) alone; it requires effective separability via L4.

5. **"Recursive `d : ℕ → ℕ`" decoding gestures at `Nat.Partrec`.** *(Cosmetic.)* Line 99 says "Mathlib's `Computable` (a.k.a. `Nat.Partrec` on the `Nat`-`Nat` slice)". This is sloppy: `Computable` is total; `Nat.Partrec` admits partials. P-R's recursive functions are total. Fix: drop the `Nat.Partrec` gesture.

## Specific responses to the three "open questions" the claim itself flagged

1. **Scalar field treatment.** Not tight enough. *Mutatis mutandis* is fine for prose but not for `claims/`. Fix: extend L1 stub to cover the complex case (Weakness #2).

2. **(NV) faithfulness.** `zero_seq` is equivalent to P-R's clause *modulo A1*. Forward via A1 with all-zero coefficients; reverse trivial. The claim asserts equivalence in passing but doesn't record the reverse direction. Fix: spell out both directions (Weakness #1).

3. **`Nat.pair`-recoding friction with A1.** No friction, but as Weakness #3 notes, the equivalence across pairings should be stated.

## Candidate counterexample / failure mode
Construct `X = ℝ` (a complete real Banach space). Let `IsComputableSeq` be the *trivial* predicate `IsComputableSeq (x : ℕ → ℝ) := ∀ n, x n = 0`. Then:
- A1 holds (any linear combination of zero sequences is zero).
- A2 holds (the effective limit of a double sequence of zero sequences is zero).
- A3 holds (the norm sequence is the zero sequence, L1-computable).
- `zero_seq` holds.

This is a "structure" satisfying every axiom the claim writes down, yet capturing none of P-R's intended content. The counterexample illustrates Weakness #4: the claim should flag that the axioms admit "trivial" computability structures and that ruling them out requires the L4 effective-separability layer. This is not a defect *in the axioms* (they are P-R's, verbatim) but an honesty-gap in the claim's rationale section about what the axioms deliver on their own.

## Verdict justification
`unsound`. The verbatim transcription is faithful, but two formal defects make the artifact not yet ready as foundation for L4/L5:
- Weakness #2 (complex scalar case has no L1 referent) is a genuine layer-graph hole.
- Weakness #1 (NV-equivalence asserted without the A1-derivation) is a small but real provenance gap.

Weaknesses #3, #4, #5 are fixable in a single edit pass.

Returning `unsound` rather than `unsupported`: the sources resolve and the substance is correct; the issue is precision in the formalization-layer commentary.

## Suggested edits

1. **(NV) equivalence.** Add: `(∃ x, IsComputableSeq x) ⇒ zero_seq` via A1 with `α = β = 0` and `d(n) = 0`. Reverse: trivial witness.
2. **Complex scalar handling.** Extend `claims/l1-computable-reals/is-computable-seq-real.md` with an `IsComputableSeqComplex` definition (sequence is computable iff real and imaginary parts both are; verbatim source at Ch. 0:216).
3. **Pairing immateriality.** Add remark: "Choice of `Nat.pair` is immaterial: any two standard pairings differ by a recursive bijection, and closure follows from A1 + the Composition Property of Ch. 2:82. A downstream lemma will discharge this."
4. **Effective-separability rationale-gap.** Extend the existing effective-separability remark: "Without effective separability, the axioms admit non-equivalent computability structures on the same `X` (P-R Examples 3, 4 at Ch. 2:338–368). Intrinsic uniqueness — the property the project's adoption of P-R is rationalized on — requires the Stability Lemma at L4, not just (A1)–(A3)+(NV)."
5. **`d : ℕ → ℕ` decoding.** Replace `Nat.Partrec` reference with "`Computable` (total)".

After these edits, expected verdict is `passes`.
