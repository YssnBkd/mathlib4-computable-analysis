---
slug: l4-cmap-axiom-linearity
started: 2026-06-01T21:56:51Z
mode: proof-attempt
max_iterations: 6
time_budget_minutes: 120
allow_writes:
  - intuition/l4-cmap-axiom-linearity.md
  - thinking/l4-cmap-axiom-linearity/**
  - claims/l4-cmap-axiom-linearity/**
  - proofs/l4-cmap-axiom-linearity/**
  - .goals/l4-cmap-axiom-linearity/**
  - .goals/INDEX.md
  - formal/ComputableAnalysis/L4/Instances/CMap.lean
  - CLAUDE.md
forbid_writes:
  - claims/** outside l4-cmap-axiom-linearity/
  - literature/papers/**/verbatim.md
  - raw_papers/**
  - formal/ComputableAnalysis/L0/**
  - formal/ComputableAnalysis/L1/**
  - formal/ComputableAnalysis/L3/**
  - formal/ComputableAnalysis.lean
devils_advocate_required_for:
  - "C2"
---

# Goal: Close the A1 (`axiom_linearity`) theorem-body sorry in L4 `CMap.lean`

## Why this matters

L4 `C([a, b], ℝ)` is the first concrete instance of the L3 `ComputabilityStructure`
typeclass. It is currently `stub` because A1/A2/A3 carry theorem-body sorries.
Closing A1 is the cleanest first step: under the P-R Ch. 2:141 polynomial-
approximation form the proof never leaves rational arithmetic, requires no new
L1 lemmas, and unblocks the L4 row's promotion path toward `formalized`. See
`docs/NEXT-SESSION.md` Direction A and
`formal/ComputableAnalysis/L4/Instances/CMap.lean` for the open obligation.

## Success criteria

- [x] C1: `cd formal && lake build` returns 0 errors. Sorry-warnings on A2/A3 are
  acceptable; A1's `-- TODO(/formalize L4 CMap):` comment must be removed and no
  sorry-warning may originate from the A1 theorem body. **(satisfied iter-02:
  1 sorry-warning at the instance level grouping A1/A2/A3, no errors. Will
  re-verify at end-of-round when A1 closes.)**
- [ ] C2: The body of `axiom_linearity` in
  `formal/ComputableAnalysis/L4/Instances/CMap.lean` is sorry-free and
  type-checks. *(DA-required.)*
- [ ] C3: `proof-reviewer` subagent verdict on the A1 proof body is "sound" or
  records only non-blocking minor weaknesses. Report at
  `.goals/l4-cmap-axiom-linearity/reviews/proof-reviewer-C2.md`.
- [ ] C4: `devils-advocate` subagent verdict on the A1 proof body is not
  `unsound`. Verdict file at
  `.goals/l4-cmap-axiom-linearity/reviews/devils-advocate-C2.md`.
- [ ] C5: Every nontrivial step in the A1 proof carries a
  `-- ref: literature/papers/PourEl-Richards-chapt2.md:LINE` citation. At
  minimum: the polynomial-approximation form (Ch. 2:141), the linearity claim
  under G-L (Ch. 2:129), and the rational-arithmetic closure invocation.
- [ ] C6: `CLAUDE.md` L4 CMap milestone row's annotation reflects A1's closure
  (e.g. "A2/A3 sorries remain; A1 closed"). Status may stay `stub` until all
  three close.

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes`
- ≥3 iterations with identical unmet criteria
- Devil's-advocate verdict `unsound` on the A1 proof
- iter ≥ 6 or elapsed ≥ 120 min
