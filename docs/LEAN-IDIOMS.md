# Lean idioms that work — formalization playbook

> *Positive recipes harvested from completed rounds. Each entry: pattern name + iter-anchor (where it was learned the expensive way) → 1-sentence "when to use" trigger → minimal Lean snippet → source-line pointer in the repo. Paired companion: [PITFALLS.md](PITFALLS.md) — gotchas these idioms resolve.*

---

## 1. `convert ... using 1` for `Pi.add_apply` / `Pi.mul_apply` gaps

**When to use**: you have an `IsComputableSeqRat` (or any predicate on `ℕ → α`) on the function-level form `(f + g)` or `(f * g)` (output of `IsComputableSeqRat.add` / `.mul`), and need it on the pointwise form `fun p => f p + g p`. The two are defeq via `Pi.add_apply` / `Pi.mul_apply` but `exact` rejects them.

**Pattern**:
```lean
-- h_r_flat : IsComputableSeqRat ((fun p => αR ...) * (fun p => pad_X ...) +
--                                (fun p => βR ...) * (fun p => pad_Y ...))
have hr' : IsComputableDoubleSeqRat (fun pair : ℕ × ℕ =>
    αR (...) * pad_X (...) +
    βR (...) * pad_Y (...)) := by
  show IsComputableSeqRat _
  convert h_r_flat using 1
exact FinsetSumHelper.finsetSum_rat hr' hn'
```

**Why it works**: `convert ... using 1` walks the two terms one constructor deep, then checks defeq. `Pi.add_apply` and `Pi.mul_apply` are `rfl`, so the bridge closes silently.

**Source**: `ComputableAnalysis/L4/Instances/CMap.lean` near the closure of `IsComputableSeqRat (flatten aS)`. Learned in `l4-cmap-axiom-linearity-cont` iter-09 — saved ~50 lines of manual `funext` + `rfl`.

---

## 2. `show ...` to bridge `Computable.nat_rec`'s `(y, IH).2`-form IH

**When to use**: you're proving an induction goal involving `Nat.rec base step j`, the `step` came from `Computable.nat_rec`'s output, and Lean displays the step body as `(y, IH).2 * X` (or `(y, IH).2 + X` etc.) rather than the more natural `IH * X`. The IH (inductive hypothesis) and the goal have semantically-equal but syntactically-different forms — `rw [IH]` fails to find the pattern.

**Pattern**:
```lean
refine h_rec.of_eq fun j => ?_
show Nat.rec 1 (fun y IH => (y, IH).2 * B) j = B^j  -- force IH's form into goal
induction j with
| zero => rfl
| succ j IH =>
  show Nat.rec 1 (fun y IH' => (y, IH').2 * B) j * B = B^(j + 1)  -- force again at succ
  rw [IH, pow_succ]
```

**Why it works**: `show` accepts definitional equality. The step `fun y IH => (y, IH).2 * B` reduces to `fun y IH => IH * B`, but Lean keeps the surface form; `show` forces the goal text to match the IH text so `rw [IH]` succeeds.

**Source**: `ComputableAnalysis/L4/Instances/CMap.lean`, `h_Bpow` proof. Learned in `l4-cmap-axiom-linearity-cont` iter-11.

---

## 3. `@[reducible]` on `noncomputable def` producing a class type

**When to use**: you're shipping a parameterized constructor of a typeclass instance (a `def F (params) : SomeClass := ...`, not an `instance`), and Lean warns: `Definition ... of class type must be marked with @[reducible] or @[implicit_reducible]`. The warning is a real Mathlib-submission blocker — without `@[reducible]`, instance synthesis cannot unfold the def.

**Pattern**:
```lean
@[reducible] noncomputable def computabilityStructureCMap_of
    (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ)) :
    ComputabilityStructure ℝ (C(Set.Icc α β, ℝ)) where
  IsComputableSeq := IsComputableSeqCMap
  isComputableSeq_linearCombination := ...
  ...
```

**Why it works**: `@[reducible]` marks the def as transparent for typeclass search and `simp`. For parameterized instance constructors, this is the right annotation — the user constructs the instance by calling `computabilityStructureCMap_of B hα_le hβ_le` and downstream typeclass synthesis can unfold through that call.

**Source**: `ComputableAnalysis/L4/Instances/CMap.lean:439`. Learned in `l4-cmap-axiom-linearity-cont` iter-16 (DA fix #3).

---

## 4. Pass `Computable.nat_rec`'s step as an explicit `Computable₂`

**When to use**: you're invoking `Computable.nat_rec` and the step function is non-trivial (composes multiple `Computable` pieces over a pair input). `refine Computable.nat_rec hf hg ?_` triggers fragile higher-order unification and often fails with a metavariable error or type mismatch.

**Pattern**:
```lean
have h_step : Computable₂ (fun (k : ℕ) (yih : ℕ × σ) =>
    /* the step body */) := by
  show Computable (fun p : ℕ × (ℕ × σ) =>
    /* body in (k, (y, ih)) → ... form */)
  -- chain of Computable.fst / .snd / .pair / .comp / Primrec.<op>.to_comp
  ...
exact Computable.nat_rec hf hg h_step
```

**Why it works**: passing `h_step` explicitly avoids the unification metavariable on `h`'s type. Lean's HO unification can't always solve for `h` when the goal shape is partly polymorphic; an explicit `Computable₂` term resolves it.

**Sources** (4 occurrences, same pattern): `ComputableAnalysis/L4/Instances/CMap.lean`'s `finsetSum_rat`, `hd_S`, `bound_x_k`, `bound_max` proofs. Learned in `l4-cmap-axiom-linearity-cont` iters 03, 07, 11, 12.

---

## 5. Inner-witness extraction from `IsComputableSeqRat`

**When to use**: you need a Mathlib-`Computable` ℕ-upper-bound on `|r k|` (or any rational sequence value) and the `IsComputableSeqRat ↔ Computable ℚ` bridge isn't available (it's not in Mathlib at the time of writing). The L1 witness already contains exactly what you need — extract it.

**Pattern**:
```lean
obtain ⟨a, b, s, ha, hb, hs, hbne, heq⟩ := hflat_X
-- Now in scope:
--   a, b, s : ℕ → ℕ  (the witness functions)
--   ha, hb, hs : Computable
--   hbne : ∀ k, b k ≠ 0  →  since b : ℕ → ℕ, b k ≥ 1
--   heq : ∀ k, r k = (-1)^(s k) * (a k / b k)
-- So |r k| ≤ a k / b k ≤ a k (as reals).
-- a k as a Computable ℕ is the upper bound you want.

-- Re-introduce hflat_X for downstream consumers:
have hflat_X : IsComputableSeqRat (fun m => ...) :=
  ⟨a, b, s, ha, hb, hs, hbne, heq⟩
```

**Why it works**: `IsComputableSeqRat r` unfolds to `∃ a b s : ℕ → ℕ, Computable a ∧ Computable b ∧ Computable s ∧ (∀ k, b k ≠ 0) ∧ (∀ k, r k = (-1)^(s k) · (a k / b k))`. Since `b : ℕ` and `b k ≠ 0` ⟹ `b k ≥ 1`, real-comparison gives `|r k| ≤ a k`. The Computable ℕ-valued `a` IS the bound, no bridge required.

**Source**: `ComputableAnalysis/L4/Instances/CMap.lean` inner destructure block (4 destructures: `aX, aY, αR, βR`). Learned in `l4-cmap-axiom-linearity-cont` iter-10 — unlocked the entire bound machinery (`bound_x_k`, `bound_max`, the new M formula).

---

## 6. `Finset.sum` form > `Nat.rec` form when feeding `finsetSum_rat`

**When to use**: you've defined a witness via `Nat.rec base step N` (e.g., `aS := Nat.rec 0 (fun k acc => acc + summand_k) (d n + 1)`) but the next step is to apply a closure helper like `FinsetSumHelper.finsetSum_rat` which expects the `Σ k ∈ Finset.range (n + 1), r (·, k)` form.

**Pattern**:
```lean
-- BEFORE (Nat.rec form): hard to feed finsetSum_rat
let aS : ℕ × ℕ × ℕ → ℚ := fun nmj =>
  Nat.rec 0 (fun k acc => acc + summand_k(nmj, k)) (d nmj.1 + 1)

-- AFTER (Finset.sum form): direct application
let aS : ℕ × ℕ × ℕ → ℚ := fun nmj =>
  ∑ k ∈ Finset.range (d nmj.1 + 1), summand_k(nmj, k)
```

**Why it works**: mathematically equivalent (`Nat.rec 0 (· + g ·) n = Σ_{k < n} g k`). But the surface form matters for closure-helper application — `finsetSum_rat` pattern-matches on the `∑ ... ∈ Finset.range (... + 1)` shape. Choose the form that matches the next closure you'll apply.

**Source**: `ComputableAnalysis/L4/Instances/CMap.lean` `aS` redef. Learned in `l4-cmap-axiom-linearity-cont` iter-08 — switched `aS` from `Nat.rec` to `Finset.sum` to enable direct `finsetSum_rat` application in iter-09's IsComputableSeqRat proof.

---

## 7. Helper lemmas + `convert` collapse boilerplate; ship them EARLY

**When to use**: you've manually written a `Nat.unpair` / `Nat.pair` re-indexing chain once. Before writing the second occurrence, factor it out as a helper. The helper's body uses `convert ... using 1` + `simp [Function.comp, Nat.unpair_pair]` to close the function-composition / beta-reduction gap.

**Pattern** (an example helper):
```lean
theorem isComputableSeqRat_doubleApply
    {f : ℕ × ℕ → ℚ} (hf : IsComputableDoubleSeqRat f)
    {a b : ℕ → ℕ} (ha : Computable a) (hb : Computable b) :
    IsComputableSeqRat (fun p => f (a p, b p)) := by
  have h_σ : Computable (fun p => Nat.pair (a p) (b p)) :=
    Primrec₂.natPair.to_comp.comp ha hb
  have key : IsComputableSeqRat (fun p => f (Nat.unpair (Nat.pair (a p) (b p)))) :=
    hf.comp h_σ
  have heq : (fun p => f (Nat.unpair (Nat.pair (a p) (b p)))) = (fun p => f (a p, b p)) := by
    funext p; rw [Nat.unpair_pair]
  rwa [heq] at key
```

**Why it works**: ad-hoc `Nat.unpair_pair`-bridging chains repeat verbatim across closure proofs. A 12-line helper invoked 2–4 times saves 30–80 lines per use AND localizes the `convert` / `funext` / `simp` complexity to one place.

**Source**: `ComputableAnalysis/L4/Instances/CMap.lean` `FinsetSumHelper` namespace — `isComputableSeqRat_doubleApply` and `_tripleApply` were used in the 150-line `IsComputableSeqRat (flatten aS)` proof. Without them, that proof would have been ~230 lines. Learned in `l4-cmap-axiom-linearity-cont` iter-08 — the regret is that they were shipped AFTER the third manual repetition; iter-08 was retroactive.

**Rule of thumb**: if the same `Nat.unpair` / `Nat.pair` chain appears in your proof twice, write the helper before the third occurrence. The cost is ~15 lines + 1 conversion proof; the savings compound.

---

## Idiom: pushing a Nat-or-positional bound through a cast-mismatching lemma

When a Mathlib lemma takes a `ℕ`-valued parameter `C : ℕ` and the bound shape is `|x| ≤ ((C : ℕ) : ℝ)` but your in-scope hypothesis carries `(B : ℝ) + 1` instead of `((B + 1 : ℕ) : ℝ)`, the call fails with `type mismatch`. The two are equal but not syntactically defeq. Fix at the call site, not at the hypothesis site:

```lean
have h_lip := polyEval_lipschitz_real a d n K (B + 1) x.val (xQ Jstar)
  (show |x.val| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_x_abs_BP1)
  (show |xQ Jstar| ≤ ((B + 1 : ℕ) : ℝ) by push_cast; exact h_xQJstar_BP1)
push_cast at h_lip
```

The trick: the inline `show ((B + 1 : ℕ) : ℝ)` followed by `push_cast` rewrites the goal to `|x.val| ≤ (B : ℝ) + 1`, which matches the in-scope hypothesis. Then `push_cast at h_lip` normalizes the conclusion's `↑(B + 1) ^ (j-1)` back to `(↑B + 1) ^ (j-1)` so downstream consumers can use the bound. Without the trailing `push_cast at h_lip`, subsequent monotonicity steps (`mul_le_mul_of_nonneg_right h_Lip_real_le_nat`) fail with the symmetric mismatch.

**Source**: `l4-cmap-axiom3-norm-resig` iter-10 (multiple `polyEval_lipschitz_real` invocations in `h_b1` and `h_b2`).

---

## Idiom: `Finset.le_sup'_iff` via `rw` + `exact ⟨..., ..., ...⟩`

For sup' lower bounds `a ≤ s.sup' H f`, use the tactic form (not term mode):

```lean
have h_a_le_sup : a ≤ s.sup' H f := by
  rw [Finset.le_sup'_iff]
  exact ⟨b, hb_mem, h_a_le_f_b⟩
```

The term-mode `Finset.le_sup'_iff.mpr ⟨...⟩` fails with `Unknown constant` in some positions even though the lemma exists; the `rw + exact` form always works.

**Source**: `l4-cmap-axiom3-norm-resig` iter-10 (`h_sNK_nn` and `h_rEntry_Jstar_le_sup`).

---

## Idiom: heartbeat-heavy theorems

For theorems with proof bodies > ~400 lines, default 200k heartbeats are exhausted by cumulative whnf during elaboration. Bump locally via `set_option ... in`, but position it correctly — `set_option ... in` must come *before* any docstring on the theorem:

```lean
set_option maxHeartbeats 1600000 in
/-- Docstring for the theorem. -/
theorem foo : ... := by ...
```

NOT after the docstring (parser error). The `in` makes the whole `theorem foo` declaration carry the heartbeat bump.

**Source**: `l4-cmap-axiom3-norm-resig` iter-10 (A3 body ~600 lines).

---

## Idiom: midpoint case-split for tightening degenerate bounds

When a proof's degenerate case threatens to violate the modulus tolerance (e.g., `3/2^mm` exceeds `2/2^K`), case-split on whether the variable lies on the left or right half of an interval:

```lean
by_cases h_x_mid : x.val ≤ (α + β) / 2
· -- left half: pick J* := 0, |x.val - xQ 0| = |x.val - α'| ≤ 2/2^mm.
  refine ⟨0, by omega, ?_⟩
  ...
· push_neg at h_x_mid  -- right half
  -- pick J* := kg, |x.val - xQ kg| = |x.val - β'| ≤ 2/2^mm.
  refine ⟨kg, le_refl _, ?_⟩
  ...
```

This converts a worst-case `3/2^mm` bound (when the variable could be anywhere) to a worst-case `2/2^mm` bound (in each half). Avoids needing a tighter Lipschitz lemma.

**Source**: `l4-cmap-axiom3-norm-resig` iter-10 (`h_b2` degenerate case `α' ≥ β'`).

---

## Idiom: `Set.projIcc` for clamping with a `hαβ` proof

When you need to clamp `x : ℝ` to `[α, β]` and have `hαβ : α ≤ β`, use `Set.projIcc α β hαβ x : Set.Icc α β`. The `.val` projection gives `max α (min β x)`. Three-case bound:

```lean
have h_clamp : |x - (Set.projIcc α β hαβ x).val| ≤ ε := by
  by_cases h1 : x < α
  · have h_eq : (Set.projIcc α β hαβ x).val = α := by
      rw [Set.coe_projIcc, max_eq_left]
      calc min β x ≤ x := min_le_right _ _
        _ ≤ α := h1.le
    rw [h_eq, abs_of_neg (by linarith)]; <bound>
  · push_neg at h1
    by_cases h2 : β < x
    · have h_eq : (Set.projIcc α β hαβ x).val = β := by
        rw [Set.coe_projIcc, min_eq_left h2.le, max_eq_right hαβ]
      rw [h_eq, abs_of_pos (by linarith)]; <bound>
    · push_neg at h2
      have h_eq : (Set.projIcc α β hαβ x).val = x := by
        rw [Set.coe_projIcc, min_eq_right h2, max_eq_right h1]
      rw [h_eq, sub_self, abs_zero]; <nonneg>
```

The structure is reusable any time you need to project to a closed interval with explicit bounds derived from the side of the projection.

**Source**: `l4-cmap-axiom3-norm-resig` iter-10 (`h_clamp_close` in A3 body).

---

## Idiom: `Nat.floor` rounding for grid covers

To cover `t ∈ [0, 1]` with `kg + 1` grid points and bound the rounding error:

```lean
set Jstar : ℕ := Nat.floor ((kg : ℝ) * t) with hJstar_def
have h_Jstar_R_le : (Jstar : ℝ) ≤ (kg : ℝ) * t := Nat.floor_le h_kg_t_nn
have h_Jstar_lt : (kg : ℝ) * t < (Jstar : ℝ) + 1 := Nat.lt_floor_add_one _
have h_Jstar_le_kg : Jstar ≤ kg := by
  have h_kgt_le_kg : (kg : ℝ) * t ≤ (kg : ℝ) := by
    have := mul_le_mul_of_nonneg_left h_t_le_one h_kg_real_pos.le
    linarith
  exact_mod_cast h_Jstar_R_le.trans h_kgt_le_kg
have h_diff_le : t - (Jstar : ℝ) / (kg : ℝ) ≤ 1 / (kg : ℝ) := by
  rw [sub_le_iff_le_add,
      show (1 : ℝ) / (kg : ℝ) + (Jstar : ℝ) / (kg : ℝ)
        = ((Jstar : ℝ) + 1) / (kg : ℝ) from by ring,
      le_div_iff₀ h_kg_real_pos]
  linarith
```

The result: `Jstar/kg ≤ t < (Jstar + 1)/kg`, so `|t - Jstar/kg| ≤ 1/kg`.

**Source**: `l4-cmap-axiom3-norm-resig` iter-10 (`h_b2` non-degenerate floor-cover).

---

## Cross-reference

For each idiom, the symmetric pitfall it resolves is documented in [PITFALLS.md](PITFALLS.md). When debugging a proof error, search PITFALLS first; when planning a new proof, search this file first.
