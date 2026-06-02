# Prompt for next session

> *Paste this prompt as the opening message in the next conversation. It is self-contained — you do not need to re-read prior transcripts.*

---

You are continuing work on **mathlib-computable-analysis**, a Lean 4 / Mathlib4 formalization of Pour-El & Richards' *Computability in Analysis and Physics* (Cambridge UP 1989), intended for upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. Read `CLAUDE.md` first — it is the project constitution.

## Major change since the last NEXT-SESSION.md

This project adopted Patrick Massot's **`leanblueprint`** framework on 2026-06-02 (one big multi-step round). Three concrete consequences for *every* future session:

1. **Lake project root moved.** The Lean source now lives at `ComputableAnalysis/` (git root), not `formal/ComputableAnalysis/`. There is no `formal/` directory anymore. `lake build` runs from the repo root, no `cd formal &&` prefix.
2. **The dep graph is the source of truth for formalization state.** `blueprint/web/dep_graph_document.html` (rebuild with `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web`) is the milestone tracker. The CLAUDE.md hand-maintained "Construction milestones" table is GONE; the 7-label YAML status taxonomy on claim files is no longer authoritative. Color states (`\leanok` = green, `\mathlibok` = dark green, `\notready` = orange) live in `blueprint/src/*.tex` and propagate to the graph via `leanblueprint web`.
3. **Skills are blueprint-aware.** `/claim` now writes both a rationale satellite under `claims/` AND a `\notready` LaTeX block in `blueprint/src/<layer>.tex`. `/formalize` Phase 6 toggles the LaTeX from `\notready` to `\lean{<Decl>}\leanok` after Lean type-checks and `leanblueprint checkdecls` passes. `/verify` runs `lake build` + `leanblueprint web` + `leanblueprint checkdecls` plus satellite-pointer-resolution.

## TL;DR

1. `lake build` should produce **0 errors, 1 sorry-warning** at `ComputableAnalysis/L4/Instances/CMap.lean:261:23` (the L4 instance grouping A1/A2/A3 theorem-body sorries). Anything else means the env diverged.
2. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web && PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls` should be silent / exit 0 / produce `blueprint/web/index.html` + `blueprint/web/dep_graph_document.html` with 12 L0 nodes green and 11 L1-L5 nodes orange.
3. **Live blueprint** (after CI deploys): `https://yssnbkd.github.io/mathlib4-computable-analysis/blueprint/` (and `.../blueprint/dep_graph_document.html` for the graph). If 404, Pages deploy didn't run yet — check `gh run list --repo YssnBkd/mathlib4-computable-analysis --limit 3`.
4. **Recommended next direction (Action 2 below)**: L1 closure-first round, **blueprint-native**. Migrate existing L1 content to blueprint LaTeX as the first iteration; then lift `isComputableSeqRat_add` from L4 to L1 proper; then ship `_mul`/`_reindex`/`_finsetSum`; define `IsComputableReal`. Each new lemma lands as a green dep-graph node.

## Where we stand by layer (blueprint-color reading)

| Layer | Lean state | Blueprint chapter state | Next milestone |
|---|---|---|---|
| L0 | done (3 files, 0 sorries) | `L0.tex` fully populated, all 12 nodes `\leanok` | none — done |
| L1 | `IsComputableSeqReal` done; closures + `IsComputableReal` pending | `L1.tex` 2 `\notready` stubs — does NOT reflect the parts already `\leanok`-eligible | migrate existing content + ship closures + define point predicate |
| L2 | not started | `L2.tex` 1 `\notready` stub | predicate `IsGLComputable` (deferred) |
| L3 | typeclass formalized (0 sorries) | `L3.tex` 1 `\notready` stub — does NOT reflect the `\leanok`-eligible parts | migration (deferred) + stability theorem |
| L4 | CMap stub (def + instance sorry-free; A1/A2/A3 theorem-body sorries) | `L4.tex` 3 `\notready` stubs | close A1 (needs L1 closures first) |
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
- `lake build`: 1 sorry-warning at `ComputableAnalysis/L4/Instances/CMap.lean:261:23`, `Build completed successfully`.
- `leanblueprint web`: produces `blueprint/web/` with no plasTeX errors.
- `leanblueprint checkdecls`: exit 0, no output.
- Recent workflow runs: most recent should be `completed` `success`.

If `checkdecls` reports unresolved decls, a `\lean{...}` macro in `blueprint/src/*.tex` points at something the Lean project doesn't export. Fix the macro target name, don't add a sorry-bearing Lean decl just to make the check pass.

### Action 2 — recommended direction: L1 closures, blueprint-native

**Why this and not L4 A1 directly:** A1 under the polynomial form needs three more closure helpers (`_mul`/`_reindex`/`_finsetSum`) plus ~50 lines of witness assembly. The prior `l4-cmap-axiom-linearity` round (2026-06-02, budget-exhausted at 5/6 iters / ~198 min) shipped one helper. Continuing in L4 with the helpers inline adds technical debt (they belong in L1). Better: open a round dedicated to L1 closures (proper home), then resume L4 A1 with the toolkit ready.

**Why blueprint-native:** every new L1 lemma is a candidate green node in the dep graph. Adding the LaTeX entry at the same time the Lean lemma lands keeps the graph honest. The adapted `/formalize` skill Phase 6 makes this nearly free (one extra `\lean{...}\leanok` toggle per lemma).

Suggested round setup:

- **Slug**: `l1-arithmetic-closure-and-real`
- **Mode**: `proof-attempt`
- **Budget**: **14 iters / 240 min** (calibrated from prior round: ~5 iters per closure helper × 3 helpers + 1 migration iter + 2 IsComputableReal iters + 3 iters slack)
- **Allow_writes**:
  - `ComputableAnalysis/L1/**`
  - `ComputableAnalysis/L4/Instances/CMap.lean` (to lift `_add` and remove its TODO comment)
  - `blueprint/src/L1.tex` (the chapter file — replace `\notready` stubs with the now-`\leanok` content)
  - `claims/l1-computable-reals/**` (convert the pre-existing claim file to satellite format)
  - `claims/l1-arithmetic-closure-and-real/**` (new rationale satellites)
  - `CLAUDE.md` (only the "Corpus ingestion" table if new chapters get ingested; no other section)
  - `.goals/l1-arithmetic-closure-and-real/**`, `.goals/INDEX.md`
  - `thinking/l1-arithmetic-closure-and-real/**`
  - `docs/NEXT-SESSION.md` (refresh at round end)
- **Forbid_writes**:
  - `ComputableAnalysis/L0/**`, `ComputableAnalysis/L3/**`, `ComputableAnalysis.lean`
  - `blueprint/src/{content,L0,L2,L3,L4,L5}.tex` (only L1.tex changes)
  - `blueprint/src/{blueprint.sty,plastex.cfg,latexmkrc}.tex` and `blueprint/src/macros/**` (scaffold; do not touch)
  - `literature/papers/**/verbatim.md`
  - `.claude/commands/**` (skills are stable)
  - `.github/workflows/**`, `lakefile.toml`, `lake-manifest.json`, `lean-toolchain`
- **Criteria** (each phrased to be machine-checkable; some target blueprint labels):
  - **C1**: `lake build` green; only residual sorry-warning is `ComputableAnalysis/L4/Instances/CMap.lean:261:23`. `leanblueprint checkdecls` exits 0.
  - **C2** (*migration*): `blueprint/src/L1.tex` has `\lean{...}\leanok` for every L1 declaration currently in `ComputableAnalysis/L1/ComputableSeqReal.lean` (the existing predicate + every helper lemma already done at 0 sorries). The two `\notready` stubs in L1.tex (`def:l1_isComputableSeqReal`, `def:l1_isComputableReal`) are replaced or extended to reflect actual state. Visual: `def:l1_isComputableSeqReal` node is green in the dep graph after Action 1 reruns.
  - **C3** (*lift*): `isComputableSeqRat_add` lifted from `ComputableAnalysis/L4/Instances/CMap.lean` to `ComputableAnalysis/L1/ComputableSeqReal.lean` (or a new `ComputableAnalysis/L1/RatClosure.lean`) under its proper public name; CMap.lean references the L1 version via the qualified name. The L4 TODO comment removed. Blueprint label `lem:isComputableSeqRat_add` (or similar) goes green.
  - **C4** (*mul*): `isComputableSeqRat_mul` shipped (fully proved). Simpler sibling of `_add` — sign XOR, no truncated-subtraction bookkeeping. Blueprint label `lem:isComputableSeqRat_mul` goes green.
  - **C5** (*reindex or finsetSum*): at least one of `isComputableSeqRat_reindex` or `isComputableSeqRat_finsetSum` shipped (whichever lands first). Blueprint label goes green.
  - **C6** (*point predicate*): `IsComputableReal : ℝ → Prop` defined in `ComputableAnalysis/L1/ComputableReal.lean` (or appended to ComputableSeqReal.lean) — ~1-line def + 1-2 sanity lemmas, P-R Ch. 0:55 citation in docstring. Blueprint label `def:l1_isComputableReal` goes green.
  - **C7** (*satellite*): pre-existing `claims/l1-computable-reals/is-computable-seq-real.md` converted to satellite format per `claims/TEMPLATE.md` (post-2026-06-02): formal statement removed (now in blueprint LaTeX); YAML `status:` field dropped; `blueprint:` field added pointing at the matching `\label`; `[[blueprint:...]]` pointer at top of body. Rationale prose preserved.

**Devil's-advocate required for**: C3 (the lift — easy to get the public name + namespace wrong), C6 (the point-predicate definition — high blast radius, see CLAUDE.md commitments #2-#3).

### Action 3 — alternative directions (if user opens with a different request)

- **Resume L4 A1 directly**: slug `l4-cmap-axiom-linearity-cont`, mode `proof-attempt`, 6 iters / 180 min. Risks repeating the prior round's budget overrun; doesn't migrate L1 content to blueprint. Allow_writes same as Action 2 PLUS L4.
- **Just define `IsComputableReal`** (narrow): slug `l1-is-computable-real`, mode `explore`, 6 iters / 90 min. Closes one L1 pending milestone in isolation; doesn't unblock L4. Useful if the L1 closure round feels too large.
- **L3 stability theorem**: slug `l3-stability`, mode `proof-attempt`, 8 iters / 150 min. P-R Ch. 2.3 — uniqueness of the computability structure under mild side conditions. The keystone result that vindicates the typeclass choice; high-leverage but no immediate dependency on L1/L4. Could go in parallel with someone else's L1 work.
- **Zulip outreach with live blueprint**: slug `zulip-l0-l3-pitches`, mode `explore`, 3 iters / 60 min (mostly conversation with the user). The L0 + L3 pitches at `docs/zulip-drafts/2026-06-01-l0-pitch.md` + `2026-06-01-l3-pitch.md` are still drafted. With Pages live we can now embed dep-graph links. Recommend waiting until L1 chapter has at least 5-7 green nodes so the blueprint visibly justifies the pitch.
- **Migrate L3 claim file to satellite** (housekeeping): 1-2 iter mechanical migration of `claims/l3-computability-structure/axioms.md`. Low-stakes; can ride along with any other round.

## Critical knowledge — the blueprint stack (NEW since prior NEXT-SESSION.md)

| Concept | Where | Note |
|---|---|---|
| Blueprint CLI | `.venv/bin/leanblueprint` | Always prefix with `PATH="$PWD/.venv/bin:$PATH"` so the CLI's shell-out to `plastex` resolves. |
| Blueprint sources | `blueprint/src/{content,L0..L5}.tex` | `content.tex` is the dispatcher (`\input{L0}…\input{L5}`). |
| Decl list | `blueprint/lean_decls` | Regenerated by `leanblueprint web`. `lake exe checkdecls blueprint/lean_decls` runs the validation. |
| Macros | `blueprint/src/macros/{common,web,print}.tex` | `theorem`/`proposition`/`lemma`/`corollary`/`definition`/`remark` envs are defined here. Do not modify the scaffold structure; ADD envs by editing common.tex if a new one is needed. |
| Dep graph | `blueprint/web/dep_graph_document.html` | Open via local server: `cd blueprint/web && python3 -m http.server 8765` then `http://localhost:8765/dep_graph_document.html`. `file://` blocks Web Workers; localhost works. |
| GHA workflows | `.github/workflows/{blueprint,docs}.yml` | Split into fast (every push, ~5 min, blueprint only) and slow (on tags, ~20 min, blueprint + Mathlib-linked API docs). Both deploy to Pages. Full rationale: `docs/CI.md`. `lint: false` + `mk_all-check: false` in the fast path (no Mathlib lint_driver declared; deferred until pre-upstream readiness). |
| Pages URL | `https://yssnbkd.github.io/mathlib4-computable-analysis/blueprint/` | Live after first successful workflow run + Pages deploy. |

## Critical knowledge — Mathlib symbols (carried from prior round)

These were verified against Mathlib master 2026-06-02 in the prior round and are load-bearing for the L1 closure work:

| Concept | Exact symbol | Import / location | Note |
|---|---|---|---|
| `Primrec.nat_add/sub/mul/le` | as named | `Mathlib/Computability/Primrec/Basic.lean:593,596,599,610` | ℕ-level arithmetic. `nat_sub` is **truncated** (0 if negative). |
| `Primrec.nat_mod / nat_bodd` | both | `Mathlib/Computability/Primrec/Basic.lean:728,733` | `nat_bodd` returns `Bool`; prefer over `% 2` when the result needs to be Computable. |
| `Primrec.ite / .cond` | both | `Mathlib/Computability/Primrec/Basic.lean:602,606` | `.cond` is `Bool`-conditional; `.ite` is `Prop`-conditional with `[DecidablePred c]`. |
| `Computable.cond` | yes | `Mathlib/Computability/Partrec.lean:594` | `cond hc hf hg : Computable (fun a => bif (c a) then (f a) else (g a))`. |
| `Computable₂.comp` | yes | `Mathlib/Computability/Partrec.lean:477` | Takes **two separate** `Computable` args, NOT a paired one. |
| `Primrec₂.to_comp` | yes | `Mathlib/Computability/Partrec.lean:252` | Lifts `Primrec₂` to `Computable₂`. Use as `Primrec.nat_mul.to_comp.comp hb₁ hb₂`. |
| `PrimrecRel.decide` | yes | `Mathlib/Computability/Primrec/Basic.lean:426` | Converts `PrimrecRel R` to `Primrec₂ (fun a b => decide (R a b))`. Use `.swap.decide` to flip arg order. |
| `Primcodable ℤ/ℚ` | auto (via `Denumerable`) | `Mathlib/Computability/Primrec/Basic.lean:139` | **No Mathlib-exported `Primrec₂` for ℤ/ℚ arithmetic**; build at the ℕ-level via sign-num-den decomposition. |

## Critical knowledge — Lean idioms that worked in `_add`

These patterns proved out in `isComputableSeqRat_add`; copy them for `_mul`/`_reindex`/`_finsetSum`:

### Computable composition pattern

```lean
have hp₁ : Computable (fun k => a₁ k * b₂ k) :=
  Primrec.nat_mul.to_comp.comp ha₁ hb₂
```

`Primrec.nat_mul` is `Primrec₂`. `.to_comp` lifts to `Computable₂`. `Computable₂.comp ha₁ hb₂` takes **two separate** `Computable` args. **NOT** `(ha₁.pair hb₂)`.

### Computable conditional pattern

For `fun k => if (Prop predicate on k) then X else Y`:

```lean
have hge : Computable (fun k => decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)) := by
  have : Primrec₂ (fun p q : ℕ => decide (p ≥ q)) := Primrec.nat_le.swap.decide
  exact this.to_comp.comp hp₁ hp₂
have htotal := Computable.cond hge hX hY
-- htotal is in `cond` form. Convert to `ite`:
refine htotal.of_eq fun k => ?_
by_cases h : (predicate)
· simp [h]
· simp [h]
```

### `(-1 : ℚ)^n` parity reduction

```lean
have pow_red : ∀ n : ℕ, (-1 : ℚ) ^ n = (-1) ^ (n % 2) := by
  intro n
  conv_lhs => rw [← Nat.div_add_mod n 2, pow_add, pow_mul]
  simp
```

After this, `pow_red (s k)` rewrites `(-1)^(s k)` to `(-1)^(s k % 2)`. Combine with `rcases Nat.mod_two_eq_zero_or_one (s k) with h | h` for case analysis.

### Ring identity with truncated ℕ-subtraction

```lean
rw [Nat.cast_sub hle]   -- ↑(a - b) → ↑a - ↑b when h : b ≤ a in ℕ
push_cast                -- distribute remaining ℕ-casts
field_simp               -- clear denominators with available `hb : (b : ℚ) ≠ 0`
try ring                 -- `try` because field_simp may already close the goal
```

The `try ring` is essential — `field_simp` closes some cases entirely; bare `ring` would error "No goals to be solved".

## Watchpoints — don't repeat past mistakes

- **DON'T trust prior-session "no new L1 lemmas needed" claims** without re-checking the actual L1 file's `## What this file is NOT` section. The l4-cmap-axiom-linearity round discovered the L1 arithmetic closure gap the hard way.
- **DON'T attempt to derive `Primrec₂.rat_add` / `int_add` from scratch.** The ℕ-level sign-num-den approach is shorter and is the project's established idiom.
- **DON'T `rw` patterns that appear on both sides of the goal** expecting it to rewrite only one. Use `conv_lhs` / `conv_rhs` / `nth_rewrite` to target.
- **DON'T commit Lean files with new sorry-warnings just to "show structure".** Either prove fully or leave the draft in `thinking/`. New sorry-warnings break the project's "1 sorry-warning at the L4 instance level" invariant and hide the blueprint `\leanok` consistency check.
- **DON'T set `\leanok` on a blueprint env whose `\lean{decl}` target has `sorry` in its proof body.** This is a hard rule in CLAUDE.md `## sorry policy`. `#print axioms <decl>` showing `sorryAx` is a refusal.
- **DON'T set proof-attempt iter budgets below what the prior round took for similar work.** The 6 iters / 120 min limit for closure proofs was off by ~2-3×. Calibration: 14 iters / 240 min for the L1 round.
- **DON'T edit `blueprint/src/` files beyond the layer you're working on.** The `\input` order in `content.tex` is fixed; other chapter files belong to other rounds.
- **DON'T touch `.claude/commands/**` or `.github/workflows/**`** — those are the workflow scaffold; modifications require their own dedicated round.

## User calibration

Technically capable; explicit authorization for bold changes. Defers on Zulip posting / commits / PRs / scope changes. Each commit needs an explicit "yes" from them; never assume. After approval, batch related changes into one or two reviewable commits with HEREDOC commit messages ending in `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`.

## Files to know

- `CLAUDE.md` — slim constitution. Read first.
- `docs/SETUP.md` — Lean install + first build (post-hoist, runs from repo root).
- `docs/NEXT-SESSION.md` — this file.
- `ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` — L0, **done**, all blueprint nodes green.
- `ComputableAnalysis/L1/ComputableSeqReal.lean` — L1 `IsComputableSeqRat`/`IsComputableSeqReal`, **done** (0 sorries). NB: explicit "What this file is NOT" section at lines 56-64 lists arithmetic closure as deferred — that gap is what the next round closes.
- `ComputableAnalysis/L3/ComputabilityStructure.lean` — **L3 keystone, formalized** (0 sorries).
- `ComputableAnalysis/L4/Instances/CMap.lean` — **L4 first instance, stub** (def + instance sorry-free; A1/A2/A3 theorem-body sorries at line 261). Carries `private theorem isComputableSeqRat_add` (~80 lines, fully proved) inline at top — the candidate lift target for Action 2 C3, marked `TODO(refactor → L1):`.
- `ComputableAnalysis.lean` — umbrella import. **Don't edit during the L1 round** (it's in forbid_writes); the L1 file is already imported.
- `blueprint/src/{content,L0,L1,L2,L3,L4,L5}.tex` — blueprint chapters. **L1.tex is the editable target for this round.**
- `blueprint/src/macros/common.tex` — theorem-env defs. Add a `\newtheorem{remark}` style only if a new env is needed.
- `blueprint/lean_decls` — declaration list (auto-regenerated). Cited by `lake exe checkdecls`.
- `blueprint/web/` — local-build output. `.gitignored`; rebuild with `leanblueprint web`.
- `claims/INDEX.md` + `claims/TEMPLATE.md` — post-2026-06-02 satellite convention. Read before writing new claim files.
- `claims/l1-computable-reals/is-computable-seq-real.md` — legacy claim file; gets migrated to satellite under Action 2 C7.
- `claims/l3-computability-structure/axioms.md` — legacy claim file; migration deferred to a future L3 round.
- `literature/papers/PourEl-Richards-*.md` — per-chapter verbatim extracts (P-R 1989).
- `.goals/l4-cmap-axiom-linearity/final.md` — prior round (budget-exhausted, 5/6 iters / ~198 min). The `_add` shipped there; A1 still sorry.
- `.goals/INDEX.md` — registry of all past rounds.
- `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` — full paper-form A1 proof + verbatim P-R citations (still load-bearing for the eventual A1 round).
- `docs/zulip-drafts/{2026-06-01-l0-pitch,2026-06-01-l3-pitch,2026-06-01b-decision}.md` — drafts (still deferred; would be updated to link the live blueprint).

## If the user types something different

The above task list assumes default continuation. If the user opens with a different request (e.g., "let's resume L4 A1 directly anyway", "let's start L2 instead", "let's actually post the Zulip pitches with the new blueprint URL"), follow their direction — this prompt is a *default*, not a script.

---

*End of prompt.*
