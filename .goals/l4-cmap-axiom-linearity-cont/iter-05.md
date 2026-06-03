# iter-05

timestamp: 2026-06-03T12:08:31.760923+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: instance restructure shipped — `instComputabilityStructureCMap : ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` → `computabilityStructureCMap_of (B : ℕ) (hα_le : |α| ≤ B) (hβ_le : |β| ≤ B)` (def, takes rational bound on |α|,|β|, matching P-R Ch. 2:148); A1 body destructured (intro x y coefα coefβ d hx hy hcoefα hcoefβ hd + 4 obtains); blueprint references updated; `lake build` + `checkdecls` both green
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md']

## What shipped

1. **`computabilityStructureCMap_of`** (new) — replaces `instComputabilityStructureCMap` (old). Signature:
   ```lean
   noncomputable def computabilityStructureCMap_of
       (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ)) :
       ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))
   ```
2. **A1 body destructured** — `intro x y coefα coefβ d hx hy hcoefα hcoefβ hd` + 4 `obtain` calls extracting:
   - `aX, dX, hflat_X, hd_X, hbnd_X` from `hx : IsComputableSeqCMap x`
   - `aY, dY, hflat_Y, hd_Y, hbnd_Y` from `hy`
   - `αR, hflat_αR, hbnd_αR` from `hcoefα : IsComputableSeqReal (fun n => coefα (Nat.unpair n))`
   - `βR, hflat_βR, hbnd_βR` from `hcoefβ`
3. **Smoke check updated** — `#check @instComputabilityStructureCMap` → `#check @computabilityStructureCMap_of`.
4. **Blueprint references updated** — `blueprint/lean_decls` and `blueprint/src/L4.tex` both point at `computabilityStructureCMap_of`. Theorem-statement text updated to mention the rational-bound parameter.

## Build status

- `lake build` → 2532 jobs successful.
- Single sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:404:18` (the A1 body, post-destructure).
- `leanblueprint checkdecls` → exit 0.
- One stylistic warning at line 385: *"Definition `ComputableAnalysis.L4.computabilityStructureCMap_of` of class type must be marked with `@[reducible]` or `@[implicit_reducible]`"*. **Benign** — informational, doesn't block build. To address in iter-08 cleanup if convenient.

## API change notes

- **Old**: `instance instComputabilityStructureCMap : ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` (`α β : ℝ` from section variable). Automatic typeclass resolution; no hypothesis. The norm-bound proof of A1 was provably unrealizable for arbitrary α, β.
- **New**: `def computabilityStructureCMap_of (B : ℕ) (hα_le hβ_le)` — explicit ℕ-rational bound on `max(|α|, |β|)`. Manual construction; downstream callers must provide B. **Currently no downstream consumers** (L5 not built), so the change is safe.

This aligns the L4 instance with P-R Ch. 2:148's restriction to "recursive reals a, b". The previous unconditional instance was an over-generalization noted in the file's pre-existing A3 TODO comment (line 391-394 of the old file, now shifted).

## Locked iter-06 → iter-08 trajectory

| Iter | Deliverable | Sorry status |
|---|---|---|
| 06 | Define M : ℕ × ℕ → ℕ (Computable precision pad using B, d, αR, βR data); dS : ℕ × ℕ → ℕ (Computable Finset.range-max bound); aS : ℕ × ℕ × ℕ → ℚ (the padcoeff-summed polynomial coefficients). Prove `IsComputableSeqRat (flatten aS)` via `_finsetSum_rat` + `ite_rat` + L1 `IsComputableSeqRat.{add, mul, comp}`. SORRY norm bound only. | Net sorries: 1 (the bound). |
| 07 | Norm bound proof: triangle inequality + precision-pad arithmetic. Uses `hα_le`, `hβ_le` to bound `‖x_k‖_∞`, `‖y_k‖_∞`. | Net sorries: 0 if successful; partial if not. |
| 08 | Blueprint `\leanok` toggle for `thm:l4_cmap_instance`; claim file C5 (`claims/l4-cmap-axiom-linearity/axiom_linearity.md`); DA on C2; refresh `docs/NEXT-SESSION.md`. Address stylistic `@[reducible]` warning if convenient. | Net sorries: 0 if 07 closed. |

## Risks for iter-06

- **Computability of M**: depends on bound computations Σ_j |aX(k, M', j)| · B^j (a finite rational sum). Computability needs to be established carefully — likely needs a Computable.list_foldr-style pattern or another nat_rec.
- **Computability of dS**: `Finset.range (d n + 1).sup (fun k => max (dX (k, M)) (dY (k, M)))`. Mathlib's `Finset.sup` might not be directly Computable for `Finset.range`; may need to inline as a `Nat.rec` similar to `_finsetSum_rat`.
- **`Computable.list_max`-style closure**: may not exist directly; can be built ad hoc via `Computable.nat_rec` (same pattern as iter-03's `_finsetSum_rat`).

## Next iter (iter-06) entry conditions

The next iter should open by:

1. Reading `ComputableAnalysis/L4/Instances/CMap.lean:404-410` (the destructured A1 body, where we left off).
2. Re-reading `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md:86-114` (the witness construction details).
3. Reading this file (`iter-05.md`) for the locked iter-06+ plan.

Then construct M, dS, aS per the strategy doc. Single-file check first.
