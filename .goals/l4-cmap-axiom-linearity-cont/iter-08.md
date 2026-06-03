# iter-08

timestamp: 2026-06-03T12:32:43.535416+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: budget doubled (8/180 → 16/360 per user authorization); `aS` redefined as `Finset.sum` form (equivalent to Nat.rec, enables direct `finsetSum_rat`); shipped two convenience helpers `isComputableSeqRat_doubleApply` (~12 lines) and `isComputableSeqRat_tripleApply` (~16 lines, uses `convert` due to function-composition beta-reduction quirk); helpers will be used in iter-09 main proof
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md', '.goals/l4-cmap-axiom-linearity-cont/iter-08.md']

## What shipped

### 1. Budget doubling

User authorized doubling on cap reach. Cap was 8/180; new cap is 16/360. Updated in:
- `current-goal.md`
- `.goals/l4-cmap-axiom-linearity-cont/goal.md`
- `.goals/INDEX.md` (status row updated to `7/16`).

### 2. `aS` redefined as `Finset.sum` form

```lean
let aS : ℕ × ℕ × ℕ → ℚ := fun nmj =>
  let n := nmj.1; let m := nmj.2.1; let j := nmj.2.2
  ∑ k ∈ Finset.range (d n + 1),
    (αR (Nat.pair n k, M (n, m)) * pad_X (k, M (n, m)) j
     + βR (Nat.pair n k, M (n, m)) * pad_Y (k, M (n, m)) j)
```

Was `Nat.rec`-based; now `Finset.sum`. Mathematically identical. `Finset.sum` enables direct application of `finsetSum_rat` for the IsComputableSeqRat (flatten aS) proof.

### 3. `isComputableSeqRat_doubleApply` helper

```lean
theorem isComputableSeqRat_doubleApply
    {f : ℕ × ℕ → ℚ} (hf : IsComputableDoubleSeqRat f)
    {a b : ℕ → ℕ} (ha : Computable a) (hb : Computable b) :
    IsComputableSeqRat (fun p => f (a p, b p)) := by
  have h_σ : Computable (fun p => Nat.pair (a p) (b p)) :=
    Primrec₂.natPair.to_comp.comp ha hb
  have key : IsComputableSeqRat (fun p => f (Nat.unpair (Nat.pair (a p) (b p)))) :=
    hf.comp h_σ
  have heq : (fun p => f (Nat.unpair (Nat.pair (a p) (b p)))) = (fun p => f (a p, b p)) := by
    funext p; rw [Nat.unpair_pair]
  rwa [heq] at key
```

~12 lines. Sorry-free. Use case: convert αR/βR (each `IsComputableDoubleSeqRat`) applied at Computable indexers into IsComputableSeqRat.

### 4. `isComputableSeqRat_tripleApply` helper

```lean
theorem isComputableSeqRat_tripleApply
    {f : ℕ × ℕ × ℕ → ℚ}
    (hf : IsComputableSeqRat (fun m =>
      f ((Nat.unpair m).1, (Nat.unpair (Nat.unpair m).2).1, (Nat.unpair (Nat.unpair m).2).2)))
    {a b c : ℕ → ℕ} (ha : Computable a) (hb : Computable b) (hc : Computable c) :
    IsComputableSeqRat (fun p => f (a p, b p, c p)) := by
  have h_bc : Computable (fun p => Nat.pair (b p) (c p)) :=
    Primrec₂.natPair.to_comp.comp hb hc
  have h_σ : Computable (fun p => Nat.pair (a p) (Nat.pair (b p) (c p))) :=
    Primrec₂.natPair.to_comp.comp ha h_bc
  have key := hf.comp h_σ
  convert key using 1
  funext p
  simp [Function.comp, Nat.unpair_pair]
```

~16 lines. The `convert ... using 1` pattern handles the function-composition vs beta-reduced form mismatch that `rwa` couldn't resolve.

Use case: convert aX/aY (each triple-flatten-IsComputableSeqRat from hflat_X, hflat_Y) applied at Computable indexers into IsComputableSeqRat.

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:439:18` (axiom_linearity decl, unchanged).
- 1 stylistic reducibility warning — deferred.

## iter-09 plan: main IsComputableSeqRat (flatten aS) proof

With aS in Finset.sum form, the first subgoal after `refine ⟨aS, dS, ?_, hd_S, ?_⟩` is:

```
IsComputableSeqRat (fun m =>
  let p := Nat.unpair m
  let q := Nat.unpair p.2
  ∑ k ∈ Finset.range (d p.1 + 1),
    (αR (Nat.pair p.1 k, M (p.1, q.1)) * pad_X (k, M (p.1, q.1)) q.2
     + βR (Nat.pair p.1 k, M (p.1, q.1)) * pad_Y (k, M (p.1, q.1)) q.2))
```

**Strategy** (port from iter-04.md's outline):

1. Apply `finsetSum_rat` with:
   - `r : ℕ × ℕ → ℚ` = the per-summand function (αR · pad_X + βR · pad_Y, indices decoded from outer)
   - `n : ℕ → ℕ` = `fun outer => d (Nat.unpair outer).1`
2. Sub-prove `Computable n`: `hd.comp (Computable.fst.comp Computable.unpair)`.
3. Sub-prove `IsComputableDoubleSeqRat r` via:
   - `IsComputableSeqRat.add` to split αR-term and βR-term.
   - For each term, `IsComputableSeqRat.mul` to split into coef + pad.
   - For αR / βR: `isComputableSeqRat_doubleApply` (this iter's helper).
   - For pad_X / pad_Y: `ite_rat` (zeroes past dX/dY), with the "then" branch via `isComputableSeqRat_tripleApply` on aX/aY.

Estimated lines: 80–120. Hairy plumbing but each step is a closure-lemma application.

### iter-10+ trajectory

| Iter | Deliverable |
|---|---|
| 09 | Ship the IsComputableSeqRat (flatten aS) proof. |
| 10 | Start norm bound: triangle inequality setup, sum-decomposition. |
| 11 | Norm bound: precision-pad arithmetic using hα_le, hβ_le. |
| 12 | Norm bound: close. |
| 13 | Blueprint `\leanok` on `thm:l4_cmap_instance`; claim file C5. |
| 14 | DA on C2; refresh `docs/NEXT-SESSION.md`. |
| 15–16 | Buffer / address stylistic reducibility warning. |
