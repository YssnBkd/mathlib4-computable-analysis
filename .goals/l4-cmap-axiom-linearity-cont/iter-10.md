# iter-10

timestamp: 2026-06-03T12:55:57.701054+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: norm-bound analysis + inner destructures shipped — extracted `(aX_a, aX_b, aX_s)`, `(aY_a, aY_b, aY_s)`, `(αR_a, αR_b, αR_s)`, `(βR_a, βR_b, βR_s)` Computable witnesses from hflat_X/Y/αR/βR; re-introduced hflat_X etc. via `have` so iter-09's IsComputableSeqRat proof still type-checks; `lake build` green; iter-11+ builds Computable bound_x_k, bound_y_k, stuff_per_k, bound_max and redefines M
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md', '.goals/l4-cmap-axiom-linearity-cont/iter-08.md', '.goals/l4-cmap-axiom-linearity-cont/iter-09.md', '.goals/l4-cmap-axiom-linearity-cont/iter-10.md']

## Norm-bound analysis: why current M is insufficient

Current `M (n, m) := m + 2 * (d n + 1)`. After triangle inequality, the bound reduces to:

```
‖s n - polyApproxCMap aS dS n m‖ ≤ Σ_k (2^{-M} · stuff_per_k(n))
                                = 2^{-M} · Σ_k stuff_per_k(n)
```

For this to be `≤ 2^{-m}`, we need `Σ_k stuff_per_k(n) ≤ 2^{M-m} = 4^{d n + 1}`. But:

```
stuff_per_k(n) := ‖x_k‖_∞ + ‖y_k‖_∞ + |αR(Nat.pair n k, M)| + |βR(...)| + 2
```

depends on the witness data `aX, aY, αR, βR` (which can be arbitrary). In particular, `‖x_k‖_∞ ≤ 1 + Σ_j |aX(k, 0, j)| · B^j` involves potentially-huge rationals. So `Σ_k stuff_per_k` is unbounded by `4^{d n + 1}` in general.

**Resolution**: M must incorporate a Computable bound on `Σ_k stuff_per_k(n)`.

## The path: use the IsComputableSeqRat inner witnesses

`IsComputableSeqRat r` unfolds to `∃ a b s : ℕ → ℕ, Computable a ∧ Computable b ∧ Computable s ∧ (∀ k, b k ≠ 0) ∧ (∀ k, r k = (-1)^(s k) · (a k / b k))`.

So from `hflat_X : IsComputableSeqRat (flat aX)`, we extract `aX_a : ℕ → ℕ` Computable with `|flat_aX k| ≤ aX_a k` (as a real, since `b ≥ 1`).

Then `|aX (k, 0, j)| = |flat_aX (Nat.pair k (Nat.pair 0 j))| ≤ aX_a (Nat.pair k (Nat.pair 0 j))`.

The ℕ-valued `aX_a (Nat.pair k (Nat.pair 0 j))` gives a Computable upper bound on `|aX (k, 0, j)|`. This is exactly the bound machinery needed for `bound_max(n)`.

## What shipped this iter

Four inner destructures, each followed by re-introducing the outer hypothesis:

```lean
obtain ⟨aX_a, aX_b, aX_s, h_aX_a, h_aX_b, h_aX_s, h_aX_bne, h_aX_eq⟩ := hflat_X
have hflat_X : IsComputableSeqRat (fun m => aX (...)) :=
  ⟨aX_a, aX_b, aX_s, h_aX_a, h_aX_b, h_aX_s, h_aX_bne, h_aX_eq⟩
-- similarly for hflat_Y, hflat_αR, hflat_βR
```

The re-introduction preserves the iter-09 IsComputableSeqRat (flatten aS) proof intact (it uses `hflat_X` etc. as `IsComputableDoubleSeqRat`/`IsComputableSeqRat` black boxes).

Now in scope:
- `aX_a, aX_b, aX_s : ℕ → ℕ` Computable (with `h_aX_a, h_aX_b, h_aX_s : Computable`).
- `h_aX_bne : ∀ k, aX_b k ≠ 0`.
- `h_aX_eq : ∀ k, flat_aX k = (-1)^(aX_s k) · (aX_a k / aX_b k)`.
- (similarly for aY, αR, βR — 24 Computable functions total)

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at the norm bound subgoal — unchanged.
- 1 stylistic reducibility warning — benign.

## iter-11 plan

Ship the Computability of:

1. `bound_aX_at_0 : ℕ × ℕ → ℕ := fun kj => aX_a (Nat.pair kj.1 (Nat.pair 0 kj.2))` — Computable via composition of `h_aX_a` + `Primrec₂.natPair.to_comp`.
2. `bound_x_k : ℕ → ℕ := fun k => 1 + Σ_j ∈ Finset.range (dX (k, 0) + 1), bound_aX_at_0 (k, j) * B^j` — Computable via `Computable.nat_rec` on `dX (k, 0) + 1`.
3. Similar for `bound_y_k`.
4. `bound_αR_at_0 : ℕ × ℕ → ℕ`, `bound_βR_at_0 : ℕ × ℕ → ℕ` (simpler — just composition).

Estimated lines: 80–100 for iter-11.

## iter-12+ plan

- iter-12: define `stuff_per_k`, `bound_max`, redefine M, reprove hM.
- iter-13: open the norm bound subgoal, set up triangle inequality, polynomial expansion.
- iter-14: bound the αR side using hα_le, hbnd_αR, hbnd_X, bound_x_k.
- iter-15: bound the βR side similarly; close the total.
- iter-16: blueprint `\leanok` + claim file C5 + DA on C2 + refresh NEXT-SESSION + reducibility warning fix.

This is tight but tractable with the budget extension.

## Round-status projection (revised)

- **Full close (C1–C5 all met)**: ~40% (was 55%). The norm bound is genuinely heavy; budget feels tight even with the extension.
- **Partial close (C1 met except norm bound)**: ~40% (was 30%). The witness construction is fully shipped; the norm bound being the only sorry is a clean partial.
- **Round budget-exhausted at iter 16**: ~20%. The norm bound may need a further extension.

If we hit iter-16 without closure, this round's deliverables are STILL substantial: 5/6 axiom_linearity fields closed, 5 reusable closure helpers (`finsetSum_rat`, `ite_rat`, `addTriple{,_b_ne_zero,_correct,_computable}`, `isComputableSeqRat_doubleApply`, `isComputableSeqRat_tripleApply`), instance restructure to take rational bound, ~500 lines of new Lean. The norm bound is well-scoped for a follow-up round.
