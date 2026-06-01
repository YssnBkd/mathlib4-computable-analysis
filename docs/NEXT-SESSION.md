# Prompt for next session

> *Paste this prompt as the opening message in the next conversation. It is self-contained — you do not need to re-read prior transcripts.*

---

You are continuing work on the **mathlib-computable-analysis** project: a Lean 4 / Mathlib4 formalization of Pour-El & Richards-style computable analysis, intended for upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. Read `CLAUDE.md` first — it is the project constitution (~210 lines, lean-first, do NOT roll back to paper-first).

## TL;DR

1. `cd formal && lake build` — should produce **0 errors, 2 `sorry` warnings** (both still in `L1/ComputableSeqReal.lean` — see Action 1 below).
2. **L3 ComputabilityStructure typeclass is `formalized`.** L4 instance work is the natural next deliverable; `C([a, b], ℝ)` with sup norm is the gentlest concrete instance to attempt.
3. **Close the 2 L1 helper sorries** — last session diagnosed the exact obstruction (cast-asymmetry around `(natAbs : ℤ) → |·|`); a one-line import fix should unblock it.
4. **Two Zulip pitches drafted, both deferred.** L0 → `#new contributors`, L3 → `#Mathlib4`. User decision needed before posting.

## Context — what happened in the prior session (2026-06-01, `l3-computability-structure-lean`)

This was a `/goal` autonomous run (mode=explore, success in 2 iterations / ~30 min). All 5 success criteria met. Full report at `.goals/l3-computability-structure-lean/final.md`.

What changed:

- **L3 ComputabilityStructure typeclass written and compiling** at `formal/ComputableAnalysis/L3/ComputabilityStructure.lean` (≈190 lines, 0 sorries). The class has 5 fields encoding P-R Ch. 2 §1: `IsComputableSeq` predicate, `axiom_linearity` (A1), `axiom_limits` (A2), `axiom_norms` (A3; reaches L1's `IsComputableSeqReal`), and `zero_seq` non-vacuity. Plus 2 derived `def`s: `IsComputableElement` (constant sequence) and `IsComputableDoubleSeq` (`Nat.unpair`-reindexed). Plus an auxiliary `class ScalarComputableSeq 𝕜` with the canonical `ℝ` instance via L1.
- **CLAUDE.md milestone tracker**: L3 row moved `claimed` → `formalized`.
- **2 Zulip pitches drafted** (both **NOT POSTED**, deferred by user decision):
  - `docs/zulip-drafts/2026-06-01-l0-pitch.md` — `#new contributors` audience, alias-layer naming question.
  - `docs/zulip-drafts/2026-06-01-l3-pitch.md` — `#Mathlib4` audience, P-R-vs-TTE design tension + 3 specific Lean design questions.
- **2 L1 helper sorries diagnosed but not closed.** Three substantive attempts at `isComputableSeqRat_const` hit a cast asymmetry: `push_cast`/`norm_cast`/`mod_cast` rewrite `((q.num.natAbs : ℕ) : ℤ)` to `|q.num|` (in ℤ) but do NOT symmetrically rewrite `((q.num.natAbs : ℕ) : ℚ)` to `|((q.num : ℤ) : ℚ)|`. The lemma we want appears to be `Int.cast_natAbs` (`(n.natAbs : α) = |((n : ℤ) : α)|` for an ordered ring `α`) but it was not in scope under the L1 imports. **Recommended next move**: add `import Mathlib.Algebra.Order.Ring.Abs` (or `Mathlib.Data.Int.Cast.Lemmas`, whichever exposes `Int.cast_natAbs`) to `L1/ComputableSeqReal.lean` and retry. The witnessing data `(a, b, s) = (q.num.natAbs, q.den, if q.num < 0 then 1 else 0)` all `Computable.const` is correct.

## Your task this session

### Action 1 — verify the build (first command)

```bash
cd formal && lake build 2>&1 | tail -20
```

Expected: 0 errors, **2 sorry warnings** (`ComputableAnalysis/L1/ComputableSeqReal.lean` at lines ~116 and ~126 — the same two helpers as the prior session, with augmented docstrings recording the cast-asymmetry obstruction). If you see anything else, see §Triage below.

### Action 2 — close the 2 L1 helper sorries (now that the obstruction is diagnosed)

The witness data is already designed; the prior session's experimental code is recoverable from the docstring comments. Plan:

1. Add `import Mathlib.Algebra.Order.Ring.Abs` (verify path via `grep -r "theorem Int.cast_natAbs" ~/.elan` or via `loogle`).
2. For `isComputableSeqRat_const q`: refine the witness as `⟨fun _ => q.num.natAbs, fun _ => q.den, fun _ => (if q.num < 0 then 1 else 0), Computable.const _, Computable.const _, Computable.const _, fun _ => q.den_ne_zero, fun _ => ?_⟩`. The remaining goal `q = (-1)^s * (↑q.num.natAbs / ↑q.den)` reduces, after `rw [Int.cast_natAbs]`, to `q = (-1)^s * (|↑q.num| / ↑q.den)`. Case-split on `q.num < 0` and apply `abs_of_neg`/`abs_of_nonneg` + `Rat.num_div_den`.
3. For `isComputableSeqReal_const_rat q`: `refine ⟨fun _ => q, isComputableSeqRat_const q, fun _ _ => ?_⟩; simp` should close it once (2) is closed.

Three-attempt rule still applies; if the import path is wrong and the lemma resists, leave the TODO and move on.

### Action 3 — L4 instance work (highest-value next step)

With L3 stable, the natural next deliverable is a concrete instance of `ComputabilityStructure 𝕜 E` for some concrete `E`. P-R Ch. 2 §2-4 covers `C[a, b]`, `L^p`, `ℓ^p`, separable Hilbert. The gentlest is `C([a, b], ℝ)` with sup norm:

- File: `formal/ComputableAnalysis/L4/Instances/CMap.lean`
- Mathlib substrate: `C(Set.Icc a b, ℝ)` (already a complete `[NormedAddCommGroup]` via the sup-norm instance, see `AnalysisBridge.lean`).
- Computable-sequence predicate idea: a sequence of continuous functions `f_n : C([a,b], ℝ)` is computable iff there is a recursive method that, given `n` and a rational `q ∈ [a, b]` and precision `k`, produces a rational `r` with `|r - f_n(q)| ≤ 2^{-k}`. (P-R Ch. 2:124 — the standard "G-L computable" definition transferred to the L3 axiomatic framework.)
- Axioms 1-3 + non-vacuity will need short proofs; the bulk is the construction.

Time-box this — if the construction itself is more than 200 lines or hits 3+ unsolved sorries in `def`/`structure` bodies (forbidden per sorry policy), abandon and pick a smaller target.

### Action 4 — Zulip post decision (still pending)

Two drafts ready, both with `## Status` deferral notes:
- `docs/zulip-drafts/2026-06-01-l0-pitch.md` (`#new contributors`)
- `docs/zulip-drafts/2026-06-01-l3-pitch.md` (`#Mathlib4`)

The L3 pitch cross-references the L0 thread URL placeholder; if posted, post L0 first or simultaneously and fill in `<L0-thread-URL>` in the L3 draft. Ask the user before posting.

## Critical knowledge — Mathlib4 symbols (verified against master 2026-06-01)

All entries from the prior session's table remain valid. Augmentations from this session:

| Concept | Exact Mathlib symbol | Import | Note |
|---|---|---|---|
| `RCLike` (for `𝕜 ∈ {ℝ, ℂ}`) | `RCLike 𝕜` | `Mathlib.Analysis.RCLike.Basic` | Extends `NormedField`; the right scalar typeclass for P-R Ch. 2 *mutatis mutandis*. |
| `NormedSpace` (the actual class) | `[NormedAddCommGroup E] [NormedSpace 𝕜 E]` | `Mathlib.Analysis.Normed.Module.Basic` | Path; not `Mathlib.Analysis.NormedSpace.Basic`. |
| `BigOperators` Σ-syntax for Finset | `∑ k ∈ s, body` | `Mathlib.Algebra.BigOperators.Group.Finset.Basic` + `open scoped BigOperators` | **Gotcha**: `∑` has lower precedence than `+`; `∑ k ∈ s, a + b` parses as `(∑ k ∈ s, a) + b`. **Always parenthesize the body** when it contains `+` outside scalar mult. |
| `(natAbs : α) → \|·\|` cast lemma | `Int.cast_natAbs` (probable name) | likely `Mathlib.Algebra.Order.Ring.Abs` or `Mathlib.Data.Int.Cast.Lemmas` — **VERIFY** | NOT in scope under default L1 imports as of this session. The `@[simp, norm_cast]` simp lemma that powers `push_cast`'s ℤ-direction natAbs→abs rewrite. |

## Critical knowledge — Lean 4 / Mathlib gotchas surfaced this session

- **`∑ k ∈ s, expr` precedence**: parenthesize any `+` in the body. (Cost ~30s to diagnose during L3 write.)
- **Cast-asymmetry around `natAbs`**: `mod_cast` / `push_cast` / `norm_cast` rewrite `((n.natAbs : ℕ) : ℤ)` to `|n|` (in ℤ) but NOT the parallel ℚ-cast. The simp lemma is one-directional. Workaround: name the lemma directly (`Int.cast_natAbs` once imported).
- **`@(𝕜 := …)` placeholder syntax for typeclass-method calls**: when `ScalarComputableSeq.IsComputableSeq` is called on a function `ℕ → 𝕜` with `𝕜` from a `[ScalarComputableSeq 𝕜]` instance arg, Lean elaborates the `𝕜` from the codomain; no explicit `(𝕜 := 𝕜)` needed. But for `IsComputableElement` and `IsComputableDoubleSeq` (where they live outside `class ComputabilityStructure`), I used `(𝕜 := 𝕜)` defensively; could be relaxed.

## Triage — if `lake build` fails

Same as prior session — Mathlib master rename, missing `elan` / `lake`, missing cache. See `docs/SETUP.md`.

If `Mathlib.Algebra.Order.Ring.Abs` (or wherever `Int.cast_natAbs` lives) was renamed or moved, the L1 sorry-closure work in Action 2 will need to find the new home. `grep -r "theorem Int.cast_natAbs" ~/.elan/toolchains/*/lib/lean4/library` or `~/.elan/toolchains/*/.cache` should locate it.

## Watchpoints — don't repeat past mistakes

All prior watchpoints still apply. Augmentations from this session:

- **DON'T spin on a sorry whose obstruction has been diagnosed.** If the cast-asymmetry workaround (`import Mathlib.Algebra.Order.Ring.Abs`) doesn't work in 1-2 attempts, fall back to TODO again — the L1 sorries are NOT blocking L4.
- **DON'T forget `open scoped BigOperators` in files using `∑ … ∈ …, …` notation.** And **parenthesize `+` inside the sum body.**
- **DON'T re-derive what's already documented.** The L3 design doc (`claims/l3-computability-structure/axioms.md`) is the source of truth for axiom-statement decisions. The Lean encoding `formal/ComputableAnalysis/L3/ComputabilityStructure.lean` matches it field-for-field; deviations should be flagged.
- **DON'T introduce new claim files for L4 instance work unless a design choice is non-obvious.** Per CLAUDE.md §"Workflow — lean-first by default": for instance constructions, the Lean docstring + claim file are optional; the type-checker is the spec.

## User calibration

Unchanged from prior session. Technically capable; explicit authorization for bold changes. Defer on Zulip posting / commits / PRs / scope changes.

## Files to know

- `CLAUDE.md` — slim constitution. Read first.
- `docs/SETUP.md` — Lean install + first build.
- `docs/NEXT-SESSION.md` — this file.
- `formal/ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` — L0, `done`.
- `formal/ComputableAnalysis/L1/ComputableSeqReal.lean` — L1 (predicates concrete; 2 helper sorries with diagnosed cast obstruction recorded in docstrings).
- `formal/ComputableAnalysis/L3/ComputabilityStructure.lean` — **L3 keystone, `formalized`** (0 sorries).
- `claims/l3-computability-structure/axioms.md` — L3 design doc (8 DA rounds clean, faithfully encoded by the Lean file).
- `claims/l1-computable-reals/is-computable-seq-real.md` — L1 design doc.
- `literature/papers/PourEl-Richards-*.md` — per-chapter verbatim extracts.
- `.goals/l3-computability-structure-lean/final.md` — full report of the prior session (success, 2/50 iters, ~30 min).
- `.goals/execute-docs-next-session-md/final.md` — full report of the session before that.
- `docs/zulip-drafts/2026-06-01-l0-pitch.md` — drafted L0 pitch, deferred.
- `docs/zulip-drafts/2026-06-01-l3-pitch.md` — drafted L3 pitch, deferred.

## If the user types something different

The above task list assumes default continuation. If the user opens with a different request (e.g., "let's actually post the Zulip pitches", "skip L4, start L5 main theorems", "rewrite the L3 typeclass with `ComputableScalar` as an outParam"), follow their direction — this prompt is a *default*, not a script.

---

*End of prompt.*
