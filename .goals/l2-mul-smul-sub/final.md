---
slug: l2-mul-smul-sub
ended: 2026-06-06T00:30:00Z
iterations: 10
outcome: success
---

# Final summary for goal: Close L2 arithmetic-closure surface — sub/smul/mul (boundedness) + lift L2-private add/neg helpers to L1

## Criteria status

- [x] **C1**: `IsComputableSeqReal.add` hoisted from L2-`private` to a named L1 §4.5 theorem at `ComputableAnalysis/L1/ComputableSeqReal.lean` (`namespace IsComputableSeqReal`, `theorem add`). L2 callsite `l2_sum_gl` now invokes `h_f.add h_g` via dot notation. DA review `.goals/l2-mul-smul-sub/reviews/C1.md`: `verdict: passes` (joint axiom-audit + Mathlib symbol grep + line-by-line bound chain).

- [x] **C2**: `IsComputableSeqReal.neg` hoisted to L1 §4.5 (`theorem neg` after `theorem add`). Modulus design verified tight: `e(p) := p.2` (unshifted) because `abs_neg` preserves magnitude exactly — contrasts with `.add`'s required `N+1` shift from triangle inequality. L2 `l2_neg_gl` now invokes `h_f.neg`. DA `reviews/C2.md`: `verdict: passes`.

- [x] **C3**: `l2_sub_gl` at `ComputableAnalysis/L2/GrzegorczykLacombe.lean` §4. Two-line proof: `rw [sub_eq_add_neg]; exact l2_sum_gl hf (l2_neg_gl hg)`. The `AddGroup C(X, ℝ)` instance from `Mathlib.Topology.ContinuousMap.Algebra` makes `f - g = f + (-g)` a one-step rewrite. DA `reviews/C3.md`: `verdict: passes`.

- [x] **C4**: `l2_smul_gl` at `…/GrzegorczykLacombe.lean` §5 with two new L1 helpers added during the same iter (iter-05 + iter-06):
  - `IsComputableSeqReal.bound` (L1 §4.5): Nat-valued `Computable` upper bound on `|y n|` extracted from the `IsComputableSeqRat`-witness ingredients `(a_w, b_w)` at index `Nat.pair n 0`. ~55 lines.
  - `IsComputableSeqReal.mul` (L1 §4.5): full multiplication closure using `.bound` for magnitude estimates. Modulus `e(n,N) := N + Ma n + Mb n + 1`; amplification via `Nat.lt_two_pow_self` (`m+1 ≤ 2^(m+1)`). ~115 lines.
  - `l2_smul_gl` itself: modulus `df (N + Mc 0)` (additive shift by Nat bound on `|c|`), clause-(i) via `IsComputableSeqReal.mul` on the constant sequence `fun _ => c` and the L1-computable `fun n => f (x n)`. ~55 lines. Spec hint was multiplicative `· 2^N` but additive form is cleaner and equally tight. DA `reviews/C4.md`: `verdict: passes` (joint review of `bound` + `mul` + `l2_smul_gl`).

- [x] **C5**: `l2_mul_gl` at `…/GrzegorczykLacombe.lean` §6 — the round's headline result. ~135 lines. Boundedness via `ContinuousMap.norm_coe_le_norm` on the compact `Set.Icc α β` (`CompactSpace` automatic from `compactSpace_Icc`, which comes from the `CompactIccSpace ℝ` instance). Modulus `d_mul N := df (N + 1 + M_g) * dg (N + 1 + M_f)` where `M_f, M_g := ⌈‖·‖⌉₊ + 1`. Cross-term bound chain `M / 2^(N+1+M) ≤ 1/2^(N+1)` via `Nat.lt_two_pow_self`'s `M ≤ 2^M`; total `≤ 1/2^N`. Required adding `import Mathlib.Topology.ContinuousMap.Compact` for the `Norm` instance. Empty-interval case (`α > β`) handled vacuously without explicit case-split. DA `reviews/C5.md`: `verdict: passes`.

- [x] **C6**: 8 new blueprint nodes total. L1.tex: 5 new lemma blocks (`lem:l1_isComputableSeqRat_neg` was previously missing — added for completeness; plus 4 new `lem:l1_isComputableSeqReal_{add,neg,bound,mul}`). L2.tex: 3 new lemma blocks (`lem:l2_{sub,smul,mul}_gl`) plus `\uses`-edge refresh on `lem:l2_sum_gl` and `lem:l2_neg_gl` to point at the lifted L1 helpers (replacing references to the now-deleted private `isComputableSeqReal_*` names). All with `\leanok` on both statement and proof + `\lean{...}` links. `leanblueprint checkdecls` → exit 0; `leanblueprint web` → exit 0.

- [x] **C7**: Full `lake build` clean (2533 jobs successful; only pre-existing `push_neg` deprecation warnings on `L4/Instances/CMap.lean`). Axiom audit (via `lake env lean /tmp/axiom_audit_l2_mul_smul_sub.lean`): all 7 new decls (`IsComputableSeqReal.{add,neg,bound,mul}`, `l2_{sub,smul,mul}_gl`) depend on `[propext, Classical.choice, Quot.sound]` only — no `sorryAx`, no new axioms.

- [x] **C8**: `docs/NEXT-SESSION.md` updated for post-round state: L1 row gains the four `IsComputableSeqReal` lemmas in description; L2 row updated to read "7 closures (const, id, sum, neg, sub, smul, mul) sorry-free"; "What just happened" section rewritten for iter-02 through iter-10 of `l2-mul-smul-sub`; round parameters table updated (slug, 10/50 iters); recommended next-round menu now lists (B) `l2-comp-closure` for the deferred composition, (C) `l2-l4-bridge` Equivalence Theorem, (D) `l4-lp-instance`, plus (A) Zulip outreach. Quick handoff axiom-audit list expanded to include the 7 new decls.

## Artifacts produced

- **`ComputableAnalysis/L1/ComputableSeqReal.lean`** (+~250 lines net): §4.5 namespace `IsComputableSeqReal` with 4 new theorems (`add`, `neg`, `bound`, `mul`). First real-valued arithmetic closures at L1; previously only rational-level closures (`IsComputableSeqRat.{add,mul,neg,sub,max,min,abs,comp}`) lived here.
- **`ComputableAnalysis/L2/GrzegorczykLacombe.lean`** (+~225 / −90 lines net): added §4 (`l2_sub_gl`), §5 (`l2_smul_gl`), §6 (`l2_mul_gl`); deleted the two `private` helpers (`isComputableSeqReal_add`, `isComputableSeqReal_neg`) now lifted to L1; rewrote §2 and §3 section headers to point at L1; updated `l2_sum_gl` and `l2_neg_gl` callsites to use L1 dot notation; added `import Mathlib.Topology.ContinuousMap.Compact`.
- **`blueprint/src/L1.tex`** (+5 lemma blocks): `lem:l1_isComputableSeqRat_neg`, `lem:l1_isComputableSeqReal_add`, `lem:l1_isComputableSeqReal_neg`, `lem:l1_isComputableSeqReal_bound`, `lem:l1_isComputableSeqReal_mul`.
- **`blueprint/src/L2.tex`** (+3 lemma blocks, 2 `\uses`-edge refreshes): `lem:l2_sub_gl`, `lem:l2_smul_gl`, `lem:l2_mul_gl`; refreshed edges on `lem:l2_sum_gl` and `lem:l2_neg_gl`.
- **`blueprint/lean_decls`** + **`blueprint/web/**`**: auto-regenerated by `leanblueprint web`.
- **`docs/NEXT-SESSION.md`**: post-round state + next-round menu refreshed.
- **`.goals/l2-mul-smul-sub/`**: `goal.md`, `iter-00.md`, `iter-02.md`…`iter-10.md`, `reviews/{C1,C2,C3,C4,C5}.md`, this `final.md`.

No `claims/l2-mul-smul-sub/`, `proofs/l2-mul-smul-sub/`, `intuition/l2-mul-smul-sub.md`, or `thinking/l2-mul-smul-sub/` artifacts were created — this was a textbook-formalization round (per `CLAUDE.md` "lean-first by default" workflow). The Lean source + docstrings + blueprint prose collectively serve the role those artifacts would play in an open-research round.

## Devil's-advocate verdicts

| Criterion | Artifact(s) | Verdict | Notes |
|---|---|---|---|
| C1 | `IsComputableSeqReal.add` lift | `passes` | Mathlib symbol-existence verified (`Computable.succ`, `Computable.snd`, `pow_le_pow_right₀`, `div_le_div_iff₀`, `abs_add_le`); modulus `N+1` shift confirmed tight; cast-distribution step audited |
| C2 | `IsComputableSeqReal.neg` lift | `passes` | Modulus invariance under `abs_neg` confirmed (`e := p.2` is the minimal sound modulus); proof body essentially the prior round's private helper with namespace+visibility change |
| C3 | `l2_sub_gl` | `passes` | Two-line corollary; `sub_eq_add_neg` on `C(X, ℝ)` `AddGroup` instance verified; no diamond on `Sub` instance |
| C4 | `l2_smul_gl` + `IsComputableSeqReal.{bound, mul}` | `passes` | Joint review across 3 artifacts; bound chain on `mul` (`Ma + Mb + 1`-style modulus via `Nat.lt_two_pow_self`) audited; smul modulus `df(N + Mc 0)` confirmed sound; `ContinuousMap.smul_apply + smul_eq_mul` chain verified |
| C5 | `l2_mul_gl` | `passes` | `ContinuousMap.norm` boundedness via `compactSpace_Icc` verified; cross-term modulus design `df(N+1+M_g) * dg(N+1+M_f)` shown to absorb each `M / 2^(N+1+M) ≤ 1/2^(N+1)` via `Nat.lt_two_pow_self`'s `M ≤ 2^M`; empty-interval edge case verified vacuously sound |

No `unsound` verdicts. No criterion required revision after its terminal DA pass. C4 DA flagged 6 non-blocking style notes but no correctness issues.

## Key findings

- **`IsComputableSeqReal` arithmetic closure is now first-class at L1.** The four new theorems (`.add`, `.neg`, `.bound`, `.mul`) complete the parallel between `IsComputableSeqRat` (which had `.add, .mul, .neg, .sub, .max, .min, .abs, .comp` already) and `IsComputableSeqReal` for downstream layers. Other rounds that previously had to inline rational-witness arithmetic can now consume L1 dot notation.

- **`IsComputableSeqReal.bound` is the foundational helper for any sequence-magnitude argument.** From a `IsComputableSeqReal y` it extracts a `Computable M : ℕ → ℕ` with `∀ n, |y n| ≤ M n`. The construction is: evaluate the rational-witness `(a_w, b_w)` at `Nat.pair n 0`; this gives an approximation to `y n` with error `≤ 1`; bound `|y n| ≤ |ry(n,0)| + 1 = a_w/b_w + 1 ≤ a_w + 1 ≤ a_w + b_w + 1`. Computability of `M` follows from the chain `Primrec.nat_add.to_comp.comp` on `a_w`, `b_w`, and the pairing. This template will recur in any future `IsComputableSeqReal` × scalar / `IsComputableSeqReal` × `IsComputableSeqReal` operation.

- **`Nat.lt_two_pow_self : ∀ n, n < 2^n` is the universal modulus-amplification primitive.** Used three times in this round: `.mul`'s `Ma + Mb + 1 ≤ 2^(Ma + Mb + 1)`, `l2_smul_gl`'s `Mc 0 ≤ 2^(Mc 0)`, `l2_mul_gl`'s `M_f ≤ 2^M_f` and `M_g ≤ 2^M_g`. The pattern: an additive `+ Nat-bound` shift in a modulus exponent absorbs a multiplicative `Nat-bound · ...` factor in the bound-chain numerator, because `Nat-bound ≤ 2^Nat-bound`.

- **Additive-vs-multiplicative modulus shapes.** The criterion text for `l2_smul_gl` suggested `df (⌈|c|⌉.toNat · 2^N + 1)` (multiplicative) and for `l2_mul_gl` suggested `max(df (⌈M_g⌉ · 2^(N+1)) , dg (⌈M_f⌉ · 2^(N+1)))` (max-of-multiplicative). The implementation instead used **additive shifts** (`df(N + M)`, `df(N+1+M_g) * dg(N+1+M_f)`) which are cleaner and equally tight (the spec was indicative, not prescriptive). The additive form avoids needing `Computable.nat_pow` (which doesn't exist by that name per `docs/PITFALLS.md §1`); the multiplicative form would have required either `Computable.nat_rec` inlining or a separate L1 helper.

- **`ContinuousMap.norm` on compact-interval subtypes works automatically.** `CompactSpace ↥(Set.Icc α β)` is inferable via the chain `compactSpace_Icc ← CompactIccSpace ℝ` (instances). Then `‖f‖` is in scope and `f.norm_coe_le_norm x : ‖f x‖ ≤ ‖f‖` gives the uniform pointwise bound. For ℝ-codomain, `‖f x‖ = |f x|` via `Real.norm_eq_abs`. The empty interval (`α > β`) gives `‖f‖ = 0` (empty iSup) and the bound holds vacuously since no `x : ↥(Set.Icc α β)` exists.

- **`import Mathlib.Topology.ContinuousMap.Compact` is the right place** for the `Norm C(α, β)` instance when `α` is compact. The Algebra import alone provides `Add`/`Mul`/`Neg`/`Sub` but not `Norm`. The Compact import expanded the build graph from 1992 to 2066 jobs in incremental builds.

- **Two-line corollary pattern**: `l2_sub_gl` shows that once `sum` and `neg` are in place, `sub` is one `rw [sub_eq_add_neg]` away. This pattern generalizes — any group-axiom rewrite reduces a derived operation to its primitives.

- **`l2_neg_gl` callsite cleanup (non-blocking, deferred).** Both DA-C1 and DA-C2 flagged that the `funext + show + rfl` `h_eq` bridge in `l2_sum_gl` / `l2_neg_gl` (which converts `(fun n => (f + g) (x n))` to `(fun n => f (x n)) + (fun n => g (x n))`) is now redundant after the lift — `h_f.add h_g` / `h_f.neg` produce a result def-equal to the goal via `Pi.add_apply` / `Pi.neg_apply`. Could be elided in a future cleanup pass.

## Open questions

1. **`l2_comp_gl` — composition closure.** The deferred piece from the Conservative scope. Needs encoding GL-computability for inner maps with range-as-subtype: `g : C(Set.Icc γ δ, Set.Icc α β)`. The subtype codomain makes the sequential clause non-trivial — what does it mean for `g`'s output sequence to be "computable" when its values live in a subtype rather than a free type? Two candidate answers: (a) require `IsComputableSeqReal (fun n => (g (x n) : ℝ))` for any computable `x` (similar to `l2_id_gl`'s coordinate inclusion); (b) require it for input sequences valued in `Set.Icc γ δ`. Both unfold to similar concrete content but the formal statement matters.

2. **L2 → L4 Equivalence Theorem** (P-R Ch. 0 §7). `IsGLComputable f ↔ IsComputableSeqCMap (fun _ => f)`. The conceptual capstone bridging Def-A (sequential modulus) to Def-B (polynomial approximation). The forward direction likely uses Stone-Weierstrass machinery already built in `l4-cmap-axiom*` rounds; the reverse needs the modulus-of-uniform-continuity extraction. ~15-25 iters estimated.

3. **`IsComputableSeqReal.bound` tightening (non-blocking).** The current bound `M n := a_w + b_w + 1` is somewhat loose — `a_w + 1` would suffice (since `a_w/b_w ≤ a_w` for `b_w ≥ 1`). The DA-C4 review noted this as a non-blocking style observation. Worth tightening if the L1 surface ever needs to be a "best-effort minimal Nat bound" for some downstream use.

4. **Mul-modulus tightening.** The current `e(n,N) := N + Ma n + Mb n + 1` is loose-by-one: each `Ma + 1` and `Mb` term contributes `(Ma + 1) + Mb = Ma + Mb + 1` to the numerator, and `Nat.lt_two_pow_self` already gives slack. A tighter `e(n,N) := N + max(Ma n, Mb n) + 1` might work but requires more careful bound-chain analysis.

5. **Possible `IsComputableSeqReal.sub`.** Symmetric to `IsComputableSeqRat.sub`. Would be a `.add + .neg` corollary. Not in scope for this round but a natural completion.

## Next-step recommendations

1. **Zulip outreach** (~30 min). Now strictly stronger than the prior round's recommendation: L2 has 7 arithmetic closures fully sorry-free, plus 4 new L1-level real-arithmetic primitives, plus the existing L0/L1/L3/L4-C[a,b] foundation. The 3-paragraph note per `docs/NEXT-SESSION.md` Option A. User posts; record under `docs/zulip-threads.md`.

2. **`/goal l2-comp-closure`** (~10-15 iters). Open the composition closure round. The genuinely-deferred piece from the Conservative scope. The L2 arithmetic surface is otherwise complete after this.

3. **`/goal l2-l4-bridge`** (~15-25 iters). Equivalence Theorem (P-R Ch. 0 §7). Highest research-quality payoff — bridges L2 Def-A to L4 Def-B and unlocks downstream uses of L4 `CMap` instances at L2-level call sites.

4. **`/goal l4-lp-instance`** (~15-25 iters). Lᵖ `ComputabilityStructure`. Significantly harder than C[a,b] (Weierstrass approximation doesn't carry over). Best attempted after either (2) or (3).
