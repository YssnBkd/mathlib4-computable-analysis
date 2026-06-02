---
description: Formalize a claim into Lean 4 / Mathlib4 under ComputableAnalysis/L<N>/. Runs env preflight; loads the PhD-prodigy persona; orchestrates stub → fill → verify → blueprint-leanok → devil's-advocate handoff inside /goal.
argument-hint: <claim-path-or-id-or-empty>
---

The user is invoking `/formalize` on `$ARGUMENTS`.

This skill drives a single Lean formalization pass: one claim satellite → one Lean file under `ComputableAnalysis/L<N>/<path>.lean`, type-checked against the pinned Mathlib4 commit, with paper provenance preserved AND the corresponding blueprint LaTeX node toggled from `\notready` to `\lean{<decl>}\leanok` on success.

> **Post-2026-06-02 transition note.** Lake project is at git root (no more `cd formal &&`). The blueprint at `blueprint/src/*.tex` is the canonical source for formalization state. Every formalization handoff updates the blueprint LaTeX so the dep graph reflects the new green node.

# What you receive

`$ARGUMENTS` is one of:
- A claim file path, e.g. `claims/l3-computability-structure/axioms.md`
- A topic-slug + claim-id pair, e.g. `l3-computability-structure axioms`
- A bare claim id, e.g. `axioms` (only valid if a /goal is active and there's exactly one matching claim under `claims/<active-topic>/`)
- Empty — only valid if a `/goal` is active and `current-goal.md` references exactly one claim with a `blueprint:` field not yet `\leanok`

If you cannot resolve a single claim, STOP and ask the user to disambiguate.

# What you do

Phases are numbered. Do them in order. The persona doc at `.claude/templates/lean-prodigy-persona.md` is the disposition you operate under for the entire session — **read it before Phase 1**, every time.

## Phase 0 — Environment preflight (always; uses watermark)

1. Run `python3 scripts/formalize_env_check.py --json`. Parse the final line.
   - `OK_fast` — watermark matched, smoke test passed → proceed
   - `OK_cold` — cold rebuild completed → proceed
   - `NEEDS_INIT` — Lake project not initialized → ask the user "may I run `python3 scripts/formalize_env_check.py --init` to scaffold lakefile.toml + lean-toolchain + ComputableAnalysis.lean at git root?". If yes, run it, then ask the user to run `lake update && lake exe cache get && lake build` (this can take 10–30 min the first time), then re-invoke `/formalize`. STOP.
   - `NO_LEAN` / `NO_LAKE` — toolchain missing → print the install hint from the script output. STOP.
   - `BUILD_FAIL` / `SMOKE_FAIL` — Lean build broken before we even started → STOP, surface the diagnostic. Do not attempt to "fix" via Lean code; the project's build is the user's call.

2. If preflight is `OK_*`, continue. Otherwise STOP — do NOT proceed to formalization with a broken env.

## Phase 1 — Load the persona, then the context

3. Read `.claude/templates/lean-prodigy-persona.md` in full. This is the character.
4. Skim `.claude/templates/lean-toolkit.md` table of contents; mark which sections (§1 search, §2 tactics, §3 naming, §4 anti-patterns, §5 area-map, §6 kernel commands) you may need to revisit during the session.
5. Resolve the target claim from `$ARGUMENTS`. Read its full content. Two cases:
   - **Satellite-format claim** (post-2026-06-02): has `blueprint:` frontmatter field pointing at `blueprint:<label>`. Pull `<label>` and find the corresponding `\label{<label>}` in `blueprint/src/<layer>.tex`. The LaTeX env between `\label` and the next `\end{...}` is the canonical statement. The satellite's prose is rationale; do not transcribe the prose into the Lean file (only the formal statement).
   - **Legacy-format claim** (pre-2026-06-02): has YAML `status: ...` + a `## Formal statement` body. Treat the formal-statement body as authoritative. If no blueprint label exists yet for this claim, propose adding one in Phase 6 (suggest a `<env>:<slug>` label) and STOP before Phase 2 to confirm with the user.

6. Verify the claim has:
   - `lean_target: ComputableAnalysis/L<N>/<path>.lean` (or equivalent — the canonical target path)
   - a source pointer for cited results (`literature/papers/<key>:LINE`)
   If missing, STOP — the claim is not ready to formalize. Ask the user to update it.

7. Read the dependency claims/satellites — each as a brief sanity check that the names you'll reference exist (or will exist).

8. Read the source: `literature/papers/<key>/...` opened at the cited line, ±20 lines for context.

9. Read the relevant intuition file: `intuition/<topic>.md` if one exists.

10. If `current-goal.md` is active, read its allow_writes and confirm both `ComputableAnalysis/**` AND `blueprint/src/**` are included (Phase 6 toggles blueprint). If not, STOP and ask the user to extend allow_writes — the Stop hook will HALT otherwise.

## Phase 2 — Externalize the Lean plan

11. Write a Lean plan to `thinking/<topic>/lean-plan-<claim-id>-<YYYY-MM-DD>.md`. The plan covers:
    - **Target file**: `ComputableAnalysis/L<N>/<path>.lean` (from `lean_target:` field)
    - **Target blueprint label**: `<env>:<label>` (from claim satellite's `blueprint:` field)
    - **Namespace**: `ComputableAnalysis.L<N>` (with a sub-namespace if multiple sibling concepts land in the same file)
    - **Mathlib hooks**: which existing Mathlib types/typeclasses we attach to. Quote the import path. Use `.claude/templates/lean-toolkit.md §5` as the starting map; verify with `exact?` / `#check` against the live Mathlib.
    - **New symbols to declare**: definitions / structures / classes / instances (these are the *no-sorry* surface) + theorems / lemmas (sorry allowed during development).
    - **Search ladder results**: for each candidate sub-lemma, what the search engines returned.
    - **Dependencies on other layers**: forward references to symbols expected to exist in lower-numbered layers, with a `-- TODO(/formalize L<N-1>):` marker if the dep isn't yet formalized.
    - **Conflict check against CLAUDE.md commitments**: explicitly verify the plan does not introduce TTE / represented spaces / `ℝ_c` / Bishop-style reformulations.

12. **If the plan introduces any of these high-blast-radius elements, STOP and ask the user before proceeding**:
    - A new typeclass hierarchy
    - A non-`Is`-prefixed predicate (i.e., a *type* rather than a `Prop`-valued predicate)
    - A definition that diverges from the Mathlib naming convention
    - Anything that touches the `ComputabilityStructure` keystone (L3) — the L3 axioms are the architectural backbone; we treat them as carefully as a Mathlib `structure` definition

## Phase 3 — Stub the Lean file

13. If `ComputableAnalysis/L<N>/<path>.lean` does not exist, create it with the Mathlib file-header convention (see `lean-toolkit.md §3 — File-header convention`). Replace `<Author Name>` with `the mathlib-computable-analysis contributors`. The `## References` block points to the canonical `literature/papers/<key>:LINE`.

14. Inside the file:
    - `import` block — only the Mathlib modules used.
    - `namespace ComputableAnalysis.L<N>` opening.
    - `variable` declarations for shared typeclass arguments.
    - **Definitions / structures / classes / instances** — concrete bodies. *No `sorry` permitted here* (R4 in the persona). If you cannot supply a concrete body, the milestone is not ready — STOP.
    - **Theorems / lemmas** — signature + `:= by sorry`. Group by topic.
    - **Smoke checks** — a `-- ## Smoke checks` block at the end with `#check` for each exported symbol.
    - `end ComputableAnalysis.L<N>`.

15. `lake env lean ComputableAnalysis/L<N>/<path>.lean` (single-file check from git root, faster than `lake build`). Fix import / signature / typeclass issues until this exits 0. If `lake env lean` complains about a missing module, the issue is the import line, *not* the proof — fix the import.

16. Once the single-file check passes, run `lake build` to confirm the full project still builds.

## Phase 4 — Fill proofs (only for theorems / lemmas)

This phase applies only when the claim's content is a theorem / lemma (not a pure `our_construction` definition). For definition-only claims, Phase 3 ends the session.

17. For each `sorry` in a theorem body, in dependency order:
    a. `intro` the hypotheses; observe the goal in the infoview (or via `lake env lean` errors when you stub `:= by intro h; sorry`).
    b. Search ladder (see `lean-toolkit.md §1`): `exact?`, `apply?`, `rw?`, loogle, LeanSearch.
    c. Tactic ladder (`lean-toolkit.md §2`): the most specific first. `ring`, `linarith`, `field_simp; ring`, `gcongr`, `polyrith`, `omega`, `positivity`, `norm_num`, `aesop`.
    d. If the proof is non-trivial, decompose with `suffices` (backward) or `have` (forward). Use `calc` blocks for chains.
    e. After each filled `sorry`, `lake env lean ComputableAnalysis/L<N>/<path>.lean` to confirm.

18. **The three-attempt rule.** If after three substantive attempts a theorem will not close, leave `sorry` and a `-- TODO(/formalize): <one-line obstruction>` comment. Move on. *Do not spin.* The TODO is the honest record; the next session (or a different angle) picks it up.

19. After filling, run `#print axioms <theorem_name>` for each filled theorem (see `lean-toolkit.md §7`). The acceptable axioms are `Classical.choice`, `Quot.sound`, `propext`. If `sorryAx` appears, the proof has a hidden `sorry` — find and fix it before considering the theorem closed.

## Phase 5 — Verify

20. `lake build` — must exit 0.

21. Grep the file for `sorry` in *forbidden positions*:
    ```bash
    grep -nE '^(def|structure|class|instance|abbrev)\b' ComputableAnalysis/L<N>/<path>.lean
    ```
    For each definition/structure/class/instance, inspect its body and confirm no `sorry`. If any forbidden `sorry` appears, the file is not committable — STOP and either supply a concrete body or remove the declaration.

22. Count `sorry` in theorem positions; record the number for the session log.

23. Run the smoke checks: `lake env lean ComputableAnalysis/L<N>/<path>.lean` and confirm each `#check` resolves.

24. **Blueprint declaration validation.** Run:
    ```bash
    PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web      # regenerates blueprint/lean_decls
    PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls
    ```
    If `checkdecls` reports an unresolved decl from your new code, it means a `\lean{...}` macro you'll add in Phase 6 won't resolve. Fix the macro target name before Phase 6.

## Phase 6 — Blueprint toggle + handoff

25. **Toggle the blueprint LaTeX from `\notready` to `\lean{...}\leanok`.** Open `blueprint/src/<layer>.tex` at the `\label{<blueprint-label>}` env. Replace `\notready` with `\lean{<fully.qualified.DeclName1>, <fully.qualified.DeclName2>}\leanok`. For a theorem whose proof depends on other lemmas you stubbed, also add `\uses{<dep-label1>, <dep-label2>}` if not already present.

26. **Re-run `leanblueprint web` + `checkdecls`** to confirm the toggled env still resolves. If `checkdecls` complains about the new `\lean{...}` macro, the decl name is wrong — fix the macro before continuing.

27. **Visual check** the dep graph: open `blueprint/web/dep_graph_document.html` (or grep for the label):
    ```bash
    grep -A1 "<blueprint-label>" blueprint/web/dep_graph_document.html | head -5
    ```
    Confirm the node is now `color=green` (or `color="#B0ECA3"` for definitions with filled boxes). If still orange (`#FFAA33`), the `\notready` wasn't fully removed.

28. **Update the claim satellite** at `claims/<topic-slug>/<claim-id>.md`:
    - For satellite-format claims: no change needed; the blueprint dep-graph color is now authoritative for "formalized". Add a one-line note to the satellite's `## Notes for future revisions` section: "`\leanok` set on YYYY-MM-DD; current dep-graph state captured at blueprint/web/dep_graph_document.html".
    - For legacy-format claims that we're treating in-place: update YAML `lean_status: complete` (definitions concrete + theorems closed) or `lean_status: stub_typechecks` (definitions concrete + theorems have sorries). The paper-status field (`status:`) is unaffected.

29. If a `/goal` is active, write a `progress:` entry to `.goals/<slug>/iter-<NN>.md`:
    ```
    progress: ComputableAnalysis/L<N>/<path>.lean type-checks; 0 def-sorry, N thm-sorry; symbols exported: <list>; blueprint <blueprint-label> toggled to \leanok
    files_changed: ['ComputableAnalysis/L<N>/<path>.lean', 'blueprint/src/<layer>.tex', 'thinking/<topic>/lean-plan-<id>-<date>.md', 'claims/<topic-slug>/<claim-id>.md']
    ```

30. Suggest the user run `/devils-advocate <criterion-id>`. Per `CLAUDE.md` §"Devil's-advocate review under Lean", the reviewer will read the claim satellite, the cited verbatim source, the Lean file, AND the blueprint LaTeX together. The verdict `passes` is required before the milestone's Lean criterion in `current-goal.md` can be marked `[x]`.

31. Report to the user: Lean file path, theorem count, sorry count by position, blueprint label now `\leanok`, suggested next action.

# Hard rules

- **Phase 0 is non-optional.** Every invocation runs the env-check script. The watermark is the fast path; you do not skip the script. A broken Lean env at session start means STOP, not "try anyway".
- **No `sorry` in `def` / `structure` / `class` / `instance` / `abbrev` bodies.** Persona R4, CLAUDE.md commitment #6. The skill REFUSES to write such a file — if the body is not concrete, the milestone is not ready.
- **No invented Mathlib symbols.** If `exact?` and loogle did not find it, the symbol does not exist. Do not write `Real.something_we_hope_exists` and pray. State the missing lemma as its own `lemma` (with a sorry, if proof is non-trivial) and surface it as a dependency.
- **No anti-goal drift.** TTE / represented spaces / `RepresentedSpace` / oracle Turing machines / Baire-space realizers / `ℝ_c` / Bishop reformulation — all forbidden. Persona §9, CLAUDE.md "Anti-goals". When you find yourself drifting, STOP and write the conflict to `thinking/<topic>/lean-conflict-<date>.md`.
- **Mathlib naming and style are enforced.** American English. snake_case proofs. UpperCamelCase types/classes/structures. `Is`-prefix for noun predicates. 100-char lines. 2-space proof indent. `Type*` not `Type 0`. `autoImplicit false`. See `lean-toolkit.md §3`.
- **AI use disclosed in commit messages.** Mathlib4 policy applies: every commit message under `ComputableAnalysis/` notes `tactics drafted by Claude under /formalize; verified by lake build`. Every `sorry` you leave has a `-- TODO(/formalize):` comment naming the obstruction.
- **The proposer is never the verifier.** This skill produces the Lean stub AND the blueprint toggle. Devil's-advocate (paper + Lean + blueprint) reviews before the criterion can be marked done. Do not auto-mark.
- **Do not edit `CLAUDE.md`, `BOOTSTRAP.md`, or `literature/papers/`.** These are out of scope. The `claims/` directory IS in scope (you update the satellite per Phase 6 step 28). If you discover the *statement* needs revision, write the finding to `thinking/<topic>/` and surface to the user — let them update the blueprint and claim.
- **The three-attempt rule.** Do not spin on a single `sorry`. Three substantive tries, then `-- TODO`, move on. The session is bounded.
- **`\leanok` is only set when the corresponding Lean decl(s) have no `sorry` transitively.** Use `#print axioms <name>` to verify (no `sorryAx`). Setting `\leanok` on a sorry-bearing decl is the worst class of error — it lies to the dep graph.

# When to use which subagent

- `formalizer` (`.claude/agents/formalizer.md`) — invoke at Phase 1 if the *claim file* is imprecise (informal statement still has English glue, hypotheses underspecified). Convert the prose into theorem-form before stubbing in Lean.
- `lit-scout` (`.claude/agents/lit-scout.md`) — invoke at Phase 2 if you suspect Mathlib has a related result not yet in our `literature/`. Use sparingly; usually `exact?` / loogle suffices for in-Mathlib lookups.
- `devils-advocate` (`.claude/agents/devils-advocate.md`) — invoked by the user via `/devils-advocate` at Phase 6, not by you directly.
- `proof-reviewer` (`.claude/agents/proof-reviewer.md`) — invoke at Phase 5 if the proof is long (>30 lines) and you want a line-by-line scrutiny before handoff.

# Recovery

If the session is interrupted (context exhausted, user paused, kernel crashed), the recovery is to re-invoke `/formalize <same-claim>`. Phase 0 will re-validate the env (probably fast-path via watermark). Phase 1 will reload the persona and context. Phase 3 will detect the partial stub and pick up where the previous session stopped (look for existing definitions; preserve them; continue filling theorems with sorries). Phase 6's blueprint toggle is idempotent — re-running `\lean{...}\leanok` on an already-toggled env is a no-op as long as the decl names match.

The `thinking/<topic>/lean-plan-<id>-<date>.md` from a prior session is the resumption point — read it first.
