# Prompt for next session

> *Paste this as the opening message in the next conversation. It is self-contained;
> you do not need prior transcripts.* This is a **default** — if the user opens with a
> different request, follow their direction.

---

You are continuing work on **mathlib-computable-analysis**, a Lean 4 / Mathlib4
formalization of Pour-El & Richards' *Computability in Analysis and Physics* (Cambridge
UP 1989), targeting upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root:
`/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. **Read `CLAUDE.md`
first** — it is the project constitution. The deliverable is **Lean code**; the
type-checker is the final arbiter.

## What just happened (2026-06-05 — round `l4-cmap-axiom3-norm-resig` wraps)

The active `/goal` round `l4-cmap-axiom3-norm-resig` closed **A3** (sup-norm
computability for `C[α, β]`) **fully sorry-free**. With A1 and A2 already
closed in earlier rounds, the entire `computabilityStructureCMap_of` instance
is now sorry-free.

Concretely, this conversation drove iter-10:

1. **A3 body (`isComputableSeqCMap_norm`)** filled via the three-error
   decomposition (P-R chapt0:984-1012):
   - **(a) Polynomial-approximation**: `|‖p‖ − ‖f_n‖| ≤ 1/2^K` via `herr`.
   - **(b1) Clamp**: `(sNK : ℝ) ≤ ‖p‖ + 1/2^K` via `Set.projIcc` clamping +
     `polyEval_lipschitz_real` + `ContinuousMap.norm_coe_le_norm`.
   - **(b2) Cover**: `‖p‖ ≤ (sNK : ℝ) + 2/2^K` via
     `ContinuousMap.norm_le` reduction + per-point Lipschitz to the grid.
     Case-splits on `α' < β'` (floor-cover) vs `α' ≥ β'` (degenerate,
     midpoint case-split).
   - **Combine** via `abs_le` → `|sNK − ‖f_n‖| ≤ 3/2^K ≤ 1/2^k ≤ 1/2^N`.
2. **Moduli tightened**: `m_mod := Lip + N + 3`, `k_grid := 8·Lip·(B+1)·2^N + 1`
   (small adjustment from iter-09; DA review notes `+3` is overkill but harmless).
3. **`computabilityStructureCMap_of`** takes six hypotheses
   `(B) (hα_le) (hβ_le) (hα_c) (hβ_c) (hαβ)` (matching A3); fully sorry-free.
4. **Blueprint**: `lem:l4_cmap_axiom3` and `thm:l4_cmap_instance` promoted to
   `\leanok` on both statement and proof; `lem:l1_isComputableSeqReal_of_effectiveConvergence`
   added; both `leanblueprint checkdecls` and `leanblueprint web` exit 0.
5. **DA review** on three-error decomposition: `verdict: passes` (see
   `.goals/l4-cmap-axiom3-norm-resig/reviews/C5.md`).

## Current state (post-session, as of 2026-06-05)

| Layer | Lean state | Blueprint |
|---|---|---|
| L0 | done, 0 sorry | `L0.tex` — 12 nodes `\leanok` |
| L1 | rational closures + real-point predicate + Prop 1 sorry-free | `L1.tex` — 14+ `\leanok` |
| L2 | not started | `L2.tex` — 1 `\notready` stub |
| L3 | `ComputabilityStructure` typeclass sorry-free | `L3.tex` — 1 `\leanok` def |
| L4 | **C[a,b] FULLY sorry-free** — A1, A2, A3 + structure all closed; Lᵖ / Hilbert not started | `L4.tex` — `lem:l4_cmap_axiom{1,2,3}` all `\leanok`; `thm:l4_cmap_instance` `\leanok`; Lᵖ/Hilbert `\notready` |
| L5 | not started | `L5.tex` — 4 `\notready` stubs |

- **HEAD** unchanged this conversation (no commit was made; user's preference).
  All work is in working tree.
- Repo-wide `sorry` count: **0** (modulo docstring-quoted occurrences).
- `lake build` green; no errors; no sorry-warnings; 6 push_neg deprecation warnings.
- Round criteria C1-C8 met; C9 (docs) in progress (this file is the C9 update).

## Recommended next action — `/goal-end` then choose next round

The active round has all proof-mathematical criteria met (C1-C8). To formally
close, first run `/goal-end` to archive the round to `.goals/<slug>/`. Then
choose one of three high-value next directions:

### Option A — Zulip outreach (recommended; ~30 min)

The project has reached a credible inflection point: L0, L1, L3, and the full
L4 C[a,b] instance are sorry-free under the kernel axioms only. This is the
right moment to engage Mathlib4 reviewers on Zulip's `#new contributors` or
`#Mathlib4` streams. **The user posts** — not Claude. The asker would draft
the 3-paragraph note:
- ¶1: project pitch (P-R formalization, predicate-first, substrate =
  Mathlib `Computable`/`Partrec`).
- ¶2: progress (L0-L4 sup-norm done; reference blueprint URL).
- ¶3: ask for feedback on the predicate-first architecture vs
  represented-spaces (Pauly/Brattka).

Record the thread under `docs/zulip-threads.md`.

### Option B — `/goal` round on **L2** (Grzegorczyk-Lacombe; ~10-20 iters)

Open a new `/goal` round `l2-grzegorczyk-lacombe` targeting P-R Ch. 0 §3 + Ch. 1.
L2 is the computable-continuous-function layer:
- Definition: `IsGLComputable : C(ℝ, ℝ) → Prop` matching P-R Ch. 0:1042
  (rational sequence with effective uniform continuity modulus).
- Closure: composition, sum, product, scalar multiplication.
- **Hook to L4**: `IsGLComputable f → IsComputableSeqCMap (fun _ => f)` for any
  `Set.Icc α β` (constant sequence ↦ singleton-precision approximation).

L2 unlocks integration / differentiation theorems in P-R Ch. 1.

### Option C — `/goal` round on **L4 Lᵖ** (~15-25 iters)

Open `l4-lp-instance` targeting `ComputabilityStructure ℝ (L^p[a,b])` for
`1 ≤ p < ∞`. P-R Ch. 2:146. Construction: rational-step-function
approximants with effective Lᵖ-convergence modulus. Requires L1 + measure
theory bridge (Mathlib's `MeasureTheory.LpSpace`).

Significantly harder than the C[a,b] instance — the polynomial-approximation
machinery doesn't carry over (Weierstrass approximation in Lᵖ is different).
Recommend Option B (L2) first.

## Round parameters (for the closed round)

- slug: `l4-cmap-axiom3-norm-resig` (CLOSED — all C1-C8 met; C9 in progress)
- mode: `proof-attempt`
- max_iterations: 100 (10 used; 90 remaining if reopened)
- time_budget_minutes: 3600 (within budget)
- DA scope: C5 verdict `passes`.

## Quick handoff checklist (run in order at session start)

1. `lake build 2>&1 | tail -10` — expect 0 errors, 0 sorry-warnings, only
   `push_neg` deprecation warnings.
2. `grep -rn "sorry" ComputableAnalysis/ --include="*.lean" | grep -v "^\s*--"` —
   expect 0 hits.
3. `#print axioms ComputableAnalysis.L4.computabilityStructureCMap_of` —
   expect `[propext, Classical.choice, Quot.sound]`.
4. `cat current-goal.md` to confirm round status; if all criteria green, run
   `/goal-end` to archive.

## Parallel-agent dispatch lessons (still applies)

From prior rounds:
1. Uncommitted main state does NOT propagate to worktrees.
2. 3-way merge for non-conflicting parallel branches works.
3. Honest agent self-evaluation matters.

## Hard guardrails (unchanged)

- **Every agent must run on the `claude-opus-4-8` model** (Agent tool's `model: "opus"`
  resolves to the latest Opus — satisfies the spirit).
- **Never commit unless the user explicitly asks.** `git push` is denied in settings.
- **Sorry policy** (`CLAUDE.md`): `sorry` allowed only in theorem/lemma bodies, each
  with a `-- TODO(/formalize L<N>):` comment.
- **Do not author L5/L2 theorem statements (or any P-R citation) from memory.** Grep
  the literature and verify verbatim first.
- **`\leanok`/`\mathlibok` only on decls with no transitive `sorry`** — the standalone
  `#print axioms` recipe in `docs/PITFALLS.md §7` is the canonical sorry-audit.
- **Read `docs/PITFALLS.md` + `docs/LEAN-IDIOMS.md`** before opening a new L-layer
  round.

## Verification pipeline (run in order)

1. `lake build 2>&1 | tail -5` — expect 0 errors and 0 sorries.
2. `python3 -c "[print(p,i) for p in ['<file>'] for i,l in enumerate(open(p,encoding='utf-8'),1) if len(l.rstrip(chr(10)))>100]"`
   — no line >100 codepoints on `.lean` files (count codepoints, not bytes).
3. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web 2>&1 | tail -5` — exit 0.
4. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls; echo "exit: $?"` —
   exit 0.

---

*End of prompt.*
