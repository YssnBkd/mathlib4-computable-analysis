# iter-12

timestamp: 2026-06-03T13:13:56.930986+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: M redesign COMPLETE — `stuff_per_k` (~15 lines) + `bound_max` via Computable.nat_rec (~25 lines) + new M formula (`m + (d n + 1) + bound_max n + 2`) + updated hM proof (~15 lines); ~80 lines of new Computability plumbing, all sorry-free; iter-09's IsComputableSeqRat proof still type-checks (M referenced as black box via hM); `lake build` green (2532 jobs); only norm-bound sorry remains; iter-13+ tackles the bound proof itself
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md', '.goals/l4-cmap-axiom-linearity-cont/iter-08.md', '.goals/l4-cmap-axiom-linearity-cont/iter-09.md', '.goals/l4-cmap-axiom-linearity-cont/iter-10.md', '.goals/l4-cmap-axiom-linearity-cont/iter-11.md', '.goals/l4-cmap-axiom-linearity-cont/iter-12.md']

## What shipped — the M redesign

### `stuff_per_k : ℕ × ℕ → ℕ` (~15 lines)

```lean
let stuff_per_k : ℕ × ℕ → ℕ := fun nk =>
  bound_x_k nk.2 + bound_y_k nk.2 + bound_αR_at_0 nk + bound_βR_at_0 nk + 6
```

Sums the 4 bound helpers shipped in iter-11 + a constant 6. Computability via standard `Primrec.nat_add` chains.

### `bound_max : ℕ → ℕ` (~25 lines)

```lean
let bound_max : ℕ → ℕ := fun n =>
  Nat.rec 0 (fun k acc => max acc (stuff_per_k (n, k))) ((d n).succ)
```

Max of `stuff_per_k (n, k)` over k ∈ `Finset.range (d n + 1)`. Computability via `Computable.nat_rec` (same pattern as iter-07's `hd_S`).

### New M formula + updated hM

```lean
let M : ℕ × ℕ → ℕ := fun nm => nm.2 + (d nm.1 + 1) + bound_max nm.1 + 2
```

With `2^M = 2^m · 2^(d n + 1) · 2^bound_max(n) · 4 ≥ 4 · (d n + 1) · 2^bound_max(n)`,
and `2^bound_max(n) ≥ bound_max(n) ≥ max_k stuff_per_k(n, k)`,
and `Σ_k stuff_per_k(n, k) ≤ (d n + 1) · max_k stuff_per_k(n, k)`,
we get `2^M ≥ 4 · Σ_k stuff_per_k(n, k)`. The `4` factor gives slack for the bound argument.

hM Computability: re-proved with `bound_max` Computability composed via `Computable.fst`.

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at the norm bound subgoal (unchanged).
- 1 stylistic reducibility warning (benign).

## Critical: iter-09's IsComputableSeqRat proof STILL works

The iter-09 IsComputableSeqRat (flatten aS) proof references M only via `hM : Computable M` (black box). Since M's new formula is more complex but its Computability is established, the iter-09 proof is unaffected. Verified by lake build success.

## iter-13 plan: open the norm-bound subgoal

Subgoal: `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1 / 2 ^ m`

Strategy outline:

1. `intro n m`.
2. Express `polyApproxCMap aS dS n m (x_*)` via interchange of sums:
   ```
   polyApproxCMap aS dS n m (x_*) = Σ k ∈ Finset.range (d n + 1),
     (αR (Nat.pair n k, M (n, m)) * (polyApprox aX dX k (M (n, m)) (x_*) : ℝ)
      + βR (Nat.pair n k, M (n, m)) * (polyApprox aY dY k (M (n, m)) (x_*) : ℝ))
   ```
   (Use `Finset.sum_comm` to swap j-sum and k-sum; the inner j-sum with padcoeff equals polyApprox.)
3. `ContinuousMap.norm_sub_le_iff` or similar to reduce `‖f - g‖ ≤ ε` to pointwise.
4. Pointwise bound at each `x_* ∈ Set.Icc α β`:
   ```
   |s n (x_*) - polyApproxCMap aS dS n m (x_*)| ≤ Σ_k (α-summand-bound + β-summand-bound)
   ```
5. α-summand bound:
   ```
   |coefα (n, k) * x k (x_*) - αR (Nat.pair n k, M) * polyApprox aX dX k M (x_*)|
     ≤ |coefα (n, k) - αR| · |x k (x_*)| + |αR| · |x k (x_*) - polyApprox aX dX k M (x_*)|
     ≤ 2^{-M} · ‖x k‖_∞ + |αR| · 2^{-M}
     ≤ 2^{-M} · (bound_x_k k + bound_αR_at_0 (n, k) + 2)
     ≤ 2^{-M} · stuff_per_k (n, k)
   ```
6. β-summand bound: mirror.
7. Sum over k: `Σ_k ≤ 2^{-M} · 2 · Σ_k stuff_per_k(n, k) ≤ 2^{-M} · 2 · (d n + 1) · bound_max(n)`.
8. Use M = m + (d n + 1) + bound_max(n) + 2: `2^M ≥ 4 · (d n + 1) · 2^bound_max(n) ≥ 4 · (d n + 1) · bound_max(n)`. So `2^{-M} · 2 · (d n + 1) · bound_max(n) ≤ 1/2 · 2^{-m} ≤ 2^{-m}`. ✓

Estimated lines: 200-300.

## Round-status projection (revised)

The bound machinery is COMPLETE. Now it's a question of whether the bound proof itself fits in 4 iters (13-16):
- **Full close**: ~50% (unchanged — the bound proof is still the question).
- **Partial close** (only norm bound sorry, with strong machinery): ~35%.
- **Budget exhausted at iter-16**: ~15%, would need another budget double.

The norm bound proof is conceptually straightforward but technically dense (ContinuousMap norm + Finset.sum manipulation + triangle inequality + bound chasing). Each step is mechanical but adds up.

## Next iter (iter-13) entry conditions

1. Read `ComputableAnalysis/L4/Instances/CMap.lean:680-700` (the norm bound subgoal state).
2. Read `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md:115-150` (paper-form bound).
3. Read this file (`iter-12.md`).

Then `intro n m`, set up the polynomial-expansion identity as a `have`, then triangle inequality.
