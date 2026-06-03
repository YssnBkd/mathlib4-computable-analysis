---
id: l4-cmap-axiom_linearity
blueprint: blueprint:thm_l4_cmap_instance
created: 2026-06-03
sources:
  - PourEl-Richards-chapt2:66-77
  - PourEl-Richards-chapt2:128-129
  - PourEl-Richards-chapt2:141-153
  - PourEl-Richards-chapt0:46
  - PourEl-Richards-chapt0:203
dependencies:
  - l1-arithmetic-closure-and-real
  - l3-computability-structure-axioms
da_status: pending
---

> **Blueprint:** `[[blueprint:thm_l4_cmap_instance]]` — formal statement and formalization
> state (`\leanok` / `\notready` / `\mathlibok`) live there. This file holds
> design rationale only.

# L4 — `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` axiom-1 (linearity) under the polynomial-approximation predicate

## Why this construction

A1 (Linear Forms) under the polynomial-form `IsComputableSeqCMap` predicate requires that finite scalar-linear combinations of computable continuous-function sequences remain computable. The polynomial-form witness assembles:

1. A precision pad `M (n, m) := m + (d n + 1) + bound_max(n) + 2`, Computable.
2. A degree bound `dS (n, m) := max_{k ≤ d n} max(dX(k, M), dY(k, M))`, Computable.
3. A coefficient triple-sequence `aS (n, m, j) := Σ_k (αR · pad_X + βR · pad_Y)`, in `IsComputableSeqRat` after triple-flattening.

The polynomial-form choice (over the more direct G-L "evaluator + modulus" form of P-R Ch. 0 §2) avoids an L2 dependency: L2's G-L predicate isn't yet formalized. Under polynomial form, the predicate routes directly through L1's `IsComputableSeqRat` without going through L2.

## Current formalization state (round `l4-cmap-axiom-linearity-cont`, 2026-06-03)

| Component | State | Lines |
|---|---|---|
| Instance signature restructured from `instance` to `def computabilityStructureCMap_of (B : ℕ) (hα_le : \|α\| ≤ B) (hβ_le : \|β\| ≤ B)` | ✓ Done | 15 |
| `IsComputableSeq := IsComputableSeqCMap` (the predicate field) | ✓ Done | 1 |
| `aS, dS, M, pad_X, pad_Y, bound_max, stuff_per_k, bound_aX/aY/αR/βR_at_0, bound_x_k, bound_y_k, h_Bpow` (witness defs + Computability) | ✓ Done | ~250 |
| `hM : Computable M` | ✓ Done | 12 |
| `hd_S : Computable dS` | ✓ Done | 28 |
| `IsComputableSeqRat (flatten aS)` via `finsetSum_rat` + helpers | ✓ Done | ~150 |
| `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m` (the norm bound) | ✗ **`sorry`** | — |
| `zero_seq` | ✓ Done (pre-existing) | 10 |

**5 of 6 axiom-fields closed; only the norm bound for `axiom_linearity` remains `sorry`.**

## Why a `def` taking explicit rational bound `B`, not an `instance`

The polynomial-form A1 norm-bound argument needs a Computable upper bound on `max(|α|, |β|)`. For arbitrary `α, β : ℝ` no such bound exists; given a rational bound `B`, the precision-pad argument absorbs `‖x_k‖_∞` via `Σ_j |aX(k, 0, j)| · B^j + 1`.

This matches **P-R Ch. 2:128** ("for recursive reals a, b"). The pre-round unconditional `instance` was provably unrealizable *by this proof strategy* (the polynomial-form `bound_x_k` chain — see DA verdict `.goals/l4-cmap-axiom-linearity-cont/reviews/C2.md:65-67` for the precise scope and a counterexample probe showing the unconditional case CAN be realizable via other strategies); the round identified this as a fundamental obstruction *for the polynomial-form bound argument* (see `.goals/l4-cmap-axiom-linearity-cont/iter-04.md` for analysis).

Downstream callers (currently none — L5 not built) must construct the instance explicitly with a `B` and the two inequality hypotheses.

## Alternatives considered

- **Unconditional instance over arbitrary α, β : ℝ** — rejected because A1's polynomial-form bound is genuinely unrealizable without rational bounds on the interval endpoints; the predicate's ε-bound requirement leaks back to `|α|, |β|`.
- **Conditional on `IsComputableReal α` and `IsComputableReal β`** (Path B in iter-04.md) — viable but more layered; extracting a Computable `B` from `IsComputableReal α` requires unfolding `IsComputableSeqReal (fun _ => α)` and computing a bound from the rational approximant. The explicit `(B : ℕ)` parameter is more direct.
- **Detour through L2's G-L predicate** — unavailable (L2 not yet formalized) and would be a much larger detour.

## Bound-machinery design (M, bound_max)

The core insight: from `hflat_X : IsComputableSeqRat (flat aX)` we extract `aX_a : ℕ → ℕ` Computable with `|flat_aX k| ≤ aX_a k` (since `b ≥ 1` makes `|q| = |a/b| ≤ a`). This bypasses the missing `IsComputableSeqRat ↔ Computable ℚ` bridge entirely.

```
bound_x_k k := 1 + Σ_j ∈ Finset.range (dX (k, 0) + 1), aX_a (Nat.pair k (Nat.pair 0 j)) * B^j
            ≥ 1 + ‖polyApprox aX dX k 0‖_∞
            ≥ ‖x_k‖_∞                                  (using hbnd_X at m=0 plus B ≥ |α|, |β|)
```

`stuff_per_k (n, k) := bound_x_k k + bound_y_k k + bound_αR_at_0(n,k) + bound_βR_at_0(n,k) + 6`. The `+6` absorbs the additive constants from the triangle-inequality decomposition.

`bound_max (n) := max_{k ≤ d n} stuff_per_k(n, k)`.

`M (n, m) := m + (d n + 1) + bound_max(n) + 2`. Then `2^M = 4 · 2^m · 2^(d n + 1) · 2^bound_max(n) ≥ 4 · (d n + 1) · bound_max(n) ≥ 4 · Σ_k stuff_per_k(n,k)`. The factor-of-4 gives slack for the bound argument.

## Reusable helpers shipped by this round (in `FinsetSumHelper` namespace)

1. **`addTriple, addTriple_b_ne_zero, tripleToRat, addTriple_correct, addTriple_computable`** — the L1 `IsComputableSeqRat.add`-witness formula at the ℕ-triple level, packaged for reuse.
2. **`finsetSum_rat`** — closure of `IsComputableSeqRat` under finite sum over a Computable-bounded range. Bridge to `L1.IsComputableSeqRat.finsetSum` in a future round.
3. **`ite_rat`** — closure under Bool-conditional with two `IsComputableSeqRat` branches.
4. **`isComputableSeqRat_doubleApply`** — `IsComputableDoubleSeqRat f` + Computable indexers → `IsComputableSeqRat (fun p => f (a p, b p))`.
5. **`isComputableSeqRat_tripleApply`** — same for triple-flattened sequences.

All sorry-free. These are independently useful and could be lifted to L1 in follow-up rounds (e.g., `l1-rat-finsetsum` per `docs/NEXT-SESSION.md`).

## The remaining gap: the norm bound

> `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1 / 2 ^ m`

The full proof outline (deferred to a follow-up round, `l4-cmap-axiom-linearity-bound`):

1. Polynomial-expansion identity: `polyApproxCMap aS dS n m (x_*) = Σ_k (αR · polyApprox aX dX k M + βR · polyApprox aY dY k M)(x_*)` via `Finset.sum_comm` swapping j and k, plus the padcoeff identity `Σ_{j ≤ dS} padcoeff aX k M j · x^j = polyApprox aX dX k M (x_*)` for k ≤ d n.
2. Reduce ContinuousMap-norm to pointwise sup via `ContinuousMap.norm_le_iff` or analogous.
3. Pointwise bound:
   ```
   |s n (x_*) - polyApproxCMap aS dS n m (x_*)|
     ≤ Σ_k (|coefα(n,k) · x_k - αR · polyApprox aX dX k M| + sim β)
   ```
4. Per-k triangle inequality + `hbnd_αR`, `hbnd_X`, `bound_x_k`, `bound_αR_at_0`:
   ```
   each k-term ≤ 2^{-M} · stuff_per_k(n, k)
   ```
5. Σ_k bound by `(d n + 1) · max_k = (d n + 1) · bound_max(n)`.
6. Close: `2^{-M} · 2 · (d n + 1) · bound_max(n) ≤ 1/2^m` by M's formula.

Estimated 200-300 lines. The follow-up round is well-scoped.

## Mathlib-idiom mapping

- `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` — extends L3's typeclass for arbitrary Banach space; this is its first concrete instance on a non-finite-dimensional space.
- `polyApproxCMap : ℕ × ℕ × ℕ → ℚ) → (ℕ × ℕ → ℕ) → ℕ → ℕ → C(Set.Icc α β, ℝ)` — `ContinuousMap.mk` of the polynomial evaluation, with `noncomputable` marker (the `ℚ → ℝ` cast is noncomputable in Mathlib).
- `IsComputableSeqRat`-side: `L1.IsComputableSeqRat.{add, mul, comp}` closures, lifted from the prior L1 round.

## Sources

- **P-R Ch. 2:66-72** (Axiom 1 statement) — `literature/papers/PourEl-Richards-chapt2.md:66-72`.
- **P-R Ch. 2:128-129** ("A1 is trivial for the G-L predicate") — `literature/papers/PourEl-Richards-chapt2.md:128-129`.
- **P-R Ch. 2:141-153** (polynomial-approximation form / Effective Density Lemma equivalence) — `literature/papers/PourEl-Richards-chapt2.md:141-153`.
- **P-R Ch. 2:128** ("for recursive reals a, b") — justifies the `(B : ℕ) (hα_le hβ_le)` parameterization.
- **P-R Ch. 0:46** (Definition 1, IsComputableSeqRat).
- **P-R Ch. 0:203** (Definition 5a, IsComputableSeqReal).

## Devil's-advocate verdict

- Last reviewed: never (round-end DA pending).
- Verdict: (none yet) — pending DA on the IsComputableSeqRat (flatten aS) proof (the 150-line chain) and on the bound-machinery soundness.
- Open weaknesses to flag for DA:
  - `convert h_r_flat using 1` (iter-09): does the Pi.add_apply/Pi.mul_apply reduction always succeed, or only here?
  - `bound_x_k` Computability via `Computable.nat_rec`: are the `Prod.snd` forms in step functions a problem for downstream consumers?
  - The factor-of-4 slack in M's bound: too tight under DA scrutiny?
  - The padcoeff identity (`Σ_{j ≤ dS} pad ... = polyApprox aX dX k M`) for k ≤ d n: this is the WLOG step the bound proof relies on; needs explicit verification.

## Notes for future revisions

- The `IsComputableSeqRat ↔ Computable ℚ` bridge would simplify several Computability chains (especially the bound machinery). If a future L1 round ships this bridge, `bound_aX_at_0` etc. could be replaced by direct `|aX(k, 0, j).num.natAbs * B^j|` Computable expressions.
- `Finset.sum_comm` / `Finset.sum_product` for the j-k swap in the bound proof is potentially smooth in Mathlib; verify before writing the bound proof.
- The `addTriple` machinery could be lifted to L1 (`IsComputableSeqRat.add_triple` or similar) — currently private-in-CMap.lean per the round's `forbid_writes`.
- If the L2 G-L predicate ships in a future round, A1 collapses to a 5-line proof per P-R Ch. 2:128-129. Worth tracking.
