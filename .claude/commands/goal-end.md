---
description: End the active /goal round. Writes a final summary, clears current-goal.md, updates the index.
---

End the active `/goal` round.

Do this:

1. Read `current-goal.md`. If empty / no slug → STOP, tell the user nothing is active.
2. Let `<slug>` be the slug from frontmatter.
3. Read all `.goals/<slug>/iter-*.md` files in order and all `.goals/<slug>/reviews/*.md` files.
4. Read the current state of `claims/<slug>/` and `proofs/<slug>/` and `intuition/<slug>.md`.
5. Write `.goals/<slug>/final.md` with this structure:

```markdown
---
slug: <slug>
ended: <ISO 8601 UTC>
iterations: <N>
outcome: success | partial | abandoned | stagnated | budget-exhausted
---

# Final summary for goal: <one-line>

## Criteria status
- [x] C1: <was met — pointer to artifact>
- [ ] C2: <was NOT met — why>
...

## Artifacts produced
- intuition/<slug>.md: <summary of changes>
- claims/<slug>/<id>.md: <one-line each, with status>
- proofs/<slug>/<claim-id>/attempt-NN.md: <verdict>
- thinking/<slug>/<date>-<slug>.md: <if any>

## Devil's-advocate verdicts
<table or list of every review: artifact, verdict, key weakness if any>

## Key findings
<3–8 bullets — what we learned, what is now believed, what is now refuted>

## Open questions
<bullets — what remains, ranked by importance>

## Next-step recommendations
<2–4 concrete next moves: a new goal, a needed literature search, a needed formalization>
```

6. Update `.goals/INDEX.md` for the slug: status -> outcome, iterations -> N.
7. Replace `current-goal.md` with the empty template (no slug). The empty template is:

```markdown
---
slug:
started:
mode:
max_iterations:
time_budget_minutes:
allow_writes:
forbid_writes:
devils_advocate_required_for:
---

# Goal: (none active)

No active goal. Run `/goal <slug>` to start one.
```

8. Suggest to the user the next-step recommendations and ask which to act on.
