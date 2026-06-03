---
slug: l4-cmap-axiom-linearity-cont
iter: 0
timestamp: 2026-06-03T11:15:29Z
mode: proof-attempt
files_changed: []
unmet: [C1, C2, C3, C4, C5]
note: goal started
---

# iter-00 — goal started

## Env preflight (Action 1 of `docs/NEXT-SESSION.md`)

All four checks pass; env matches the snapshot recorded by the prior round (`l1-arithmetic-closure-and-real`):

- `lake build` → `Build completed successfully (2532 jobs)`; single sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:104:23` (the `axiom_linearity := sorry` body inside `instComputabilityStructureCMap`; sorry-line attributes to the instance decl).
- `leanblueprint web` → built `sect0001.html` … `sect0006.html` with no plasTeX errors.
- `leanblueprint checkdecls` → exit 0, no unresolved decls.
- `gh run list --repo YssnBkd/mathlib4-computable-analysis --limit 3` → most recent (for the `chore(goal): close l1-arithmetic-closure-and-real round` commit) is `in_progress` (4m26s elapsed at goal-start); two preceding runs are `completed success`.

## Prior-round context preserved (must re-read next iter)

- `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` — load-bearing polynomial-approximation strategy with verbatim P-R citations. Authored by the budget-exhausted `l4-cmap-axiom-linearity` round (5/6 iters); the strategy itself was sound, only the L1 toolkit was missing at the time.
- `.goals/l4-cmap-axiom-linearity/final.md` — full final report for the prior round.
- `ComputableAnalysis/L1/ComputableSeqReal.lean` §4 — `IsComputableSeqRat.{add,mul,comp}` available unqualified inside CMap.lean (already `open ComputableAnalysis.L1`).

## Next iter plan

1. Re-read `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` (full).
2. Re-read `ComputableAnalysis/L4/Instances/CMap.lean` lines 1–160 to confirm the current `polyApproxCMap` / `IsComputableSeqCMap` / `instComputabilityStructureCMap` shape and the exact statement of `axiom_linearity` in the L3 typeclass.
3. Confirm the precision-pad argument and the `IsComputableSeqRat.{add,mul,comp}` reuse plan still apply.
4. Draft the `axiom_linearity` body in CMap.lean and run a single-file check (`lake env lean ComputableAnalysis/L4/Instances/CMap.lean`) before full `lake build`.
