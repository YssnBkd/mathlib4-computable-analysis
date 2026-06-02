---
slug: l4-cmap-axiom-linearity
ended: 2026-06-02T01:16:14Z
iterations: 5
outcome: budget-exhausted
---

# Final summary for goal: Close the A1 (`axiom_linearity`) theorem-body sorry in L4 `CMap.lean`

The round did not close C2 (the A1 sorry) but shipped a real, fully-proved
artifact: `isComputableSeqRat_add` — closure of L1's
`IsComputableSeqRat` under pointwise addition, the largest single closure
helper required for A1 (and reusable for A2/A3). The round ran 65% over
the 120-min budget; the central finding was that NEXT-SESSION.md's
"~80-120 Lean lines for A1" estimate undershot the actual cost by ~3-5×
because L1's planned-deferred arithmetic-closure machinery turned out to
be a hard prerequisite, not optional scaffolding.

## Criteria status

- [x] **C1** (build green, ≤1 sorry-warning at the L4 instance level).
  Final state: `lake build` returns 0 errors, **1 sorry-warning** at
  `formal/ComputableAnalysis/L4/Instances/CMap.lean:261:23` (the
  unchanged L4 instance grouping A1/A2/A3). The newly-added closure
  helper at `:81` has **zero internal sorries**.
- [ ] **C2** (A1 body sorry-free). **NOT MET.** A1's theorem body is
  unchanged from the round's start. The closure helper that landed
  unblocks part of A1's coefficient construction, but `_mul`, `_reindex`,
  `_finsetSum` plus ~50 lines of witness assembly still stand between
  the round's end-state and C2.
- [ ] **C3** (proof-reviewer verdict sound). **NOT MET / not run.** Did
  not reach a state where a full A1 proof existed to review.
- [ ] **C4** (devil's-advocate verdict not unsound). **NOT MET / not
  run.** DA was gated on C2 closure, which did not occur.
- [ ] **C5** (verbatim P-R citations at every nontrivial A1 step).
  **Paper-form done; Lean threading pending.** Citations were assembled
  in `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` against
  `literature/papers/PourEl-Richards-chapt2.md:66-72, 128-129, 141-150,
  53` and `chapt0.md:203`. The actual Lean A1 proof never reached the
  citation-threading stage. The closure helper that DID land carries a
  citation to `PourEl-Richards-chapt0.md:46` (P-R Ch. 0 Def 1).
- [ ] **C6** (CLAUDE.md tracker reflects A1 closure). **NOT MET.** The
  L4 row's annotation was not updated this round (A1 didn't close).
  See "Next-step recommendations" for a small partial-credit update
  worth doing.

## Artifacts produced

### Lean code (lake build green)

- `formal/ComputableAnalysis/L4/Instances/CMap.lean`:
  - **NEW**: `private theorem isComputableSeqRat_add` (~80 lines,
    fully proved). Witness via 4-case ℕ-level dispatch on sign-parities
    `(s₁ k % 2, s₂ k % 2)` × `(p₁ k ≥ p₂ k)` where `p₁ k = a₁ k * b₂ k`,
    `p₂ k = a₂ k * b₁ k`. Computability via `Computable.cond` + decidable
    rel lifts (`Primrec.beq`, `Primrec.nat_le.swap.decide`) + `of_eq`
    pattern. Rational identity via a `pow_red` helper
    (`(-1:ℚ)^n = (-1)^(n%2)`) + 6-sub-case ring identity proof
    (`Nat.cast_sub` for the truncated subtractions, `push_cast`,
    `field_simp`, `try ring`).
  - Header docstring `"## L1 closure helpers (private; TODO: refactor →
    ComputableAnalysis.L1)"` documents the temporary-home rationale.

### Design / strategy notes (informational)

- `thinking/l4-cmap-axiom-linearity/iter-02-orientation.md`: discovered
  the L1-closure bottleneck; paper-form proof outline.
- `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md`: Mathlib
  reconnaissance (Primcodable ℤ/ℚ available via Denumerable; ℤ/ℚ
  arithmetic Primrec NOT exported); full paper-form A1 proof with
  verbatim P-R citations (pre-discharge of C5 in paper form); Lean
  skeleton for 4 closure helpers; realistic-outcome projection (correctly
  predicted partial trajectory).
- `thinking/l4-cmap-axiom-linearity/iter-04-add-helper.lean.draft`:
  pre-port Lean draft of `isComputableSeqRat_add` — subsumed by the
  actual code that landed in `CMap.lean` during iter-05.

### Goal-tracking artifacts

- `.goals/l4-cmap-axiom-linearity/{goal.md, iter-00.md, iter-02.md,
  iter-03.md, iter-04.md, iter-05.md, reviews/}` (reviews/ is empty).

### Not produced

- `claims/l4-cmap-axiom-linearity/*.md` — none. The design fit in
  `thinking/` notes; no formal claim file was required.
- `proofs/l4-cmap-axiom-linearity/*.md` — none.
- `intuition/l4-cmap-axiom-linearity.md` — none.

## Devil's-advocate verdicts

None. C2 (the A1 closure, which was the only DA-gated criterion) was
never reached, so DA was never invoked. The `isComputableSeqRat_add`
helper that DID land is a closure lemma on L1's predicate, not a P-R
result whose conjectural truth requires adversarial review — its
correctness is type-checked by Lean.

## Key findings

1. **L1's arithmetic closure is not optional scaffolding for L4
   axioms.** The L1 file at `ComputableSeqReal.lean:56-64` explicitly
   defers closure of `IsComputableSeqRat` under `+`, `*`, reindex. We
   discovered iter-02 that under the polynomial-approximation form
   (P-R Ch. 2:141), every L4 axiom proof — including A1 — uses these
   closures non-trivially. NEXT-SESSION.md's "no new L1 lemmas needed"
   was a misjudgment.

2. **Mathlib does not export `Primrec₂` for ℤ-arithmetic or
   ℚ-arithmetic.** `Primcodable ℤ` and `Primcodable ℚ` are auto-derived
   via Denumerable (priority-10 instance in `Primrec/Basic.lean:139`),
   and `Primrec.nat_add/sub/mul/le` exist as primitives — but bridging
   from ℕ-Primrec to ℚ-Primrec requires manual derivation.
   **Implication**: closure proofs work at the ℕ-level via sign-num-den
   decomposition, not via a `Computable r : ℕ → ℚ` bridge.

3. **The `Computable.cond` + `of_eq` + `by_cases` pattern is the right
   idiom** for proving `Computable f` when `f` is defined with
   `if-then-else` on a decidable Prop predicate. Builds the function in
   Bool-`cond` form, then rewrites to Prop-`if` form via `of_eq`.

4. **The `pow_red : (-1 : ℚ)^n = (-1)^(n % 2)` lemma collapses
   `(-1)^(big_n)` to `(-1)^{0,1}`** via `Nat.div_add_mod`. Used inside
   the A1 closure helper; will be reusable for `_mul` and any future
   sign-tracking proofs.

5. **Time budget reality.** ~80 lines of Lean per iter is realistic when
   the pattern is well-understood; ~40-60 when iterating idioms. A
   ~300-500 line proof attempt across 4 helpers + A1 assembly needs
   8-10 iters or a much wider per-iter budget, not 6 × ~20 min.

6. **Round's main contribution survives the budget loss.**
   `isComputableSeqRat_add` is fully proved, type-checks, and is
   reusable for A2/A3 and any future A1 attempt. The round was net
   positive even though it did not satisfy C2.

## Open questions

1. **`_mul`, `_reindex`, `_finsetSum` closure helpers.** Same structure
   as `_add`; `_mul` should be simpler (no truncated-sub bookkeeping).
   Estimated 40-60 Lean lines each.

2. **A1 witness assembly.** Given all four closure helpers + L1's
   `IsComputableSeqReal` destructuring, ~50 lines of Lean to construct
   the rational triple-sequence `aˢ` and the degree bound `dˢ`, then
   prove the triangle-inequality bound.

3. **Refactor location.** Closure helpers should live in
   `ComputableAnalysis.L1` (proper architectural home), not L4. Current
   inline location is temporary, marked with `TODO(refactor → L1)`.

4. **A2 / A3 dependence.** A2 (limits) and A3 (norms) also use the
   closure helpers but additionally need composition lemmas for the
   modulus `e : ℕ × ℕ → ℕ` (A2) and an L1 closure under `max` /
   `abs` (A3, deferred work).

## Next-step recommendations

Ranked by value-per-effort:

1. **(Quick win)** Update `CLAUDE.md`'s L4 row annotation now to note
   the closure helper landed, even though A1 itself didn't close. This
   is the C6 partial-credit update mentioned above. Single-line edit.

2. **(Highest leverage)** Open a follow-up round
   `l4-cmap-axiom-linearity-cont` with widened `allow_writes` to
   include `formal/ComputableAnalysis/L1/**`. Budget 6 iters / 180 min
   (3× the budget that turned out too small here). Mode
   `proof-attempt`. Mission: lift `isComputableSeqRat_add` to L1; ship
   `_mul`, `_reindex`, `_finsetSum`; assemble A1.

3. **(Alternative pivot, lower stack-depth)** Open round
   `l1-is-computable-real` (Direction B from NEXT-SESSION.md). This
   defines `IsComputableReal : ℝ → Prop` and ships the L1 closure
   machinery in its proper home as a natural by-product. Once landed,
   the L4 A1 round becomes a much cleaner attack.

4. **(Architecture documentation)** Add a short
   `claims/l4-cmap-axiom-linearity/closure-helpers.md` design note
   recording: the discovered L1-closure bottleneck, the chosen ℕ-level
   strategy, the `pow_red` reusable lemma, and the work-order for the
   3 remaining helpers. Useful for whoever picks up the work next.
