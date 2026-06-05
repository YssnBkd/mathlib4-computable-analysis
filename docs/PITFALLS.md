# Pitfalls hit + workarounds — formalization gotchas log

> *Negative-framing companion to [LEAN-IDIOMS.md](LEAN-IDIOMS.md). Each entry: pitfall description → workaround → iter-anchor where it bit us. Search this file first when debugging a confusing error; search LEAN-IDIOMS first when planning a new proof.*

---

## 1. `Primrec.nat_pow` doesn't exist in Mathlib

**Pitfall**: assuming `Primrec.nat_pow : Primrec₂ Nat.pow` (or `Primrec.nat_pow B : Primrec (fun j => B^j)`) is available. It isn't, in Mathlib's `Computability/Primrec/` at the time of writing.

**Workaround**: define `B^j` Computable inline via `Computable.nat_rec`:
```lean
have h_Bpow : Computable (fun j : ℕ => B^j) := by
  have hh : Computable₂ (fun (_ : ℕ) (yih : ℕ × ℕ) => yih.2 * B) := by
    show Computable (fun p : ℕ × (ℕ × ℕ) => p.2.2 * B)
    exact Primrec.nat_mul.to_comp.comp (Computable.snd.comp Computable.snd)
      (Computable.const B)
  refine (Computable.nat_rec Computable.id (Computable.const (1 : ℕ)) hh).of_eq fun j => ?_
  show Nat.rec 1 (fun y IH => (y, IH).2 * B) j = B^j
  induction j with
  | zero => rfl
  | succ j IH =>
    show Nat.rec 1 (fun y IH' => (y, IH').2 * B) j * B = B^(j + 1)
    rw [IH, pow_succ]
```

**General rule**: see `feedback_grep_before_assuming` in auto-memory. Grep `.lake/packages/mathlib/Mathlib/<area>/` BEFORE relying on any unverified symbol. If it's missing, define inline via `Computable.nat_rec` or `Primrec.nat_rec`.

**Hit at**: `l4-cmap-axiom-linearity-cont` iter-11.

---

## 2. The `IsComputableSeqRat ↔ Computable ℚ` bridge is not shipped

**Pitfall**: assuming `IsComputableSeqRat r` is equivalent to `Computable (r : ℕ → ℚ)` (via Primcodable ℚ). It *would* be, but the bridge theorems aren't in this project's L1 yet — neither direction is exported.

**Workaround**: sidestep via inner-witness extraction (see `LEAN-IDIOMS.md` §5). From `IsComputableSeqRat r` get `a, b, s : ℕ → ℕ` Computable, then `|r k| ≤ a k` as a real (since `b k ≥ 1`). The Computable ℕ-valued `a` IS the bound you want, with no bridge needed.

**Don't try to build the bridge in-round** — it's a multi-iter L1 effort and conflicts with most round `forbid_writes`. Defer to a dedicated L1 round.

**Hit at**: `l4-cmap-axiom-linearity-cont` iter-02 strategy doc (flagged as `Primrec₂.rat_add` wall) and iter-10 (resolved via inner-witness extraction).

---

## 3. `Computable.id` makes `Computable.nat_rec` inductions ugly

**Pitfall**: passing `Computable.id` as the `f` parameter of `Computable.nat_rec` causes Lean's goal display to show `id j` instead of `j` and the step function to render as `(y, IH).2 * X` instead of `IH * X`. `rw [IH]` then fails because the surface form doesn't match.

**Workaround**: use `show ...` to force the goal into the IH's form (see `LEAN-IDIOMS.md` §2). Or, if your input is naturally extracted via something else (`.fst.comp Computable.snd`, etc.), use that instead of `.id`.

**Hit at**: `l4-cmap-axiom-linearity-cont` iter-11 (`h_Bpow` proof — the `id j` surfaces in the `.of_eq` goal).

---

## 4. `obtain ⟨...⟩ := hflat_X` consumes `hflat_X`

**Pitfall**: destructuring `IsComputableSeqRat` to access the inner `(a, b, s)` witness functions consumes the original hypothesis. Downstream proofs that referenced `hflat_X` (or `hflat_αR` etc.) by name break.

**Workaround**: immediately re-introduce the original hypothesis from the destructured parts:
```lean
obtain ⟨aX_a, aX_b, aX_s, h_aX_a, h_aX_b, h_aX_s, h_aX_bne, h_aX_eq⟩ := hflat_X
have hflat_X : IsComputableSeqRat (fun m => ...) :=
  ⟨aX_a, aX_b, aX_s, h_aX_a, h_aX_b, h_aX_s, h_aX_bne, h_aX_eq⟩
```

The `have` shadows the original (consumed) `hflat_X` with an identical-typed reconstruction. Subsequent `isComputableSeqRat_doubleApply hflat_X ...` calls continue working.

**Hit at**: `l4-cmap-axiom-linearity-cont` iter-10 — when inner destructures were added, the iter-09 IsComputableSeqRat proof initially broke because it used `hflat_X` as an opaque `IsComputableSeqRat` hypothesis. The re-introduction restored compatibility.

---

## 5. `claims/INDEX.md` is NOT in `allow_writes` for round-scoped goals

**Pitfall**: when shipping a new claim file under `claims/<slug>/`, the natural impulse is to also add a section to `claims/INDEX.md`. But round-scoped `allow_writes` typically lists `claims/<slug>/**` (the specific subdir), NOT `claims/INDEX.md` (the registry).

**Workaround**: the Stop hook will catch this with `HALT (out-of-scope write)`. To avoid: before editing `claims/INDEX.md` (or `.goals/INDEX.md`, top-level `README.md`, `CLAUDE.md`, anything in `.github/`), grep `current-goal.md` for the path. If absent from `allow_writes`, either (a) defer the INDEX update to a follow-up `*-cleanup` round, or (b) propose extending allow_writes to the user before editing.

**General rule**: see `feedback_allow_writes_scope_check` in auto-memory.

**Hit at**: `l4-cmap-axiom-linearity-cont` iter-13 — cost one wasted iter + a revert before iter-14 continued.

---

## 6. Citation discipline — verify `<bibkey>:<line>` references

**Pitfall**: writing a citation like `P-R Ch. 2:148 ("for recursive reals a, b")` from memory. Line numbers in `literature/papers/<key>.md` shift across edits; the cited phrase may NOT be at the cited line; mid-paragraph quotes are particularly error-prone.

**Workaround**: for every `<bibkey>:<line>` (or `<file>:<line>`) citation you write, immediately before writing, read the source at that line and verify the quoted phrase appears verbatim:
```bash
# Or via Read with offset/limit:
sed -n '<LINE>p' literature/papers/<key>.md
```

**Cost of skipping**: in `l4-cmap-axiom-linearity-cont`, the citation `Ch. 2:148` for "for recursive reals a, b" was wrong (actual line: `:128`). The typo propagated to 4 files — `ComputableAnalysis/L4/Instances/CMap.lean:427`, `claims/l4-cmap-axiom-linearity/axiom_linearity.md:52, 121`, `blueprint/src/L4.tex:14` — before the devil's-advocate review caught it at iter-15. Fix required 4 edits + an over-claim softening + a round-end note.

**General rule**: see `feedback_grep_before_assuming` in auto-memory (same rule, citation flavor).

**Hit at**: `l4-cmap-axiom-linearity-cont` iter-04 (introduced) → iter-15 (caught by DA).

---

## 7. `#print axioms (inst).someField` falsely reports `sorryAx` from sibling fields

**Pitfall**: to audit that ONE field of a multi-field `instance`/`structure` is genuinely sorry-free, the natural move is `#print axioms (computabilityStructureCMap_of ..).isComputableSeq_linearCombination`. This reports `sorryAx` whenever ANY *sibling* field (e.g. `isComputableSeq_of_effectiveLimit`, `isComputableSeqReal_norm`) still has a `sorry` — regardless of the inspected field's own purity. The projection drags in the whole structure's axiom set, so it cannot isolate one field. **False positive** — and equally a false *negative* risk if you ever read the absence of `sorryAx` on a projection as proof a sibling is clean.

**Workaround**: extract the field's proof body verbatim into a standalone theorem whose type is the field type, with NO sibling fields in scope, then audit that:
```lean
theorem isComputableSeq_linearCombination_isolated : <the field's type> := by
  <paste the field body verbatim>
#print axioms isComputableSeq_linearCombination_isolated   -- reflects ONLY this proof
```
If it compiles clean and prints `[propext, Classical.choice, Quot.sound]` (no `sorryAx`, no `nativeDecide`, no `Lean.ofReduceBool`), the field is genuinely sound; any instance-level `sorryAx` is then provably attributable to the other (out-of-scope) fields.

**Control that proves the artifact**: a hand-built structure with `isComputableSeq_linearCombination := trivial` (provably pure) but `sorry` in two siblings STILL prints `sorryAx` on the projected `.isComputableSeq_linearCombination`. So projection is unsound for field-level audits even when the conclusion happens to be right.

**Hit at**: `l4-cmap-axiom-linearity-bound` — the first-pass C2 review used field projection and reached the right verdict by luck; the post-compaction re-run caught the flawed method and replaced it with standalone extraction.

---

## 8. Devil's-advocate verdict token must be exactly `verdict: passes`

**Pitfall**: writing the DA verdict as prose — `## VERDICT: **sound**`, `Verdict: looks good`, or even `verdict: passes-partial`. The `/goal` Stop hook (`scripts/goal_stop_hook.py:257`) greps each review with the anchored regex `^verdict:\s*passes\s*$` (case-insensitive, MULTILINE). Anything that isn't a bare `verdict: passes` line fails to match, so marking the criterion `[x]` trips `HALT (unauthorized check)` — even though a human reading the review sees a clear pass. Note `passes-partial` also fails the `$`-anchor; only bare `passes` clears the gate.

**Workaround**: the DA vocabulary is a fixed three-token enum — `passes | unsound | unsupported` (`.claude/agents/devils-advocate.md:38,69`). "sound" is NOT a token. Every review for a `devils_advocate_required_for` criterion must contain a line that is exactly `verdict: passes` (own line, lowercase, no markdown decorations; a frontmatter `verdict: passes` works too, since the regex is MULTILINE).

**Do NOT fix it by hand-editing the token** — that bypasses the very gate the criterion exists to enforce (the moral equivalent of `--no-verify`). If a review has the wrong token, re-run `/devils-advocate <id>` for a genuine fresh verdict (it may also surface real issues — here it caught the §7 projection-artifact flaw). Treat the Stop hook as part of the definition of done: before reporting a round complete, grep `^verdict:\s*passes` on every DA-required review yourself.

**Hit at**: `l4-cmap-axiom-linearity-bound` (post-compaction) — a prose `## VERDICT: **sound**` review HALTed the round at completion; resolved by re-running the DA gate, which returned canonical `verdict: passes`.

---

## 9. Order-lemma naming drift: `div_le_div_iff` renamed, `Max.max_eq_left` doesn't exist

**Pitfall**: two systematic Mathlib-naming-drift issues bite at once when formalizing rational-fraction `max`/`min` closure under `IsComputableSeqRat`:

1. **`div_le_div_iff` is no longer a valid identifier.** Lemmas attempting to compare cross-products via `a/b ≤ c/d ↔ a·d ≤ c·b` fail with `Unknown identifier 'div_le_div_iff'`. The current canonical name is **`div_le_div_iff₀`** at `.lake/packages/mathlib/Mathlib/Algebra/Order/GroupWithZero/Unbundled/Basic.lean:1419` — signature `div_le_div_iff₀ (hb : 0 < b) (hd : 0 < d) : a / b ≤ c / d ↔ a * d ≤ c * b`. Note the trailing `₀` (subscript zero, not letter o). Adjacent siblings exist but with different shapes — `div_le_div_iff_of_pos_left` (one numerator fixed), `div_le_div_iff_right` (one denominator fixed), `div_le_div_iff'` (group form, `LinearOrderedSemifield`). The `₀` variant is the one for the cross-product rewrite.

2. **`Max.max_eq_left`, `Max.max_eq_right`, `Min.min_eq_left`, `Min.min_eq_right` do NOT exist as qualified names.** The qualification looks plausible because `Max` and `Min` are real typeclasses in Mathlib, but the order-collapse lemmas live at the root namespace — use **unqualified** `max_eq_left : b ≤ a → max a b = a`, `max_eq_right : a ≤ b → max a b = b`, `min_eq_left : a ≤ b → min a b = a`, `min_eq_right : b ≤ a → min a b = b`. The dot-notation `h.max_eq_left` also won't fire because `h : b ≤ a` is not a `Max`-namespace declaration.

**Workaround**: when proving rational-order closures, write the cross-product comparison as
```lean
have hr1le : (a₁ k : ℚ) / (b₁ k : ℚ) ≤ (a₂ k : ℚ) / (b₂ k : ℚ) := by
  rw [div_le_div_iff₀ hb₁ℚ hb₂ℚ]
  exact_mod_cast hle_case
rw [max_eq_right (by linarith)]   -- NOT Max.max_eq_right
```
and then close the goal-shape via `by linarith` after `(-1)^(0:ℕ) = 1` / `(-1)^(1:ℕ) = -1` collapse via `simp`.

**General rule**: see `feedback_grep_before_assuming` in auto-memory. Before writing an order-lemma rewrite, grep `.lake/packages/mathlib/Mathlib/Order/MinMax.lean` and `.lake/packages/mathlib/Mathlib/Algebra/Order/` for the exact identifier. The 5-second grep prevents a multi-iter cleanup round.

**Hit at**: `l1-max-abs-closure` iter-02 (the original drafts of `.max` and `.min` collapsed under 5×`div_le_div_iff` failures and 4×`Max.max_eq_left`/`Min.min_eq_right` failures; reverted at round end). Resolved at `l1-max-min-rebuild` (this round) by the `div_le_div_iff₀` substitution and dropping the `Max.`/`Min.` qualification.

---

## Cross-reference

For the positive recipe that resolves each pitfall, see [LEAN-IDIOMS.md](LEAN-IDIOMS.md). Pitfalls #1, #3, #4 map to LEAN-IDIOMS §1–5; pitfall #2 maps to LEAN-IDIOMS §5; pitfalls #5 and #6 are procedural, resolved via the auto-memory `feedback_*` entries. Pitfall #7 is a Lean soundness-audit gotcha (no LEAN-IDIOMS counterpart yet); pitfall #8 is procedural — the `/goal` Stop-hook contract (`scripts/goal_stop_hook.py:257`, `.claude/agents/devils-advocate.md:38,69`). Pitfall #9 is a Mathlib naming-drift gotcha — same family as #1, but for order lemmas rather than `Primrec`/`Computable` primitives. Pitfalls #10–#14 are A3-round-specific naming drifts and elaboration-order gotchas.

---

## 10. Order-lemma drift: `le_or_lt` is now `le_or_gt`

**Pitfall**: `le_or_lt α' β'` errors with `Unknown identifier`. Renamed in Mathlib4 to `le_or_gt : a ≤ b ∨ b < a` (`.lake/packages/mathlib/Mathlib/Order/Defs/LinearOrder.lean:100`). The dual `lt_or_ge : a < b ∨ b ≤ a` is at line 97.

**Workaround**: `rcases le_or_gt α' β' with h | h`.

**Hit at**: `l4-cmap-axiom3-norm-resig` iter-10 (`h_min_αβ'`, `h_max_αβ'` in A3 body).

---

## 11. `Finset.le_sup'_iff.mpr` fails in term mode but works in tactic mode

**Pitfall**: `have h : a ≤ s.sup' H f := Finset.le_sup'_iff.mpr ⟨b, hb_mem, h_le_f⟩` errors with `Unknown constant Finset.le_sup'_iff.mpr` — even though `Finset.le_sup'_iff` exists at `.lake/packages/mathlib/Mathlib/Data/Finset/Lattice/Fold.lean:732` and is widely used elsewhere. The same lemma applied via `rw` in tactic mode works.

**Workaround**: always use the tactic form for sup' lower-bound proofs:
```lean
have h : a ≤ s.sup' H f := by
  rw [Finset.le_sup'_iff]
  exact ⟨b, hb_mem, h_le_f⟩
```

**Hit at**: `l4-cmap-axiom3-norm-resig` iter-10 (`h_sNK_nn` and `h_rEntry_Jstar_le_sup` in A3 body).

---

## 12. `set_option ... in` immediately after a docstring confuses the parser

**Pitfall**:
```lean
/-- Docstring ... -/
set_option maxHeartbeats 1600000 in
theorem foo : ... := by ...
```
errors with `unexpected token 'set_option'; expected 'lemma'`. The parser treats the docstring as belonging to the *next* declaration, but `set_option ... in` is itself a directive, not a decl — so Lean expects `theorem`/`lemma`/`def` right after the docstring.

**Workaround**: move `set_option ... in` BEFORE the docstring:
```lean
set_option maxHeartbeats 1600000 in
/-- Docstring ... -/
theorem foo : ... := by ...
```

**Hit at**: `l4-cmap-axiom3-norm-resig` iter-10 (A3 theorem required heartbeats bump for the ~600-line proof body).

---

## 13. `linarith` doesn't relate `c/2^N` and `1/2^N` as algebraic atoms

**Pitfall**: `linarith` treats each fraction with `2^N`-denominator as an opaque atom. From `β - α ≤ 2 / 2^mm`, it cannot derive `(β - α)/2 ≤ 1 / 2^mm` because `1 / 2^mm` and `2 / 2^mm` are distinct atoms — `linarith` doesn't auto-recognize `2 / X = 2 · (1 / X)`.

**Workaround**: provide the algebraic identity as an explicit hypothesis:
```lean
have h_eq : (2 : ℝ) / 2^mm = 2 * (1 / 2^mm) := by ring
linarith [h_β_minus_α, h_eq]
```

**Hit at**: `l4-cmap-axiom3-norm-resig` iter-10 (degenerate-case midpoint argument in `h_b2`).

---

## 14. `xQ 0` β-reduces to `α' + ((0 : ℕ) : ℝ) / kg · ...` — `Nat.cast 0` doesn't auto-reduce

**Pitfall**: writing `show α' + 0 / kg * (β' − α') = α'` after a `set xQ : ℕ → ℝ := fun J => ...` and querying at `xQ 0` errors with `not definitionally equal`. Lean's β-reduction of `xQ J` at `J := (0 : ℕ)` produces `α' + ((0 : ℕ) : ℝ) / kg * ...` — and `((0 : ℕ) : ℝ)` is `Nat.cast 0`, which doesn't reduce to `(0 : ℝ)` by defeq.

**Workaround**: match the actual β-reduced form in `show`, then explicit cast normalization:
```lean
have h_xQ_0 : xQ 0 = α' := by
  show α' + ((0 : ℕ) : ℝ) / (kg : ℝ) * (β' - α') = α'
  rw [Nat.cast_zero]; ring
```

**Hit at**: `l4-cmap-axiom3-norm-resig` iter-10 (`h_xQ_0_eq` in degenerate-case A3 body).
