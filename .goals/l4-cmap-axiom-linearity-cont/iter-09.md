# iter-09

timestamp: 2026-06-03T12:43:18.233729+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: MAJOR — IsComputableSeqRat (flatten aS) PROVED via `finsetSum_rat` + `isComputableSeqRat_doubleApply` + `isComputableSeqRat_tripleApply` + `ite_rat` + L1 `.add`/`.mul`; ~150 lines of decoder/indexer chains + the explicit-`hr'` `convert ... using 1` trick to bridge Pi.add_apply/Pi.mul_apply gap; only norm bound sorry remains; pad_X/Y switched to `bif decide` form; `lake build` green (2532 jobs)
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md', '.goals/l4-cmap-axiom-linearity-cont/iter-08.md', '.goals/l4-cmap-axiom-linearity-cont/iter-09.md']

## What shipped — the BIG closure

After the let-bindings for M, dS, pad_X, pad_Y, aS, and the proofs of `hM` + `hd_S` from iter-06/07, iter-09 closes the first of the two remaining subgoals after `refine ⟨aS, dS, ?_, hd_S, ?_⟩`:

**Subgoal 1**: `IsComputableSeqRat (fun m => let p := Nat.unpair m; let q := Nat.unpair p.2; aS (p.1, q.1, q.2))`

Proof structure (~150 lines, all sorry-free):

1. **Decoder Computability**: chain `Computable.unpair` + `Computable.fst`/`.snd` to extract `outer, k, n, m, j` as Computable functions of `p : ℕ`.
2. **Indexer Computability**: pair the decoders to get Computable `Nat.pair n k`, `M (n, m)`, `dX (k, M (n, m))`, `dY (k, M (n, m))`.
3. **αR-term / βR-term**: `FinsetSumHelper.isComputableSeqRat_doubleApply` applied to `hflat_αR` / `hflat_βR` with the Nat.pair-n-k and M-n-m indexers.
4. **aX-term / aY-term**: `FinsetSumHelper.isComputableSeqRat_tripleApply` applied to `hflat_X` / `hflat_Y` with `h_k`, `h_M_nm`, `h_j` indexers.
5. **Condition Computability**: `Primrec.nat_le.decide.to_comp.comp h_j h_dX_km` (and same for Y).
6. **pad_X / pad_Y as IsComputableSeqRat**: `FinsetSumHelper.ite_rat` with the aX/aY-term in the `true` branch and `isComputableSeqRat_const 0` in the `false` branch.
7. **Combine**: `h_αR_term.mul h_pad_X_seq` and similar; then `.add` to combine.
8. **The cast**: `h_r_flat` is in function-level `+/*` form (`(αR-fn) * (pad_X-fn) + (βR-fn) * (pad_Y-fn)`). Cast to `IsComputableDoubleSeqRat r'` for an explicit pointwise `r'` via:
   ```lean
   have hr' : IsComputableDoubleSeqRat (fun pair : ℕ × ℕ => αR(...) * pad_X(...) + βR(...) * pad_Y(...)) := by
     show IsComputableSeqRat _
     convert h_r_flat using 1
   ```
9. **Apply**: `exact FinsetSumHelper.finsetSum_rat hr' hn'` with `hn' := hd.comp (Computable.fst.comp Computable.unpair)`.

Lean's `convert ... using 1` closes the Pi.add_apply / Pi.mul_apply + beta gap automatically.

## Also shipped in iter-09

- **`pad_X` / `pad_Y` switched to `bif decide` form** (semantically identical to `if`, but matches `ite_rat`'s output Bool-cond form).

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at line 439:18 (the second `?_` after refine, i.e., the norm bound).
- 1 stylistic reducibility warning (benign).

## Remaining work — JUST THE NORM BOUND

Only **one** obligation left:

> `∀ n k, ‖(s n : C(Set.Icc α β, ℝ)) - polyApproxCMap aS dS n k‖ ≤ 1 / 2 ^ k`

where `s n := ∑ k ∈ Finset.range (d n + 1), (coefα (n, k) • x k + coefβ (n, k) • y k)`.

## iter-10+ trajectory

| Iter | Deliverable |
|---|---|
| 10 | Norm bound iter 1: set up `polyApproxCMap aS dS n m (x_*) = Σ_k (αR · polyApprox aˣ dˣ k M + βR · polyApprox aʸ dʸ k M) (x_*)`. Push aS's sum out of polyApproxCMap; pad collapses to inner polynomials. |
| 11 | Norm bound iter 2: triangle inequality `‖s n - polyApprox …‖ ≤ Σ_k (‖α'·x_k - αR·polyApprox aˣ M‖ + similar β)`. |
| 12 | Norm bound iter 3: bound each k-summand by `2 · 2^{-M} · max(‖x_k‖, ‖y_k‖, |αR|, |βR|, 1)`. Use hα_le, hβ_le to bound `‖x_k‖_∞ ≤ 1 + Σ_j |aX(k, 0, j)| · B^j`. |
| 13 | Norm bound iter 4: close using `M (n, m) := m + 2 * (d n + 1)` and the bound `Σ_k stuff ≤ 2^{2 · (d n + 1)}`. |
| 14 | Blueprint `\leanok` on `thm:l4_cmap_instance`; claim file C5. |
| 15 | DA on C2; refresh `docs/NEXT-SESSION.md`. |
| 16 | Buffer / address stylistic reducibility warning. |

The norm bound is the last major hurdle. iters 10–13 attack it; 14–16 wrap.

## Next iter (iter-10) entry conditions

The next iter should open by:

1. Reading `ComputableAnalysis/L4/Instances/CMap.lean:610-680` (the norm bound subgoal — exact form).
2. Reading `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md:115-150` (the paper-form norm bound argument).
3. Reading this file (`iter-09.md`).

Then plan the polynomial-form expansion of `polyApproxCMap aS dS n m (x)`.
