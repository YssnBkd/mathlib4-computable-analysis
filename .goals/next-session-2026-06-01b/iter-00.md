---
iter: 0
timestamp: 2026-06-01T20:41:31Z
mode: explore
files_changed: []
unmet:
  - C1
  - C2
  - C3
  - C4
  - C5
  - C6
---

# iter-00 — goal started

`next-session-2026-06-01b` initialized per user's `/goal` invocation. Baseline state captured
from prior session's handoff at `docs/NEXT-SESSION.md`:

- `formal/` builds with 0 errors and 2 sorry warnings, both at
  `ComputableAnalysis/L1/ComputableSeqReal.lean` lines ~116 and ~126
  (`isComputableSeqRat_const`, `isComputableSeqReal_const_rat`). Both blocked on a
  cast-asymmetry around `(natAbs : ℤ) → |·|`; recommended workaround is to import
  `Mathlib.Algebra.Order.Ring.Abs` to bring `Int.cast_natAbs` into scope.
- L3 keystone (`ComputabilityStructure` typeclass at
  `formal/ComputableAnalysis/L3/ComputabilityStructure.lean`) is `formalized`, 0 sorries.
- No L4 file exists yet. `formal/ComputableAnalysis/L4/Instances/` directory does not exist.
- Two Zulip pitches drafted, NOT posted, awaiting user decision; user chose `record-only`
  for this round.

## Plan (ordered, time-boxed)

1. **iter-01** — Run `lake build`, confirm 0 errors + 2 sorry baseline. Cheap sanity check.
2. **iter-02..04** — Close the two L1 helper sorries (NEXT-SESSION §Action 2). Three-attempt
   rule per CLAUDE.md / `/formalize` skill: try the `Int.cast_natAbs` import + the
   case-split-on-sign witness construction. If it doesn't land in three attempts, refresh
   the TODO and move on.
3. **iter-05..N** — Bring up `formal/ComputableAnalysis/L4/Instances/CMap.lean` (NEXT-SESSION
   §Action 3). Define the computable-sequence predicate on `C(Set.Icc a b, ℝ)` (G-L-flavoured,
   per P-R Ch. 2:124), prove the three L3 axioms + non-vacuity at the theorem level (sorries
   allowed in *theorem* bodies only), declare the `ComputabilityStructure` instance.
4. **iter-final-1** — Update CLAUDE.md milestone tracker; record Zulip decision under
   `docs/zulip-drafts/`.
5. **iter-final** — `/goal-end` (writes final.md, clears current-goal.md, updates INDEX).

## Risks I'm tracking

- **L4 instance scope creep.** The predicate definition is short; the axiom proofs are not
  — A3 (norms) bridges to L1's `IsComputableSeqReal`, which is the natural pivot, but A2
  (limits) needs a "uniform effective convergence" lemma that may not be in Mathlib. If
  A2 resists, theorem-body sorries with TODOs are explicit allowed by CLAUDE.md.
- **Cast-asymmetry fix might not be in `Mathlib.Algebra.Order.Ring.Abs`.** NEXT-SESSION
  flagged this — the lemma name `Int.cast_natAbs` is *probable*, not verified. If wrong,
  `loogle (n.natAbs : α) = |((n : ℤ) : α)|` or grep through the toolchain will locate it.
  Don't over-spin: 1-2 attempts then refresh the TODO.
- **`C(Set.Icc a b, ℝ)` vs `BoundedContinuousFunction` namespace.** Mathlib's sup-norm
  instance for `C(α, β)` requires `[CompactSpace α]` so we instantiate on `Set.Icc a b`
  with `a ≤ b`. Need to thread the `a ≤ b` hypothesis through the file structure.

## What "done" looks like

All six criteria checked. CLAUDE.md milestone tracker shows L4 CMap row at `stub` or
`formalized`. Build still green. Brief decision note in `docs/zulip-drafts/`.
