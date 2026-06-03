# iter-06

timestamp: 2026-06-03T12:18:52.987575+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: A1 body skeleton shipped — let-bindings for `M`, `dS`, `pad_X`, `pad_Y`, `aS` inside `axiom_linearity` body (concrete formulas, type-checked, sorry-free at the let-binding level); outer `sorry` retained; `lake build` green, 1 sorry-warning total; user authorized budget doubling on cap reach
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md']

## What shipped

Inside the `axiom_linearity` proof body (after the 4 obtains), iter-06 adds five let-bindings defining the witness:

```lean
let M : ℕ × ℕ → ℕ := fun nm => nm.2 + 2 * (d nm.1 + 1)
let dS : ℕ × ℕ → ℕ := fun nm =>
  Nat.rec 0 (fun k acc => max acc (max (dX (k, M nm)) (dY (k, M nm))))
    ((d nm.1).succ)
let pad_X : ℕ × ℕ → ℕ → ℚ := fun km j =>
  if j ≤ dX km then aX (km.1, km.2, j) else 0
let pad_Y : ℕ × ℕ → ℕ → ℚ := fun km j =>
  if j ≤ dY km then aY (km.1, km.2, j) else 0
let aS : ℕ × ℕ × ℕ → ℚ := fun nmj =>
  let n := nmj.1; let m := nmj.2.1; let j := nmj.2.2
  Nat.rec 0 (fun k acc => acc
    + αR (Nat.pair n k, M (n, m)) * pad_X (k, M (n, m)) j
    + βR (Nat.pair n k, M (n, m)) * pad_Y (k, M (n, m)) j)
    ((d n).succ)
```

All five let-bindings are concrete, type-checked, sorry-free at the let-binding level. The outer `sorry` retained closes axiom_linearity for now; iter-07 turns it into a `refine ⟨aS, dS, ?_, ?_, ?_⟩` + the three subgoals.

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:404:18` (the outer `sorry`, unchanged).
- 1 stylistic warning (reducibility on `computabilityStructureCMap_of`) — benign, deferred.

## Budget update (per user instruction)

User authorized **doubling of the iteration cap and time budget on cap reach**:
- Current cap: 8 iters / 180 min.
- On reaching 8/8 (or 180 min elapsed), double to 16 iters / 360 min.

This removes the pressure to ship a partial A1; we can take the time needed for a clean A1 close. Round-status projection updated:

- **Full close (C1–C5 all met)**: ~55% (was 40%).
- **Partial close (C1 met except norm bound, C4–C5 partial)**: ~30% (was 40%).
- **Still pending or partial**: ~15% (was 20%).

## iter-07 → iter-08 (and iter-09–iter-16 if needed) trajectory

| Iter | Deliverable | Notes |
|---|---|---|
| 07 | `refine ⟨aS, dS, ?_, ?_, ?_⟩` + close `Computable dS` via `Computable.nat_rec` (same pattern as `_finsetSum_rat`). | Net sorries: 2 after iter-07 (was 1, now split into 2 subgoals). |
| 08 | Close `IsComputableSeqRat (flatten aS)` via `_finsetSum_rat` on outer-k-sum + `ite_rat` for pads + L1 closures. Heaviest plumbing iter. | Net sorries: 1 (just the bound). |
| 09 (if needed) | Norm bound iter 1: extract polynomial-form expansion of `polyApproxCMap aS dS n m`, set up triangle inequality. | Net sorries: 1. |
| 10 (if needed) | Norm bound iter 2: close the precision-pad arithmetic using hα_le, hβ_le. | Net sorries: 0 → C1 met. |
| 11–12 (if needed) | Blueprint `\leanok` for `thm:l4_cmap_instance`; claim file C5; DA on C2; refresh `docs/NEXT-SESSION.md`; address stylistic `@[reducible]` warning. | Net sorries: 0. C1–C5 all met. |

If iter-07/08 go well, the round can wrap by iter-10–12. If norm bound proves harder, iters 13–16 absorb spillover.

## Next iter (iter-07) entry conditions

The next iter should open by:

1. Reading `ComputableAnalysis/L4/Instances/CMap.lean:395-430` (the destructured + let-bound A1 body).
2. Reading `ComputableAnalysis/L1/ComputableSeqReal.lean:159-352` (the L1 closures: `.add`, `.mul`, `.comp`).
3. Reading `ComputableAnalysis/L4/Instances/CMap.lean:159-310` (this round's helpers: `addTriple{_b_ne_zero,_correct,_computable}`, `finsetSum_rat`, `ite_rat`).
4. Reading this file (`iter-06.md`) for the iter-07+ plan.

Then implement `Computable dS` via `Computable.nat_rec`. Single-file check first.
