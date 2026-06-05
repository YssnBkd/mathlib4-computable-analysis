---
iter: 9
timestamp: 2026-06-04T10:30:00Z
mode: proof-attempt
unmet: [C4, C5, C6, C7, C8, C9]
files_changed:
  - ComputableAnalysis/L4/Instances/CMap.lean
note: |
  **Stage 3 substantial progress.** Modulus formulas refined for the Lipschitz
  argument (B → B+1, k_grid := 4·Lip·(B+1)·2^k+1). Added real-line variant
  `polyEval_lipschitz_real`. A3 signature now takes `hαβ : α ≤ β` (necessary
  — without it, `Set.Icc α β = ∅` and the adversarial-coefficient
  counterexample applies). Stage 3 skeleton: outer reduction + error (a) +
  combine all sorry-free; sole residual sorry is the analytic core
  `h_b : |sNK - ‖p‖| ≤ 2/2^K` (b1+b2 directions). Inside h_b, local constants
  + endpoint-closeness + (B+1)-bounds + xQ-convex-hull bound also landed
  sorry-free; the remaining work is the Lipschitz application itself.
---

# iter-09 — Phase 3.3 Stage 3 substantial progress

## What landed

### Modulus reformulation (`B → B+1`)

To make the Lipschitz argument work for grid points possibly outside `[α, β]`
(which lie in `[-(B+1), B+1]`), updated:
- `Lip_nat nN := Nat.rec 0 (fun j acc => acc + j · a_num(...) · (B+1)^(j−1)) ...`
  — uses `(B+1)^(j−1)` instead of `B^(j−1)`.
- `k_grid nN := 4 · Lip_nat nN · (B+1) · 2^nN.2 + 1` — uses `B+1` and `4` (the
  smaller constant matching the analytic decomposition).

Why this matters: the polynomial Lipschitz constant on `[-(B+1), B+1]` is
`Σⱼ j · |aⱼ| · (B+1)^(j−1)`, dominated by `Lip_nat (n, k)` viewed as ℝ. With
the previous `B^(j−1)` formula, that dominance fails for grid points outside
`[α, β]` (in particular when `B = 0`, `B^(j−1) = 0` ∀ j ≥ 1 but the actual
Lip can be nonzero on a neighborhood of zero).

### New top-level lemma: `polyEval_lipschitz_real`

The existing `polyApproxCMap_lipschitz` takes `x, y : Set.Icc α β` and bounds
`|p(x) − p(y)|` for the `ContinuousMap` evaluation. The new
`polyEval_lipschitz_real` takes raw `x, y : ℝ` with explicit `|·| ≤ C`
bounds and bounds the **polynomial expression** `Σⱼ aⱼ · x^j`. Structurally
identical proof (`abs_pow_sub_pow_le` + `pow_le_pow_left₀` + sum bounds);
~50 lines.

### A3 signature: `hαβ : α ≤ β` added

Necessary because:
- If `α > β`, then `Set.Icc α β = ∅`, `‖f n‖ = 0`, and the bound
  `‖f n − polyApproxCMap a d n k‖ ≤ 1/2^k` is vacuous (0 ≤ 1/2^k).
  So the user can choose ANY coefficients `a`, including ones making
  `sNK(n, k)` arbitrarily large. Our construction's bound `|sNK − ‖f n‖| ≤ 1/2^k`
  then FAILS.
- The natural fix is to require `α ≤ β`. The α > β degenerate case (empty
  interval, trivially-bounded continuous maps) is uninteresting for upstream
  contribution.

Updated `computabilityStructureCMap_of` to take and pass `hαβ`. **C6**
accordingly extended (instance refit takes 6 hypotheses, not 5).

### Stage 3 skeleton (inside A3 body)

```
intro n N k hkN
-- ① Reduce 1/2^N goal to 1/2^k via monotonicity.
suffices h_core : |((sNK (n, k) : ℝ)) - ‖f n‖| ≤ 1 / 2 ^ k by
  apply h_core.trans
  apply one_div_le_one_div_of_le
  · positivity
  · exact pow_le_pow_right₀ (by norm_num : (1:ℝ) ≤ 2) hkN
-- ② Set up local constants: K := k + 2, p := polyApproxCMap a d n K.
set K : ℕ := k + 2 with hK_eq
set p : C(Set.Icc α β, ℝ) := polyApproxCMap (α := α) (β := β) a d n K
-- ③ (a) Polynomial-approximation error: |‖p‖ - ‖f n‖| ≤ 1/2^K.
have h_a : |‖p‖ - ‖f n‖| ≤ 1 / 2 ^ K := by ... [sorry-free]
-- ④ (b) sNK ≈ ‖p‖: the analytic core.
have h_b : |((sNK (n, k) : ℝ)) - ‖p‖| ≤ 2 / 2 ^ K := by
  -- Local naming, closeness, (B+1)-bounds, xQ-convex-hull-bound: sorry-free.
  ...
  -- The remaining work: h_b1 (sNK ≤ ‖p‖ + 1/2^K) + h_b2 (‖p‖ ≤ sNK + 2/2^K).
  sorry  -- sole residual sorry
-- ⑤ Combine (a) + (b) → 1/2^k bound.
calc |((sNK (n, k) : ℝ)) - ‖f n‖|
    ≤ |((sNK (n, k) : ℝ)) - ‖p‖| + |‖p‖ - ‖f n‖| := abs_sub_le _ _ _
  _ ≤ 2 / 2 ^ K + 1 / 2 ^ K := add_le_add h_b h_a
  _ = 3 / 2 ^ K := by ring
  _ ≤ 1 / 2 ^ k := by
      rw [h_K_eq] -- 2^K = 4 · 2^k
      have h_pos : (0 : ℝ) < 2 ^ k := by positivity
      rw [div_le_div_iff₀ (by positivity) h_pos]; linarith
```

### Inside `h_b` (landed sorry-free)

- Local constants: `kg, mm, Lip_nℕ, α', β'` via `set` bindings.
- Closeness: `|α' - α| ≤ 1/2^mm`, `|β' - β| ≤ 1/2^mm` via `hαR_err`, `hβR_err`.
- `(B+1)`-bounds: `|α'|, |β'| ≤ B + 1` via triangle ineq.
- xQ-convex-hull bound: `|α' + (J/kg)·(β' - α')| ≤ B + 1` for `J ≤ kg` —
  proven by expressing xQ as a convex combination `(1 - J/kg)·α' + (J/kg)·β'`
  and bounding by the convex sum of bounds.

## Errors hit & fixes

1. **`abs_add` unknown identifier** — Mathlib4 name is `abs_add_le` (the new
   subadditivity lemma). Fixed.
2. **`one_le_pow_of_one_le'` requires `MulLeftMono ℝ` instance** — wrong lemma.
   Use `one_le_pow₀ (h : 1 ≤ a) : 1 ≤ a^n` (works on ℝ via `ZeroLEOneClass` +
   `PosMulMono`). Fixed.
3. **`rw [hrw]` with `hrw : β' = β + (β' - β)` rewrites recursively** — `β'`
   appears inside `(β' - β)` so `rw` keeps rewriting. Fix: use
   `calc ... = ... := by congr 1; ring` to introduce the desired form
   without explicit `rw`.

## Build status

- `lake build` ✓ — sole sorry @ `CMap.lean:2114` (A3 body's `h_b`'s analytic core).
- Build time: ~50s incremental, ~100s after Lipschitz lemma addition.

## Criteria delta

- C1, C2, C3 met.
- **C3 amended**: A3 signature now also takes `hαβ : α ≤ β`. Documented in
  `current-goal.md` (no explicit change needed since C3 just requires the
  signature to be "refitted").
- **C4 strong further progress**: the high-level Stage 3 structure (reduction,
  (a), combine) is sorry-free. Inside `h_b`, the local setup + bounds are also
  sorry-free. Sole residual: the Lipschitz argument tying sample values to
  ‖polyApproxCMap‖.
- **C5** (DA on error decomposition): the decomposition is now explicit in the
  code (h_a, h_b, combine), DA can review the structure.
- **C6**: needs update — `computabilityStructureCMap_of` now takes `hαβ`
  (already implemented in this iter).
- C7, C8, C9 unmet.

## What's needed for iter-10

Close `h_b`'s analytic core. Decomposition:
- **h_b1**: `(sNK (n, k) : ℝ) ≤ ‖p‖ + Lip_real · 1/2^mm ≤ ‖p‖ + 1/2^K`.
  - For each `J ≤ kg`, clamp `xQ_J` to `[α, β]` to get `xQ_J^c`. Distance
    `|xQ_J − xQ_J^c| ≤ 1/2^mm` (uses `hαβ`, `hα'_close`, `hβ'_close`).
  - Apply `polyEval_lipschitz_real` at `C := B + 1` to bound
    `|pℝ(xQ_J) − pℝ(xQ_J^c)| ≤ Lip_real · 1/2^mm`.
  - For `xQ_J^c ∈ [α, β]`, `pℝ(xQ_J^c) = (polyApproxCMap)(⟨xQ_J^c, hc⟩)`
    (the `ContinuousMap` evaluation).
  - `|sample_J| ≤ |p(xQ_J^c)| + Lip_real · 1/2^mm ≤ ‖p‖ + 1/2^K`.
  - Sup over J gives `sNK ≤ ‖p‖ + 1/2^K`.
- **h_b2**: `‖p‖ ≤ (sNK (n, k) : ℝ) + Lip_real · ((B+1)/kg + 1/2^mm) ≤ sNK + 2/2^K`.
  - For each `x ∈ [α, β]`, find `J*` with `xQ_{J*}` near `x`.
  - Cover argument: nearest grid point distance `≤ (B+1)/kg + 1/2^mm`.
  - `|p(x) − pℝ(xQ_{J*})| ≤ Lip_real · ((B+1)/kg + 1/2^mm)`.
  - `|p(x)| ≤ sNK + Lip_real · ((B+1)/kg + 1/2^mm) ≤ sNK + 2/2^K`.
  - Sup gives `‖p‖ ≤ sNK + 2/2^K`.
- **Combine h_b1 + h_b2** via `abs_sub_le_iff`.

Sub-lemmas likely needed (or inline):
- `h_Lip_real_le_nat`: `Lip_real ≤ (Lip_nℕ : ℝ)`.
- `h_Lip_2m_bound`: `Lip_real · 1/2^mm ≤ 1/2^K` (uses `Lip_nℕ ≤ 2^Lip_nℕ`).
- `h_Lip_BpKg_bound`: `Lip_real · (B+1)/kg ≤ 1/2^K`.
- `h_sNK_cast`: `((sNK (n, k) : ℚ) : ℝ) = sup over J of (|sample_J| : ℝ)`
  (cast distributes over sup').
- `h_pℝ_eq_p`: for `x ∈ [α, β]`, `pℝ(x) = (polyApproxCMap a d n K)(⟨x, _⟩)`.

## Iters budget

Used: 9 / 100. Remaining: 91. Estimated 4-6 more iters to close C4-C7.

## Files changed this iter

- `ComputableAnalysis/L4/Instances/CMap.lean`:
  - Lip_nat: `B^(j-1)` → `(B+1)^(j-1)`.
  - k_grid: `8·Lip·B·2^k+1` → `4·Lip·(B+1)·2^k+1`.
  - Computability proofs updated to match.
  - Added `polyEval_lipschitz_real` (~50 lines, sorry-free).
  - A3 signature: added `(hαβ : α ≤ β)`.
  - `computabilityStructureCMap_of` signature: added `(hαβ : α ≤ β)`.
  - Stage 3 skeleton inside A3 body: reduction + (a) + h_b stub + combine.
  - Inside h_b: local setup + closeness + (B+1)-bounds + xQ-hull bound.

## Verification

- `lake build` ✓ (sole sorry @ A3 body's `h_b` analytic core).
- Line-length check ✓.
- Stop-hook write-scope respected: only `CMap.lean` modified.
