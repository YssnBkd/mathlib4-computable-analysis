# iter-11

timestamp: 2026-06-03T13:04:45.446768+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: bound machinery shipped — `bound_aX_at_0`, `bound_aY_at_0`, `bound_αR_at_0`, `bound_βR_at_0` (simple compositions) + `h_Bpow : Computable (fun j => B^j)` (via Computable.nat_rec) + `bound_x_k`, `bound_y_k : ℕ → ℕ` (Σ_j bound_a · B^j, Computable via Computable.nat_rec); ~100 lines of plumbing, all sorry-free; `lake build` green; iter-12 ships bound_max + M redefinition
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md', '.goals/l4-cmap-axiom-linearity-cont/iter-08.md', '.goals/l4-cmap-axiom-linearity-cont/iter-09.md', '.goals/l4-cmap-axiom-linearity-cont/iter-10.md', '.goals/l4-cmap-axiom-linearity-cont/iter-11.md']

## What shipped

### Simple bound helpers (4 × ~10 lines each = 40 lines)

- `bound_aX_at_0 (k, j) := aX_a (Nat.pair k (Nat.pair 0 j))` — ℕ-upper-bound on `|aX(k, 0, j)|`.
- `bound_aY_at_0` — mirror for aY.
- `bound_αR_at_0 (n, k) := αR_a (Nat.pair (Nat.pair n k) 0)` — ℕ-upper-bound on `|αR(Nat.pair n k, 0)|`.
- `bound_βR_at_0` — mirror for βR.

Each Computability proof is a 3-line chain using `Primrec₂.natPair.to_comp.comp` + `h_aX_a.comp` etc.

### `h_Bpow : Computable (fun j : ℕ => B^j)` (~15 lines)

Built via `Computable.nat_rec` + `.of_eq` + induction:
```lean
have h_Bpow : Computable (fun j : ℕ => B^j) := by
  have hh : Computable₂ (fun (_ : ℕ) (yih : ℕ × ℕ) => yih.2 * B) := ...
  have h_rec := Computable.nat_rec Computable.id (Computable.const (1 : ℕ)) hh
  refine h_rec.of_eq fun j => ?_
  show Nat.rec 1 (fun y IH => (y, IH).2 * B) j = B^j
  induction j with
  | zero => rfl
  | succ j IH =>
    show Nat.rec 1 (fun y IH' => (y, IH').2 * B) j * B = B^(j + 1)
    rw [IH, pow_succ]
```

**Pitfall hit**: the `Computable.nat_rec` output has step function `fun y IH => (y, IH).2 * B` (with `Prod.snd` on a tuple lambda) rather than the more natural `fun _ IH => IH * B`. To make `rw [IH]` succeed in the succ case, `show` forces the goal into the IH's exact form.

### `bound_x_k`, `bound_y_k` (~30 lines each = 60 lines)

```lean
let bound_x_k : ℕ → ℕ := fun k =>
  Nat.rec 1 (fun j acc => acc + bound_aX_at_0 (k, j) * B^j) ((dX (k, 0)).succ)
have h_bound_x_k : Computable bound_x_k := by
  -- Computable.nat_rec with:
  --   f := fun k => (dX (k, 0)).succ  (Computable via hd_X.comp ...)
  --   g := const 1
  --   h := fun k (j, acc) => acc + bound_aX_at_0 (k, j) * B^j  (Computable via composition)
  ...
```

The step Computability chain (`hh`) uses 8 `have`s for projections + indexers + multiplications.

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at the norm bound subgoal — unchanged.
- 1 stylistic reducibility warning — benign.

## Now in scope (for iter-12+)

- `bound_aX_at_0, bound_aY_at_0, bound_αR_at_0, bound_βR_at_0 : ℕ × ℕ → ℕ` Computable.
- `bound_x_k, bound_y_k : ℕ → ℕ` Computable.
- `h_Bpow : Computable (fun j => B^j)`.

## iter-12 plan

1. Define `stuff_per_k : ℕ × ℕ → ℕ := fun nk => bound_x_k nk.2 + bound_y_k nk.2 + bound_αR_at_0 nk + bound_βR_at_0 nk + 6` and prove Computability (~15 lines).
2. Define `bound_max : ℕ → ℕ := fun n => Nat.rec 0 (fun k acc => max acc (stuff_per_k (n, k))) ((d n).succ)` and prove Computability via `Computable.nat_rec` (~20 lines).
3. Redefine `M : ℕ × ℕ → ℕ := fun nm => nm.2 + (d nm.1 + 1) + bound_max nm.1 + 2` (5 lines).
4. Reprove `hM : Computable M` (10 lines).

This should fit in iter-12. iter-13+ then has the norm bound machinery in place and tackles the bound proof.

## iter-13-16 plan (norm bound proof)

- iter-13: open the norm bound subgoal, introduce `n m`, set up the polynomial expansion:
  `polyApproxCMap aS dS n m (x_*) = Σ_k (αR · polyApprox aX dX k M + βR · polyApprox aY dY k M) (x_*)`
- iter-14: triangle inequality + α-side bound calculation.
- iter-15: β-side bound + close.
- iter-16: blueprint `\leanok` + claim file C5 + DA on C2 + refresh NEXT-SESSION.

## Round-status projection (revised)

The bound machinery is shipping faster than expected (iter-11 was productive). Updated:
- **Full close**: ~50% (was 40%). The hard part (Computability of bound machinery) is mostly done.
- **Partial close**: ~35% (was 40%).
- **Budget exhausted at iter-16**: ~15% (was 20%).

The actual norm bound proof (iters 13-15) remains the risk. If it spills past iter-16, we'll need another budget double per user's authorization.
