---
slug: l4-cmap-axiom-linearity-cont
ended: 2026-06-03T13:55:00Z
iterations: 16
outcome: partial
---

# Final summary for goal: Close L4 `axiom_linearity` (P-R Ch. 2 A1, polynomial form) for the `C(Set.Icc α β, ℝ)` instance

## Criteria status

- [ ] **C1**: `lake build` green; CMap.lean has 0 sorry-warnings attributable to `axiom_linearity` — **NOT MET**. 1 sorry remains at line 439:31 (the norm bound `‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m`). All other components of axiom_linearity closed sorry-free.
- [ ] **C2**: `axiom_linearity` body concrete (no sorry); witness construction faithful to `iter-03-strategy.md` — **PARTIAL**. The witness construction IS shipped + verified faithful by DA review (`reviews/C2.md`); the body is NOT fully concrete due to the bound sorry. DA verdict: `passes-partial`.
- [x] **C3**: A2 and A3 remain sorry (deferred) — **MET**. axiom_limits and axiom_norms unchanged at sorry per criterion's allowed wording.
- [ ] **C4**: blueprint label `thm:l4_cmap_instance` toggled to `\leanok` — **NOT MET**. Lean target has sorry; `\leanok` would violate CLAUDE.md's sorry policy.
- [x] **C5**: claim file written per `claims/TEMPLATE.md` — **MET**. `claims/l4-cmap-axiom-linearity/axiom_linearity.md` (~150 lines) shipped with full design rationale + DA-verified roadmap.

**Scorecard: 2/5 met strictly, 1/5 partial. Round outcome: `partial`.**

## Artifacts produced

### Lean code (sorry-free unless noted) in `ComputableAnalysis/L4/Instances/CMap.lean`

- **Instance restructure** (iter-05): `noncomputable instance instComputabilityStructureCMap` → `@[reducible] noncomputable def computabilityStructureCMap_of (B : ℕ) (hα_le : |α| ≤ B) (hβ_le : |β| ≤ B)`. Matches P-R Ch. 2:128's restriction to recursive reals.
- **`FinsetSumHelper` namespace** (iters 03, 04, 08): 9 decls, all sorry-free.
  - `addTriple`, `addTriple_b_ne_zero`, `tripleToRat`, `addTriple_correct`, `addTriple_computable` (~150 lines): triple-witness ℕ-level add formula matching L1's `IsComputableSeqRat.add`.
  - `finsetSum_rat` (~80 lines): closure of `IsComputableSeqRat` under Computable-bounded finset sum via `Computable.nat_rec`.
  - `ite_rat` (~25 lines): closure under Bool conditional.
  - `isComputableSeqRat_doubleApply` (~12) + `isComputableSeqRat_tripleApply` (~16): convert flat-applied functions of pair/triple indexers into IsComputableSeqRat.
- **Inner destructures** (iter-10): `aX_a/b/s`, `aY_a/b/s`, `αR_a/b/s`, `βR_a/b/s` (24 Computable functions extracted from `hflat_X/Y/αR/βR`).
- **Bound machinery** (iters 11, 12, ~250 lines, all sorry-free):
  - `bound_aX/aY/αR/βR_at_0` (~40 lines combined).
  - `h_Bpow : Computable (fun j => B^j)` (~15 lines).
  - `bound_x_k, bound_y_k` (~60 lines).
  - `stuff_per_k` (~15 lines).
  - `bound_max` (~25 lines).
- **A1 witness components** (iters 06, 07, 12):
  - `M (n, m) := m + (d n + 1) + bound_max(n) + 2` + `hM` (~15 lines).
  - `dS, pad_X, pad_Y, aS` let-bindings.
  - `hd_S : Computable dS` via `Computable.nat_rec` (~28 lines).
- **`IsComputableSeqRat (flatten aS)` proof** (iter-09, ~150 lines):
  - 3-deep Nat.unpair decoder chain.
  - Indexer Computability chain.
  - Closure chain (doubleApply / tripleApply / ite_rat / .mul / .add).
  - The `convert h_r_flat using 1` Pi-app bridge.
  - Final `exact FinsetSumHelper.finsetSum_rat hr' hn'`.

Total new Lean: ~600 lines.

### Documentation

- `claims/l4-cmap-axiom-linearity/axiom_linearity.md` (~150 lines) — C5 claim file with full design rationale, 6 P-R citations, alternatives considered, bound-machinery design, 6-step bound proof outline, DA-flagged weaknesses.
- `blueprint/src/L4.tex` — theorem text updated to reflect partial state.
- `blueprint/lean_decls` — pointer updated to `computabilityStructureCMap_of`.
- `.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md` (~240 lines) — DA verdict `passes-partial` with per-item ⊕/⊖ analysis.
- `docs/NEXT-SESSION.md` (~250 lines) — refreshed with round summary + follow-up round plan.
- 16 iter notes at `.goals/l4-cmap-axiom-linearity-cont/iter-00.md` through `iter-16.md`.

## Devil's-advocate verdicts

| Artifact | Verdict | Key weaknesses found |
|---|---|---|
| `computabilityStructureCMap_of` def + axiom_linearity body (C2) | **passes-partial** | (1) Citation typo `Ch. 2:148 → :128` in 4 files [FIXED iter-15]. (2) "Provably unrealizable" over-claim in iter-04 / claim file [FIXED iter-15: softened to "by this proof strategy", with DA's monomial counterexample probe]. (3) Reducibility warning on the class-type def [FIXED iter-16 via `@[reducible]`]. (4) `convert h_r_flat using 1` stability concern for future `IsComputableSeqRat` refactor [flagged, not blocking]. |
| All 5 reusable closure helpers | sound (within `passes-partial`) | None — `finsetSum_rat` matches L1's `_add` dispatch, `ite_rat` case-analysis verified, doubleApply/tripleApply convert-pattern verified non-circular. |
| Bound machinery algebra (iters 11-12) | sound | M's factor-2 slack verified: `2^M = 4·2^m·2^(d n + 1)·2^bound_max(n) ≥ 2 · Σ_k stuff_per_k(n)`. `+6` in stuff_per_k gives `+4` needed slack. `bound_aX_at_0` upper bound on `|aX|` verified via `aX_b ≥ 1` (from L1's `b k ≠ 0` for `b : ℕ`). |
| `IsComputableSeqRat (flatten aS)` proof | sound | None — 3-deep Nat.unpair decoder chain verified; `convert h_r_flat using 1` step verified as Pi.add_apply / Pi.mul_apply defeq. |
| Edge-case probes (α > β, α = β, B = 0) | sound | All edge cases verified. Empty `Set.Icc α β` (when α > β) handled via `ContinuousMap.norm_le` which does NOT require `Nonempty`. |

## Key findings

1. **The polynomial-form A1 norm bound requires a Computable bound on `max(|α|, |β|)`** (iter-04 analysis, DA-verified iter-15). For arbitrary `α, β : ℝ`, no such bound exists; the round resolved this via the `(B : ℕ) (hα_le hβ_le)` parameterization (Path A), matching P-R Ch. 2:128's restriction to recursive reals. The unconditional instance was provably unrealizable *by this proof strategy*, not in general — DA's monomial counterexample (constant linear combination) shows the unconditional case can be realizable by other strategies.

2. **The `IsComputableSeqRat ↔ Computable ℚ` bridge can be sidestepped via inner-witness extraction** (iter-10 insight). From `hflat_X : IsComputableSeqRat (flat aX)`, extract `aX_a : ℕ → ℕ` Computable. Since `b ≥ 1` in the witness, `|aX(k, 0, j)| ≤ aX_a(Nat.pair k (Nat.pair 0 j))` as a real. This gives Computable ℕ-upper-bounds on rational witness values without the bridge.

3. **`convert ... using 1`** is a powerful tool for bridging Pi.add_apply / Pi.mul_apply gaps in IsComputableSeqRat reasoning (iter-09 trick). Lean's higher-order unification with explicit-then-convert is more reliable than direct unification.

4. **`Computable.nat_rec` step functions display as `(y, IH).2 * X`** (iter-11 pitfall). For inductions on the result, use `show` to force the goal into the matching form.

5. **`@[reducible]` on a `def` producing a class type** silences Lean's "must be marked" warning and enables typeclass unfolding (iter-16 fix). For parameterized constructors of typeclass instances, this is the right annotation.

6. **9 reusable closure helpers shipped**: 4 `addTriple` decls + `tripleToRat` + `finsetSum_rat` + `ite_rat` + 2 `*Apply` helpers. All are L1-shaped and should be lifted to `L1.IsComputableSeqRat.*` in a follow-up L1 round.

7. **The round's allow_writes excludes `claims/INDEX.md`** (caught by Stop hook iter-13). The L4 INDEX entry needs a separate cleanup round.

8. **DA verdict `passes-partial` is the correct outcome** for "5/6 components closed sorry-free, 1 sorry remaining". Not `passes` (the strict reading fails). Not `unsound` (nothing in the closed parts is wrong). Not `unsupported` (the bound outline is mathematically sound).

## Open questions

- **Norm bound proof**: ~200-300 lines of `ContinuousMap.norm_le` + `Finset.sum_comm` + per-k summand bound chasing + close-out. DA-identified 5 highest-risk steps (in `reviews/C2.md:233-247`). Friction-driven, not content-driven.
- **`finsetSum_rat` and `ite_rat` L1 lifting**: currently private-in-CMap.lean per the round's forbid_writes; should be lifted to `L1.IsComputableSeqRat.{finsetSum, ite}` in a future L1 round.
- **`isComputableSeqRat_doubleApply` and `_tripleApply` L1 lifting**: same.
- **`addTriple` machinery L1 lifting**: extract as a private helper in L1's `_add` proof.
- **A2 + A3 for CMap.lean**: `axiom_limits` (= P-R Ch. 0 Thm. 4) and `axiom_norms` (= P-R Ch. 0 Thm. 7) remain stub. These require their own rounds.
- **Whether to migrate to Path B** (`IsComputableReal α, β` instead of `(B : ℕ) (hα_le hβ_le)`): DA noted Path B is more P-R-faithful but more layered. Defer.

## Next-step recommendations

In order of priority:

1. **Round `l4-cmap-axiom-linearity-bound`** — close the remaining norm bound. Slug, mode, budget (10 iters / 240 min), criteria, DA-required-for-C2, all pre-populated in `docs/NEXT-SESSION.md` Action 2. **Recommended next session.**

2. **Round `l1-finsetsum-and-ite-lift`** — lift `finsetSum_rat` and `ite_rat` (and possibly `isComputableSeqRat_doubleApply/tripleApply`) from `FinsetSumHelper` to `L1.IsComputableSeqRat.*`. ~150 lines + small refactor in CMap.lean. Slug `l1-finsetsum-and-ite`, ~6 iters / 90 min. Frees CMap.lean from carrying L1-shaped code.

3. **Round `claims-index-cleanup`** — add the L4 section to `claims/INDEX.md` (caught out-of-scope by Stop hook iter-13). ~5 lines, 1 iter / 15 min.

4. **Zulip outreach** — the L4 partial close + 5/6 axiom_linearity fields + 9 reusable helpers is substantial enough for a Zulip pitch. Slug `zulip-l4-partial-pitch`, mode `explore`, 3 iters / 60 min.
