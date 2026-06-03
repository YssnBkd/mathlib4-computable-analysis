# iter-07

timestamp: 2026-06-03T12:25:25.993680+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: shipped `Computable M` (~6 lines) and `Computable dS` (~25 lines, uses `Computable.nat_rec` + `Primrec.nat_max`) inside A1 body; `refine ⟨aS, dS, ?_, hd_S, ?_⟩` placed; 2 of 5 witness fields closed (`IsComputableSeq` + `Computable d`), 2 sorries remain (IsComputableSeqRat aS, norm bound); Lean consolidates to 1 sorry-warning at decl line; `lake build` + `checkdecls` both green
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md']

## What shipped

Inside A1 body, after the let-bindings:

1. **`have hM : Computable M`** — Computability of the precision pad. Pattern:
   `Computable.snd.pair (Primrec.nat_mul.to_comp.comp (.const 2) (Computable.succ.comp (hd.comp Computable.fst)))` style composition. ~6 lines.

2. **`have hd_S : Computable dS`** — Computability of the degree bound, via `Computable.nat_rec` on `(d nm.1).succ`. The step function `(nm, (k, acc)) ↦ max acc (max (dX (k, M nm)) (dY (k, M nm)))` is Computable₂ via a chain of `.fst`/`.snd`/`.pair`/`.comp` projections + `Primrec.nat_max` (`Primrec/Basic.lean:620`). ~25 lines.

3. **`refine ⟨aS, dS, ?_, hd_S, ?_⟩`** — fills the witness `⟨a, d, IsComputableSeqRat, Computable d, bound⟩`. **4 of 5 positions closed** (aS and dS as the literal let-bindings; hd_S as the Computability proof; the IsComputableSeq field is closed earlier in the struct via `IsComputableSeq := IsComputableSeqCMap`). 2 subgoals remain.

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:404:18` — Lean consolidates the 2 internal sorries (IsComputableSeqRat aS subgoal + norm bound subgoal) into a single declaration-level warning at the `axiom_linearity` line.
- 1 stylistic warning (reducibility) — benign, deferred.

## Budget situation

- Current iter: **7/8**.
- Next iter (08) is the original cap. Per user authorization, on cap reach the budget doubles to **16 iters / 360 min**.
- Realistic projection: iter-08 ships the IsComputableSeqRat (flatten aS) proof (~80–120 lines of plumbing); iters 09–11 ship the norm bound; iters 12–13 finalize blueprint/claim/DA.

## iter-08 plan (heaviest iter)

Target: close the IsComputableSeqRat (flatten aS) subgoal.

Strategy:
1. Express `flatten aS : ℕ → ℚ` (the Nat.unpair-reindexed aS) as a finset sum closure.
2. The sum has form `Σ_{k ≤ d n} (αR_term + βR_term)` where each term is `αR · pad`.
3. Apply `_finsetSum_rat` with the outer-k as the sum index.
4. The double-seq `r' : ℕ × ℕ → ℚ` for `_finsetSum_rat` is the per-summand value: `r'(outerIdx, k) = αR · pad_X + βR · pad_Y` at appropriately-indexed values.
5. To show `IsComputableDoubleSeqRat r'`: chain through L1's `IsComputableSeqRat.{add, mul, comp}` + `ite_rat` (for pad's conditional).

Estimated lines: 80–120. Most of the work is plumbing — proving Computability of various compositions on ℕ × ℕ × ℕ → ℚ.

## Notes for iter-08 entry

The next iter should open by:

1. Reading `ComputableAnalysis/L4/Instances/CMap.lean:395-470` (the current A1 body state).
2. Reading this file (`iter-07.md`) for the iter-08 plan.
3. Re-reading `ComputableAnalysis/L4/Instances/CMap.lean:159-310` for the helpers (`finsetSum_rat`, `ite_rat`).

Single-file check after each major chunk. Aggressive but the helpers are in place.
