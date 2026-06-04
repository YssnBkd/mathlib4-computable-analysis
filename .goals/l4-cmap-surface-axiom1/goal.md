---
slug: l4-cmap-surface-axiom1
started: 2026-06-04T00:33:26Z
mode: proof-attempt
max_iterations: 30
time_budget_minutes: 3600
allow_writes:
  - ComputableAnalysis/L4/Instances/CMap.lean
  - blueprint/src/L4.tex
  - blueprint/lean_decls
  - claims/l4-cmap-surface-axiom1/**
  - .goals/l4-cmap-surface-axiom1/**
  - .goals/INDEX.md
  - thinking/l4-cmap-surface-axiom1/**
  - current-goal.md
  - docs/NEXT-SESSION.md
  - docs/PITFALLS.md
  - docs/LEAN-IDIOMS.md
forbid_writes:
  - ComputableAnalysis/L0/**
  - ComputableAnalysis/L1/**
  - ComputableAnalysis/L3/**
  - ComputableAnalysis/L5/**
  - ComputableAnalysis.lean
  - blueprint/src/content.tex
  - blueprint/src/L0.tex
  - blueprint/src/L1.tex
  - blueprint/src/L2.tex
  - blueprint/src/L3.tex
  - blueprint/src/L5.tex
  - blueprint/src/blueprint.sty
  - blueprint/src/plastex.cfg
  - blueprint/src/latexmkrc
  - blueprint/src/macros/**
  - literature/papers/**/verbatim.md
  - .claude/commands/**
  - .github/workflows/**
  - lakefile.toml
  - lake-manifest.json
  - lean-toolchain
  - claims/INDEX.md
  - claims/l3-computability-structure-axioms/**
  - claims/l4-cmap-axiom-linearity/**
  - claims/l1-arithmetic-closure-and-real/**
devils_advocate_required_for:
  - "C2"
  - "C3"
---

# Goal: Surface the A1 win — extract `isComputableSeqCMap_linearCombination` as a standalone sorry-free lemma and add a green blueprint node `lem:l4_cmap_axiom1` wired into `thm:l4_cmap_instance`

## Why this matters

Right now the L4 dep-graph view of the C[a,b] instance is uniformly white-bordered:
because `computabilityStructureCMap_of` carries `sorryAx` from open A2/A3 fields,
the single `thm:l4_cmap_instance` node hides the fact that **A1 (linearity, including
the full polynomial-approximation + finite-`max` norm-bound machinery) is already
sorry-free**. Phase 1 from `docs/NEXT-SESSION.md` is to *expose* that win — no new
mathematics, just a refactor that gives the blueprint a green-fillable node — turning
"nothing green in L4" into "L4 has one fully-formalised lemma" without touching A2/A3.
This is the highest-leverage low-risk move in the project: it makes credible progress
visible to a Mathlib audience (per CLAUDE.md §"Mathlib community engagement") at zero
proof cost. Phase 2 (close A2 and A3) is deferred to subsequent rounds.

## Success criteria

- [ ] C1: A standalone Lean lemma `isComputableSeqCMap_linearCombination` exists in
  `ComputableAnalysis/L4/Instances/CMap.lean`, with the same conclusion shape as the
  A1 field of `ComputabilityStructure` for C[a,b] (i.e. closure of the sequence
  predicate under linear combinations with computable rational coefficients), and the
  `ComputabilityStructure` instance field is defined `:= isComputableSeqCMap_linearCombination …`
  (or unfolds to it definitionally). Verified by `#print axioms isComputableSeqCMap_linearCombination`
  reporting **no `sorryAx`** (standalone-theorem method per `docs/PITFALLS.md §7`;
  field projection on the instance does NOT count — known false positive).
- [ ] C2: Blueprint node `\label{lem:l4_cmap_axiom1}` exists in `blueprint/src/L4.tex`
  with `\lean{isComputableSeqCMap_linearCombination}`, `\leanok` on the statement, and a
  `\begin{proof}\leanok ... \end{proof}` block whose prose faithfully describes what the
  Lean lemma states and proves. **Devil's-advocate required**: verify the LaTeX
  statement and the Lean lemma's type-signature agree on hypotheses and conclusion (no
  silent strengthening/weakening), and that the proof-sketch matches the actual Lean
  argument's strategy (polynomial approximation + finite-`max` norm-bound).
- [ ] C3: `thm:l4_cmap_instance` invokes `lem:l4_cmap_axiom1` via a **proof-level**
  `\uses` (placed inside the `\begin{proof}…\end{proof}` block, not at the
  statement level — because the typeclass signature does not name A1, but the
  instance's body assigns the A1 field from this lemma). **Devil's-advocate required**:
  verify the placement is proof-level (not statement-level), and that `leanblueprint web`
  renders the edge in the dep graph.
- [ ] C4: Verification pipeline green:
  (a) `lake build 2>&1 | tail -5` exit 0 with exactly **2 `sorry`s** remaining in
  `CMap.lean` (the A2 `isComputableSeq_of_effectiveLimit` and A3
  `isComputableSeqReal_norm` field bodies — unchanged in count by this refactor) and
  exactly **1 sorry-warning** on the `computabilityStructureCMap_of` decl (because
  A2/A3 still carry `sorry`);
  (b) the edited files (`CMap.lean`, `L4.tex`) have no line with codepoint length >100;
  (c) `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web 2>&1 | tail -5` exit 0;
  (d) `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls; echo "exit: $?"` exit 0
  (the new `\lean{isComputableSeqCMap_linearCombination}` target must resolve in the
  lake env).

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes`
- ≥3 iterations with identical unmet criteria
- Devil's-advocate verdict `unsound` on C2 or C3
- A new `sorry` introduced anywhere in `CMap.lean`, OR the A1 field's pre-existing
  sorry-freeness regressing (any path that re-introduces `sorryAx` into the A1
  lemma's transitive closure)
- iter ≥ 30 or elapsed ≥ 3600 minutes

## Out of scope (deferred to subsequent rounds)

- Closing A2 (`isComputableSeq_of_effectiveLimit`) — needs the effective-limit
  triangle-inequality bookkeeping (P-R Ch. 0 Thm 4).
- Closing A3 (`isComputableSeqReal_norm`) — blocked on L1 finite-`max`/abs closure,
  which is itself a separate L1 buildout round.
- Any change to L0/L1/L3/L5 Lean code or their blueprint chapters.
- Any change to `claims/INDEX.md` or the historical claim/goal trees of prior rounds.
