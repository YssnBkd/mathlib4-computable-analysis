---
id: l1-computable-reals-is-computable-seq-real
blueprint: blueprint:def:l1_isComputableSeqReal
created: 2026-06-01
sources:
  - PourEl-Richards-1989:Ch.0:203 (Definition 5a)
  - PourEl-Richards-1989:Ch.0:46 (Definition 1)
  - PourEl-Richards-1989:Ch.0:189 (computable double sequences)
  - PourEl-Richards-1989:Ch.0:200 (Definition 5)
dependencies: []
da_status: pending
---

> **Blueprint:** `[[blueprint:def:l1_isComputableSeqReal]]` — formal statement
> and formalization state (`\leanok` / `\notready` / `\mathlibok`) live there.
> This file holds design rationale only.

# `IsComputableSeqReal` — predicate-form computable sequences of reals on Mathlib's `ℝ`

## Why this construction

The L1 → L3 reach-down forces three pinned choices:

1. **Predicate, not new type.** Per project commitment #3, we do not introduce
   a parallel `ℝ_c` type. L3's typeclass `ComputabilityStructure` adds
   structure to Mathlib's pre-existing Banach hierarchy; its Axiom 3 (Norms)
   asks for "the norm of a computable sequence in `X` is a computable
   sequence in `ℝ`". That requires a `Prop` on `ℕ → ℝ`, not membership in a
   subtype.
2. **Definition 5a, not Definition 5.** P-R offers two equivalent
   formulations (lines 200 vs 203 of Ch. 0): Definition 5 carries an explicit
   recursive modulus `e(n, N)` ("`k ≥ e(n, N) ⇒ |r_{n,k} − x_n| ≤ 2^{-N}`");
   Definition 5a folds the modulus into the second index ("`|r_{n,k} − x_n|
   ≤ 2^{-k}`"). The reverse direction `5 ⇒ 5a` is the short subsequence
   argument at chapt0.md:209 (`r'_{n,k} := r_{n, e(n,k)}`). Adopting 5a as
   primary saves the predicate's signature one parameter and matches the
   blueprint's clean form.
3. **Computable double sequence via `Nat.unpair`.** P-R Ch. 0:189 says "by
   one of the standard recursive pairing functions"; we use Mathlib's
   `Nat.unpair` (the inverse of the max-based `Nat.pair`) because it is the
   pairing already wired into `Primrec`/`Computable` throughout Mathlib. The
   specific Cantor formula `(x+y)(x+y+1)/2 + x` is also available as
   `ComputableAnalysis.L0.cantorPair` for paper-citation purposes; both
   bijections are recursive so all P-R statements transfer.

## Alternatives considered

- **New `ℝ_c` subtype.** Rejected — violates commitment #3 and forces
  duplication of the entire Mathlib analysis hierarchy.
- **Definition 5 with explicit modulus.** Rejected as primary form — adds a
  parameter to every L1 lemma and to L3 Axiom 3's signature. We may state
  Definition 5 as an `iff`-equivalence lemma later.
- **TTE / represented spaces.** Rejected as headline framework per CLAUDE.md
  preferences; the predicate-on-Mathlib-types route is more directly
  compatible with `NormedSpace 𝕜 E` upstream.
- **Cantor pairing `(x+y)(x+y+1)/2 + x` as primary.** Rejected as primary
  decode; kept as a citation-only constructor in L0.

## Mathlib-idiom mapping

- `IsComputableSeqRat`, `IsComputableDoubleSeqRat`, `IsComputableSeqReal` are
  defined in `ComputableAnalysis/L1/ComputableSeqReal.lean` against:
  - `Mathlib.Computability.Partrec` (`Computable`)
  - `Mathlib.Data.Nat.Pairing` (`Nat.unpair`)
  - `Mathlib.Data.Rat.Defs` / `Mathlib.Data.Rat.Cast.Defs`
  - `Mathlib.Data.Real.Basic` (`ℝ`)
- The `Is`-prefix follows Mathlib idiom (compare `Continuous : Prop`).
  Bundled subtype forms (à la `ContinuousMap`) are allowed as additions when
  ergonomically necessary, never as replacements.

## Sources

- P-R Ch. 0:46 (Def. 1): *"A sequence `{r_k}` of rational numbers is
  computable if there exist three recursive functions `a, b, s` from `ℕ` to
  `ℕ` such that `b(k) ≠ 0` for all `k` and `r_k = (-1)^{s(k)} · a(k)/b(k)`
  for all `k`."* — `literature/papers/PourEl-Richards-chapt0.md:46`.
- P-R Ch. 0:189: *"A double sequence will be called computable if it is
  mapped onto a computable sequence by one of the standard recursive pairing
  functions from `ℕ × ℕ` onto `ℕ`. Similarly for triple or `q`-fold
  sequences."* — `literature/papers/PourEl-Richards-chapt0.md:189`.
- P-R Ch. 0:200 (Def. 5): *"A sequence of real numbers `{x_n}` is computable
  (as a sequence) if there is a computable double sequence of rationals
  `{r_{n k}}` such that `r_{n k} → x_n` as `k → ∞`, effectively in `k` and
  `n`."* — `literature/papers/PourEl-Richards-chapt0.md:200`.
- P-R Ch. 0:203 (Def. 5a, primary): *"A sequence of real numbers `{x_n}` is
  computable (as a sequence) if there is a computable double sequence of
  rationals `{r_{n k}}` such that `|r_{n k} − x_n| ≤ 2^{-k}` for all `k` and
  `n`."* — `literature/papers/PourEl-Richards-chapt0.md:203`.

## Devil's-advocate verdict

- Last reviewed: never
- Verdict: (none yet)
- Open weaknesses: equivalence of Definitions 5 and 5a is *stated* but not
  formally proved in Lean yet — should land as a downstream lemma so future
  callers can rely on either form interchangeably.

## Notes for future revisions

- If Mathlib ever upstreams `Mathlib.Computability.Real.IsComputableSeq` (or
  similar), this predicate and its docstring become the migration target.
- The `IsComputableSeqComplex` and `q`-vector extensions (P-R Ch. 0:216) get
  their own claim file when they land — they are out of scope here.
- The countable-subfield structure on `ℝ_c` (Ch. 0 §3) is also a separate
  downstream claim; it depends on `IsComputableReal` (point predicate, see
  `[[blueprint:def:l1_isComputableReal]]`) which is `\notready` as of
  2026-06-03.
