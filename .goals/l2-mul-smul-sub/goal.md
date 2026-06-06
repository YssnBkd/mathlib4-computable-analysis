---
slug: l2-mul-smul-sub
started: 2026-06-05T21:30:00Z
mode: proof-attempt
max_iterations: 50
time_budget_minutes: 360
allow_writes:
  - "ComputableAnalysis/L1/ComputableSeqReal.lean"
  - "ComputableAnalysis/L2/GrzegorczykLacombe.lean"
  - "ComputableAnalysis.lean"
  - "blueprint/src/L1.tex"
  - "blueprint/src/L2.tex"
  - "blueprint/lean_decls"
  - "blueprint/web/**"
  - "docs/NEXT-SESSION.md"
  - ".goals/l2-mul-smul-sub/**"
  - ".goals/l2-grzegorczyk-lacombe/**"
  - ".goals/INDEX.md"
forbid_writes:
  - "claims/**"
  - "literature/papers/**"
  - "raw_papers/**"
  - "ComputableAnalysis/L0/**"
  - "ComputableAnalysis/L3/**"
  - "ComputableAnalysis/L4/**"
  - "ComputableAnalysis/L5/**"
  - "intuition/**"
  - "proofs/**"
devils_advocate_required_for:
  - "C1"
  - "C2"
  - "C3"
  - "C4"
  - "C5"
---

# Goal: Close L2 arithmetic-closure surface — sub/smul/mul (boundedness) + lift L2-private add/neg helpers to L1

## Why this matters

The prior round `l2-grzegorczyk-lacombe` (closed 2026-06-05) landed `IsGLComputable`
plus four structural closures (`const`, `id`, `sum`, `neg`) but left the multiplicative
side untouched and the two sum/neg-supporting helpers (`isComputableSeqReal_add`,
`isComputableSeqReal_neg`) inlined as `private` in L2 with TODO markers for an L1
lift. Closing sub/smul/mul completes the algebra-of-functions skeleton for L2
(matching the L4 `C[a,b]` surface, which already has these via Mathlib's
`ContinuousMap.Algebra`), and lifting the helpers gives L1 a properly named
`IsComputableSeqReal.add` / `.neg` that downstream layers (and the L2→L4 bridge
round) can call by name instead of re-inlining.

Composition (`l2_comp_gl`) is intentionally deferred — encoding `g : C(Set.Icc γ δ,
Set.Icc α β)` (range-as-subtype) is genuinely tricky and warrants its own focused
round (see `.goals/l2-grzegorczyk-lacombe/final.md` §Open questions §4).

Mul is the headline difficulty here: it requires a boundedness argument
(`‖f‖, ‖g‖ ≤ M` on the compact interval) and a modulus shape roughly
`d_mul N := max (df (⌈M_g⌉·2^(N+1))) (dg (⌈M_f⌉·2^(N+1)))` — see
`literature/papers/PourEl-Richards-chapt0.md` (Def A discussion / Theorem 1
algebra closures).

## Success criteria

- [ ] C1: Lift `isComputableSeqReal_add` (currently `private` in
  `ComputableAnalysis/L2/GrzegorczykLacombe.lean:227-266`) to a named theorem
  `IsComputableSeqReal.add` in `ComputableAnalysis/L1/ComputableSeqReal.lean`.
  Signature: `IsComputableSeqReal f → IsComputableSeqReal g →
  IsComputableSeqReal (fun n => f n + g n)`. Update the L2 callsite
  (`l2_sum_gl`) to invoke the L1 name. Sorry-free; DA verdict `passes`.

- [ ] C2: Lift `isComputableSeqReal_neg` (currently `private` in
  `ComputableAnalysis/L2/GrzegorczykLacombe.lean:372-403`) to a named theorem
  `IsComputableSeqReal.neg` in `ComputableAnalysis/L1/ComputableSeqReal.lean`.
  Signature: `IsComputableSeqReal f → IsComputableSeqReal (fun n => -(f n))`.
  Update the L2 callsite (`l2_neg_gl`) to invoke the L1 name. Sorry-free; DA
  verdict `passes`.

- [ ] C3: `l2_sub_gl` named lemma in `…/GrzegorczykLacombe.lean` —
  `IsGLComputable f → IsGLComputable g → IsGLComputable (f - g)`. Recommended:
  derive as corollary of `l2_sum_gl + l2_neg_gl` via `sub_eq_add_neg`
  rewriting on `ContinuousMap`. Sorry-free; DA verdict `passes`.

- [ ] C4: `l2_smul_gl` named lemma in `…/GrzegorczykLacombe.lean` —
  `IsComputableReal c → IsGLComputable f → IsGLComputable (c • f)` (or the
  equivalent scalar-mult form on `C(Set.Icc α β, ℝ)`). Both clauses witnessed:
  (i) `c · f(x_n)` sequentially computable from `IsComputableReal c` and the
  `f` sequential clause; (ii) modulus shape `d_smul N := df (⌈|c|⌉.toNat·2^N+1)`
  or similar with positivity. Sorry-free; DA verdict `passes`.

- [ ] C5: `l2_mul_gl` named lemma in `…/GrzegorczykLacombe.lean` —
  `IsGLComputable f → IsGLComputable g → IsGLComputable (f * g)`. Boundedness
  via `ContinuousMap.norm` on the compact `Set.Icc α β` to extract
  `M_f := ‖f‖`, `M_g := ‖g‖`. Modulus shape:
  `d_mul N := max (df (⌈M_g⌉.toNat + 1)·2^(N+1)) (dg (⌈M_f⌉.toNat + 1)·2^(N+1))`
  with positivity from `Nat.mul_pos`. Sorry-free; DA verdict `passes`.

- [ ] C6: Blueprint nodes added to `blueprint/src/L1.tex`
  (`lem:l1_isComputableSeqReal_add`, `lem:l1_isComputableSeqReal_neg`) and
  `blueprint/src/L2.tex` (`lem:l2_sub_gl`, `lem:l2_smul_gl`, `lem:l2_mul_gl`)
  each with `\leanok` on both statement and proof envs and `\lean{...}` links.
  `leanblueprint checkdecls` → exit 0; `leanblueprint web` → exit 0; dep graph
  shows new nodes dark-green.

- [ ] C7: `lake build` clean (no new warnings beyond the pre-existing
  `push_neg` deprecations on `L4/Instances/CMap.lean`); `#print axioms` for
  each new declaration (`IsComputableSeqReal.add`, `IsComputableSeqReal.neg`,
  `l2_sub_gl`, `l2_smul_gl`, `l2_mul_gl`) returns
  `[propext, Classical.choice, Quot.sound]` only — no `sorryAx`, no new
  axioms.

- [ ] C8: `docs/NEXT-SESSION.md` updated for the post-round state: L1 row
  gains `add`/`neg` named lemmas; L2 row gains `sub`/`smul`/`mul` closures;
  iter count and round slug refreshed; recommended next-round menu includes
  (a) `l2_comp_gl` (composition, the deferred piece) and (b) the L2→L4
  Equivalence bridge.

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes` (Stop hook
  enforces).
- ≥3 iterations with identical `unmet` criteria (loop indicator).
- Devil's-advocate verdict `unsound` on any committed proof.
- `iter ≥ 50` or `elapsed ≥ 360 min`.
- `lake build` regression that cannot be resolved within the current iter.
