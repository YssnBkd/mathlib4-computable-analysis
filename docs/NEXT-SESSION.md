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

## What just happened (2026-06-04 — L1 max/min/abs + L4 A2 close + A3 obstruction surfaced)

A single long control-tower session did three substantive things:

1. **L1 `IsComputableSeqRat.{max, min, abs}` closures shipped sorry-free.** Each is
   verified by standalone `#print axioms` returning `[propext, Classical.choice,
   Quot.sound]`. The implementation pattern is `set chooseR1 := fun k => bif ... with
   hchooseR1_def` — a single Boolean discriminator gates all three witness ingredients
   (newA, newB, newS) via `cond chooseR1`. The 4-parity case-split (`(s₁ k % 2, s₂ k % 2) ∈
   {(0,0), (0,1), (1,0), (1,1)}`) drives the cross-product comparison in the same- and
   different-parity branches. The `.abs` lemma is the simpler sibling — set the sign
   witness to constant 0 and use `show |r k| = (-1 : ℚ) ^ (0 : ℕ) * ((a k : ℚ) / (b k : ℚ))`
   to force beta-reduction before the first `rw [heq k]`.

2. **L4 A2 (`isComputableSeqCMap_of_effectiveLimit`) closed sorry-free.** P-R Ch. 0 Thm 4
   ("Closure under effective uniform convergence"). Verbatim quote at
   `literature/papers/PourEl-Richards-chapt0.md:748`. Witness: diagonalise the polynomial-approximant
   double sequence by `a'_{n,N,j} := a_{n, e(n,N+1), N+1, j}` and `d'_{n,N} := d_{n, e(n,N+1), N+1}`.
   Norm bound via triangle inequality. Named lemma at `ComputableAnalysis/L4/Instances/CMap.lean`
   around line 1262; instance field delegates. `#print axioms` clean.

3. **L4 A3 (`isComputableSeqCMap_norm`) surfaced as a named lemma with a *documented obstruction*.**
   P-R Ch. 0 Thm 7 ("Maximum Values"). Verbatim quote at
   `literature/papers/PourEl-Richards-chapt0.md:977`. **Partial close only** — the body
   still carries `sorry`. A dispatched closure-attempt subagent (working with `IsComputableSeqRat.{max, abs}`
   in scope) honestly evaluated and concluded the **lemma's current signature is provably
   inadequate**. A concrete counterexample is recorded in the lemma's docstring:

   > "With `α := 0`, `β := -ε` where `ε := if P then 1 else 0` for undecidable `P`, the
   > constant-1 sequence has `IsComputableSeqCMap f = True` (via polynomial `p ≡ 1`) but
   > `‖f n‖ ∈ {0, 1}` depending on `P` (via `BoundedContinuousFunction.norm_eq_zero_of_empty`
   > vs. nonempty-singleton case), so `(‖f n‖)` is not `IsComputableSeqReal`."

   **Where P-R's proof breaks**: at `chapt0.md:986-989` (the rational grid `s_{n,k} =
   max{f_n(α + (j/k)(β-α)) : 1 ≤ j ≤ k}` is constructed from grid points `α + (j/k)(β-α)`,
   which are only computable reals when `α, β` are). The bound `|α|, |β| ≤ B` is
   insufficient — `B` is a rational bound but doesn't supply the rational-approximant
   double sequence for `α, β` that P-R's proof actually uses (`chapt0.md:992`: "Since `a`,
   `b` are computable reals, and since `{f_n}` is sequentially computable, the double
   sequence `{s_{nk}}` is computable").

   **Recommended fix** (from the subagent): add `(hα_c : IsComputableReal α) (hβ_c :
   IsComputableReal β)` hypotheses. `IsComputableReal` is defined at
   `ComputableAnalysis/L1/ComputableSeqReal.lean:696`. The signature change cascades: the
   `def computabilityStructureCMap_of` instance would need to either (a) also take those
   hypotheses, (b) split into two defs (rational-bound-only vs computable-real), or (c)
   the A3 obligation gets surfaced *outside* the instance entirely (a separate theorem
   that takes the strong hypotheses).

   See `lem:l4_cmap_axiom3` in `blueprint/src/L4.tex` for the partial-close blueprint
   node. It deliberately has NO `\leanok` markers (transitive sorry forbids them per
   CLAUDE.md).

4. **`docs/PITFALLS.md §9` added.** Two systematic Mathlib-naming-drift gotchas hit during
   the L1 round: `div_le_div_iff` renamed to `div_le_div_iff₀` (subscript zero,
   `(hb : 0 < b) (hd : 0 < d) : a / b ≤ c / d ↔ a * d ≤ c * b`); and `Max.max_eq_left` /
   `Min.min_eq_right` qualification doesn't exist (use the root-namespace unqualified
   forms `max_eq_left`, `min_eq_right`, etc.). The 5-second grep-before-write convention
   would have saved an iter; documented as a hard rule.

5. **6 new blueprint nodes**: `lem:l1_isComputableSeqRat_{max, min, abs}` (all fully
   dark-green), `lem:l4_cmap_axiom2` (fully dark-green), `lem:l4_cmap_axiom3` (blue
   border + no fill, partial), plus a refreshed proof block on `thm:l4_cmap_instance`
   referencing all three axioms.

## Current state (post-session, as of 2026-06-04)

| Layer | Lean state | Blueprint |
|---|---|---|
| L0 | done, 0 sorry | `L0.tex` — 12 nodes `\leanok`, 8 dark-green |
| L1 | rational-seq closures `{add, mul, comp, max, min, abs}` done; real *point* predicate done; 0 sorry | `L1.tex` — 14 `\leanok`, 10 dark-green (3 new this session) |
| L2 | not started (Grzegorczyk–Lacombe) | `L2.tex` — 1 `\notready` stub |
| L3 | `ComputabilityStructure` typeclass done, 0 sorry | `L3.tex` — 1 `\leanok` def |
| L4 | C[a,b]: **A1+A2 closed sorry-free** (`isComputableSeqCMap_{linearCombination,of_effectiveLimit}`); **A3 partial-close** (`isComputableSeqCMap_norm` sorry-bodied, signature inadequate — see obstruction analysis); Lᵖ/Hilbert not started | `L4.tex` — `lem:l4_cmap_axiom{1,2}` dark-green fully proved; `lem:l4_cmap_axiom3` blue border (partial, no `\leanok`); `thm:l4_cmap_instance` partially blue (uses include A3 partial); 2 `\notready` |
| L5 | not started | `L5.tex` — 4 `\notready` stubs |

- **HEAD** = the commit landing all of the above (committed at the end of this session).
- Repo-wide `sorry` count: **1** (only A3's body in `isComputableSeqCMap_norm`, at
  `CMap.lean` ~line 1586). Down from 2 at session start.
- `lake build` green; sole warning is the A3 sorry. `leanblueprint web` + `checkdecls`
  both exit 0.

## Recommended next task — A3 signature redesign + closure

The single open Lean-side obligation is A3. The path forward is well-defined by the
obstruction analysis in `isComputableSeqCMap_norm`'s docstring. Pick one of the three
resolution paths (the docstring spells out the trade-offs):

(A) **Strengthen the lemma's signature** (recommended). Add `(hα_c : IsComputableReal α)
    (hβ_c : IsComputableReal β)` to `isComputableSeqCMap_norm`. The instance
    `computabilityStructureCMap_of` keeps the rational-bound signature but its A3 field
    is now obviously unprovable in that context — surface A3 as a **separate** theorem
    `computabilityStructureCMap_of_computable` that takes the additional hypotheses and
    proves all three axioms (including the strengthened A3).

(B) **Pass rational-approximant data explicitly.** Add a hypothesis `(αApprox : ℕ → ℚ)
    (βApprox : ℕ → ℚ) (hα_conv : ∀ n, |αApprox n - α| ≤ 1/2^n)` etc. More invasive but
    keeps the instance signature monomorphic in `α, β : ℝ`. Less idiomatic.

(C) **Switch to the Grzegorczyk-Lacombe predicate** (`L2`). The G-L predicate at L2 is
    a direct point-predicate `IsGLContinuous` that builds-in the computable-modulus
    requirement; it avoids the polynomial-approximant detour. Heavier — L2 is not yet
    started. *Not recommended* unless the L2 work is on the critical path anyway.

### Concrete plan for option (A)

1. **Add `IsComputableReal` hypotheses** to `isComputableSeqCMap_norm`'s signature.
   Update the docstring to reflect the new state.
2. **Implement the grid construction** using `IsComputableReal`'s constant-sequence
   form: extract the rational approximant `(α_n)` with `|α_n - α| ≤ 1/2^n` (similarly
   for `β`), then the discretization grid is `α_n + (j/k)·(β_n - α_n)` — rational
   arithmetic over k+1 points.
3. **Apply `IsComputableSeqRat.{max, abs}`** to take the max of `|f_{n,k}(grid_point_j)|`
   over the grid.
4. **Bound the discretization error** via the polynomial Lipschitz constant (computable
   from the polynomial coefficients + B).
5. **Audit** with the standalone `#print axioms` recipe (PITFALLS §7).
6. **Update the instance**: introduce `computabilityStructureCMap_of_computable` taking
   the strong hypotheses; or, equivalently, mark `computabilityStructureCMap_of` as
   incomplete-on-A3 with a comment pointing to the stronger version.
7. **Update blueprint**: promote `lem:l4_cmap_axiom3` from partial to fully green.

### Round parameters to propose to the user

- slug: `l4-cmap-axiom3-norm-resig`
- mode: `proof-attempt`
- max_iterations: 30
- time_budget_minutes: 240
- DA scope: optional on the new instance design (worth scrutinising the cascading
  signature change); not needed on the actual A3 proof body.
- allow_writes:
  - `ComputableAnalysis/L4/Instances/CMap.lean`
  - `blueprint/src/L4.tex`, `blueprint/lean_decls`
  - `.goals/l4-cmap-axiom3-norm-resig/**`, `thinking/l4-cmap-axiom3-norm-resig/**`,
    `current-goal.md`, `.goals/INDEX.md`
  - `docs/NEXT-SESSION.md`, `docs/PITFALLS.md`, `docs/LEAN-IDIOMS.md`
- forbid_writes: same as the prior round (`L0/L2/L3/L5` Lean + `.tex`; literature
  verbatim; lakefile; claims/INDEX).

## Other viable directions (ranked menu)

- **Lift `set chooseR1` idiom to `docs/LEAN-IDIOMS.md`** (slug: `idiom-multi-output-cond`).
  1 iter / 15 min. The pattern was reused 3 times this session (.max, .min, and A3
  could too); name it formally.
- **Zulip outreach.** With L0, L1, L3 green and L4 A1+A2 done, the project is
  credible to pitch. Draft 3-paragraph note mentioning P-R framework choice, the C[a,b]
  A1+A2 results, the new L1 closures, and an explicit invitation for feedback on the
  A3 signature decision. **The user posts**, not Claude.
- **L2 (Grzegorczyk-Lacombe) start** (slug: `l2-gl-foundations`). If Option (C) for A3
  is preferred, L2 must come first. Otherwise this is later in the dep order.
- **L5 (Main Theorems) scaffold** (slug: `l5-stubs`). Even just adding the L5 theorem
  *statements* (with `sorry` bodies) would let the blueprint visualise the full target.

## Parallel-agent dispatch lessons

This session ran the first multi-agent parallel-worktree round in this project. Lessons:

1. **Uncommitted main state does NOT propagate to worktrees.** `git worktree add` checks
   out from HEAD. When Agent A2 / A3 were dispatched in worktrees, their checkout
   *omitted* main's uncommitted L1 work — which is why Agent A3's first attempt
   partial-closed (couldn't see L1). **Rule**: commit prerequisites to master *before*
   dispatching isolated agents that need them.

2. **3-way merge for non-conflicting parallel branches works.** `git merge-file -p
   <ours> <base> <theirs>` cleanly merged Agent A2's CMap.lean edits into main's
   working copy. Three conflict regions were all "keep both" (independent new lemma
   additions) or "compose" (instance fields editing different fields) — resolvable by
   Python script.

3. **Honest agent self-evaluation matters.** The fresh A3 agent declined to fabricate
   a proof and instead surfaced the signature obstruction with a concrete counterexample.
   That's far more valuable than a slick-but-wrong attempt or a giving-up message.

## Hard guardrails (unchanged from prior NEXT-SESSION.md)

- **Every agent must run on the `claude-opus-4-8` model** (Agent tool's `model: "opus"`
  resolves to the latest Opus — satisfies the spirit).
- **Never commit unless the user explicitly asks.** `git push` is denied in settings.
- **Sorry policy** (`CLAUDE.md`): `sorry` allowed only in theorem/lemma bodies, each
  with a `-- TODO(/formalize L<N>):` comment.
- **Do not author L5/L2 theorem statements (or any P-R citation) from memory.** Grep
  the literature and verify verbatim first.
- **`\leanok`/`\mathlibok` only on decls with no transitive `sorry`** — the standalone
  `#print axioms` recipe in `docs/PITFALLS.md §7` is the canonical sorry-audit.
- **Read `docs/PITFALLS.md` (now 9 entries) + `docs/LEAN-IDIOMS.md`** before opening a
  new L-layer round.

## Verification pipeline (run in order)

1. `lake build 2>&1 | tail -5` — expect 0 errors. Until A3 is closed, expect exactly
   **1 sorry** (`CMap.lean` ~line 1586) and **1** sorry-warning at the
   `isComputableSeqCMap_norm` decl.
2. `python3 -c "[print(p,i) for p in ['<file>'] for i,l in enumerate(open(p,encoding='utf-8'),1) if len(l.rstrip(chr(10)))>100]"`
   — no line >100 codepoints on `.lean` files (count codepoints, not bytes).
3. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web 2>&1 | tail -5` — exit 0.
4. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls; echo "exit: $?"` —
   exit 0.

---

*End of prompt.*
