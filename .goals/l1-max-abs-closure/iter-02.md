# iter-02

timestamp: 2026-06-04T07:53:25.591530+00:00
unmet: [C1, C2, C3, C4, C5, C6]
mode: proof-attempt
progress: C3 closed (.abs sorry-free per #print axioms); .max + .min drafted but build outcome unknown at HALT (time budget hit at 206min ≫ 120min); two `show`-syntax errors fixed (double `:` ascription replaced by `↑(...) : ℚ`); build was running in background bj66lc4ve at HALT
files_changed: ['.goals/INDEX.md', 'current-goal.md', '.goals/l1-max-abs-closure/goal.md', '.goals/l1-max-abs-closure/iter-00.md']

## Decisions

- **Function shape**: `IsComputableSeqRat (fun k => max (r₁ k) (r₂ k))`, mirroring
  Mathlib's `Continuous.max : Continuous (fun b => max (f b) (g b))`.
- **Witness via chooseR1 boolean**: a single Bool function that determines whether
  max equals r₁ or r₂. newA/newB/newS all branch on the same chooseR1 — cleaner
  than `.add` (where newA's inner branches differ from newS's).
- **chooseR1 decision tree** (case-split on (par₁, par₂)):
  - (0,0) both ≥ 0: r₁ ≥ r₂ ⇔ a₁·b₂ ≥ a₂·b₁ ⇔ chooseR1
  - (0,1) r₁ ≥ 0 ≥ r₂: chooseR1 = true always
  - (1,0) r₂ ≥ 0 ≥ r₁: chooseR1 = false always
  - (1,1) both ≤ 0: r₁ ≥ r₂ ⇔ a₁·b₂ ≤ a₂·b₁ ⇔ chooseR1
- **`.min`**: dual of `.max` — flip chooseR1 direction.
- **`.abs`**: trivial — set newS := fun _ => 0, keep (a, b). |(-1)^s · (a/b)| = a/b.

## Next action

Edit `L1/ComputableSeqReal.lean` to insert `.max`, `.min`, `.abs` after `.mul`
(line 333) and before `.comp` (line 335). Then `lake build` to verify C1-C4.
