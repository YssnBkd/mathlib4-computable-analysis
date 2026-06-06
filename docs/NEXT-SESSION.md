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

## What just happened (2026-06-06 — round `l2-mul-smul-sub` wraps)

The active `/goal` round `l2-mul-smul-sub` extended **L2** with the
remaining arithmetic closures (sub, smul, mul) and lifted four L1 helpers
(`IsComputableSeqReal.add`, `.neg`, `.bound`, `.mul`) from previously-private
status into the L1 namespace. **All sorry-free, all DA-passed.**

Concretely, the round drove iter-02 through iter-10 (8 effective iters):

1. **C1, C2 — L1 helper lifts.** `IsComputableSeqReal.add` (modulus
   `e(n,N) := N+1`, triangle inequality) and `.neg` (modulus unshifted via
   `abs_neg`) hoisted from `private` L2 helpers to named L1 §4.5 theorems.
   `l2_sum_gl` and `l2_neg_gl` callsites updated to `h_f.add h_g` /
   `h_f.neg` dot-notation. Two-line proof for each at the L2 site.
2. **C3 — `l2_sub_gl`.** Two-line corollary:
   `rw [sub_eq_add_neg]; exact l2_sum_gl hf (l2_neg_gl hg)`.
3. **C4 — `l2_smul_gl`** (closure under `c • f` for `IsComputableReal c`).
   Required two new L1 helpers: `IsComputableSeqReal.bound` (Nat-valued
   `Computable` upper bound on `|y n|` extracted from the
   `IsComputableSeqRat` witness ingredients at `Nat.pair n 0`) and
   `IsComputableSeqReal.mul` (modulus `e(n,N) := N + Ma + Mb + 1`,
   amplification via `Nat.lt_two_pow_self`). The L2 lemma uses modulus
   `df (N + M)` with `M := Mc 0` an additive shift by the Nat bound on `|c|`.
4. **C5 — `l2_mul_gl`** (the headline closure under `*`). Boundedness via
   `ContinuousMap.norm` on the compact `Set.Icc α β`
   (`CompactSpace` automatic from `compactSpace_Icc`). Modulus
   `d_mul N := df (N + 1 + M_g) * dg (N + 1 + M_f)` where
   `M_f, M_g := ⌈‖·‖⌉₊ + 1` are Nat upper bounds. Cross-term bound chain
   `M / 2^(N+1+M) ≤ 1/2^(N+1)` via `Nat.lt_two_pow_self`'s `M ≤ 2^M`;
   total ≤ `1/2^N`. Required adding
   `import Mathlib.Topology.ContinuousMap.Compact` (for the `Norm` instance).
5. **C6 — Blueprint.** Added 5 new L1 nodes (including previously-missing
   `lem:l1_isComputableSeqRat_neg`) and 3 new L2 nodes
   (`lem:l2_{sub,smul,mul}_gl`); refreshed `\uses` on `lem:l2_sum_gl` /
   `lem:l2_neg_gl` to point at the lifted L1 helpers.
   `leanblueprint checkdecls` and `web` exit 0.
6. **C7 — Build + axiom audit.** Full `lake build` clean (2533 jobs); all 7
   new declarations (`IsComputableSeqReal.{add,neg,bound,mul}`,
   `l2_{sub,smul,mul}_gl`) return
   `[propext, Classical.choice, Quot.sound]` only.
7. **DA reviews**: `verdict: passes` on C1, C2, C3, C4, C5. All five reviews
   under `.goals/l2-mul-smul-sub/reviews/`.

## Current state (post-session, as of 2026-06-06)

| Layer | Lean state | Blueprint |
|---|---|---|
| L0 | done, 0 sorry | `L0.tex` — 12 nodes `\leanok` |
| L1 | rational + **real** closures (add/neg/mul/bound) + real-point predicate + Prop 1 sorry-free | `L1.tex` — 19+ `\leanok` |
| L2 | **`IsGLComputable` + 7 closures (const, id, sum, neg, sub, smul, mul) sorry-free** — composition (`l2_comp_gl`) and L2→L4 bridge still open | `L2.tex` — def + 7 lemmas all `\leanok` |
| L3 | `ComputabilityStructure` typeclass sorry-free | `L3.tex` — 1 `\leanok` def |
| L4 | **C[a,b] FULLY sorry-free** — A1, A2, A3 + structure all closed; Lᵖ / Hilbert not started | `L4.tex` — `lem:l4_cmap_axiom{1,2,3}` all `\leanok`; `thm:l4_cmap_instance` `\leanok`; Lᵖ/Hilbert `\notready` |
| L5 | not started | `L5.tex` — 4 `\notready` stubs |

- **HEAD** unchanged this conversation (no commit was made; user's preference).
  All work is in working tree.
- Repo-wide `sorry` count: **0** (modulo docstring-quoted occurrences).
- `lake build` green; no errors; no sorry-warnings; only pre-existing
  `push_neg` deprecation warnings on `L4/Instances/CMap.lean`.
- Round criteria C1-C8 all green; awaiting `/goal-end`.

## Recommended next action — `/goal-end` then choose next round

The active round has all 8 criteria met. To formally close, first run
`/goal-end` to archive the round to `.goals/l2-mul-smul-sub/`. Then choose
one of four high-value next directions:

### Option A — Zulip outreach (recommended; ~30 min)

The project now has L0, L1 (with full real-arithmetic closure), L3, L4
C[a,b], and **L2 Grzegorczyk-Lacombe Def-A + 7 closures (const, id, sum,
neg, sub, smul, mul) all sorry-free**. This is a stronger inflection point
than the prior round's. **The user posts** — not Claude. The asker would
draft:
- ¶1: project pitch (P-R formalization, predicate-first, substrate =
  Mathlib `Computable`/`Partrec`).
- ¶2: progress (L0-L4 sup-norm done; L2 Def-A anchor with full algebra
  closure; reference blueprint URL).
- ¶3: ask for feedback on the predicate-first architecture vs
  represented-spaces (Pauly/Brattka).

Record the thread under `docs/zulip-threads.md`.

### Option B — `/goal l2-comp-closure` (composition; ~10-15 iters)

Open `l2-comp-closure` to add the final L2 arithmetic-surface piece:
- `l2_comp_gl` — closure under precomposition with a GL-computable map
  `g : C(Set.Icc γ δ, Set.Icc α β)`. Tricky because of the range-as-subtype
  encoding (codomain of `g` is the subtype `↥(Set.Icc α β)`, not a free
  type — defining what GL-computability means for `g` itself requires
  thought). This is the genuinely-deferred piece from the prior round; once
  it lands, the L2 arithmetic surface is closed.

### Option C — `/goal l2-l4-bridge` (Equivalence Theorem; ~15-25 iters)

Open `l2-l4-bridge` targeting P-R Ch. 0 §7 **Equivalence Theorem** (Def-A ⇔
Def-B): construct `IsGLComputable f ↔ IsComputableSeqCMap (fun _ => f)`.
This is the conceptual capstone of L2 — it bridges the
sequential-computability-plus-modulus shape (Def A) to the
polynomial-approximation shape (Def B, used by L4 `CMap`). Likely requires
the L4-side Stone-Weierstrass machinery already built in `l4-cmap-axiom*`
rounds. **Highest research-quality payoff** of the four options.

### Option D — `/goal l4-lp-instance` (~15-25 iters)

Open `l4-lp-instance` targeting `ComputabilityStructure ℝ (L^p[a,b])` for
`1 ≤ p < ∞`. P-R Ch. 2:146. Construction: rational-step-function
approximants with effective Lᵖ-convergence modulus. Requires L1 + measure
theory bridge (Mathlib's `MeasureTheory.LpSpace`). Significantly harder than
C[a,b] — Weierstrass approximation doesn't carry over.

## Round parameters (for the closed round)

- slug: `l2-mul-smul-sub` (CLOSED — all C1-C8 met)
- mode: `proof-attempt`
- max_iterations: 50 (10 used; 40 remaining if reopened)
- time_budget_minutes: 360 (within budget)
- DA scope: C1, C2, C3, C4, C5 — all `verdict: passes`.

## Quick handoff checklist (run in order at session start)

1. `lake build 2>&1 | tail -10` — expect 0 errors, 0 sorry-warnings, only
   `push_neg` deprecation warnings.
2. `grep -rn "sorry" ComputableAnalysis/ --include="*.lean" | grep -v "^\s*--"` —
   expect 0 hits.
3. `#print axioms ComputableAnalysis.L4.computabilityStructureCMap_of` and
   `#print axioms ComputableAnalysis.L2.{IsGLComputable, l2_const_gl, l2_id_gl, l2_sum_gl, l2_neg_gl, l2_sub_gl, l2_smul_gl, l2_mul_gl}` and
   `#print axioms ComputableAnalysis.L1.IsComputableSeqReal.{add, neg, bound, mul}` —
   expect `[propext, Classical.choice, Quot.sound]` on each.
4. `cat current-goal.md` to confirm round status; if all criteria green, run
   `/goal-end` to archive.

## Parallel-agent dispatch lessons (still applies)

From prior rounds:
1. Uncommitted main state does NOT propagate to worktrees.
2. 3-way merge for non-conflicting parallel branches works.
3. Honest agent self-evaluation matters.

## Hard guardrails (unchanged)

- **Every agent must run on the `claude-opus-4-8` model** (Agent tool's `model: "opus"`
  resolves to the latest Opus — satisfies the spirit).
- **Never commit unless the user explicitly asks.** `git push` is denied in settings.
- **Sorry policy** (`CLAUDE.md`): `sorry` allowed only in theorem/lemma bodies, each
  with a `-- TODO(/formalize L<N>):` comment.
- **Do not author L5/L2 theorem statements (or any P-R citation) from memory.** Grep
  the literature and verify verbatim first.
- **`\leanok`/`\mathlibok` only on decls with no transitive `sorry`** — the standalone
  `#print axioms` recipe in `docs/PITFALLS.md §7` is the canonical sorry-audit.
- **Read `docs/PITFALLS.md` + `docs/LEAN-IDIOMS.md`** before opening a new L-layer
  round.

## Verification pipeline (run in order)

1. `lake build 2>&1 | tail -5` — expect 0 errors and 0 sorries.
2. `python3 -c "[print(p,i) for p in ['<file>'] for i,l in enumerate(open(p,encoding='utf-8'),1) if len(l.rstrip(chr(10)))>100]"`
   — no line >100 codepoints on `.lean` files (count codepoints, not bytes).
3. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web 2>&1 | tail -5` — exit 0.
4. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls; echo "exit: $?"` —
   exit 0.

---

*End of prompt.*
