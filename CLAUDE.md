# CLAUDE.md — operating protocol

This repository is a **research environment** built to use Claude Opus 4.7 (1M context, max extended thinking) under a **/goal autonomous-iteration pattern** driven by Claude Code Stop hooks. The repo enforces an **intuition-first, provenance-first** workflow.

The repo's structure is the protocol: file locations are not suggestions. Treat them as load-bearing.

## What this repo is for

Open-ended research (default flavour: frontier mathematics — but the workflow is domain-agnostic). The intended cadence is:

1. A research thread starts in `intuition/<topic>.md` — informal prose: mental model, analogies, falsification conditions, unknowns. **No formal claims here.**
2. As intuitions sharpen, candidate statements move to `claims/<topic>/<id>.md` — each with a status label and provenance.
3. Proof attempts live in `proofs/<topic>/<claim-id>/attempt-NN.md` — tied to a specific claim id.
4. Literature gets fetched into `raw_papers/<key>/` (canonical) and indexed into `literature/papers/<key>/{meta.json,verbatim.md,notes.md}`.
5. Curated extended-thinking output that's worth preserving lives in `thinking/<topic>/<date>-<slug>.md`.
6. Optional formalization in `formal/` (Lean 4, opt-in per result).

## The status taxonomy (mandatory)

Every claim in `claims/` carries one of these labels in its YAML frontmatter:

| Label | Meaning | Requires |
|---|---|---|
| `intuition` | An informal idea. Not a claim of truth. | Nothing beyond mental model |
| `conjecture` | A precise statement we believe but cannot yet prove. | Formal statement, dependencies |
| `our_construction` | A definition or object we introduce. | Formal statement, motivation |
| `cited_result` | A theorem we are using from the literature. | Source pointer to `literature/papers/<key>/verbatim.md` |
| `verified` | A claim with a complete proof we have audited. | Proof attempt + devil's-advocate verdict `passes` |
| `refuted` | A claim we previously held that has been broken. | The counterexample / argument that refuted it |

A bare statement with no label is a bug. `/verify` enforces this.

## The /goal autonomous pattern

`current-goal.md` at the repo root is the **active research goal**. When non-empty, the Claude Code **Stop hook** at `scripts/goal_stop_hook.py` runs at the end of every Claude turn:

- If success criteria are met → lets Claude stop, surfaces a summary.
- If unmet AND budget remains → re-injects a continuation prompt, Claude continues to the next turn.
- If a forbidden write was made, stagnation is detected, or budget is exhausted → halts.

Goals have a **mode** (`explore`, `lit-search`, `conjecture-test`, `proof-attempt`) that controls how aggressively the hook auto-iterates and whether **devil's-advocate review** is required before a criterion can be marked done. See `current-goal.md` template at the repo root.

A criterion of the form `- [x]` is only honored if (where required by the goal) `.goals/<slug>/reviews/<criterion>.md` exists with verdict `passes`. The hook reverts unauthorized check-marks.

## Subagents

Four specialized subagents (defined in `.claude/agents/`):

- **`devils-advocate`** — runs in an isolated context with access only to the artifact being reviewed. Returns verdict `passes | unsound | unsupported` with weaknesses and (for conjectures) a candidate counterexample.
- **`lit-scout`** — searches arXiv / HAL / Project Euclid / Annals / DOI / Tao's blog / MathOverflow / nLab / Wikipedia for prior art. Returns structured citations only — no editorializing.
- **`formalizer`** — converts informal prose into theorem-form with hypotheses listed and citation-requiring steps flagged.
- **`proof-reviewer`** — line-by-line proof scrutiny.

**The proposer is never the verifier.** Before marking any proof-step or conjecture as established, invoke the matching subagent.

## Rules

1. **Provenance is mandatory.** Every claim in `claims/` and every theorem cited in `proofs/` has a status label and a source pointer. `/verify` catches violations.
2. **Cite from the canonical source, not memory.** A theorem cited from a paper must be verbatim-extracted into `literature/papers/<key>/verbatim.md` first. Re-derivation from memory is forbidden. **Extraction must go through the `verbatim-extract` skill** (full-coverage 2-pass duplicate-extraction with 3-way diff + PDF-visual tiebreaker). Sample-based consensus (e.g., "≥3 random pages") is forbidden for any paper that will be cited in a proof; partial coverage requires an explicit justification block in `extraction-consensus.md`. PDF-tiebreaker reasoning MUST quote the printed text or glyph from the `Read` tool's image output — logical inference about what the text "should" say is not a tiebreaker. See `.claude/templates/literature-goal.md` for the canonical literature-ingestion goal template.
3. **Intuition stays in `intuition/`.** No `\begin{theorem}` or formal statement in intuition files. Use `claims/` for that.
4. **The proposer is never the verifier.** Devil's-advocate review is required on every `conjecture`-status claim and on every committed `proof-attempt` step before a `/goal` criterion referencing it can be marked done.
5. **Externalize thinking.** When you use extended thinking on a proposal, emit a structured artifact: hypothesis list → branch evaluation → committed direction → residual uncertainty. Saved to `thinking/<topic>/<date>-<slug>.md` when novel.
6. **Context engineering, not maximization.** Read `BOOTSTRAP.md` at session start. Don't blindly read every file every turn.
7. **No premature formalization.** `formal/` is opt-in per result. Don't install Lean until the first claim is mature enough to formalize.
8. **Append, don't overwrite.** Previously written intuitions, claims, and proofs stay. Corrections are explicit: add a new file, link back, and update the status of the old one (often to `refuted`).

## Looking up a result

1. Open `literature/INDEX.md` to find the paper key.
2. Read `literature/papers/<key>/verbatim.md` — verbatim LaTeX of every result we've extracted, with stable section anchors.
3. Notes/interpretations live in `literature/papers/<key>/notes.md`, kept separate from verbatim.
4. The PDF and source bundle live in `raw_papers/<key>/`, with `meta.json` carrying bibtex, arxiv id, and sha256 of the bundle.

## When to use `thinking/`

Save a thinking trace when:
- The reasoning explored a novel branch (not just routine derivation).
- The structure of the argument (the *strategy*, not the conclusion) is worth re-reading.
- A subagent's structured verdict deserves preservation alongside the artifact.

Don't save: routine algebraic chains, conclusions duplicated in claims/proofs.

## Workflow checklist for any session

1. Read `current-goal.md`. If non-empty, you are in `/goal` mode — read `BOOTSTRAP.md` for what else to load.
2. If starting a new thread:
   - If the input is **one clean intuition**: `/intuition <topic>` directly.
   - If the input is **raw / multi-thread soup** (multiple ideas bundled, mixed domains, felt associations alongside concrete hypotheses): `/intuition-prep` first. It decomposes the soup into discrete threads, interviews per thread, writes one `intuition/<slug>.md` per thread plus an audit trail at `thinking/_unbundled/`.
3. When promoting an intuition to a precise statement: `/claim <topic> <id>` with the right status label.
4. When attempting a proof: write it under `proofs/<topic>/<claim-id>/attempt-NN.md`. After a complete attempt, invoke `proof-reviewer` and `devils-advocate`.
5. When citing a paper not yet in the corpus: fetch via `scripts/fetch_arxiv.py` into `raw_papers/<key>/`, then invoke the `verbatim-extract` skill (do NOT hand-roll the extraction — the skill orchestrates the 2-pass duplicate-extraction layout per Rule 2). Use `.claude/templates/literature-goal.md` as the goal template.
6. Before ending an autonomous goal: `/verify` to catch any provenance / status / citation violations (including PDF-tiebreaker discipline in `extraction-consensus.md` files).
7. Every iter note under `.goals/<slug>/iter-NN.md` should include a one-line `progress:` field (e.g., `progress: pages 19–24 diffed; 1 verbatim edit applied`). The stagnation detector in `scripts/goal_stop_hook.py` uses this to recognize within-criterion advancement — without it, page-by-page work over multiple iters can falsely HALT even when the criteria-set is unchanged. If you intentionally revert a `[x]` checkbox during a goal (honest accounting), add a `revert: C<N>  # reason` line — the stagnation counter resets on revert.
