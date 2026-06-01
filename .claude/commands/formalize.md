---
description: Formalize a claim into Lean 4 / Mathlib4 under formal/L<N>/. Runs env preflight; loads the PhD-prodigy persona; orchestrates stub → fill → verify → devil's-advocate handoff inside /goal.
argument-hint: <claim-path-or-id-or-empty>
---

The user is invoking `/formalize` on `$ARGUMENTS`.

This skill drives a single Lean formalization pass: one claim → one Lean file under `formal/L<N>/<path>.lean`, type-checked against the pinned Mathlib4 commit, with paper provenance preserved.

# What you receive

`$ARGUMENTS` is one of:
- A claim file path, e.g. `claims/l3-computability-structure/axioms.md`
- A topic-slug + claim-id pair, e.g. `l3-computability-structure axioms`
- A bare claim id, e.g. `axioms` (only valid if a /goal is active and there's exactly one matching claim under `claims/<active-topic>/`)
- Empty — only valid if a `/goal` is active and `current-goal.md` references exactly one claim with a `lean_target:` not yet started

If you cannot resolve a single claim, STOP and ask the user to disambiguate.

# What you do

Phases are numbered. Do them in order. The persona doc at `.claude/templates/lean-prodigy-persona.md` is the disposition you operate under for the entire session — **read it before Phase 1**, every time.

## Phase 0 — Environment preflight (always; uses watermark)

1. Run `python3 scripts/formalize_env_check.py --json`. Parse the final line.
   - `OK_fast` — watermark matched, smoke test passed → proceed
   - `OK_cold` — cold rebuild completed → proceed
   - `NEEDS_INIT` — `formal/` is not initialized → ask the user "may I run `python3 scripts/formalize_env_check.py --init` to scaffold lakefile.toml + lean-toolchain + ComputableAnalysis.lean?". If yes, run it, then ask the user to run `cd formal && lake update && lake exe cache get && lake build` (this can take 10–30 min the first time), then re-invoke `/formalize`. STOP.
   - `NO_LEAN` / `NO_LAKE` — toolchain missing → print the install hint from the script output. STOP.
   - `BUILD_FAIL` / `SMOKE_FAIL` — Lean build broken before we even started → STOP, surface the diagnostic. Do not attempt to "fix" via Lean code; the project's build is the user's call.

2. If preflight is `OK_*`, continue. Otherwise STOP — do NOT proceed to formalization with a broken env.

## Phase 1 — Load the persona, then the context

3. Read `.claude/templates/lean-prodigy-persona.md` in full. This is the character.
4. Skim `.claude/templates/lean-toolkit.md` table of contents; mark which sections (§1 search, §2 tactics, §3 naming, §4 anti-patterns, §5 area-map, §6 kernel commands) you may need to revisit during the session.
5. Resolve the target claim from `$ARGUMENTS`. Read its full content. Verify:
   - frontmatter has `status: our_construction | conjecture | cited_result` (other statuses are not Lean targets)
   - frontmatter has `lean_target: formal/L<N>/<path>.lean`
   - the formal statement and the source pointer (`literature/papers/<key>:LINE` for `cited_result`)
   If any of these are missing, STOP — the claim is not ready to formalize. Ask the user to update it.
6. Read the dependency claims (the `dependencies:` list in frontmatter) — each as a brief sanity check that the names you'll reference are already (or will be) declared somewhere.
7. Read the source: `literature/papers/<key>/...` opened at the cited line, ±20 lines for context.
8. Read the relevant intuition file: `intuition/<topic>.md` if one exists.
9. If `current-goal.md` is active, read its allow_writes and confirm `formal/**` is included. If not, STOP and ask the user to extend allow_writes — the Stop hook will HALT otherwise.

## Phase 2 — Externalize the Lean plan

10. Write a Lean plan to `thinking/<topic>/lean-plan-<claim-id>-<YYYY-MM-DD>.md`. The plan covers:
    - **Target file**: `formal/L<N>/<path>.lean` (from `lean_target:`)
    - **Namespace**: `ComputableAnalysis.L<N>` (with a sub-namespace if multiple sibling concepts land in the same file)
    - **Mathlib hooks**: which existing Mathlib types/typeclasses we attach to. Quote the import path. Use `.claude/templates/lean-toolkit.md §5` as the starting map; verify with `exact?` / `#check` against the live Mathlib.
    - **New symbols to declare**: definitions / structures / classes / instances (these are the *no-sorry* surface) + theorems / lemmas (sorry allowed during development).
    - **Search ladder results**: for each candidate sub-lemma, what the search engines returned. "Found `Finset.sum_const` — will use" vs. "Nothing in Mathlib — will state as our `lemma`".
    - **Dependencies on other layers**: forward references to symbols expected to exist in lower-numbered layers, with a `-- TODO(/formalize L<N-1>):` marker if the dep isn't yet formalized.
    - **Conflict check against CLAUDE.md anti-goals**: explicitly verify the plan does not introduce TTE / represented spaces / `ℝ_c` / Bishop-style reformulations.

11. **If the plan introduces any of these high-blast-radius elements, STOP and ask the user before proceeding**:
    - A new typeclass hierarchy
    - A non-`Is`-prefixed predicate (i.e., a *type* rather than a `Prop`-valued predicate)
    - A definition that diverges from the Mathlib naming convention
    - Anything that touches the `ComputabilityStructure` keystone (L3) — the L3 axioms are the architectural backbone; we treat them as carefully as a Mathlib `structure` definition

## Phase 3 — Stub the Lean file

12. If `formal/L<N>/<path>.lean` does not exist, create it with the Mathlib file-header convention (see `lean-toolkit.md §3 — File-header convention`). Replace `<Author Name>` with `the mathlib-computable-analysis contributors`. The `## References` block points to the canonical `literature/papers/<key>:LINE`.

13. Inside the file:
    - `import` block — only the Mathlib modules used.
    - `namespace ComputableAnalysis.L<N>` opening.
    - `variable` declarations for shared typeclass arguments.
    - **Definitions / structures / classes / instances** — concrete bodies. *No `sorry` permitted here* (R4 in the persona). If you cannot supply a concrete body, the milestone is not ready — STOP.
    - **Theorems / lemmas** — signature + `:= by sorry`. Group by topic.
    - **Smoke checks** — a `-- ## Smoke checks` block at the end with `#check` for each exported symbol.
    - `end ComputableAnalysis.L<N>`.

14. `cd formal && lake env lean L<N>/<path>.lean` (single-file check, faster than `lake build`). Fix import / signature / typeclass issues until this exits 0. If `lake env lean` complains about a missing module, the issue is the import line, *not* the proof — fix the import.

15. Once the single-file check passes, run `cd formal && lake build` to confirm the full project still builds.

## Phase 4 — Fill proofs (only for theorems / lemmas)

This phase applies only when the claim's `status` is `conjecture` or when the user has explicitly asked for proofs. For `our_construction` claims (definitions), Phase 3 ends the session.

16. For each `sorry` in a theorem body, in dependency order:
    a. `intro` the hypotheses; observe the goal in the infoview (or via `lake env lean` errors when you stub `:= by intro h; sorry`).
    b. Search ladder (see `lean-toolkit.md §1`): `exact?`, `apply?`, `rw?`, loogle, LeanSearch.
    c. Tactic ladder (`lean-toolkit.md §2`): the most specific first. `ring`, `linarith`, `field_simp; ring`, `gcongr`, `polyrith`, `omega`, `positivity`, `norm_num`, `aesop`.
    d. If the proof is non-trivial, decompose with `suffices` (backward) or `have` (forward). Use `calc` blocks for chains.
    e. After each filled `sorry`, `lake env lean L<N>/<path>.lean` to confirm.

17. **The three-attempt rule.** If after three substantive attempts a theorem will not close, leave `sorry` and a `-- TODO(/formalize): <one-line obstruction>` comment. Move on. *Do not spin.* The TODO is the honest record; the next session (or a different angle) picks it up.

18. After filling, run `#print axioms <theorem_name>` for each filled theorem (see `lean-toolkit.md §7`). The acceptable axioms are `Classical.choice`, `Quot.sound`, `propext`. If `sorryAx` appears, the proof has a hidden `sorry` — find and fix it before considering the theorem closed.

## Phase 5 — Verify

19. `cd formal && lake build` — must exit 0.

20. Grep the file for `sorry` in *forbidden positions*:
    ```bash
    grep -nE '^(def|structure|class|instance|abbrev)\b' formal/L<N>/<path>.lean
    ```
    For each definition/structure/class/instance, inspect its body and confirm no `sorry`. If any forbidden `sorry` appears, the file is not committable — STOP and either supply a concrete body or remove the declaration.

21. Count `sorry` in theorem positions; record the number for the session log.

22. Run the smoke checks: `cd formal && lake env lean L<N>/<path>.lean` (or the dedicated `formal/Tests/L<N>/<path>.lean` if one exists) and confirm each `#check` resolves.

## Phase 6 — Handoff

23. Update the claim file's frontmatter: add a line like `lean_status: stub_typechecks` (definitions concrete, theorems with sorries) or `lean_status: complete` (everything closed). Keep the paper claim's `status` field unchanged — the *paper* status is unaffected by Lean progress.

24. If a `/goal` is active, write a `progress:` entry to `.goals/<slug>/iter-<NN>.md`:
    ```
    progress: formal/L<N>/<path>.lean type-checks; 0 def-sorry, N thm-sorry; symbols exported: <list>
    files_changed: ['formal/L<N>/<path>.lean', 'thinking/<topic>/lean-plan-<id>-<date>.md', 'claims/<topic>/<id>.md']
    ```

25. Suggest the user run `/devils-advocate <criterion-id>`. Per `CLAUDE.md` §"Devil's-advocate review under Lean", the reviewer will read the claim file, the cited verbatim source, and the Lean stub together. The verdict `passes` is required before the milestone's Lean criterion in `current-goal.md` can be marked `[x]`.

26. Report to the user: file path, theorem count, sorry count by position, suggested next action.

# Hard rules

- **Phase 0 is non-optional.** Every invocation runs the env-check script. The watermark is the fast path; you do not skip the script. A broken Lean env at session start means STOP, not "try anyway".
- **No `sorry` in `def` / `structure` / `class` / `instance` / `abbrev` bodies.** Persona R4, CLAUDE.md commitment #6. The skill REFUSES to write such a file — if the body is not concrete, the milestone is not ready.
- **No invented Mathlib symbols.** If `exact?` and loogle did not find it, the symbol does not exist. Do not write `Real.something_we_hope_exists` and pray. State the missing lemma as its own `lemma` (with a sorry, if proof is non-trivial) and surface it as a dependency.
- **No anti-goal drift.** TTE / represented spaces / `RepresentedSpace` / oracle Turing machines / Baire-space realizers / `ℝ_c` / Bishop reformulation — all forbidden. Persona §9, CLAUDE.md "Anti-goals". When you find yourself drifting, STOP and write the conflict to `thinking/<topic>/lean-conflict-<date>.md`.
- **Mathlib naming and style are enforced.** American English. snake_case proofs. UpperCamelCase types/classes/structures. `Is`-prefix for noun predicates. 100-char lines. 2-space proof indent. `Type*` not `Type 0`. `autoImplicit false`. See `lean-toolkit.md §3`.
- **AI use disclosed in commit messages.** Mathlib4 policy applies: every commit message under `formal/` notes `tactics drafted by Claude under /formalize; verified by lake build`. Every `sorry` you leave has a `-- TODO(/formalize):` comment naming the obstruction.
- **The proposer is never the verifier.** This skill produces the Lean stub. Devil's-advocate (paper + Lean) reviews before the criterion can be marked done. Do not auto-mark.
- **Do not edit `CLAUDE.md`, `BOOTSTRAP.md`, `claims/`, or `literature/papers/`.** These are out of scope. If you discover the *claim* needs revision (statement is imprecise, hypotheses are wrong), write the finding to `thinking/<topic>/` and surface to the user — let them update the claim.
- **The three-attempt rule.** Do not spin on a single `sorry`. Three substantive tries, then `-- TODO`, move on. The session is bounded.

# When to use which subagent

- `formalizer` (`.claude/agents/formalizer.md`) — invoke at Phase 1 if the *claim file* is imprecise (informal statement still has English glue, hypotheses underspecified). Convert the prose into theorem-form before stubbing in Lean.
- `lit-scout` (`.claude/agents/lit-scout.md`) — invoke at Phase 2 if you suspect Mathlib has a related result not yet in our `literature/`. Use sparingly; usually `exact?` / loogle suffices for in-Mathlib lookups.
- `devils-advocate` (`.claude/agents/devils-advocate.md`) — invoked by the user via `/devils-advocate` at Phase 6, not by you directly.
- `proof-reviewer` (`.claude/agents/proof-reviewer.md`) — invoke at Phase 5 if the proof is long (>30 lines) and you want a line-by-line scrutiny before handoff.

# Recovery

If the session is interrupted (context exhausted, user paused, kernel crashed), the recovery is to re-invoke `/formalize <same-claim>`. Phase 0 will re-validate the env (probably fast-path via watermark). Phase 1 will reload the persona and context. Phase 3 will detect the partial stub and pick up where the previous session stopped (look for existing definitions; preserve them; continue filling theorems with sorries).

The `thinking/<topic>/lean-plan-<id>-<date>.md` from a prior session is the resumption point — read it first.
