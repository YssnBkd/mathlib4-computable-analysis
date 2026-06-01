---
slug: l3-computability-structure-lean
status: success
started: 2026-06-01T19:20:06Z
ended: 2026-06-01T19:50:00Z
mode: explore
iterations: 2/50
time_used_minutes: ~30
devils_advocate_invocations: 0
---

# Final report — `l3-computability-structure-lean`

## Outcome

**All 5 success criteria met.** No iterations stagnated; no devil's-advocate
required (per NEXT-SESSION.md §Watchpoints — formalization work, type-checker
adjudicates).

## Criteria status

| ID | Statement | Outcome |
|---|---|---|
| C1 | `cd formal && lake build` returns exit 0 | ✅ 2531 jobs, exit 0, 2 expected sorry warnings (the L1 helpers — C3 keeps them with TODO markers, per sorry-policy theorem-body allowance) |
| C2 | L3 ComputabilityStructure file exists, type-checks, all required fields | ✅ `formal/ComputableAnalysis/L3/ComputabilityStructure.lean` (≈190 lines); `class ComputabilityStructure` with 5 fields (`IsComputableSeq` predicate, `axiom_linearity`, `axiom_limits`, `axiom_norms`, `zero_seq`); 2 derived `def`s (`IsComputableElement`, `IsComputableDoubleSeq`); auxiliary `class ScalarComputableSeq 𝕜` with canonical `ℝ` instance via L1; umbrella `ComputableAnalysis.lean` imports it; 0 sorries in the L3 file. |
| C3 | 2 pre-existing L1 helper sorries closed or retained with TODO | ✅ via path (b) — 3+ substantive attempts (`exact_mod_cast`, explicit ℤ-bridge with `Int.natAbs_neg`/`Int.natAbs_of_nonneg`, goal/hypothesis `push_cast`) all hit a `(natAbs : ℤ) → |·|` simp-normalization asymmetry: the lemma fires in ℤ but does not symmetrically simplify the `ℕ → ℚ` direct cast. Reverted both sorries to their original TODO markers, with the obstruction and recommended next move (`Int.cast_natAbs`, likely under `Mathlib.Algebra.Order.Ring.Abs`) recorded inline in the docstrings. |
| C4 | Zulip post decision recorded | ✅ via deferral — drafted companion `docs/zulip-drafts/2026-06-01-l3-pitch.md` for `#Mathlib4` audience (parallel 3-paragraph structure to the L0 pitch, headlining the P-R-vs-TTE design tension and three specific Lean design questions); both L0 and L3 drafts carry `## Status` notes recording the deferral and revisit-next-session trigger. |
| C5 | CLAUDE.md milestone tracker reflects L3 outcome | ✅ Row for "L3 / `ComputabilityStructure` typeclass — three axioms" moved from `claimed` → `formalized` (0 sorries in L3 file). Pointer updated to describe the actual Lean content. |

## C2 breakdown — L3 typeclass shape

| Field / def | Purpose | P-R reference |
|---|---|---|
| `IsComputableSeq : (ℕ → E) → Prop` | The primitive predicate on vector sequences | Ch. 2:49 |
| `axiom_linearity` | Closure under bounded scalar-linear combinations w/ computable double-seq coefficients | Ch. 2:66-72 |
| `axiom_limits` | Closure under effective limits of computable double sequences | Ch. 2:58-64, 73 |
| `axiom_norms` | Norms of computable sequences are L1-computable real sequences | Ch. 2:75 |
| `zero_seq` | Non-vacuity: constant zero sequence is computable | Ch. 2:77 |
| `def IsComputableElement (x : E)` | Computable points (constant sequence form) | Ch. 2:55 |
| `def IsComputableDoubleSeq (x : ℕ × ℕ → E)` | Convenience: `Nat.unpair`-reindexed double sequence | Ch. 2:53 |

Auxiliary: `class ScalarComputableSeq (𝕜 : Type*) [RCLike 𝕜]` providing
`IsComputableSeq : (ℕ → 𝕜) → Prop`. Canonical `ℝ` instance defers to L1's
`IsComputableSeqReal`; `ℂ` instance deferred to whenever L1's
`IsComputableSeqComplex` lands.

## Key gotchas surfaced

1. **`∑ k ∈ s, a + b` parses with `+` outside the binder.** Lean's `∑` notation
   has lower precedence than `+`, so `∑ k ∈ Finset.range (d n + 1), α (n, k) •
   x k + β (n, k) • y k` parses as `(∑ k ∈ …, α (n, k) • x k) + β (n, k) •
   y k`, leaving `k` free in the trailing summand. Fix: parenthesize the
   body: `∑ k ∈ s, (α (n, k) • x k + β (n, k) • y k)`. (Caught on first build,
   ~30s to diagnose.)
2. **`(natAbs : α) → |·|` cast asymmetry.** `push_cast`/`norm_cast`/`mod_cast`
   normalize `((q.num.natAbs : ℕ) : ℤ)` to `|q.num|` (in ℤ, via a `@[simp,
   norm_cast]` lemma), but the same normalization does NOT fire on the direct
   `(q.num.natAbs : ℕ) → ℚ` cast. This blocks the elementary
   `(-1)^s * |q.num| = q.num` ℤ→ℚ transfer for `isComputableSeqRat_const`.
   Investigated workarounds: `Int.cast_natAbs` (the lemma we want — likely in
   `Mathlib.Algebra.Order.Ring.Abs` per the symbol name, but not in scope under
   our current imports); explicit `Int.natCast_natAbs + Int.cast_abs` chain
   (untried — recommended for next attempt). Per Watchpoint, capped at 3
   substantive attempts and deferred.

## Files touched

- **New**: `formal/ComputableAnalysis/L3/ComputabilityStructure.lean`
  (≈190 lines, class + 5 fields + 2 derived defs + aux class with ℝ instance,
  0 sorries).
- **New**: `docs/zulip-drafts/2026-06-01-l3-pitch.md` (companion to L0 pitch,
  for `#Mathlib4`).
- **Modified**: `formal/ComputableAnalysis.lean` (L3 import line).
- **Modified**: `formal/ComputableAnalysis/L1/ComputableSeqReal.lean` (sorries
  experimentally proven and then reverted to TODO; docstrings augmented with
  the cast-asymmetry rationale).
- **Modified**: `CLAUDE.md` (L3 milestone-tracker row: `claimed` → `formalized`
  with concrete pointer description).
- **Modified**: `docs/zulip-drafts/2026-06-01-l0-pitch.md` (added `## Status`
  deferral note).
- **Modified**: `current-goal.md` (all 5 criteria ticked with met-iter
  annotations).
- **Modified**: `.goals/l3-computability-structure-lean/iter-02.md` (progress
  field filled; unmet emptied; files_changed populated).
- **Modified**: `.goals/INDEX.md` (will be marked `success` at goal close).

## Open questions / suggested follow-ups for next session

1. **Close the 2 L1 helper sorries.** The blocked path through cast normalization
   should resolve by either (a) importing `Mathlib.Algebra.Order.Ring.Abs`
   (verify this is the right path — could also be `Mathlib.Data.Int.Cast.Lemmas`)
   to bring `Int.cast_natAbs` into scope, or (b) chaining
   `Int.natCast_natAbs + Int.cast_abs + Int.cast_natCast` manually. Either
   approach should be a 5-line proof once the cast lemma is named correctly.
2. **Zulip posts (L0 + L3).** Both drafts ready and tagged deferred. The L3
   draft cross-references the L0 thread URL placeholder; if posted, post L0
   first or simultaneously and fill in the cross-reference.
3. **L4 instance work** is now the natural next deliverable. `C([a,b], ℝ)`
   with sup norm is the gentlest concrete instance to attempt; `L^p[a,b]` and
   separable Hilbert follow.
4. **L1 follow-ups (still on CLAUDE.md tracker as `pending`)**:
   `IsComputableReal : ℝ → Prop` (constant-sequence case), arithmetic closure
   of `IsComputableSeqReal`, countable-subfield theorem, `IsComputableSeqComplex`.
5. **Uniqueness / Stability Lemma** (L3 second milestone, `pending`) is the
   natural follow-up to the ComputabilityStructure typeclass — provable only
   under an `EffectivelySeparable` mixin that we factored out per Ch. 2:204,
   2:248.

## Statistics

- **Total iterations**: 2 (well under 50 cap)
- **Time elapsed**: ~30 min (well under 3600 min cap)
- **L3 sorries closed/avoided**: full L3 file is sorry-free (0/0)
- **L1 sorries closed**: 0/2 (per C3 path (b); 3+ attempts each, reverted)
- **Devil's-advocate invocations**: 0 (matches NEXT-SESSION.md §Watchpoints
  cadence for formalization work)
