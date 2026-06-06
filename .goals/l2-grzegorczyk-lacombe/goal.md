---
slug: l2-grzegorczyk-lacombe
started: 2026-06-05T17:00:00Z
mode: proof-attempt
max_iterations: 50
time_budget_minutes: 360
allow_writes:
  - ComputableAnalysis/L2/**
  - ComputableAnalysis.lean
  - blueprint/src/L2.tex
  - blueprint/src/content.tex
  - docs/NEXT-SESSION.md
  - claims/l2-grzegorczyk-lacombe/**
  - .goals/l2-grzegorczyk-lacombe/**
  - .goals/INDEX.md
forbid_writes:
  - claims/**
  - literature/papers/**
  - raw_papers/**
  - ComputableAnalysis/L0/**
  - ComputableAnalysis/L1/**
  - ComputableAnalysis/L3/**
  - ComputableAnalysis/L4/**
  - ComputableAnalysis/L5/**
devils_advocate_required_for:
  - C1
  - C2
  - C3
  - C4
  - C5
---

# Goal: Open L2 — Grzegorczyk–Lacombe predicate + structural closures (const, id, sum, neg) sorry-free

## Why this matters

L2 is the computable-continuous-function layer of the P-R five-layer scaffold —
the analytic bridge between L1 (computable reals) and L4 (Banach-space
computability instances). The previous round closed `C[α,β]` in L4 entirely
sorry-free, but L4's predicate is polynomial-approximation-shaped (Definition B);
L2's `IsGLComputable` is sequential-computability + effective uniform-continuity
(Definition A). Having Definition A available in Lean unlocks the eventual Ch. 0
§7 Equivalence Theorem (`IsGLComputable → IsComputableSeqCMap`) and is the
prerequisite for Ch. 1's integration/differentiation results. This round
deliberately holds back the L4 bridge (effective Stone-Weierstrass) and the
product/composition closures (boundedness arguments) to land a small, fully
sorry-free L2 anchor first; follow-up rounds extend.

Reference: P-R Ch. 0 §3 Definition A at `literature/papers/PourEl-Richards-chapt0.md:427-435`.

## Success criteria

- [ ] C1: Define `IsGLComputable` in `ComputableAnalysis/L2/GrzegorczykLacombe.lean`
      as a concrete `def` (not a `class`), parameterized on
      `{α β : ℝ}` (or `{α β : ℚ}` if the L4 bridge later demands it; the
      round selects one and documents the choice), taking a continuous map
      `f : C(Set.Icc α β, ℝ)` and returning `Prop`. The body must match
      P-R Ch. 0:427-435 Definition A verbatim — *both* clauses (i) sequential
      computability on computable sequences `x : ℕ → Set.Icc α β` and (ii)
      effective uniform-continuity modulus `d : ℕ → ℕ` with `Computable d`
      and `|x-y| ≤ 1/d N → |f x - f y| ≤ 1/2^N`. No `sorry`. The file header
      docstring quotes Definition A verbatim.

- [ ] C2: `lem:l2_const_gl` — for any `c : ℝ` with `IsComputableReal c`,
      `IsGLComputable (ContinuousMap.const _ c)`. Named, sorry-free lemma
      under `ComputableAnalysis.L2`.

- [ ] C3: `lem:l2_id_gl` — the coordinate inclusion
      `(fun x : Set.Icc α β => (x : ℝ)) : C(Set.Icc α β, ℝ)` satisfies
      `IsGLComputable` (modulus `d N = 2^N` or `N+1`-shaped; sequential
      computability follows from the input sequence's own computability).
      Named, sorry-free lemma.

- [ ] C4: `lem:l2_sum_gl` — `IsGLComputable f → IsGLComputable g →
      IsGLComputable (f + g)`. Sequential computability via L1's
      `IsComputableSeqReal.add`; modulus is `max (d_f (N+1)) (d_g (N+1))`-shaped.
      Named, sorry-free lemma.

- [ ] C5: `lem:l2_neg_gl` — `IsGLComputable f → IsGLComputable (-f)`.
      Sequential computability via L1's `IsComputableSeqReal.neg`; modulus
      preserved unchanged. Named, sorry-free lemma.

- [ ] C6: Blueprint nodes `def:isGLComputable`, `lem:l2_const_gl`,
      `lem:l2_id_gl`, `lem:l2_sum_gl`, `lem:l2_neg_gl` exist in
      `blueprint/src/L2.tex` with `\leanok` markers on *both* statement
      and (for the lemmas) proof envs, plus `\lean{<DeclName>}` links to
      the actual Lean decls. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls`
      exits 0; `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web` exits 0.

- [ ] C7: `ComputableAnalysis.lean` umbrella imports the new
      `ComputableAnalysis.L2.GrzegorczykLacombe` module. `lake build` reports
      0 errors and 0 `sorry`-warnings (the existing `push_neg` deprecation
      warnings on `L4/Instances/CMap.lean` are the accepted baseline).
      `#print axioms ComputableAnalysis.L2.IsGLComputable` and `#print axioms`
      on each of `l2_const_gl`, `l2_id_gl`, `l2_sum_gl`, `l2_neg_gl` shows
      only `[propext, Classical.choice, Quot.sound]`.

- [ ] C8: `docs/NEXT-SESSION.md` updated with the post-L2 state table
      (L2 row now `definition + 4 closures \leanok`), a "what just happened"
      summary, and a recommended-next-round section that points at either
      product/composition closures, the L4 bridge (Equivalence Theorem),
      or Zulip outreach.

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes`.
- ≥3 iterations with identical unmet criteria.
- Devil's-advocate verdict `unsound` on any committed claim.
- iter ≥ `max_iterations` (50) or elapsed ≥ `time_budget_minutes` (360).
- Repeated `lake build` failures on the same missing-Mathlib-symbol error
  (escalate to grep-first, see `docs/PITFALLS.md §1`).
