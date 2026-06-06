# Audit prompt — paste this as the opening message in a fresh conversation

You are continuing work on **mathlib-computable-analysis**, a Lean 4 / Mathlib4
formalization of Pour-El & Richards' *Computability in Analysis and Physics*
(Cambridge UP 1989), targeting upstream contribution to
`Mathlib.Computability.Analysis.*`.

Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`.

**Step 0**: Read `CLAUDE.md` first — it is the project constitution.

## The task

Open a `/goal pr-coverage-assessment` round to audit the formalization
against P-R verbatim. This is a **stop-and-assess** round, not an
implementation round. The deliverable is a single Markdown doc, not Lean
code.

The audit:

- **Reads** P-R chapter verbatim files under `literature/papers/`
  (`PourEl-Richards-0.1.introduction.md`,
  `PourEl-Richards-0.2.prerequisites.md`,
  `PourEl-Richards-chapt0.md` through `PourEl-Richards-chapt5.md`).
- **Greps** the current Lean state under `ComputableAnalysis/L{0,1,2,3,4,5}/`
  and the blueprint under `blueprint/src/L{0,1,2,3,4,5}.tex`.
- **Produces** a single deliverable doc `docs/PR-COVERAGE.md`.
- **Does NOT write** Lean, blueprint, claims, proofs, or intuition files.
  Findings about needed changes there go INTO `docs/PR-COVERAGE.md`,
  addressed in follow-up rounds.

A previous attempt at this round (`pr-coverage-assessment`, archived under
`.goals/pr-coverage-assessment/`) was abandoned at iter-18 with no
substantive progress, by user request for a fresh conversation. Re-snapshot
when you open the new round.

## Round parameters

Confirm these with `/goal pr-coverage-assessment`:

- **slug**: `pr-coverage-assessment`
- **mode**: `explore`
- **max_iterations**: 50
- **time_budget_minutes**: 3600 (60-hour budget — multi-session OK)
- **allow_writes**:
  - `docs/PR-COVERAGE.md`
  - `docs/state-assessment-*.md`
  - `.goals/pr-coverage-assessment/**`
  - `.goals/INDEX.md`
  - `current-goal.md`
- **forbid_writes**:
  - `literature/papers/**`
  - `raw_papers/**`
  - `claims/**`
  - `proofs/**`
  - `intuition/**`
- **devils_advocate_required_for**: `["C7"]`

Note: `ComputableAnalysis/**` and `blueprint/**` are deliberately **not** in
`forbid_writes` because the Stop hook tracks session-wide writes and would
HALT on residual writes from prior rounds. The "no Lean / blueprint writes
in this round" rule is **behavioural** — you must not modify those paths
in this round; findings about needed changes there go into
`docs/PR-COVERAGE.md`.

## Success criteria

- **C1**: Per-section coverage table. For each P-R section (Intro,
  Prerequisites, Ch. 0, Ch. 1, Ch. 2, Ch. 3, Ch. 4, Ch. 5), produce a
  table of landmark items (definitions, theorems, propositions, lemmas)
  with columns: `P-R location` (file:line in `literature/papers/`),
  `Lean status` (`done` / `partial` / `deferred` / `not started`),
  `Lean ref` (`<file>:<line>` or rationale).

- **C2**: Citation verification for every `done` row. Read the P-R
  verbatim at the cited line and confirm the Lean statement (signature +
  intent) matches semantically. Flag any "claimed done but actually
  partial / divergent" cases as audit findings.

- **C3**: Rationale + effort estimate for every `deferred` or
  `not started` row. Format: `<reason>` (e.g., requires Lᵖ measure theory,
  depends on L5 First Main Theorem, intentionally out of scope per
  `CLAUDE.md` commitment #N) + `<effort class S/M/L/XL>`.

- **C4**: Inventory of **divergences from P-R**: machinery in the
  formalization that goes beyond / differs from P-R in design choice, with
  rationale per divergence. Known candidates:
  - the explicit positivity conjunct `∀ N, 0 < d N` in `IsGLComputable`
    (P-R writes `1/d(N)` classically; we encode positivity because of
    Mathlib's `1/0 = 0` convention);
  - `IsComputableSeqReal.bound` (P-R argues via uniform continuity, we
    extract a Nat bound directly from the witness);
  - `ContinuousMap.norm`-based boundedness in `l2_mul_gl` (P-R uses
    pointwise bounds from `f`'s modulus and a base point);
  - the `Computable`-vs-`Recursive`-vs-`Primrec` distinction;
  - the predicate-first vs subtype design (project commitment #3 in
    `CLAUDE.md`).

- **C5**: Top-5 priority list. Rank the next 5 most valuable P-R results
  to formalize, with rationale per ranking covering `(impact × effort ×
  what-it-unlocks)`. Each entry should suggest a candidate `/goal` slug.

- **C6**: Deliverable `docs/PR-COVERAGE.md` is self-contained, dated
  `2026-06-06` (or the date of completion if later), written so a
  future-session reader (or a reviewer landing cold) can absorb the
  project's state in one read. Includes a **one-page executive summary** at
  the top.

- **C7**: DA review on `docs/PR-COVERAGE.md`. Verifies:
  (a) no P-R citation is misattributed (grep-able);
  (b) no `file:line` Lean ref points to a non-existent location;
  (c) no `done` row covers something that is actually `partial` (e.g.,
  has a `sorry`);
  (d) priority ranking is internally consistent with the effort estimates
  in C3.
  DA verdict must be exactly `verdict: passes`.

## Workflow

1. Read `CLAUDE.md`.
2. Read `literature/INDEX.md` for the paper registry.
3. Optionally open `blueprint/web/dep_graph_document.html` for a quick
   visual orientation (cross-check only — not the source of truth).
4. Run `/goal pr-coverage-assessment` with the parameters above. When the
   skill asks for confirmation, accept the defaults shown.
5. Work through chapters one at a time (Intro + Prerequisites first, then
   Ch. 0 which is the densest, then Ch. 1, Ch. 2 — the L3 axiomatic
   keystone — then Ch. 3, 4, 5).
6. For each chapter: read the verbatim file, list every numbered item
   (definitions, theorems, propositions, lemmas), grep Lean +
   `blueprint/src/L*.tex` for matches, fill in the table row.
7. After all per-chapter passes: synthesize C4 (divergences) and C5
   (priority list), then write the executive summary at the top.
8. Invoke `/devils-advocate C7` on the deliverable.
9. Run `/goal-end` when all criteria green.

## Sources of truth

- **P-R verbatim**: `literature/papers/PourEl-Richards-*.md` (one file per
  chapter; intentionally flat layout per `CLAUDE.md`).
- **Lean source**: `ComputableAnalysis/L{0,1,2,3,4,5}/`.
- **Blueprint LaTeX**: `blueprint/src/L{0,1,2,3,4,5}.tex`.
- **Blueprint dep graph**: `blueprint/web/dep_graph_document.html`
  (cross-check, not source of truth — the question is "does it match P-R,"
  which requires reading P-R independently).

## Hard rules (from CLAUDE.md)

- Read verbatim; do not paraphrase P-R from memory.
- Every citation in the deliverable must include a `file:line` ref that
  grep-passes verbatim.
- Every agent (including subagents spawned for `/devils-advocate`) must run
  on Opus (`claude-opus-4-8`).
- Never commit unless the user explicitly asks; `git push` is denied.
- This is an **audit round** — no Lean / blueprint / claims / proofs /
  intuition writes. Findings about those go INTO `docs/PR-COVERAGE.md`.

## Reference: prior-round archive

The previous round attempt is archived under
`.goals/pr-coverage-assessment/{goal.md, iter-00.md, …, iter-18.md, final.md}`.
`iter-00.md` contains the recommended per-chapter workflow that was
sketched but not executed. You may copy the iter-00 multi-iter plan
verbatim into your new round's iter-00.

The just-completed prior round `l2-mul-smul-sub` (closed
`.goals/l2-mul-smul-sub/final.md` 2026-06-06) is also relevant context for
the L2 row of the coverage table.

---

**Begin** by reading `CLAUDE.md`, then `literature/INDEX.md`, then run
`/goal pr-coverage-assessment` with the parameters above.
