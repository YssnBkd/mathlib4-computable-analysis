# iter-06

timestamp: 2026-06-05T15:23:41.163541+00:00
unmet: [C4, C5, C6, C7, C8]
mode: proof-attempt
progress: Predicate fix — added (∀ N, 0 < d N) conjunct to IsGLComputable clause (ii) to close the vacuous-witness bug; C2/C3 proofs updated with Nat.one_pos / Nat.two_pow_pos positivity discharges; lake build green; axioms = [propext, Classical.choice, Quot.sound] on all three. Re-running DAs on C1, C2, C3 in parallel.
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis.lean', 'current-goal.md', '.goals/l2-grzegorczyk-lacombe/goal.md', '.goals/l2-grzegorczyk-lacombe/iter-00.md', '.goals/l2-grzegorczyk-lacombe/iter-02.md', '.goals/l2-grzegorczyk-lacombe/iter-03.md', '.goals/l2-grzegorczyk-lacombe/iter-04.md', '.goals/l2-grzegorczyk-lacombe/iter-05.md', '.goals/l2-grzegorczyk-lacombe/iter-06.md', '.goals/l2-grzegorczyk-lacombe/reviews/C1.md', '.goals/l2-grzegorczyk-lacombe/reviews/C2.md', '.goals/l2-grzegorczyk-lacombe/reviews/C3.md', 'ComputableAnalysis/L2/GrzegorczykLacombe.lean']

## Note — predicate-fix rationale

**The bug.** In the pre-iter-06 `IsGLComputable` clause (ii):
```
∃ d : ℕ → ℕ, Computable d ∧ ∀ N x y, |x - y| ≤ 1/(d N : ℝ) → |f x - f y| ≤ 1/2^N
```
the witness `d := fun _ => 0` satisfies the existential for **any** `f`: `Computable.const 0` gives the recursiveness, and `1/(0:ℝ) = 0` (Mathlib convention) forces the antecedent to fire only at `x = y`, where the conclusion `|f x - f y| = 0 ≤ 1/2^N` is automatic. So the modulus clause was vacuous, collapsing the predicate to the Banach-Mazur definition (sequential computability alone, chapt0:520) — strictly weaker than P-R's Definition A (effective uniform continuity).

The DA verdicts on C1-C3 (iter-02, iter-03, iter-04) each examined the `d N = 0` edge in the context of a *fixed* witness proof and called it "harmless," but did not ask whether the *existential as a whole* admits trivial witnesses. The reviewers answered a narrower question than the bug surfaced.

**The fix.** Added `(∀ N, 0 < d N) ∧` as an explicit conjunct between `Computable d` and the modulus implication:
```
∃ d : ℕ → ℕ, Computable d ∧ (∀ N, 0 < d N) ∧ ∀ N x y, ...
```
This forces every witness `d` to be uniformly positive, restoring P-R's classical reading (where `1/d(N)` is implicitly a positive real). The docstring on the def + a new design-note paragraph on lines 58-69 document the rationale and the bug history.

**Why positivity rather than the `+1` shift (Option 1 in the user-decision menu).** Positivity is more semantically transparent — the predicate now matches Mathlib's idiom for analytic notions (`Metric.UniformContinuous` and friends use explicit positivity), and downstream extractors get `d N > 0` directly. The `+1` shift would be more idiomatic for `Nat.succ`-shaped indexing dimensions, which is not the right framing for a modulus.

**Proof-side changes.**
- `l2_const_gl` (C2): `refine` now takes 3 placeholders (clause (i), positivity, modulus). Positivity discharged by `Nat.one_pos`. Existing clause (i) and modulus proofs unchanged.
- `l2_id_gl` (C3): `refine` now takes 4 placeholders. Positivity discharged by `Nat.two_pow_pos N`. Existing clause (i), `Computable.nat_rec` recipe, and modulus-implication proofs unchanged.

**Verification (orchestrator-confirmed).**
- Single-file `lake env lean ComputableAnalysis/L2/GrzegorczykLacombe.lean` exits 0 silently.
- Full `lake build` 2533/2533 ✓.
- `#print axioms` on `IsGLComputable`, `l2_const_gl`, `l2_id_gl` each prints `[propext, Classical.choice, Quot.sound]`.

**Audit-trail action.** The old DA reviews at `reviews/C1.md`, `reviews/C2.md`, `reviews/C3.md` are stale (they reviewed the buggy predicate). Re-running DAs in parallel for the fixed code; the new verdicts will overwrite the old reviews. Per round policy this preserves the audit trail in the iter-XX.md notes (which reference the old reviews) but updates the canonical review file to the current state of the artifact.

Next: invoke `/devils-advocate C1`, `/devils-advocate C2`, `/devils-advocate C3` in parallel (single message, three Agent tool calls). After all three return `passes`, no checkbox flip needed (C1-C3 remain `[x]`).
