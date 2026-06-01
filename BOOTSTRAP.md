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

## On demand (when relevant)

11. `literature/INDEX.md` and `literature/papers/<key>/verbatim.md` — only fetch when actually citing.
12. `raw_papers/<key>/` PDFs — only when verbatim.md is insufficient and the source is needed.
13. Other topic threads under `intuition/`, `claims/`, `proofs/` — when cross-thread connections matter.

## What NOT to load by default

- All of `literature/` (it grows; load specific papers on demand).
- All of `archive/` (session JSONL files; only inspected during `/record`).
- All of `thinking/` for unrelated topics (anchors reasoning on prior threads).

## Sanity check before starting work

After loading, you should be able to answer:
- What is the active goal? (or "no active goal")
- What criteria are unmet?
- What was the last delta — what changed in the previous iteration?
- What devil's-advocate verdicts are outstanding?
- Which claims are `conjecture`-status and depend on each other?

If any of these are unclear, re-read the relevant file before proceeding.
