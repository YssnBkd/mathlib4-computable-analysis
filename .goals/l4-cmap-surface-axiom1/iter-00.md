---
timestamp: 2026-06-04T00:33:26Z
iter: 0
mode: proof-attempt
unmet: [C1, C2, C3, C4]
files_changed: []
note: goal started
---

# iter-00 — goal started

Round `l4-cmap-surface-axiom1` opened to execute Phase 1 of `docs/NEXT-SESSION.md`'s
"drive C[a,b] to a complete instance" plan: surface the A1 win as a green blueprint
node by extracting the already-closed A1 proof from the inline `instance`-field-body
into a named standalone lemma. No new mathematics; refactor + blueprint update only.

## Env preflight (run 2026-06-04, before round open)

- `lake build` → **2532 jobs, exit 0**. Single warning at
  `ComputableAnalysis/L4/Instances/CMap.lean:639:31`
  (`declaration uses 'sorry'`) covering both A2 and A3 field bodies. Matches the
  claim in NEXT-SESSION.md verbatim.
- `grep -n "sorry" CMap.lean` → exactly **2** `sorry` lines at
  `CMap.lean:1268` (A2 = `isComputableSeq_of_effectiveLimit` field body) and
  `CMap.lean:1279` (A3 = `isComputableSeqReal_norm` field body). Also matches.
- File scope locked: `namespace ComputableAnalysis.L4` (`CMap.lean:58`) →
  `section CMap` (`CMap.lean:485`) with `variable {α β : ℝ}` (line 487) →
  `end CMap` (line 1293) → `end ComputableAnalysis.L4` (line 1295).
- A1 inline body: `isComputableSeq_linearCombination := by` at `CMap.lean:643`
  (with `obtain` destructuring at 645 and onward), continuing until the next
  field assignment `isComputableSeq_of_effectiveLimit := by` at `CMap.lean:1258`
  — so the A1 tactic block occupies ~615 lines (CMap.lean:644..1257). The
  extraction will hoist all of those into a standalone theorem above the
  instance decl at line 639.
- Outer args: `computabilityStructureCMap_of (B : ℕ) (hα_le : |α| ≤ (B : ℝ))
  (hβ_le : |β| ≤ (B : ℝ))` (`CMap.lean:639-641`). Both `B` and the bound
  hypotheses are needed inside the A1 body (per the iter-05 rationale at
  `CMap.lean:622-629`), so the extracted theorem must take them as explicit
  arguments too.
- Current `blueprint/src/L4.tex` (39 lines): single `\theorem
  thm:l4_cmap_instance` (lines 5-27) with an inline `\begin{proof}` summarising
  all three axioms. No node yet for A1 alone. Plus two `\notready` stubs for
  L^p and Hilbert instances. Phase 1 adds `lem:l4_cmap_axiom1` between the
  theorem and its proof (or just before the proof block).

## Target (this round)

Refactor + blueprint exposure of the closed A1 lemma. Criteria summary:

- C1: standalone, sorry-free Lean lemma `isComputableSeqCMap_linearCombination`
  + instance field delegates to it.
- C2: blueprint node `lem:l4_cmap_axiom1` with `\lean{...}`, `\leanok`, and a
  `\begin{proof}\leanok ... \end{proof}` block. DA-required.
- C3: `thm:l4_cmap_instance`'s proof block references `lem:l4_cmap_axiom1` via
  proof-level `\uses`. DA-required.
- C4: full verification pipeline (lake build, ≤100 cols, leanblueprint web,
  leanblueprint checkdecls) green; sorry/warning counts unchanged.

## Plan for iter-01

1. Read `ComputableAnalysis/L3/ComputabilityStructure.lean` to pin down the
   *exact* type signature the A1 field expects (the type of
   `ComputabilityStructure.isComputableSeq_linearCombination`). Without this
   the extracted theorem's signature is guesswork — grep first
   (`CLAUDE.md §"When in doubt, grep"`).
2. Read `CMap.lean:644..1257` end-to-end to know what's being hoisted —
   especially any references to `α`, `β`, `B`, `hα_le`, `hβ_le` that need to
   be in scope.
3. Draft the standalone theorem (signature + body = existing tactics) above
   line 639. Body unchanged — pure code motion.
4. Replace lines 643..1257 with the one-liner
   `isComputableSeq_linearCombination := isComputableSeqCMap_linearCombination B hα_le hβ_le`
   (or `:= by exact …` if elaboration needs help).
5. `lake build` → expect still 2532 jobs, single warning at the (now shifted)
   instance decl line, two `sorry`s in unchanged A2/A3 body positions.
6. `#print axioms isComputableSeqCMap_linearCombination` via a temporary
   `#print axioms` line, then remove the line — verify no `sorryAx`. (PITFALLS
   §7 standalone method.)

iter-02 onward: blueprint changes (C2, C3) + DA review + verification pipeline.
