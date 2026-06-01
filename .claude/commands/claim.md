---
description: Promote an idea to a structured claim with status + provenance.
argument-hint: <topic-slug> <claim-id>
---

Promote an idea into a structured claim.

Arguments: `$ARGUMENTS` is `<topic-slug> <claim-id>` (two whitespace-separated tokens).

Do this:

1. Parse `<topic-slug>` and `<claim-id>` from `$ARGUMENTS`. If `<claim-id>` does not already start with `<topic-slug>-`, prepend it (so the id has a canonical form like `topic-something`).
2. If `claims/<topic-slug>/<claim-id>.md` exists, STOP and tell the user — do not overwrite.
3. Ask the user:
   - **Status** — one of: `intuition`, `conjecture`, `our_construction`, `cited_result`, `verified`, `refuted`. Refuse `verified` unless they can name an existing proof attempt + a passing devil's-advocate / proof-reviewer verdict.
   - **One-line statement** (the H1 of the file)
   - **Formal statement** (the precise theorem-form text). If they cannot give this, recommend invoking the `formalizer` subagent first on the relevant intuition prose.
   - **Informal restatement** (one paragraph)
   - **Why we believe it** (provenance)
   - **Dependencies** (other claim ids; can be empty)
   - **Sources** — REQUIRED if status is `cited_result` or `verified`. Format: `<bibkey>:<locator>` where `<bibkey>` is a directory under `literature/papers/`.
4. Create `claims/<topic-slug>/<claim-id>.md` by filling `claims/TEMPLATE.md` with the inputs.
5. If status is `cited_result`, verify each `<bibkey>` resolves to `literature/papers/<bibkey>/`. If not, ask the user to fetch the paper via `scripts/fetch_arxiv.py` first.
6. Run `scripts/verify_claims.py`. Report any violations and ask the user to fix.

**Hard rules**:
- Do NOT auto-populate `Devil's-advocate verdict` — that comes from the subagent.
- Status `verified` requires both a complete proof in `proofs/<topic-slug>/<claim-id>/` and a `passes` verdict from `devils-advocate`. Refuse otherwise.
- Status `refuted` requires a counterexample or refuting argument in the body.
