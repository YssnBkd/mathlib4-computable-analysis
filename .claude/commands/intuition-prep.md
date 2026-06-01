---
description: Decompose a raw, multi-thread research intuition into discrete /intuition files, with a guided interview per thread and an audit trail.
argument-hint: [optional raw text — or leave empty and paste it afterward]
---

The user has raw, soup-state research intuition that is **not yet ready for `/intuition`**. It probably contains multiple research threads bundled together, a mix of strong concrete claims and weaker felt associations, cross-domain analogies (math ↔ physics ↔ geometry), hidden load-bearing claims that weren't stated as claims, and possibly imprecise vocabulary that should be preserved rather than sanitized.

Your job: unbundle the soup into discrete threads, interview each, and produce one well-formed `intuition/<slug>.md` per thread, with an audit trail.

# Step 1 — Receive the raw input

If `$ARGUMENTS` is non-empty, use that as the raw input.

Otherwise, say: *"Paste your raw intuition. Don't pre-organize it — bullet points, multiple paragraphs, half-formed analogies, felt associations are all fine. I will decompose it."*

Read it carefully before doing anything else.

# Step 2 — Decompose

Identify the distinct research threads. Each thread = one central mental model. Multiple threads ≠ one big thread.

As you decompose, follow these principles:

1. **Separate strong from weak.** A thread with concrete literature on both sides (e.g., "X-theorem connects to Y-program") is different from a felt association (e.g., "this reminds me of Z but I can't say why"). Both deserve recording, but they get different treatment in the resulting `intuition/` file.

2. **Surface hidden load-bearing claims.** When the user writes "X is essentially Y" or "this stems from the fact that Z" or "as proven by W," those are CLAIMS — not just observations. Tag them as `[needs verification: <one-line restatement>]` so they don't get formalized later without a citation check.

3. **Detect cross-domain frames.** Math ↔ physics ↔ geometry mixing is common in raw intuition. Flag it so the eventual formalization picks a domain or builds a careful translation layer.

4. **Preserve the user's vocabulary.** If they wrote "twist of spacetime," do NOT sanitize to "topological defect." If they wrote "Zeno machine," do NOT promote to "transfinite computation model." Vocabulary preservation captures the mental model and respects the user's actual thinking.

5. **Track felt associations as data.** "I can't explain why X feels like Y" is its own valid input. Don't dismiss it; don't over-explain it; record it honestly.

6. **Flag honest warnings briefly.** If the user's analogy has a physical or mathematical defect (e.g., a physics picture that conflicts with known facts), mention it once and move on. Don't lecture. The intuition's spatial/structural content may still be useful even if the packaging is wrong.

For each candidate thread, write a brief proposal:

```
### Thread <N>: <proposed-slug> (kebab-case)
- **Core claim**: <one line, in the user's vocabulary where possible>
- **Strength**: strong | medium | weak
  - strong = concrete literature on both sides, articulated mechanism
  - medium = specific mental model but mechanism unclear or untraceable
  - weak = felt association, "can't explain why"
- **Hidden load-bearing claims**:
  - [needs verification: <one-line restatement>]
  - ...
- **Honest warnings** (if any): <one line>
- **Domain frames mixed**: <math / physics / geometry / etc.>
```

Then present the decomposition to the user and ask:

*"Are these the right threads? Should any be merged, split, renamed, or dropped? Did I miss anything?"*

**Do not proceed to Step 3 until the user signs off on the thread split.** If they correct you, redo the decomposition.

# Step 3 — Interview per thread

Once threads are confirmed, interview each thread in turn. Announce which thread you're on. For each, ask these questions **one at a time, waiting for the user's answer before asking the next**:

1. *"In one paragraph, what is this thread about?"* — mental model
2. *"What is it analogous to that you already understand? Give at least three."* — analogies
3. *"What would have to be true if this hunch is right? Give at least three."* — entailments
4. *"What would falsify it? Give at least three."* — falsifiers
5. *"What do you not yet know?"* — unknowns

For **weak / felt-association** threads, add one more question:

6. *"Why does this association feel right to you, even if you can't articulate the mechanism? A picture, a phrase, a sensation — anything."* — felt-content

Take notes verbatim. Do **not** paraphrase to sound more rigorous. If the user says "it feels like spacetime is glitching," write "feels like spacetime is glitching" — not "exhibits non-smooth metric behavior."

If the user gives fewer than the minimum count (e.g., only 1 analogy when 3 are asked), prompt once with *"can you stretch for two more, even speculative?"* — then accept what they give.

# Step 4 — Save the decomposition audit trail

Before creating any `intuition/<slug>.md`, write the decomposition itself to:

```
thinking/_unbundled/<YYYY-MM-DD>-<strongest-thread-slug>.md
```

Create the directory if it does not exist.

Structure:

```markdown
# Unbundling trail — <YYYY-MM-DD>

## Raw input
<verbatim copy of the user's original raw text — never sanitized>

## Decomposition
<your thread proposals with strength labels, hidden claims, warnings, domains>

## Interview transcripts
### Thread <N>: <slug>
- mental model: <verbatim user answer>
- analogies: ...
- entailments: ...
- falsifiers: ...
- unknowns: ...

## Threads produced
- intuition/<slug-1>.md (strength: <strong/medium/weak>)
- intuition/<slug-2>.md (...)
- ...

## Threads considered but dropped (if any)
- <name> — reason
```

This is the audit trail. If a thread later needs to be re-decomposed or its origin questioned, this trail makes it recoverable.

# Step 5 — Create the /intuition files

For each confirmed thread, write `intuition/<slug>.md` by filling `intuition/TEMPLATE.md` with the interview answers. The first two lines must be:

```markdown
# <slug-as-title>

**Status**: intuition — not a claim, not a proof.
**Provenance**: created by /intuition-prep on <YYYY-MM-DD> from a multi-thread input. Full decomposition trail at `thinking/_unbundled/<YYYY-MM-DD>-<strongest-slug>.md`.
```

For threads labelled **weak / felt-association**, add a third bold line:

```markdown
**Strength**: felt association — recorded for completeness, not yet a working hypothesis. See "What I don't know yet" for the felt-content notes.
```

In the body:
- Use the user's vocabulary verbatim where possible.
- Convert hidden claims (the `[needs verification]` tags from Step 2) into bullet points under "What would have to be true if this is right" or "What I don't know yet," depending on whether they are entailed or merely suspected.
- Cross-domain frame warnings go in "What I don't know yet" as honest unknowns (e.g., "whether the physics analogy survives a careful translation to the math").

Append a row to `intuition/INDEX.md` per thread:
```
| <slug> | <YYYY-MM-DD> | live | <one-line summary> |
```

# Step 6 — Cross-link siblings

In each new `intuition/<slug>.md`, append to the "Pointers" section:
```
- sibling threads (same /intuition-prep session):
  - intuition references → <other-slug-1>.md — <one-line relation>
  - intuition references → <other-slug-2>.md — <one-line relation>
```

This makes the family of threads navigable from any single file.

# Step 7 — Report and suggest next

Tell the user:
- **Files created**: each `intuition/<slug>.md` and the `thinking/_unbundled/...` trail
- **Strongest thread**: name it; explain why; suggest invoking the `lit-scout` subagent on it as the natural next step
- **Weaker threads**: noted; can be revisited later; nothing more needed now
- **When to run `/goal`**: only after `lit-scout` has surveyed the strongest thread and you have a sense of what verifiable criteria a goal could check

# Hard rules

- **Never write to `claims/`, `proofs/`, `literature/`, or `raw_papers/`.** Intuition stays in `intuition/`. The audit trail goes only to `thinking/_unbundled/`.
- **Never invent threads the user didn't mean.** If unsure whether two fragments are one thread or two, ASK before proposing.
- **Never proceed past Step 2 without explicit user confirmation** of the thread split.
- **Never sanitize the user's vocabulary.** Preservation > rigor at this stage. Rigor comes later via `/claim` and the `formalizer` subagent.
- **Never dismiss a felt association.** Record it as its own thread with `Strength: felt association`.
- **Never let a hidden claim go untagged.** Every "X is essentially Y" / "this stems from Z" gets a `[needs verification]` tag that propagates into the resulting intuition file.
- **Never auto-fire `lit-scout` or `/goal`.** Always end with a *suggestion* to the user. They decide when to escalate.
