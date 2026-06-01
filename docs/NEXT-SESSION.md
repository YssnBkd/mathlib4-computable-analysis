# Prompt for next session

> *Paste this prompt as the opening message in the next conversation. It is self-contained — you do not need to re-read prior transcripts.*

---

You are continuing work on the **mathlib-computable-analysis** project: a Lean 4 / Mathlib4 formalization of Pour-El & Richards-style computable analysis, intended for upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. Read `CLAUDE.md` first — it is the project constitution (~210 lines, lean-first, do NOT roll back to paper-first).

## TL;DR

1. `cd formal && lake build` — should produce **0 errors, 1 sorry-warning** (one *declaration* uses sorry: the L4 CMap instance, grouping the 3 axiom theorem-body sorries A1/A2/A3 into one warning).
2. **L1 is `done`** — both helper sorries closed last session (the cast-asymmetry obstruction turned out to be a name guess: the lemma is `Nat.cast_natAbs`, already in scope, not `Int.cast_natAbs` as previously conjectured).
3. **L4 `C([a, b], ℝ)` instance is `stub`.** File at `formal/ComputableAnalysis/L4/Instances/CMap.lean`. Predicate via P-R Ch. 2:141 polynomial-approximation form. Instance declared, `zero_seq` proven, A1/A2/A3 theorem-body sorries with `-- TODO(/formalize L4 CMap):` + verbatim P-R citations.
4. **Two Zulip pitches still drafted, still deferred.** L0 → `#new contributors`, L3 → `#Mathlib4`. Decision recorded at `docs/zulip-drafts/2026-06-01b-decision.md`.

## Context — what happened in the prior session (2026-06-01, `next-session-2026-06-01b`)

This was a `/goal` autonomous run (mode=explore, success in 2 iterations / ~30 min). All 6 success criteria met. Full report at `.goals/next-session-2026-06-01b/final.md`.

What changed:

- **L1 `done`.** `isComputableSeqRat_const` and `isComputableSeqReal_const_rat` in `formal/ComputableAnalysis/L1/ComputableSeqReal.lean` are CLOSED (0 sorries). The proof routes via `rw [Nat.cast_natAbs, Int.cast_abs]` + `conv_lhs => rw [← Rat.num_div_den q]` + sign case-split. **Key gotcha (now documented in the closure's docstring):** `rw [← Rat.num_div_den q]` *without* `conv_lhs` rewrites every literal `q` in the goal — including the `q`s inside `q.num`/`q.den` field projections on the RHS — and explodes the goal. Use `conv_lhs` to target only one side.
- **L4 CMap `stub`.** New file `formal/ComputableAnalysis/L4/Instances/CMap.lean` (~150 lines including docstring). Defines `polyApproxCMap` (noncomputable continuous map) and `IsComputableSeqCMap : (ℕ → C(Set.Icc α β, ℝ)) → Prop` (P-R Ch. 2:141 polynomial form). `noncomputable instance instComputabilityStructureCMap` declared with all four axiom fields. `zero_seq` is proved (all-zero coefficient triple sequence). A1 / A2 / A3 are theorem-body sorries with explicit `-- TODO(/formalize L4 CMap):` comments and P-R citations (Ch. 2:129 for A1 "trivial"; Ch. 0 Thm 4 for A2; Ch. 0 Thm 7 for A3).
- **Umbrella import** at `formal/ComputableAnalysis.lean` extended with the L4 line.
- **CLAUDE.md milestone tracker**: L1 row → `done`; L4 CMap row → `stub`.
- **Zulip decision recorded** at `docs/zulip-drafts/2026-06-01b-decision.md` — defer both posts (user choice).

## Your task this session

### Action 1 — verify the build (first command)

```bash
cd formal && lake build 2>&1 | tail -20
```

Expected: 0 errors, **1 sorry warning** (`ComputableAnalysis/L4/Instances/CMap.lean:104:23: declaration uses sorry` — this is ONE warning for the L4 instance grouping 3 internal theorem-body sorries at lines 117/128/139). If you see anything else, see §Triage below.

### Action 2 — choose a direction (open)

The L1 work is fully done. L3 is stable. L4 CMap.lean compiles. Three orthogonal directions, ranked by value:

#### Direction A — fill an L4 axiom proof (heaviest, highest payoff)

The three open axioms in `formal/ComputableAnalysis/L4/Instances/CMap.lean`:

- **A1 (`axiom_linearity`)** — P-R Ch. 2:129 says "trivial" for the G-L predicate, but under our polynomial-approximation form (Ch. 2:141) it requires ~80-120 Lean lines of rational arithmetic: explicit rational-approximation of scalar coefficients α/β to precision `2^{-m}`, sum over `k ∈ Finset.range (d n + 1)` of the rational-polynomial combinations, plus a 2x-precision pad. Each polynomial-combination's coefficients are a finite sum of rational products → rational. Degree bound = `max_k (d^x (k, m'), d^y (k, m'))`. Witness data flattens to a quadruple-sequence via three `Nat.pair` calls.
- **A2 (`axiom_limits`)** — P-R says A2 = Ch. 0 Theorem 4. Diagonalize: given the double sequence `f_{n, k} → f_n` effectively with modulus `e`, take `a'_{n, N, j} := a_{n, e(n, N+1), N+1, j}`, `d'_{n, N} := d_{n, e(n, N+1), N+1}`. Triangle inequality gives the `2^{-N+1}` bound. Need composition lemmas on `Computable`.
- **A3 (`axiom_norms`)** — P-R says A3 = Ch. 0 Theorem 7. Hardest of the three: sup-norm computability requires evaluating polynomials on a rational grid + L1 closure under finite `max` + absolute-value. Likely needs an L1 closure lemma (`IsComputableSeqReal` closure under `max`) that is itself deferred work.

**Recommended target:** A1 first. It's the most self-contained — the proof never leaves the polynomial form, doesn't need new L1 lemmas, and the bound bookkeeping (while tedious) is mechanical.

Suggested goal slug: `l4-cmap-axiom-linearity`. Mode: `proof-attempt`. Budget: 6 iters / 120 min.

#### Direction B — L1 `IsComputableReal` (point-form predicate; lighter)

The L1 row in the CLAUDE.md tracker for `IsComputableReal : ℝ → Prop` is still `pending`. By P-R Ch. 0 commitment, a single real `x : ℝ` is computable iff the constant sequence `(x, x, x, …)` is in `IsComputableSeqReal`. This is a one-line definition + a few sanity lemmas (closure under `+`, `*`, etc.) that route through the L1 sequence-closure machinery (also pending).

This is the natural prerequisite for **A3** above. If A1 lands cleanly and you want to keep stacking L4 progress, doing L1 `IsComputableReal` and L1 closure lemmas first unblocks A3.

Suggested goal slug: `l1-is-computable-real`. Mode: `explore`. Budget: 12 iters / 90 min.

#### Direction C — post the deferred Zulip pitches

Two drafts ready, both currently with `## Status` deferral notes:
- `docs/zulip-drafts/2026-06-01-l0-pitch.md` (`#new contributors`)
- `docs/zulip-drafts/2026-06-01-l3-pitch.md` (`#Mathlib4`)

The decision-recipe (post L0 first, wait, fill in L3's URL placeholder, post L3) is in `docs/zulip-drafts/2026-06-01b-decision.md`. This is ~30 min of human-in-loop bookkeeping but high-leverage for L4/L5 design feedback from Brattka, Pauly, Schröder. Always ask the user before posting.

### Action 3 — if no direction is chosen, default to Direction A

The user's prior round opened "ambitious — L4 instance formalized". With the instance now `stub`, the natural continuation is filling an axiom. A1 is the cleanest.

## Critical knowledge — Mathlib4 symbols (verified against master 2026-06-01)

All entries from the prior sessions' tables remain valid. Augmentations from this session:

| Concept | Exact Mathlib symbol | Import | Note |
|---|---|---|---|
| `(↑n.natAbs : α) = ↑\|n\|` (abs in ℤ then cast) | `Nat.cast_natAbs` (in `_root_` namespace) | `Mathlib.Algebra.Order.Ring.Int` (transitively in scope under default L1 imports) | NOT `Int.cast_natAbs` — that was a prior-session name guess. The `@[simp]` simp lemma the prior session was looking for. |
| `(↑\|n\| : α) = \|↑n\|` (cast then abs in α) | `Int.cast_abs` | transitively in scope | Bridges from the form `Nat.cast_natAbs` produces (abs in ℤ then cast) to the form most arguments need (cast then abs in α). |
| `(q.num : ℚ) / (q.den : ℚ) = q` | `Rat.num_div_den` | `Mathlib.Algebra.Ring.Rat` (transitively in scope) | **Gotcha**: `rw [← Rat.num_div_den q]` rewrites every literal `q` in the goal, including the `q`s inside `q.num`/`q.den` field projections — use `conv_lhs` (or `conv_rhs` / `nth_rewrite`) to target one side only. |
| `C(Set.Icc α β, ℝ)` sup-norm instances | auto via `ContinuousMap.instNormedAddCommGroup` etc. | `Mathlib.Topology.ContinuousMap.Compact` + `.Bounded.Normed` | `NormedAddCommGroup`, `NormedSpace ℝ`, `CompleteSpace` all auto-inferred. The space is `noncomputable` (ℝ's field structure), so the L4 instance is `noncomputable instance`. |
| Building a continuous polynomial in `x.val` | `ContinuousMap.mk (fun x => ...) (by continuity)` | same | The `continuity` tactic closes the continuity-obligation for polynomial expressions in `x.val^j`. |

## Critical knowledge — Lean 4 / Mathlib gotchas surfaced this session

- **`Nat.cast_natAbs` is the lemma name** (not `Int.cast_natAbs`). Confirmed at `Mathlib/Algebra/Order/Ring/Int.lean:50`. `@[simp]`, in `_root_` namespace.
- **The `Nat.cast_natAbs ∘ Int.cast_abs` two-step** is the canonical way to convert `((n.natAbs : ℕ) : α)` to `|((n : ℤ) : α)|` for an `α` with `Abs`. Direct `push_cast` / `norm_cast` won't do this in one step — they only know the ℤ-direction.
- **`rw` rewrites ALL literal occurrences of the pattern in the goal**, including ones inside field projections. If a lemma has `q` on one side, `rw [← lemma q]` will rewrite the `q`s inside `q.num`/`q.den` on the OTHER side too. Use `conv_lhs` / `conv_rhs` / `nth_rewrite` to constrain.
- **`noncomputable instance` for ℝ-valued normed types** — when defining an `instance` on a type involving ℝ (or any noncomputable field), prefix with `noncomputable`. Lean's elaborator will complain otherwise about `Real.normedField` being noncomputable.
- **The `continuity` tactic handles polynomial expressions in `x.val^j`** when `x : Set.Icc α β` (or any subtype-of-ℝ where `Continuous Subtype.val` is auto). No manual continuity proof needed.

## Triage — if `lake build` fails

Same as prior sessions — Mathlib master rename, missing `elan` / `lake`, missing cache. See `docs/SETUP.md`.

If the cast lemmas were renamed: grep `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/formal/.lake/packages/mathlib/Mathlib/` for the new home. The names we relied on this session:

- `Nat.cast_natAbs` (at `Mathlib/Algebra/Order/Ring/Int.lean:50`)
- `Int.cast_abs` (implicit-arg form; transitively in scope)
- `Rat.num_div_den` (at `Mathlib/Algebra/Ring/Rat.lean:78`)

## Watchpoints — don't repeat past mistakes

All prior watchpoints still apply. Augmentations from this session:

- **DON'T conjecture lemma names** (`Int.cast_natAbs`-vs-`Nat.cast_natAbs`). 30 seconds of `grep -rn "theorem.*natAbs\|lemma.*natAbs" .lake/packages/mathlib/Mathlib/` finds the right name and avoids 3 wasted attempts.
- **DON'T use `rw [← lemma_about_q]` when `q.num` or `q.den` appears in the goal.** Use `conv_lhs` (or `nth_rewrite 1`) to target only one occurrence. Otherwise the rewrite cascades into the field projections and explodes.
- **DON'T inline L2 to avoid building it.** This session used the P-R Ch. 2:141 polynomial form for L4 CMap precisely to bypass needing L2 right now. The equivalence is licensed by P-R + Effective Density. If you later build L2, refactor the L4 predicate to route through L2 — but don't introduce a parallel L2 stub inside L4 in the meantime.
- **DON'T over-promise `formalized` status.** L4 CMap.lean has theorem-body sorries on A1/A2/A3 — that's `stub`, not `formalized`. `formalized` per CLAUDE.md taxonomy requires "predicate/structure bodies sorry-free" AND ideally theorem bodies converging to sorry-free. Be honest in the tracker.

## User calibration

Unchanged from prior session. Technically capable; explicit authorization for bold changes. Defer on Zulip posting / commits / PRs / scope changes (the user authorized today's commit specifically, after the session).

## Files to know

- `CLAUDE.md` — slim constitution. Read first.
- `docs/SETUP.md` — Lean install + first build.
- `docs/NEXT-SESSION.md` — this file.
- `formal/ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` — L0, `done`.
- `formal/ComputableAnalysis/L1/ComputableSeqReal.lean` — L1, **`done`** (0 sorries; constant-sequence helpers proved).
- `formal/ComputableAnalysis/L3/ComputabilityStructure.lean` — **L3 keystone, `formalized`** (0 sorries).
- `formal/ComputableAnalysis/L4/Instances/CMap.lean` — **L4 first instance, `stub`** (def/instance bodies sorry-free; 3 theorem-body sorries on A1/A2/A3 with TODOs).
- `formal/ComputableAnalysis.lean` — umbrella import.
- `claims/l3-computability-structure/axioms.md` — L3 design doc.
- `claims/l1-computable-reals/is-computable-seq-real.md` — L1 design doc.
- `literature/papers/PourEl-Richards-*.md` — per-chapter verbatim extracts.
- `.goals/next-session-2026-06-01b/final.md` — full report of the prior session (success, 2/50 iters, ~30 min).
- `.goals/l3-computability-structure-lean/final.md` — full report of the session before that.
- `docs/zulip-drafts/2026-06-01-l0-pitch.md` — drafted L0 pitch, deferred.
- `docs/zulip-drafts/2026-06-01-l3-pitch.md` — drafted L3 pitch, deferred.
- `docs/zulip-drafts/2026-06-01b-decision.md` — defer-both-posts decision + 5-step post-when-ready recipe.

## If the user types something different

The above task list assumes default continuation. If the user opens with a different request (e.g., "let's actually post the Zulip pitches", "skip A1, start the L5 First Main Theorem stub", "rewrite the L4 predicate using the raw G-L form instead of polynomial approximation"), follow their direction — this prompt is a *default*, not a script.

---

*End of prompt.*
