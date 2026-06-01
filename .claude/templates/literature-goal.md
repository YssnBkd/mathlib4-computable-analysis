# Literature-ingestion goal template

Use this as the canonical 4-criterion structure for any `/goal` that ingests a paper into `literature/papers/<key>/`. Drop into `current-goal.md` and substitute the bracketed placeholders.

This template replaces the ad-hoc "≥3 randomly chosen pages" wording that was used pre-2026-05-21. That wording was satisfied literally by sampling 3 of 34 pages on `branicky-clocks` but missed 9 verbatim errors (including 2 substantive math errors) and 1 PDF-tiebreaker misverification. The new C2 forces full-coverage via the `verbatim-extract` skill.

---

```yaml
---
slug: <key>-verbatim
started: <ISO-8601-timestamp>
mode: lit-search
max_iterations: 24
time_budget_minutes: 1000
allow_writes:
  - literature/papers/<key>/**
  - literature/INDEX.md
  - claims/<key>-verbatim/**
  - proofs/<key>-verbatim/**
  - thinking/<key>-verbatim/**
  - intuition/<key>-verbatim.md
  - .goals/<key>-verbatim/**
  - .goals/INDEX.md
  - current-goal.md
forbid_writes:
  - raw_papers/**
  - scripts/**
  - formal/**
  - CLAUDE.md
  - BOOTSTRAP.md
  - intuition/test-thread/**
devils_advocate_required_for:
  - "C3"
---

# Goal: full verbatim extraction of <key>.pdf, then chain-of-thought reconstruction

## Why this matters

<one paragraph: where this paper sits in the corpus, what proofs/claims will cite it, what makes the math non-trivial>.

## Success criteria

- [ ] C1: `literature/papers/<key>/verbatim.md` exists and contains all N pages of the PDF, each under a stable `## Page N` anchor, with LaTeX math, footnotes, figure captions, references, and section headers preserved verbatim. Read via the `Read` tool's `pages` parameter — never via `pdftotext` or memory.
- [ ] C2: `literature/papers/<key>/extraction-consensus.md` exists and documents a **full-coverage** duplicate-extraction cross-check via the `verbatim-extract` skill (2 passes × ⌈N/6⌉ independent agents covering all N pages, 3-way diff against primary, PDF-visual tiebreaker for every disagreement). Every per-page row in the consensus must contain one of: `agree (3/3)`, `agree (2-1 …)`, `disagree-resolved-via-PDF (X edits)`, `deferred — ambiguous PDF glyph`. Every `disagree-resolved-via-PDF` row MUST quote the printed text or glyph (`PDF page N reads "..."` or `PDF page N glyph: <description>`); logical inference as tiebreaker is forbidden (see CLAUDE.md rule 2). Partial coverage is allowed ONLY with an explicit justification block in the consensus header (e.g., "supplementary source, not cited in any proof").
- [ ] C3: `literature/papers/<key>/chain-of-thought.md` exists and (a) covers every section of the paper, (b) preserves all definitions, theorems, lemmas, propositions with their full LaTeX statements, (c) renders every proof as a numbered reasoning chain ("Step 1: ... Step 2: ... ∴ ...") with natural-language commentary kept, and (d) cites the verbatim page range for each block (`see verbatim.md §Page N`). **Requires devil's-advocate review** (`.goals/<key>-verbatim/reviews/C3.md` with verdict `passes`) confirming the CoT does not drift from the **corrected** verbatim (i.e., post-C2). If C2 surfaces verbatim corrections, the C3 review must explicitly address the cascade audit (which corrections propagate to the CoT and which do not).
- [ ] C4: `literature/papers/<key>/meta.json` exists with bibtex, page count (N), sha256, and a one-line abstract; `literature/INDEX.md` references the new `<key>` entry with `**comprehensive**` status and an indication of the consensus coverage ("full-coverage" or the justified partial-coverage shorthand).

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes`
- ≥3 iterations with identical unmet criteria AND identical `progress:` field AND identical `files_changed` set (stagnation; see CLAUDE.md workflow for the `progress:` convention)
- Devil's-advocate verdict `unsound` on C3 (CoT drift detected)
- iter ≥ 24 or elapsed ≥ 1000 minutes
- Any attempt to use `pdftotext` or similar conversion tool on `<key>.pdf` (per [[feedback-pdf-extraction]] — must read directly via `Read` tool)
```

---

## Iter-note convention

Every iter file under `.goals/<key>-verbatim/iter-NN.md` should include a `progress:` field — a single line describing what changed this iter. This is read by `scripts/goal_stop_hook.py`'s stagnation detector so legitimate page-by-page progress does not trigger HALT.

Example:
```
# iter-09
timestamp: 2026-05-21T09:32:01Z
unmet: [C2, C3]
mode: lit-search
progress: launched 12 duplicate-extraction agents (2 passes × 6); awaiting returns
files_changed: ['.goals/<key>-verbatim/iter-09.md', '.goals/<key>-verbatim/extraction-pass-a1/*.md']
```

## When reverting a `[x]` checkbox

If during the goal you discover a checkbox needs to be reverted (because the criterion text was over-permissive or the artifact didn't meet the spirit of the criterion), include a `revert:` field in the iter note:

```
# iter-08
unmet: [C2, C3]
progress: reverted C2 from [x] to [ ] — original 3-page consensus did not meet the spirit of full-coverage
revert: C2  # iter-08 honest-accounting per the user's flag; full-coverage remediation begins next iter
```

The stagnation detector resets when it sees a `revert:` line — the iter-08 move was correct-by-design and should not subsequently produce stagnation HALT 3 iters later.

## Cross-references

- [[verbatim-extract]] — the skill that C2 mandates.
- [[feedback-multi-agent-consensus]] — the underlying protocol; see its addendum for correlated-error, PDF-tiebreaker, and full-coverage rules.
- [[feedback-pdf-extraction]] — `Read`-with-`pages`, no `pdftotext`.
- `scripts/goal_stop_hook.py` — reads the `progress:` and `revert:` fields described above.
- `scripts/verify_provenance.py` — enforces the PDF-glyph-quote rule in `disagree-resolved-via-PDF` rows.
