# iter-04

timestamp: 2026-06-03T11:54:47.761610+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: shipped `FinsetSumHelper.ite_rat` (closure of `IsComputableSeqRat` under Computable-Bool conditional, ~25 lines, sorry-free); identified the rational-bound-on-|α|,|β| obstruction blocking A1's norm bound for arbitrary α β : ℝ; planned iter-05 instance restructure to take `(B : ℕ) (hαβ : |α| + |β| ≤ B)`
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md']

## What shipped

| Decl | Status | Lines | Use |
|---|---|---|---|
| `FinsetSumHelper.ite_rat` | sorry-free | ~25 | Closure of `IsComputableSeqRat` under `Computable`-Bool conditional with two `IsComputableSeqRat` branches. Needed for A1's `padcoeff` (zeroes polynomial coefficients past per-k degree bound `dˣ(k, M)`). |

`lake build`: green, single sorry-warning still at line 389:23 (the A1 body itself, unchanged from iter-03).

## Obstruction discovered: |α|, |β| bound for the A1 norm-bound proof

Re-reading the iter-03 strategy doc + L4 file's existing A2/A3 TODO comments, the deep issue is exposed:

**The polynomial-form A1 proof needs a Computable bound on `max(|α|, |β|)`.** Specifically, the precision pad `M(n, m)` must satisfy `2^{-M} · (d n + 1) · max(‖x_k‖_∞ + ‖y_k‖_∞ + |αRat| + |βRat|) ≤ 2^{-m}`. The factor `‖x_k‖_∞` is bounded via `‖x_k - polyApprox aˣ dˣ k 0‖_∞ + ‖polyApprox aˣ dˣ k 0‖_∞ ≤ 1 + ‖polyApprox‖_∞`, and `‖polyApprox aˣ dˣ k 0‖_∞ = sup_{x_* ∈ [α, β]} |Σ_j aˣ(k, 0, j) · x_*^j|` requires a bound on `|x_*| ≤ max(|α|, |β|)`.

For **arbitrary** α, β : ℝ (the current instance signature), no rational bound on `max(|α|, |β|)` is available, so `M(n, m)` cannot be a Computable ℕ function. **A1's polynomial-form bound is genuinely unprovable in the current instance signature.**

This matches P-R's actual treatment: Ch. 2 §2 (page 148) explicitly restricts to "recursive reals a, b" — i.e., to a computable interval. The current `noncomputable instance instComputabilityStructureCMap` is broader than P-R intends, and pays the price in unprovability.

The existing file's A3 TODO comment (line 391-394) already half-acknowledges this: *"α, β are recursive reals — actually here arbitrary reals; the proof uses approximations to rationals"*.

## Proposed iter-05 restructure

Two paths considered:

**Path A** — Convert the instance to a conditional `def` taking `(B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ))`:

```lean
noncomputable def computabilityStructureCMap_of
    (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ)) :
    ComputabilityStructure ℝ (C(Set.Icc α β, ℝ)) := { ... }
```

- Pros: minimal, transparent; B as ℕ is Computable.
- Cons: loses `instance`-resolution; downstream callers must construct B explicitly. (Currently no downstream consumers, so safe.)

**Path B** — Restrict to `IsComputableReal α` and `IsComputableReal β` (the actual P-R notion):

```lean
noncomputable def computabilityStructureCMap_of
    (hα : IsComputableReal α) (hβ : IsComputableReal β) :
    ComputabilityStructure ℝ (C(Set.Icc α β, ℝ)) := { ... }
```

- Pros: matches P-R semantics exactly.
- Cons: extracting a Computable B from `IsComputableReal α` requires unfolding `IsComputableSeqReal (fun _ => α)` and computing a bound from the rational approximant — more layered.

**Recommendation: Path A for iter-05.** Direct, minimal, works for the A1 proof.

## Locked iter-05 → iter-08 trajectory

| Iter | Deliverable | Sorry status |
|---|---|---|
| 05 | Restructure instance to conditional def w/ `(B : ℕ) (hα_le) (hβ_le)`. Begin A1 body: destructure 5 hypotheses, define M, dˢ, aˢ (the latter using `_ite_rat` + `_finsetSum_rat`), prove Computability of aˢ flatten. SORRY norm bound only. | Net sorries: 1 (the bound). |
| 06 | Norm bound iter 1: triangle inequality setup, sum-by-sum decomposition. May need further auxiliary lemmas. | Net sorries: 1. |
| 07 | Norm bound iter 2: precision-pad arithmetic close-out. | Net sorries: 0 if successful; else partial. |
| 08 | Blueprint `\leanok` on `lem:l4_cmap_axiom_linearity`; claim file C5; DA on C2; refresh `docs/NEXT-SESSION.md`. | Net sorries: 0 if 07 closed, else partial round. |

## Realistic outcome probabilities (DA-style)

- **Full close (C1–C5 all met)**: ~40%. The norm-bound proof is intricate; even with the rational bound on α, β, the precision-pad arithmetic and sum manipulations are bookkeeping-heavy.
- **Partial close (C1 met except A1 bound is sorry'd, C4–C5 partial)**: ~40%. The witness construction lands cleanly; the bound remains.
- **Round budget-exhausted with A1 still entirely sorry**: ~20%. Instance restructure proves trickier than expected; the witness construction has unanticipated Lean-syntax frictions.

In all cases, the round delivers genuine value: `_finsetSum_rat` (iter-03) and `_ite_rat` (iter-04) are independently useful and lifted to L1 in a follow-up round; the instance restructure (iter-05) clarifies the design intent regardless of A1's proof status.

## What to NOT do in iter-05

- **Do not** add a second instance/def variant; replace the existing unconditional instance with the conditional def. There's no downstream consumer of the unconditional form to preserve.
- **Do not** try to extract B from `IsComputableSeqReal` machinery — pass it as explicit ℕ. Cleaner Lean, faster proof.
- **Do not** attempt the norm bound in iter-05; the witness construction is already a full iter's worth.
- **Do not** modify A2 / A3 stubs in this round; they remain `sorry` (allowed per C3).

## Next iter (iter-05) entry conditions

The next iter should open by:

1. Reading `ComputableAnalysis/L4/Instances/CMap.lean:355-420` (the existing instance) to confirm the field shape.
2. Reading `ComputableAnalysis/L3/ComputabilityStructure.lean:120-127` (A1's exact statement) once more to lock the destructure pattern.
3. Reading this file (`iter-04.md`) for the locked trajectory + obstruction analysis.

Then implement per the iter-05 row above. Use Path A (explicit `B : ℕ` hypothesis).
