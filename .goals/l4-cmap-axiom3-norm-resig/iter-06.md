---
iter: 6
timestamp: 2026-06-04T07:30:00Z
mode: proof-attempt
unmet: [C4, C5, C6, C7, C8, C9]
files_changed:
  - ComputableAnalysis/L4/Instances/CMap.lean
note: |
  Phase 3.1 (FinsetMaxHelper) + Phase 3.2 (polyApproxCMap_lipschitz) + Phase
  3.3.1 (pow_isComputableDoubleSeqRat) + Phase 3.3.2 (polyVal_isComputableSeqRat)
  all CLOSED, sorry-free. Single sorry remains at A3 body (`CMap.lean:1968`).
  Foundation laid for the partial-max construction of step ②, the polynomial
  Lipschitz bound for step ③, and the polynomial-evaluator closure for the
  combined steps ②+③.
---

# iter-06 — Phase 3.3.1 + 3.3.2 closures landed

## What landed (continuing from iter-05)

### Phase 3.2: polynomial Lipschitz bound (`polyApproxCMap_lipschitz`)

For `x, y ∈ Set.Icc α β` with `max(|α|, |β|) ≤ B`:
`|p_{n,k}(x) − p_{n,k}(y)| ≤ (Σⱼ j · |a(n,k,j)| · B^(j−1)) · |x.val − y.val|`.

Proof routes through Mathlib's `abs_pow_sub_pow_le` (`Algebra/Order/Ring/Abs.lean:186`):
`|xʲ − yʲ| ≤ |x − y| · j · max(|x|,|y|)^(j−1)`. Bound the `max` by `B`, sum
term-by-term via triangle inequality. **Key gotcha**: `abs_pow_sub_pow_le`
takes `a, b, n` as **explicit** positional arguments, not implicit — must
pass `abs_pow_sub_pow_le x.val y.val j` (extend PITFALLS).

### Phase 3.3.1: power closure (`PolyEvalHelper.pow_isComputableDoubleSeqRat`)

`IsComputableSeqRat q ⟹ IsComputableDoubleSeqRat (fun pj ↦ q pj.1 ^ pj.2)`.

Witness lift: `(a, b, s)` for `q` becomes `(a^j, b^j, s·j)` for `q^j`. Identity
proves by `mul_pow + ← pow_mul + div_pow + push_cast + ring`.
**Mathlib drift**: `Primrec.nat_pow` does not exist (cf. PITFALLS §1). Used
the `Nat.Primrec.pow` wrapper `Primrec₂.unpaired'.1 Nat.Primrec.pow` to obtain
`Primrec₂ ((· ^ ·) : ℕ → ℕ → ℕ)`, then `.to_comp.comp ha h_snd` for the
witness components.

### Phase 3.3.2: polynomial-evaluator closure (`polyVal_isComputableSeqRat`)

Given:
- coefficient family `a : ℕ × ℕ × ℕ → ℚ` with flat `IsComputableSeqRat`,
- `Computable` degree bound `d : ℕ × ℕ → ℕ`,
- `Computable` indexers `n_idx, K_idx : ℕ → ℕ`,
- `IsComputableSeqRat` evaluation point `q : ℕ → ℚ`,

then `p ↦ Σⱼ a(n_idx p, K_idx p, j) · (q p)^j` (`j ∈ range(d(n_idx p, K_idx p) + 1)`)
is `IsComputableSeqRat`. This is the **A3 step ③ workhorse** (effective
uniform polynomial evaluation).

Proof: factor inner term `r (p, j) := a (...) * (q p)^j` as a product
`r₁ · r₂` of two `IsComputableDoubleSeqRat`s:
- `r₁ (p, j) := a (n_idx p, K_idx p, j)` via triple-flat reindex of `a`.
- `r₂ (p, j) := (q p)^j` via `pow_isComputableDoubleSeqRat hq`.
Product via `IsComputableSeqRat.mul` on flat forms. Apply `finsetSum_rat`.

**Idiom win**: `convert ... using 1` closes the matching-up goals when the
two sides differ only by definitional unfolding; no need for explicit
`funext + rfl`. Extend LEAN-IDIOMS.

## Build status

- `lake build ComputableAnalysis.L4.Instances.CMap` ✓ (only sorry: A3 body @1968).
- All new helpers visible from the round's scope.
- No 100-char overruns; no out-of-scope writes.

## Criteria delta

- C1, C2, C3 met (unchanged).
- C4 partial: helpers landed, body still open.
- C5–C9 unmet.

## What's needed next

### Phase 3.3.3 — Grid points construction (next iter)

Build `gridQ : ℕ × ℕ × ℕ → ℚ` taking `(n, N, J) ↦ αR + (J/k) · (βR − αR)`
(rational point interior to or on the boundary of `[α, β]`-approximation).
Express as flat `IsComputableSeqRat` indexed by `p = Nat.pair n (Nat.pair N J)`.

**Stepwise build** via existing closures:
1. `αR_seq` = `αR ∘ σ_m` where `σ_m p = Nat.pair 0 (m(n p, N p))`. Via
   `IsComputableSeqRat.comp`.
2. `βR_seq` similarly.
3. `(-1)·αR_seq` via `mul` with constant `-1`.
4. `(βR − αR)_seq` via `add` (subtraction-as-add-neg).
5. `(J : ℚ)` and `1/k` via direct witnesses `(J p, 1, 0)` and `(1, k p, 0)`.
6. `J/k = J · (1/k)` via `mul`.
7. `(J/k) · (βR − αR)` via `mul`.
8. `αR + (J/k)·(βR−αR)` via `add`.

Each step is a single closure call.

### Phase 3.3.4 — sNK definition + IsComputableDoubleSeqRat

`sNK (n, N) := max_{J=0..k(n,N)} |p_{n,K(n,N)}(gridQ(n,N,J))|`.
Construction: apply `polyVal_isComputableSeqRat` with `q := gridQ_seq` to
get `polyAtGrid (p) := p_{n_idx p, K_idx p}(gridQ_seq p)`, then
`IsComputableSeqRat.abs`, then `finsetMax_rat` with bound `k(n, N)` over `J`.

### Phase 3.3.5 — Modulus engineering

Choose `K(n,N), m(n,N), k(n,N)` as Computable functions such that the
three errors sum to ≤ 2⁻ᴺ:
- Polynomial: `2⁻ᴷ ≤ 2⁻ᴺ⁻²` ⟹ `K := N + 2`.
- Endpoint: `Lip(p) · 2⁻ᵐ ≤ 2⁻ᴺ⁻²` ⟹ `m := ⌈log₂(Lip_bd(n,K))⌉ + N + 3`.
- Grid: `Lip(p) · 2B / k ≤ 2⁻ᴺ⁻²` ⟹ `k := ⌈Lip_bd · 2B · 2^(N+2)⌉`.

Bound `Lip_bd(n,K)` rationally via the polynomial's coefficient sum.

### Phase 3.3.6 — Error decomposition + DA review (C5)

Three-error proof.

### Phase 3.4 — Apply Prop 1, close A3 body

Apply `isComputableSeqReal_of_effectiveConvergence` with `e (n, N) := N`
and the engineered `sNK`.

## Iters budget

Used: 6 / 100. Remaining: 94. Estimated 4-6 more iters to close C4-C7.

## Files changed this iter

- `ComputableAnalysis/L4/Instances/CMap.lean` — added `PolyEvalHelper` namespace
  with `pow_isComputableDoubleSeqRat` and `polyVal_isComputableSeqRat`, plus
  `polyApproxCMap_lipschitz` in `section CMap`. Plus iter-05's
  `FinsetMaxHelper.maxTriple_computable` and `finsetMax_rat`.

## Verification

- `lake build ComputableAnalysis.L4.Instances.CMap` ✓.
- Line-length check ✓ (no > 100).
- Single sorry warning at expected `CMap.lean:1968` (A3 body).
