---
description: Invoke the devil's-advocate subagent on a criterion id or an artifact path. Writes verdict to .goals/<slug>/reviews/<id>.md.
argument-hint: <criterion-id-or-path>
---

Invoke the `devils-advocate` subagent for adversarial review.

Argument: `$ARGUMENTS` is either:
- A criterion id like `C3` (refers to a criterion in `current-goal.md`), OR
- A path to a specific artifact (`claims/<topic>/<id>.md`, `proofs/<topic>/<claim-id>/attempt-NN.md`).

Do this:

1. If `$ARGUMENTS` looks like a criterion id (matches `^[A-Z]\d+$`):
   - Read `current-goal.md`. Find the criterion line `- [ ] <id>: <text>`.
   - From the text, identify which artifact the criterion refers to. If unambiguous, that is the review target. If ambiguous, ASK the user which artifact to review.
   - Read the active goal slug from frontmatter.
2. Otherwise, treat `$ARGUMENTS` as a path. The active slug (if any) comes from `current-goal.md`.
3. Spawn the `devils-advocate` subagent with:
   - The target artifact path.
   - The criterion id (if applicable).
   - The active slug (for the output location).
4. The subagent will produce a structured review.
5. Write the review to `.goals/<slug>/reviews/<criterion-id-or-artifact-slug>.md` (use criterion id if there is one; otherwise derive a filename from the artifact path).
6. Report the verdict to the user.
7. If verdict is `passes` AND there is an associated criterion in `current-goal.md` AND the user wants to mark it done — flip `- [ ]` to `- [x]` for that criterion. Otherwise leave it.

**Hard rule**: do NOT mark a criterion done unless the subagent verdict line is exactly `verdict: passes`. The Stop hook will revert any unauthorized check-mark.
