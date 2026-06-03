# Prompt for next session

> *Paste this prompt as the opening message in the next conversation. It is self-contained — you do not need to re-read prior transcripts.*

---

You are continuing work on **mathlib-computable-analysis**, a Lean 4 / Mathlib4 formalization of Pour-El & Richards' *Computability in Analysis and Physics* (Cambridge UP 1989), intended for upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. Read `CLAUDE.md` first — it is the project constitution.

## Major change since the last NEXT-SESSION.md

Round `l1-arithmetic-closure-and-real` (2026-06-03, success 7/14 iters) shipped the L1 arithmetic-closure layer:

1. **Rational-sequence closures shipped under Mathlib dot-notation.** `IsComputableSeqRat.add` (lifted from L4's private 80-line helper), `IsComputableSeqRat.mul` (clean 4-line algebra), `IsComputableSeqRat.comp` (precomposition with a computable re-indexing). All in `namespace ComputableAnalysis.L1.IsComputableSeqRat`, callable as `h₁.add h₂` etc.
2. **Point-level predicate shipped.** `IsComputableReal x := IsComputableSeqReal (fun _ => x)` with sanity lemmas `.ofRat` and `.zero`. Citation is P-R Ch. 0:58 (Definition 3) — *not* Ch. 0:55 (Definition 2 = effective-convergence relation); the prior NEXT-SESSION.md had inherited the wrong line and the DA review caught it during this round.
3. **Blueprint L1.tex chapter went from 2 envs to 11 envs**, all `\leanok` except 0 stubs (was 2 `\notready`). Dep-graph L1 column is now fully populated for the rational + point-predicate slice.
4. **L4 CMap cleaned up.** The private 80-line `isComputableSeqRat_add` + 60-line "TODO refactor → L1" comment block deleted. CMap's `axiom_linearity` body still `sorry` (the sole remaining sorry-warning), but now references the lifted L1 lemma via `open ComputableAnalysis.L1`. Sorry-line shifted: `261:23` → `104:23`.
5. **Legacy claim file migrated to satellite format.** `claims/l1-computable-reals/is-computable-seq-real.md` now points at `[[blueprint:def:l1_isComputableSeqReal]]`; rationale prose preserved; stale `formal/...` paths removed.

## TL;DR

1. `lake build` should produce **0 errors, 1 sorry-warning** at `ComputableAnalysis/L4/Instances/CMap.lean:104:23` (the L4 instance grouping A1/A2/A3 theorem-body sorries — `axiom_linearity := by … sorry` is the proximate cause; the warning attributes to the instance decl line). Anything else means the env diverged.
2. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web && PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls` should be silent / exit 0 / produce `blueprint/web/index.html` + `blueprint/web/dep_graph_document.html` with 12 L0 nodes green, 11 L1 nodes green, 1 L1 stub + L2/L4/L5 nodes orange, 1 L3 node green.
3. **Live blueprint** (after CI deploys): `https://yssnbkd.github.io/mathlib4-computable-analysis/blueprint/` (and `.../blueprint/dep_graph_document.html` for the graph). If 404, Pages deploy didn't run yet — check `gh run list --repo YssnBkd/mathlib4-computable-analysis --limit 3`.
4. **Recommended next direction (Action 2 below)**: resume **L4 `axiom_linearity` proof** (P-R Ch. 2 A1, polynomial form). Now unblocked by the L1 closures shipped in this round. The full paper-form proof + verbatim P-R citations live at `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` (still load-bearing). Estimated 6-8 iters / 150-180 min.

## Where we stand by layer (blueprint-color reading)

| Layer | Lean state | Blueprint chapter state | Next milestone |
|---|---|---|---|
| L0 | done (3 files, 0 sorries) | `L0.tex` fully populated, all 12 nodes `\leanok` | none — done |
| L1 | rat-seq closures (+ /×/comp), point predicate done | `L1.tex` 11 `\leanok` envs, 0 `\notready` | real-seq closures (`IsComputableSeqReal.add/.mul/.comp`); `_finsetSum` (rat-seq); Def 5 ↔ Def 5a equivalence |
| L2 | not started | `L2.tex` 1 `\notready` stub | predicate `IsGLComputable` (deferred) |
| L3 | typeclass formalized (0 sorries) | `L3.tex` 1 `\notready` stub — does NOT reflect the `\leanok`-eligible parts | content migration (deferred) + stability theorem |
| L4 | CMap stub (def + instance sorry-free; A1/A2/A3 theorem-body sorries) | `L4.tex` 3 `\notready` stubs | close A1 — **toolkit ready** from this round's L1 closures |
| L5 | not started | `L5.tex` 4 `\notready` stubs | First Main Theorem (P-R Ch. 3) |

## Your task this session

### Action 1 — confirm the env is intact (~3 min)

```bash
lake build 2>&1 | tail -5
PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web 2>&1 | tail -5
PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls; echo "exit: $?"
gh run list --repo YssnBkd/mathlib4-computable-analysis --limit 3
```

Expected:
- `lake build`: 1 sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:104:23`, `Build completed successfully (2532 jobs)`.
- `leanblueprint web`: produces `blueprint/web/` with no plasTeX errors.
- `leanblueprint checkdecls`: exit 0, no output.
- Recent workflow runs: most recent should be `completed` `success` for the `l1-arithmetic-closure-and-real` commit (`feat(L1): ship arithmetic closure...`).

If `checkdecls` reports unresolved decls, a `\lean{...}` macro in `blueprint/src/*.tex` points at something the Lean project doesn't export. Fix the macro target name; don't add a sorry-bearing Lean decl just to make the check pass.

### Action 2 — recommended direction: resume L4 `axiom_linearity` (A1)

**Why this and not L1 real-seq closures:** the prior round's L4 attempt (`l4-cmap-axiom-linearity`, budget-exhausted at 5/6 iters / ~198 min) discovered the L1 rational-closure gap — which `l1-arithmetic-closure-and-real` just closed. Resuming A1 directly is now the highest-leverage next step: the toolkit is `IsComputableSeqRat.add/.mul/.comp` plus the rational-arithmetic identities, all available unqualified inside CMap.lean (already opens `ComputableAnalysis.L1`).

**Why not parallel L1 real-seq closures first:** they would be useful for *future* L4 axioms (`axiom_limits`, `axiom_norms`) and other instances, but A1 in the polynomial-approximation form can be discharged using just the rational closures plus standard real-arithmetic identities (no `IsComputableSeqReal.add` needed at the topmost level — the witness assembly stays at the ℚ-level). Confirm by re-reading `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` before opening the round.

Suggested round setup:

- **Slug**: `l4-cmap-axiom-linearity-cont`
- **Mode**: `proof-attempt`
- **Budget**: **8 iters / 180 min** (calibrated: prior round shipped `_add` in 5 iters; A1 closure is "assemble the 3 helpers around the polynomial double-sum + 2x-precision pad", which the prior round's iter-03 strategy estimated at ~50 lines of witness assembly).
- **Allow_writes**:
  - `ComputableAnalysis/L4/Instances/CMap.lean`
  - `blueprint/src/L4.tex` (toggle the A1 `\notready` to `\leanok` after the proof lands)
  - `blueprint/lean_decls`
  - `claims/l4-cmap-axiom-linearity/**`
  - `CLAUDE.md` (only the corpus-ingestion table if new chapters get ingested)
  - `.goals/l4-cmap-axiom-linearity-cont/**`, `.goals/INDEX.md`
  - `thinking/l4-cmap-axiom-linearity-cont/**`
  - `docs/NEXT-SESSION.md` (refresh at round end)
- **Forbid_writes**:
  - `ComputableAnalysis/L0/**`, `ComputableAnalysis/L1/**`, `ComputableAnalysis/L3/**`, `ComputableAnalysis.lean`
  - `blueprint/src/{content,L0,L1,L2,L3,L5}.tex`
  - `blueprint/src/{blueprint.sty,plastex.cfg,latexmkrc}.tex` and `blueprint/src/macros/**`
  - `literature/papers/**/verbatim.md`
  - `.claude/commands/**`
  - `.github/workflows/**`, `lakefile.toml`, `lake-manifest.json`, `lean-toolchain`
- **Criteria** (machine-checkable):
  - **C1**: `lake build` green; `ComputableAnalysis/L4/Instances/CMap.lean` has **0** sorry-warnings (A1 closed; A2 and A3 may remain — see below). `leanblueprint checkdecls` exits 0.
  - **C2** (A1 fully proved): `axiom_linearity` body in `instComputabilityStructureCMap` is concrete (no `sorry`); the polynomial-approximation witness construction is faithful to the iter-03 strategy.
  - **C3** (A2 + A3 deferred or shipped): either (a) both `axiom_limits` and `axiom_norms` remain `sorry` and the C1 wording is updated to "0 sorries in A1; A2/A3 still sorry", or (b) one/both are also shipped (budget permitting).
  - **C4** (blueprint): blueprint label `lem:l4_cmap_axiom_linearity` (or chosen name) goes `\leanok`.
  - **C5** (claim file): a satellite `claims/l4-cmap-axiom-linearity/axiom_linearity.md` is written per `claims/TEMPLATE.md`, capturing the strategy that succeeded.

**Devil's-advocate required for**: C2 (the A1 proof body — the witness construction is non-trivial and the precision-pad argument is the kind of thing that wants a second pair of eyes).

### Action 3 — alternative directions

- **L1 real-sequence closures** (`IsComputableSeqReal.add/.mul/.comp`): slug `l1-real-sequence-closure`, mode `proof-attempt`, ~10 iters / 180 min. Lifts the rational-seq closures shipped this round through `IsComputableSeqReal`'s double-rational-witness form. Useful for downstream L3 axiom proofs across instances. *Doesn't* directly unblock anything currently sorry — A1 can be done at the ℚ-level.
- **L3 stability theorem** (P-R Ch. 2.3): slug `l3-stability`, mode `proof-attempt`, ~8 iters / 150 min. Uniqueness of the computability structure under mild side conditions. Independent of L1/L4; high-leverage but no immediate dependency.
- **Ship `IsComputableSeqRat.finsetSum`** (the deferred C5 sibling): slug `l1-rat-finsetsum`, mode `proof-attempt`, ~4 iters / 60 min. Standard induction on `Finset` chaining `.add`. Will be needed for L4 A1's `Σ_{j=0}^{d(n,k)} α_{n,k,j} · ...` form eventually; could go in parallel.
- **Definition 5 ↔ Definition 5a equivalence**: slug `l1-def5-equivalence`, mode `proof-attempt`, ~4 iters / 60 min. Short (per P-R Ch. 0:209-215, "given Def 5 with modulus e, set `r'_{n,k} := r_{n, e(n,k)}`"); only a nice-to-have for now.
- **Zulip outreach with live blueprint**: slug `zulip-l0-l1-l3-pitches`, mode `explore`, 3 iters / 60 min. L1 chapter is now substantial (11 green nodes); the L0 + L3 pitches at `docs/zulip-drafts/*` can credibly link a populated dep graph.

## Critical knowledge — what's in `ComputableAnalysis/L1/ComputableSeqReal.lean` now

The L1 file's public API as of 2026-06-03 (post-round):

| Section | Decls | Status |
|---|---|---|
| §1 | `IsComputableSeqRat`, `IsComputableDoubleSeqRat` | def-level, sorry-free |
| §2 | `IsComputableSeqReal` | def-level, sorry-free |
| §3 | `isComputableSeqRat_const`, `isComputableSeqReal_const_rat` | sanity, sorry-free (snake-case, predates the §4 convention) |
| §4 | `namespace IsComputableSeqRat` containing `.add`, `.mul`, `.comp` | full proofs, sorry-free |
| §5 | `def IsComputableReal`, `namespace IsComputableReal` containing `.ofRat`, `.zero` | full proofs, sorry-free |
| §6 | smoke `#check` block | — |

**Idioms that worked, copy them:** the closure proofs reuse the prior round's `Primrec.nat_mul.to_comp.comp h h'` / `Computable.cond` / `Computable.of_eq` patterns; the rational arithmetic identities are closed by `rw [pow_add]; push_cast; field_simp; try ring`. The `try ring` is essential — `field_simp` closes some cases entirely and bare `ring` errors with "No goals to be solved".

**Naming convention drift:** §3's `_const` lemmas are at module-level snake-case (`isComputableSeqRat_const`); §4-§5 use dot-notation under sub-namespaces (`IsComputableSeqRat.add`, `IsComputableReal.ofRat`). The drift is documented in the file's `## What this file is NOT` preamble; do not retroactively rename §3 unless a future round explicitly budgets it.

## Critical knowledge — Mathlib symbols (carried from prior rounds, re-verified)

| Concept | Exact symbol | Import / location | Note |
|---|---|---|---|
| `Primrec.nat_add/sub/mul/le` | as named | `Mathlib/Computability/Primrec/Basic.lean:593,596,599,610` | ℕ-level arithmetic. `nat_sub` is **truncated** (0 if negative). |
| `Primrec.nat_mod / nat_bodd` | both | `Mathlib/Computability/Primrec/Basic.lean:728,733` | `nat_bodd` returns `Bool`; prefer over `% 2` when the result needs to be Computable. |
| `Primrec.ite / .cond` | both | `Mathlib/Computability/Primrec/Basic.lean:602,606` | `.cond` is `Bool`-conditional; `.ite` is `Prop`-conditional with `[DecidablePred c]`. |
| `Computable.cond` | yes | `Mathlib/Computability/Partrec.lean:594` | `cond hc hf hg : Computable (fun a => bif (c a) then (f a) else (g a))`. |
| `Computable₂.comp` | yes | `Mathlib/Computability/Partrec.lean:477` | Takes **two separate** `Computable` args, NOT a paired one. |
| `Primrec₂.to_comp` | yes | `Mathlib/Computability/Partrec.lean:252` | Lifts `Primrec₂` to `Computable₂`. |
| `PrimrecRel.decide` | yes | `Mathlib/Computability/Primrec/Basic.lean:426` | Converts `PrimrecRel R` to `Primrec₂ (fun a b => decide (R a b))`. Use `.swap.decide` to flip arg order. |
| `Pi.add_apply / Pi.mul_apply` | both | `Mathlib/Algebra/Group/Pi/Basic.lean` | `rfl`-level. `(r₁ + r₂) k` reduces definitionally to `r₁ k + r₂ k`; `show r₁ k + r₂ k = _` absorbs the conclusion form change. |

## Watchpoints — don't repeat past mistakes

- **DON'T cite P-R Ch. 0:55 for the point predicate.** Line 55 is *inside Definition 2's display equation* (effective convergence relation, with explicit modulus `e(N)`). The point predicate is **Definition 3** at line 58. This was caught by C6's DA review in this round.
- **DON'T rename §3's snake-case sanity lemmas without budgeting it.** They're stable public surface; mechanical retroactive renames widen blast radius for no DA-acknowledged gain.
- **DON'T ship a lemma at module level when it should be under `namespace IsComputableSeqRat` (or similar).** Mathlib dot-notation convention. Match the §4-§5 idiom for any new closure lemmas.
- **DON'T set `\leanok` on a blueprint env whose `\lean{decl}` target has `sorry` in its proof body.** Hard rule in CLAUDE.md `## sorry policy`. `#print axioms <decl>` showing `sorryAx` is a refusal.
- **DON'T set proof-attempt iter budgets below what prior similar work took.** The L1 closure round used 7/14 iters; A1 closure is comparable scope. 8/180 is the calibrated budget for L4 A1.
- **DON'T edit `blueprint/src/L0.tex` / `L1.tex` / `L3.tex` / `L5.tex` (etc.)** outside the active layer. The `\input` order in `content.tex` is fixed; other chapter files belong to other rounds.
- **DON'T touch `.claude/commands/**` or `.github/workflows/**`** — workflow scaffold; modifications require their own dedicated round.

## User calibration

Technically capable; explicit authorization for bold changes. Defers on Zulip posting / commits / PRs / scope changes. Each commit needs an explicit "yes" from them; never assume. After approval, batch related changes into one or two reviewable commits with HEREDOC commit messages ending in `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`.

## Files to know

- `CLAUDE.md` — slim constitution. Read first.
- `docs/SETUP.md` — Lean install + first build (runs from repo root).
- `docs/NEXT-SESSION.md` — this file.
- `ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` — L0, **done**, all blueprint nodes green.
- `ComputableAnalysis/L1/ComputableSeqReal.lean` — L1, **mature**: rat-seq predicates + closures (`IsComputableSeqRat.{add,mul,comp}`) + point predicate `IsComputableReal` + `.{ofRat,zero}`. 0 sorries.
- `ComputableAnalysis/L3/ComputabilityStructure.lean` — **L3 keystone, formalized** (0 sorries).
- `ComputableAnalysis/L4/Instances/CMap.lean` — **L4 first instance, A1/A2/A3 still sorry** (consolidated as `axiom_linearity := sorry` etc; the sole sorry-warning at line 104:23 attributes to the instance decl). The private `_add` helper from the prior round has been lifted to L1 and removed from this file.
- `ComputableAnalysis.lean` — umbrella import. **Don't edit** in most rounds.
- `blueprint/src/{content,L0,L1,L2,L3,L4,L5}.tex` — blueprint chapters. **L4.tex is the editable target for the next recommended round.**
- `blueprint/src/macros/common.tex` — theorem-env defs.
- `blueprint/lean_decls` — declaration list (auto-regenerated). Must be in `allow_writes` for any round touching blueprint envs.
- `blueprint/web/` — local-build output. `.gitignored`; rebuild with `leanblueprint web`.
- `claims/INDEX.md` + `claims/TEMPLATE.md` — post-2026-06-02 satellite convention. Read before writing new claim files.
- `claims/l1-computable-reals/is-computable-seq-real.md` — **post-migration** satellite (clean reference for the migration pattern).
- `claims/l3-computability-structure/axioms.md` — legacy claim file; migration deferred to a future L3 round.
- `literature/papers/PourEl-Richards-*.md` — per-chapter verbatim extracts (P-R 1989).
- `.goals/l1-arithmetic-closure-and-real/final.md` — **completed** round (success, 7/14 iters). Full report. Read for context on the L1 closure shipping.
- `.goals/l4-cmap-axiom-linearity/final.md` — prior L4 round (budget-exhausted, 5/6 iters). Strategy + verbatim P-R citations at `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` (still load-bearing for the resumed A1 round).
- `.goals/INDEX.md` — registry of all past rounds.
- `docs/zulip-drafts/{2026-06-01-l0-pitch,2026-06-01-l3-pitch,2026-06-01b-decision}.md` — drafts (still deferred; can now be updated to link the live blueprint with 11 green L1 nodes in addition to L0 and L3).

## If the user types something different

The above task list assumes default continuation. If the user opens with a different request (e.g., "let's parallel-ship the L1 real-seq closures first", "let's actually post the Zulip pitches now"), follow their direction — this prompt is a *default*, not a script.

---

*End of prompt.*
