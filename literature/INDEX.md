# literature/INDEX.md — paper corpus index

Per-paper records, one folder per paper at `literature/papers/<bibkey>/`. Each folder has:

- `meta.json` — bibtex key, arxiv/doi/HAL id, sha256 of canonical PDF, page count, role
- `verbatim.md` — verbatim LaTeX-style extracts of theorems / definitions / hypotheses, with stable section anchors
- `notes.md` — our annotations and interpretation, kept strictly separate from `verbatim.md`

Canonical PDFs live at `raw_papers/<bibkey>/<arxiv-id>.pdf`. Integrity is tracked via the `sha256` field in `meta.json`.

To add a paper: run `scripts/fetch_arxiv.py <arxiv-id> <bibkey>`, then invoke the `verbatim-extract` skill on it (full-coverage 2-pass duplicate-extraction with 3-way diff + PDF-visual tiebreaker — see `.claude/templates/literature-goal.md`).

## Papers (ingested = has `meta.json`)

| bibkey | citation (short) | year | venue | arxiv/doi/HAL | verbatim.md |
|---|---|---|---|---|---|
| _(none yet)_ | | | | | |

## Status legend

- **pending** — directory + `meta.json` + `notes.md` exist; `verbatim.md` not yet created (extraction still to be done)
- **partial** — `verbatim.md` exists with some sections; more to come (the file itself lists which sections are complete)
- **complete-for-thread** — every result that the active research thread cites has a verbatim entry with section anchors
- **comprehensive** — entire paper is in `verbatim.md` (full-coverage extraction via the `verbatim-extract` skill)

## Topic groupings

(Add `### Topic` headings as your corpus grows. Group papers by the role they play in your research threads, not by chronology.)
