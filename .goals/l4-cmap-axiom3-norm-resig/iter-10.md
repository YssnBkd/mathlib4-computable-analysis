---
iter: 10
timestamp: 2026-06-05T00:00:00Z
mode: proof-attempt
unmet: []
files_changed:
  - ComputableAnalysis/L4/Instances/CMap.lean
  - blueprint/src/L1.tex
  - blueprint/src/L4.tex
  - blueprint/lean_decls
  - current-goal.md
  - .goals/INDEX.md
  - .goals/l4-cmap-axiom3-norm-resig/iter-10.md
  - .goals/l4-cmap-axiom3-norm-resig/reviews/C5.md
  - docs/NEXT-SESSION.md
  - docs/PITFALLS.md
  - docs/LEAN-IDIOMS.md
note: |
  **Round closes — A3 fully proved.** This iter landed everything:
  - Stage 3 (analytic core `h_b`): clamping + floor-cover + midpoint
    case-split degenerate, all sorry-free.
  - DA verdict `passes` on the three-error decomposition.
  - Blueprint promote (lem:l4_cmap_axiom3 + thm:l4_cmap_instance + Prop 1 entry).
  - Docs refresh (NEXT-SESSION rewrite, PITFALLS §10-§14, LEAN-IDIOMS recipes).
  All criteria C1-C9 met. `#print axioms` clean. `lake build` 2532 jobs green.
---

# iter-10 — Phase 3.3 Stage 3 complete: A3 closes sorry-free

## What landed

### Modulus reformulation (small tweak for tightness)

- `m_mod := Lip_nat + N + 3` (was `+ 2` in iter-09; bumped to `+ 3` to give the
  3/2^mm-degenerate-case bound `Lip · 3/2^mm ≤ 2/2^K` headroom).
- `k_grid := 8·Lip·(B+1)·2^N + 1` (was `4·(B+1)` in iter-09; restored to `8·(B+1)`
  matching iter-08's factor with the `(B+1)` correction from iter-09).
- Computability proofs updated (`Computable.const 8`, two-step
  `Computable.succ.comp`).

The tighter constants make both the non-degenerate (1/2^mm + 2(B+1)/kg)
and degenerate (3/2^mm in the worst-case, via midpoint argument bounded by
2/2^mm) Lipschitz contributions fit within `2/2^K`:

- `Lip · 1/2^mm ≤ 1/2^K` (uses `Lip ≤ 2^Lip` from `Nat.lt_two_pow_self`).
- `Lip · 2(B+1)/kg ≤ 1/2^K` (uses `kg ≥ 8·Lip·(B+1)·2^k`).
- Sum: `≤ 2/2^K`. ✓

### Helpers inside `h_b` (all sorry-free)

Ordered as recorded in iter-09's plan:

1. `xQ : ℕ → ℝ := fun J => α' + (J : ℝ)/(kg : ℝ) · (β' − α')` — real-line
   grid points.
2. `h_min_αβ'`, `h_max_αβ'` — padded interval bounds via `hαβ`,
   `hα'_close`, `hβ'_close` (case-split `α' ≤ β'` vs `α' > β'`).
3. `h_xQ_in_padded` — `xQ J ∈ [α − 1/2^mm, β + 1/2^mm]` via convex
   combination + min/max bounds.
4. `h_clamp_close` — `|xQ J − projIcc α β hαβ (xQ J).val| ≤ 1/2^mm`
   via three-case split (xQ J vs α, β).
5. `h_rEntry_eq` — `((rEntry ((n,k), J) : ℚ) : ℝ) = |∑ⱼ (a(n,K,j):ℝ)·xQ_J^j|`
   via stepwise unfolding (σ-app, hn_eq, hN_eq, hKidx_eq, h_J_extract,
   h_mmod_eq, h_kgrid_eq, h_gridQ_eq) followed by `Rat.cast_abs` and
   `Rat.cast_sum`.
6. `h_sNK_cast` — `((sNK : ℚ) : ℝ) = sup' (cast ∘ rEntry)` via
   `Finset.apply_sup'_eq_sup'_comp` with `Rat.cast_max`.
7. `h_Lip_natrec` — `Nat.rec 0 step N = ∑ j ∈ range N, summand j` by
   induction. Closes `h_Lip_nℕ_eq : Lip_nℕ = sum over j of ...`.
8. `h_a_bnd` — per-coefficient bound `|(a (n,K,j) : ℝ)| ≤ (a_num : ℝ)` via
   `ha_eq` + `Rat.cast_abs` + division bound.
9. `h_Lip_real_le_nat` — polynomial Lipschitz `Σⱼ j·|a|·(B+1)^(j−1) ≤
   (Lip_nℕ : ℝ)` term-by-term.
10. `h_Lip_2m_le_K` — `Lip · 1/2^mm ≤ 1/2^K` via `Lip ≤ 2^Lip` and explicit
    power-arithmetic (`hmm_form` substitution + `div_le_div_iff₀`).
11. `h_Lip_BpKg_bound` — `Lip · 2(B+1)/kg ≤ 1/2^K` via `kg ≥
    8·Lip·(B+1)·2^k` and arithmetic.
12. `h_combined_bound` — sum `≤ 2/2^K` (linarith from 10, 11).

### `h_b1` (clamping direction)

For each `J ∈ Finset.range (kg + 1)`:
- Clamp `xc_J := Set.projIcc α β hαβ (xQ J) ∈ [α, β]`.
- Apply `polyEval_lipschitz_real` to bound
  `|pℝ(xQ J) − pℝ(xc_J.val)| ≤ Lip · 1/2^mm ≤ 1/2^K`.
- `|pℝ(xc_J.val)| ≤ ‖p‖` via `ContinuousMap.norm_coe_le_norm`.
- Triangle inequality gives `|pℝ(xQ J)| ≤ ‖p‖ + 1/2^K`.
- `Finset.sup'_le` to conclude `(sNK : ℝ) ≤ ‖p‖ + 1/2^K`.

### `h_b2` (covering direction)

Reduced via `ContinuousMap.norm_le` to per-point bound on `|p x|`. The cover
construction case-splits on `α' < β'`:

**Non-degenerate (α' < β')**: clamp `y := max α' (min β' x.val) ∈ [α', β']`,
parameter `t := (y − α')/(β' − α') ∈ [0,1]`, integer
`Jstar := Nat.floor (kg · t) ≤ kg`. Algebraic identity `y − xQ Jstar
= (t − Jstar/kg)(β' − α')` plus floor bounds give `|y − xQ Jstar| ≤
(β'−α')/kg ≤ 2(B+1)/kg`. Triangle inequality with `|x.val − y| ≤ 1/2^mm`
(from clamping) gives `|x.val − xQ Jstar| ≤ 1/2^mm + 2(B+1)/kg`. Apply
`polyEval_lipschitz_real`, then `h_combined_bound` closes the per-point
Lipschitz contribution at `2/2^K`.

**Degenerate (α' ≥ β')**: forces `β − α ≤ 2/2^mm`. Midpoint case-split on
`x.val ≤ (α+β)/2`:
- Yes: pick `J* := 0` (so `xQ 0 = α'`). `|x.val − α'| ≤ (β − α)/2 + 1/2^mm ≤
  1/2^mm + 1/2^mm = 2/2^mm` (uses `β − α ≤ 2/2^mm`).
- No: pick `J* := kg` (so `xQ kg = β'`). Symmetric: `|x.val − β'| ≤ 2/2^mm`.

Either subcase: `Lip · 2/2^mm = 2·(Lip · 1/2^mm) ≤ 2/2^K`.

### Combination

`abs_le.mpr` decomposes `|sNK − ‖p‖| ≤ 2/2^K` into two ≤'s:
- `−(2/2^K) ≤ sNK − ‖p‖` from `h_b2` (i.e., `‖p‖ ≤ sNK + 2/2^K`).
- `sNK − ‖p‖ ≤ 2/2^K` from `h_b1` (i.e., `sNK ≤ ‖p‖ + 1/2^K ≤ ‖p‖ + 2/2^K`).

### Set-option for heartbeats

The A3 theorem body is ~600 lines of single proof. Default 200k heartbeats
were exhausted by the cumulative whnf during elaboration. Added
`set_option maxHeartbeats 1600000 in` **before** the docstring (since
`set_option ... in` immediately after a docstring confuses the parser).

## Errors hit & fixes

1. **`le_or_lt` unknown** — Mathlib4 renamed to `le_or_gt`. Fix:
   `rcases le_or_gt α' β' with h | h`. Adopted as PITFALLS entry.
2. **`Finset.le_sup'_iff.mpr` unknown in term mode** — for some reason Lean
   refuses to resolve `Finset.le_sup'_iff.mpr` as a chained Iff projection in
   term-mode `:=` position. Worked around with `by rw [Finset.le_sup'_iff];
   exact ⟨...⟩`. *(Both h_sNK_nn and h_rEntry_Jstar_le_sup needed this fix.)*
3. **`set_option ... in` after a docstring** — parser sees the docstring as
   attached to `set_option` rather than to the theorem-after-`in`. Fix: move
   `set_option ... in` BEFORE the docstring.
4. **`(B + 1 : ℕ) : ℝ` vs `(B : ℝ) + 1`** — `polyEval_lipschitz_real` has
   `C : ℕ` so the bound is `|x| ≤ ((C : ℕ) : ℝ) = ↑(B + 1)`. Our local bound
   is `(B : ℝ) + 1`. These are equal but not syntactically defeq. Fix:
   `show |x| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_local_bound` and
   `push_cast at h_lip` to normalize the conclusion. *(Reusable idiom; add
   to LEAN-IDIOMS.)*
5. **`linarith` doesn't relate `1/2^mm` and `2/2^mm`** — these are separate
   opaque atoms to linarith. Need explicit hint:
   `have h_eq : (2 : ℝ) / 2^mm = 2 * (1 / 2 ^ mm) := by ring`. *(PITFALLS.)*
6. **`xQ 0` β-reduces to `α' + ((0:ℕ):ℝ)/kg · ...` not `α' + 0/kg · ...`**
   — Nat-cast of 0 doesn't auto-reduce to literal 0. Fix: `show α' +
   ((0 : ℕ) : ℝ) / (kg : ℝ) * (β' − α') = α'; rw [Nat.cast_zero]; ring`.
7. **`add_le_add_left h_β'mα'_kg_le` — silent failure**. Either signature
   confusion or Lean doesn't see the natural application. Workaround:
   `linarith [h_β'mα'_kg_le]`. *(LEAN-IDIOMS — when in doubt, use linarith.)*
8. **`field_simp` leaves trivial residual `y = α' + (y − α')`** — need
   `field_simp; ring` to close. *(LEAN-IDIOMS.)*
9. **`push_neg` deprecation warnings** (6 sites) — left as warnings; the new
   `push Not at h` syntax should work but the warning macro suggests the
   substitution is opt-in. Not worth touching mid-round.

## Build status

- `lake build` ✓ — 2532 jobs, NO errors, NO sorry-warnings.
- `#print axioms isComputableSeqCMap_norm` →
  `[propext, Classical.choice, Quot.sound]`.
- `#print axioms computabilityStructureCMap_of` →
  `[propext, Classical.choice, Quot.sound]`.
- Build time: ~73s (single-file incremental), ~165s after heartbeat bump.

## Criteria delta

- **C1, C2**: previously met (Prop 1 lemma).
- **C3**: previously met (A3 signature with `hα_c, hβ_c` + iter-09 addition of `hαβ`).
- **C4 met**: A3 body sorry-free, `#print axioms` clean. ✓
- **C5 unmet**: DA review on three-error decomposition pending.
- **C6 met (amended)**: instance takes six hypotheses (the iter-09 addition of
  `hαβ`); fully delegates to named lemma; `#print axioms` clean. ✓
- **C7 met**: repo-wide green; sorry-free. ✓
- **C8 unmet**: blueprint promotion.
- **C9 unmet**: NEXT-SESSION / PITFALLS / LEAN-IDIOMS updates.

## What's needed for iter-11

1. **C5**: invoke `/devils-advocate` on the three-error decomposition.
   Provide: `iter-10.md` (this file) + `CMap.lean` lines 2114-3017 + P-R
   chapt0:984-1012 verbatim. Challenge: are the three error sources
   (a) polynomial-approximation, (b) clamping, (c) cover individually
   tight enough? Is the midpoint case-split for `α' ≥ β'` the cleanest?
   Does the `Lip · 3/2^mm ≤ 2/2^K` bound need `mm = +4` instead of `+3`?
2. **C8**: blueprint promote `lem:l4_cmap_axiom3`:
   - Add `\lean{ComputableAnalysis.L4.isComputableSeqCMap_norm}` if not present.
   - Add `\leanok` on both statement and proof block.
   - Verify dep graph renders dark-green.
3. **C9**: docs:
   - `docs/NEXT-SESSION.md` — point at next obligation (Zulip outreach? L2?
     L5?). Match `feedback_round_pragmatism`.
   - `docs/PITFALLS.md` — entries for errors 1, 2, 5, 6 above.
   - `docs/LEAN-IDIOMS.md` — entries for errors 4, 7, 8 above.

## Iters budget

Used: 10 / 100. Remaining: 90. Closing criteria C5 + C8 + C9 estimated 2-3
more iters.

## Files changed this iter

- `ComputableAnalysis/L4/Instances/CMap.lean`:
  - Modulus tweak: m_mod +2→+3, k_grid 4→8 in factor.
  - h_b's complete analytic core (~360 lines): helpers, h_b1, h_b2, combine.
  - `set_option maxHeartbeats 1600000 in` before A3 docstring.
  - Stale "carries sorry" comment in `computabilityStructureCMap_of` docstring
    rewritten to reflect closure.
- `current-goal.md`: C4, C6, C7 checkboxes ticked.
- `.goals/INDEX.md`: iter count 9→10.

## Verification

- `lake build` ✓ (2532 jobs, no sorries).
- `#print axioms` ✓ (three kernel axioms only).
- Stop-hook write-scope respected: only allowed-list files touched.
