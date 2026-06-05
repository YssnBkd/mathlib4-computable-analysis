---
slug: l4-cmap-axiom3-norm-resig
ended: 2026-06-05T12:30:00Z
iterations: 10
outcome: success
---

# Final summary for goal: Close A3 (sup-norm computability) for `C[α, β]` by signature refit, with the missing P-R Prop 1 lemma lifted as a reusable L1 building block.

## Criteria status

- [x] **C1: Prop 1 lemma stated.** `isComputableSeqReal_of_effectiveConvergence` lives in `ComputableAnalysis/L1/ComputableSeqReal.lean` §2.5 with signature matching P-R Ch. 0 Prop 1. *DA verdict: sound — see `reviews/C1.md`.* Met at iter-01.
- [x] **C2: Prop 1 lemma proved sorry-free.** `#print axioms isComputableSeqReal_of_effectiveConvergence` returns `[propext, Classical.choice, Quot.sound]` (no `sorryAx`). Verified iter-01.
- [x] **C3: A3 signature refit.** `isComputableSeqCMap_norm` takes `(B) (hα_le) (hβ_le) (hα_c : IsComputableReal α) (hβ_c : IsComputableReal β) (hαβ : α ≤ β)`. The `hαβ` addition (iter-09) is mathematically essential — without it, an empty `Set.Icc α β` admits adversarial coefficients defeating the bound.
- [x] **C4: A3 body sorry-free.** `#print axioms isComputableSeqCMap_norm` returns `[propext, Classical.choice, Quot.sound]`. Met iter-10 via the three-error decomposition (Stage 3 of the round's Phase 3).
- [x] **C5: Error decomposition justified.** Three error sources named and explicitly bounded: `h_a` (polynomial-approximation), `h_b1` (clamp), `h_b2` (cover). DA verdict `passes`. See `reviews/C5.md`.
- [x] **C6: Instance refit.** `computabilityStructureCMap_of` takes 6 hypotheses (B, hα_le, hβ_le, hα_c, hβ_c, hαβ); `#print axioms` clean. Iter-09 +10.
- [x] **C7: Repo-wide green.** `lake build` 2532 jobs, 0 errors, 0 sorry-warnings. `grep -rn sorry ComputableAnalysis/` shows only docstring-quoted mentions.
- [x] **C8: Blueprint promoted.** `lem:l4_cmap_axiom3` and `thm:l4_cmap_instance` carry `\leanok` on both statement and proof. `lem:l1_isComputableSeqReal_of_effectiveConvergence` added. `leanblueprint checkdecls` and `leanblueprint web` both exit 0.
- [x] **C9: Docs updated.** `NEXT-SESSION.md` rewritten with the closed-A3 state. `PITFALLS.md` extended with §10-§14 (Mathlib4 naming drifts + elaboration-order gotchas). `LEAN-IDIOMS.md` extended with positive recipes for clamp, cover, cast-mismatch, sup'-iff, heartbeat-heavy theorems.

## Artifacts produced

- **`ComputableAnalysis/L1/ComputableSeqReal.lean`**: added `isComputableSeqReal_of_effectiveConvergence` (~120 lines, sorry-free). P-R Ch. 0 Prop 1.
- **`ComputableAnalysis/L4/Instances/CMap.lean`**: A3 (`isComputableSeqCMap_norm`) and supporting helpers `polyApproxCMap_lipschitz` (Phase 3.2) + `polyEval_lipschitz_real` (iter-09) + `FinsetMaxHelper.{maxTriple, finsetMax_rat}` (Phase 3.1) + `PolyEvalHelper.{gridQ, polyVal}_isComputableSeqRat` + the A3 body's ~600-line proof.
- **`blueprint/src/L1.tex`**: `lem:l1_isComputableSeqReal_of_effectiveConvergence` added with `\leanok` on statement and proof.
- **`blueprint/src/L4.tex`**: `lem:l4_cmap_axiom3` promoted with `\leanok` and an expanded proof block walking through the three-error decomposition; `thm:l4_cmap_instance` upgraded with `\leanok`.
- **`blueprint/lean_decls`**: Prop 1 added to the registry.
- **`current-goal.md`**: all 9 criteria checked.
- **`docs/NEXT-SESSION.md`**: rewritten to point at three next-round options.
- **`docs/PITFALLS.md` §10–§14**: `le_or_lt → le_or_gt`; `Finset.le_sup'_iff.mpr` term-mode failure; `set_option ... in` after docstring; `linarith` atom-blindness on `c/2^N` vs `1/2^N`; `Nat.cast 0` not auto-reducing in `xQ 0`.
- **`docs/LEAN-IDIOMS.md`**: cast-normalization at call-site; `rw [le_sup'_iff]` tactic-form; `set_option in` before docstring; midpoint case-split; `Set.projIcc` three-case clamp; `Nat.floor` grid cover.
- **No** `claims/`, `proofs/`, or `intuition/` satellites — this round was formalization-mode, where the type-checker is the verifier.

## Devil's-advocate verdicts

| Criterion | Artifact | Verdict | Key finding |
|---|---|---|---|
| C1 | `isComputableSeqReal_of_effectiveConvergence` (signature + proof outline) | sound (reviews/C1.md) | P-R Prop 1 specialization to rational inputs is the right move; diagonalization step `r'(n,k) := r(n, e(n,k))` is faithful. |
| C5 | A3 three-error decomposition (CMap.lean lines 2044–2996) | passes (reviews/C5.md) | All edge cases verified: B=0, α=β, Lip_nat=0, midpoint ambiguity, J=0, J=kg, kg=1. Hypotheses hαβ, hα_c, hβ_c all load-bearing. Lean's grid range {0..kg} is strictly broader than P-R's {1..k}; preserves soundness. Lipschitz-of-polynomial-approximant substitutes for P-R's modulus-of-uniform-continuity-of-f_n; equivalent route. Minor recommendation: `m_mod = +3` is unnecessarily looser than needed (+2 would suffice) but not wrong. |

## Key findings

- **The signature refit was essential, not cosmetic.** The iter-04 obstruction analysis (counterexample with undecidable Σ⁰₁ `P` making `Set.Icc α β` empty vs. nonempty) is what forced `(hα_c) (hβ_c)`. The iter-09 `hαβ` addition is a separate but equally necessary refit (adversarial-coefficient case under empty interval). Both are documented in the A3 docstring.
- **The polynomial-Lipschitz route is cleaner than P-R's modulus-of-uniform-continuity route.** Both reach the same `|s_{nk} − ‖f_n‖| ≤ 2⁻ᴺ` conclusion. P-R uses the function's own modulus of uniform continuity; we derive a constant from the *coefficients* of the polynomial approximant. The constructive flavor of the latter is closer to Mathlib idiom and avoids needing a separate uniform-continuity-modulus calculation.
- **The grid construction case-splits on `α' < β'` vs `α' ≥ β'`.** The degenerate case `α' ≥ β'` forces `β − α ≤ 2/2^mm` (provably), so a midpoint case-split keeps the bound at `2/2^mm` instead of the worst-case `3/2^mm`. This was discovered during iter-10 build-debug — without it, the modulus would need to grow further.
- **Heartbeats: 600-line theorem bodies need ~1.6M heartbeats.** The default 200k is exhausted by cumulative `whnf` during elaboration. `set_option maxHeartbeats N in` must come *before* the docstring (not after), or the parser errors with `unexpected token 'set_option'; expected 'lemma'`.
- **The `IsComputableSeqRat` destructure-rebuild idiom** (from `feedback_round_pragmatism`) generalizes: every L4 instance that consumes an `IsComputableSeqRat` witness will need it, because `IsComputableSeqRat` unfolds to `Exists` and dot-notation is parser-broken.
- **Mathlib4 naming drift is a recurring tax.** This round added five renames to the catalog: `le_or_lt → le_or_gt`, `Finset.le_sup'_iff` term-mode opacity, `div_le_div_iff → div_le_div_iff₀`, etc. The `grep -rn` reflexive check in CLAUDE.md is now well-earned.

## Open questions

- **Should we tighten `m_mod` from `+3` to `+2`?** DA flagged the slack as unnecessary. The tighter `+2` would save a factor of 2 in elaboration-time heartbeat cost. Not worth a follow-up iter on its own; could be folded into the upstream-PR's polish pass.
- **Is `polyEval_lipschitz_real` ready for upstream review?** DA black-boxed it. If pitching to Mathlib4 as a standalone lemma, it should be re-reviewed under the same adversarial lens.
- **Should A1/A2/A3 be packaged for Mathlib4 review?** All three are sorry-free; the structure-def `computabilityStructureCMap_of` is sorry-free. The natural next move is a Zulip pitch on `#new contributors` or `#Mathlib4`. **The user posts**, not Claude.
- **Lᵖ instance (L4)** is the natural next L4 target after C[a,b]. Significantly harder than the polynomial-approximation route — Lᵖ uses step-function approximants and `MeasureTheory.LpSpace` bridge.
- **L2 (Grzegorczyk-Lacombe) layer** is the natural next layer-completion target. Defines `IsGLComputable : C(ℝ, ℝ) → Prop` and its closure operations; unlocks integration/differentiation in P-R Ch. 1.

## Next-step recommendations

1. **Zulip outreach** (highest immediate ROI; ~30 min user time). With L0 + L1 + L3 + L4-C[a,b] sorry-free, the project is at a credible inflection. Draft a 3-paragraph note: (1) pitch, (2) progress + blueprint URL, (3) ask for architecture feedback on predicate-first vs represented-spaces. The user posts.
2. **`/goal` round on L2** (`l2-grzegorczyk-lacombe`, ~10–20 iters). Define `IsGLComputable` and its closure operations. Hook to L4 via constant-sequence injection. Unlocks P-R Ch. 1 (integration, differentiation, analytic functions).
3. **`/goal` round on L4 Lᵖ** (`l4-lp-instance`, ~15–25 iters). Harder than C[a,b] — Weierstrass-style polynomial approximation doesn't carry over; needs step-function approximants and the MeasureTheory bridge. Recommend Option B before this.
4. **Polish pass on `polyEval_lipschitz_real`** (small) — tighten the bound's hypothesis shape so future consumers don't need the cast-normalize-at-call-site idiom. Can be folded into upstream PR prep.
