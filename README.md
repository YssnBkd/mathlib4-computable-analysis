# research-template

Boilerplate for a Claude-Opus-driven research environment with `/goal` autonomous iteration, intuition-first / provenance-first workflow, and four specialized subagents (`devils-advocate`, `lit-scout`, `formalizer`, `proof-reviewer`).

Clone this directory, rename it, and start a new research stream. Nothing here is project-specific.

## What you get

- **`CLAUDE.md`** — the operating protocol (status taxonomy, eight rules, when to use what).
- **`BOOTSTRAP.md`** — what to load into context at session start.
- **`/goal` autonomous-iteration pattern** — Stop hook at `scripts/goal_stop_hook.py` keeps Claude iterating across turns until success criteria are met or budget is exhausted.
- **Four subagents** at `.claude/agents/` — independent verifiers (the proposer is never the verifier).
- **Slash commands** at `.claude/commands/` — `/intuition`, `/intuition-prep`, `/claim`, `/goal`, `/goal-end`, `/devils-advocate`, `/verify`, `/record`.
- **Provenance scripts** at `scripts/` — `verify_claims.py` and `verify_provenance.py` enforce the status taxonomy and citation discipline.
- **Templates** — `intuition/TEMPLATE.md`, `claims/TEMPLATE.md`, and `.claude/templates/literature-goal.md` (the 4-criterion literature-ingestion goal).
- **One worked example** under `intuition/example-collatz.md` and `claims/example-collatz/` — delete (or replace) once you start your own work.

## Quick start

```bash
# 1. Clone and rename
cp -R research-template my-project && cd my-project

# 2. Set up the Python venv used by hooks and scripts (stdlib-only hooks
#    still work without it; venv is needed for the optional sympy / arxiv deps).
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt

# 3. Initialize git
git init && git add -A && git commit -m "init from research-template"

# 4. Delete the worked example (optional)
rm -rf intuition/example-collatz.md claims/example-collatz
#    Then edit intuition/INDEX.md and claims/INDEX.md to remove the example rows.

# 5. Open in Claude Code; the slash commands are loaded automatically.
#    Start a thread:
#      /intuition <new-topic>
#    or, if you have raw multi-thread soup:
#      /intuition-prep
#    Then promote to a goal:
#      /goal <slug>
#    First prompt: "Begin. Iterate toward the goal."
```

The Stop hook at `scripts/goal_stop_hook.py` drives Claude across multiple turns until the goal's verifiable criteria are met or a budget is exhausted.

## Read before doing anything

- `CLAUDE.md` — operating protocol (status taxonomy, rules, when to use what).
- `BOOTSTRAP.md` — what to load at session start.

## Layout

```
intuition/    prose-first mental models (entry point)
claims/       statements with status label + provenance
proofs/       proof attempts tied to claim ids
literature/   parsed/extracted statements from sources
raw_papers/   canonical PDFs and source bundles
thinking/     curated extended-thinking traces
.goals/       per-goal logs (iter-NN.md, reviews/, final.md)
lakefile.toml + ComputableAnalysis/ + .lake/    Lean 4 project at git root (was nested under formal/ pre-2026-06-02)
blueprint/    leanblueprint LaTeX sources (added 2026-06-02 transition)
scripts/      hooks + verifiers + fetcher (stdlib-only hooks)
archive/      session JSONL + checkpoint ledger (via /record)
```

## Hook configuration

`.claude/settings.json` already wires:

- **Stop hook** → `scripts/goal_stop_hook.py` (drives autonomous iteration)
- **UserPromptSubmit hook** → `scripts/goal_prompt_hook.py` (prepends goal context to each prompt when a goal is active)
- **Permissions allowlist** — generic git, python, web-fetch domains commonly needed by `lit-scout`. Add more domains as your research demands.

The hooks are pure-stdlib Python; they do not depend on `.venv/`. They will silently no-op if `current-goal.md` is empty.

## Renaming this template

Nothing in the scaffold references the directory name. Safe to `mv research-template <whatever>` and continue.
