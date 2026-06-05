---
slug: l4-cmap-axiom3-norm-resig
started: 2026-06-04T00:00:00Z
mode: proof-attempt
max_iterations: 100
time_budget_minutes: 3600
allow_writes:
  - ComputableAnalysis/L1/ComputableSeqReal.lean
  - ComputableAnalysis/L4/Instances/CMap.lean
  - blueprint/src/L1.tex
  - blueprint/src/L4.tex
  - blueprint/lean_decls
  - .goals/l4-cmap-axiom3-norm-resig/**
  - thinking/l4-cmap-axiom3-norm-resig/**
  - current-goal.md
  - .goals/INDEX.md
  - docs/NEXT-SESSION.md
  - docs/PITFALLS.md
  - docs/LEAN-IDIOMS.md
forbid_writes:
  - ComputableAnalysis/L0/**
  - ComputableAnalysis/L2/**
  - ComputableAnalysis/L3/**
  - ComputableAnalysis/L5/**
  - blueprint/src/L0.tex
  - blueprint/src/L2.tex
  - blueprint/src/L3.tex
  - blueprint/src/L5.tex
  - literature/papers/**/verbatim.md
  - raw_papers/**
  - lakefile.toml
  - lean-toolchain
  - lake-manifest.json
  - claims/INDEX.md
devils_advocate_required_for:
  - "C1"
  - "C5"
  - "C7"
---

# Goal: Close A3 (sup-norm computability) for `C[α, β]` by signature refit, with the missing P-R Prop 1 lemma lifted as a reusable L1 building block.

## Why this matters

The L4 `ComputabilityStructure ℝ (C(Set.Icc α β, ℝ))` instance is the project's
first concrete `ComputabilityStructure` — the "canary instance" that validates
the L3 typeclass design against P-R Ch. 2:128's three-axiom obligation. A1
(linearity) and A2 (effective limit) closed sorry-free in prior rounds; A3
(norm = max of `|fₙ|`) is the single open Lean obligation. Closing A3 makes the
*entire* `C[α, β]` instance sorry-free and unlocks pitching the project to
Mathlib Zulip with a *fully proved* L4 instance in hand.

The signature is provably inadequate (counterexample in lemma docstring — uses
undecidable Σ⁰₁ `P` to make `[α, β]` empty vs. nonempty), so this is a
*signature-refit + body-fill* round, not just a body-fill round. The fix lifts
the P-R Prop 1 ("Closure under effective convergence" — `chapt0:246`) as a
reusable L1 lemma along the way, matching P-R's own dependency structure.

ref: `docs/NEXT-SESSION.md` (recommended-next-task section);
`literature/papers/PourEl-Richards-chapt0.md:977-1012` (Theorem 7);
`literature/papers/PourEl-Richards-chapt0.md:246-272` (Proposition 1);
`literature/papers/PourEl-Richards-chapt2.md:128-129` (axiom 3 = Ch. 0 Thm 7).

## Success criteria

- [ ] **C1: Prop 1 lemma stated.** `IsComputableSeqReal_of_rat_effectiveLimit`
      (or similarly-named) lives in `ComputableAnalysis/L1/ComputableSeqReal.lean`
      with signature matching P-R Ch. 0 Prop 1: given a doubly-computable
      rational sequence `(r_{n,k}) : ℕ × ℕ → ℚ` and a Computable effective
      modulus `e : ℕ × ℕ → ℕ` such that `k ≥ e(n, N) ⇒ |r_{n,k} − x n| ≤ 2⁻ᴺ`,
      conclude `IsComputableSeqReal x`. *(DA required: review statement.)*
- [ ] **C2: Prop 1 lemma proved sorry-free.** Standalone `#print axioms
      isComputableSeqReal_of_rat_effectiveLimit` returns exactly `[propext,
      Classical.choice, Quot.sound]` (no `sorryAx`).
- [ ] **C3: A3 signature refit.** `isComputableSeqCMap_norm` takes the two
      additional hypotheses `(hα_c : IsComputableReal α) (hβ_c : IsComputableReal β)`
      and its docstring is updated to remove the "signature inadequate" obstruction
      and reflect the new closed form.
- [ ] **C4: A3 body filled sorry-free.** The `sorry` at `CMap.lean:~1586` is
      replaced by a complete proof. Standalone `#print axioms
      isComputableSeqCMap_norm` returns exactly the three kernel axioms.
- [ ] **C5: Error decomposition justified.** The three error sources used by
      the proof (polynomial-approximation, endpoint-approximant, grid-discretization)
      are *individually named lemmas or `have`-clauses* with explicit
      computable bounds, not buried in a single arithmetic chain. The proof's
      structure traces visibly to P-R's chapt0:984-1012 steps ①-⑥.
      *(DA required: review the three-error decomposition for soundness and
      completeness.)*
- [ ] **C6: Instance refit.** `computabilityStructureCMap_of` takes all five
      hypotheses `(B) (hα_le) (hβ_le) (hα_c) (hβ_c)`, compiles sorry-free, and
      its A3 field directly delegates to the renewed `isComputableSeqCMap_norm`.
      `#print axioms computabilityStructureCMap_of` returns exactly the three
      kernel axioms.
- [ ] **C7: Repo-wide green.** `lake build 2>&1 | tail -10` shows 0 errors and
      0 sorry-warnings. `grep -rn "sorry" ComputableAnalysis/ --include="*.lean"`
      shows 0 hits (modulo docstring-quoted occurrences). *(DA required:
      sanity-check that no transitive sorry has been introduced elsewhere.)*
- [ ] **C8: Blueprint promoted.** `lem:l4_cmap_axiom3` carries `\leanok` on both
      statement and proof block; the dep graph node renders dark-green. The new
      L1 lemma has a blueprint entry. `leanblueprint web` and
      `leanblueprint checkdecls` exit 0.
- [ ] **C9: Docs updated.** `docs/NEXT-SESSION.md` rewritten to point at the
      next obligation (Zulip outreach? L2 start? L5 stubs?). Any new pitfalls
      hit during the round added to `docs/PITFALLS.md`; any reusable idiom to
      `docs/LEAN-IDIOMS.md`.

## DA usage protocol (round-specific)

Per user direction (round confirmation): the devil's-advocate subagent should
also be invoked to **mine P-R verbatim chapters for relevant insights** at
non-trivial decision points — not only to challenge proposed claims. Specifically:

- When choosing the effective-modulus `e(n, N)` for grid-density, ask DA to
  read `chapt0:984-1012` line-by-line and flag any P-R reasoning we are not
  yet using.
- When the polynomial-Lipschitz computation hits a wall, ask DA whether P-R
  Ch. 0 §3 (Grzegorczyk-Lacombe form) or Ch. 2 §5 (Effective Density Lemma)
  expose a cheaper path.
- When the error-decomposition draft is ready, ask DA to **cross-check it
  against P-R's six-step chapt0:984-1012 derivation** for any silently-skipped
  step.

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes` (the Stop hook
  will halt out-of-scope writes).
- ≥3 iterations with identical unmet criteria (apparent no-progress; halt
  and reassess scope).
- Devil's-advocate verdict `unsound` on any committed claim (refuse to advance
  until resolved).
- `iter ≥ 100` or `elapsed ≥ 3600 min` (round wrap; partial-close gracefully
  per `feedback_round_pragmatism`).
- A criterion gets pushed past its third unmet iteration cycle without a
  rationale recorded in the corresponding `iter-NN.md` (this is the "stuck
  state" the round-pragmatism memory warns about).
