# CLAUDE.md — operating protocol

This repository is a **research environment** built to use Claude Opus 4.7 (1M context, max extended thinking) under a **/goal autonomous-iteration pattern** driven by Claude Code Stop hooks. The repo enforces an **intuition-first, provenance-first** workflow.

The repo's structure is the protocol: file locations are not suggestions. Treat them as load-bearing.

## Project mission — computable analysis in Mathlib

**Goal.** Build a formal foundation for computable analysis in Mathlib (Lean 4), following the **axiomatic Banach-space approach of Pour-El & Richards** (*Computability in Analysis and Physics*, 1989).

**Primary reference.** Pour-El & Richards, citation key `PourEl-Richards`. The introduction and prerequisites are already available at `literature/papers/PourEl-Richards-0.1.introduction.md` and `…-0.2.prerequisites.md`. The rest of the textbook is also available and broken down into chapters in `literature/papers/`.

**Primary deliverable.** The project's output is **Lean 4 code under `formal/`, intended for upstream contribution to Mathlib4**. Paper claims under `claims/`, intuitions under `intuition/`, and proofs under `proofs/` are *design infrastructure for the Lean code*, not standalone deliverables. A milestone is `done` iff its corresponding `formal/L<N>/<artifact>.lean` exists, type-checks against the project's pinned Mathlib4 commit, and exports the predicate / structure / theorem named in the milestone.

### Architectural commitments — durable; do not relitigate

The computable-analysis literature is dominated by the TTE / represented-spaces / Weihrauch tradition (Pauly, Brattka, Weihrauch's later work). Training data will push future sessions toward that framework. **We have deliberately chosen the Pour-El–Richards framework instead.** The justifying passages live in P-R's own introduction (`PourEl-Richards-0.1.introduction.md:7`, `:28`, `:41`).

1. **Axiomatic computability structures on pre-existing Banach spaces.** We add structure (a `ComputabilityStructure` typeclass) to Mathlib's existing normed-space hierarchy. We do NOT define a parallel category of "computable Banach spaces". (P-R intro:28: *"These axioms define a 'computability structure' on a preexisting Banach space. We do not define a 'computable Banach space'."*)
2. **Sequences are primary, points are derived.** A point is computable iff its constant sequence is. (P-R intro:7: *"a point x is computable if the sequence x, x, x, … is computable. However, it is natural, and in fact necessary, to deal with sequences rather than individual points."*)
3. **Predicates, not parallel types.** Computable reals are `IsComputableReal : ℝ → Prop` on Mathlib's `ℝ`. No new `ℝ_c` type. Same pattern at every higher layer — we predicate over Mathlib objects, we do not rebuild them.
4. **Classical reasoning.** (P-R intro:41: *"we do not work within the intuitionist or constructivist framework — e.g. the framework of Brouwer or Bishop."*) Mathlib is classical; this matches.
5. **Substrate is `Mathlib.Computability.Partrec`.** Plain recursive functions `ℕ → ℕ`. We do NOT build oracle Turing machines, Baire-space realizers, or Type-2 TMs.
6. **Every claim has a Lean target.** Each `claims/<topic>/<id>.md` carries a `lean_target: formal/L<N>/<path>.lean` field in its YAML frontmatter. Each /goal touching the milestone must include a Lean criterion: the target file exists, type-checks against the pinned Mathlib4 commit, and exports the named predicate / structure / theorem. Theorem proofs may use `sorry` while paper proof is maturing; **predicate and structure definitions cannot use `sorry`**. Mathlib4 is project infrastructure, installed as soon as the first Lean-criterion goal opens.

### Five-layer architecture

| Layer | Content | P-R chapter | Mathlib hook | Lean target |
|---|---|---|---|---|
| L0 | Recursion-theoretic bridge | Prerequisites | `Computability.{Partrec,Halting}`, `Nat.pair` | `formal/L0/Bridge.lean`, `formal/L0/PropB.lean` |
| L1 | Computable reals + computable sequences of reals | Ch. 0 | `Data.Real.Basic` (as predicate) | `formal/L1/ComputableSeqReal.lean`, `formal/L1/ComputableSeqComplex.lean` |
| L2 | Grzegorczyk-Lacombe computable continuous functions | Ch. 0–1 | `Topology.ContinuousFunction` | `formal/L2/GrzegorczykLacombe.lean` |
| L3 | `ComputabilityStructure` typeclass on Banach spaces (the keystone) | Ch. 2 | `NormedSpace`, `InnerProductSpace`, `CompleteSpace` | `formal/L3/ComputabilityStructure.lean` |
| L4 | Concrete instances: `C[a,b]`, `L^p`, separable Hilbert | Ch. 2 + applications | `ContinuousMap`, `MeasureTheory.Lp` | `formal/L4/Instances/{CMap,Lp,Hilbert}.lean` |
| L5 | First/Second Main Theorems, Eigenvector Theorem | Ch. 3, 4, 5 | `ContinuousLinearMap`, `IsSelfAdjoint`, spectral theory | `formal/L5/{FirstMainTheorem,SecondMainTheorem,Eigenvector}.lean` |

### Anti-goals — out of scope (surface the conflict before pursuing)

- **Type-2 Theory of Effectivity / represented spaces** (Pauly, Schröder). Tell-tale signs to STOP on: `RepresentedSpace`, partial surjection `δ : (ℕ → ℕ) →. X`, "admissible representation", oracle Turing machines, Baire-space realizers.
- **Weihrauch reducibility lattice.** Not in P-R. Deferrable extension; not foundational.
- **Bishop / Brouwer constructive reformulation.** Rejected explicitly by P-R.
- **A new computable real type `ℝ_c`** parallel to Mathlib's `ℝ`. We predicate over `ℝ`.
- **Paper-only milestones without a Lean target.** Every `our_construction` / `verified` / `cited_result` claim must specify `lean_target` in its frontmatter; a milestone that reaches devil's-advocate `passes` without a Lean stub is **not** `done`. Indefinite Lean deferral conflicts with the project's primary deliverable.

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
6. **Lean formalization in `formal/L<N>/...` — the primary deliverable.** Co-developed with each claim in the same /goal scope; not optional. Theorem proofs may carry `sorry` while paper proof matures, but predicate / structure definitions are concrete.

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

**Terminal-state convention.** `verified` is the terminal state for the **paper** proof. `formalized` (with a corresponding Lean file that type-checks against the pinned Mathlib commit and is `sorry`-free in predicates / structures) is the terminal state for the **project** milestone. The milestone tracker uses `formalized` (or `done`) as terminal; `verified` is intermediate. Architectural commitment #6 and Rule 7 spell out the Lean side.

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
7. **Lean formalization is mandatory per milestone.** Each claim file specifies `lean_target: formal/L<N>/<path>.lean` in its frontmatter. Each /goal touching the milestone includes a Lean criterion (target file exists, type-checks against the pinned Mathlib commit, exports the named symbols). Mathlib4 lives at `formal/` as a Lake project (`lakefile.toml`); the toolchain is pinned via `lean-toolchain`. Installation is a one-time task in the first Lean-criterion goal.
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
4. **Every new claim file specifies `lean_target`** in its frontmatter, even if the Lean file does not yet exist. Use the layer-prefix convention `formal/L<N>/<file>.lean`. This is enforced by Rule 7 and Architectural commitment #6.
5. When attempting a proof: write it under `proofs/<topic>/<claim-id>/attempt-NN.md`. After a complete attempt, invoke `proof-reviewer` and `devils-advocate`.
6. When citing a paper not yet in the corpus: fetch via `scripts/fetch_arxiv.py` into `raw_papers/<key>/`, then invoke the `verbatim-extract` skill (do NOT hand-roll the extraction — the skill orchestrates the 2-pass duplicate-extraction layout per Rule 2). Use `.claude/templates/literature-goal.md` as the goal template.
7. Before ending an autonomous goal: `/verify` to catch any provenance / status / citation violations (including PDF-tiebreaker discipline in `extraction-consensus.md` files).
8. Every iter note under `.goals/<slug>/iter-NN.md` should include a one-line `progress:` field (e.g., `progress: pages 19–24 diffed; 1 verbatim edit applied`). The stagnation detector in `scripts/goal_stop_hook.py` uses this to recognize within-criterion advancement — without it, page-by-page work over multiple iters can falsely HALT even when the criteria-set is unchanged. If you intentionally revert a `[x]` checkbox during a goal (honest accounting), add a `revert: C<N>  # reason` line — the stagnation counter resets on revert.
9. **Each /goal touching a milestone includes a Lean criterion.** Test: `cd formal && lake build` succeeds, the named symbols are declared in the target file (`#check` produces no errors), and predicate / structure bodies are `sorry`-free. Theorem proofs may carry `sorry` (the paper proof is the audit trail) but predicate / structure definitions cannot.

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

| Layer | Milestone | Status | Lean target | Pointer |
|---|---|---|---|---|
| L0 | Map P-R logic prerequisites onto Mathlib's `Computability.*` | `pending` | `formal/L0/Bridge.lean` | — |
| L0 | Recursively inseparable pair (P-R Prop. B) constructed | `pending` | `formal/L0/PropB.lean` | — |
| L1 | `IsComputableSeqReal` definition | `claimed` | `formal/L1/ComputableSeqReal.lean` | `claims/l1-computable-reals/is-computable-seq-real.md` |
| L1 | `IsComputableSeqComplex` definition | `claimed` | `formal/L1/ComputableSeqComplex.lean` | `claims/l1-computable-reals/is-computable-seq-real.md` |
| L1 | `IsComputableReal` definition | `pending` | `formal/L1/ComputableReal.lean` | — |
| L1 | Computable reals form a countable subfield of ℝ | `pending` | `formal/L1/SubfieldStructure.lean` | — |
| L2 | Grzegorczyk-Lacombe computable continuous function definition | `pending` | `formal/L2/GrzegorczykLacombe.lean` | — |
| L2 | Closure properties of G-L computable functions | `pending` | `formal/L2/GLClosure.lean` | — |
| L3 | `ComputabilityStructure` typeclass — three axioms | `claimed` | `formal/L3/ComputabilityStructure.lean` | `claims/l3-computability-structure/axioms.md` |
| L3 | Uniqueness theorem under mild side conditions | `pending` | `formal/L3/Stability.lean` | — |
| L4 | Instance: `C([a,b], ℝ)` with sup norm | `pending` | `formal/L4/Instances/CMap.lean` | — |
| L4 | Instance: `L^p[a,b]` | `pending` | `formal/L4/Instances/Lp.lean` | — |
| L4 | Instance: separable Hilbert space | `pending` | `formal/L4/Instances/Hilbert.lean` | — |
| L5 | First Main Theorem (Ch. 3) | `pending` | `formal/L5/FirstMainTheorem.lean` | — |
| L5 | Effective Plancherel theorem | `pending` | `formal/L5/Plancherel.lean` | — |
| L5 | Second Main Theorem (Ch. 4) | `pending` | `formal/L5/SecondMainTheorem.lean` | — |
| L5 | Eigenvector Theorem (Ch. 4) | `pending` | `formal/L5/Eigenvector.lean` | — |

## Lean integration cadence

The "Bundled per goal" pattern: every /goal touching a milestone carries paper + Lean criteria for the same milestone. A milestone is `done` only when its Lean stub type-checks. This section spells out the conventions.

### Directory layout under `formal/`

- `formal/lakefile.toml` — Lake project configuration (Mathlib4 as the sole dependency)
- `formal/lean-toolchain` — pinned Lean version (matches Mathlib's required toolchain)
- `formal/lake-manifest.json` — pinned Mathlib commit (regenerated only by an `update-mathlib` /goal)
- `formal/L0/` … `formal/L5/` — code organized by layer; namespaces `ComputableAnalysis.L0` … `ComputableAnalysis.L5`
- `formal/Tests/L<N>/` — `#check` and small example files exercising each layer's public API
- `formal/ComputableAnalysis.lean` — umbrella import file (re-exports each layer)

### `sorry` policy

- **Allowed:** theorem and lemma proofs while paper proof is maturing
- **Forbidden:** predicate definitions, structure-field definitions, the `structure` / `class` headers themselves, instance bodies that the milestone names as the deliverable
- Every iter note inspects `formal/` for new `sorry` occurrences in forbidden contexts and tags them in the `progress:` field

### Mathlib pinning

- The first Lean-criterion /goal pins Mathlib to a specific commit recorded in `lake-manifest.json`
- Re-pinning is a separate /goal (`update-mathlib`); it does not happen mid-claim
- The pinned commit's API supersedes textual "Mathlib hook" references in the five-layer architecture if the API has changed

### Devil's-advocate review under Lean

For a claim that has both paper and Lean artifacts, the devil's-advocate subagent reads both. Verdict `passes` requires:

1. Paper claim faithful to source (the round-1 check)
2. Lean stub matches paper claim's definitions (no silent drift in names, signatures, or quantifier order)
3. Lean stub type-checks against the pinned Mathlib commit

Mismatch on (2) returns `unsound`; a non-type-checking stub returns `unsupported`.

### Naming conventions

- Predicates: `Is*` (matches Mathlib), e.g., `IsComputableSeqReal`, `IsComputableSeqComplex`
- Typeclasses: PascalCase, e.g., `ComputabilityStructure`, `EffectivelySeparable`
- Instance declarations: `instance : ComputabilityStructure (ContinuousMap ...) := ...`
- File names match the principal export: `ComputabilityStructure.lean` declares `ComputabilityStructure`

### Skill / tooling implications (deferred to follow-up work)

- The `/verify` skill should eventually inspect `formal/` for `sorry` violations in predicate / structure positions and unresolved `lean_target` fields. For now this is a manual check in each iter note.
- The `devils-advocate` subagent's prompt is updated to include the Lean stub when present (specification in this section; implementation deferred to a `devils-advocate-lean` /goal).
