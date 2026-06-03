---
slug: l4-cmap-axiom-linearity-bound
started: 2026-06-03T15:56:45Z
mode: proof-attempt
max_iterations: 50
time_budget_minutes: 3600
allow_writes:
  - ComputableAnalysis/L4/Instances/CMap.lean
  - blueprint/src/L4.tex
  - blueprint/lean_decls
  - claims/l4-cmap-axiom-linearity/**
  - CLAUDE.md
  - .goals/l4-cmap-axiom-linearity-bound/**
  - .goals/INDEX.md
  - thinking/l4-cmap-axiom-linearity-bound/**
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
  - blueprint/src/latexmkrc
  - blueprint/src/macros/**
  - literature/papers/**/verbatim.md
  - .claude/commands/**
  - .github/workflows/**
  - lakefile.toml
  - lake-manifest.json
  - lean-toolchain
  - claims/INDEX.md
devils_advocate_required_for:
  - "C2"
---

# Goal: Close the L4 C[a,b] axiom_linearity norm bound (the sole remaining sorry in A1)

## Why this matters
The round `l4-cmap-axiom-linearity-cont` shipped 5/6 of `axiom_linearity` sorry-free:
witness (`aS`, `dS`, `M`), Computability, and `IsComputableSeqRat (flatten aS)`. The
only gap is the norm bound `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m`
(`ComputableAnalysis/L4/Instances/CMap.lean:809`). Closing it completes A1 (Linear
Forms) for the first concrete `ComputabilityStructure` instance on an
infinite-dimensional space, unblocking downstream L5 work. DA-verified 5/6-step
roadmap in `claims/l4-cmap-axiom-linearity/axiom_linearity.md:88-108`. See
`intuition`/design context: this round is Action 2 of `docs/NEXT-SESSION.md`.

## Success criteria
- [ ] C1: `lake build` green. The `axiom_linearity` field body contains no `sorry`.
  Build shows exactly **1** residual `declaration uses sorry` warning (now solely
  from `axiom_limits` + `axiom_norms`). Machine-check:
  `grep -nE "^[[:space:]]+sorry[[:space:]]*$" ComputableAnalysis/L4/Instances/CMap.lean`
  returns exactly **2** hits, down from 3.
- [ ] C2: The norm bound `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m` is proved
  concretely (no `sorry`), following the DA-verified outline in
  `claims/l4-cmap-axiom-linearity/axiom_linearity.md:94-106`. **[DA-required]**
- [ ] C3: `axiom_limits` (A2) and `axiom_norms` (A3) remain `sorry` (deferred — out of
  scope this round; C1's residual warning is attributable solely to these two).
- [ ] C4: blueprint `thm:l4_cmap_instance` prose updated to reflect `axiom_linearity`
  fully closed (witness + `IsComputableSeqRat` + norm bound); node **stays
  white-bordered** (NOT `\leanok`, since A2/A3 keep the decl's `sorryAx`).
  `leanblueprint checkdecls` exits 0 and `/verify` reports no new violations.
- [ ] C5: `claims/l4-cmap-axiom-linearity/axiom_linearity.md` updated with the bound
  proof's actual structure (replacing the deferred-outline section) + the DA verdict
  on C2.

## Hard stops
- Any write outside allow_writes or matching forbid_writes
- ≥3 iterations with identical unmet criteria
- Devil's-advocate verdict `unsound` on C2
- iter ≥ max_iterations (50) or elapsed ≥ time_budget_minutes (3600)
