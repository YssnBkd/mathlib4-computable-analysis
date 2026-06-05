---
iter: 7
timestamp: 2026-06-04T08:30:00Z
mode: proof-attempt
unmet: [C4, C5, C6, C7, C8, C9]
files_changed:
  - ComputableAnalysis/L4/Instances/CMap.lean
  - ComputableAnalysis/L1/ComputableSeqReal.lean
note: |
  Phase 3.3.3 (`gridQ_isComputableSeqRat`) CLOSED, sorry-free. Plus
  `IsComputableSeqRat.neg` and `.sub` added to L1 as reusable closures.
  All Phase 3.3 helper plumbing is now in place; A3's body fill-in is the
  remaining work. Sole sorry @ `CMap.lean:~2061` (A3 body).
---

# iter-07 — Phase 3.3.3 close (grid points + L1 neg/sub)

## What landed

### L1: `IsComputableSeqRat.neg` and `.sub`

Two short reusable closure lemmas (~15 lines combined) added to L1's
`IsComputableSeqRat` namespace, between `mul` and `max`:

- **`neg h`**: closure under pointwise negation. Witness flips sign by
  `s := old_s + 1`; identity reduces via `pow_succ` + `ring`.
- **`sub h₁ h₂`**: closure under pointwise subtraction. Defined as
  `add ∘ neg` with `convert ... using 1; ring` to match the goal.

These pave the way for `gridQ`-style constructions where `βR − αR` arises.

### L4: `PolyEvalHelper.gridQ_isComputableSeqRat`

Given `IsComputableDoubleSeqRat αR, βR` (the rational approximants from
`hα_c, hβ_c`), `Computable` precision selector `m : ℕ × ℕ → ℕ`, and
`Computable` nonzero grid count `k : ℕ × ℕ → ℕ`, the doubly-indexed rational
grid
`αR(0, m(n,N)) + (J/k(n,N)) · (βR(0, m(n,N)) − αR(0, m(n,N)))`
viewed as a flat `IsComputableSeqRat` indexed by `p = Nat.pair n (Nat.pair N J)`.

Stepwise build via closure API:
1. Computable projectors `n, N, J : ℕ → ℕ` via `Computable.unpair` chains.
2. `αR_seq, βR_seq` via `IsComputableSeqRat.comp` of `αR-flat, βR-flat` with
   `σ p := Nat.pair 0 (m (n_p, N_p))`.
3. `βR_seq − αR_seq` via `IsComputableSeqRat.sub` (new L1 helper).
4. `(J:ℚ)/(k:ℚ)` via direct witness triple `(J p, k (n_p, N_p), 0)` using
   `hk_pos` for the b-nonzero clause.
5. Product via `IsComputableSeqRat.mul`.
6. Sum via `IsComputableSeqRat.add`.

Each step is one closure application; total ~70 lines. A3 step ① helper.

## Build status

- `lake build ComputableAnalysis.L4.Instances.CMap` ✓ (sole sorry @ A3 body).
- L1's neg/sub compile clean.
- One transient `push_cast`-does-nothing warning fixed.

## Criteria delta

- C1, C2, C3 met (unchanged).
- **C4 partial++**: all helpers for the construction now in place; the
  modulus engineering + sNK assembly + error-bound proof remain.
- C5–C9 unmet.

## What's needed for A3 body close (next iter)

### Stage 1 — Modulus engineering (concrete defs)

Inside A3's body, after destructuring `hf, hα_c, hβ_c`:
- `K_poly (nN) := nN.2 + 2` (polynomial precision; gives 2⁻ᴺ⁻² error).
- `Lip_nat (nN)`: ℕ-valued bound on `Lip(p_{n,K_poly})`. Concretely:
  `Σⱼ j · a_num(Nat.pair n (Nat.pair K_poly(nN) j)) · B^(j−1)` summed via
  `Nat.rec` to bound `d (n, K_poly(nN))`. Loose ℕ bound: replace each
  `|aⱼ| = a_num/b_den` by `a_num` (since `b_den ≥ 1`).
- `m (nN) := Lip_nat (nN) + nN.2 + 4`.
- `k_grid (nN) := 4 · Lip_nat (nN) · 2 · B · 2^nN.2 + 1`.

### Stage 2 — sNK assembly

- `polyAtGrid_seq` := apply `polyVal_isComputableSeqRat` to `(a, d, n_idx,
  K_idx, gridQ_seq)`. Get `IsComputableSeqRat polyAtGrid_seq`.
- `abs_polyAtGrid_seq` := `IsComputableSeqRat.abs`.
- `sNK (n, N)` := `(range (k_grid (n,N) + 1)).sup' (fun J => abs_poly... (Nat.pair n (Nat.pair N J)))`
- `hsNK` := `finsetMax_rat (hr := abs_polyAtGrid_lifted_to_double) (hn := h_k_grid)`.

### Stage 3 — Three-error bound (DA-reviewed, C5)

Prove `∀ n k, |((sNK (n, k) : ℝ)) - ‖f n‖| ≤ 1/2^k`.

Decomposition:
- (a) Polynomial approximation: `|‖f n‖ − ‖p_{n, K_poly(n,k)}‖_∞| ≤ 2⁻ᴷ⁻² = 2⁻ᵏ⁻²` (via `herr`).
- (b) Grid + endpoint: `|sNK (n, k) − ‖p_{n, K_poly}‖_∞| ≤ Lip·(2·2⁻ᵐ + (β−α)/k_grid)`.
- With `m, k_grid` chosen as above: (b) ≤ 2⁻ᵏ⁻³ + 2⁻ᵏ⁻² < 3·2⁻ᵏ⁻².
- Total: (a) + (b) ≤ 2⁻ᵏ.

### Stage 4 — Apply Prop 1

`isComputableSeqReal_of_effectiveConvergence hsNK (Computable.snd) bound`
where `e (n, N) := N` (the `Computable.snd` of the pair `(n, N)`).

## Iters budget

Used: 7 / 100. Remaining: 93. Estimated 3-4 more iters to close C4-C7.

## Files changed this iter

- `ComputableAnalysis/L1/ComputableSeqReal.lean` — added `IsComputableSeqRat.neg`
  and `IsComputableSeqRat.sub`.
- `ComputableAnalysis/L4/Instances/CMap.lean` — added
  `PolyEvalHelper.gridQ_isComputableSeqRat`; minor `push_cast` cleanup.

## Verification

- `lake build` ✓.
- Line-length check ✓.
- Single sorry warning at expected `CMap.lean:~2061` (A3 body).
- Stop-hook write-scope respected: L1 and L4/CMap are both in allow_writes.
