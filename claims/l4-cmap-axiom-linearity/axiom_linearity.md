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
da_status: done
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

## Current formalization state (rounds `l4-cmap-axiom-linearity-cont` + `…-bound`, 2026-06-03)

| Component | State | Lines |
|---|---|---|
| Instance signature restructured from `instance` to `def computabilityStructureCMap_of (B : ℕ) (hα_le : \|α\| ≤ B) (hβ_le : \|β\| ≤ B)` | ✓ Done | 15 |
| `IsComputableSeq := IsComputableSeqCMap` (the predicate field) | ✓ Done | 1 |
| `aS, dS, M, pad_X, pad_Y, bound_max, stuff_per_k, bound_aX/aY/αR/βR_at_0, bound_x_k, bound_y_k, h_Bpow` (witness defs + Computability) | ✓ Done | ~250 |
| `hM : Computable M` | ✓ Done | 12 |
| `hd_S : Computable dS` | ✓ Done | 28 |
| `IsComputableSeqRat (flatten aS)` via `finsetSum_rat` + helpers | ✓ Done | ~150 |
| `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1/2^m` (the norm bound) | ✓ Done (round `…-bound`) | ~260 (+ ~140 helpers) |
| `zero_seq` | ✓ Done (pre-existing) | 10 |

**`axiom_linearity` (A1) is fully closed `sorry`-free.** `lake build` green (2067 jobs); the single residual `declaration uses sorry` warning at `CMap.lean:634` is attributable solely to the two deferred fields `axiom_limits` (A2) and `axiom_norms` (A3), which remain `sorry` out of scope this round. So the decl still carries `sorryAx` and the blueprint node stays white-bordered (no `\leanok`).

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

## The norm bound — as formalized (round `l4-cmap-axiom-linearity-bound`)

> `∀ n m, ‖s n - polyApproxCMap aS dS n m‖ ≤ 1 / 2 ^ m`  (`CMap.lean:988–1249`)

Closed `sorry`-free in ≈260 lines, resting on a set of pure helper lemmas (§0b,
`CMap.lean:383–562`, all `sorry`-free):

- **`le_natRec_max g k N (h : k < N)`** : `g k ≤ Nat.rec 0 (fun j acc => max acc (g j)) N`.
  Gives both `stuff_per_k(n,k) ≤ bound_max n` and `dX/dY(k, M) ≤ dS(n,m)`.
- **`natRec_add_eq_sum c g N`** : `Nat.rec c (·+·) N = c + Σ_{j<N} g j` — converts the
  `Nat.rec` bound definitions into `Finset.sum` form for `polyApproxCMap_norm_le_sum`.
- **`abs_cast_neg_one_pow_div_le a b s (hb : b ≠ 0)`** : `|((-1)^s · (a/b) : ℝ)| ≤ a`
  (needs `b ≥ 1`). The per-coefficient ℕ-upper-bound, applied to `aX`, `aY`, `αR`, `βR`.
- **`perk_bound cα xkw αr pxkw ε Ca Px …`** : `|cα·xkw − αr·pxkw| ≤ ε·(Ca + Px)`, via the
  split `cα·xkw − αr·pxkw = cα·(xkw − pxkw) + (cα − αr)·pxkw` then `|cα|·ε + ε·|pxkw|`.
- **`closeout_nat D Bm m`** : `(D+1)·Bm·2^m ≤ 2^(m+(D+1)+Bm+2)` — the close-out; the `+2`
  in `M` is the slack source (replaces the pre-round "factor-of-4" heuristic).
- **`polyApproxCMap_eval`, `polyApproxCMap_conv_eval`, `polyApproxCMap_norm_le_sum`** — the
  approximant's pointwise value, the j–k swap / expansion identity, and the
  sup-norm-by-coefficients bound `‖poly‖ ≤ Σ_j |coef_j|·B^j`.

**Spine** (`CMap.lean:1003–1249`):

1. `ContinuousMap.norm_le (0 ≤ 1/2^m)` reduces `‖·‖ ≤ 1/2^m` to `∀ w, |(s n − polyApprox aS dS n m)(w)| ≤ 1/2^m`.
2. `hPval`: expansion identity `polyApproxCMap aS dS n m (w) = Σ_{k<d n+1} (αR(pair n k, M)·polyApprox aX dX k M + βR(…)·polyApprox aY dY k M)(w)`, via `polyApproxCMap_eval` + `polyApproxCMap_conv_eval` with `hge_dS : dX(k,M), dY(k,M) ≤ dS`.
3. `hsval`: `(Σ_k coefα•x_k + coefβ•y_k)(w) = Σ_k (coefα·x_k(w) + coefβ·y_k(w))`.
4. `rw [ContinuousMap.sub_apply, hsval, hPval, ← Finset.sum_sub_distrib]` collapses LHS−RHS into one `Σ_k` of per-k differences.
5. `hperk` — the per-k bound `|F_k − G_k| ≤ 2^{−M}·stuff_per_k(n,k)`, assembled from `hclose_X/Y` (`norm_coe_le_norm` + `hbnd_X/Y`), `hαr_close/hβr_close` (`hbnd_αR/βR`), `hcα_bd/hcβ_bd` (`|coefα| ≤ bound_αR_at_0 + 1` via the precision-0 approximant + `abs_sub_abs_le_abs_sub`), `hpXk_bd/hpYk_bd` (`|polyApprox..(w)| ≤ bound_x_k + 2` via a `norm_sub_norm_le` chain to the precision-0 approximant + `polyApproxCMap_norm_le_sum`), then `perk_bound` on X and Y + `abs_add_le` + `add_le_add`.
6. Assembly: `Finset.abs_sum_le_sum_abs` → `Finset.sum_le_sum hperk` → `Finset.mul_sum` → `Σ_k stuff_per_k ≤ (d n+1)·bound_max n` → `closeout_nat` closes via `M(n,m) = m+(d n+1)+bound_max n+2`.

**Deviations from the pre-round outline:** the j–k swap is encapsulated in the dedicated
helper `polyApproxCMap_conv_eval` rather than an inline `Finset.sum_comm`; the pointwise
reduction uses `ContinuousMap.norm_le` (not `norm_le_iff`); and the close-out is the exact
inequality `closeout_nat` rather than the heuristic "factor-of-4 × 2·(d n+1)·bound_max".

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

- **Last reviewed:** 2026-06-03 (round `l4-cmap-axiom-linearity-bound`, on C2 = the norm bound). Full review: `.goals/l4-cmap-axiom-linearity-bound/reviews/C2.md`.
- **Verdict: sound.** The `axiom_linearity` field (CMap.lean:638–1249) is a sorry-free, faithful proof of P-R Axiom 1 for `C([α,β], ℝ)` under the polynomial-approximation predicate; no soundness-laundering.
- **Attacks that passed:**
  - *Statement adequacy* — the goal type (`L3/ComputabilityStructure.lean:120-127`) encodes Axiom 1 verbatim against `PourEl-Richards-chapt2.md:66-72`; `Finset.range (d n + 1)` = `k=0..d(n)`; witness genuinely recursion-theoretic; **no `Classical.choose`/`Nonempty.some` in the witness path**.
  - *Close-out* — `closeout_nat` verified over an 8×8×8 grid; its RHS exponent is definitionally `M(n,m)`, so `hMunfold` is a genuine `rfl`.
  - *Bound lemmas* — `abs_cast_neg_one_pow_div_le` (correctly derives `1 ≤ b` from `b ≠ 0`), `polyApproxCMap_norm_le_sum`, `bound_x_k` via `natRec_add_eq_sum` all check out.
  - *Expansion identity* — degree domination `dX/dY(k,M) ≤ dS` is real (via `le_natRec_max`); no off-by-one (`d n + 1` ↔ `(d n).succ` defeq), no coefficient aliasing.
  - *Soundness-laundering* — all ten transitively-used helpers print axioms `[propext, Classical.choice, Quot.sound]`, **no `sorryAx`**; the instance-level `sorryAx` is from the deferred A2/A3 sibling fields only and cannot contaminate A1.
- **Non-blocking caveats (acknowledged, not defects):**
  - The `+6` in `stuff_per_k` exactly absorbs the `(1+2)+(1+2)` constants from the two `perk_bound` calls — tight but correct. (Note: the actual close-out uses `closeout_nat`'s `+2`-in-`M` slack, not the pre-round "factor-of-4" heuristic.)
  - The explicit-`B` parameterization is a documented scoping restriction relative to P-R's "recursive reals a, b" — downstream callers must supply `B`.

## Notes for future revisions

- The `IsComputableSeqRat ↔ Computable ℚ` bridge would simplify several Computability chains (especially the bound machinery). If a future L1 round ships this bridge, `bound_aX_at_0` etc. could be replaced by direct `|aX(k, 0, j).num.natAbs * B^j|` Computable expressions.
- `Finset.sum_comm` / `Finset.sum_product` for the j-k swap in the bound proof is potentially smooth in Mathlib; verify before writing the bound proof.
- The `addTriple` machinery could be lifted to L1 (`IsComputableSeqRat.add_triple` or similar) — currently private-in-CMap.lean per the round's `forbid_writes`.
- If the L2 G-L predicate ships in a future round, A1 collapses to a 5-line proof per P-R Ch. 2:128-129. Worth tracking.
