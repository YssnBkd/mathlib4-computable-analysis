---
iter: 0
timestamp: 2026-06-05T17:00:00Z
mode: proof-attempt
unmet: [C1, C2, C3, C4, C5, C6, C7, C8]
files_changed: []
---

# iter-00 — round started

## Note

Round started via `/goal l2-grzegorczyk-lacombe` per `docs/NEXT-SESSION.md`
Option B (recommended next direction after the previous round closed L4
`C[α,β]` fully sorry-free).

**Three deliberate scope deviations from NEXT-SESSION.md's literal text:**

1. **L4 bridge deferred.** NEXT-SESSION.md listed
   `IsGLComputable f → IsComputableSeqCMap (fun _ => f)` as a one-line hook
   ("singleton-precision approximation"). On inspection of `L4/Instances/CMap.lean:1214`,
   `IsComputableSeqCMap` is the polynomial-approximation predicate (Def B-style),
   so this hook IS the Ch. 0 §7 Equivalence Theorem — effective Stone-Weierstrass.
   That's a major theorem, not an incidental closure. Deferred to a follow-up
   round so this one can land a small, fully sorry-free L2 anchor.

2. **Product / composition closures deferred.** P-R Ch. 0 §4 Theorem 1
   (composition) requires boundedness arguments for the modulus pullback
   (`g`'s range stays in a known compact, then `f`'s modulus applies).
   Product needs `‖f‖_∞ · |g(x)-g(y)| + ‖g‖_∞ · |f(x)-f(y)|` with effective
   sup-norm bounds (L4 already has `polyEval_lipschitz_real`-style machinery
   we'd need to mirror for `C(Set.Icc α β, ℝ)`). Both deferred.

3. **Negation (C5) added** that NEXT-SESSION.md didn't list. It's nearly free
   given sum closure and `IsComputableSeqReal.neg`, and it pairs naturally
   with sum for the additive-group structure.

## Pre-iter state

- `current-goal.md` was empty (prior round `l4-cmap-axiom3-norm-resig`
  archived as `success` 10/100 in `.goals/INDEX.md`).
- `lake build` green; 0 sorries in `.lean` bodies (all hits are docstrings
  or comments per `grep` audit).
- `ComputableAnalysis/L2/` does not exist yet — clean greenfield.
- `blueprint/src/L2.tex` is a 9-line stub (chapter header + start of one
  definition env) — needs full fleshing-out under C6.
- P-R Ch. 0 §3 Definition A verbatim at chapt0.md:427-435 confirmed in
  context: clauses (i) sequential computability + (ii) effective uniform
  continuity modulus `d : ℕ → ℕ` (recursive) with `|x-y| ≤ 1/d(N) → |f(x)-f(y)| ≤ 2^{-N}`.

## Planned iter-01

Stub the file: write `ComputableAnalysis/L2/GrzegorczykLacombe.lean` with
the verbatim docstring header (Def A quoted from chapt0:427-435), the
`IsGLComputable` predicate body, and the umbrella import in
`ComputableAnalysis.lean`. Target: file compiles, `IsGLComputable` is a
concrete `def` (no `sorry`), `#print axioms` clean. C1 + part of C7.

Domain-choice decision: parameterize on `{α β : ℝ}` with sequential
computability stated for `x : ℕ → Set.Icc α β` — directly matches
P-R's "every computable sequence of points x_k ∈ I^q" wording. The
ℚ-endpoint variant can be derived for free when needed by specializing.
