# iter-02

timestamp: 2026-06-03T11:17:14.234913+00:00
unmet: [C1, C2, C3, C4, C5]
mode: proof-attempt
progress: orientation — re-read iter-03-strategy.md + CMap.lean + L1 closures + L3 axiom_linearity sig + P-R Ch. 2:114-128; located Mathlib `Computable.nat_rec` (Partrec.lean:584) as the lever for `_finsetSum_rat`; locked private-in-CMap.lean scope (L1 forbid_writes) and iter-03–iter-08 trajectory
files_changed: ['.goals/INDEX.md', 'current-goal.md', '.goals/l4-cmap-axiom-linearity-cont/goal.md', '.goals/l4-cmap-axiom-linearity-cont/iter-00.md', '.goals/l4-cmap-axiom-linearity-cont/iter-02.md']

## Orientation findings (from re-reads)

- **`thinking/l4-cmap-axiom-linearity/iter-03-strategy.md`** (load-bearing): paper-form proof of A1 via polynomial-approximation form, with verbatim P-R citations locked at lines 226–245 of the doc. Identifies 4 closure helpers needed: `_add`, `_mul`, `_comp/_reindex`, `_finsetSum`. Lines 209–224's "realistic projection" assumed all 4 needed shipping; now obsolete in a helpful direction — 3 of 4 landed in L1 via the prior round (`l1-arithmetic-closure-and-real`).
- **`ComputableAnalysis/L1/ComputableSeqReal.lean`** (verified): `IsComputableSeqRat.{add, mul, comp}` ship under `namespace IsComputableSeqRat` (lines 159–352), callable as `h₁.add h₂`. `IsComputableDoubleSeqRat r := IsComputableSeqRat (fun n => r (Nat.unpair n))` at line 97.
- **`ComputableAnalysis/L4/Instances/CMap.lean`**: `axiom_linearity := sorry` at line 117 (instance decl at 104, hence the sorry-warning at 104:23). `IsComputableSeqCMap` predicate at lines 91–98 unpacks to `∃ a : ℕ × ℕ × ℕ → ℚ, ∃ d : ℕ × ℕ → ℕ, <triple-flatten of a in IsComputableSeqRat> ∧ Computable d ∧ ∀ n k, ‖f n − polyApproxCMap a d n k‖ ≤ 1/2^k`. `open ComputableAnalysis.L1 ComputableAnalysis.L3` already in scope (line 61).
- **`ComputableAnalysis/L3/ComputabilityStructure.lean`**: A1 statement (lines 120–127) takes 5 hypotheses (`IsComputableSeq x/y`, `ScalarComputableSeq.IsComputableSeq` on α/β-unpair, `Computable d`) and concludes `IsComputableSeq (fun n => ∑ k ∈ Finset.range (d n + 1), (α (n, k) • x k + β (n, k) • y k))`. The scalar instance for `ℝ` defers to `L1.IsComputableSeqReal` (L3:95).
- **`literature/papers/PourEl-Richards-chapt2.md:114-118`** (A1 statement) + **`:128-129`** (G-L predicate satisfies A1 "trivially"). Citations confirmed; will thread into the Lean proof comments.

## Critical gap: `finsetSum` closure on `IsComputableSeqRat`

A1's polynomial witness `aˢ(n, m, j) := Σ_{k=0}^{d n} ( αRat(...,M) · padcoeff_aˣ(k, M, j) + βRat(...,M) · padcoeff_aʸ(k, M, j) )` needs closure of `IsComputableSeqRat` under finite sums over a `Computable`-bounded range. This is helper #4 from the strategy doc, the only remaining gap after the L1 round.

**Scope decision**: ship `finsetSum` as a *private helper in CMap.lean* (`_finsetSum_rat`), NOT in L1. Justification:
- L1 is in `forbid_writes` for this round (per Action 2 of `docs/NEXT-SESSION.md`).
- Mirrors the prior round's pattern: private `_add` helper lived in CMap.lean for one round, then got lifted to L1 by the follow-up L1 round. The L1 lifting of `_finsetSum_rat` is explicitly named as a separate future round (`l1-rat-finsetsum`, 4 iters / 60 min) in NEXT-SESSION.md.
- A private helper in `ComputableAnalysis/L4/Instances/CMap.lean` (which IS in `allow_writes`) avoids any L1 edit while keeping A1's proof concrete.

## Implementation plan for `_finsetSum_rat` (iter-03 deliverable)

**Signature** (target):
```lean
private theorem _finsetSum_rat
    {r : ℕ × ℕ → ℚ} (h : IsComputableDoubleSeqRat r)
    {n : ℕ → ℕ} (hn : Computable n) :
    IsComputableSeqRat (fun k => ∑ j ∈ Finset.range (n k + 1), r (k, j))
```

**Strategy** — direct witness construction at the ℕ-triple level via primitive recursion, avoiding the `Primrec₂.rat_add` wall:

1. Extract `(a_r, b_r, s_r) : ℕ → ℕ` Computable from `h : IsComputableDoubleSeqRat r` (these are the witness functions of `(fun n => r (Nat.unpair n))`).
2. Define an `addFormula : ℕ × ℕ × ℕ → ℕ × ℕ × ℕ → ℕ × ℕ × ℕ` matching L1's `_add`-witness construction (the 4-case dispatch on parity + comparison from `L1/ComputableSeqReal.lean:177-200`).
3. Build the per-k witness triple by `Nat.rec`:
   ```
   absTriple : ℕ → ℕ × ℕ × ℕ :=
     fun k => Nat.rec (motive := fun _ => ℕ × ℕ × ℕ)
       (0, 1, 0)
       (fun j ih => addFormula ih (a_r (Nat.pair k j), b_r (Nat.pair k j), s_r (Nat.pair k j)))
       (n k + 1)
   ```
4. Computability of `absTriple` follows from `Computable.nat_rec` (`Mathlib/Computability/Partrec.lean:584`):
   ```
   nat_rec : Computable f → Computable g → Computable₂ h → 
     Computable (fun a => (f a).rec (g a) (fun y IH => h a (y, IH)))
   ```
   With `α := ℕ`, `σ := ℕ × ℕ × ℕ` (Primcodable via `Primcodable.prod`), `f := (· + 1) ∘ n`, `g := const (0, 1, 0)`, `h := step using addFormula + r-witnesses`.
5. Newly-extracted `(newA, newB, newS) := (absTriple.1, absTriple.2.1, absTriple.2.2)`, each Computable via `Computable.fst`/`.snd`/composition.
6. The rational identity `(∑ j ∈ range (n k + 1), r (k, j)) = (-1)^(newS k) · (newA k / newB k)` is proved by Lean-level induction on the bound `m := n k + 1`, peeling off summands via `Finset.sum_range_succ` and chaining through the per-step `addFormula` identity. The per-step identity is the same 4-case `field_simp`+`push_cast`+`try ring` chain from L1's `_add` proof.

**Estimated lines**: 80–120 (~30 for setup + extraction, ~40 for the nat_rec witness, ~50 for the identity induction).

## Locked iter-03 → iter-08 trajectory

| Iter | Deliverable | Verifier |
|---|---|---|
| 03 | private `_finsetSum_rat` in CMap.lean. | `lake build` green; sorry-warning still at A1 body; new helper compiles. |
| 04 | A1 body draft: destructure 5 hypotheses, define `M`, `dˢ`, `aˢ` formally as Lean terms; route Computable proofs through `_finsetSum_rat` + `IsComputableSeqRat.{add, mul, comp}`. First build will fail on the norm bound; that's expected. | A1 body type-checks down to the norm bound. |
| 05 | Norm bound argument: triangle inequality per strategy doc lines 116–145; precision-pad reasoning. | Norm bound compiles. |
| 06 | Buffer / iterate on bound; possibly factor out auxiliary `private` poly-bound lemmas. | Full A1 compiles; A2/A3 still `sorry`. |
| 07 | Blueprint `\leanok` for `lem:l4_cmap_axiom_linearity`; regenerate `blueprint/lean_decls`; `leanblueprint checkdecls` exits 0. | C4 met. |
| 08 | Claim file C5 (`claims/l4-cmap-axiom-linearity/axiom_linearity.md`); DA round on C2; refresh `docs/NEXT-SESSION.md`. | C5 + C2 DA-cleared; ready for `/goal-end`. |

## Risks

- **Norm bound spillover (iter-05 → iter-06)**: triangle inequality + precision pad arithmetic may need more bookkeeping than 1 iter. **Fallback**: leave a single `sorry` inside A1 body on the bound side; revise C1 wording to "0 sorries except for the bound side of A1"; document in C3.
- **`Computable.nat_rec` on `σ := ℕ × ℕ × ℕ` quirks**: may need explicit `Primcodable` instance or `(Primcodable.prod).prod` chaining. **Fallback**: encode the triple as a single ℕ via `Primcodable.encode/decode`, do `nat_rec` on ℕ, decode back. Adds ~10 lines.
- **L4 `polyApproxCMap`'s `noncomputable` mark**: the polynomial-approximant function on `C(Set.Icc α β, ℝ)` is `noncomputable` (ℝ-arithmetic). This is fine for the *predicate* proofs (we never need to *evaluate* the polynomial computably), but worth flagging if any `decide`/`Decidable` machinery on the polynomial output is invoked. **No mitigation needed** at planning stage; will surface as a build error if it bites.
- **Citation drift**: the strategy doc's verbatim citations reference Ch. 2:66-72 / 128-129 / 141-150 / Ch. 0:203 / Ch. 2:53. All confirmed valid against current literature files. No drift risk identified.

## Next iter (iter-03) entry conditions

The next iter should open by re-reading:
- `ComputableAnalysis/L1/ComputableSeqReal.lean:177-200` (the `_add` witness formula to copy into `addFormula`)
- `Mathlib/Computability/Partrec.lean:584` (the `nat_rec` signature)
- This file (`.goals/l4-cmap-axiom-linearity-cont/iter-02.md`) for the locked plan.

Then implement `_finsetSum_rat` per the strategy above. Single-file check first (`lake env lean ComputableAnalysis/L4/Instances/CMap.lean`) before full `lake build`.
