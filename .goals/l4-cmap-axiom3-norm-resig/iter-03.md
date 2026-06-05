---
iter: 3
timestamp: 2026-06-04T01:15:00Z
mode: proof-attempt
unmet: [C4, C5, C6, C7, C8, C9]
files_changed:
  - ComputableAnalysis/L4/Instances/CMap.lean
note: |
  Phase 2 (signature refit) complete. C3 met. Six-move proof outline written
  into the lemma docstring. Phase 3 sub-plan drafted with a critical
  building-block gap identified: a `IsComputableSeqRat.finsetMax` closure
  doesn't yet exist. Phase 3 naturally splits into 5 sub-phases.
---

# iter-03 — Phase 2 done, Phase 3 plan committed

## What happened

Refit `isComputableSeqCMap_norm`'s signature:
- Added `(hα_c : IsComputableReal α) (hβ_c : IsComputableReal β)` after
  the existing `B, hα_le, hβ_le` args.
- Replaced the docstring's "signature inadequate / counterexample / where
  P-R breaks" sections with a brief evolution-history paragraph + a
  six-move proof outline tracing P-R chapt0:984-1012.
- Updated `computabilityStructureCMap_of` to take and forward both new hyps.

Build verifies: sole sorry-warning now at `CMap.lean:1510` (shifted from
1586 because docstring shrunk). Instance compiles; downstream untouched.

## Phase 3 sub-plan (5 sub-phases)

Auditing what tools we have and what's missing:

**Available L1 closures (sorry-free, axioms clean):**
- `IsComputableSeqRat.{add, mul, max, min, abs, comp}` — pointwise binary
  closures. NOT a Finset-aggregate.

**Available L4 helpers (in `FinsetSumHelper` namespace, private):**
- `addTriple` + `addTriple_correct` + `addTriple_computable` — composing
  rational-witness triples for sum.
- `finsetSum_rat` — Nat.rec-based accumulator producing `IsComputableSeqRat`
  for `fun k => Σ j ∈ Finset.range (n k + 1), r (k, j)` given Computable `n`.
- `isComputableSeqRat_doubleApply` / `tripleApply` / `ite_rat` —
  reindexing convenience lemmas.

**Available L1 Prop-1 closure (this round):**
- `isComputableSeqReal_of_effectiveConvergence` — Phase 1's new lemma.

**MISSING for A3:**
- **`IsComputableSeqRat.finsetMax`** or `finsetMaxAbs`. The A3 proof needs
  `max_{j ∈ Finset.range (k + 1)} |p_{n,k}(x_j)|` as a doubly-computable
  rational sequence. No closure lemma currently expresses this.

**Possible workarounds** (none satisfactory):
- Fixed-size grid (2-3 points) — fails effective convergence.
- Binary tree of pairwise maxes — equivalent to writing `finsetMax`.
- Inline the accumulator without naming — same work, less reusable.

**Decision**: write `IsComputableSeqRat.finsetMax` as a named L1 closure,
parallel to `IsComputableSeqRat.add/mul/etc.`. Internally uses a `maxTriple`
helper analogous to `addTriple`, with a Nat.rec accumulator analogous to
`finsetSum_rat`. ~80-120 lines.

### Phase 3 sub-phases

**Phase 3.1** — Build `maxTripleLogic` (the rational-witness-triple max
operation): given two triples `(a, b, s)` representing rationals `(-1)^s · a/b`,
return the triple representing their max. Decision tree:
- Same parity, both even (nonneg): take t₁ iff `a₁ · b₂ ≥ a₂ · b₁`.
- Same parity, both odd (nonpos): take t₁ iff `a₁ · b₂ ≤ a₂ · b₁`.
- Different parity: take t₁ iff `s₁ % 2 = 0` (i.e. t₁ is the nonneg one).
Implement as a `cond chooseR1` over a Boolean discriminator built from
parities + cross-products. Estimated: 1-2 iters, ~40-60 lines.

**Phase 3.2** — Build `IsComputableSeqRat.finsetMax`: Nat.rec accumulator
mirroring `finsetSum_rat`'s structure but using `maxTripleLogic` as the
step. Estimated: 1 iter, ~30-40 lines.

**Phase 3.3** — Build polynomial-Lipschitz bound helper: from polynomial
coefficients `a : ℕ × ℕ × ℕ → ℚ` and degree `d : ℕ × ℕ → ℕ` and the bound
`B`, produce a Computable rational `lipBnd : ℕ × ℕ → ℚ` with
`Lip(p_{n,k}) ≤ lipBnd (n, k)` on `[α, β]`. Closed-form: `Σ_{j=1}^{d} j |a_j| B^(j-1)`.
Estimated: 1 iter, ~20-30 lines.

**Phase 3.4** — Define the A3 witness double-sequence `sNK : ℕ × ℕ → ℚ`
concretely, show `IsComputableDoubleSeqRat sNK`, construct the modulus
`e : ℕ × ℕ → ℕ` with `Computable e`, prove the three-error bound. **DA
required** on the error decomposition. Estimated: 2-3 iters, ~80-120 lines.

**Phase 3.5** — Apply `isComputableSeqReal_of_effectiveConvergence` and
close. Estimated: 1 iter, ~10 lines.

**Total Phase 3 estimate**: 6-8 iters, ~180-260 lines.

## Forward warnings from DA (chapt0:246-280 mining)

Reapplying DA's Phase-3 forward-warning from iter-02:
- `e(n, N) := M · L(n, N)` where `M ≥ ⌈β - α⌉` (computable from `hα_c, hβ_c,
  hβ_le`) and `L(n, N) = lipBnd(n, N+padding) · 2^(N+padding)`. The factor `2^N`
  is hidden inside `L`'s output, not a separate `nat_pow` construction.
- This **avoids `Primrec.nat_pow`** (which doesn't exist — see PITFALLS §1).

## Files changed

- `ComputableAnalysis/L4/Instances/CMap.lean` — docstring + signature
  refit for `isComputableSeqCMap_norm` and `computabilityStructureCMap_of`.

## Criteria delta

- C3 ✅ — signature refit confirmed by build.
- C4-C9 unmet.

## Next iter (Phase 3.1)

Implement `maxTripleLogic` + computability proof in L1 §4, immediately
after the existing `IsComputableSeqRat.max` lemma. The function and its
correctness will mirror `addTriple` / `addTriple_correct` from the L4
`FinsetSumHelper` namespace but be in L1 directly (L1 is in this round's
`allow_writes`).
