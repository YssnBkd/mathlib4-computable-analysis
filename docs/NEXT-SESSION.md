# Prompt for next session

> *Paste this prompt as the opening message in the next conversation. It is self-contained — you do not need to re-read prior transcripts.*

---

You are continuing work on the **mathlib-computable-analysis** project: a Lean 4 / Mathlib4 formalization of Pour-El & Richards-style computable analysis, intended for upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. Read `CLAUDE.md` first — it is the project constitution (~210 lines, lean-first, do NOT roll back to paper-first).

## TL;DR

1. `cd formal && lake build` — should produce 0 errors, 2 `sorry` warnings (both in L1 theorem bodies — see Action 2 below).
2. **L3 keystone is the highest-value next move.** Promote `claims/l3-computability-structure/axioms.md` to `formal/ComputableAnalysis/L3/ComputabilityStructure.lean`. All L0/L1 prerequisites are now in place.
3. Close the 2 L1 helper sorries if quick, defer if not.
4. Decide on Zulip post (draft already exists at `docs/zulip-drafts/2026-06-01-l0-pitch.md` — the user has not yet authorized posting).

## Context — what happened in the prior session (2026-06-01)

This was a `/goal` autonomous run (`execute-docs-next-session-md`, mode=explore, success in 2 iterations / ~140 min). All 4 success criteria met. Full report at `.goals/execute-docs-next-session-md/final.md`.

What changed:
- **All 5 L0 sorries CLOSED** (not just TODO'd — actually proven). The hardest one (`insepA_insepB_no_separator`) uses Mathlib's `Nat.Partrec.Code.fixed_point₂` (Kleene recursion theorem, partial form) — so Prop B turned out to be a one-screen Lean proof, not a Mathlib contribution.
- **L0 status `stub` → `done` for all three files** (`Bridge.lean`, `PropB.lean`, `AnalysisBridge.lean`). CLAUDE.md milestone tracker updated.
- **L1 `IsComputableSeqReal` written** at `formal/ComputableAnalysis/L1/ComputableSeqReal.lean` — concrete `def` bodies; 2 sorries remain in helper theorems (`isComputableSeqRat_const`, `isComputableSeqReal_const_rat`).
- **Build-environment fixes:**
  - Umbrella `ComputableAnalysis.lean` had module-docstring before `import` (Lean 4 forbids this) — reordered.
  - `AnalysisBridge.lean`'s `L^p` smoke test was implicitly requiring `MeasureSpace ℝ` (would pull in `Mathlib.MeasureTheory.Measure.Haar.OfBasis` — too heavy at L0). Switched to abstract measure.
  - `AnalysisBridge.lean` needed `open scoped ZeroAtInfty` for the `C₀` notation.
- **`formal/lake-manifest.json`** now exists (committed) — pins Mathlib4 and 8 transitive deps. `lake update` re-resolves; `lake exe cache get` was needed once (≈8479 files, ~5 min).
- **Zulip pitch drafted** but NOT posted (`docs/zulip-drafts/2026-06-01-l0-pitch.md`). User decision required before posting.

## Your task this session

### Action 1 — verify the build (first command)

```bash
cd formal && lake build 2>&1 | tail -20
```

Expected: 0 errors, **2 sorry warnings** (both in `ComputableAnalysis/L1/ComputableSeqReal.lean` at lines ~121 and ~130). If you see anything else, see §Triage below.

### Action 2 — L3 keystone (highest-value)

This is the architectural centerpiece of the entire project (CLAUDE.md commitment #1). All prerequisites are now in place:

- L0 `IsRecursive`, `IsRecursivelyEnumerable`, `IsRecursiveSet`, `prop_A`, `prop_B` (`done`)
- L1 `IsComputableSeqReal` (the reach-down for Axiom 3 / Norms)
- Mathlib's `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]`

Write `formal/ComputableAnalysis/L3/ComputabilityStructure.lean`, driven by `claims/l3-computability-structure/axioms.md` (the design doc, ~110 lines, 8 devil's-advocate iterations on paper — it's the ripest non-Lean artifact in the repo). Pattern:

```lean
/-- A computability structure on a Banach space `E` over `𝕜`, as in
Pour-El & Richards Ch. 2. Three axioms over a designated effective basis. -/
class ComputabilityStructure
    (𝕜 : Type*) [RCLike 𝕜]   -- or [NontriviallyNormedField 𝕜] depending on the axiom set
    (E : Type*) [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E] where
  /-- The effective basis: a designated computable sequence. -/
  basis : ℕ → E
  /-- Predicate: "(x_n) is a computable sequence in E". -/
  IsComputableSeq : (ℕ → E) → Prop
  /-- Axiom 1 (Linearity): … -/
  axiom_linearity : …
  /-- Axiom 2 (Limits / effective convergence): … -/
  axiom_limits : …
  /-- Axiom 3 (Norms): … invokes `IsComputableSeqReal` from L1 … -/
  axiom_norms : …
```

Refine the exact field signatures against the claim file. Keep definitions concrete (per sorry policy); proofs that the *axioms hold* for specific instances (`C[a,b]`, `L^p`, separable Hilbert) are L4 work — defer with stubs.

**Once L3 stubs compile, post to Zulip `#Mathlib4`** (separate post from the `#new contributors` L0 pitch). Brattka, Pauly, Schröder read that stream; their input on the P-R-vs-represented-spaces tension is the highest-value review available. Ask the user before posting.

### Action 3 — close the 2 L1 helper sorries (if quick)

`formal/ComputableAnalysis/L1/ComputableSeqReal.lean` has two `sorry`s, both with explicit TODOs:

1. `isComputableSeqRat_const (q : ℚ) : IsComputableSeqRat (fun _ => q)` — exhibit `a, b, s : ℕ → ℕ` as constant functions encoding `q.num.natAbs`, `q.den`, and sign of `q`. `Computable.const` plus arithmetic. Should be ~10-15 lines.
2. `isComputableSeqReal_const_rat (q : ℚ) : IsComputableSeqReal (fun _ => (q : ℝ))` — use (1) on the constant double sequence `fun _ => q`. The bound `|q - q| = 0 ≤ 1/2^k` is `by simp` or `by positivity`.

If either resists 3 substantive attempts, leave the TODO and move on. These are not blocking L3.

### Action 4 — Zulip post decision (user-gated)

Draft at `docs/zulip-drafts/2026-06-01-l0-pitch.md`. Ask the user whether to post (or wait until L3 stubs compile and then post both pitches). If they say go, record thread URL + 1-paragraph summary at `docs/zulip-threads.md` after posting.

## Critical knowledge — Mathlib4 symbols (verified against master 2026-06-01)

These were verified during this session's L0/L1 work. Trust them.

| Concept | Exact Mathlib symbol | Import |
|---|---|---|
| r.e. predicate | `REPred` (all caps, no namespace) | `Mathlib.Computability.RE` |
| recursive predicate | `ComputablePred (· ∈ s)` | `Mathlib.Computability.RE` |
| `ComputablePred → REPred` | `ComputablePred.to_re` | `Mathlib.Computability.RE:211` |
| `ComputablePred.decide` (extract Bool indicator) | `hp.decide : Computable fun a => decide (p a)` | `Mathlib.Computability.RE:136` |
| halting set, r.e. half | `ComputablePred.halting_problem_re (n)` | `Mathlib.Computability.Halting` |
| halting set, not recursive | `ComputablePred.halting_problem (n)` | `Mathlib.Computability.Halting` |
| Mathlib's `Nat.pair` formula | `if a < b then b*b + a else a*a + a + b` (max-based) | `Mathlib.Data.Nat.Pairing` |
| Primrec / Primcodable | new home | `Mathlib.Computability.Primrec.Basic` |
| `Primrec.nat_add/mul/div` (live in `namespace Primrec` — names misleading) | `Primrec.nat_add : Primrec₂ ((·+·) : ℕ→ℕ→ℕ)`, similar for `mul`, `div` | `…Primrec.Basic:593/599/710` |
| `Primrec.beq` | `Primrec₂ (BEq.beq)` (via `Primrec.eq.decide`) | `…Primrec.Basic:658` |
| `Primrec.to_comp` / `Primrec₂.to_comp` | upgrade Primrec→Computable | `…Partrec:246/251` |
| Universal eval | `Nat.Partrec.Code.eval_part : Partrec₂ eval` | `…PartrecCode:994` |
| **Kleene recursion theorem (partial)** | `Nat.Partrec.Code.fixed_point₂ {f : Code → ℕ →. ℕ} (hf : Partrec₂ f) : ∃ c, eval c = f c` | `…PartrecCode:1022` |
| **Kleene recursion theorem (total)** | `Nat.Partrec.Code.fixed_point` | `…PartrecCode:1004` |
| `Partrec.cond` | conditional Partrec with computable Bool predicate | `Mathlib.Computability.RE:110` |
| `Partrec.dom_re` | `Partrec f → REPred fun a => (f a).Dom` | `Mathlib.Computability.RE:164` |
| `Partrec.bind` | `Partrec f → Partrec₂ g → Partrec fun a => (f a).bind (g a)` | `Mathlib.Computability.Partrec:400` |
| `Part.bind_dom` | `(f.bind g).Dom ↔ ∃ h, (g (f.get h)).Dom` | `Mathlib.Data.Part:577` |
| `Part.some_inj` | `Part.some a = Part.some b ↔ a = b` | `Mathlib.Data.Part:199` |
| `Part.not_none_dom` | `¬ Part.none.Dom` | `Mathlib.Data.Part:173` |
| `Part.eq_some_iff` | `a = Part.some b ↔ b ∈ a` | `Mathlib.Data.Part` |
| ℓ^p | `lp` (lowercase) | `Mathlib.Analysis.Normed.Lp.lpSpace` |
| L^p | `MeasureTheory.Lp` | `Mathlib.MeasureTheory.Function.LpSpace.Basic` |
| `MeasureSpace ℝ` (only if `volume` needed) | `Real.measureSpace` | `Mathlib.MeasureTheory.Measure.Haar.OfBasis:319` |
| Banach space | `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]` | no single class |
| Hilbert space | `[RCLike 𝕜] [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]` | no single class |
| `EuclideanSpace` | `abbrev EuclideanSpace 𝕜 n := PiLp 2 fun _ : n => 𝕜` | `Mathlib.Analysis.InnerProductSpace.PiL2` |
| `ContDiff` smoothness | `ContDiff 𝕜 (n : WithTop ℕ∞) f` | `Mathlib.Analysis.Calculus.ContDiff.Defs` |
| `C(X, Y)` sup norm on compact X | sup-norm instance via `ContinuousMap.Compact` | `Mathlib.Topology.ContinuousMap.Compact` |
| `C₀(X, Y)` zero at infinity | `ZeroAtInftyContinuousMap`; notation `C₀(α, β)` is `scoped[ZeroAtInfty]` — `open scoped ZeroAtInfty` to use | `Mathlib.Topology.ContinuousMap.ZeroAtInfty` |
| Recursively inseparable pair | **NOW in our `PropB.lean`** — fully proven via `Code.fixed_point₂` | — |

## Triage — if `lake build` fails

The likely failure modes:

- **Mathlib master moved**: `lake-manifest.json` is committed but Mathlib master may have a breaking rename. Run `lake update mathlib`, then `lake exe cache get`, then `lake build`. If the build still fails, the renamed symbol(s) will be in the error log; cross-reference the table above and update imports.
- **elan / lake missing**: see `docs/SETUP.md` §1. First-time install is `brew install elan-init`.
- **No cache**: `lake exe cache get` fetches ≈8479 files (~5 min, 50-300 MB). If you skip this, `lake build` will compile Mathlib from scratch (30+ min). Don't.

## Watchpoints — don't repeat past mistakes

- **DON'T fall back into paper-first.** Write the Lean stub; let the type-checker tell you what's actually open. The L3 design doc has been DA'd 8 times — it's ready for Lean, not more paper review.
- **DON'T invoke `/goal` or `/devils-advocate` for L0 / L1 / L3 axiom-statement prerequisites.** Type-checker + Zulip is faster. Reserve `/goal` for genuine open research (L5 main theorems may qualify). This session's `execute-docs-next-session-md` goal used mode=explore + zero DA, completed in 2 iters/140 min — that's the right cadence for formalization work.
- **DON'T re-litigate the 4 architectural commitments in CLAUDE.md.** They are durable. If you find a genuine conflict, write to `thinking/_arch-conflicts/<date>.md` and surface to the user; don't unilaterally amend.
- **DON'T invent Mathlib symbols.** If `exact?` / loogle don't find it, the symbol doesn't exist. State a missing lemma as its own `lemma` (with sorry + TODO) or restructure.
- **DON'T forget the `.comp` dot-notation gotcha**: `Primrec₂.nat_add.comp` parses as a 3-part qualified name lookup, not as `(Primrec₂.nat_add).comp`. Either use parens, or call `Primrec₂.comp` explicitly (preferred — clearer). Also note: `Primrec.nat_add` (etc.) lives in `namespace Primrec`, NOT `namespace Primrec₂`, even though it produces a `Primrec₂` value.
- **DON'T put module docstring before imports.** Lean 4 requires order: copyright header `/- ... -/` → `import` lines → module docstring `/-! ... -/` → code. Mathlib's `module` / `public import` keywords are the new module system; we currently use the classic form.
- **DON'T spin on a single sorry.** Three substantive attempts, then `-- TODO` and move on.
- **DON'T ask the user clarifying questions when you can decide.** Reserve questions for public communication (Zulip posts, PRs), mission-level scope changes, irreversible destructive operations.

## User calibration

Technically capable; explicit authorization for bold changes: *"Do any change you deem will increase our chance to succeed in writing the right Lean4 code and trying the most successful strategies."* Will push back if you are over-deferential.

- **Defer on**: pushing commits, opening PRs, posting publicly (Zulip), mission scope changes.
- **Decide yourself**: code structure within `formal/`, sorry priority, naming, refactoring, file moves, whether a claim file is needed.

## Files to know

- `CLAUDE.md` — slim constitution. Read first.
- `docs/SETUP.md` — Lean install + first build.
- `docs/NEXT-SESSION.md` — this file.
- `formal/ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` — L0, `done`.
- `formal/ComputableAnalysis/L1/ComputableSeqReal.lean` — L1 (predicates concrete; 2 helper sorries).
- `claims/l1-computable-reals/is-computable-seq-real.md` — L1 design doc.
- `claims/l3-computability-structure/axioms.md` — L3 design doc, *the next big target*.
- `literature/papers/PourEl-Richards-*.md` — per-chapter verbatim extracts. Cite from these.
- `.goals/execute-docs-next-session-md/final.md` — full report of the prior session.
- `docs/zulip-drafts/2026-06-01-l0-pitch.md` — drafted L0 pitch, NOT posted.

## If the user types something different

The above task list assumes default continuation. If the user opens with a different request (e.g., "let's actually post the Zulip pitch", "rewrite the L3 design", "let's think about L4 instances first"), follow their direction — this prompt is a *default*, not a script.

---

*End of prompt.*
