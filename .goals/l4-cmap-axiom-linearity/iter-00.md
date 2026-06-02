---
iter: 0
timestamp: 2026-06-01T21:56:51Z
mode: proof-attempt
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

Round `l4-cmap-axiom-linearity` opened. No work performed yet; this entry only
records the initial state.

## Frame

- **Slug**: `l4-cmap-axiom-linearity`
- **Mode**: `proof-attempt` (caps at 6 iters by convention)
- **Budget**: 6 iters / 120 min
- **DA gate**: C2 (the A1 proof closure)

## Selection rationale

`docs/NEXT-SESSION.md` Action 3 names Direction A as the default and supplies
the slug/mode/budget verbatim. The user confirmed Direction A with the
**Extended** criterion set (A1 + literature pass) and DA scoped only to the
A1 proof itself.

A1 was chosen over A2/A3 because, under the P-R Ch. 2:141 polynomial-
approximation form, the proof is the most self-contained of the three:

- A1: rational arithmetic on polynomial coefficients; no new L1 lemmas.
- A2: needs `Computable` composition lemmas + diagonalization (Ch. 0 Thm 4).
- A3: needs an L1 closure lemma (`IsComputableSeqReal` closed under `max`),
  which is itself deferred work.

## First-iteration plan (iter-01)

1. Verify the build (Action 1 of NEXT-SESSION.md): `cd formal && lake build`.
   Expected: 0 errors, 1 sorry-warning at `L4/Instances/CMap.lean:104:23`.
2. Read the current `CMap.lean` end-to-end, especially the `axiom_linearity`
   theorem-body sorry and the `polyApproxCMap` / `IsComputableSeqCMap`
   definitions surrounding it.
3. Read `literature/papers/PourEl-Richards-chapt2.md` around lines 129 and 141
   for the verbatim citations the proof must thread through.
4. Draft the A1 proof skeleton (paper-form, in a scratch
   `thinking/l4-cmap-axiom-linearity/` note) before touching Lean — the
   rational-arithmetic bookkeeping is mechanical but easy to mis-thread.
