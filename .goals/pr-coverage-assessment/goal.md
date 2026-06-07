---
slug: pr-coverage-assessment
started: 2026-06-06T09:14:40Z
mode: explore
max_iterations: 50
time_budget_minutes: 3600
allow_writes:
  - docs/PR-COVERAGE.md
  - docs/state-assessment-*.md
  - .goals/pr-coverage-assessment/**
  - .goals/INDEX.md
  - current-goal.md
forbid_writes:
  - literature/papers/**
  - raw_papers/**
  - claims/**
  - proofs/**
  - intuition/**
devils_advocate_required_for:
  - "C7"
---

# Goal: Audit the current Pour-El & Richards formalization against the P-R verbatim and produce `docs/PR-COVERAGE.md`

## Why this matters

This is a **stop-and-assess** round, not an implementation round. The deliverable is a single Markdown doc that gives a future-session reader (or a Mathlib reviewer landing cold) a complete picture of: (a) what P-R material is formalized vs deferred, (b) where the Lean state diverges from P-R by design and why, and (c) the top-5 highest-value-per-effort next results to formalize. Round spec source: `AUDIT.md` at repo root. Prior abandoned attempt: `.goals/pr-coverage-assessment/prior-{goal,iter-00,final}.md`.

## Success criteria

- [ ] C1: Per-section coverage table for each P-R section (Intro, Prerequisites, Ch. 0, Ch. 1, Ch. 2, Ch. 3, Ch. 4, Ch. 5), with landmark items (definitions, theorems, propositions, lemmas) and columns `P-R location` (file:line), `Lean status` (`done` / `partial` / `deferred` / `not started`), `Lean ref` (`<file>:<line>` or rationale).
- [ ] C2: Citation verification for every `done` row — read P-R verbatim at the cited line and confirm Lean statement signature + intent matches semantically; flag "claimed done but actually partial / divergent" cases.
- [ ] C3: Rationale + effort estimate (`S/M/L/XL`) for every `deferred` or `not started` row.
- [ ] C4: Inventory of divergences from P-R (machinery beyond / differing from P-R in design choice) with rationale per divergence. Known candidates: explicit positivity conjunct in `IsGLComputable`, `IsComputableSeqReal.bound`, `ContinuousMap.norm` boundedness in `l2_mul_gl`, `Computable`-vs-`Recursive`-vs-`Primrec` distinction, predicate-first vs subtype design.
- [ ] C5: Top-5 priority list ranked by `(impact × effort × what-it-unlocks)`, each with a candidate `/goal` slug.
- [ ] C6: Deliverable `docs/PR-COVERAGE.md` is self-contained, dated `2026-06-06` (or completion date), includes a one-page executive summary at the top.
- [ ] C7: DA review on `docs/PR-COVERAGE.md` with verdict exactly `verdict: passes`. Verifies: (a) no P-R citation misattributed (grep-able); (b) no `file:line` Lean ref points to a non-existent location; (c) no `done` row covers something with a `sorry`; (d) priority ranking consistent with C3 effort estimates.

## Hard stops

- Any write outside allow_writes or matching forbid_writes (Lean / blueprint / claims / proofs / intuition / literature paths). Findings about needed changes there go INTO `docs/PR-COVERAGE.md`.
- ≥3 iterations with identical unmet criteria
- Devil's-advocate verdict `unsound` on `docs/PR-COVERAGE.md`
- iter ≥ 50 or elapsed ≥ 3600 minutes
