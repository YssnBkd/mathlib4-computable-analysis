---
slug:
started:
mode:
max_iterations:
time_budget_minutes:
allow_writes:
forbid_writes:
devils_advocate_required_for:
---

# Goal: (none active)

No active goal. Run `/goal <slug>` to start one.

The most recent completed goal was `l4-cmap-axiom-linearity`
(budget-exhausted, 5/6 iters, ~198 min). See
`.goals/l4-cmap-axiom-linearity/final.md` for the full report. Main
deliverable: `isComputableSeqRat_add` (private theorem, ~80 lines) in
`formal/ComputableAnalysis/L4/Instances/CMap.lean` — fully proved closure
of L1's `IsComputableSeqRat` under pointwise addition, reusable for L4
A1/A2/A3 and a candidate refactor target for L1 proper. A1 itself
remains a `sorry` (3 more closure helpers + ~50 lines of witness
assembly needed).
