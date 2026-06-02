---
description: Promote an idea to a structured rationale satellite + write the canonical statement into the blueprint LaTeX.
argument-hint: <topic-slug> <claim-id> <blueprint-label>
---

Promote an idea into a structured **rationale satellite** under `claims/`, and write the canonical statement into `blueprint/src/<chapter>.tex` (the source of truth for formalization state post-2026-06-02 transition).

Arguments: `$ARGUMENTS` is `<topic-slug> <claim-id> <blueprint-label>` (three whitespace-separated tokens). `<blueprint-label>` is the `\label{...}` used in blueprint LaTeX, typically of the form `def:foo` / `lem:bar` / `thm:baz` (matching blueprint convention).

Do this:

1. Parse `<topic-slug>`, `<claim-id>`, and `<blueprint-label>` from `$ARGUMENTS`. If `<claim-id>` does not already start with `<topic-slug>-`, prepend it. Normalize `<blueprint-label>` to lowercase if it isn't already.

2. If `claims/<topic-slug>/<claim-id>.md` exists, STOP and tell the user — do not overwrite.

3. If `<blueprint-label>` already appears as a `\label{...}` anywhere in `blueprint/src/*.tex`, STOP and tell the user — labels must be globally unique. Suggest a disambiguated label.
   ```bash
   grep -nE "\\\\label\{${LABEL}\}" blueprint/src/*.tex
   ```

4. Ask the user:
   - **Layer** — which chapter file the LaTeX block lands in: `L0`, `L1`, ..., `L5`. Map from `<topic-slug>` if obvious.
   - **Environment** — one of: `definition` / `lemma` / `theorem` / `proposition` / `corollary` / `remark` (only these appear in the dep graph; remark does not). For pre-formal ideas (no statement yet) use `remark` and add `\notready`.
   - **One-line statement** — the H1 of the satellite file and the body of the LaTeX env.
   - **Formal statement** (LaTeX) — the precise theorem-form text that goes inside `\begin{<env>}...\end{<env>}`. Use `\texttt{Name}` for type / function names; standard `amssymb` macros (`\mathbb{R}`, `\to`, `\le`).
   - **`\uses{}` dependencies** — comma-separated list of other blueprint labels this depends on (can be empty). Use `[[blueprint:label]]` form in the satellite's prose.
   - **Sources** — REQUIRED if the env is `theorem` / `proposition` and the result is cited from literature. Format: `<bibkey>:<locator>` where `<bibkey>` is a directory under `literature/papers/`.
   - **Mathlib-idiom mapping** — one paragraph: which Mathlib types/namespaces this hooks into, why this shape vs. alternatives.
   - **Alternatives considered** — bullet list of approaches rejected and why.

5. **Write the LaTeX block** to `blueprint/src/<layer>.tex` (append to the appropriate section, or create a new section). Start the env with `\notready` — the L1-L5 stubs already use this pattern; the `\lean{...}\leanok` toggles come later under `/formalize`.
   ```latex
   \begin{<env>}
     \label{<blueprint-label>}
     \notready
     [optionally: \uses{dep1, dep2}]
     <formal statement>
   \end{<env>}
   ```

6. **Create the rationale satellite** at `claims/<topic-slug>/<claim-id>.md` by filling `claims/TEMPLATE.md` with:
   - `blueprint: blueprint:<blueprint-label>` (the post-2026-06-02 frontmatter field)
   - `[[blueprint:<blueprint-label>]]` pointer at top of body
   - the rationale, alternatives, sources, Mathlib mapping the user supplied
   - **no formal statement section** — that's now in blueprint LaTeX

7. **Verify the blueprint LaTeX still renders.** Run:
   ```bash
   PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web
   ```
   If plasTeX fails, restore the prior `blueprint/src/<layer>.tex` and report the error.

8. **Verify the legacy provenance scripts still pass** (they still run on satellite YAML):
   ```bash
   .venv/bin/python scripts/verify_claims.py
   ```
   Report any violations and ask the user to fix.

9. **Report.** Tell the user: blueprint LaTeX block at `blueprint/src/<layer>.tex:<line>` (`\notready`), satellite at `claims/<topic-slug>/<claim-id>.md`. Suggest next step: `/formalize <claim-path>` when the user is ready to write Lean against this statement.

**Hard rules**:
- Do NOT auto-populate `da_status` in the satellite — that comes from the devil's-advocate subagent.
- The `\leanok` / `\mathlibok` markers are NEVER added by `/claim`. They are added only by `/formalize` after Lean type-checks and `checkdecls` passes.
- Refuse to write a `theorem` / `proposition` env without sources if the result is presented as cited (informal "from the literature" without a `bibkey:locator` pointer is a verification gap).
- If the satellite's YAML has `da_status: unsound` or `refuted`, the blueprint LaTeX block must be marked `\notready` (or removed entirely). Never `\leanok` a refuted statement.
