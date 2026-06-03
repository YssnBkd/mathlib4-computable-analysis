---
timestamp: 2026-06-03T15:56:45Z
iter: 0
mode: proof-attempt
unmet: [C1, C2, C3, C4, C5]
files_changed: []
note: goal started
---

# iter-00 — goal started

Round `l4-cmap-axiom-linearity-bound` opened (Action 2 of `docs/NEXT-SESSION.md`).

## Env preflight (Action 1, confirmed before round open)
- `lake build`: 2532 jobs, exit 0, **1** `declaration uses sorry` warning at
  `ComputableAnalysis/L4/Instances/CMap.lean:439:31` (decl-level; covers all 3 sorry
  bodies — axiom_linearity@809, axiom_limits@820, axiom_norms@831). Matches expected.

## Target
Close the `axiom_linearity` norm bound at `CMap.lean:809`:
`∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m`. ~200-300 lines.

## Criteria corrections made at setup (vs NEXT-SESSION.md draft)
- **C1**: NEXT-SESSION said "0 sorry-warnings" — impossible while A2/A3 stay `sorry`
  in the same decl (Lean emits one decl-level warning). Restated as: axiom_linearity
  body sorry-free + exactly 1 residual warning from A2/A3; grep returns 2 sorry lines.
- **C4**: NEXT-SESSION said toggle `thm:l4_cmap_instance` to `\leanok` — would violate
  the sorry-policy (`#print axioms` still shows `sorryAx` from A2/A3) and `verify` would
  flag it. Restated (per user choice "Prose-only"): update prose, keep node
  white-bordered, no `\leanok`.
- Budget: user override to 50 iters / 3600 min (NEXT-SESSION proposed 10/240).

## DA-verified bound roadmap (from claims/.../axiom_linearity.md:94-106)
1. ContinuousMap-norm → pointwise (`ContinuousMap.norm_le`, Compact.lean:204; no Nonempty).
2. Polynomial-expansion identity via `Finset.sum_comm` (j-k swap) + padcoeff identity.
3. Pointwise triangle inequality on `Σ_k (coefα·x_k - αR·polyApprox aX dX k M)`.
4. Per-k summand bound via `hbnd_αR`, `hbnd_X`, `bound_x_k`, `bound_αR_at_0`, `hα_le`, `hβ_le`.
5. `Σ_k` bound by `(d n + 1) · bound_max(n)` (`Finset.sum_le_sum` + `Finset.sum_const_nat`).
6. Close: `2^M ≥ 4 · (d n + 1) · bound_max(n)` by M's formula.

## DA risk profile (high→low, from .goals/l4-cmap-axiom-linearity-cont/reviews/C2.md)
1. `Finset.sum_comm` for the j-k swap (highest syntactic friction).
2. `ContinuousMap.norm_le` application.
3. Per-k summand bound chasing through deeply nested `let`s (name resolution).
4. Σ_k bound.
5. Close-out arithmetic (`2^{-M}·2·(d n+1)·bound_max(n) ≤ 1/2^m`).
