# Prompt for next session

> *Paste this prompt as the opening message in the next conversation. It is self-contained — you do not need to re-read prior transcripts.*

---

You are continuing work on the **mathlib-computable-analysis** project: a Lean 4 / Mathlib4 formalization of Pour-El & Richards-style computable analysis, intended for upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root: `/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. Read `CLAUDE.md` first — it was rewritten in the prior session and is now ~210 lines (was ~400). The pivot it encodes is **load-bearing**; do not roll back to paper-first.

## TL;DR

1. `cd formal && lake build` — should produce 0 errors and ~5 `sorry` warnings.
2. Drive the sorries down. Don't write new paper claims.
3. After L0 compiles, draft a Zulip pitch (ask user before posting).
4. Start L1 from `claims/l1-computable-reals/is-computable-seq-real.md` (design already done).

## Context — what happened in the prior session (2026-06-01)

The user authorized a substantial pivot. Their exact instruction was: *"I want you to feel completely free, redefine the project's purpose, scaffolding, constitution, skills, nothing is out of scope. Do any change you deem will increase our chance to succeed in writing the right Lean4 code and trying the most successful strategies."*

Diagnosis behind the pivot: the L3 axioms claim had been through **8 devil's-advocate review iterations on paper**, with zero lines of Lean. The `/goal` + DA + verbatim-extract scaffolding is research infrastructure (designed for open conjectures of uncertain truth); it was being misapplied to formalization (where the textbook is the spec and the Lean type-checker is the verifier).

What changed in the prior session:
- **CLAUDE.md rewritten** — 4 core architectural commitments (was 6+anti-goals); anti-goals softened to preferences; lean-first workflow as default; `/goal`+DA relegated to genuine open research.
- **L0 Lean files written** at `formal/ComputableAnalysis/L0/` — `Bridge.lean`, `PropB.lean`, `AnalysisBridge.lean`. Total ~360 lines, 5 sorries (all in theorem positions, definitions concrete).
- **Lake project scaffolded** — `lakefile.toml` (Mathlib4 git dep, `autoImplicit false`), `lean-toolchain` pinned to `leanprover/lean4:v4.31.0-rc1` (matches Mathlib master).
- **`docs/SETUP.md`** — elan install + first-build steps + troubleshooting.
- **Existing claim files updated** — `lean_target:` paths corrected to `formal/ComputableAnalysis/L<N>/...` (was `formal/L<N>/...`).

What did NOT change: existing L1 and L3 claim files (good design docs), literature extracts, `.goals/` scaffolding (dormant, not deleted), the existing skills.

## Your task this session

### Action 1 — verify the build (first command)

```bash
cd formal && lake build 2>&1 | head -50
```

Three outcomes:

- **Clean** (0 errors, ~5 `sorry` warnings): proceed to Action 2.
- **Compile errors**: most likely cause is Mathlib API drift since the June-2026 verification. Triage with `docs/SETUP.md` §3 troubleshooting and the verified-knowledge list below. Fix imports / identifiers one at a time.
- **elan / lake missing**: the user hasn't completed install from `docs/SETUP.md` yet; tell them which step to run.

### Action 2 — drive the sorries

Five sorries exist; tackle in this order:

1. **`PropB.lean:insepA_insepB_disjoint`** (~5 lines, easiest). If `e ∈ insepA ∩ insepB` then `Part.some 0 = e.eval (encode e) = Part.some 1`, so `0 = 1` via `Part.some_injective`, contradicting `Nat.zero_ne_one` (or `(by decide : (0 : ℕ) ≠ 1)`).
2. **`Bridge.lean:cantorPair_computable`**. `(x+y)(x+y+1)/2 + x` is primitive recursive. Best route: build a `Primrec₂` witness from `Primrec₂.nat_add`, `.nat_mul`, `.nat_div`, `Primrec₂.const`, then close with `Primrec₂.to_comp`. If direct composition is painful, search Mathlib for `Nat.Primrec.add_mul_div` or similar prebuilt helpers.
3. **`PropB.lean:insepA_re`** and **`insepB_re`**. Show `fun e : Code => e.eval (encode e) = Part.some k` is `REPred`. Decompose: universal eval is `Partrec₂`, the diagonal `fun e => e.eval (encode e)` is `Partrec` by composition with `Encodable.encode` (which is `Computable`), then post-compose with the decidable equality test against `Part.some k` to get `REPred`. Search Mathlib for `Nat.Partrec.Code.eval_partrec` or `Code.evaln_prim` for the universal-eval handle.
4. **`PropB.lean:insepA_insepB_no_separator`** (hardest, the meat of Prop B). Recursion-theorem fixed-point argument. Search Mathlib for `Nat.Partrec.Code.fixed_point` or `Nat.Partrec.Code.smn` (the s-m-n theorem). If neither exists as a clean lemma, the construction may itself be a contribution to Mathlib. Standard textbook sketch is in `PropB.lean`'s docstring; the Lean translation is the work.

**Three-attempt rule.** If a sorry resists 3 substantive attempts, leave it with a `-- TODO(/formalize L0):` comment naming the specific obstruction and move on. Don't spin.

### Action 3 — Zulip pitch (draft, then ask user)

Draft a 3-paragraph project pitch for `#new contributors` on the Mathlib Zulip:

- Paragraph 1: what we're doing (P-R-style computable analysis), why (no formalization exists), what's done (L0 stubs compile).
- Paragraph 2: the architectural choice (predicates over Mathlib's spaces; `ComputabilityStructure` typeclass) and why we chose P-R over TTE.
- Paragraph 3: the specific question — *"Are the L0 alias-layer names (`IsRecursive`, `IsRecursivelyEnumerable`, `IsRecursiveSet`) ones you'd accept upstream as part of `Mathlib.Computability.Analysis.Bridge`, or would you prefer we drop the aliases and use `Computable`, `REPred`, `ComputablePred` directly throughout?"*

Save the draft at `docs/zulip-drafts/<date>-l0-pitch.md`. **Do not post without asking the user** — public communication is their call. Once posted, track the thread at `docs/zulip-threads.md`.

### Action 4 — start L1

The claim `claims/l1-computable-reals/is-computable-seq-real.md` has the design done (Definition 5a from P-R Ch. 0, the modulus-free form). Write `formal/ComputableAnalysis/L1/ComputableSeqReal.lean` directly from it. Pattern:

```lean
def IsComputableSeqRat (r : ℕ → ℚ) : Prop := ∃ a b s : ℕ → ℕ,
  Computable a ∧ Computable b ∧ Computable s ∧ (∀ k, b k ≠ 0) ∧
  ∀ k, r k = (-1)^(s k) * (a k / b k : ℚ)

def IsComputableSeqReal (x : ℕ → ℝ) : Prop := ∃ r : ℕ × ℕ → ℚ,
  IsComputableSeqRat (r ∘ Nat.unpair) ∧
  ∀ n k, |((r (n, k) : ℝ)) - x n| ≤ 1 / 2^k
```

(Sketch; refine signatures against the claim.) `IsComputableSeqComplex` follows coordinatewise. Definitions concrete; closure lemmas with `sorry` + TODO. Skip writing a separate claim file — the existing one is the design doc.

## Critical knowledge — facts verified against Mathlib4 master on 2026-06-01

These took a 15-minute agent run to verify. Trust them. If you need to extend the lookup, the prior agent's ID is `af8576b19b1d6e872` — use `SendMessage` to continue it rather than spawning a fresh agent.

| Concept | Exact Mathlib symbol | Import |
|---|---|---|
| r.e. predicate | `REPred` (all caps, no namespace) | `Mathlib.Computability.RE` |
| recursive predicate | `ComputablePred (· ∈ s)` | `Mathlib.Computability.RE` |
| halting set, r.e. half | `ComputablePred.halting_problem_re (n) : REPred fun c => (eval c n).Dom` | `Mathlib.Computability.Halting` |
| halting set, not recursive | `ComputablePred.halting_problem (n) : ¬ComputablePred ...` | `Mathlib.Computability.Halting` |
| Mathlib's `Nat.pair` formula | `if a < b then b*b + a else a*a + a + b` (max-based, NOT Cantor) | `Mathlib.Data.Nat.Pairing` |
| Primrec / Primcodable | new home | `Mathlib.Computability.Primrec.Basic` (old `.Primrec` deprecated 2026-01-10) |
| ℓ^p | `lp` (lowercase) | `Mathlib.Analysis.Normed.Lp.lpSpace` (moved from old `NormedSpace.lpSpace`) |
| L^p | `MeasureTheory.Lp` | `Mathlib.MeasureTheory.Function.LpSpace.Basic` |
| Banach space | conjunction `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]` | no single class |
| Hilbert space | conjunction `[RCLike 𝕜] [NormedAddCommGroup E] [InnerProductSpace 𝕜 E] [CompleteSpace E]` | no single class |
| `EuclideanSpace` | `abbrev EuclideanSpace 𝕜 n := PiLp 2 fun _ : n => 𝕜` | `Mathlib.Analysis.InnerProductSpace.PiL2` |
| `ContDiff` smoothness | `ContDiff 𝕜 (n : WithTop ℕ∞) f`. For C^∞ use `n = ∞ : ℕ∞` (open scoped namespace). | `Mathlib.Analysis.Calculus.ContDiff.Defs` |
| `C(X, Y)` sup norm on compact X | sup-norm instance via `ContinuousMap.Compact` (not in `.Defs`) | `Mathlib.Topology.ContinuousMap.Compact` |
| `C₀(X, Y)` zero at infinity | `ZeroAtInftyContinuousMap` | `Mathlib.Topology.ContinuousMap.ZeroAtInfty` |
| Recursively inseparable pair | **NOT in Mathlib** — real work, lives in our `PropB.lean` | — |

## Watchpoints — don't repeat past mistakes

- **DON'T fall back into paper-first.** If you find yourself writing a long Markdown design doc before any Lean, stop. Write the Lean stub; let the type-checker tell you what design questions are actually open.
- **DON'T invoke `/goal` or `/devils-advocate` for L0 / L1 prerequisites.** Type-checker + Zulip is faster and better-calibrated. Reserve `/goal` for genuine open research (the L5 First/Second Main Theorems may qualify; the L0/L1 prerequisites do not).
- **DON'T re-litigate the 4 architectural commitments in CLAUDE.md.** They are durable. If you find a genuine conflict, write to `thinking/_arch-conflicts/<date>.md` and surface to the user; don't unilaterally amend.
- **DON'T invent Mathlib symbols.** If `exact?` / loogle don't find it, the symbol doesn't exist. Either state a missing lemma as its own `lemma` (with sorry + TODO) or restructure.
- **DON'T spin on a single sorry.** Three substantive attempts, then `-- TODO` and move on.
- **DON'T ask the user clarifying questions when you can decide.** The user explicitly authorized boldness. Decide on code structure, sorry-priority, naming, refactoring, file moves yourself. Reserve questions for: public communication (Zulip posts, PRs), mission-level scope changes, irreversible destructive operations.

## User calibration

Technically capable; has invested significant time; explicitly OK with bold changes that increase the chance of success. Their exact phrasing was: *"Do any change you deem will increase our chance to succeed in writing the right Lean4 code and trying the most successful strategies."* They will push back if you are over-deferential or asking too many questions.

Defer on: pushing commits, opening PRs, posting publicly (Zulip), mission scope changes.
Decide yourself: code structure within `formal/`, sorry priority, naming, refactoring, whether a claim file is needed.

## Files to know

- `CLAUDE.md` — the new slim constitution. Read first.
- `docs/SETUP.md` — Lean install + first build.
- `docs/NEXT-SESSION.md` — this file.
- `formal/ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` — the L0 stubs.
- `claims/l1-computable-reals/is-computable-seq-real.md` — L1 design doc, drives L1 Lean code.
- `claims/l3-computability-structure/axioms.md` — L3 design doc, drives L3 Lean code.
- `literature/papers/PourEl-Richards-*.md` — per-chapter verbatim extracts. Cite from these, not from memory.

## If the user types something different

The above task list assumes default continuation. If the user opens with a different request (e.g., "let's actually skip L0 sorries and jump to L3", "I want to think about TTE for a minute", "rewrite the lakefile"), follow their direction — this prompt is a *default*, not a script.

---

*End of prompt.*
