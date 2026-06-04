# Prompt for next session

> *Paste this as the opening message in the next conversation. It is self-contained;
> you do not need prior transcripts.* This is a **default** — if the user opens with a
> different request, follow their direction.

---

You are continuing work on **mathlib-computable-analysis**, a Lean 4 / Mathlib4
formalization of Pour-El & Richards' *Computability in Analysis and Physics* (Cambridge
UP 1989), targeting upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root:
`/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. **Read `CLAUDE.md`
first** — it is the project constitution. The deliverable is **Lean code**; the
type-checker is the final arbiter.

## What just happened (2026-06-04 Phase-1 A1 surfacing)

The previous session executed Phase 1 of the prior NEXT-SESSION plan in a single
substantive iteration (round `l4-cmap-surface-axiom1`, 5/30 iters, both DA reviews
`passes`). **No new mathematics was proved; this was pure exposure of work already
closed in earlier rounds.**

1. **A1 (Linear Forms) hoisted into a named, sorry-free top-level lemma.** The
   inline ~615-line A1 tactic body inside `computabilityStructureCMap_of`'s
   `where`-clause was extracted into `ComputableAnalysis.L4.isComputableSeqCMap_linearCombination`
   at `ComputableAnalysis/L4/Instances/CMap.lean:636`. The instance field now
   delegates: `isComputableSeq_linearCombination := isComputableSeqCMap_linearCombination B hα_le hβ_le`
   (`CMap.lean:1286-1287`). The code-motion was done by a Python file-surgery script
   (`thinking/l4-cmap-surface-axiom1/extract_a1.py`) with three anchor-line assertions
   — far less brittle than a ~615-line `Edit` `old_string`. Verified by the standalone
   `#print axioms` method per `docs/PITFALLS.md §7`: the named theorem depends only
   on `[propext, Classical.choice, Quot.sound]` — no `sorryAx`. *(Field projection on
   the instance would have given a false positive due to sibling A2/A3 sorries — this
   is precisely why §7's recipe matters.)*

2. **Blueprint node `lem:l4_cmap_axiom1` added with green border + dark-green
   fill `#1CAC78`** — the **first L4 node to reach `fully_proved`**. Block at
   `blueprint/src/L4.tex:5-26` with `\lean{...}`, `\leanok` on both statement and
   proof, plus statement-level `\uses{def:l3_computabilityStructure,
   def:l1_isComputableSeqRat}` and proof-level
   `\uses{lem:l1_isComputableSeqRat_{add, mul, comp}}`. DA caught one cosmetic
   over-estimate in the triangle bound (stray factor 2 — Lean's bound is tighter);
   tightened same-iter to match the actual estimate at `CMap.lean:1244`.

3. **`thm:l4_cmap_instance` wired to the new lemma via proof-level `\uses`.** The
   theorem's `\begin{proof}` block at `L4.tex:34-40` now reads
   `\uses{lem:l4_cmap_axiom1, def:l1_isComputableSeqReal}`; the Linearity paragraph
   collapsed to `\Cref{lem:l4_cmap_axiom1}`. The dep graph renders the edge
   `lem:l4_cmap_axiom1 -> thm:l4_cmap_instance` as a SOLID arrow (proof-level
   convention). The theorem advanced from grey to **blue fill `#A3D6FF`**
   (`can_prove`: all proof-level deps `\leanok`); border remains blue, no `\leanok`
   on the theorem itself — correct, since A2/A3 still carry `sorry`.

Round summary at `.goals/l4-cmap-surface-axiom1/final.md`; DA verdicts at
`.../reviews/{C2,C3}.md`. **The reusable patterns are**: (a) Python file-surgery
for big code-motion edits with assertions; (b) the standalone-theorem `#print
axioms` audit for sorry-isolation in multi-field instances; (c) proof-level vs
statement-level `\uses` placement determines solid-vs-dashed edges in the rendered
dep graph.

## Current state (post-Phase-1, as of 2026-06-04)

| Layer | Lean state | Blueprint |
|---|---|---|
| L0 | done, 0 sorry (recursion bridge + Prop B inseparable pair) | `L0.tex` — 12 nodes `\leanok`, 8 with proof blocks (dark-green fill) |
| L1 | rational-seq closures + real *point* predicate done, 0 sorry | `L1.tex` — 11 `\leanok`, 7 dark-green |
| L2 | not started (Grzegorczyk–Lacombe) | `L2.tex` — 1 `\notready` stub |
| L3 | `ComputabilityStructure` typeclass done, 0 sorry | `L3.tex` — 1 `\leanok` def |
| L4 | C[a,b]: **A1 closed as named standalone lemma `isComputableSeqCMap_linearCombination`** (sorry-free, dark-green node `lem:l4_cmap_axiom1`); A2/A3 sorried; Lᵖ/Hilbert not started | `L4.tex` — `lem:l4_cmap_axiom1` (dark-green fill `#1CAC78`); `thm:l4_cmap_instance` (blue border + blue fill `#A3D6FF`, `can_prove`); 2 `\notready` |
| L5 | not started (Main Theorems) | `L5.tex` — 4 `\notready` stubs |

- **HEAD = the most recent `feat(L4): surface A1 …` commit on `master`.** This
  session opens with a clean working tree (everything from Phase 1 + the prior
  conformance-pass tail is committed). Run `git log --oneline -5` for orientation.
- The two remaining `sorry`s are in `CMap.lean`: A2 `isComputableSeq_of_effectiveLimit`
  at **line 1298**, A3 `isComputableSeqReal_norm` at **line 1309** (line numbers
  shifted by +30 from the prior session due to the extracted theorem above the
  instance). Each has a detailed TODO sketch in the field body citing P-R Ch. 0
  Thm 4 (A2) and Thm 7 (A3) — **re-verify those citations verbatim before copying
  them into a claim or blueprint** (`docs/PITFALLS.md §6`).
- `blueprint/web/` is gitignored (regenerated, not committed).

## Recommended next task — L1 finite-`max` and absolute-value closure

The highest-leverage next move is **L1 closure under finite `max` and absolute
value** (slug suggestion: `l1-max-abs-closure`). It's a foundation-first round
that:

- **Unblocks A3** (the next major L4 closure). A3 (`isComputableSeqReal_norm` —
  sup-norm computable) needs the maximum of finitely many `IsComputableSeqRat`
  values + absolute-value closure, per the TODO sketch at `CMap.lean:1299-1308`.
  Without L1 max/abs, A3 has no clean way to express its witness array.
- **Cleanly extends an already-green layer.** L1 currently has `IsComputableSeqRat.{add,mul,comp}`
  (all `\leanok` with proof blocks; see `blueprint/src/L1.tex:52-83`). Adding
  `.max`, `.min`, `.abs` follows the exact same template — each is a per-component
  witness construction on `(a, b, s)` of the recursive rational triple.
- **Is bounded in scope.** Comparable round `l1-arithmetic-closure-and-real` closed
  at 7/14 iters. Estimate 4-8 iters here; the surface area is smaller.

### Concrete plan

1. **Grep Mathlib for existing primitives first** (per CLAUDE.md §"When in doubt,
   grep"): `grep -rn "Computable.max\|Primrec.max\|Computable.natAbs\|Computable.int\?Abs" .lake/packages/mathlib/Mathlib/Computability/`.
   If `Computable.max` etc. exist, the lift to `IsComputableSeqRat.max` is a
   compose-with-`Primrec₂` argument; if not, the witnesses must be built inline
   via `Computable.nat_rec` over pair structure.
2. **Pattern-match the existing `IsComputableSeqRat.add` (`CMap.lean` via
   `ComputableAnalysis/L1/ComputableSeqReal.lean`):** the `add` witness does a
   four-way sign-parity case split + cross-product magnitude comparison. The
   `max(q1, q2)` reduces to a *single* comparison (which of `a₁/b₁` and `a₂/b₂`
   is larger? — equivalent to comparing `a₁·b₂` vs `a₂·b₁` since both `b` are
   positive). The `abs` lemma is even simpler: zero out the sign component
   (`s := fun _ => 0`).
3. **Add blueprint nodes** `lem:l1_isComputableSeqRat_max`, `lem:l1_isComputableSeqRat_min`,
   `lem:l1_isComputableSeqRat_abs` in `blueprint/src/L1.tex`, each with `\lean{...}`,
   `\leanok`, statement-level `\uses{def:l1_isComputableSeqRat}`. Each should get
   a `\begin{proof}\leanok ... \end{proof}` block — at most 3-5 sentences each.
4. **Verify** via the standard pipeline: `lake build` (still 2 sorries, no new
   warnings); `#print axioms` on each new lemma (no `sorryAx`); `leanblueprint
   web` and `checkdecls` both exit 0.

### Round parameters to propose to the user

- mode: `proof-attempt`
- max_iterations: 14 (matches the L1-arithmetic round budget; double-budget rule
  has natural endpoint at round wrap per `feedback_round_pragmatism.md`)
- time_budget_minutes: 120
- DA scope: optional — these are direct generalisations of an existing pattern
  (`IsComputableSeqRat.add`); the type-checker is the strong arbiter. Suggest
  DA on the blueprint nodes only if any proof prose departs from the L1.tex
  template.
- allow_writes:
  - `ComputableAnalysis/L1/ComputableSeqReal.lean` (where `IsComputableSeqRat.{add,mul,comp}` already live)
  - `blueprint/src/L1.tex`, `blueprint/lean_decls`
  - `.goals/l1-max-abs-closure/**`, `thinking/l1-max-abs-closure/**`, `current-goal.md`, `.goals/INDEX.md`
  - `docs/NEXT-SESSION.md`, `docs/PITFALLS.md`, `docs/LEAN-IDIOMS.md`
- forbid_writes (highlights — full list per recent rounds): `ComputableAnalysis/{L0,L3,L4,L5}/**`, `blueprint/src/{L0,L2,L3,L4,L5}.tex`, `literature/papers/**/verbatim.md`, `lakefile.toml`, `lake-manifest.json`, `lean-toolchain`, `claims/INDEX.md`.

## Other viable directions (ranked menu)

- **A2 close** (slug `l4-cmap-axiom2-effectivelimit`): self-contained, no L1
  prerequisite. Effective-limit triangle-inequality + diagonalisation of a
  computably-Cauchy double array of polynomial approximants (P-R Ch. 0 Thm 4).
  The TODO sketch at `CMap.lean:1289-1297` already names the witness shape
  `a'_{n,N,j} := a_{n, e(n,N+1), N+1, j}` and `d'_{n,N} := d_{n, e(n,N+1), N+1}`.
  Once closed, only A3 stands between us and a fully green `thm:l4_cmap_instance`.
  Can run **in parallel** with the L1 max/abs round above using a separate git
  worktree (they touch disjoint files — but **NOT** with a shared tree, since
  `current-goal.md` / `.goals/INDEX.md` / `docs/NEXT-SESSION.md` would collide).
- **L1 helper hoist** (slug `l1-finsetsum-and-ite`): move the private
  `FinsetSumHelper` closure helpers from `CMap.lean:71-381` up to L1's
  `IsComputableSeqRat` namespace. Frees ~250 lines of L1-shaped code currently
  stranded in L4 and improves review-readability before upstream. No downstream
  consumer is blocked on this — pure refactor.
- **L3 stability theorem** (slug `l3-stability`): uniqueness of `IsComputableSeq`
  under effective separability (P-R Ch. 2 Stability Lemma). Independent of L1/L4,
  high-leverage for L5 prep, exercises the typeclass design.
- **Zulip outreach** (per `CLAUDE.md` §"Mathlib community engagement"): with
  L0/L1/L3 green and the first L4 lemma fully formalized, the project is
  credible to pitch. Prepare a 3-paragraph draft mentioning the P-R framework
  choice, the C[a,b] A1 result, and an explicit invitation for feedback on
  the P-R-vs-represented-spaces tension. **The user does the actual
  posting/sharing**, not you.

## Parallel-agent dispatch

If launching several autonomous agents at once: pin **exactly one objective per
agent**. The L1 max/abs round, A2 close, and L1 helper hoist all touch disjoint
Lean files (`L1/ComputableSeqReal.lean` vs `L4/Instances/CMap.lean` body vs the
`FinsetSumHelper` namespace within `CMap.lean`) — but they ALL touch
`current-goal.md`, `.goals/INDEX.md`, and `docs/NEXT-SESSION.md`, so they
**cannot share a working tree**. Use **git worktree per agent** (one branch each,
merge back at the end). Because no agent may commit unless the user asks (see
Hard guardrails), agents cannot checkpoint to isolate their work — worktree
isolation is the only reliable barrier.

## Hard guardrails

- **Every agent must run on the `claude-opus-4-8` model** — do not dispatch any
  agent (including subagents) on a lighter model.
- **Never commit unless the user explicitly asks.** `git push` is denied in settings.
- **Sorry policy** (`CLAUDE.md`): `sorry` allowed only in theorem/lemma bodies,
  each with a `-- TODO(/formalize L<N>):` comment; **never** in
  `def`/`structure`/`class`/`instance`/`abbrev` bodies. `\leanok`/`\mathlibok`
  only on decls with no transitive `sorry` — and the *only* correct sorry-isolation
  audit on multi-field instances is the standalone-theorem `#print axioms` method
  from `docs/PITFALLS.md §7` (NOT field projection on the instance — false positive).
- **Do not author L5/L2 theorem statements (or any P-R citation) from memory.**
  Grep the literature and verify the quoted phrase verbatim first (`CLAUDE.md`
  §"When in doubt, grep"; `docs/PITFALLS.md §6`).
- **Do not touch**: `claims/INDEX.md`, `.github/workflows/**`, `lakefile.toml`,
  `lake-manifest.json`, `lean-toolchain`, `literature/papers/**/verbatim.md`, and
  the historical `.goals/**` / `claims/**` / `thinking/**` archives.
- **Stop hook discipline**: the hook checks (a) writes against `allow_writes`,
  (b) criterion checkbox state in `current-goal.md` (`- [x]` flip needed after
  each criterion closes; iter-prose alone does NOT satisfy the hook), and
  (c) HALTs on pre-existing dirt outside scope (revert OR extend `allow_writes`
  with a documenting comment). Plan iter scope to absorb at most one
  bookkeeping iter for hook reactions.
- **Read `docs/PITFALLS.md` + `docs/LEAN-IDIOMS.md`** before opening a new
  L-layer round.

## Verification pipeline (run in order)

1. `lake build 2>&1 | tail -5` — expect 0 errors. Until A2/A3 close, expect
   exactly **2 `sorry`s** (`CMap.lean:1298, 1309`) and **1** sorry-warning at
   the instance decl line.
2. `python3 -c "[print(p,i) for p in ['<file>'] for i,l in enumerate(open(p,encoding='utf-8'),1) if len(l.rstrip(chr(10)))>100]"`
   — no line >100 columns on **`.lean`** files (count **codepoints**, not bytes;
   awk over-counts unicode). `.tex` files are paragraph-per-line per leanblueprint
   convention; 100-col is not enforced there.
3. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web 2>&1 | tail -5` — exit 0.
4. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls; echo "exit: $?"` —
   must stay exit 0 (every `\lean{}` target resolves in the lake env).

---

*End of prompt.*
