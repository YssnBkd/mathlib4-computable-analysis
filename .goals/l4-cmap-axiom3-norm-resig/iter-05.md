---
iter: 5
timestamp: 2026-06-04T05:30:00Z
mode: proof-attempt
unmet: [C4, C5, C6, C7, C8, C9]
files_changed:
  - ComputableAnalysis/L4/Instances/CMap.lean
note: |
  Phase 3.1 CLOSED. The `FinsetMaxHelper` namespace is now complete and
  sorry-free: `maxTriple_computable : Computable₂ maxTriple` and
  `finsetMax_rat` (IsComputableSeqRat closure under `Finset.sup'` over a
  Computable-bounded range) both compile. This resolves the exact blocker
  that stalled iter-04 (`maxTriple_correct`'s parity case-split + the
  variable-depth-fold correctness).
---

# iter-05 — Phase 3.1 close (FinsetMaxHelper complete)

## What landed (sorry-free, `lake build` green; sole sorry = A3 body @1783)

1. **`maxTriple_correct`** (rewritten last session, verified compiling this
   session): the wholesale-selection design
   `maxTriple t₁ t₂ := bif maxBool t₁ t₂ then t₁ else t₂` reduces the
   correctness proof to a clean 4-way parity case-split closing each branch
   with `div_le_div_iff₀` + `sup_eq_left/right`. The iter-04 stall (component
   recombination) is gone.

2. **`maxTriple_computable : Computable₂ maxTriple`** — mirrors
   `addTriple_computable`'s projection + `Computable.cond` recipe. `maxBool` is
   a nested `Computable.cond` (parity-eq Bool, parity-zero Bool, `≥`/`≤`
   cross-product Bools), then `Computable.cond h_maxbool fst snd` selects the
   winning triple. Used `Primrec.nat_le.decide` for the `≤` branch (vs.
   `.swap.decide` for `≥`).

3. **`finsetMax_rat`** — the max-analogue of `FinsetSumHelper.finsetSum_rat`.
   Statement: for `IsComputableDoubleSeqRat r` and `Computable n`,
   `fun k => (range (n k + 1)).sup' nonempty_range_add_one (fun j => r (k,j))`
   is `IsComputableSeqRat`. This is A3 outline step ② ("partial max").

## Key design win — route correctness through `partialSups`

The max-fold has **no additive identity** (unlike `finsetSum_rat`'s
`(0,1,0)`), so the fold starts from the first element (`witness k 0`) and the
target `sup'` is over a **nonempty** range. Rewriting `range (m+1)` under a
`sup'`'s nonempty-proof argument hits a motive error. **Sidestepped entirely**
by proving the fold equals `partialSups (fun j => r (k,j)) m`
(Mathlib `Mathlib.Order.PartialSups`), via:
- `partialSups_zero : partialSups f 0 = f 0` (base);
- `partialSups_succ : partialSups f (Order.succ m) = partialSups f m ⊔ f (Order.succ m)`
  (step) — works because `Nat.succ_eq_succ : Order.succ = Nat.succ := rfl`, so
  `Order.succ m` is **defeq** `m + 1` on ℕ; `exact (partialSups_succ …).symm`
  closes the succ goal directly.
- `partialSups_eq_sup'_range : partialSups f n = (range (n+1)).sup' … f` — the
  final bridge, applied via `funext` on plain function equality (no
  dependent-proof rewriting).

Added `import Mathlib.Order.PartialSups` to CMap.lean.

## Mathlib facts verified this iter (extend PITFALLS at round end)

- `partialSups` (lowercase, root namespace) + `partialSups_zero` /
  `partialSups_succ` / `partialSups_eq_sup'_range` in `Mathlib.Order.PartialSups`.
- `Nat.succ_eq_succ : Order.succ = Nat.succ := rfl` (`Data/Nat/SuccPred.lean:52`)
  — `Order.succ` is defeq `+1` on ℕ, so `partialSups_succ` needs no massaging.
- `Finset.sup'_insert` needs `s.Nonempty`; `Finset.sup'_singleton`,
  `Finset.range_one` exist but rewriting the Finset under `sup'`'s proof arg is
  a motive trap — prefer the `partialSups` route.
- `rw [maxTriple_correct ih_b (hne_r …)]` leaves `?t₂` as a metavar (the
  `b ≠ 0` hyp doesn't pin a Prod via projection unification); `rw`'s match
  against the goal's iota-reduced `Nat.rec … (succ m)` solves it — same idiom
  as `finsetSum_rat`.

## Criteria delta

- C1, C2, C3 met (unchanged).
- **C4 partial**: FinsetMaxHelper (step ②'s closure) done; A3 body still open.
- C5–C9 unmet — Phase 3.2/3.3/3.4 + Phase 4 ahead.

## Next (this conversation continues)

- Phase 3.2: polynomial Lipschitz bound helper (pure real-analysis lemma).
- Phase 3.3: A3 witness `sNK` + modulus `e` + three-error decomposition (DA req, C5).
- Phase 3.4: apply `isComputableSeqReal_of_effectiveConvergence` to close @1783.
