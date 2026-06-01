---
description: Run integrity checks across claims/, proofs/, literature/. Reports violations.
---

Run the integrity-check scripts and report.

Do this:

1. Run `.venv/bin/python scripts/verify_claims.py` — capture stdout and exit code.
2. Run `.venv/bin/python scripts/verify_provenance.py` — capture stdout and exit code.
3. If both exit 0: report `OK` with the summary lines from each.
4. If either exits non-zero: report each violation. For each, suggest a specific fix:
   - Missing frontmatter → "add YAML frontmatter with `id`, `status`, `created`."
   - Invalid status → "use one of intuition/conjecture/our_construction/cited_result/verified/refuted."
   - `cited_result` / `verified` with empty sources → "add a `sources:` list with at least one `<bibkey>:<locator>`."
   - Unknown dependency id → "either correct the id or create the missing claim file."
   - Missing literature paper → "run `scripts/fetch_arxiv.py <arxiv-id> <bibkey>` to seed it, then extract the verbatim statement."
5. Do NOT auto-fix unless the user asks. Reporting is the default.
