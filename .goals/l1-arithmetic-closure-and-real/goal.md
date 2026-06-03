---
slug: l1-arithmetic-closure-and-real
started: 2026-06-03T09:15:10Z
mode: proof-attempt
max_iterations: 14
time_budget_minutes: 240
allow_writes:
  - ComputableAnalysis/L1/**
  - ComputableAnalysis/L4/Instances/CMap.lean
  - blueprint/src/L1.tex
  - blueprint/lean_decls
  - claims/l1-computable-reals/**
  - claims/l1-arithmetic-closure-and-real/**
  - CLAUDE.md
  - .goals/l1-arithmetic-closure-and-real/**
  - .goals/INDEX.md
  - thinking/l1-arithmetic-closure-and-real/**
  - docs/NEXT-SESSION.md
forbid_writes:
  - ComputableAnalysis/L0/**
  - ComputableAnalysis/L3/**
  - ComputableAnalysis.lean
  - blueprint/src/content.tex
  - blueprint/src/L0.tex
  - blueprint/src/L2.tex
  - blueprint/src/L3.tex
  - blueprint/src/L4.tex
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
  - "C3"
  - "C6"
---

# Goal: L1 arithmetic-closure round — lift `_add`, ship `_mul` and `_reindex|_finsetSum`, define `IsComputableReal`, migrate to blueprint-native

## Why this matters

A1 of the `C[α,β]` instance (L4) is blocked on three closure helpers for `IsComputableSeqRat` that belong in L1, not inline at the L4 instance. The prior round (`l4-cmap-axiom-linearity`, budget-exhausted 5/6 iters) shipped one of the three (`_add`, ~80 lines, fully proved) but kept it `private` inside `ComputableAnalysis/L4/Instances/CMap.lean` with a `TODO(refactor → L1):` marker. This round lifts that helper to its proper L1 home, ships its two siblings, defines the missing point-level predicate `IsComputableReal : ℝ → Prop` (P-R Ch. 0:55 — currently a `\notready` blueprint stub), and migrates the legacy L1 claim file to the post-2026-06-02 satellite format. Every Lean lemma that lands is mirrored as a `\leanok` blueprint node so the dep graph reflects actual state. See `docs/NEXT-SESSION.md` Action 2 for the full rationale.

## Success criteria

- [x] C1: `lake build` green at end of round; only residual sorry-warning is `ComputableAnalysis/L4/Instances/CMap.lean:261:23` (the A1/A2/A3 grouping). `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls` exits 0.
- [x] C2 (migration): `blueprint/src/L1.tex` has `\lean{...}\leanok` for every L1 declaration currently in `ComputableAnalysis/L1/ComputableSeqReal.lean` (the existing predicate + every helper lemma already at 0 sorries). The two pre-existing `\notready` stubs (`def:l1_isComputableSeqReal` already `\leanok`, `def:l1_isComputableReal`) are replaced or extended to reflect actual state.
- [x] C3 (lift): `isComputableSeqRat_add` lifted from `ComputableAnalysis/L4/Instances/CMap.lean` to `ComputableAnalysis/L1/ComputableSeqReal.lean` (or new `ComputableAnalysis/L1/RatClosure.lean`) under its proper public name; CMap.lean references the L1 version via the qualified name; the L4 TODO comment is removed. Blueprint label `lem:isComputableSeqRat_add` (or similar) `\leanok`. **DA required.**
- [x] C4 (mul): `isComputableSeqRat_mul` shipped (fully proved). Simpler sibling of `_add` — sign XOR, no truncated-subtraction bookkeeping. Blueprint label `lem:isComputableSeqRat_mul` `\leanok`.
- [x] C5 (reindex or finsetSum): at least one of `isComputableSeqRat_reindex` / `isComputableSeqRat_finsetSum` shipped. Blueprint label `\leanok`.
- [x] C6 (point predicate): `IsComputableReal : ℝ → Prop` defined in `ComputableAnalysis/L1/ComputableReal.lean` (or appended to ComputableSeqReal.lean); ~1-line def + 1-2 sanity lemmas; P-R Ch. 0:58 (Definition 3) citation in docstring. Blueprint label `def:l1_isComputableReal` `\leanok`. **DA required.** (Note: NEXT-SESSION.md inherited an incorrect "Ch. 0:55" — verified during DA review of this round that Def 2 ends at line 55 and Def 3 starts at line 58.)
- [x] C7 (satellite): `claims/l1-computable-reals/is-computable-seq-real.md` converted to satellite format per `claims/TEMPLATE.md`: formal statement removed (now in blueprint LaTeX); YAML `status:` field dropped; `blueprint:` field added pointing at the matching `\label`; `[[blueprint:...]]` pointer at top of body. Rationale prose preserved.

## Hard stops

- Any write outside allow_writes or matching forbid_writes
- ≥3 iterations with identical unmet criteria
- Devil's-advocate verdict `unsound` on any committed claim
- iter ≥ max_iterations (14) or elapsed ≥ time_budget_minutes (240)
- New sorry-warnings beyond the L4 baseline of 1 (`ComputableAnalysis/L4/Instances/CMap.lean:261:23`) committed to Lean source
- `\leanok` set on a blueprint env whose `\lean{...}` target has `sorry` in its proof body
