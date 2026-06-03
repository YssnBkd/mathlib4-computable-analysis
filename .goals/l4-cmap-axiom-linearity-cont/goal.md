---
slug: l4-cmap-axiom-linearity-cont
started: 2026-06-03T11:15:29Z
mode: proof-attempt
max_iterations: 16
time_budget_minutes: 360
allow_writes:
  - ComputableAnalysis/L4/Instances/CMap.lean
  - blueprint/src/L4.tex
  - blueprint/lean_decls
  - claims/l4-cmap-axiom-linearity/**
  - CLAUDE.md
  - .goals/l4-cmap-axiom-linearity-cont/**
  - .goals/INDEX.md
  - thinking/l4-cmap-axiom-linearity-cont/**
  - docs/NEXT-SESSION.md
forbid_writes:
  - ComputableAnalysis/L0/**
  - ComputableAnalysis/L1/**
  - ComputableAnalysis/L3/**
  - ComputableAnalysis.lean
  - blueprint/src/content.tex
  - blueprint/src/L0.tex
  - blueprint/src/L1.tex
  - blueprint/src/L2.tex
  - blueprint/src/L3.tex
  - blueprint/src/L5.tex
  - blueprint/src/blueprint.sty
  - blueprint/src/plastex.cfg
  - blueprint/src/latexmkrc.tex
  - blueprint/src/macros/**
  - literature/papers/**/verbatim.md
  - .claude/commands/**
  - .github/workflows/**
  - lakefile.toml
  - lake-manifest.json
  - lean-toolchain
devils_advocate_required_for:
  - "C2"
---

# Goal: Close L4 `axiom_linearity` (P-R Ch. 2 A1, polynomial form), removing the sole sorry-warning in `ComputableAnalysis/L4/Instances/CMap.lean`

## Why this matters
A1 is the first concrete `ComputabilityStructure` axiom proof on the `C[a,b]` instance. The L1 closures shipped in `l1-arithmetic-closure-and-real` (2026-06-03) now provide `IsComputableSeqRat.{add,mul,comp}` callable unqualified inside CMap.lean (the file already `open ComputableAnalysis.L1`), so the polynomial double-sum witness construction sketched in `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` is unblocked. Closing A1 ships the first nontrivial L4 instance and turns the L4 chapter's lead lemma green in the dep graph; A2/A3 can remain `sorry` per C3.

## Success criteria
- [ ] C1: `lake build` green; `ComputableAnalysis/L4/Instances/CMap.lean` has 0 sorry-warnings attributable to `axiom_linearity` (A2/A3 may remain — see C3). `leanblueprint checkdecls` exits 0.
- [ ] C2: `axiom_linearity` body inside `instComputabilityStructureCMap` is concrete (no `sorry`); the polynomial-approximation witness construction is faithful to `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` (precision pad + `IsComputableSeqRat.{add,mul,comp}` assembly at the ℚ-level). **DA-gated.**
- [ ] C3: A2 + A3 either remain `sorry` (with C1 wording updated to "0 sorries in A1; A2/A3 still sorry") or are also shipped (budget permitting).
- [ ] C4: Blueprint label `lem:l4_cmap_axiom_linearity` (or chosen name) goes `\leanok` in `blueprint/src/L4.tex`; `blueprint/lean_decls` regenerated.
- [ ] C5: Satellite `claims/l4-cmap-axiom-linearity/axiom_linearity.md` is written per `claims/TEMPLATE.md`, capturing the strategy that succeeded.

## Hard stops
- Any write outside `allow_writes` or matching `forbid_writes`
- ≥3 iterations with identical unmet criteria
- Devil's-advocate verdict `unsound` on any committed claim
- iter ≥ 8 or elapsed ≥ 180 min
