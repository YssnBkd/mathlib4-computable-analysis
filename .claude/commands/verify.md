---
description: Run integrity checks across blueprint/, claims/, proofs/, literature/, and the Lean project. Reports violations.
---

Run the integrity-check pipeline and report. The blueprint dep graph is the source of truth for formalization state (post-2026-06-02 transition); this skill verifies that the rest of the repo is consistent with it.

Do this:

1. **Lean project builds.**
   Run `lake build` from the repo root. Capture stdout, stderr, exit code.
   - Pass: 0 errors; sorry-warnings only at theorem positions matching `ComputableAnalysis/L4/Instances/CMap.lean:261` (the L4 instance A1/A2/A3 sorries) — or whatever the user has documented as expected. Anything else → report.

2. **Blueprint LaTeX renders.**
   Run `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web` (requires the `.venv` from the 2026-06-02 transition). Pass: exits 0 with `INFO: ` messages and HTML files under `blueprint/web/`. Fail: report the plasTeX error tail.

3. **Every `\lean{...}` resolves.**
   Run `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls`. Pass: exit 0, no output. Fail: report the unresolved declaration(s); the fix is either to correct the `\lean{...}` macro in `blueprint/src/*.tex` or to add the missing decl in `ComputableAnalysis/**`.

4. **Every claim satellite's `[[blueprint:label]]` pointer resolves.**
   ```bash
   # Collect blueprint labels:
   grep -rEo '\\label\{[^}]+\}' blueprint/src/*.tex | sed 's/.*\\label{\([^}]*\)}.*/\1/' | sort -u > /tmp/bp_labels
   # Collect satellite pointers:
   grep -rEo '\[\[blueprint:[^]]+\]\]' claims/ | sed 's/.*\[\[blueprint:\([^]]*\)\]\].*/\1/' | sort -u > /tmp/sat_pointers
   # Pointers without a matching label:
   comm -23 /tmp/sat_pointers /tmp/bp_labels
   ```
   For each non-resolving pointer, report it; suggest either updating the pointer to the actual label or adding the missing `\label{...}` in blueprint LaTeX.

5. **Legacy provenance scripts (claim YAML + literature pointers).**
   These still run on the pre-existing claim files (`l1-computable-reals/`, `l3-computability-structure/`) that have not yet been migrated to satellite form.
   - `.venv/bin/python scripts/verify_claims.py` — exit code + summary.
   - `.venv/bin/python scripts/verify_provenance.py` — exit code + summary.
   For each violation, suggest a specific fix:
   - Missing frontmatter → "add YAML frontmatter with `id`, `created`."
   - Invalid status (legacy claim files) → "use one of `intuition` / `conjecture` / `our_construction` / `cited_result` / `verified` / `refuted`, or migrate the claim to satellite form (see `claims/TEMPLATE.md` post-2026-06-02)."
   - `cited_result` / `verified` with empty sources → "add a `sources:` list with at least one `<bibkey>:<locator>`."
   - Unknown dependency id → "either correct the id or create the missing claim file."
   - Missing literature paper → "run `scripts/fetch_arxiv.py <arxiv-id> <bibkey>` to seed it, then extract the verbatim statement."

6. **Report.**
   - If all 5 checks pass: report `OK — blueprint state matches Lean project; all declarations resolve; legacy claim files clean`.
   - Otherwise: report each failing check with its specific violation + suggested fix.
   - Do NOT auto-fix unless the user asks. Reporting is the default.

Hard rules:
- Never modify `blueprint/src/`, `ComputableAnalysis/`, or `claims/` from inside `/verify`. Read-only.
- Step 3 (`checkdecls`) depends on Step 2 (`web` populates `blueprint/lean_decls`). Run them in order.
