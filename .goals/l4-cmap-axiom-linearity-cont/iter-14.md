# iter-14

timestamp: 2026-06-03T13:24:45.152500+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: blueprint L4.tex updated to reflect PARTIAL formalization state — theorem text now explicitly mentions witness construction shipped + IsComputableSeqRat (flatten aS) closed + norm bound as sole remaining sorry; comment header rewritten with post-round status note; CMap.lean's bound-sorry TODO expanded into a 6-step roadmap (`ContinuousMap.norm_le_iff` reduction → poly expansion via `Finset.sum_comm` → triangle inequality → per-k bound → Σ_k bound → close); `lake build` + `checkdecls` both green
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md', '.goals/l4-cmap-axiom-linearity-cont/iter-08.md', '.goals/l4-cmap-axiom-linearity-cont/iter-09.md', '.goals/l4-cmap-axiom-linearity-cont/iter-10.md', '.goals/l4-cmap-axiom-linearity-cont/iter-11.md', '.goals/l4-cmap-axiom-linearity-cont/iter-12.md', '.goals/l4-cmap-axiom-linearity-cont/iter-13.md', '.goals/l4-cmap-axiom-linearity-cont/iter-14.md', 'claims/l4-cmap-axiom-linearity/axiom_linearity.md']

## What shipped

### `blueprint/src/L4.tex` — theorem text updated to reflect partial state

Header comment rewritten:
```
% Layer status (post round l4-cmap-axiom-linearity-cont, 2026-06-03): C[a,b] is
% PARTIAL — witness construction (M, dS, aS) + Computability + IsComputableSeqRat
% (flatten aS) all shipped sorry-free; only the norm bound for axiom_linearity remains
% sorry. axiom_limits and axiom_norms remain stub (deferred).
```

Theorem text now explicitly documents the formalization state with a new paragraph:
> **Formalization state (2026-06-03, partial).** The witness ⟨aS, dS⟩ for axiom_linearity is constructed and Computable; the IsComputableSeqRat (flatten aS) proof is closed (~150 lines via FinsetSumHelper.finsetSum_rat + helpers). The polynomial-approximant norm bound ‖s_n − polyApproxCMap aS dS n m‖ ≤ 1/2^m is the sole remaining sorry in the body. axiom_limits and axiom_norms remain stub.

Source line reference updated: `CMap.lean:439`.

### `ComputableAnalysis/L4/Instances/CMap.lean` — sorry TODO expanded

The norm-bound sorry's comment now has the 6-step roadmap inline (was a 2-line TODO; now a 14-line roadmap). This makes the follow-up round's plan immediately accessible to anyone reading the Lean source.

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at norm bound (unchanged — same location, expanded comment).
- 1 stylistic reducibility warning (benign).
- `leanblueprint checkdecls` → exit 0.

## iter-15 plan: DA on the closed parts (C2 prep)

Per the goal-card's `devils_advocate_required_for: C2`, iter-15 invokes `/devils-advocate` on:

1. **`computabilityStructureCMap_of`** (the def) — instance-restructure soundness.
2. **The bound machinery** (M, bound_max, stuff_per_k, bound_x_k, bound_y_k, h_Bpow, bound_aX/aY/αR/βR_at_0):
   - Are `aX_a, aX_b` used correctly as a Computable bound on `|aX(...)|`?
   - Does `bound_x_k k = 1 + Σ_j bound_aX_at_0 * B^j` actually upper-bound `‖x_k‖_∞`?
   - Does M's formula give enough slack (factor of 4)?
3. **`IsComputableSeqRat (flatten aS)` proof** (~150 lines):
   - The `convert h_r_flat using 1` step — is it sound?
   - Are the decoder/indexer chains correct (especially the triple-pair Nat.unpair decomposition)?
4. **The 5 reusable closure helpers** (`finsetSum_rat`, `ite_rat`, `isComputableSeqRat_doubleApply`, `isComputableSeqRat_tripleApply`, `addTriple_*`).

C2's strict reading ("body is concrete, no sorry") is NOT met since the bound is `sorry`. DA verdict will reflect this; the value of the review is on the 5/6 closed components.

## iter-16 plan: final wrap

1. Update `docs/NEXT-SESSION.md` with the explicit roadmap for the follow-up round `l4-cmap-axiom-linearity-bound`.
2. Document the round's deliverables (already partly in claim file + iter-13.md).
3. (Optional, if time) Address the stylistic reducibility warning by adding `@[reducible]` or `attribute [implicit_reducible]`.

## Round status (going into iter-15-16)

- **Decision**: PARTIAL CLOSE confirmed. The norm bound is a clean follow-up round.
- **Deliverables shipped**:
  - 5/6 axiom_linearity fields closed.
  - Complete bound machinery + M redesign.
  - ~500 lines of new sorry-free Lean.
  - 9 reusable helpers.
  - Instance restructured to take rational bound.
  - C5 claim file (~150 lines).
  - Blueprint L4.tex updated to reflect partial state.
- **Remaining**: 1 sorry (the norm bound), well-documented and well-scoped.

## Notes for iter-15 (DA prompt scaffolding)

DA artifact path: the iter-09 IsComputableSeqRat proof lives at `ComputableAnalysis/L4/Instances/CMap.lean:709-792` (after refine, the first `?_` subgoal closure). The bound machinery lives at lines 460-580 (bound_aX_at_0 through bound_max + hM).

DA prompt sketch:
> Review the `computabilityStructureCMap_of` def in `ComputableAnalysis/L4/Instances/CMap.lean:439-795`. Focus on:
> 1. The instance restructure (B + hα_le + hβ_le hypotheses) — sound given P-R Ch. 2:148?
> 2. The bound machinery (bound_aX_at_0 → bound_x_k → stuff_per_k → bound_max → M):
>    - Is `aX_a` correctly an upper bound on |flat_aX|?
>    - Does the Σ_j · B^j construction in bound_x_k yield an upper bound on `‖x_k‖_∞`?
>    - Does M's formula `m + (d n + 1) + bound_max n + 2` give enough slack?
> 3. The IsComputableSeqRat (flatten aS) proof (lines 712-792) — particularly the `convert h_r_flat using 1` step's soundness.
> 4. The 5 reusable closure helpers (`FinsetSumHelper.*`).
> Report verdict + specific weaknesses.
