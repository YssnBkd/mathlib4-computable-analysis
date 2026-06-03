# Prompt for next session

> *Paste this prompt as the opening message in the next conversation. It is self-contained — you do not need to re-read prior transcripts.*

---

You are continuing work on **mathlib-computable-analysis**, a Lean 4 / Mathlib4 formalization of Pour-El & Richards' *Computability in Analysis and Physics* (Cambridge UP 1989), intended for upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. Read `CLAUDE.md` first — it is the project constitution.

## Major change since the last NEXT-SESSION.md

Round `l4-cmap-axiom-linearity-cont` (2026-06-03, partial close at 16/16 of doubled budget) shipped the **L4 `axiom_linearity` witness construction + Computability + IsComputableSeqRat proof** — 5 of 6 axiom_linearity components closed sorry-free; only the norm bound remains. Devil's-advocate verdict on C2: `passes-partial` (all closed parts sound).

Key shipped pieces:

1. **Instance restructured** — `noncomputable instance instComputabilityStructureCMap` → `@[reducible] noncomputable def computabilityStructureCMap_of (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ))`. Takes explicit rational bound on `max(|α|, |β|)`, matching P-R Ch. 2:128's restriction to recursive reals. `@[reducible]` was added so the def can participate in typeclass unfolding.
2. **Witness `aS, dS, M, pad_X, pad_Y`** as concrete let-bindings inside `axiom_linearity` body. M's formula: `m + (d n + 1) + bound_max(n) + 2`.
3. **Complete bound machinery** (~250 lines, all sorry-free): `bound_aX_at_0`, `bound_aY_at_0`, `bound_αR_at_0`, `bound_βR_at_0`, `h_Bpow` (B^j Computable via `Computable.nat_rec`), `bound_x_k`, `bound_y_k`, `stuff_per_k`, `bound_max`, `hM`, `hd_S`.
4. **`IsComputableSeqRat (flatten aS)` proof** via `FinsetSumHelper.finsetSum_rat` + `ite_rat` + `isComputableSeqRat_doubleApply` + `isComputableSeqRat_tripleApply` + L1 `IsComputableSeqRat.{add, mul, comp}`. ~150 lines, all sorry-free. The `convert h_r_flat using 1` trick bridges the Pi.add_apply/Pi.mul_apply gap.
5. **5 reusable closure helpers** in `FinsetSumHelper` namespace (in `ComputableAnalysis/L4/Instances/CMap.lean`): `addTriple` (+ `_b_ne_zero`, `_correct`, `_computable`), `tripleToRat`, `finsetSum_rat`, `ite_rat`, `isComputableSeqRat_doubleApply`, `isComputableSeqRat_tripleApply`. TODO: lift to L1 in a follow-up round.
6. **C5 claim file** at `claims/l4-cmap-axiom-linearity/axiom_linearity.md` — full design rationale + alternatives + sources + DA-pending verdict + roadmap.
7. **Blueprint L4.tex updated** to reflect partial state.
8. **DA verdict** at `.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md` (~240 lines): `passes-partial`. All closed parts verified sound; 3 fixes applied (citation typo, over-claim softening, reducibility warning).

## TL;DR

1. `lake build` should produce **0 errors, 1 sorry-warning** at `ComputableAnalysis/L4/Instances/CMap.lean:439:31` (the `axiom_linearity` decl line; the actual sorry is the norm bound at the end of axiom_linearity's body). 2532 jobs.
2. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web && PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls` should be silent / exit 0 / produce blueprint with 12 L0 nodes green, 11 L1 nodes green, 1 L1 stub + L2/L5 nodes orange, 1 L3 node green, 1 L4 node WHITE-BORDERED (stated, polynomial-form predicate; partial proof — witness + IsComputableSeqRat closed, norm bound deferred).
3. **Recommended next direction (Action 2 below)**: open round **`l4-cmap-axiom-linearity-bound`** to close the remaining norm bound (~200-300 lines). DA-verified 5-step plan in `claims/.../axiom_linearity.md:88-107` + risk profile in `.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md:233-247`.

## Where we stand by layer (blueprint-color reading)

| Layer | Lean state | Blueprint chapter state | Next milestone |
|---|---|---|---|
| L0 | done | `L0.tex` all 12 nodes `\leanok` | none — done |
| L1 | rat-seq closures + point predicate done | `L1.tex` 11 `\leanok` envs | real-seq closures; `finsetSum` lift; Def 5 ↔ 5a |
| L2 | not started | `L2.tex` 1 `\notready` stub | predicate `IsGLComputable` (deferred) |
| L3 | typeclass formalized (0 sorries) | `L3.tex` 1 `\notready` stub — does NOT reflect `\leanok`-eligible parts | content migration (deferred) + stability theorem |
| L4 | **CMap stub: A1 PARTIAL (witness + IsComputableSeqRat closed, norm bound sorry); A2/A3 stub** | `L4.tex` 3 `\notready` stubs; CMap text updated to reflect partial state | **close A1 norm bound** (recommended next) |
| L5 | not started | `L5.tex` 4 `\notready` stubs | First Main Theorem |

## Your task this session

### Action 1 — confirm the env is intact (~3 min)

```bash
lake build 2>&1 | tail -5
PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web 2>&1 | tail -5
PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls; echo "exit: $?"
gh run list --repo YssnBkd/mathlib4-computable-analysis --limit 3
```

Expected: 2532 jobs successful, 1 sorry-warning at `CMap.lean:439:31`, exit 0 for checkdecls.

### Action 2 — recommended direction: close the L4 A1 norm bound

**Why this and not other directions**: the round just shipped 5/6 of A1 with all bound machinery in place. The norm bound is well-scoped (200-300 lines), DA-verified for soundness, and the polynomial-form A1 proof completion unlocks the full L4 CMap instance for downstream L5 work.

Suggested round setup:

- **Slug**: `l4-cmap-axiom-linearity-bound`
- **Mode**: `proof-attempt`
- **Budget**: **10 iters / 240 min** (calibrated: 200-300 lines of Lean, friction-driven not content-driven).
- **Allow_writes**:
  - `ComputableAnalysis/L4/Instances/CMap.lean`
  - `blueprint/src/L4.tex` (toggle to `\leanok` after closure)
  - `blueprint/lean_decls`
  - `claims/l4-cmap-axiom-linearity/**`
  - `CLAUDE.md`
  - `.goals/l4-cmap-axiom-linearity-bound/**`
  - `.goals/INDEX.md`
  - `thinking/l4-cmap-axiom-linearity-bound/**`
  - `docs/NEXT-SESSION.md`
- **Forbid_writes**:
  - `ComputableAnalysis/L0/**`, `ComputableAnalysis/L1/**`, `ComputableAnalysis/L3/**`, `ComputableAnalysis.lean`
  - `blueprint/src/{content,L0,L1,L2,L3,L5}.tex`
  - `blueprint/src/{blueprint.sty,plastex.cfg,latexmkrc}.tex` and `blueprint/src/macros/**`
  - `literature/papers/**/verbatim.md`
  - `.claude/commands/**`
  - `.github/workflows/**`, `lakefile.toml`, `lake-manifest.json`, `lean-toolchain`
- **Criteria** (machine-checkable):
  - **C1**: `lake build` green; `ComputableAnalysis/L4/Instances/CMap.lean` has **0** sorry-warnings (A1 fully closed; A2 and A3 still sorry — see C3).
  - **C2**: norm bound `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m` is concrete (no `sorry`); the proof follows the DA-verified 5-step outline.
  - **C3**: A2 and A3 remain `sorry` (deferred).
  - **C4**: blueprint label `thm:l4_cmap_instance` toggled to `\leanok`.
  - **C5**: claim file updated with the bound proof's actual structure + DA verdict on C2.
- **Devil's-advocate required for**: C2 (the bound proof).

### DA-identified risk profile for the bound round (high to low)

1. **`Finset.sum_comm` for the polynomial j-k swap** (highest Lean-syntactic friction).
2. **`ContinuousMap.norm_le`** (Compact.lean:204) for `‖f - g‖ → ∀ x_*, |f x_* - g x_*| ≤ ε`. Does NOT require `Nonempty` — handles empty `Set.Icc α β` directly.
3. **Per-k summand bound chasing** using `hbnd_αR`, `hbnd_X`, `bound_x_k`, `bound_αR_at_0`, `hα_le`, `hβ_le`. Deeply nested `let`s — name resolution may be painful.
4. **Σ_k bound** via `Finset.sum_le_sum` + `Finset.sum_const_nat`.
5. **Close-out**: `2^{-M} · 2 · (d n + 1) · bound_max(n) ≤ 1/2^m` using `Nat.lt_pow_self` or similar.

Bound algebra verified by DA: `2^M = 4 · 2^m · 2^(d n + 1) · 2^bound_max(n)`. Two factor-≤-1 brackets `[(d n + 1) / 2^(d n + 1)]` and `[bound_max(n) / 2^bound_max(n)]` give factor 2 slack.

### Action 3 — alternative directions

- **L1 real-sequence closures** (slug `l1-real-sequence-closure`, proof-attempt, ~10 iters / 180 min). Lifts `IsComputableSeqRat.{add,mul,comp}` through `IsComputableSeqReal`. Useful for future L4 axioms but doesn't close any current sorry.
- **L1 `finsetSum_rat` + `ite_rat` lift** (slug `l1-finsetsum-and-ite`, proof-attempt, ~6 iters / 90 min). Lifts the round's two private closure helpers from CMap.lean to L1's `IsComputableSeqRat` namespace. Frees CMap.lean from carrying ~250 lines of L1-shaped code.
- **L3 stability theorem** (slug `l3-stability`, proof-attempt, ~8 iters / 150 min). Independent of L1/L4; high-leverage.
- **Zulip outreach with live blueprint** (slug `zulip-l0-l1-l3-l4-pitches`, mode `explore`, 3 iters / 60 min). L1 now has 11 green nodes + L4 has a substantial partial; Zulip pitches at `docs/zulip-drafts/*` can credibly link a fuller dep graph.

## Critical knowledge — what's in `ComputableAnalysis/L4/Instances/CMap.lean` now

| Section | Decls | Status |
|---|---|---|
| §0 `FinsetSumHelper` | `addTriple`, `addTriple_b_ne_zero`, `tripleToRat`, `addTriple_correct`, `addTriple_computable`, `finsetSum_rat`, `isComputableSeqRat_doubleApply`, `isComputableSeqRat_tripleApply`, `ite_rat` | All sorry-free |
| `polyApproxCMap` | `noncomputable def` | sorry-free |
| `IsComputableSeqCMap` | `def` | sorry-free |
| `computabilityStructureCMap_of` | `@[reducible] noncomputable def` taking `(B : ℕ) (hα_le hβ_le)` | **A1 partial** (witness + Computability + IsComputableSeqRat closed; norm bound sorry); **A2/A3 stub**; `zero_seq` done |

Length: ~850 lines (was ~360 before this round).

## Critical knowledge — Mathlib symbols (re-verified through iter-16)

| Concept | Exact symbol | Location | Note |
|---|---|---|---|
| `Computable.nat_rec` | yes | `Partrec.lean:584` | Constant-motive form. Step function may show as `(y, IH).2 * X` — use `show` to bridge to `IH * X` in inductions. |
| `Computable.id, .const, .fst, .snd, .pair, .comp, .succ, .unpair` | all standard | `Partrec.lean:268-301` | |
| `Primrec.nat_add/sub/mul/le/max/mod/bodd` | all | `Primrec/Basic.lean:593,596,599,610,620,728,733` | |
| `Primrec.nat_le.decide`, `Primrec.beq` | yes | derived | For Bool conditions |
| `Primrec₂.natPair` | yes | derived from `Primrec.nat_pair` | For pairing |
| `ContinuousMap.norm_le` | yes | `Topology/ContinuousMap/Compact.lean:204` | Does NOT require Nonempty; only `0 ≤ C` |
| `Finset.sum_comm` | yes | standard | For polynomial j-k swap |
| `Finset.sum_le_sum`, `Finset.sum_const_nat` | yes | standard | For Σ_k bound |

**Pitfalls logged from iter-03 → iter-12**:
- `Computable.nat_rec` step shows `(y, IH).2 * X` — use `show Nat.rec ... j` in induction with same form.
- `let` shadowing for hypotheses: `obtain ⟨...⟩ := h; have h : ... := ⟨...⟩` to re-introduce.
- `convert ... using 1` for Pi.add_apply/Pi.mul_apply gap (iter-09 trick).
- `@[reducible]` on `def` of class type (iter-16 fix).

## Watchpoints — don't repeat past mistakes

- **DON'T cite P-R Ch. 2:148 for "recursive reals a, b"**. The phrase is at Ch. 2:128. Line 148 has the polynomial-form equation. This was caught by DA in this round.
- **DON'T over-claim "provably unrealizable"** without specifying scope. The unconditional A1 instance is unrealizable *by the polynomial-form bound strategy*, not in general. DA's monomial counterexample (constant linear combination) shows an alternative strategy could work.
- **DON'T write to `claims/INDEX.md` outside an explicit allow_writes**. Caught by Stop hook in iter-13.
- **DON'T expect Mathlib to have everything**. `Primrec.nat_pow` doesn't exist — define inline via `Computable.nat_rec`.

## Files to know

- `CLAUDE.md` — slim constitution. Read first.
- `docs/NEXT-SESSION.md` — this file.
- `ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` — L0, done.
- `ComputableAnalysis/L1/ComputableSeqReal.lean` — L1, mature.
- `ComputableAnalysis/L3/ComputabilityStructure.lean` — L3 keystone, formalized.
- `ComputableAnalysis/L4/Instances/CMap.lean` — **L4 first instance, A1 partial (witness + IsComputableSeqRat closed, norm bound sorry); A2/A3 stub**. ~850 lines.
- `claims/l4-cmap-axiom-linearity/axiom_linearity.md` — round's design rationale + DA-verified roadmap for the bound.
- `.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md` — ~240-line DA verdict.
- `.goals/l4-cmap-axiom-linearity-cont/final.md` — round-end summary.
- `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` — paper-form A1 proof, still load-bearing for the bound round.

## If the user types something different

The above task list assumes default continuation (Action 2 = close the A1 bound). If the user opens with a different request, follow their direction — this prompt is a *default*, not a script.

---

*End of prompt.*
