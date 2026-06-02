# Prompt for next session

> *Paste this prompt as the opening message in the next conversation. It is self-contained — you do not need to re-read prior transcripts.*

---

You are continuing work on the **mathlib-computable-analysis** project: a Lean 4 / Mathlib4 formalization of Pour-El & Richards-style computable analysis, intended for upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. Read `CLAUDE.md` first — it is the project constitution (~210 lines, lean-first, do NOT roll back to paper-first).

## TL;DR

1. `lake build` — should produce **0 errors, 1 sorry-warning** at `ComputableAnalysis/L4/Instances/CMap.lean:261:23` (the L4 `C[α,β]` instance grouping A1/A2/A3 theorem-body sorries).
2. **A real new artifact landed last round**: `private theorem isComputableSeqRat_add` in `ComputableAnalysis/L4/Instances/CMap.lean` (~80 lines, fully proved). Closure of L1's `IsComputableSeqRat` under pointwise addition, marked `TODO(refactor → L1):` for a future architectural move.
3. **L4 A1 (`axiom_linearity`) still has a `sorry` body.** Prior round (`l4-cmap-axiom-linearity`, 2026-06-02) closed `budget-exhausted` (5/6 iters, ~198 min vs 120 budget); shipped `_add` but not the three additional closure helpers + witness assembly needed for A1.
4. **Recommended next direction**: pivot to L1 — lift `_add` to its proper home, ship `_mul`/`_reindex`/`_finsetSum`, define `IsComputableReal`. Closure-first round before resuming L4 axiom proofs.

## Context — what happened in the prior session (`l4-cmap-axiom-linearity`, 2026-06-02)

This was a `proof-attempt` `/goal` round. Mode `proof-attempt`, budget 6 iters / 120 min. Full report at `.goals/l4-cmap-axiom-linearity/final.md`.

Trajectory:

- **iter-02 (orient)**: Confirmed C1 (build green). Discovered the central finding: L1's `IsComputableSeqRat` lacks arithmetic closure (intentionally deferred per `ComputableSeqReal.lean:56-64`), and A1 under the polynomial form (P-R Ch. 2:141) genuinely needs these closures. NEXT-SESSION.md's prior "no new L1 lemmas needed" was wrong.
- **iter-03 (strategy)**: Mathlib reconnaissance — `Primcodable ℤ/ℚ` automatic via Denumerable, `Primrec.nat_add/sub/mul/le` exist, `Primrec.ite/cond` exist, but **no direct `Primrec₂` for ℤ-arithmetic or ℚ-arithmetic**. Drafted full paper-form A1 proof with verbatim P-R citations.
- **iter-04 (Lean draft)**: Wrote `isComputableSeqRat_add` skeleton in `thinking/` not committed to CMap.lean, with concrete idiom hints and 4-case dispatch.
- **iter-05 (breakthrough)**: Ported the draft to `CMap.lean` and proved it completely. Build clean.
- **iter-06 (didn't happen)**: budget exhausted.

What changed on disk:

- **`ComputableAnalysis/L4/Instances/CMap.lean`**: added private theorem `isComputableSeqRat_add` (~80 lines) at the top of the file, between the namespace open and `section CMap`. Has a "## L1 closure helpers" section header docstring explaining the temporary L4 location.
- **CLAUDE.md** L4 CMap row annotation updated to note `_add` landed.
- **`.goals/l4-cmap-axiom-linearity/`**: full round artifacts including `final.md`.
- **`thinking/l4-cmap-axiom-linearity/`**: iter-02 orientation, iter-03 strategy with full paper-form A1 proof + verbatim citations, iter-04 Lean draft (now subsumed by the actual code).

## Your task this session

### Action 1 — verify the build (first command)

```bash
lake build 2>&1 | tail -10
```

Expected: 0 errors, **exactly 1 sorry-warning** (`ComputableAnalysis/L4/Instances/CMap.lean:261:23` for the L4 instance). If you see anything else, see `docs/SETUP.md`.

### Action 2 — recommended direction: L1 closure-first

**Why this and not "resume A1 directly"**: A1 under polynomial form needs three more closure helpers (`_mul`, `_reindex`, `_finsetSum`) plus ~50 lines of witness assembly. The prior round shipped one helper in 5 iters. Continuing in L4 with the `_add` helper now living inline in `CMap.lean` adds technical debt (it belongs in L1). Better path: open a round dedicated to L1 closures (proper home), then resume L4 A1 with the toolkit ready.

Suggested round setup:

- **Slug**: `l1-arithmetic-closure-and-real`
- **Mode**: `proof-attempt`
- **Budget**: 12 iters / 180 min (3× the prior round's budget, calibrated to the discovered cost)
- **Allow_writes**: `ComputableAnalysis/L1/**`, `ComputableAnalysis/L4/Instances/CMap.lean` (to lift `_add` and remove its TODO comment), `CLAUDE.md`, `claims/l1-arithmetic-closure-and-real/**`, `.goals/l1-arithmetic-closure-and-real/**`, `.goals/INDEX.md`, `thinking/l1-arithmetic-closure-and-real/**`.
- **Forbid_writes**: `ComputableAnalysis/L0/**`, `ComputableAnalysis/L3/**`, `ComputableAnalysis.lean`, `literature/papers/**/verbatim.md`.
- **Criteria sketch**:
  - C1: `lake build` green; the L4 instance sorry-warning is the only residual.
  - C2: `isComputableSeqRat_add` lifted from `L4/Instances/CMap.lean` to `L1/ComputableSeqReal.lean` (or a new `L1/RatClosure.lean`) under its proper public name; CMap.lean references the L1 version.
  - C3: `isComputableSeqRat_mul` shipped (fully proved). The simpler sibling of `_add` — sign XOR, no truncated-subtraction bookkeeping.
  - C4: At least one of `isComputableSeqRat_reindex` or `isComputableSeqRat_finsetSum` shipped (whichever lands first).
  - C5: `IsComputableReal : ℝ → Prop` defined in `ComputableAnalysis/L1/ComputableReal.lean` (~1-line definition + 1-2 sanity lemmas, P-R Ch. 0:55 citation in docstring).
  - C6: CLAUDE.md L1 tracker rows updated.

### Action 3 — alternative directions

If the user has different priorities:

- **Just define `IsComputableReal`** (narrow, low-stakes): NEXT-SESSION.md's original Direction B at the previous session, now still applicable but doesn't unblock L4. Slug `l1-is-computable-real`, mode `explore`, 6 iters / 90 min.
- **Resume L4 A1 directly** (stack-deeper, risk of repeating the budget overrun): slug `l4-cmap-axiom-linearity-cont`, mode `proof-attempt`, 6 iters / 180 min. Keep `_add` inline (or lift it first), then ship `_mul`/`_reindex`/`_finsetSum` + A1 witness assembly. Same allow_writes as the prior round PLUS L1.
- **Post the deferred Zulip pitches** (human-in-loop): the L0 + L3 pitches at `docs/zulip-drafts/2026-06-01-l0-pitch.md` + `docs/zulip-drafts/2026-06-01-l3-pitch.md` are still drafted, still deferred. Decision recipe at `docs/zulip-drafts/2026-06-01b-decision.md`. ~30 min.

## Critical knowledge — Mathlib symbols verified this session

Augmentations to the prior tables; all entries verified against Mathlib master 2026-06-02.

| Concept | Exact symbol | Import / location | Note |
|---|---|---|---|
| `Primrec₂.nat_add/sub/mul/le` | `Primrec.nat_add` etc. | `Mathlib/Computability/Primrec/Basic.lean:593,596,599,610` | The ℕ-level arithmetic building blocks. `nat_sub` is **truncated** (0 if negative). |
| `Primrec.nat_mod / nat_bodd` | both | `Mathlib/Computability/Primrec/Basic.lean:728,733` | Use `nat_bodd` (Bool-valued: odd? true : false) over `% 2` when the result needs to be Computable. |
| `Primrec.ite / .cond` | both | `Mathlib/Computability/Primrec/Basic.lean:602,606` | `.cond` is Bool-conditional; `.ite` is Prop-conditional with `[DecidablePred c]`. |
| `Computable.cond` (Bool conditional on Computable) | yes | `Mathlib/Computability/Partrec.lean:594` | `cond hc hf hg : Computable (fun a => bif (c a) then (f a) else (g a))`. |
| `Computable₂.comp` | yes | `Mathlib/Computability/Partrec.lean:477` | `(hf : Computable₂ f).comp (hg : Computable g) (hh : Computable h) : Computable (fun a => f (g a) (h a))`. **Critical**: takes two separate args, NOT a paired one. |
| `Primrec₂.to_comp` | yes | `Mathlib/Computability/Partrec.lean:252` | Lifts Primrec₂ to Computable₂. Use as `Primrec.nat_mul.to_comp.comp hb₁ hb₂`. |
| `PrimrecRel.decide` | yes | `Mathlib/Computability/Primrec/Basic.lean:426` | Converts a `PrimrecRel R` (like `nat_le`) to `Primrec₂ (fun a b => decide (R a b))`. Use `.swap.decide` to flip arg order. |
| `Primcodable ℤ/ℚ` (via `Denumerable`) | auto | `Mathlib/Computability/Primrec/Basic.lean:139` priority-10 | `instDenumerableInt` at `Mathlib/Logic/Denumerable.lean:158`; `instDenumerableRat` at `Mathlib/Data/Rat/Denumerable.lean:30`. **BUT** no Mathlib-exported `Primrec₂` for ℤ-arithmetic or ℚ-arithmetic — those have to be built. |

## Critical knowledge — Lean 4 / Mathlib idioms that worked

These patterns worked cleanly in `isComputableSeqRat_add`; copy them for the upcoming `_mul`/`_reindex`/`_finsetSum`:

### Computable composition pattern

```lean
have hp₁ : Computable (fun k => a₁ k * b₂ k) :=
  Primrec.nat_mul.to_comp.comp ha₁ hb₂
```

`Primrec.nat_mul` is `Primrec₂`. `.to_comp` lifts to `Computable₂`. `Computable₂.comp ha₁ hb₂` takes **two separate** `Computable` args. **NOT** `(ha₁.pair hb₂)`.

### Computable conditional pattern

For a function `fun k => if (Prop predicate on k) then X else Y`:

```lean
have hge : Computable (fun k => decide (a₁ k * b₂ k ≥ a₂ k * b₁ k)) := by
  have : Primrec₂ (fun p q : ℕ => decide (p ≥ q)) := Primrec.nat_le.swap.decide
  exact this.to_comp.comp hp₁ hp₂
have htotal := Computable.cond hge hX hY
-- htotal is in `cond` form. Now convert to `ite` form:
refine htotal.of_eq fun k => ?_
by_cases h : (predicate)
· simp [h]
· simp [h]
```

### `(-1 : ℚ)^n` parity reduction

```lean
have pow_red : ∀ n : ℕ, (-1 : ℚ) ^ n = (-1) ^ (n % 2) := by
  intro n
  conv_lhs => rw [← Nat.div_add_mod n 2, pow_add, pow_mul]
  simp
```

After this, `pow_red (s k)` rewrites `(-1)^(s k)` to `(-1)^(s k % 2)`. Combine with `rcases Nat.mod_two_eq_zero_or_one (s k) with h | h` for case analysis.

### Ring identity with truncated ℕ-subtraction

```lean
rw [Nat.cast_sub hle]  -- ↑(a - b) → ↑a - ↑b when h : b ≤ a in ℕ
push_cast               -- distributes other ℕ-casts
field_simp              -- clears denominators using available `hb : (b : ℚ) ≠ 0`
try ring                -- closes leaf; `try` because field_simp may already close
```

The `try ring` is essential — `field_simp` closes some cases entirely; `ring` would then error "No goals to be solved" without `try`.

## Critical knowledge — Mathlib gotchas surfaced this session

- **`Primrec₂.to_comp` returns `Computable₂`, not `Computable`.** Composition pattern is `.comp arg1 arg2`, NOT `.comp (arg1.pair arg2)`.
- **No direct `Primrec₂` for ℤ/ℚ arithmetic in Mathlib.** Don't waste time looking for `Primrec.int_add` or `Primrec.rat_add`; they're derivable but not exported. The `IsComputableSeqRat` closure proofs work at the **ℕ-level** via sign-num-den decomposition.
- **`nat_sub` is truncated.** `(a - b : ℕ)` is `0` when `b > a`. The ℚ-cast `Nat.cast_sub : b ≤ a → ((a - b : ℕ) : ℚ) = (a : ℚ) - (b : ℚ)` requires the hypothesis to handle the truncation properly.
- **`(-1 : ℚ)^n` is best reduced via `n % 2`** rather than tracking parity in the witness predicate. The `pow_red` helper above is the bridge.
- **`field_simp` may close the goal.** Always follow with `try ring` rather than bare `ring` to avoid "No goals to be solved" errors.

## Watchpoints — don't repeat past mistakes

All prior watchpoints still apply. Augmentations from this session:

- **DON'T trust prior-session "no new L1 lemmas needed" claims without checking the actual L1 file's `## What this file is NOT` section.** Last session's NEXT-SESSION.md made this misjudgment; the entire L1 arithmetic-closure machinery was deferred at L1 design time and we discovered it the hard way.
- **DON'T attempt to derive `Primrec₂.rat_add` / `int_add` from scratch.** The ℕ-level sign-num-den approach is much shorter and is the project's established idiom.
- **DON'T `rw` patterns that appear on both sides of the goal expecting it to rewrite only one.** Use `conv_lhs` / `conv_rhs` / `nth_rewrite` to target. (This was last session's `Rat.num_div_den` gotcha; still relevant.)
- **DON'T commit Lean files with new sorry-warnings just to "show structure".** Either prove fully or leave the draft in `thinking/`. Sorry-warnings in production Lean degrade C1 and the project's "1 sorry-warning at the instance level" invariant.
- **DON'T set proof-attempt iter budgets below what the prior round took for similar work.** The 6 iters / 120 min limit for closure proofs is too tight by ~2-3×.

## User calibration

Unchanged from prior session. Technically capable; explicit authorization for bold changes. Defer on Zulip posting / commits / PRs / scope changes. The user authorized the prior round's final commit specifically.

## Files to know

- `CLAUDE.md` — slim constitution. Read first.
- `docs/SETUP.md` — Lean install + first build.
- `docs/NEXT-SESSION.md` — this file.
- `ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` — L0, `done`.
- `ComputableAnalysis/L1/ComputableSeqReal.lean` — L1 `IsComputableSeqRat`/`IsComputableSeqReal`, **`done`** (0 sorries). **NB**: explicit "What this file is NOT" section at lines 56-64 lists arithmetic closure as deferred — that gap is what the next round closes.
- `ComputableAnalysis/L3/ComputabilityStructure.lean` — **L3 keystone, `formalized`** (0 sorries).
- `ComputableAnalysis/L4/Instances/CMap.lean` — **L4 first instance, `stub`** (def/instance bodies sorry-free; A1/A2/A3 theorem-body sorries grouped under the instance at line 261; **new this round**: `private theorem isComputableSeqRat_add` ~80 lines at the top, marked `TODO(refactor → L1):` — the candidate lift target).
- `ComputableAnalysis.lean` — umbrella import.
- `claims/l3-computability-structure/axioms.md` — L3 design doc.
- `claims/l1-computable-reals/is-computable-seq-real.md` — L1 design doc.
- `literature/papers/PourEl-Richards-*.md` — per-chapter verbatim extracts.
- `.goals/l4-cmap-axiom-linearity/final.md` — full report of the prior round (budget-exhausted, 5/6 iters, ~198 min; `_add` shipped, A1 still sorry).
- `.goals/INDEX.md` — registry of all past rounds.
- `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` — full paper-form A1 proof + verbatim P-R citations (still load-bearing; the citations and proof sketch will guide the future A1 round).
- `docs/zulip-drafts/{2026-06-01-l0-pitch,2026-06-01-l3-pitch,2026-06-01b-decision}.md` — Zulip drafts (still deferred).

## If the user types something different

The above task list assumes default continuation. If the user opens with a different request (e.g., "let's actually post the Zulip pitches", "resume L4 A1 directly anyway", "let's start L2 instead"), follow their direction — this prompt is a *default*, not a script.

---

*End of prompt.*
