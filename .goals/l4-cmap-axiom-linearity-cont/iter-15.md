# iter-15

timestamp: 2026-06-03T13:30:23.166669+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: DA review on C2 done — verdict `passes-partial` (closed parts sound, sorry'd bound flagged separately); applied 2 DA fixes — citation typo `Ch. 2:148 → :128` in CMap.lean + claim file + L4.tex (4 locations) + softened the "provably unrealizable" claim in claim file with DA's monomial-counterexample probe context; `lake build` + `checkdecls` both green; iter-16 wraps with reducibility warning + NEXT-SESSION refresh
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis/L4/Instances/CMap.lean', 'blueprint/lean_decls', 'blueprint/src/L4.tex', '.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md', '.goals/l4-cmap-axiom-linearity-cont/iter-03.md', '.goals/l4-cmap-axiom-linearity-cont/iter-04.md', '.goals/l4-cmap-axiom-linearity-cont/iter-05.md', '.goals/l4-cmap-axiom-linearity-cont/iter-06.md', '.goals/l4-cmap-axiom-linearity-cont/iter-07.md', '.goals/l4-cmap-axiom-linearity-cont/iter-08.md', '.goals/l4-cmap-axiom-linearity-cont/iter-09.md', '.goals/l4-cmap-axiom-linearity-cont/iter-10.md', '.goals/l4-cmap-axiom-linearity-cont/iter-11.md', '.goals/l4-cmap-axiom-linearity-cont/iter-12.md', '.goals/l4-cmap-axiom-linearity-cont/iter-13.md', '.goals/l4-cmap-axiom-linearity-cont/iter-14.md', '.goals/l4-cmap-axiom-linearity-cont/iter-15.md', 'claims/l4-cmap-axiom-linearity/axiom_linearity.md']

## DA verdict: `passes-partial`

Full verdict at `.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md` (~240 lines, very thorough).

**Per-item DA outcomes** (5 items reviewed):

| Item | Status | Notes |
|---|---|---|
| 1. Instance restructure justification | ⊕ Sound; ⊖ citation typo; ⊖ "provably unrealizable" over-claim | Citation typo fixed this iter; over-claim softened in claim file |
| 2. Bound machinery (`bound_aX_at_0` → `bound_x_k` → ... → M) | ⊕ ALL ALGEBRA CHECKS OUT | Factor-2 slack in M; `+6` in `stuff_per_k` gives `+4` needed slack; `bound_aX_at_0` correctly bounds `\|aX\|` via `aX_b ≥ 1` |
| 3. `IsComputableSeqRat (flatten aS)` proof (~150 lines) | ⊕ Sound | 3-deep Nat.unpair decoder chain verified; `convert h_r_flat using 1` step verified as Pi.add_apply/Pi.mul_apply defeq |
| 4. 5 reusable closure helpers | ⊕ ALL SOUND | `finsetSum_rat`, `ite_rat`, `doubleApply`, `tripleApply`, `addTriple_*` all mathematically and definitionally correct |
| 5. Faithfulness to `iter-03-strategy.md` | ⊕ Matches paper-form A1 + iter-12 M-formula elaboration |

The DA also performed edge-case probes (α > β empty domain, α = β singleton, B = 0) — all sound. The bound proof outline at `claims/.../axiom_linearity.md:88-107` is verified as a faithful sketch.

## DA-required fixes applied this iter (2 of 3)

### Fix 1: Citation typo `Ch. 2:148 → :128` (4 locations)
- `ComputableAnalysis/L4/Instances/CMap.lean:427`
- `claims/l4-cmap-axiom-linearity/axiom_linearity.md:52, 121`
- `blueprint/src/L4.tex:14`

Verified via grep — all `Ch. 2:148` references now read `Ch. 2:128`. Build + checkdecls green.

### Fix 2: Soften "provably unrealizable" over-claim
Updated `claims/.../axiom_linearity.md:52` to: "*provably unrealizable by this proof strategy* (the polynomial-form `bound_x_k` chain — see DA verdict ... for the precise scope and a counterexample probe showing the unconditional case CAN be realizable via other strategies)". This matches the DA's monomial-counterexample analysis (line 84 of the verdict).

### Fix 3 (deferred to iter-16): reducibility warning
The `Definition computabilityStructureCMap_of of class type must be marked with @[reducible]` warning is a real Mathlib-submission blocker. To fix in iter-16.

## DA-flagged risk items for the follow-up round

DA identified 5 highest-risk steps for `l4-cmap-axiom-linearity-bound`:
1. `Finset.sum_comm` for the polynomial j-k swap (highest Lean-syntactic friction risk).
2. `ContinuousMap.norm_le` for ‖f - g‖ → pointwise.
3. Per-k summand bound chasing.
4. Σ_k bound via `Finset.sum_le_sum` + `Finset.sum_const_nat`.
5. Close-out using `Nat.lt_pow_self` or similar.

Estimated: 200-300 lines, friction-driven not content-driven.

## Build status

- `lake build` → 2532 jobs successful.
- 1 sorry-warning at norm bound (unchanged).
- 1 stylistic reducibility warning (iter-16 fix).
- `leanblueprint checkdecls` → exit 0.

## iter-16 plan (final wrap)

1. **Address reducibility warning** (DA fix #3): try `@[reducible] noncomputable def` or `@[implicit_reducible]`. If neither works cleanly, use `attribute [...] computabilityStructureCMap_of`.
2. **Refresh `docs/NEXT-SESSION.md`** with:
   - Round outcome (partial close: 5/6 fields + machinery + DA verdict).
   - Follow-up round `l4-cmap-axiom-linearity-bound` plan with the DA-identified 5-step risk profile.
   - Updated layer status table (L4 axiom_linearity now PARTIAL not STUB).
3. **Run `/goal-end`** or document round-end status.

Round projected to close as `partial` at iter-16.

## Round summary going into iter-16

- **5/6 axiom_linearity fields** closed sorry-free.
- **DA `passes-partial`** on the closed parts (sound, ready to ship eventually).
- **9 reusable helpers** + **complete bound machinery** + **instance restructure** + **claim file C5** + **blueprint update**.
- **1 sorry remaining** (norm bound) — well-scoped follow-up round with the 5-step risk profile.
- **3 DA-required fixes**: 2 done (citation + over-claim), 1 deferred (reducibility) for iter-16.
- **~600 lines** of new Lean code shipped in CMap.lean.
