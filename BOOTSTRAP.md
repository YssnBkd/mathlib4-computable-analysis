# BOOTSTRAP.md — what to load at session start

Read this file first. It tells you what to load into your context for the active research state. The Opus 4.7 1M-context window can hold all of it; the point of this file is to load it **deliberately and in order**, not exhaustively.

## Always load (every session)

1. `CLAUDE.md` — operating protocol, status taxonomy, rules.
2. `current-goal.md` — if non-empty, the active `/goal` and its success criteria.
3. `.goals/INDEX.md` — registry of past / completed / abandoned goals.

## If `current-goal.md` is non-empty

Let `<slug>` be the active goal slug, and `<topic>` the topic it works on (typically the same).

4. `intuition/<topic>.md` — the seed mental model.
5. `.goals/<slug>/goal.md` — the original goal snapshot.
6. The **last 3** iteration logs: `.goals/<slug>/iter-{N-2,N-1,N}.md`.
7. Any `.goals/<slug>/reviews/*.md` — past devil's-advocate verdicts.
8. All claims under `claims/<topic>/` — current formal-statement state.
9. Recent attempts: latest file in each `proofs/<topic>/<claim-id>/` directory.
10. The most recent `thinking/<topic>/*.md` (if any) — preserved reasoning.
11. **The Lean target file(s) for the active milestone**: `ComputableAnalysis/L<N>/<artifact>.lean` — when a Lean-criterion /goal is open, this shows the current type-checking state. Run `lake build` (from repo root) to verify before marking a Lean criterion done. The path is in the claim file's `lean_target` frontmatter field (Architectural commitment #6).

## On demand (when relevant)

12. `literature/INDEX.md` and `literature/papers/<key>/verbatim.md` — only fetch when actually citing.
13. `raw_papers/<key>/` PDFs — only when verbatim.md is insufficient and the source is needed.
14. Other topic threads under `intuition/`, `claims/`, `proofs/` — when cross-thread connections matter.

## What NOT to load by default

- All of `literature/` (it grows; load specific papers on demand).
- All of `archive/` (session JSONL files; only inspected during `/record`).
- All of `thinking/` for unrelated topics (anchors reasoning on prior threads).

## When a Lean target is in scope — use `/formalize`

If the active `/goal` has a Lean criterion (a claim with `lean_target: ComputableAnalysis/L<N>/...` whose target file does not yet type-check), invoke `/formalize <claim-id>` rather than hand-rolling Lean code. The skill:

1. Runs `scripts/formalize_env_check.py` (watermark-cached env preflight).
2. Loads the PhD-prodigy persona from `.claude/templates/lean-prodigy-persona.md`.
3. Has on-demand access to `.claude/templates/lean-toolkit.md` (search engines, tactic ladder, Mathlib naming bible, computable-analysis area map).
4. Stubs the Lean file with `sorry`-free definitions and theorems-with-sorry, then iterates fills under the three-attempt rule.
5. Hands off to `/devils-advocate` for paper + Lean review (CLAUDE.md §"Devil's-advocate review under Lean").

First-time setup (only once per machine): `python3 scripts/formalize_env_check.py --init` scaffolds `lakefile.toml`, `lean-toolchain`, `ComputableAnalysis.lean` at git root. After that, `lake update && lake exe cache get && lake build` populates the watermark.

## Sanity check before starting work

After loading, you should be able to answer:
- What is the active goal? (or "no active goal")
- What criteria are unmet?
- What was the last delta — what changed in the previous iteration?
- What devil's-advocate verdicts are outstanding?
- Which claims are `conjecture`-status and depend on each other?

If any of these are unclear, re-read the relevant file before proceeding.
