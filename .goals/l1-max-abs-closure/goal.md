---
slug: l1-max-abs-closure
started: 2026-06-04T07:52:07Z
mode: proof-attempt
max_iterations: 14
time_budget_minutes: 120
allow_writes:
  - ComputableAnalysis/L1/ComputableSeqReal.lean
  - ComputableAnalysis/L1/**
  - ComputableAnalysis.lean
  - blueprint/src/L1.tex
  - blueprint/lean_decls
  - .goals/l1-max-abs-closure/**
  - thinking/l1-max-abs-closure/**
  - current-goal.md
  - .goals/INDEX.md
  - docs/NEXT-SESSION.md
  - docs/PITFALLS.md
  - docs/LEAN-IDIOMS.md
forbid_writes:
  - ComputableAnalysis/L0/**
  - ComputableAnalysis/L2/**
  - ComputableAnalysis/L3/**
  - ComputableAnalysis/L4/**
  - ComputableAnalysis/L5/**
  - blueprint/src/L0.tex
  - blueprint/src/L2.tex
  - blueprint/src/L3.tex
  - blueprint/src/L4.tex
  - blueprint/src/L5.tex
  - literature/papers/**/verbatim.md
  - lakefile.toml
  - lake-manifest.json
  - lean-toolchain
  - claims/INDEX.md
  - .github/workflows/**
devils_advocate_required_for: []
---

# Goal: L1 closure under finite `max`, `min`, and absolute value — unblock A3 (sup-norm)

## Why this matters

A3 (`isComputableSeqReal_norm` — sup-norm computable, the last open axiom in
`computabilityStructureCMap_of`) needs `IsComputableSeqRat.max` over a finite
index range plus `IsComputableSeqRat.abs`, per the TODO sketch at
`ComputableAnalysis/L4/Instances/CMap.lean:1299-1308` (P-R Ch. 0 Thm 7).
Without these L1 primitives, A3 has no clean way to express its witness array.
This round extends an already-green L1 layer with three lemmas that pattern-match
`IsComputableSeqRat.add` (`\leanok` since round `l1-arithmetic-closure-and-real`).

See `docs/NEXT-SESSION.md` for the full plan and ranked alternatives menu.

## Success criteria

- [ ] C1: `IsComputableSeqRat.max` defined and sorry-free in
  `ComputableAnalysis/L1/ComputableSeqReal.lean`; verified by standalone
  `#print axioms IsComputableSeqRat.max` showing only
  `[propext, Classical.choice, Quot.sound]` (no `sorryAx`).
- [ ] C2: `IsComputableSeqRat.min` defined and sorry-free; same `#print axioms`
  audit passes.
- [ ] C3: `IsComputableSeqRat.abs` defined and sorry-free; same `#print axioms`
  audit passes.
- [ ] C4: `lake build` succeeds end-to-end with exactly **2** `sorry`s (the
  two pre-existing A2/A3 sorries in `CMap.lean`) and no new warnings.
- [ ] C5: Blueprint nodes `lem:l1_isComputableSeqRat_max`,
  `lem:l1_isComputableSeqRat_min`, `lem:l1_isComputableSeqRat_abs` added to
  `blueprint/src/L1.tex` with `\lean{...}`, `\leanok` on statement, and a
  `\begin{proof}\leanok ... \end{proof}` block referencing
  `def:l1_isComputableSeqRat`. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web`
  exits 0.
- [ ] C6: `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls` exits 0
  (every `\lean{}` target resolves in the lake env); no line in any edited
  `.lean` file exceeds 100 codepoints.

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes`
- ≥3 iterations with identical unmet criteria
- iter ≥ 14 or elapsed ≥ 120 min
