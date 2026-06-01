---
slug: next-session-2026-06-01b
started: 2026-06-01T20:41:31Z
mode: explore
max_iterations: 50
time_budget_minutes: 3600
allow_writes:
  - current-goal.md
  - .goals/INDEX.md
  - .goals/next-session-2026-06-01b/**
  - thinking/next-session-2026-06-01b/**
  - claims/next-session-2026-06-01b/**
  - formal/**
  - CLAUDE.md
  - docs/zulip-drafts/**
forbid_writes:
  - claims/l0-*/**
  - claims/l1-*/**
  - claims/l2-*/**
  - claims/l3-*/**
  - claims/l5-*/**
  - literature/papers/**/verbatim.md
  - raw_papers/**
  - .goals/execute-docs-next-session-md/**
  - .goals/l3-computability-structure-axioms/**
  - .goals/l3-computability-structure-lean/**
devils_advocate_required_for: []
---

# Goal: execute docs/NEXT-SESSION.md — close L1 helper sorries and bring up L4 C[a,b] sup-norm instance

## Why this matters

NEXT-SESSION.md hands off three concrete actions from the prior `l3-computability-structure-lean`
round: (1) verify the build still passes (cheap), (2) close the two L1 helper sorries whose
cast-asymmetry obstruction was diagnosed last session (recommended fix:
`import Mathlib.Algebra.Order.Ring.Abs` to bring `Int.cast_natAbs` into scope), and (3)
write the first concrete instance of the L3 `ComputabilityStructure` typeclass — the gentlest
target is `C([a, b], ℝ)` with sup-norm (P-R Ch. 2 §2-4, Ch. 2:124 for the
Grzegorczyk-Lacombe-flavoured computable-sequence predicate). Action 4 (Zulip posts) is
deferred per user decision: record-only, no posting.

The headline deliverable is L4 instance work — it's the first time the L3 typeclass meets
a concrete Banach space. If C[a,b] formalizes cleanly, the same template extends to L^p
and separable Hilbert later.

## Success criteria

- [ ] C1: `cd formal && lake build` exits status 0 at goal end. Sorry-warning count is
  tracked at iter-00 (baseline: 2 sorries in `L1/ComputableSeqReal.lean`) and at goal end;
  any new sorries are confined to theorem-body positions with explicit
  `-- TODO(/formalize L<N>):` comments per CLAUDE.md §sorry policy.
- [ ] C2: Both L1 helper sorries (`isComputableSeqRat_const` and `isComputableSeqReal_const_rat`
  in `formal/ComputableAnalysis/L1/ComputableSeqReal.lean`) are EITHER closed (no `sorry`
  remains in their proof bodies) OR retained with a refreshed `-- TODO(/formalize L1):`
  comment and an attempt log in the iter file under the three-attempt rule.
- [ ] C3: File `formal/ComputableAnalysis/L4/Instances/CMap.lean` exists, is wired into the
  Lake project (umbrella import updated if needed), and defines a P-R-shaped
  computable-sequence predicate on `ℕ → C(Set.Icc a b, ℝ)`. All `def` / `structure` /
  `class` / `instance` bodies in the file are sorry-free (CLAUDE.md §sorry policy hard
  rule).
- [ ] C4: An `instance : ComputabilityStructure ℝ C(Set.Icc (a : ℝ) b, ℝ)` (or equivalent
  declaration matching the L3 typeclass signature) is declared in CMap.lean. All four
  axiom-field positions (A1 linearity, A2 limits, A3 norms, NV non-vacuity) are present;
  theorem-body sorries in those proofs are permitted with TODO comments, but the instance
  itself must elaborate.
- [ ] C5: `cd formal && lake build` accepts CMap.lean (any new sorry warnings are flagged
  with TODO comments and listed in the goal's final report).
- [ ] C6: CLAUDE.md milestone tracker is updated: L1 row reflects sorry-closure outcome
  (→ `done` if closed, stay `formalized` otherwise); the L4 `C([a,b], ℝ)` row moves to
  `stub` (file exists, instance declared, some theorem-body sorries) or `formalized`
  (all bodies concrete; theorem sorries trivial). Zulip post decision recorded as a brief
  note in `docs/zulip-drafts/` (record-only — NO posting to Zulip itself).

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes`
- ≥3 iterations with identical unmet criteria
- iter ≥ max_iterations (50) or elapsed ≥ time_budget_minutes (3600)
- C3 or C4 hit the "200-line / 3+ def-body sorries" abandon condition from NEXT-SESSION.md
  §Action 3 — in that case mark C3/C4/C5 as `abandoned` with reason, keep C1/C2/C6.
- Zulip post performed against user's `record-only` decision
- Any external network action (no `gh`, no Zulip API, no PR creation, no remote pushes)
