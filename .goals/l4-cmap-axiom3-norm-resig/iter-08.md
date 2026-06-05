---
iter: 8
timestamp: 2026-06-04T09:30:00Z
mode: proof-attempt
unmet: [C4, C5, C6, C7, C8, C9]
files_changed:
  - ComputableAnalysis/L4/Instances/CMap.lean
note: |
  **Phase 3.3 Stages 1+2 land sorry-free.** The A3 body now contains the
  complete recursion-theoretic plumbing: modulus engineering (K_poly, Lip_nat,
  m_mod, k_grid) with computability proofs; gridQ + polyVal + abs + σ-reshape
  + sNK assembly; IsComputableDoubleSeqRat sNK established; Prop 1 applied
  with e := Computable.snd. The sole remaining sorry is the analytic
  three-error bound (Stage 3).
---

# iter-08 — Phase 3.3 Stages 1+2 (modulus + sNK assembly) inside A3 body

## What landed

### Modulus engineering (Stage 1)

Inside `isComputableSeqCMap_norm`'s body, after destructuring `hf, hα_c, hβ_c, ha_seq`:

- `K_poly nN := nN.2 + 2` — polynomial precision (gives 2⁻ᴺ⁻² polynomial-approx error).
- `Lip_nat nN := Nat.rec 0 (fun j acc => acc + j · a_num(Nat.pair n (Nat.pair K_poly j)) · B^(j−1)) (d(n, K_poly nN) + 1)` — ℕ-valued upper bound on the polynomial Lipschitz constant (uses `Nat.rec` summation; the closed-form `Finset.range.sum` is `natRec_add_eq_sum`-equivalent but not needed at this stage).
- `m_mod nN := Lip_nat nN + nN.2 + 2` — endpoint approximant precision (chosen so `Lip · 2⁻ᵐ ≤ 2⁻ᴺ⁻²`).
- `k_grid nN := 8 · Lip_nat nN · B · 2^nN.2 + 1` — grid count (chosen so `Lip · 2B / k_grid ≤ 2⁻ᴺ⁻²`).

**Computability proofs** (sorry-free):
- `hK_poly_c`: trivial `Computable.succ.comp (Computable.succ.comp Computable.snd)`.
- `hLip_nat_c`: `Computable.nat_rec` with explicit Computable₂ step proof, chain of ~10 sub-Computable's including `Primrec₂.unpaired'.1 Nat.Primrec.pow` for B-power (since `Primrec.nat_pow` doesn't exist; cf. PITFALLS §1).
- `hm_mod_c`, `hk_grid_c`: linear chains of `Primrec.nat_add`, `Primrec.nat_mul`, `Computable.succ`.
- `hk_grid_pos`: `omega` (formula is `... + 1 ≠ 0`).

### sNK assembly (Stage 2)

Stepwise via closure API:
1. **`gridQ : ℕ → ℚ`** as a `set`-bound symbol → `IsComputableSeqRat gridQ` via `PolyEvalHelper.gridQ_isComputableSeqRat`.
2. **Computable projectors** `n_idx, N_idx, K_idx : ℕ → ℕ` via `Computable.unpair` chains.
3. **`ha_seq'`** rebuilt from destructured witness components for `polyVal` application.
4. **`polyVal : ℕ → ℚ`** as a `set`-bound symbol → `IsComputableSeqRat polyVal` via `PolyEvalHelper.polyVal_isComputableSeqRat`.
5. **`absPolyVal : ℕ → ℚ`** as a `set`-bound symbol → `IsComputableSeqRat absPolyVal := polyVal.abs`.
6. **`σ : ℕ → ℕ`** reshape map packing `M.1 ∷ (M.2, J)` → `Computable σ` via `Primrec₂.natPair` chain.
7. **`habsPolyVal_σ_c`** := `habsPolyVal_c.comp hσ_c`.
8. **`rEntry : ℕ × ℕ → ℚ := fun MJ => absPolyVal (σ (Nat.pair MJ.1 MJ.2))`** → `IsComputableDoubleSeqRat rEntry` via the `Nat.pair_unpair`-bridged equality `(fun N => rEntry (Nat.unpair N)) = (fun N => absPolyVal (σ N))`.
9. **`hsNK_flat`** := `FinsetMaxHelper.finsetMax_rat hrEntry_double hk_grid_unpair_c`.
10. **`sNK : ℕ × ℕ → ℚ`** as a `set`-bound symbol → `IsComputableDoubleSeqRat sNK` via the analogous bridge.
11. **Apply Prop 1**: `refine isComputableSeqReal_of_effectiveConvergence (r := sNK) hsNK_double (e := fun p => p.2) Computable.snd ?_`.

### Sole residual sorry

The bound `∀ n N k, k ≥ N → |((sNK (n, k) : ℝ)) - ‖f n‖| ≤ 1/2^N`. This is the three-error decomposition (analytic core, DA required per C5).

## Errors hit & fixes

1. **`.succ` field-notation** on `Computable.snd.succ.succ` and `hd_Kpoly.succ` etc. — invalid because `Computable.succ : Computable Nat.succ` is a constant, not a projection. Fix: `Computable.succ.comp X` form. Established pattern at CMap.lean:266, 1284 etc. *(Add to PITFALLS.)*
2. **`convert ... using 1` timeout at whnf** — the inlined `rEntry` body (a huge `Finset.sum` over `Finset.range (d (n_idx (σ (Nat.pair MJ.1 MJ.2)), K_idx ...) + 1)` etc.) caused Lean to exhaust 200k heartbeats trying to defeq-check sub-terms. Fix: factor `gridQ, polyVal, absPolyVal, rEntry, sNK` as `set`-bound symbols so the equality proofs operate at the symbol level via `rw [Nat.pair_unpair]` rather than unfolding the bodies. *(Add to LEAN-IDIOMS as the "set-out, prove-via-rewrite" idiom.)*

## Build status

- `lake build ComputableAnalysis.L4.Instances.CMap` ✓ (sole sorry @ A3 body, line 2060).
- `lake build` (full repo) ✓ — 2532 jobs, sole sorry @ A3 body.

## Criteria delta

- C1, C2, C3 met (unchanged).
- **C4 strong progress**: the entire recursion-theoretic + computability scaffold is now sorry-free. The sole residual is the analytic three-error bound. C4 is **gated solely on Stage 3** (the bound proof).
- C5 unmet (Stage 3, DA required).
- C6, C7, C8, C9 unmet (downstream).

## What's needed next iter (iter-09)

### Stage 3 — Three-error bound proof

The bound to prove:
```
∀ n N k, k ≥ N → |((sNK (n, k) : ℝ)) - ‖f n‖| ≤ 1/2^N
```

With `e (n, N) := N`, this follows from the cleaner
```
∀ n k, |((sNK (n, k) : ℝ)) - ‖f n‖| ≤ 1/2^k
```
plus monotonicity `k ≥ N → 1/2^k ≤ 1/2^N`.

**Three-error decomposition** (DA-reviewed per C5):

- (a) **Polynomial-approximation error.** `|‖f n‖ - ‖p_{n, K_poly (n, k)}‖_∞| ≤ 2⁻ᴷ_poly⁻¹ = 2⁻ᵏ⁻²` (∗by `herr` applied at K = K_poly).
- (b) **Endpoint slack.** `Lip · max(2⁻ᵐ, 0)`-bounded by `Lip_nat · 2⁻ᵐ ≤ 2⁻ᵏ⁻²` by choice of `m_mod := Lip_nat + k + 2`.
- (c) **Grid spacing.** `Lip · 2B / k_grid ≤ 2⁻ᵏ⁻²` by choice of `k_grid := 8 · Lip_nat · B · 2^k + 1`.

Sum: 2⁻ᵏ⁻² + 2⁻ᵏ⁻² + 2⁻ᵏ⁻² < 2⁻ᵏ.

### Sub-lemmas likely needed

- `Lip_nat_bound`: `(Σⱼ j · |a(n, K_poly nN, j)| · B^(j−1) : ℝ) ≤ Lip_nat nN` (real-valued Lip bound ≤ ℕ-valued Lip_nat).
- `polyVal_eq_polyApproxCMap`: `polyVal p (as ℝ) = polyApproxCMap a d n K_poly evaluated at gridQ p (as ℝ)` for grid points in `[α, β]`; for grid points outside `[α, β]`, the polynomial expression is `Σⱼ a_j · x^j` evaluated outside the ContinuousMap domain.
- `sNK_lower`: `‖p_{n, K_poly k}‖_∞ ≤ sNK (n, k) + Lip · (2⁻ᵐ + 2B / k_grid)`.
- `sNK_upper`: `sNK (n, k) ≤ ‖p_{n, K_poly k}‖_∞ + Lip · 2⁻ᵐ`.

### DA invocation plan

After drafting Stage 3, invoke `/devils-advocate` with:
- The error-decomposition draft.
- The chapt0:984-1012 P-R verbatim text for cross-check.
- Specific challenge: are (a), (b), (c) tight enough? Does the `m_mod := Lip_nat + N + 2` choice actually give `Lip · 2⁻ᵐ ≤ 2⁻ᴺ⁻²`?

## Iters budget

Used: 8 / 100. Remaining: 92. Estimated 4-6 more iters to close C4-C7
(the analytic bound is the biggest remaining chunk).

## Files changed this iter

- `ComputableAnalysis/L4/Instances/CMap.lean` — replaced the A3 body's
  Phase-3 placeholder with the full Stage 1+2 plumbing (~210 lines added
  inside the body, sole sorry retained for Stage 3 only).

## Verification

- `lake build` ✓ (2532 jobs).
- Sole sorry warning at expected `CMap.lean:2060` (A3 body).
- Stop-hook write-scope respected: only `CMap.lean` modified.
