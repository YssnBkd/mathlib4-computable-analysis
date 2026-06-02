# iter-03 strategy — the closure-helper bottleneck

> Refines iter-02's orientation. Locks the implementation strategy for
> iter-04+. Doubles as a paper-form proof so C5 is partially-discharged
> by the end of iter-03 (the verbatim citations are in this file; iter-04
> only needs to copy them onto the Lean proof lines).

## Mathlib reconnaissance — what is/isn't available

Searched `formal/.lake/packages/mathlib/Mathlib/Computability/` and
`Mathlib/Logic/Denumerable.lean`, `Mathlib/Data/Rat/Denumerable.lean`,
`Mathlib/Data/Rat/Encodable.lean`.

| Need | Mathlib has | Location | Notes |
|---|---|---|---|
| `Denumerable ℕ` | yes | `Logic/Denumerable.lean:106` | |
| `Denumerable ℤ` | yes | `Logic/Denumerable.lean:158` | via `Equiv.intEquivNat` |
| `Encodable ℚ` | yes | `Data/Rat/Encodable.lean:23` | |
| `Denumerable ℚ` | yes | `Data/Rat/Denumerable.lean:30` | via `ofEncodableOfInfinite ℚ` |
| `Primcodable α from Denumerable α` | yes | `Computability/Primrec/Basic.lean:139` | priority 10, auto |
| `Primrec.nat_add` / `nat_mul` | yes | `Computability/Primrec/Basic.lean:593, 599` | |
| `Primrec.int_add` / `int_mul` | **no direct lemma** | — | derivable but not exported |
| `Primrec.rat_add` / `rat_mul` | **no direct lemma** | — | derivable but not exported |
| `Computable.add` / `mul` for `ℕ → ℚ` | **not directly** | — | needs Primrec₂ for ℚ-arith |

**Conclusion**: Mathlib has `Primcodable ℤ` and `Primcodable ℚ` (via Denumerable),
but doesn't ship `Primrec₂` for their arithmetic. The bridge approach
(`Computable r → IsComputableSeqRat r`) requires manually establishing
ℚ-arithmetic Primrec, which is doable but tedious. The direct
sign/num/den approach faces the same problem at the integer level
(need `Primrec.int_add` to combine signed numerators).

## Realistic scope of the A1 obligation

The full A1 proof under polynomial form requires, at minimum, these four
closure helpers on `IsComputableSeqRat`:

1. `IsComputableSeqRat.add` — closure under `(r₁ k) + (r₂ k)`.
2. `IsComputableSeqRat.mul` — closure under `(r₁ k) · (r₂ k)`.
3. `IsComputableSeqRat.reindex` — closure under `r ∘ φ` for `Computable φ : ℕ → ℕ`.
4. `IsComputableSeqRat.finset_sum` — closure under `Σ_{k ∈ range (n k)} r (Nat.pair n k)` for recursive `n`.

Each requires ~30–60 Lean lines. Total ≈ 150–250 lines of closure scaffolding
before the A1 proof body itself can even be drafted. The A1 proof body, given
the helpers, is ~40–80 lines (witness construction + triangle inequality).

**Round budget reality**: 3 iters remain (iter-04, 05, 06). At iter rate of
~60–80 productive Lean lines per iter, full closure + A1 application is
unrealistic. The round should ship the closure helpers + a partial A1
application (likely showing the witness construction with the bound left
to a `sorry`-bodied auxiliary), OR ship the closure helpers alone and
defer A1 to a follow-up round.

## Paper-form proof of A1 (full, with verbatim citations for C5)

> Adapts P-R Ch. 2 §1 (axioms) and §2 (G-L predicate satisfies axioms) to
> the polynomial-approximation form of Ch. 2 §5 (Theorem 6 / Effective
> Density Lemma).

### Hypotheses

Fix `α₀, β₀ : ℝ`. Let `E := C(Set.Icc α₀ β₀, ℝ)` with the sup-norm. Given:

- `x, y : ℕ → E` with `IsComputableSeqCMap x`, `IsComputableSeqCMap y`.
  By the definition (`CMap.lean:91-98`, restating P-R Ch. 2:141-150), there
  exist `aˣ : ℕ × ℕ × ℕ → ℚ`, `dˣ : ℕ × ℕ → ℕ` (and similarly `aʸ, dʸ`) with
  `aˣ`'s triple-flattening in `IsComputableSeqRat`, `dˣ` `Computable`, and
  `‖x k − polyApprox aˣ dˣ k m‖_∞ ≤ 2⁻ᵐ` for all `k, m`. *(ref:
  `literature/papers/PourEl-Richards-chapt2.md:141-150`.)*
- `α, β : ℕ × ℕ → ℝ` with `(fun n ↦ α (Nat.unpair n)) ∈ IsComputableSeqReal`
  (and similarly β). By L1 `IsComputableSeqReal` definition
  (`ComputableSeqReal.lean:101-104`, P-R Ch. 0 Def 5a), there exist
  `αRat, βRat : ℕ × ℕ → ℚ`, each itself in `IsComputableSeqRat` after
  Nat.unpair-flattening, with `|αRat (n', m) − α (Nat.unpair n')| ≤ 2⁻ᵐ`.
- `d : ℕ → ℕ` `Computable`.

### Claim

The sequence
`s n := Σ_{k ∈ Finset.range (d n + 1)} (α (n, k) • x k + β (n, k) • y k)`
is in `IsComputableSeqCMap`. *(ref:
`literature/papers/PourEl-Richards-chapt2.md:66-72` — Axiom 1 statement; and
`literature/papers/PourEl-Richards-chapt2.md:128-129` — "trivial to verify
that Axiom 1 (Linear Forms) holds for 𝒮".)*

### Construction of the polynomial witness

Choose precision pad `M := M(n, m) := m + ⌈log₂(4 · (d n + 1) · max(Bˣ(n,m),Bʸ(n,m)))⌉ + 1`
where `Bˣ(n, m)` is a sup-norm bound on `polyApprox aˣ dˣ k 0` over
`k ∈ range (d n + 1)` (computable: read off the rational coefficients).
The pad is computable from `d, aˣ, dˣ, aʸ, dʸ` and grows linearly in `m`.

Define:

- `dˢ : ℕ × ℕ → ℕ`,
  `dˢ (n, m) := max_{k ∈ range (d n + 1)} max (dˣ (k, M(n,m)), dʸ (k, M(n,m)))`.
  Computable by `Computable` closure under `Finset.range`, `Finset.max`,
  composition.

- `aˢ : ℕ × ℕ × ℕ → ℚ`,
  `aˢ (n, m, j) := Σ_{k ∈ range (d n + 1)}
      ( αRat (Nat.pair n k, M(n,m)) · padcoeff aˣ k (M(n,m)) j
      + βRat (Nat.pair n k, M(n,m)) · padcoeff aʸ k (M(n,m)) j )`

  where `padcoeff a k m j := if j ≤ dˣ (k, m) then a (k, m, j) else 0`
  (rational; the zero-pad lets us share a single `dˢ` across all k).

  In `IsComputableSeqRat` after triple-flattening, by:
  - `IsComputableSeqRat.reindex` applied to `αRat` and `aˣ` (composing with
    `Computable` re-indexing into `Nat.pair n k, M(n,m), j` etc.);
  - `IsComputableSeqRat.mul` for the product;
  - `IsComputableSeqRat.finset_sum` for the finite sum over
    `k ∈ range (d n + 1)`;
  - `IsComputableSeqRat.add` to combine the α and β pieces.

### Norm bound (triangle inequality)

For any `x_* ∈ Set.Icc α₀ β₀`:

```
|s n (x_*) − polyApprox aˢ dˢ n m (x_*)|
  ≤ Σ_{k ∈ range (d n + 1)}
      |α (n, k) · x k (x_*) − αRat (·, M) · polyApprox aˣ dˣ k M (x_*)|
   + Σ_{k ∈ range (d n + 1)}
      |β (n, k) · y k (x_*) − βRat (·, M) · polyApprox aʸ dʸ k M (x_*)|
```

For each `k`-summand on the α-side, splitting via the auxiliary
`αRat · x k`:

```
|α (n, k) · x k (x_*) − αRat (·, M) · polyApprox aˣ dˣ k M (x_*)|
  ≤ |α (n, k) − αRat (·, M)| · |x k (x_*)|
  + |αRat (·, M)| · |x k (x_*) − polyApprox aˣ dˣ k M (x_*)|
  ≤ 2⁻ᴹ · ‖x k‖_∞ + (|α (n, k)| + 2⁻ᴹ) · 2⁻ᴹ
  ≤ 2⁻ᴹ · Bˣ(n, m) + (Bα + 2⁻ᴹ) · 2⁻ᴹ
```

where `Bˣ(n, m)` is the polynomial-approximant-derived norm bound and
`Bα = |α (n, k)|` (bounded by `|αRat (·, 0)| + 1`, hence rationally
bounded). Summing over `k ∈ range (d n + 1)` and combining α and β:

```
‖s n − polyApprox aˢ dˢ n m‖_∞ ≤ 2 · (d n + 1) · 2⁻ᴹ · (Bˣ + Bα + 1) ≤ 2⁻ᵐ
```

by the pad choice. *(This is the "trivial" verification of Axiom 1 that
P-R Ch. 2:128-129 cites — the substance lies in the rational closure
plumbing, which is what the Lean proof is mostly about.)*

## Lean skeleton for iter-04+

```lean
-- iter-04+: closure helpers (private), placed at the top of CMap.lean
-- under namespace ComputableAnalysis.L4. To be later refactored to L1.

namespace ComputableAnalysis.L4

open ComputableAnalysis.L1

/-- **iter-04 target**: TODO(refactor → L1).
Closure of `IsComputableSeqRat` under pointwise addition. -/
private theorem isComputableSeqRat_add
    {r₁ r₂ : ℕ → ℚ}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂) :
    IsComputableSeqRat (fun k => r₁ k + r₂ k) := by
  -- Strategy A (preferred): use Primcodable ℚ + derive Primrec₂.rat_add.
  -- Strategy B (fallback): direct sign-num-den case analysis at the ℕ-level.
  --
  -- Strategy A in detail:
  --   The hypothesis `IsComputableSeqRat r` is essentially `Computable r`
  --   after a one-step Primcodable ℚ conversion. So:
  --   1. Show `IsComputableSeqRat r ↔ Computable r` (two private lemmas).
  --   2. Apply Mathlib's `Computable.add` (which requires Primrec₂ rat_add,
  --      itself derivable from Primrec₂ encode/decode + nat_add).
  sorry

/-- **iter-04 target**: TODO(refactor → L1).
Closure of `IsComputableSeqRat` under pointwise multiplication. -/
private theorem isComputableSeqRat_mul
    {r₁ r₂ : ℕ → ℚ}
    (h₁ : IsComputableSeqRat r₁) (h₂ : IsComputableSeqRat r₂) :
    IsComputableSeqRat (fun k => r₁ k * r₂ k) := by
  sorry

/-- **iter-04 target**: TODO(refactor → L1).
Closure of `IsComputableSeqRat` under Computable reindexing. -/
private theorem isComputableSeqRat_reindex
    {r : ℕ → ℚ} {φ : ℕ → ℕ}
    (h : IsComputableSeqRat r) (hφ : Computable φ) :
    IsComputableSeqRat (fun k => r (φ k)) := by
  sorry

/-- **iter-04 target**: TODO(refactor → L1).
Closure of `IsComputableSeqRat` under finite-range sum with computable bound. -/
private theorem isComputableSeqRat_finsetSum
    {r : ℕ × ℕ → ℚ} {n : ℕ → ℕ}
    (h : IsComputableSeqRat (fun m => r (Nat.unpair m)))
    (hn : Computable n) :
    IsComputableSeqRat (fun k => ∑ j ∈ Finset.range (n k + 1), r (k, j)) := by
  sorry

end ComputableAnalysis.L4
```

(Note: these are SKELETONS — actually compiling them requires resolving
`Primrec₂.rat_add`. iter-04 starts here.)

## Realistic round outcome

Three iters remain. Honest projection:

- **iter-04**: prove `isComputableSeqRat_add` via Strategy A. Sets the
  pattern. ~80 lines if Strategy A works; ~150 if we fall back to B.
- **iter-05**: prove `isComputableSeqRat_mul` and `_reindex`. ~80 lines
  each given the pattern from iter-04.
- **iter-06**: prove `isComputableSeqRat_finsetSum`, then assemble A1.
  Likely runs out of budget; A1 closure may need a follow-up round.

If the round ends with closure helpers shipped but A1 still open, the
proper status is `partial` — closure helpers in this file are a real
contribution (they unblock A1, A2, A3 simultaneously), even if A1 itself
remains a sorry. The user should know this projection in advance via the
iter-03 progress note.

## Citation lines locked in (for C5)

Whenever A1 lands in Lean, the proof must thread these:

- `literature/papers/PourEl-Richards-chapt2.md:66-72` — Axiom 1 statement.
  Cite at: the top of the proof, just after `axiom_linearity := by` to
  state which axiom is being discharged.
- `literature/papers/PourEl-Richards-chapt2.md:128-129` — "trivial under
  G-L". Cite at: the comment justifying why the bound argument works (the
  paper's verbatim "trivial" is misleading; the citation grounds why we
  may use the polynomial form's rational decomposition).
- `literature/papers/PourEl-Richards-chapt2.md:141-150` — polynomial-
  approximation form. Cite at: the witness-construction step (defining
  `aˢ`, `dˢ`).
- `literature/papers/PourEl-Richards-chapt0.md:203` (P-R Ch. 0 Def 5a) —
  the `IsComputableSeqReal` rational-approximation form for the α, β
  scalar hypotheses. Cite at: the destructuring of α, β hypotheses.
- `literature/papers/PourEl-Richards-chapt2.md:53` (P-R Ch. 2 double-
  sequence definition). Cite at: the `Nat.pair n k` reindex into
  `αRat (n', m)`.
