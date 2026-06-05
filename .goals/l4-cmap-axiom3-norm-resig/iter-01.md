---
iter: 1
timestamp: 2026-06-04T00:30:00Z
mode: proof-attempt
unmet: [C1, C3, C4, C5, C6, C7, C8, C9]
files_changed:
  - ComputableAnalysis/L1/ComputableSeqReal.lean
note: |
  Phase 1 — P-R Prop 1 lifted as `isComputableSeqReal_of_effectiveConvergence`
  in L1 §2.5. Signature: rational doubly-computable r + Computable modulus e
  + ∀ n N k, k ≥ e(n,N) → |r(n,k) - x n| ≤ 1/2^N → IsComputableSeqReal x.
  Proof: diagonalised witness r'(n,k) := r(n, e(n,k)), with Computable reindex
  σ m := Nat.pair (Nat.unpair m).1 (e (Nat.unpair m)) and the bound from
  hconv at N := k, k_input := e(n,k). C2 met (#print axioms clean).
  C1 pending DA verdict.
---

# iter-01 — Phase 1 lemma landed, C2 met, C1 awaiting DA verdict

## What happened

Wrote `isComputableSeqReal_of_effectiveConvergence` in L1 (§2.5 between Def 5a
and the existing §3 sanity lemmas). Statement matches P-R Ch. 0 Proposition 1
(`chapt0:246`) in its rational-input specialization. Proof is ~30 lines and
follows P-R's "subsequence trick" (`chapt0:260-272`).

## Three Lean-specific gotchas hit and resolved

1. **`hr.comp hσ` failed** with `Invalid field 'comp': The environment does
   not contain 'Exists.comp'`. Cause: `IsComputableDoubleSeqRat` is a `def`
   that displays as `Exists`, and Lean's dot-notation reaches the unfolded
   head. **Fix**: rebind via `have hflat : IsComputableSeqRat _ := hr` to
   restore the displayed head.

2. **`hflat.comp hσ` still failed** — same root cause but at the
   `IsComputableSeqRat` level (it's also a `def` unfolding to `Exists`).
   **Fix attempt 1**: explicit name `IsComputableSeqRat.comp hflat hσ`.
   But Lean *parses* this as `IsComputableSeqRat ∘ comp hflat hσ` — treating
   `IsComputableSeqRat` as a function value and `.comp` as `Function.comp`!
   **Fix attempt 2**: `@IsComputableSeqRat.comp _ _ hflat hσ` — same problem,
   `@` only forces implicit-to-explicit, doesn't change parser interpretation.
   **Fix that worked**: inline `IsComputableSeqRat.comp`'s body —
   destructure `hflat` with `obtain` and rebuild the witness manually. This
   sidesteps the parser entirely and matches the §4 closure-lemma idiom.

3. **`change IsComputableSeqRat ...` succeeded for the unfold** — making the
   `IsComputableDoubleSeqRat r'` goal into the `IsComputableSeqRat (fun m => r ((Nat.unpair m).1, e (Nat.unpair m)))` form needed for the rebuild.

## Pitfall worth recording

These are real Lean-4 pitfalls that will hit again. Add to `docs/PITFALLS.md`
at round end:

> **§10: `IsComputableSeqRat.<method>` doesn't work via dot-notation OR
> explicit-name call.** `IsComputableSeqRat` is a `def` unfolding to
> `Exists`; dot-notation reaches the unfolded head. The explicit form
> `IsComputableSeqRat.foo h` parses as `IsComputableSeqRat ∘ foo h`
> (treating `IsComputableSeqRat` as a function value, `.foo` as
> `Function.comp` / projection). Workaround: destructure with `obtain
> ⟨a, b, s, ha, hb, hs, hne, heq⟩ := h` and rebuild manually.

## Files changed

- `ComputableAnalysis/L1/ComputableSeqReal.lean` — added §2.5 with the new
  named lemma (~70 lines including docstring).

## Verification done

- `lake build ComputableAnalysis.L1.ComputableSeqReal` — ✓ (37 s).
- `lake build` (full repo) — ✓; only warning is the expected A3 sorry.
- Standalone `#print axioms` on the new lemma returns exactly `[propext,
  Classical.choice, Quot.sound]` — sorry-free.

## Criteria delta

- C2 ✅ — lemma compiled, axioms clean.
- C1 ⏳ — implementation-complete but DA review (statement faithfulness +
  insight-mining from chapt0:246-272) pending.
- C3-C9 unmet.

## Next iter

While DA reviews C1, advance into Phase 2 (signature refit). The signature
refit is mechanical: add two hypothesis arguments to `isComputableSeqCMap_norm`
and to `computabilityStructureCMap_of`. No proof work yet — the body's `sorry`
stays in place until Phase 3.
