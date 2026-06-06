# iter-04

timestamp: 2026-06-05T12:43:26.463787+00:00
unmet: [C4, C5, C6, C7, C8]
mode: proof-attempt
progress: C3 closed — l2_id_gl proved (d = fun N => 2^N via Computable.nat_rec; push_cast bridge); lake build green; axioms = [propext, Classical.choice, Quot.sound]; DA verdict passes (reviews/C3.md). C4-C8 remain.
files_changed: ['.goals/INDEX.md', 'ComputableAnalysis.lean', 'current-goal.md', '.goals/l2-grzegorczyk-lacombe/goal.md', '.goals/l2-grzegorczyk-lacombe/iter-00.md', '.goals/l2-grzegorczyk-lacombe/iter-02.md', '.goals/l2-grzegorczyk-lacombe/iter-03.md', '.goals/l2-grzegorczyk-lacombe/reviews/C1.md', '.goals/l2-grzegorczyk-lacombe/reviews/C2.md', 'ComputableAnalysis/L2/GrzegorczykLacombe.lean', '.goals/l2-grzegorczyk-lacombe/iter-04.md']

## Note

- Appended `theorem l2_id_gl : IsGLComputable (⟨fun x : Set.Icc α β => (x : ℝ), continuous_subtype_val⟩ : C(Set.Icc α β, ℝ))` to `ComputableAnalysis/L2/GrzegorczykLacombe.lean`.
- **Clause (i)** discharged by `exact hx`: the output sequence `fun n => (coord_incl) (x n)` reduces definitionally (via ContinuousMap's FunLike coe → structure-literal `.toFun` → beta) to `fun n => (x n : ℝ)`, which IS the input hypothesis `hx`.
- **Clause (ii) — modulus witness** `d := fun N => 2^N`. The `Computable d` proof is inline via the `Computable.nat_rec` recipe from `docs/PITFALLS.md §1` (no `Primrec.nat_pow` in Mathlib), proven verbatim in `CMap.lean:1316-1329`'s `h_Bpow`. The induction step uses `show` to bridge the `(y, IH).2 * 2`-form Lean displays after nat_rec (per `docs/LEAN-IDIOMS.md §2`).
- **Clause (ii) — modulus implication** discharged by `push_cast at hxy; exact hxy`. The `push_cast` normalizes `((2^N : ℕ) : ℝ)` to `(2 : ℝ)^N` via `Nat.cast_pow` and `Nat.cast_ofNat`, after which the antecedent matches the goal definitionally (identity preserves distance).
- Single-file `lake env lean` exits 0 silently; full `lake build` 2533/2533 ✓; `#print axioms` = `[propext, Classical.choice, Quot.sound]`.
- Next: invoke `/devils-advocate C3` checking (a) ContinuousMap structure-literal well-formedness (η-match of `fun x => (x : ℝ)` with `Subtype.val`), (b) modulus witness `d N = 2^N ≥ 2^N` discharges, (c) `push_cast`-bridge soundness, (d) nat_rec recipe faithfulness to CMap.lean:1316-1329 pattern.

