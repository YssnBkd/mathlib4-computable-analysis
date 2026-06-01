---
description: Start a /goal autonomous-iteration round. Instantiates current-goal.md and the .goals/<slug>/ tree.
argument-hint: <topic-slug>
---

The user is starting a `/goal` autonomous iteration round on slug `$ARGUMENTS`.

Do this:

1. If `current-goal.md` is non-empty (has a slug set), STOP and tell the user a goal is already active. Suggest `/goal-end` first.
2. Pick the slug from `$ARGUMENTS` (kebab-case). Use the same slug as the related `intuition/<slug>.md` if one exists.
3. Confirm with the user, asking them to choose:
   - **mode**: `explore` | `lit-search` | `conjecture-test` | `proof-attempt`
   - **max_iterations** (default 12; proof-attempt caps at 6)
   - **time_budget_minutes** (default 90)
   - **success criteria** (3–6 lines, each starting with `C1:`, `C2:`, ... — make each as machine-checkable as possible)
   - which criteria require **devil's-advocate review** before being marked done (default: all conjectures and all proof steps; never required for `lit-search` mode unless explicit)
   - **allow_writes** globs (default: `intuition/<slug>.md`, `thinking/<slug>/**`, `claims/<slug>/**`, `proofs/<slug>/**`, `.goals/<slug>/**`)
   - **forbid_writes** globs (default: `claims/**` outside the active topic, `literature/papers/**/verbatim.md`, `raw_papers/**`)
4. Write `current-goal.md` with the chosen frontmatter and criteria. Use this template:

```markdown
---
slug: <slug>
started: <ISO 8601 UTC, e.g. 2026-05-20T16:30:00Z>
mode: <explore|lit-search|conjecture-test|proof-attempt>
max_iterations: <N>
time_budget_minutes: <M>
allow_writes:
  - <glob>
  - ...
forbid_writes:
  - <glob>
  - ...
devils_advocate_required_for:
  - "<criterion id>"
  - ...
---

# Goal: <one-line statement>

## Why this matters
<2–3 sentences; link to intuition/<slug>.md>

## Success criteria
- [ ] C1: <statement>
- [ ] C2: <statement>
- ...

## Hard stops
- Any write outside allow_writes or matching forbid_writes
- ≥3 iterations with identical unmet criteria
- Devil's-advocate verdict `unsound` on any committed claim
- iter ≥ max_iterations or elapsed ≥ time_budget_minutes
```

5. Copy the new `current-goal.md` to `.goals/<slug>/goal.md` (snapshot).
6. Write `.goals/<slug>/iter-00.md` with: `timestamp`, `unmet: [C1, C2, ...]`, `mode`, `files_changed: []`, `note: goal started`.
7. Append a row to `.goals/INDEX.md`: `| <slug> | started | <date> | 0/<max> | <mode> |`.
8. Tell the user the goal is active and the Stop hook will drive iteration. Remind them: the first prompt should be a directive like "Begin. Work toward the goal. Invoke `/devils-advocate` on every committed claim. Stop when criteria are met or budget exhausted."
