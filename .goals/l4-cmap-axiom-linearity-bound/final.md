---
slug: l4-cmap-axiom-linearity-bound
ended: 2026-06-03T21:30:00Z
iterations: 9
outcome: success
---

# Final summary for goal: Close the L4 C[a,b] axiom_linearity norm bound (the sole remaining sorry in A1)

## Criteria status
- [x] C1: `lake build` green; `axiom_linearity` body sorry-free; exactly 1 residual
  `declaration uses sorry` warning (A2/A3 only); machine-check returns exactly **2**
  standalone sorries (down from 3). The 2 remaining are `CMap.lean:1260` (axiom_limits) and
  `CMap.lean:1271` (axiom_norms).
- [x] C2: norm bound `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m` proved concretely.
  **[DA-required → `verdict: passes`]** — `.goals/.../reviews/C2.md`.
- [x] C3: `axiom_limits` (A2) + `axiom_norms` (A3) remain `sorry` (deferred, in scope).
- [x] C4: blueprint `thm:l4_cmap_instance` prose updated; node stays white-bordered (no
  `\leanok`, since the instance still carries `sorryAx` from A2/A3); `checkdecls` exit 0; no
  new `/verify` violations.
- [x] C5: `claims/l4-cmap-axiom-linearity/axiom_linearity.md` rewritten with the bound's
  actual proof structure + DA verdict; `da_status: done`.

## Artifacts produced
- `ComputableAnalysis/L4/Instances/CMap.lean`: norm-bound proof (~lines 988–1249) +
  supporting helpers (~383–595, e.g. `perk_bound`, `closeout_nat`, `abs_cast_neg_one_pow_div_le`,
  `polyApproxCMap_conv_eval`, `le_natRec_max`); `axiom_linearity` now fully sorry-free
  (+444 lines this round).
- `claims/l4-cmap-axiom-linearity/axiom_linearity.md`: norm-bound section rewritten with the
  actual proof structure; DA verdict recorded; `da_status: done`.
- `blueprint/src/L4.tex`: prose for `thm:l4_cmap_instance` updated; node white-bordered.
- `.goals/l4-cmap-axiom-linearity-bound/reviews/C2.md`: DA verdict `passes` — re-run
  independently post-compaction in canonical format (supersedes the first-pass prose verdict).
- `thinking/l4-cmap-axiom-linearity-bound/iter-02-plan.md`: strategy doc.

## Devil's-advocate verdicts
| Artifact | Criterion | Verdict | Key note |
|---|---|---|---|
| `axiom_linearity` norm bound (`CMap.lean:638–1249`) | C2 | **passes** | Sorry-free faithful proof of P-R Axiom 1; soundness verified via standalone-theorem extraction → axioms = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. The re-run caught + corrected a projection-artifact flaw in the first-pass review's method (see Key findings). |

## Key findings
- **P-R Axiom 1 (Linear Forms) is now fully proved for the first concrete
  `ComputabilityStructure` instance on an infinite-dimensional space** (`C([α,β], ℝ)`) — the
  keystone "first instance" milestone for L4.
- The proof needs an explicit rational bound `B` with `|α|,|β| ≤ B` — a documented scoping
  restriction relative to P-R's "recursive reals a,b" (chapt2:128); downstream callers must
  supply `B`. Not a soundness defect.
- **Auditing one field of a multi-field instance for `sorryAx` must use standalone-theorem
  extraction, NOT `#print axioms` on a projected field** — the projection false-positives
  `sorryAx` from sibling fields regardless of the inspected field's purity. Harvested to
  `docs/PITFALLS.md §7`.
- **The DA verdict token is exactly `verdict: passes`** (not "sound") — a prose verdict trips
  the Stop hook's `unauthorized-check` HALT; the gate must not be cleared by hand-editing the
  token. Harvested to `docs/PITFALLS.md §8`.
- `closeout_nat` is over-provisioned (the `+2` slack is never strictly needed) and
  `perk_bound` is tight at the boundary — both numerically stress-tested by the DA agent.

## Open questions
- `axiom_limits` (A2, closure under effective limits) — still `sorry` (`CMap.lean:1260`);
  the natural next field to discharge for this instance.
- `axiom_norms` (A3, the `(x_n) ↦ (‖x_n‖)` map into L1's `IsComputableSeqReal`) — still
  `sorry` (`CMap.lean:1271`).
- Until A2/A3 close, the instance carries `sorryAx` and the blueprint node correctly stays
  white-bordered. Closing both turns the node green.
- Generalizing away the explicit-`B` parameterization to genuine recursive reals `a,b`.

## Next-step recommendations
- Open a follow-up round for **A2 (`axiom_limits`)** on the `C[a,b]` instance — the natural
  continuation; A2 + A3 together turn the blueprint node green.
- Or pause L4 and pursue `docs/NEXT-SESSION.md` Action 3 items (L1 `finsetSum_rat`/`ite_rat`
  lift, L3 stability theorem).
- Consider a Zulip `#Mathlib4` post: a first concrete infinite-dim `ComputabilityStructure`
  instance with Axiom 1 proved is a milestone worth community feedback (CLAUDE.md engagement
  guidance) — Brattka/Pauly/Schröder on the P-R-vs-represented-spaces tension.
