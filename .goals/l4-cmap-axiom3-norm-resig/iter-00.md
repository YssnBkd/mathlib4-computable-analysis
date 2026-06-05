---
iter: 0
timestamp: 2026-06-04T00:00:00Z
mode: proof-attempt
unmet: [C1, C2, C3, C4, C5, C6, C7, C8, C9]
files_changed: []
---

# iter-00 — round started

## Note

Round started. NEXT-SESSION.md examined and challenged in conversation;
refined plan adopted with five deviations from the literal NEXT-SESSION.md
text:

1. **Phase 1 added** — P-R Ch. 0 Proposition 1 lifted as named L1 lemma
   (`isComputableSeqReal_of_rat_effectiveLimit` or similar) BEFORE attacking
   A3. NEXT-SESSION.md implicitly inlined this; lifting wins on reuse for
   downstream Ch. 0 Th. 5 / Th. 7 / Effective Density Lemma work.
2. **L1 added to `allow_writes`** (needed for Phase 1).
3. **Instance design** collapsed to a single 5-hypothesis def
   `computabilityStructureCMap_of (B, hα_le, hβ_le, hα_c, hβ_c)`. The
   "two defs" and "outside instance" paths from NEXT-SESSION.md aren't
   viable since A3 is a required field of the `ComputabilityStructure`
   typeclass.
4. **`set chooseR1` idiom lift dropped** — out of critical path; can be
   revisited at round end if relevant.
5. **DA scope** broadened per user direction: DA should also be used to
   mine P-R verbatim chapters at decision points (modulus choice, Lipschitz
   wall, error-decomposition cross-check), not only to challenge claims.

## Plan (4 phases)

- **Phase 1 — Prop 1 lift (C1, C2).** Prove `isComputableSeqReal_of_rat_effectiveLimit`
  in L1.
- **Phase 2 — A3 signature refit (C3, C6 partial).** Extend
  `isComputableSeqCMap_norm` with `IsComputableReal α/β` hypotheses; update
  `computabilityStructureCMap_of`.
- **Phase 3 — A3 body fill (C4, C5).** Six-step proof tracing P-R's
  chapt0:984-1012.
- **Phase 4 — Verification + propagation (C6 final, C7, C8, C9).**

## Next iter

Begin Phase 1 — read P-R Ch. 0 Proposition 1 verbatim once more, draft the
Lean statement of `isComputableSeqReal_of_rat_effectiveLimit`, and request
DA review on the statement (C1).
