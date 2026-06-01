# CLAUDE.md — operating protocol

This repository is a **research environment** built to use Claude Opus 4.7 (1M context, max extended thinking) under a **/goal autonomous-iteration pattern** driven by Claude Code Stop hooks. The repo enforces an **intuition-first, provenance-first** workflow.

The repo's structure is the protocol: file locations are not suggestions. Treat them as load-bearing.

## Project mission — computable analysis in Mathlib

**Goal.** Build a formal foundation for computable analysis in Mathlib (Lean 4), following the **axiomatic Banach-space approach of Pour-El & Richards** (*Computability in Analysis and Physics*, 1989).

**Primary reference.** Pour-El & Richards, citation key `PourEl-Richards`. The introduction and prerequisites are already available at `literature/papers/PourEl-Richards-0.1.introduction.md` and `…-0.2.prerequisites.md`. The rest of the textbook is also available and broken down into chapters in `literature/papers/`.

### Architectural commitments — durable; do not relitigate

The computable-analysis literature is dominated by the TTE / represented-spaces / Weihrauch tradition (Pauly, Brattka, Weihrauch's later work). Training data will push future sessions toward that framework. **We have deliberately chosen the Pour-El–Richards framework instead.** The justifying passages live in P-R's own introduction (`PourEl-Richards-0.1.introduction.md:7`, `:28`, `:41`).

1. **Axiomatic computability structures on pre-existing Banach spaces.** We add structure (a `ComputabilityStructure` typeclass) to Mathlib's existing normed-space hierarchy. We do NOT define a parallel category of "computable Banach spaces". (P-R intro:28: *"These axioms define a 'computability structure' on a preexisting Banach space. We do not define a 'computable Banach space'."*)
2. **Sequences are primary, points are derived.** A point is computable iff its constant sequence is. (P-R intro:7: *"a point x is computable if the sequence x, x, x, … is computable. However, it is natural, and in fact necessary, to deal with sequences rather than individual points."*)
3. **Predicates, not parallel types.** Computable reals are `IsComputableReal : ℝ → Prop` on Mathlib's `ℝ`. No new `ℝ_c` type. Same pattern at every higher layer — we predicate over Mathlib objects, we do not rebuild them.
4. **Classical reasoning.** (P-R intro:41: *"we do not work within the intuitionist or constructivist framework — e.g. the framework of Brouwer or Bishop."*) Mathlib is classical; this matches.
5. **Substrate is `Mathlib.Computability.Partrec`.** Plain recursive functions `ℕ → ℕ`. We do NOT build oracle Turing machines, Baire-space realizers, or Type-2 TMs.

### Five-layer architecture

| Layer | Content | P-R chapter | Mathlib hook |
|---|---|---|---|
| L0 | Recursion-theoretic bridge | Prerequisites | `Computability.{Partrec,Halting}`, `Nat.pair` |
| L1 | Computable reals + computable sequences of reals | Ch. 0 | `Data.Real.Basic` (as predicate) |
| L2 | Grzegorczyk-Lacombe computable continuous functions | Ch. 0–1 | `Topology.ContinuousFunction` |
| L3 | `ComputabilityStructure` typeclass on Banach spaces (the keystone) | Ch. 2 | `NormedSpace`, `InnerProductSpace`, `CompleteSpace` |
| L4 | Concrete instances: `C[a,b]`, `L^p`, separable Hilbert | Ch. 2 + applications | `ContinuousMap`, `MeasureTheory.Lp` |
| L5 | First/Second Main Theorems, Eigenvector Theorem | Ch. 3, 4, 5 | `ContinuousLinearMap`, `IsSelfAdjoint`, spectral theory |

### Anti-goals — out of scope (surface the conflict before pursuing)

- **Type-2 Theory of Effectivity / represented spaces** (Pauly, Schröder). Tell-tale signs to STOP on: `RepresentedSpace`, partial surjection `δ : (ℕ → ℕ) →. X`, "admissible representation", oracle Turing machines, Baire-space realizers.
- **Weihrauch reducibility lattice.** Not in P-R. Deferrable extension; not foundational.
- **Bishop / Brouwer constructive reformulation.** Rejected explicitly by P-R.
- **A new computable real type `ℝ_c`** parallel to Mathlib's `ℝ`. We predicate over `ℝ`.
- **Premature Lean formalization.** Rule 7 holds; `formal/` is opt-in per result. Definitions live in `claims/` first.

### Conflict resolution

If a session proposes a direction that may conflict with these commitments:
1. Quote the specific commitment being challenged.
2. Cite the relevant P-R passage verbatim from the extracted chapter, OR
3. Surface the conflict to the user and wait for explicit re-scoping.

The proposer-is-never-the-verifier rule (Rule 4) applies here too: a session may not unilaterally amend the architectural commitments.

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

## Milestone tracker — computable analysis project

Update this table whenever a milestone advances. Details live in `claims/`, `proofs/`, and `.goals/<slug>/`. Status values:

- `pending` — not yet started
- `in-progress` — work begun, see pointer
- `claimed` — claim file exists in `claims/` with appropriate status label
- `proved` — proof attempt complete, devil's-advocate verdict `passes`
- `formalized` — Lean code committed under `formal/`
- `done` — milestone fully discharged (terminal)

### Corpus ingestion (P-R chapters)

| Chapter | Topic | Status | Pointer |
|---|---|---|---|
| Intro | — | `done` | `literature/papers/PourEl-Richards-0.1.introduction.md` |
| Prerequisites | Logic + analysis recap | `done` | `literature/papers/PourEl-Richards-0.2.prerequisites.md` |
| Ch. 0 | Computable reals + G-L continuous functions | `done` | `literature/papers/PourEl-Richards-chapt0.md` |
| Ch. 1 | Differentiation, analytic functions | `pending` | — (deferred; needed for advanced L2 results) |
| Ch. 2 | Axiomatic computability structure on Banach spaces (keystone) | `done` | `literature/papers/PourEl-Richards-chapt2.md` |
| Ch. 3 | First Main Theorem + applications | `done` | `literature/papers/PourEl-Richards-chapt3.md` |
| Ch. 4 | Second Main Theorem + Eigenvector Theorem | `done` | `literature/papers/PourEl-Richards-chapt4.md` |
| Ch. 5 | Proof of Second Main Theorem | `done` | `literature/papers/PourEl-Richards-chapt5.md` |

Note: chapters are extracted as flat per-chapter files rather than the canonical `literature/papers/<key>/verbatim.md` structure. This is an intentional deviation accepted by the user; per-chapter granularity is more navigable for a 600-page textbook. Rule 2 still applies: any theorem cited in a proof must quote verbatim from the relevant chapter file, with a `file:line` pointer.

### Construction milestones

| Layer | Milestone | Status | Pointer |
|---|---|---|---|
| L0 | Map P-R logic prerequisites onto Mathlib's `Computability.*` | `pending` | — |
| L0 | Recursively inseparable pair (P-R Prop. B) constructed | `pending` | — |
| L1 | `IsComputableSeqReal` definition | `pending` | — |
| L1 | `IsComputableReal` definition | `pending` | — |
| L1 | Computable reals form a countable subfield of ℝ | `pending` | — |
| L2 | Grzegorczyk-Lacombe computable continuous function definition | `pending` | — |
| L2 | Closure properties of G-L computable functions | `pending` | — |
| L3 | `ComputabilityStructure` typeclass — three axioms | `pending` | — |
| L3 | Uniqueness theorem under mild side conditions | `pending` | — |
| L4 | Instance: `C([a,b], ℝ)` with sup norm | `pending` | — |
| L4 | Instance: `L^p[a,b]` | `pending` | — |
| L4 | Instance: separable Hilbert space | `pending` | — |
| L5 | First Main Theorem (Ch. 3) | `pending` | — |
| L5 | Effective Plancherel theorem | `pending` | — |
| L5 | Second Main Theorem (Ch. 4) | `pending` | — |
| L5 | Eigenvector Theorem (Ch. 4) | `pending` | — |
