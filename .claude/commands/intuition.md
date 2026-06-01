---
description: Start a new research thread with prose-first mental model (no formal claims).
argument-hint: <topic-slug>
---

The user is starting a new research thread on the topic `$ARGUMENTS`.

Do this:

1. Pick a kebab-case slug from `$ARGUMENTS` (lowercase, dashes for spaces).
2. If `intuition/<slug>.md` already exists, STOP and tell the user it exists — do not overwrite.
3. Otherwise, create `intuition/<slug>.md` by copying `intuition/TEMPLATE.md` and filling the `<topic>` placeholder.
4. Append a line to `intuition/INDEX.md`: `- [<slug>](<slug>.md) — started <today's date>`.
5. Ask the user to dictate the mental model, or offer to interview them by asking these questions one at a time:
   - "In one paragraph, what is this thread about?"
   - "What is it analogous to that you already understand?"
   - "What would have to be true if this hunch is right?"
   - "What would falsify it?"
   - "What do you not yet know?"
6. As the user answers, fill the corresponding sections of `intuition/<slug>.md`.

**Hard rules** (enforce these):
- Do NOT add `\begin{theorem}`, `\begin{lemma}`, `\begin{proposition}`, or any formal-claim syntax to the intuition file. Formal statements live in `claims/`, not here.
- Do NOT auto-invoke `lit-scout` yet. Intuition first, literature second.
- The file's `**Status**` line must remain `intuition — not a claim, not a proof.`

When done, suggest the user run `/goal <slug>` once they want to start an autonomous iteration round.
