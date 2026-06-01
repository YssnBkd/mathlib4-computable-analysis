# RESEARCH-INDEX.md

Cross-goal catalogue for this research environment. **One entry per closed/active goal.** Future `/goal` invocations should consult this file before starting a new stream — to (a) avoid duplicating work, (b) lift a pre-drafted candidate entry, and (c) know which papers are already in the shared corpus.

Entry-point overview (in evaluation order for a session):

1. **`current-goal.md`** at repo root — is a goal active right now?
2. **This file** (`RESEARCH-INDEX.md`) — what's the closed-goal context, and are there draft candidates for the new direction?
3. **`.goals/INDEX.md`** — table of all goals with status/dates/iters.
4. **`literature/INDEX.md`** — paper corpus (shared across goals).
5. **`intuition/INDEX.md`** — registry of intuition threads by slug.
6. **`claims/INDEX.md`** — registry of formal claims by slug.
7. **`README.md`** — protocol quick-start (read once per session).

---

## Active goal

(none)

Run `/goal "<new statement>"` to start a stream. Pick from "Candidates for future goals" below if your direction matches an existing thread.

---

## Closed goals

(none yet)

---

## Goal-spawning convention

When you start a new `/goal`:

1. **Check this file's "Candidates for future goals" sections** to see if your intended slug already has a draft entry. If yes, lift the entry's "Suggested success criteria" / prerequisites / key references when you respond to the `/goal` skill's AskUserQuestion prompts.
2. **Check `literature/INDEX.md`** to see which papers are already in the shared corpus. The corpus is goal-agnostic — your new goal can cite any extracted paper directly without re-fetching.
3. **Use slug-named namespacing** (`intuition/<slug>/`, `claims/<slug>/`, `proofs/<slug>/`, `.goals/<slug>/`).
4. **Cross-goal claim references** use the claim `id` field (e.g., `topic-something-v2`). `scripts/verify_claims.py` resolves these regardless of which slug they live under. So a new claim in `claims/<new-slug>/` can depend on or cite an existing claim via its id.
5. **When the new goal closes**, add a row to this file (one paragraph statement + key artifacts + new candidates spawned + new papers added to corpus).

---

## Commit message convention

| Commit kind | Prefix | Example |
|---|---|---|
| Iteration within an active goal | `<slug>/iter-NN:` | `my-topic/iter-03: address W3* via Iyer thesis extraction` |
| Goal closure (`/goal-end` aftermath) | `<slug>/close:` | `my-topic/close: final summary + 4 candidate future-goals` |
| Goal scaffolding (`/goal` invocation) | `<slug>/start:` | `my-topic/start: scaffold with 4 success criteria` |
| Cross-goal infrastructure / meta | `meta/<topic>:` | `meta/research-index: stand up RESEARCH-INDEX.md + claims/INDEX.md` |
| Paper-corpus changes shared across goals | `corpus/<bibkey>:` | `corpus/leray-1934: ingest weak-solution-existence paper` |

This enables grep-based history slicing:

- `git log --grep '^<slug>/'` → all commits for that goal.
- `git log --grep '^meta/'` → cross-goal housekeeping.
- `git log --grep '^corpus/'` → paper-corpus changes.
