---
iter: 0
timestamp: 2026-06-04T07:52:07Z
mode: proof-attempt
unmet:
  - C1
  - C2
  - C3
  - C4
  - C5
  - C6
files_changed: []
note: goal started
---

# iter-00 — goal started

Round opened from `docs/NEXT-SESSION.md` recommendation (Phase 2 successor to
`l4-cmap-surface-axiom1`). Slug: `l1-max-abs-closure`. Mode: `proof-attempt`.
Budget: 14 iters / 120 min. DA scope: optional (blueprint prose only if it
departs from the L1.tex template).

## Concrete plan (from NEXT-SESSION.md §"Concrete plan")

1. **Grep Mathlib first** for `Computable.max`, `Primrec.max`,
   `Computable.natAbs`, `Computable.int?Abs` under
   `.lake/packages/mathlib/Mathlib/Computability/` and adjacent primitive
   areas. Decide whether `.max`/`.min`/`.abs` lift through a single
   `Primrec₂`/`Computable₂` compose, or whether the witness must be built
   inline via `Computable.nat_rec` over the rational triple `(a, b, s)`.
2. **Read `IsComputableSeqRat.add`** in
   `ComputableAnalysis/L1/ComputableSeqReal.lean` to fix the closure idiom:
   the witness shape, the sign-parity case split, and the cross-product
   comparison `a₁·b₂` vs `a₂·b₁` (both `b > 0`).
3. **Write `.max` first.** Single comparison between the two rational
   triples — choose the larger by cross-product, copy its `(a, b, s)`.
   Then `.min` is the dual; then `.abs` is the cheapest (set `s := fun _ => 0`).
4. **Add blueprint nodes** in `blueprint/src/L1.tex` mirroring
   `lem:l1_isComputableSeqRat_add` (`L1.tex:52-83` per NEXT-SESSION's pointer).
5. **Verify pipeline**: `lake build`; `#print axioms` on each new lemma;
   `leanblueprint web`; `leanblueprint checkdecls`; 100-col scan.

## Risk register

- **Mathlib primitive existence** — if `Computable.max`/`Primrec.max` exist on
  `ℚ` directly, the round may close in 4-5 iters; if we need inline
  `Computable.nat_rec` witness construction (the `.add` route), expect 6-8.
- **Sign-parity in `.max`/`.min`** — `.add` handles four sign-parity cases
  via cross-product; `.max` may inherit the same case structure since
  comparing `(a₁/b₁, s₁)` vs `(a₂/b₂, s₂)` depends on both magnitudes and
  signs. The TODO at `CMap.lean:1300` hints A3 ultimately needs `max` of
  *non-negative* values (`|q_i - q_j|`), but the L1 lemma should be stated
  generally for any sign.
- **Blueprint dark-green eligibility** — `lem:l1_isComputableSeqRat_max` will
  reach dark-green fill only if `def:l1_isComputableSeqRat` is dark-green
  (already proved). Cross-check at iter-end.
- **Stop hook scope** — `current-goal.md` checkbox flips are mandatory after
  each criterion closes; plan one bookkeeping iter for hook reactions per
  `feedback_round_pragmatism.md`.

Next action: iter-01 begins by grepping Mathlib for existing computability
primitives on `max`/`min`/`abs`, then re-reading `IsComputableSeqRat.add` to
lock the template.
