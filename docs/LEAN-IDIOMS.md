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
  axiom_linearity := ...
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

## Cross-reference

For each idiom, the symmetric pitfall it resolves is documented in [PITFALLS.md](PITFALLS.md). When debugging a proof error, search PITFALLS first; when planning a new proof, search this file first.
