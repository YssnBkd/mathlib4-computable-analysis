# iter-02 orientation — L4 A1 (`axiom_linearity`)

> Scratch note. Not a claim. Records iter-02's findings; informs iter-03's plan.

## C1 status

`cd formal && lake build` → 0 errors, 1 sorry-warning at `L4/Instances/CMap.lean:104:23`.
This is the L4 instance, grouping A1/A2/A3 theorem-body sorries. **C1 satisfied
modulo the A1 sorry going away** (which is C2's job; C1 will still pass with
A2/A3 sorries because the warning is at the *instance* level, single line).

## Exact obligation

From `formal/ComputableAnalysis/L3/ComputabilityStructure.lean:120-127`:

```lean
axiom_linearity :
  ∀ (x y : ℕ → E) (α β : ℕ × ℕ → 𝕜) (d : ℕ → ℕ),
    IsComputableSeq x → IsComputableSeq y →
    ScalarComputableSeq.IsComputableSeq (fun n => α (Nat.unpair n)) →
    ScalarComputableSeq.IsComputableSeq (fun n => β (Nat.unpair n)) →
    Computable d →
    IsComputableSeq
      (fun n => ∑ k ∈ Finset.range (d n + 1), (α (n, k) • x k + β (n, k) • y k))
```

Specialized to `𝕜 = ℝ`, `E = C(Set.Icc α₀ β₀, ℝ)`, `IsComputableSeq = IsComputableSeqCMap`:

- **Given**:
  - `x, y : ℕ → C[α₀,β₀]` with `IsComputableSeqCMap x`, `IsComputableSeqCMap y`
    — i.e. polynomial-approximation witnesses `(aˣ : ℕ×ℕ×ℕ → ℚ, dˣ : ℕ×ℕ → ℕ)`
    and `(aʸ, dʸ)` satisfying `‖x k − polyApprox aˣ dˣ k m‖ ≤ 2⁻ᵐ`, ditto y.
  - `α, β : ℕ×ℕ → ℝ` with the `(fun n ↦ α (Nat.unpair n))` (and β) in
    `IsComputableSeqReal` — i.e. there are rational double-sequences
    `αRat, βRat : ℕ × ℕ → ℚ` (each itself in `IsComputableSeqRat` after
    flattening) with `|αRat (n', m) − α (Nat.unpair n')| ≤ 2⁻ᵐ` and similarly β.
  - `d : ℕ → ℕ` `Computable`.
- **Show**: the sequence
  `s n := Σ_{k ∈ range (d n + 1)} (α (n, k) • x k + β (n, k) • y k)`
  is in `IsComputableSeqCMap` — i.e. construct rational triple-sequence `aˢ`,
  recursive `dˢ`, both witnessing
  `‖s n − polyApprox aˢ dˢ n m‖ ≤ 2⁻ᵐ`.

## Candidate construction (paper-level)

Set the precision pad `m' := m + M` for some `M : ℕ` chosen below. Define

- `dˢ (n, m) := max_{k ∈ range (d n + 1)} max (dˣ (k, m'), dʸ (k, m'))`
- `aˢ (n, m, j) := Σ_{k ∈ range (d n + 1)}
    (αRat (Nat.pair n k, m') · aˣ (k, m', j)
     + βRat (Nat.pair n k, m') · aʸ (k, m', j))`
  with the convention that `aˣ (k, m', j) = 0` whenever `j > dˣ (k, m')` (zero-pad).

Triangle inequality (paper form, sup-norm over `[α₀, β₀]`):

```
‖s n − polyApprox aˢ dˢ n m‖
  ≤ Σ_k ‖α (n,k) • x k − αRat (·,m') • polyApprox aˣ dˣ k m'‖
   + Σ_k ‖β (n,k) • y k − βRat (·,m') • polyApprox aʸ dʸ k m'‖
  ≤ Σ_k (|α (n,k) − αRat| · ‖x k‖ + |αRat| · ‖x k − polyApprox aˣ dˣ k m'‖)
   + ...
  ≤ 2 · (d n + 1) · (B · 2⁻ᵐ' + B' · 2⁻ᵐ')
  ≤ 2⁻ᵐ          [pick m' = m + log₂(4·(d n + 1)·max(B, B')) + 1]
```

where `B`-style bounds come from the polynomial witnesses themselves (the
first-precision-1 approximant `polyApprox aˣ dˣ k 0` is sup-norm-bounded and
its bound is computable from the rational coefficients on `[α₀, β₀]`).

**This is the part P-R Ch. 2:128–129 says is "trivial":** under the G-L
predicate the bound `B` is bundled into the witness data; under the
polynomial-approximation form (Ch. 2:141), `B` arises from
`‖polyApprox aˣ dˣ k 0‖ + 1`, which is a rational quantity over the bounds
`α₀, β₀, |aˣ(k, 0, j)|, dˣ(k, 0)`.

## Obstruction discovered iter-02 — L1 closure lemmas not in scope

`formal/ComputableAnalysis/L1/ComputableSeqReal.lean:56-64` (the "What this
file is NOT" section) explicitly lists:

> Out of scope (deferred to downstream L1 milestones):
> - Closure of `IsComputableSeqReal` under arithmetic (sum, product, …)

The A1 proof's coefficient construction uses:

1. **Rational-sequence sum closure**: `aˢ` is a finite sum of products of
   rational sequences. To prove `aˢ ∈ IsComputableSeqRat`, we need
   `IsComputableSeqRat`-closure under (a) finite sums, (b) products.
2. **Rational-sequence reindex closure**: `aˢ` evaluates `αRat` and
   `aˣ` at composed `Computable` indices (`Nat.pair n k`, etc.) — need
   `IsComputableSeqRat`-closure under recursive reindexing.

These are absent in L1. Adding them to L1 is the cleanest path — but the
round's `allow_writes` excludes `formal/ComputableAnalysis/L1/**`.

## Path forward — three options for iter-03

### Option A — inline helpers in `CMap.lean` (no frame change)

Add the needed `IsComputableSeqRat`-closure helpers as `private theorem`s at
the top of `formal/ComputableAnalysis/L4/Instances/CMap.lean`, then use them
to close A1. The helpers belong in L1 long-term; the inline location is
documented as temporary with `-- TODO(refactor → L1):` comments.

**Pros**: keeps the round's frame intact; closure helpers are reusable for A2/A3.
**Cons**: ~60–120 lines of closure scaffolding inside an instance file;
slight scope creep beyond the named A1 obligation. Estimated +2 iters of
work.

### Option B — amend allow_writes to include L1, add closures there (frame change)

Edit `current-goal.md` to add `formal/ComputableAnalysis/L1/**` to
`allow_writes`. Ship `IsComputableSeqRat`-closure lemmas in L1 (proper home);
then close A1 using them.

**Pros**: clean architectural placement; closures available for L1's own
deferred milestone (`IsComputableReal`).
**Cons**: round-frame amendment; the original goal was "close A1", not "ship
L1 arithmetic closure + close A1". Expanding scope after the round started.

### Option C — pivot to a different A1 proof strategy (avoid closures)

Restate A1 via a coarser argument that bypasses rational-arithmetic closure.
For instance: prove `s n ∈ IsComputableSeqCMap` by *constructing* a polynomial
approximant whose coefficients use `Computable` arithmetic at the
`ℕ → ℕ` level (working with the sign/num/den triples directly, not through
`ℚ`-arithmetic).

**Pros**: stays within frame; technically possible since `Computable` is closed
under composition + Mathlib's `Computable.add`, etc., at the ℕ level.
**Cons**: harder to express in Lean (ℕ-level rational arithmetic is uglier
than ℚ-level); arguably reproves the closure lemmas anyway, just hidden
inside the A1 proof. Likely 150+ lines.

## Recommendation

**Option A** is best for the round-frame-preservation principle. The inline
helpers are small enough (~60-100 lines for sum/product/reindex closure on
`IsComputableSeqRat`) and reusable for A2/A3 (which the next rounds will fill).
Document each helper with `-- TODO(refactor → L1):` so a later round can lift
them upstream.

## Verbatim citations needed (for C5)

The A1 proof body must thread the following `-- ref:` comments:

- `literature/papers/PourEl-Richards-chapt2.md:66-72` — Axiom 1 statement
  ("Let `{xₙ}` and `{yₙ}` be computable sequences in `X`, …").
- `literature/papers/PourEl-Richards-chapt2.md:128-129` — "trivial to verify
  that Axiom 1 (Linear Forms) holds for 𝒮".
- `literature/papers/PourEl-Richards-chapt2.md:141-150` — polynomial-
  approximation characterization (`pₙₖ = Σ aₙₖⱼ xʲ`, computable triple
  sequence of rationals + recursive `d`).

## Mathlib lemmas to look up (iter-03)

- `Computable.pair`, `Computable.comp`, `Computable.const`, `Computable.max`,
  `Computable.add`, `Computable.mul` (for `Computable d`, `Computable a/b/s`).
- `Computable` interaction with `Finset.range` / `Finset.sum` over `ℕ` —
  whether Mathlib has a "computable finite sum" combinator out of the box.
- `Primcodable ℚ` and how to lift `ℕ → ℕ` computability to `ℕ → ℚ`.
- `Rat.add`, `Rat.mul` formulas in terms of `num`/`den` for the sign-num-den
  reconstruction inside closure lemmas.

## iter-03 plan

1. Add `private theorem isComputableSeqRat_add` (and `_mul`, `_finset_sum`,
   `_reindex`) at the top of `CMap.lean`, each as `private theorem` so they
   don't leak into the public L4 API.
2. Sketch each closure helper's proof — they all follow the same
   destruct-Computable / reconstruct-Computable shape. Lean lines per helper:
   ~15–25. Total: ~80 lines.
3. Use the helpers to build `aˢ` and `dˢ`.
4. Triangle-inequality bound — likely needs an auxiliary
   `polyApprox_norm_le` lemma stating that the polynomial approximants have a
   computable sup-norm bound (just `Σ_j |aₙₖⱼ| · max(|α₀|^j, |β₀|^j)`).
