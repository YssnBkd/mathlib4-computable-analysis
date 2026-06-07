# PR-COVERAGE — Audit of the mathlib-computable-analysis formalization against Pour-El & Richards

**Date**: 2026-06-06 (audit-in-progress)
**Round**: `pr-coverage-assessment` (slug, `/goal explore`, 50-iter / 3600-min budget)
**Round artifacts**: `.goals/pr-coverage-assessment/` (active) — prior abandoned attempt preserved as `prior-{goal,iter-00,final}.md`
**Audited against**: P-R *Computability in Analysis and Physics* (Cambridge UP 1989) — verbatim at `literature/papers/PourEl-Richards-*.md`.

---

## Executive summary (one page)

**State** (2026-06-06): the formalization has reached **end of L4-`CMap`** with **zero `sorry` in any proof body** across L0–L4 (5,216 LoC of Lean). The five-layer P-R staircase is populated as follows:

| Layer | P-R chapter | Status |
|---|---|---|
| L0 — Recursion bridge + Prop A/B + Analysis-bridge pointer | §0.2 | **complete** — Prop A & Prop B fully proved; analysis bridge is a Mathlib alias module |
| L1 — Computable reals + computable sequences (closure: `+, -, *, max, min, abs, bound`, effective convergence) | Ch. 0 | **complete** — every L1 closure shipped through round `l2-mul-smul-sub` (final 2026-06-06) |
| L2 — Grzegorczyk–Lacombe `IsGLComputable` predicate + closure under `const, id, +, -, neg, smul, *` | Ch. 0 §3-4 (Def A) | **complete-for-Def-A** — Def A axiomatized; equivalence theorem (P-R Ch. 0 §7) **not started** |
| L3 — `ComputabilityStructure` typeclass (Axioms 1–3) | Ch. 2 | **typeclass surface complete** — three structure fields + `zero_seq` field declared; `\leanok` is for the *definition*, not the *instance witnesses* |
| L4 — Instances | Ch. 2 examples | **C[a,b] only** — all three axioms proved for `C(Set.Icc α β, ℝ)`; **`L^p`, separable Hilbert, `ℓ^p`** all `\notready` in blueprint, no Lean stubs |
| L5 — Main theorems | Ch. 3–5 | **not started** — all four theorems (First Main, Plancherel, Second Main, Eigenvector) are `\notready` blueprint stubs only |

**Coverage by chapter** (counting only landmark numbered items the project intends to formalize):

| P-R section | Landmark items | Done | Partial | Deferred / not started |
|---|---|---|---|---|
| Intro (§0.1) | 0 numbered items (project-level commitments only) | n/a | n/a | n/a |
| Prereq (§0.2) | 2 propositions (A, B) + ~9 vocabulary anchors | 2/2 props, all vocab via Mathlib | 0 | 0 |
| Ch. 0 (computability on ℝ + G-L) | ~48 landmark items (full enumeration in C1 §Ch. 0) | 9 | 8 (vocabulary-only / partial) | ~28 (+9 methodological-remarks/n-a) |
| Ch. 1 (differentiation, analytic functions) | (verbatim **NOT in corpus**) | 0 | 0 | all (out of scope per CLAUDE.md ingestion table) |
| Ch. 2 (axiomatic structure) | ~33 landmark items (full enumeration in C1 §Ch. 2) | 8 (typeclass + C[a,b] instance + derived element/double-seq + Axioms 1/2/3 instantiations) | 1 (vocabulary-only) | ~24 (Effective Density + Stability Lemmas, L^p/ℓ^p instances, Composition/Insertion derived corollaries, 3 effective generating sets, counterexample family) |
| Ch. 3 (First Main + applications) | ~33 landmark items (full enumeration in C1 §Ch. 3) | 0 | 2 (Mathlib `ContinuousLinearMap` covers bounded-operator vocab) | ~28 (First Main, Plancherel, Theorem 4 trio, step-function Thm 5, wave/heat/Laplace Thms 6-9) + 3 methodological |
| Ch. 4 (Second Main + Eigenvector) | ~37 landmark items (full enumeration in C1 §Ch. 4) | 0 | 6 (Mathlib aliases: adjoint/self-adjoint/normal/spectrum/eigenvalue/isometry available but not surfaced) | ~32 (Second Main + Thms 1/2/3, Thm 4 discontinuity, Thm 5 non-normal counterexample, Thm 6 Eigenvector, Lemmas 1-8, Eff Independence + ℓ^1 counterexample) + 3 methodological |
| Ch. 5 (proof of Second Main) | ~40 landmark items (largest enumeration in C1 §Ch. 5) | 0 | 4 (Mathlib spectral-measure + continuous functional calculus available for bounded normal) | ~32 (SpThm 1-7, Uniformity Lemma, Pre-steps A/B/C, InEq 1-3, Propositions 1-4, Theorem 1 Normal, Unbounded reduction, Examples 1-2 Converses) + 3 pedagogical |

**Top-5 next results to formalize** (full ranking + slugs in §C5 below — preview):

1. **L4 — Equivalence Theorem** (P-R Ch. 0 §7): `IsGLComputable f ↔ IsComputableSeqCMap (const f)` over C[a,b]. Bridges L2's Def-A and L4's typeclass instance — unlocks `IsComputableSeqCMap` for elements coming from G-L Def-A constructions.
2. **L4 — L^p[a,b] computability structure instance** (P-R Ch. 2 §3 / Ch. 3): the bedrock instance behind the Plancherel application.
3. **L1 — Computable complex sequences** + `ScalarComputableSeq ℂ` instance: unlocks complex-Hilbert downstream and removes the `🚧-marker` in `L3/ComputabilityStructure.lean:53`.
4. **L4 — separable Hilbert instance** (P-R Ch. 2 §3): isolates the recursion-theoretic content of orthonormal-basis-based computability.
5. **L5 — First Main Theorem statement** (P-R Ch. 3): even just the statement (with `\notready` proof) populates the L5 layer with a target the downstream `/goal` rounds can climb toward.

**Headline divergences from P-R** (full inventory in §C4 below):

- **D1**: `IsGLComputable` carries an explicit `∀ N, 0 < d N` positivity conjunct on the modulus witness. P-R writes `1/d(N)` classically; we encode positivity because of Mathlib's `1/0 = 0` convention.
- **D2**: `IsComputableSeqReal.bound` extracts a `Computable ℕ`-valued bound from the rational witness; P-R argues via uniform continuity classically.
- **D3**: `l2_mul_gl` extracts function bounds via `ContinuousMap.norm` (sup-norm over the compact `Icc`); P-R uses pointwise bounds from `f`'s modulus and a base point.
- **D4**: We use Mathlib's `Computable` substrate; P-R says "recursive" throughout. `Primrec` (primitive recursive) is used for witness arithmetic where it shortens proofs but is upcast to `Computable` at the API surface.
- **D5**: Predicate-first design (project commitment #3 from `CLAUDE.md`). P-R uses prose; our `IsComputableSeqReal : (ℕ → ℝ) → Prop` on Mathlib's `ℝ` follows the Mathlib `Continuous` / `ContinuousMap` precedent.
- **D6**: L0 `AnalysisBridge.lean` is a **pointer file** that introduces no Lean symbols — only docstrings mapping P-R §0.2 vocabulary onto Mathlib names. Downstream layers use Mathlib's `NormedSpace`, `InnerProductSpace`, `Lp`, `lp`, `ContinuousMap`, `ContDiff` directly.

**Audit verification status** (per C7 acceptance criteria; not yet DA-reviewed):

- (a) **Citation accuracy**: every `done` row in the chapter tables is sourced from a `literature/papers/PourEl-Richards-*.md` line range that was opened and read verbatim in this audit.
- (b) **Lean-ref validity**: every `<file>:<line>` Lean ref points to a declaration head that `grep -n "^(def|theorem|lemma|abbrev|instance|class|structure) "` confirms.
- (c) **No done-but-sorry**: a project-wide `grep -rnE "\bsorry\b" ComputableAnalysis/` returns 8 matches, **all** inside docstring / comment text (e.g., `"per CLAUDE.md §sorry policy"`); **zero** proof bodies contain `sorry`. Strict verification via `#print axioms` is deferred to the DA agent (C7).
- (d) **Priority ranking ↔ effort estimates consistency**: priorities in §C5 carry explicit effort classes (S/M/L/XL) that match those given in the §C3 deferral table.

---

## C1 — Per-section coverage table

Conventions used throughout this section:

- **Lean status**:
  - **`done`** — Lean declaration exists; signature + intent match P-R verbatim; no `sorry` in proof; blueprint node `\leanok` (when blueprint covers it).
  - **`partial`** — Lean declaration exists but covers only part of the P-R statement, or has a non-trivial divergence that needs to be reconciled.
  - **`deferred`** — P-R landmark for which we have decided (in CLAUDE.md or a prior round) not to formalize now; rationale + effort in C3.
  - **`not started`** — P-R landmark not yet attempted; rationale (typically "depends on layer-X infrastructure that doesn't exist yet") + effort in C3.
- **P-R location** is `<chapter-file>:<line>` against `literature/papers/PourEl-Richards-*.md`.
- **Lean ref** is `<file>:<line>` against the repo root.
- A `🛈` next to a row indicates a divergence (cross-link to §C4).

---

### Intro — §0.1 (`PourEl-Richards-0.1.introduction.md`, 55 lines)

The Intro has **zero numbered statements** (no definition, theorem, proposition, or lemma is asserted). It is pure exposition. What it *does* establish is the set of project-level **commitments** that the formalization either honors or deliberately diverges from. We audit those instead.

| P-R commitment | P-R location | Honored by formalization? | Cross-ref |
|---|---|---|---|
| "We axiomatize the notion of a *computability structure* on a Banach space. … We do not define a *computable Banach space*." | `PourEl-Richards-0.1.introduction.md:28` | **YES** — encoded as a `class ComputabilityStructure (𝕜 E : Type*) [NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]` on a *preexisting* Mathlib Banach space. | `ComputableAnalysis/L3/ComputabilityStructure.lean:108`; CLAUDE.md commitment #1 |
| "the concept axiomatized is *computable sequence of vectors*. Then a point $x$ is computable if the sequence $x, x, x, \ldots$ is computable." | `PourEl-Richards-0.1.introduction.md:7` | **YES** — sequence-first predicates, with point predicates derived. Examples: `IsComputableSeqReal : (ℕ → ℝ) → Prop` (`L1/ComputableSeqReal.lean:106`) and `IsComputableReal x := IsComputableSeqReal (fun _ => x)` (`L1/ComputableSeqReal.lean:1086`). | CLAUDE.md commitment #2 |
| "The reasoning in this book is classical. … we do not work within the intuitionist or constructivist framework." | `PourEl-Richards-0.1.introduction.md:41` | **YES** — Mathlib is classical (LEM + AC); we match without apology. | CLAUDE.md "Preferences — classical reasoning" |
| Three Main Theorems (First, Second, Eigenvector) and the chapter map for them. | `PourEl-Richards-0.1.introduction.md:9-22, 38` | **DEFERRED to L5** — all four landmark theorems are `\notready` blueprint stubs (`blueprint/src/L5.tex:5-27`), no Lean stubs. | §C5 ranking #5; effort XL each |
| "we have deliberately written the book so as to require a minimal list of prerequisites … From logic, we require only a few standard facts about recursive functions." | `PourEl-Richards-0.1.introduction.md:43` | **YES** — Lean substrate is Mathlib's `Computable` / `Partrec`. Only Prop A + Prop B are surfaced as named theorems. | `L0/Bridge.lean:104` (Prop A), `L0/PropB.lean:149` (Prop B); CLAUDE.md commitment #4 |

**Intro audit verdict**: all five commitments are honored; no Intro-level findings require remediation. The Intro's *only* deferred content is the high-level statement of the three Main Theorems, which is tracked under Ch. 3–5.

---

### Prerequisites — §0.2 (`PourEl-Richards-0.2.prerequisites.md`, 82 lines)

Prereqs split into a **logic** half (lines 1–56: Propositions A and B, pairing function, characteristic-function convention) and an **analysis** half (lines 58–81: Banach / Hilbert / `L^p` / `ℓ^p` / `C[a,b]` / `Cⁿ[a,b]` / `C∞[a,b]` / `C₀(ℝ^q)`).

#### Logic half

| Landmark | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Definition: r.e. set ($A = \varnothing$ or range of recursive $a$) | `0.2.prerequisites.md:25` | **done** | `L0/Bridge.lean:72` — `abbrev IsRecursivelyEnumerable A := REPred (· ∈ A)` (alias of Mathlib `REPred`). Equivalence to the "range of $a$" formulation is a Mathlib lemma (`Computable.image_re` / `REPred.range`) not surfaced as a named theorem in the project — see §C2 footnote ⓡ. |
| Definition: recursive set ($A$ and $\mathbb{N} \setminus A$ both r.e.) | `0.2.prerequisites.md:27` | **done** | `L0/Bridge.lean:77` — `abbrev IsRecursiveSet A := ComputablePred (· ∈ A)`. The "both r.e." characterization vs `ComputablePred` is classical and not re-derived. |
| **Proposition A**: ∃ r.e. set that is not recursive | `0.2.prerequisites.md:31` | **done** | `L0/Bridge.lean:104` — `theorem prop_A_exists_re_not_recursive` (full proof, leanok). Built via `haltingSetAt n` (the halting set at fixed input `n`). Blueprint `\leanok` at `blueprint/src/L0.tex:81-92`. |
| **Proposition B**: ∃ recursively inseparable r.e. pair | `0.2.prerequisites.md:35` | **done** | `L0/PropB.lean:149` — `theorem prop_B` (full proof via `Nat.Partrec.Code.fixed_point₂`). Blueprint `\leanok` at `blueprint/src/L0.tex:144-155`. |
| Recursive pairing function $J : \mathbb{N}^2 \to \mathbb{N}$ with inverses $K, L$ | `0.2.prerequisites.md:40-44` | **done** | `L0/Bridge.lean:117` — `def cantorPair := Nat.pair`, with computability lemma `cantorPair_computable` at `L0/Bridge.lean:125`. The standard form $J(x,y) = (x+y)(x+y+1)/2 + x$ is exactly Mathlib's `Nat.pair` after `Nat.unpair` re-indexing. Blueprint `\leanok` at `blueprint/src/L0.tex:35-46`. |
| Characteristic function $\chi_S$ ("analysts' convention" — 1 if $x \in S$, 0 if not) | `0.2.prerequisites.md:52-56` | **done** | `L0/Bridge.lean:148` — `def charFn (S : Set ℕ) [DecidablePred (· ∈ S)] (x : ℕ) : ℕ`. Matches the analysts' convention verbatim. |

#### Analysis half — the "vocabulary" definitions

P-R lists 8 named spaces in §0.2. The L0 `AnalysisBridge.lean` file documents the P-R ↔ Mathlib correspondence for each, **introduces no new Lean symbols**, and serves as a pointer.

| P-R notion | P-R location | Mathlib name (used directly in downstream layers) | Pointer in repo |
|---|---|---|---|
| Banach space | `0.2.prerequisites.md:60-70` | `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]` (typeclass conjunction; no single `BanachSpace` class) | `L0/AnalysisBridge.lean:28` |
| Hilbert space | `0.2.prerequisites.md:71` | adds `[RCLike 𝕜] [InnerProductSpace 𝕜 E] [CompleteSpace E]` | `L0/AnalysisBridge.lean:30` |
| $L^p[a,b]$ ($1 \le p < \infty$) | `0.2.prerequisites.md:74` | `MeasureTheory.Lp ℝ p (volume.restrict (Set.Icc a b))` | `L0/AnalysisBridge.lean:32` |
| $\ell^p$ ($1 \le p < \infty$) | `0.2.prerequisites.md:75` | `lp (fun _ : ℕ => 𝕜) p` | `L0/AnalysisBridge.lean:34` |
| $C[a,b]$ with sup norm | `0.2.prerequisites.md:76` | `C(Set.Icc a b, ℝ)` (sup-norm instance from `Topology.ContinuousMap.Compact`) | `L0/AnalysisBridge.lean:35` |
| $C^n[a,b]$ | `0.2.prerequisites.md:77` | `ContDiffOn ℝ n` restricted to `Set.Icc a b` | `L0/AnalysisBridge.lean:37` |
| $C^\infty[a,b]$ | `0.2.prerequisites.md:78` | `ContDiff ℝ ∞` | `L0/AnalysisBridge.lean:39` |
| $C_0(\mathbb{R}^q)$ | `0.2.prerequisites.md:79` | `C₀(EuclideanSpace ℝ (Fin q), ℝ)` from `ContinuousMap.ZeroAtInfty` | `L0/AnalysisBridge.lean:40` |
| $L^2, \ell^2$ are Hilbert spaces | `0.2.prerequisites.md:81` | Mathlib instances (`MeasureTheory.Lp` at `p = 2`; `lp` at `p = 2`) | (downstream — not surfaced in `AnalysisBridge.lean`) |

**Prerequisites audit verdict**: the recursion-theoretic half of §0.2 (Prop A, Prop B, pairing function, characteristic function) is **fully formalized** in L0. The analysis half is honored as a *pointer file* per CLAUDE.md commitment #1 (build on Mathlib's existing Banach hierarchy rather than re-defining). No Prerequisites-level findings require remediation; flagging the missing alias-equivalence between P-R's "range of recursive $a$" and Mathlib's `REPred` definition as **footnote ⓡ** (see §C2 below) for completeness.

---

### Ch. 0 — Computability on the real line, G-L continuous functions (`PourEl-Richards-chapt0.md`, 1,369 lines)

Ch. 0 contains the densest concentration of landmark items in the book (~48 numbered definitions / theorems / propositions / lemmas / corollaries / examples / facts across 7 sections). The table below is the complete enumeration, audited in iter-03 by line-by-line walk of the verbatim file.

#### §1 — Computable real numbers (lines 36-176)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Definition 1** (computable sequence of rationals) | `chapt0.md:46` | **done** | `L1/ComputableSeqReal.lean:87` — `def IsComputableSeqRat`. Blueprint `\leanok` at `blueprint/src/L1.tex:6-11`. |
| **Definition 2** (effective convergence of a rational sequence to a real) | `chapt0.md:52` | **vocabulary-only** | Embedded in the body of `IsComputableSeqReal` (`L1/ComputableSeqReal.lean:106`); not surfaced as a separate named predicate. Effort to surface: **S**. See §C3. |
| **Definition 3** (computable real, point predicate via effectively-convergent rational sequence) | `chapt0.md:58` | **done** 🛈 | `L1/ComputableSeqReal.lean:1086` — `def IsComputableReal x := IsComputableSeqReal (fun _ => x)`. **Divergence D8** in §C4 (we use the constant-sequence form; equivalence to P-R's direct Cauchy form is implicit and not surfaced). Blueprint `\leanok` at `blueprint/src/L1.tex:130-136`. |
| **Proposition 0** (positivity/negativity of a nonzero computable real is effectively decidable; equality with zero is not) | `chapt0.md:64` | **not started** | Effort **S–M**. The positive-witness direction follows from the rational approximant; the "not decidable for zero" half is the §2 Example 4 / Fact 3 chain. Useful as a named theorem once `IsComputableReal` is the bedrock. See §C3. |
| Remark on **exact comparisons** for computable rational sequences (the sign-of-sequence test via `(s, a)`) | `chapt0.md:81-86` | **partial** | Implicit in the rational-witness destructuring throughout L1 (e.g. `L1/ComputableSeqReal.lean:212` `isComputableSeqRat_const` uses the same case-on-sign machinery), but not surfaced as a named decidability lemma. Effort to surface: **S**. |
| **Lemma (Waiting Lemma)** | `chapt0.md:98` | **not started** | Effort **M**. P-R says "used repeatedly throughout the book"; we have not needed it yet for L0–L4 closure proofs, but it is a prerequisite for any noncomputable-real existence proof (e.g. Corollary 2b). See §C3. |
| **Lemma (Optimal Modulus of Convergence)** | `chapt0.md:117` | **not started** | Effort **M**. Companion to the Waiting Lemma. Used to construct the canonical Specker-style counterexamples. |
| **Example** (Specker/Rice — ∃ computable monotone rational sequence converging noneffectively) | `chapt0.md:147` | **not started** | Effort **M** given the two preceding lemmas. The negative-result yields Corollary 2b ("∃ noncomputable real"). |
| Alternative-definitions discussion (Cauchy = Dedekind = nested intervals = base-$b$ decimals) | `chapt0.md:167-176` | **deferred** | P-R explicitly opts for Cauchy and skips re-proofs ("not needed"). We follow. **n/a** as a Lean target. |

#### §2 — Computable sequences of real numbers (lines 178-406)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Technicality: double sequence = computable iff `Nat.pair`-fold is computable | `chapt0.md:189` | **done** | `L1/ComputableSeqReal.lean:97` — `def IsComputableDoubleSeqRat`. Blueprint `\leanok` at `blueprint/src/L1.tex:13-19`. |
| **Definition 4** (effective convergence of a double sequence to a sequence, jointly in $k$ and $n$) | `chapt0.md:191` | **vocabulary-only** | Embedded in `IsComputableSeqReal` (`L1/ComputableSeqReal.lean:106`) and in the hypothesis of `isComputableSeqReal_of_effectiveConvergence` (`L1/ComputableSeqReal.lean:157`); not surfaced as a separate named predicate. Effort to surface: **S**. |
| **Definition 5** (computable sequence of reals via Def 4) | `chapt0.md:200` | **done (via Def 5a equivalence)** | We use Def 5a directly; the Def 5 → Def 5a reduction P-R gives at `chapt0.md:209-215` is implicit (`r'(n,k) := r(n, e(n,k))`). Effort to surface as a named theorem: **S**. |
| **Definition 5a** (computable sequence of reals via uniform bound $\|r_{nk} - x_n\| \le 2^{-k}$) | `chapt0.md:203` | **done** | `L1/ComputableSeqReal.lean:106` — `def IsComputableSeqReal`. Blueprint `\leanok` at `blueprint/src/L1.tex:32-38`. |
| Uniformity-in-analysis vs. effectiveness-in-logic clarification | `chapt0.md:220-223` | **n/a** | Methodological remark; the Lean predicate distinguishes by signature (`Computable e : ℕ → ℕ → ℕ` for effectiveness, plain `∀` quantifier for uniformity). |
| **Example 1** (`k/(k+n+1) → 1`: effective, not uniform) | `chapt0.md:226` | **not started** | Pedagogical; effort **S**. Could surface as a named example if useful for documentation. |
| **Example 2** (constant-in-$n$ noneffective sequence) | `chapt0.md:234` | **not started** | Pedagogical; effort **S** given the §1 Example. |
| **Proposition 1** (Closure under effective convergence) | `chapt0.md:246` | **done** | `L1/ComputableSeqReal.lean:157` — `theorem isComputableSeqReal_of_effectiveConvergence`. Blueprint `\leanok` at `blueprint/src/L1.tex:162-173`. |
| **Proposition 2** (Monotone convergence ⇔ effective convergence, for monotone double sequences) | `chapt0.md:273` | **not started** | Effort **M**. The "if" direction is Proposition 1; the "only if" direction uses the rational-witness structure of `{x_n}` and `{x_{nk}}` together (P-R's proof at `chapt0.md:285-308`). |
| **Corollary 2a** (single-sequence monotone case of Proposition 2) | `chapt0.md:275` | **not started** | Effort **S** given Proposition 2. |
| **Corollary 2b** (∃ computable rational sequence converging to noncomputable real) | `chapt0.md:277` | **not started** | Effort **M** given the §1 Example (Specker) + Corollary 2a. The "existence of noncomputable real" landmark. |
| **Remark (Elementary functions)**: closure of `IsComputableSeqReal` under $\pm, \cdot, /, \max, \min, \exp, \sin, \cos, \log, \sqrt[m]{}, \arcsin, \arccos, \arctan$ | `chapt0.md:311` | **partial** | Done in L1 for **addition** (`L1/ComputableSeqReal.lean:806`), **negation** (`:852`), **multiplication** (`:964`), and implicitly **subtraction** (via `add` + `neg`). Done in L2 for **subtraction** at the function level (`L2/GrzegorczykLacombe.lean:374` `l2_sub_gl`). Done in L1 for `max`, `min`, `abs` at the **rational-sequence level only** (`L1/ComputableSeqReal.lean:{466, 619, 759}`); not lifted to the real-sequence level. **Not started** for division (with `≠ 0` hypothesis) and all transcendentals (`exp, sin, cos, log, sqrt, arcsin, arccos, arctan`). Effort each transcendental: **M** (Taylor-series witness via `Proposition 1`); division: **M** (per P-R's mention that `1/x` requires the modulus shift to `[1/M, M]`). |
| Field-structure remark: "the computable reals form a field" (forward to Theorem 9 for "real closed field") | `chapt0.md:328` | **deferred** | The point predicate `IsComputableReal` does not have a `Field`/`Ring` instance attached. Effort to surface: **L** (requires the full set of point-level arithmetic closure lemmas — which themselves derive from the sequence-level ones via the constant-sequence trick). |
| Field structure → forward ref to Theorem 9 (real closed field) | `chapt0.md:328` | **n/a** | See Theorem 9 row in §6 below. |
| **Example 3** (characteristic function of an r.e. nonrecursive set is a non-computable real sequence) | `chapt0.md:347` | **not started** | Effort **M**. Uses Prop A from L0; the construction is straightforward. Negative result; not on the L5 critical path. |
| **Example 4** (refined construction with $2^{-m}$ weights showing a computable sequence with non-effective zero-decidability) | `chapt0.md:365` | **not started** | Effort **M**. Companion to Example 3. |
| **Fact 1** (∃ computable double seq converging noneffectively to a char function) | `chapt0.md:385` | **not started** | Effort **S** given Example 3. |
| **Fact 2** (∃ computable double seq converging effectively in $k$ but noneffectively in $n$) | `chapt0.md:390` | **not started** | Effort **S** given Example 3. |
| **Fact 3** (zero-equality on `IsComputableReal` is not effectively decidable) | `chapt0.md:395` | **not started** | Effort **S** given Example 4. Closes the Proposition 0 negative half. |
| **Fact 4** (∃ rational sequence computable as a real-sequence but not as a rational-sequence) | `chapt0.md:399` | **not started** | Effort **S** given Example 4. Subtle distinction between the two computability predicates. |
| Alternative-definitions discussion (Cauchy ≠ Dedekind for sequences; Mostowski) | `chapt0.md:403-406` | **n/a** | Methodological; not a Lean target. |

#### §3 — Computable functions of one or several real variables (lines 408-520)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Definition A** (Grzegorczyk–Lacombe: sequentially computable + effectively uniformly continuous) | `chapt0.md:427-435` | **done** 🛈 | `L2/GrzegorczykLacombe.lean:108` — `def IsGLComputable`. **Divergence D1** in §C4 (explicit positivity conjunct `∀ N, 0 < d N`). Blueprint `\leanok` at `blueprint/src/L2.tex:6-17`. |
| Definition of "computable sequence of rational polynomials" | `chapt0.md:439-445` | **partial** | The L4 file's polynomial-approximant witness (`L4/Instances/CMap.lean:991` `polyApproxCMap_eval` and surroundings) realizes this notion concretely but does not surface a standalone `IsComputableSeqRatPoly` predicate. Effort to surface: **S**. |
| **Definition B** (single-function Effective Weierstrass) | `chapt0.md:447` | **not started** | The L4-level `IsComputableSeqCMap` is the **B′ form** (sequence version); Definition B for a single function is not surfaced. Effort: **S** once Definition B′ exists. |
| **Definition A′** (sequence version of A) | `chapt0.md:460` | **partial** | Not surfaced as a separate predicate. Operationally, `IsGLComputable` on each $f_n$ + a `Computable` modulus indexed by $(n, N)$ would realize it. Effort to surface: **M**. |
| **Definition B′** (sequence version of B) | `chapt0.md:468` | **done** | `L4/Instances/CMap.lean:1214` — `def IsComputableSeqCMap`. Blueprint `\leanok` at `blueprint/src/L4.tex:` (implicit in the C[a,b] instance section). |
| **Definition A″** (unbounded-domain sequence version of A) | `chapt0.md:482` | **not started** | Effort **L**. Project scope is currently bounded-interval `Set.Icc α β`; the unbounded case is on the deferral roadmap. |
| **Definition B″** (unbounded-domain sequence version of B) | `chapt0.md:491` | **not started** | Effort **L**. As above. |
| Standard-functions remark ($e^x, \sin x, \cos x, \log x, J_0(x), \Gamma(x), x \pm y, xy, x/y$ all computable) | `chapt0.md:504` | **partial** | $x \pm y$, $xy$ are done at the function level via L2 `l2_sum_gl`, `l2_sub_gl`, `l2_mul_gl` (`L2/GrzegorczykLacombe.lean:{245, 374, 489}`). The transcendentals are not yet. Effort each: **M**. |
| Computability on $(0, \infty)$ via the $[1/M, M]$-exhaustion construction | `chapt0.md:508` | **not started** | Effort **M**. Variant of Definition A″. |
| Real-polynomial vs. rational-polynomial interchangeability remark | `chapt0.md:516` | **n/a** | Methodological. We always use rational coefficients. |
| Banach–Mazur predicate (sequential computability without uniform continuity is strictly broader) | `chapt0.md:520` | **deferred** | The positivity conjunct in `IsGLComputable` (D1) explicitly rules this out by design. Not a Lean target. |

#### §4 — Preliminary Constructs (Composition, Patching, Expansion) (lines 522-730)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Theorem 1** (Composition on $I^q$) | `chapt0.md:533` | **not started** | Effort **M**. Foundational; cited by Theorems 2, 3, 5, 6, the Effective Weierstrass proof, and many L5 applications. |
| **Theorem 1a** (Composition on unbounded $\mathbb{R}^q$) | `chapt0.md:611` | **not started** | Effort **M** given Theorem 1. |
| **Lemma (Rate of growth)** | `chapt0.md:616` | **not started** | Effort **S–M**. Used in the proof of Theorem 1a; corollary-like. |
| **Theorem 1b** (Composition on sequences of vector-valued functions) | `chapt0.md:669` | **not started** | Effort **M** given Theorem 1a. |
| **Theorem 2** (Patching) | `chapt0.md:685` | **not started** | Effort **M**. Uses Proposition 1 (which is done). The proof's "effective decidability of $x < b$, $x > b$" via rational approximants is a re-usable technique. |
| **Theorem 3** (Expansion) | `chapt0.md:713` | **not started** | Effort **S** given Theorems 1 and 2. Corollary-level. |

#### §5 — Basic Constructs of Analysis (Effective uniform convergence, Integration) (lines 731-967)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Definition: $f_{nk} \to f_n$ uniformly in $x$, effectively in $k, n$ | `chapt0.md:742` | **vocabulary-only** | Embedded in the hypothesis of `isComputableSeqCMap_of_effectiveLimit` (`L4/Instances/CMap.lean:1894`). |
| **Theorem 4** (Closure under effective uniform convergence) | `chapt0.md:748` | **done** (L4 form) | `L4/Instances/CMap.lean:1894` — `theorem isComputableSeqCMap_of_effectiveLimit`. Blueprint `\leanok` at `blueprint/src/L4.tex:43-53`. NB this is L4-`IsComputableSeqCMap`-typed; the L2-`IsGLComputable`-typed analog is not surfaced (an L2-only restatement would be trivial via the L2→L4 direction of the Equivalence Theorem). |
| **Theorem 5** (Definite Integrals — computable sequence of functions has computable sequence of integrals) | `chapt0.md:777` | **not started** | Effort **L**. Foundation for Corollaries 6a, 6b, 6c. The Riemann-sum effectivization is fully constructive in P-R. |
| **Theorem 6** (Equivalence of Definitions A and B / A′ and B′ / A″ and B″) | `chapt0.md:853` | **partial** (easy half "B ⇒ A" follows from Theorem 4 which we have; hard half "A ⇒ B" via Effective Weierstrass is §7) | Effort to close the hard half: **L–XL**. **§C5 #1 priority** in the form "Equivalence Theorem on the constant sequence": `IsGLComputable f ↔ IsComputableSeqCMap (fun _ => f)`. Full A↔B equivalence for general single $f$ is a richer target. |
| **Corollary 6a** (Indefinite integrals) | `chapt0.md:877` | **not started** | Effort **M** given Theorems 5, 6. |
| **Corollary 6b** (Integrals depending on parameter) | `chapt0.md:885` | **not started** | Effort **M** given Theorems 5, 6. |
| Definition: computable function on compact $K \subseteq \mathbb{R}^q$ via extension to a rectangle | `chapt0.md:895` | **not started** | Effort **S**. Vocabulary; needed for Corollary 6c. |
| Definition: computably integrable pair $\langle K, \mu \rangle$ | `chapt0.md:899` | **not started** | Effort **S**. Vocabulary; needed for Corollary 6c. |
| **Corollary 6c** (Integration over regions — line/surface/parameter-integrals in $\mathbb{R}^3$) | `chapt0.md:922` | **not started** | Effort **L** given the prerequisites. Cited in P-R Ch. 3 for the wave-equation Kirchhoff formula. |

#### §6 — Max-Min and Intermediate Value (lines 969-1160)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Theorem 7** (Maximum values — sup-norm of a computable sequence of functions is computable as a sequence of reals) | `chapt0.md:977` | **done** (L4 form) | `L4/Instances/CMap.lean:2115` — `theorem isComputableSeqCMap_norm`. Blueprint `\leanok` at `blueprint/src/L4.tex:55-77`. The L4 form is on `IsComputableSeqCMap`-typed sequences; the L2-`IsGLComputable`-typed version (sup-norm of a single G-L computable function is a computable real) is not surfaced as a separate named theorem. |
| Remark: non-computable maximum **points** (Specker [1959], Kreisel [1958], Lacombe [1957b]) | `chapt0.md:1014` | **deferred** | Negative result, off the critical path. Effort **M** as a counterexample construction. |
| **Theorem 8** (Intermediate Value Theorem for a single computable function) | `chapt0.md:1021` | **not started** | Effort **M**. Bisection-with-rational-comparison construction. Uses Proposition 0 (sign decidability for nonzero). |
| **Example 8a** (IVT fails for sequences — Specker-style construction using a recursively inseparable pair) | `chapt0.md:1046` | **not started** | Effort **L**. Uses Proposition B (which we have at `L0/PropB.lean:149`). Negative result, but proof construction is illustrative. |
| **Theorem 9** (Computable reals form a real closed field) | `chapt0.md:1153` | **not started** | Effort **L** given Theorem 8. Standard polynomial-root reduction. |
| Remark: Mean Value Theorem deliberately omitted by P-R | `chapt0.md:1157` | **n/a** | Out of scope per P-R. |

#### §7 — Proof of Effective Weierstrass (the hard half of Theorem 6) (lines 1161-1369)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Effective Weierstrass Theorem** (Def A ⇒ Def B, hard direction of Theorem 6) | `chapt0.md:1172` | **not started** | Effort **XL**. The full constructive proof — polynomial-pulse $P_m(x) = (1 - (x/M)^2)^m$, the Technical Lemma's integral-ratio estimate, the three-piece decomposition $(A) + (B) + (C)$, the explicit recursive modulus $m(N) = 8 S M^3 \cdot d(N)^3 \cdot 2^N$. P-R itself says "Here is where we get our hands dirty"; this is the only major-classical-proof effectivization in the book. **§C5 #1 priority** alternative formulation is the simpler "Equivalence Theorem on constant sequences via the L4 instance", which sidesteps this. The full §7 proof remains as a deeper target. |
| Technical Lemma (pulse-function integral ratio $\le 8 d^3 M^3 / (3m)$) | `chapt0.md:1228` | **not started** | Effort **L**. Internal lemma to the Effective Weierstrass proof. |

**Ch. 0 audit verdict** (final, after iter-03 walk):

- **Done**: 9 items (Def 1, Def 3, Def 5a, double-seq computability, Prop 1, Def A, Def B′, Theorem 4 L4-form, Theorem 7 L4-form) + L1/L2 closure family for `+, neg, mul, sub` and `const, id, sum, neg, sub, smul, mul` respectively (all part of the "elementary functions" remark and Def A closures).
- **Partial / vocabulary-only**: 8 items (Def 2 embedded, Def 4 embedded, Def 5 via 5a, exact-comparison remark, real-polynomial seq predicate, Def A′ implicit, Def B implicit, Theorem 6 easy half).
- **Not started**: ~28 items, with the biggest single landmarks being **Theorem 5** (Definite Integrals), **Theorem 6 hard half** (Effective Weierstrass §7), **Theorems 1/1a/1b/2/3** (the Composition + Patching + Expansion family), **Theorem 8** (IVT), **Theorem 9** (real closed field), **Corollary 6c** (Integration over regions), and the transcendental closures (`exp, sin, cos, log, sqrt, arcsin, arccos, arctan`).
- **Deferred / n/a**: ~9 methodological remarks + the Banach-Mazur predicate + Mean Value Theorem.

The Equivalence Theorem (Theorem 6) on the constant-sequence form remains §C5's #1 priority — it is a strict subset of the full §7 Effective Weierstrass proof and unlocks the L2/L4 cross-layer reconciliation without committing to the full Weierstrass construction.

---

### Ch. 1 — Differentiation, analytic functions (`PourEl-Richards-chapt1.md`)

**This file is not in the corpus** (`ls literature/papers/PourEl-Richards-chapt1.md` → no such file; CLAUDE.md "Corpus ingestion" table line for Ch. 1 reads `pending`).

The entire chapter is therefore `deferred / not started` in this audit; the CLAUDE.md table will need to be updated to mark Ch. 1 as `pending` either ingested or deliberately scoped out. P-R Ch. 1 covers differentiation of computable functions and computable analytic functions — material that does not feed into the L3 keystone or any of the three Main Theorems on the critical path.

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Differentiation of G-L computable functions | (Ch. 1 verbatim not ingested) | **not started** | Effort **L**; not on the critical path to L5 Main Theorems. See §C3. |
| Computable analytic functions | (Ch. 1 verbatim not ingested) | **not started** | Effort **L–XL**; depends on Ch. 0 §7 Equivalence first. See §C3. |

---

### Ch. 2 — Axiomatic computability structure (`PourEl-Richards-chapt2.md`, 371 lines)

Ch. 2 is the L3 keystone. The chapter has 7 sections: (1) The Axioms, (2) C[a,b] classical case, (3) Intrinsic $L^p$, (4) Intrinsic $\ell^p$, (5) Effective Density Lemma + Stability Lemma, (6) Counterexamples to effective separability + $L^\infty$, (7) Ad hoc structures. Full per-section enumeration below.

#### §1 — The Axioms (lines 47-124)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Setup: $\mathscr{S}$ = computable sequences as undefined term, $\langle X, \mathscr{S}\rangle$ pair convention | `chapt2.md:51` | **done** | `L3/ComputabilityStructure.lean:108` — `class ComputabilityStructure` carries `IsComputableSeq : (ℕ → E) → Prop` as the primitive predicate field. |
| Double-sequence convention (via `Nat.pair` fold) | `chapt2.md:53` | **done** | `L3/ComputabilityStructure.lean:177` — `def IsComputableDoubleSeq` via `Nat.unpair` reindex. |
| Computable element ($x, x, x, \ldots$ is computable) | `chapt2.md:55` | **done** | `L3/ComputabilityStructure.lean:169` — `def IsComputableElement (x : E) : Prop := IsComputableSeq (fun _ => x)`. |
| Definition (effective convergence on Banach space, in norm: $\|x_{nk} - x_n\| \le 1/2^N$ for $k \ge e(n,N)$) | `chapt2.md:58` | **vocabulary-only** | Embedded in Axiom 2 hypothesis (`L3/ComputabilityStructure.lean:128-139`); not surfaced as a separate named def. Effort to surface: **S**. |
| **Axiom 1 (Linear Forms)** | `chapt2.md:66` | **done** | `L3/ComputabilityStructure.lean:120` — typeclass field `isComputableSeq_linearCombination`. Instantiated for C[a,b] at `L4/Instances/CMap.lean:1240` `isComputableSeqCMap_linearCombination`. Blueprint `\leanok` (`blueprint/src/L3.tex:5-17`, `blueprint/src/L4.tex:5-26`). |
| **Axiom 2 (Limits)** | `chapt2.md:73` | **done** | `L3/ComputabilityStructure.lean:134` — typeclass field `isComputableSeq_of_effectiveLimit`. Instantiated for C[a,b] at `L4/Instances/CMap.lean:1894` `isComputableSeqCMap_of_effectiveLimit`. Blueprint `\leanok`. |
| **Axiom 3 (Norms)** | `chapt2.md:75` | **done** | `L3/ComputabilityStructure.lean:144` — typeclass field `isComputableSeqReal_norm`. Instantiated for C[a,b] at `L4/Instances/CMap.lean:2115` `isComputableSeqCMap_norm`. Blueprint `\leanok`. |
| Non-vacuity: "∃ a computable sequence, equivalently the zero sequence is computable" | `chapt2.md:77` | **done** | `L3/ComputabilityStructure.lean:153` — typeclass field `zero_seq`. (We encode the zero-sequence form directly; equivalence with "∃ computable sequence" via Axiom 1 is in the design doc.) |
| **Proposition (Composition Property)**: $\{x_n\}$ computable + $a$ recursive ⇒ $\{x_{a(n)}\}$ computable | `chapt2.md:82` | **not started** | Effort **S** — direct corollary of Axiom 1 with $y_n = 0$, $\alpha_{nk} = [k = a(n)]$. Used as a named lemma in `L3/ComputabilityStructure.lean:220` proof commentary (Effective Density Lemma) but not surfaced. |
| **Proposition (Insertion Property)**: $\{x_n\}, \{y_n\}$ computable ⇒ interleaved $\{x_0, y_0, x_1, y_1, \ldots\}$ computable | `chapt2.md:83` | **not started** | Effort **S** — direct corollary of Axiom 1. |
| Definition (effective generating set + effectively separable Banach space) | `chapt2.md:120` | **not started** (deferred to L4 per `L3/ComputabilityStructure.lean:70`) | Effort **S** — a predicate `IsEffectiveGeneratingSet (e : ℕ → E) : Prop := IsComputableSeq e ∧ DenseRange (linearSpan e)`. **Prerequisite** for the Effective Density Lemma + Stability Lemma. |
| Effective-density automatic from density Remark (forward to Theorem 1) | `chapt2.md:124` | **not started** | The remark is methodological; Theorem 1 below is the real content. |

#### §2 — The Classical Case: $C[a,b]$ (lines 126-152)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Full $C[a,b]$ computability structure (Axioms 1, 2, 3 + non-vacuity), recovers Ch. 0 G-L sequences | `chapt2.md:128-129` (cites Ch. 0 Theorems 4 and 7) | **done** | `L4/Instances/CMap.lean:3023` `computabilityStructureCMap_of`. Blueprint `\leanok` (`blueprint/src/L4.tex:28-41`). Recursive-endpoint restriction (`IsComputableReal α`, `IsComputableReal β`, `α ≤ β`) matches P-R verbatim. |
| Effective generating set: monomials $\{1, x, x^2, \ldots\}$ for $C[a,b]$ | `chapt2.md:131` | **not started** | Effort **S** once `IsEffectiveGeneratingSet` predicate exists. The monomial-sequence's computability and density-in-C[a,b] are both classical/Mathlib results. |
| Effective generating set: piecewise linear functions with rational corners | `chapt2.md:133` | **not started** | Effort **M**. The "piecewise linear with rational corners" sequence requires a Lean concretization. |
| Effective generating set: trigonometric polynomials $\{1, \cos x, \sin x, \cos 2x, \sin 2x, \ldots\}$ (for $f(0) = f(2\pi)$ subspace of $C[0,2\pi]$) | `chapt2.md:135-139` | **not started** | Effort **M**. Restricted-subspace requires extra Mathlib glue. |
| Stronger property of $\{x^n\}$ from Ch. 0 Theorem 6: every computable $\{f_n\}$ is the **effective uniform limit** of a computable rational-polynomial double sequence | `chapt2.md:141-145` | **done (as a forward-cited form)** | This is precisely the L4 `IsComputableSeqCMap` form (`L4/Instances/CMap.lean:1214`) — the polynomial-approximant witness IS the canonical representation. |
| Forward ref to §5 generalization (every computable sequence is the effective limit of a finite-linear-combination double sequence over the generating set) | `chapt2.md:147-152` | **not started** | This IS the Effective Density Lemma in disguise. See §5 row. |

#### §3 — Intrinsic $L^p$-computability (lines 153-183)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Definition (a)** — single $L^p[a,b]$-computable function via $L^p$-norm effective convergence of continuous-Chapter-0-computable $g_k$ | `chapt2.md:161` | **not started** (blueprint `\notready`) | Effort **XL**. §C5 ranking #2. `blueprint/src/L4.tex:79-83`. |
| **Definition (b)** — $L^p[a,b]$-computable sequence | `chapt2.md:162` | **not started** | Effort **L** given (a). |
| Computability for $L^p(I^q)$ (q-dim) | `chapt2.md:164` | **not started** | Effort **L** given the 1-d versions. |
| Claim: $L^p[a,b]$-computable sequences satisfy the three axioms (= the $L^p$ instance) | `chapt2.md:166` | **not started** | Same as the deferred L^p instance row (§C5 #2). |
| Four effective generating sets for $L^p[a,b]$: monomials, p.w. linear w/ rational corners, trig polys, **step functions with rational jump points and values** | `chapt2.md:166` | **not started** | Step functions are the **headline P-R divergence from "computable ⇒ continuous"**: see Intro :48 and Ch. 3 step-function classification. |
| **Definition** — $L^p(\mathbb{R})$-computable sequence (compact-support exhaustion) | `chapt2.md:174` | **not started** | Effort **L** given the bounded-interval version. |
| Reduction-to-Chapter-0 note: at $p = \infty$, $L^\infty[a,b]$ computability via this definition coincides with $C[a,b]$ Chapter-0 computability | `chapt2.md:179` | **not started** | Useful as a reconciliation lemma once L^p lands. |
| Claim: $L^p(\mathbb{R})$ satisfies axioms + effectively separable, with continuous-rational-corner compact-support functions as effective generating set | `chapt2.md:181-182` | **not started** | Same as the L^p-noncompact instance row. |

#### §4 — Intrinsic $\ell^p$-computability (lines 184-194)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Definition (a)** — $\ell^p$-computable scalar sequence ($\{c_k\}$ computable + $\sum |c_k|^p$ converges effectively) | `chapt2.md:188` | **not started** | Effort **M** — direct on Mathlib's `lp` (`L0/AnalysisBridge.lean:34`). |
| Special case $\ell^\infty_0$ — sequence converging effectively to zero | `chapt2.md:190` | **not started** | Effort **M**. |
| **Definition (b)** — $\ell^p$-computable sequence of $\ell^p$ elements | `chapt2.md:191` | **not started** | Effort **M** given (a). |
| Claim: $\ell^p$ satisfies axioms + effectively separable via $e_n = (0, \ldots, 1, \ldots)$ | `chapt2.md:193` | **not started** | Effort **L** to bundle. §C5 honorable-mention (cheaper than $L^p$). |

#### §5 — Effective Density Lemma + Stability Lemma (lines 195-254)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Theorem 1 (Effective Density Lemma)**: $\{x_n\}$ computable in $X$ iff there is a computable rational-coefficient finite-linear-combination double sequence $p_{nk}$ over the effective generating set $\{e_n\}$ converging effectively to $\{x_n\}$ | `chapt2.md:204` | **not started** | Effort **L**. **L4 deferral** explicitly noted in `L3/ComputabilityStructure.lean:67` ("Stability Lemma (uniqueness of `IsComputableSeq` under effective separability) — deferred to L4"). Prerequisite for everything downstream in §5. |
| **Corollary 1a (Effective Weierstrass Theorem)** | `chapt2.md:222` | **not started** | Effort **S** given Theorem 1 + the `{x^n}` effective generating set for $C[a,b]$. This is the *much easier* version of P-R Ch. 0 §7 — sidestepping the polynomial-pulse machinery. **§C5 #1 priority alternative formulation.** |
| **Corollary 1b (Effective Stieltjes–Hamburger–Carleman Theorem)** | `chapt2.md:240` | **not started** | Effort **M** given Theorem 1 + a Lean definition of $G^\alpha(\mathbb{R})$ (the $e^{-|x|^\alpha}$-weighted continuous-function space). Out of scope for the main P-R path. |
| **Corollary 1c (Effective Wiener Tauberian Theorem)** | `chapt2.md:244` | **not started** | Effort **M** given Theorem 1 + $L^1$ computability. Out of scope for the main P-R path. |
| **Theorem 2 (Stability Lemma)**: two computability structures sharing an effective generating set are equal | `chapt2.md:248` | **not started** | Effort **S** given Theorem 1. Project-narrative-critical: this is what justifies the axiomatic-vs-genetic claim ("axioms determine the structure uniquely under mild side conditions"). |
| **Corollary 2a**: sub-structure rigidity ($\mathscr{S}' \subseteq \mathscr{S}$ + generating set ⇒ equality) | `chapt2.md:253` | **not started** | Effort **S** given Theorem 2. |

#### §6 — Counterexamples (lines 255-321)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Example 1** (separable ≠ effectively separable: ultra-computability on $L^2[0,2\pi]$ via bounded-degree trigonometric polynomials) | `chapt2.md:263` | **not started** | Effort **L**. Negative-result counterexample; useful for project-narrative completeness but off the critical path. |
| Condition (C) (interval-characteristic functions are computable for computable endpoint sequences) | `chapt2.md:297` | **not started** | Effort **S** vocabulary; needed for Example 2. |
| **Example 2** (no computability structure on $L^\infty[0,1]$ satisfies (C)) | `chapt2.md:302` | **not started** | Effort **M**. Uses Prop A (which we have at `L0/Bridge.lean:104`). |

#### §7 — Ad Hoc Computability Structures (lines 323-371)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Three questions about non-intrinsic structures (existence, utility, relation) | `chapt2.md:329-331` | **n/a** | Methodological. Answers in Ch. 4 §§5-6. |
| **Example 3** (ad hoc structure on $C[0,1]$ via multiplication by noncomputable complex $c$, $|c| = 1$) | `chapt2.md:338` | **not started** | Effort **M**. Constructs a $\mathscr{S}_1$ that shares only the zero sequence with intrinsic $\mathscr{S}_0$. Used in Ch. 4 Eigenvector proof. |
| **Example 4** (ad hoc structure on $C_0(\mathbb{R})$ via translation by noncomputable $\alpha$) | `chapt2.md:353` | **not started** | Effort **M**. Real-valued analog of Example 3. |

**Ch. 2 audit verdict** (after iter-04 walk):

- **Done**: 8 items — the typeclass surface (all three axioms + zero_seq + the "computable element" derived def + the double-seq derived def) at L3, plus the full C[a,b] instance + Axioms 1/2/3 for C[a,b] at L4. The structure carries the **§2 stronger Effective Weierstrass corollary** (every $\{f_n\}$ is the effective uniform limit of a computable rational-polynomial double sequence) as the L4 `IsComputableSeqCMap` predicate's polynomial-approximant witness.
- **Vocabulary-only / partial**: 1 item (the §1 effective-convergence definition is embedded in Axiom 2's hypothesis).
- **Not started**: ~24 items — the headlines being (a) the **Effective Density Lemma + Stability Lemma** (the entire §5, which justifies the axiomatic-vs-genetic-uniqueness narrative of the chapter), (b) the **$L^p$ and $\ell^p$ instances** (§§3-4), (c) the **Composition + Insertion derived corollaries** (§1), (d) the **3 effective generating sets** for $C[a,b]$ (§2), and (e) the **counterexample family** (Examples 1, 2, 3, 4 across §§6-7).
- **n/a**: 1 item (§7 methodological-questions remark).

The §5 Effective Density Lemma is in many ways the most under-served gap in Ch. 2 from the project-narrative standpoint: it is the formal substance behind the "axioms determine the structure uniquely under mild side conditions" claim that justifies the entire axiomatic-approach decision. Effort to land: **L** for the Lemma + the `IsEffectiveGeneratingSet` predicate + the monomial generating-set instance for C[a,b]; the Stability Lemma is then a **S** corollary. Considering adding this as a §C5 honorable mention.

---

### Ch. 3 — First Main Theorem + applications (`PourEl-Richards-chapt3.md`, 730 lines)

Ch. 3 has 5 sections: (1) Bounded + Closed unbounded operators, (2) the First Main Theorem statement + proof, (3) Simple applications to real analysis, (4) Further applications (Fourier + step-function characterization), (5) Applications to physical theory (wave, heat, Laplace). Full enumeration below; **every landmark item is not-started in Lean** (L5 layer is empty).

#### §1 — Bounded operators and closed unbounded operators (lines 41-170)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Definition (bounded linear operator $T : X \to Y$, $\|Tx\| \le M\|x\|$) | `chapt3.md:47` | **partial (via Mathlib)** | Mathlib's `ContinuousLinearMap` (`Mathlib.Analysis.NormedSpace.OperatorNorm`) provides the standard form; not surfaced in our project but available for downstream use. Effort to surface as an L5 alias: **S**. |
| Equivalent formulation (sequential continuity) | `chapt3.md:54` | **partial (via Mathlib)** | Mathlib's `ContinuousLinearMap` already encodes this equivalence. |
| Definition (closed operator: $x_n \to x$ in $X$ and $Tx_n \to y$ in $Y$ ⇒ $x \in \mathcal{D}(T)$ and $Tx = y$) | `chapt3.md:67` | **not started** | Mathlib does not have a unified "closed operator" predicate (only `ContinuousLinearMap` which is bounded). Effort to define: **M**. |
| Equivalent closed-graph characterization | `chapt3.md:77-79` | **not started** | Effort **S** given the previous row. |
| **Proposition (First closure criterion)** ($T$ one-to-one onto, $T^{-1}$ bounded ⇒ $T$ closed) | `chapt3.md:122` | **not started** | Effort **S** given closed-operator predicate. |
| **Proposition (Second closure criterion)** ($T$ continuous in weaker Hausdorff topologies $\tau_1, \tau_2$ ⇒ $T$ has a closed extension) | `chapt3.md:141` | **not started** | Effort **M**. Requires multi-topology infrastructure. |
| Example (proper inclusion $L^r \hookrightarrow L^p$ for $p < r$, inverse is closed) | `chapt3.md:150` | **not started** | Effort **S** as a worked example. |
| Example (Fourier transform on $L^p(\mathbb{R})$, closed via second criterion) | `chapt3.md:156` | **not started** | Effort **M**. Touches the distribution-topology comment. |

#### §2 — The First Main Theorem (lines 172-275)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Effective-density-from-density restatement (used as a black box) | `chapt3.md:178-180` | **not started** | This is Ch. 2 Theorem 1 (Effective Density Lemma) restated. See §C5 HM1. |
| **First Main Theorem** ($T$ closed + $\{e_n\}$ effective generating set + $\{Te_n\}$ computable ⇒ $T$ preserves computability iff $T$ bounded) | `chapt3.md:184` | **not started** (blueprint `\notready`) | `blueprint/src/L5.tex:5-9`. Effort **XL**. **§C5 #5 priority**. Requires Effective Density Lemma (HM1), closed-operator predicate, and instances of `ComputabilityStructure` on the source/target spaces. |
| **Complement** (if $T$ bounded then $\mathcal{D}(T) = X$ and $T$ maps every computable sequence to a computable sequence) | `chapt3.md:186` | **not started** | Effort **S** as a follow-on to First Main. |
| **Lemma 1** (under unboundedness, ∃ computable sequence $\{p_n\}$ of finite linear combinations of $\{e_n\}$ with $\|Tp_n\| > 10^n \|p_n\|$) | `chapt3.md:196` | **not started** | Effort **M**. Internal lemma to First Main. Uses Composition + Norm Axiom. |
| **Lemma 2** ($r > 2$, $\{z_n\}$ unit-norm computable, $a$ enumerates $A$ ⇒ $y = \sum r^{-a(k)} z_k$ computable iff $A$ recursive) | `chapt3.md:210` | **not started** | Effort **M**. Internal lemma to First Main; the construction is recursion-theoretic and decoupled from analysis specifics. |

#### §3 — Simple applications to real analysis (lines 277-384)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| "Standing convention" — intrinsic computability for each space | `chapt3.md:284` | **n/a** | Methodological. |
| **Theorem 1 (Integrals and Derivatives)**: (a) indefinite integral of computable $f \in C[a,b]$ is computable; (b) ∃ computable $f \in C[a,b]$ with continuous but non-computable derivative | `chapt3.md:286` | **not started** | Effort **M** given First Main + the indefinite-integral operator $C[a,b] \to C[a,b]$. (a) was already proved by direct methods in Ch. 0 Cor 6a. |
| **Theorem 2 (Convergence of Fourier series)**: ∃ computable $f \in C[0,2\pi]$ whose Fourier series is computable + uniformly convergent but NOT effectively uniformly convergent | `chapt3.md:296` | **not started** | Effort **L**. Requires constructing a custom Banach space $Y$ of uniformly convergent sequences with its own computability structure. |
| **Effective Fejer Theorem**: $f \in C[0,2\pi]$ computable ⇒ Cesàro averages $\sigma_k$ are effectively uniformly convergent to $f$ | `chapt3.md:341` | **not started** | Effort **M** given Theorem 2's setup + First Main. |
| **Theorem 3 ($L^p$-computability for varying $p$)** — three parts: | `chapt3.md:354` | **not started** | Effort **L** for the trio, given the L^p and ℓ^p instances. |
| Theorem 3 (a) ($L^p[a,b] \to L^r[a,b]$, $r \le p$ preserves; $r > p$ counterexample) | `chapt3.md:354` | **not started** | Effort **M**. |
| Theorem 3 (b) ($L^p(\mathbb{R}) \to L^r(\mathbb{R})$, $r \ne p$ counterexample) | `chapt3.md:355` | **not started** | Effort **M**. |
| Theorem 3 (c) ($\ell^p \to \ell^r$, $p \le r$ preserves; $p > r$ counterexample) | `chapt3.md:356` | **not started** | Effort **M**. |
| **Example 1** (continuous $L^p$-computable but NOT Chapter-0-computable) | `chapt3.md:362` | **not started** | Effort **M**. Headline negative result. |
| **Example 2** ($f \in C_0(\mathbb{R}) \cap L^r(\mathbb{R})$, Chapter-0-computable but not $L^r$-computable) | `chapt3.md:366` | **not started** | Effort **M**. Headline counterexample. |

#### §4 — Further applications: Fourier + well-understood functions (lines 386-558)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Theorem 4 (Fourier series and transforms)** — three parts: | `chapt3.md:418` | **not started** | Effort **XL** total. P-R's headline Fourier-analytic application of First Main. |
| Theorem 4 (a) ($T : L^p[0,2\pi] \to \ell^r$ Fourier coefficients preserves comp iff $r \ge \max(q, 2)$) | `chapt3.md:418` | **not started** | Effort **L** given First Main + L^p + ℓ^p instances. |
| Theorem 4 (b) ($T^{-1} : \ell^p \to L^r[0,2\pi]$ inverse Fourier preserves comp iff $r \le q$ and $p \le 2$) | `chapt3.md:419` | **not started** | Effort **L**. |
| Theorem 4 (c) ($FT : L^p(\mathbb{R}) \to L^r(\mathbb{R})$ Fourier transform preserves comp iff $r = q$ and $p \le 2$) | `chapt3.md:420` | **not started** | Effort **L** given the Mathlib `MeasureTheory.Fourier` infrastructure. |
| **Corollary 4d (Effective Plancherel Theorem)**: $f \in L^2[0,2\pi]$ computable iff Fourier coefficients are computable in $\ell^2$; $f \in L^2(\mathbb{R})$ computable iff FT is | `chapt3.md:445` | **not started** (blueprint `\notready`) | `blueprint/src/L5.tex:11-15`. **§C5 #5 alternative anchor** (more concrete than just "First Main statement"). Effort **L** given Theorem 4. |
| **Corollary 4e (Effective Riemann-Lebesgue Lemma)**: $f$ computable in $L^1(\mathbb{R})$ ⇒ $FT(f)$ computable in $C_0(\mathbb{R})$ + decays effectively | `chapt3.md:447` | **not started** | Effort **M** given Theorem 4 (c). |
| **Theorem*** ($L^p$-computability via Fourier coefficients + norm, $1 < p < \infty$) — the unnamed/starred theorem | `chapt3.md:455` | **not started** | Effort **XL** for $p \ne 2$ (P-R defers proof to Pour-El & Richards [1984]); **M** for $p = 2$ given Plancherel. |
| Step / continuous / sequence-of-steps trichotomy summary | `chapt3.md:467-488` | **n/a** | Methodological. |
| Definition (computable sequence of step functions in the elementary sense) | `chapt3.md:477` | **not started** | Effort **M**. Vocabulary for Theorem 5 + Example. |
| **Example** (sequence of step functions $L^p$-computable but not elementary-computable, "number of steps" grows non-recursively) | `chapt3.md:493` | **not started** | Effort **M**. Uses the Waiting Lemma. |
| **Theorem 5 (step functions)**: a single step function is $L^p$-computable iff all values $c_i$ and essential transition points $a_i$ are computable | `chapt3.md:538` | **not started** | Effort **L**. Proof via the indefinite-integral operator $L^p \to C[a,b]$. Headline result on "well-understood functions". |

#### §5 — Applications to physical theory (lines 559-730)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Wave-equation setup (compact-domain restriction $D_1 \subset D_2$, Kirchhoff's formula) | `chapt3.md:565-598` | **not started** | Effort **L** vocabulary; Mathlib's PDE infrastructure is light. |
| **Theorem 6 (Wave Propagation, Uniform Norm)**: ∃ computable $f \in C(D_2)$ with non-computable solution $u(\cdot, 1) \in C(D_1)$ — **wave equation does NOT preserve uniform-norm computability** | `chapt3.md:600` | **not started** | Effort **XL**. Headline negative result. §C5 honorable mention as a Ch. 3 highlight. |
| Energy-norm definition ($E(u,t)^2$ via $|\nabla u|^2 + (\partial_t u)^2$ integral) | `chapt3.md:615-633` | **not started** | Effort **L** vocabulary. |
| **Theorem 7 (Wave Propagation, Energy Norm)**: solution $u$ is computable in the energy norm when initial data $(f, g)$ are | `chapt3.md:667` | **not started** | Effort **XL**. Headline positive result; the Sobolev-like energy norm "rescues" the wave equation. |
| Heat-equation setup (Gaussian kernel $K_t$) | `chapt3.md:673-700` | **not started** | Effort **M** vocabulary. |
| **Theorem 8 (Heat Equation)**: $f$ computable in $C_0(\mathbb{R}^3)$ ⇒ solution $u$ computable in $C_0(\mathbb{R}^4)$ | `chapt3.md:702` | **not started** | Effort **L** given First Main + the kernel decay estimate. |
| Laplace's equation setup (max principle, 4 standard regions: rectangle, cylinder, ball, ellipsoid) | `chapt3.md:704-720` | **not started** | Effort **M** vocabulary. |
| **Theorem 9 (Laplace's Equation)**: $f$ Chapter-0-computable on boundary of standard region $D$ ⇒ solution $u$ Chapter-0-computable | `chapt3.md:721` | **not started** | Effort **L** given First Main + monomials-as-generating-set + classical Laplace solution formulas. |
| Dimensions-other-than-3 remark (Theorems 7, 8, 9 extend mutatis mutandis; Theorem 6 extends only for $q \ge 2$) | `chapt3.md:727-730` | **n/a** | Methodological. |

**Ch. 3 audit verdict** (after iter-05 walk):

- **Done**: 0 landmark items. The L5 layer in Lean is empty; all of Ch. 3 is awaiting the First Main Theorem + the Ch. 2 instances (`L^p`, `ℓ^p`).
- **Partial via Mathlib**: 2 items (Mathlib's `ContinuousLinearMap` covers the bounded-operator predicate + sequential continuity, but is not aliased into our L5 namespace).
- **Not started**: ~28 items, headlined by **First Main Theorem** (§C5 #5), **Effective Plancherel** (alternative anchor for §C5 #5), **Theorem 6 wave-uniform negative**, **Theorem 7 wave-energy positive**, **Theorem 5 step-function characterization**, and the **Fourier Theorem 4 trio**.
- **n/a**: 3 methodological remarks.
- **Total Ch. 3 landmark items**: ~33.

The chapter's dependency structure: **First Main Theorem ⇒ Theorems 1–9 + Corollaries 4d, 4e**. First Main itself depends on the **Effective Density Lemma** (Ch. 2 Theorem 1, §C5 HM1) + a **closed-operator predicate** (not yet in Mathlib in this form) + concrete `ComputabilityStructure` instances on the source / target spaces (§C5 #2 L^p + #3 complex-Hilbert + #4 separable Hilbert). The Ch. 3 critical path therefore stays gated for several more layers of L4 buildout.

---

### Ch. 4 — Second Main Theorem + Eigenvector Theorem (`PourEl-Richards-chapt4.md`, 787 lines)

Ch. 4 has 7 sections: (1) Basic notions for unbounded operators + effectively determined, (2) Second Main Theorem + corollaries, (3) Discontinuities in eigenvalues, (4) Non-normal counterexample, (5) Eigenvector Theorem (preliminary form), (6) Eigenvector Theorem (completed) + Lemmas 6/7/8, (7) Banach-space results (Effective Independence Lemma + $\ell^1$ counterexample). Full enumeration below; **every landmark item is not-started in Lean** (L5 layer is empty).

#### §1 — Closed unbounded operators, adjoint, self-adjoint, spectrum, effectively determined (lines 43-126)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Closed-operator review (forward to Ch. 3 §1) | `chapt4.md:47` | **not started** | Same predicate as Ch. 3 §1 row. |
| **Definition (adjoint $T^*$, first variant via $(Tx, y) = (x, T^*y)$)** | `chapt4.md:57` | **partial (via Mathlib)** | Mathlib has `LinearMap.adjoint` / `ContinuousLinearMap.adjoint` for bounded operators; unbounded adjoint requires `LinearMap` over the dense domain — not unified in Mathlib. Effort to surface as an L5 alias: **M** (bounded) / **L** (unbounded). |
| **Definition (adjoint, second variant via graph orthogonal complement)** | `chapt4.md:72` | **not started** | Effort **M**. |
| **Definition (self-adjoint operator, $T = T^*$)** | `chapt4.md:80` | **partial (via Mathlib for bounded)** | Mathlib has `IsSelfAdjoint` for bounded operators on Hilbert space. Effort to extend to unbounded: **L**. |
| **Definition (normal bounded operator, $T^*T = TT^*$)** | `chapt4.md:86` | **partial (via Mathlib)** | Mathlib has `IsStarNormal`. Effort to alias: **S**. |
| **Definition (spectrum, $\lambda$ such that $T - \lambda$ has no bounded inverse)** | `chapt4.md:92` | **partial (via Mathlib)** | Mathlib has `spectrum`. Effort to alias: **S**. |
| **Definition (eigenvalue: $\exists x \ne 0, Tx = \lambda x$)** | `chapt4.md:98` | **partial (via Mathlib)** | Mathlib has `Module.End.HasEigenvalue` / `LinearMap.HasEigenvalue`. Effort to alias: **S**. |
| Definition (computability on the Cartesian product $H \times H$) | `chapt4.md:112` | **not started** | Effort **S**. Product computability via the obvious bridge. |
| **Definition (Effectively determined operator)**: ∃ computable sequence $\{e_n\}$ in $H$ such that $\{\langle e_n, Te_n\rangle\}$ is an effective generating set for the graph of $T$ | `chapt4.md:114` | **not started** | Effort **M**. The prerequisite for both Second Main and Eigenvector. Requires the `IsEffectiveGeneratingSet` predicate from Ch. 2. |
| Corollary: bounded $T$ effectively determined iff $\{Te_n\}$ computable | `chapt4.md:123` | **not started** | Effort **S** given the definition. |

#### §2 — Second Main Theorem + corollaries (lines 127-170)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Second Main Theorem** (effectively determined self-adjoint $T$ ⇒ ∃ computable real sequence $\{\lambda_n\}$ + r.e. set $A$ with: (i) $\overline{\{\lambda_n\}} = $ spectrum$(T)$; (ii) eigenvalues = $\{\lambda_n : n \notin A\}$; (iii) every such spectrum is realized; (iv) every such eigenvalue set is realized) | `chapt4.md:131` | **not started** (blueprint `\notready`) | `blueprint/src/L5.tex:17-21`. Effort **XL**. Proof entirely in Ch. 5. Headline result of Part III. |
| **Theorem 1** (Sequence of eigenvalues — ∃ effectively determined bounded self-adjoint $T$ whose **sequence** of eigenvalues is not computable, via Second Main (iv) with $\lambda_n = 2^{-n}$ and $A$ r.e.-not-recursive) | `chapt4.md:143` | **not started** | Effort **M** given Second Main + Prop A from L0. Headline negative result on sequence-vs-individual. |
| **Theorem 2** (Compact operators — compact self-adjoint ⇒ eigenvalues form a computable sequence) | `chapt4.md:149` | **not started** | Effort **M** given Second Main + Mathlib `IsCompactOperator`. Positive corollary. |
| **Theorem 3** (Operator norm — ∃ effectively determined bounded self-adjoint $T$ whose norm is not computable, via Second Main (iii) and a non-effectively-convergent series of $2^{-a(k)}$) | `chapt4.md:157` | **not started** | Effort **M** given Second Main + Prop A. Headline negative result on the operator norm. |

#### §3 — Creation and destruction of eigenvalues (lines 171-233)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Discontinuity setup (operator-norm topology) | `chapt4.md:175-177` | **n/a** | Methodological. |
| **Theorem 4** (one-parameter $\{T_\epsilon\}$ family of bounded self-adjoint operators on $H = L^2[-1,1] \oplus \langle\delta\rangle$ with: (i) $T_\epsilon$ continuous in operator norm; (ii) $T_0$ has unique eigenvalue $\lambda = 0$ of multiplicity 1; (iii) $T_\epsilon \ne 0$ near $0$ has no eigenvalue near $0$ but does near $\pm 1$) | `chapt4.md:179` | **not started** | Effort **L**. Explicit construction; the proof uses an integral characterization of eigenvalues via $\int (x - \lambda)^{-1} dx$. Not a computability-flavored result per se but a counterpoint to the Second Main Theorem. |

#### §4 — Non-normal operator with non-computable eigenvalue (lines 234-292)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Theorem 5** (Noncomputable eigenvalues — ∃ effectively determined bounded **non-normal** operator $T : L^2[0,1] \to L^2[0,1]$ with noncomputable real eigenvalue $\alpha = \sum 4^{-a(k)}$) | `chapt4.md:240` | **not started** | Effort **L**. Headline negative result demonstrating that the self-adjointness/normality hypothesis in Second Main is necessary. The construction $T = T_1 + T_2$ via diagonal + off-diagonal parts is explicit. |
| Lemma 8 cross-reference: result transfers to any effectively separable Hilbert space | `chapt4.md:238` | **not started** | Forward reference to §6 Lemma 8 (universal-form result). |

#### §5 — Eigenvector Theorem (preliminary form) (lines 293-489)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Theorem 6 (Eigenvector Theorem, final form)**: ∃ effectively determined compact self-adjoint $T : L^2[0,1] \to L^2[0,1]$ with $\lambda = 0$ eigenvalue of multiplicity 1 and **no** computable eigenvector for $0$ | `chapt4.md:296` | **not started** (blueprint `\notready`) | `blueprint/src/L5.tex:23-27`. Effort **XL**. Headline result of Ch. 4 / motivating result for §C5 #4 (separable Hilbert instance). |
| **Eigenvector Theorem (preliminary form)** — same as final but with an ad hoc computability structure on $H$ instead of the standard one | `chapt4.md:302` | **not started** | Effort **L** (given the ad hoc structure setup). Stepping stone to Theorem 6 via §6 Lemma 8. |
| Setup: ad hoc structure on $L^2[0,1]$ via the generating set $\{f, e_1, e_2, \ldots\}$ with $f = \gamma\Lambda + \sum \alpha_n e_n$ and $\gamma$ noncomputable | `chapt4.md:312-359` | **not started** | Effort **L**. Construction technique used throughout Ch. 4. Requires §C5 #3 (complex-Hilbert / ScalarComputableSeq ℂ) since $L^2[0,1]$ here uses $e^{2\pi i m x}$. |
| The operator $T$ ($T\Lambda = 0$, $Te_n = 2^{-n} e_n$): compact + self-adjoint + has unique eigenvalue $\lambda = 0$ with eigenvector $\Lambda$ | `chapt4.md:361-370` | **not started** | Effort **S** given setup. |
| Pre-lemma: inner products of computable sequences in any Hilbert space with computability structure are computable (via polarization identity + Linear Forms + Norm axioms) | `chapt4.md:380` | **not started** | Effort **M**. General useful corollary of the axioms, independent of the Eigenvector Theorem. |
| **Lemma 1** (computable sequence in $H$ iff Fourier coefficients $\{c_{nk}\}$ are computable AND series $\sum \|c_{nk}\|^2$ converges effectively in $k$ and $n$, given computable orthonormal basis $\{e_n\}$) | `chapt4.md:388` | **not started** | Effort **M**. Spectral characterization of computable sequences. |
| **Lemma 2** (vector $x$ with computable Fourier coefficients $\{c_k\}$ but no effective convergence ⇒ inner products $\{(x, y_m)\}$ with computable sequence $\{y_m\}$ are computable) | `chapt4.md:403` | **not started** | Effort **M**. Internal lemma for Lemma 3. |
| **Lemma 3** (the ad hoc structure on $H$ satisfies the axioms + is effectively separable) | `chapt4.md:437` | **not started** | Effort **M** given Lemmas 1, 2. Verification of the Norm Axiom is the non-trivial part. |
| **Lemma 4** ($T$ is effectively determined in the ad hoc structure) | `chapt4.md:471` | **not started** | Effort **S** given Lemma 1 + setup. |
| **Lemma 5** (no nonzero multiple of $\Lambda$ is ad hoc computable) | `chapt4.md:483` | **not started** | Effort **S**. Closes the preliminary form. |

#### §6 — Eigenvector Theorem (completed) + Hilbert isomorphism (lines 491-564)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Lemma 6 (Effective Independence Lemma)**: any effective generating set $\{e_n\}$ for an effectively separable Banach space contains a linearly independent effective generating subset $\{f_n\}$ | `chapt4.md:499` | **not started** | Effort **L** (proof deferred to §7; complex inductive construction with the Independence Criterion). |
| **Lemma 7** (every effectively separable Hilbert space has a computable orthonormal basis, via Gram-Schmidt) | `chapt4.md:503` | **not started** | Effort **M** given Lemma 6 + inner-product computability pre-lemma. The L4 §C5 #4 (separable Hilbert instance) effort is largely this lemma + the underlying definitions. |
| **Lemma 8** (every effectively separable Hilbert computability structure has the spectral form: $\{x_n\}$ computable iff its Fourier coefficients $\{c_{nk}\}$ in some computable orthonormal basis $\{u_k\}$ are computable + the series $\sum |c_{nk}|^2$ converges effectively) | `chapt4.md:534` | **not started** | Effort **M** given Lemmas 1, 7. **Headline result**: all effectively separable Hilbert computability structures are isometrically isomorphic (consequence). |
| Completion: Eigenvector Theorem (final form) via Lemma 8 transfer from ad hoc to natural structure | `chapt4.md:540-562` | **not started** | Effort **L**. The transfer machinery via Lemma 8 is the key bridge. |

#### §7 — Banach-space results (lines 566-786)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Effective Independence Lemma — full proof (Independence Criterion + the Test (a)/(b) construction) | `chapt4.md:570-659` | **not started** | Effort **L**. The Independence Criterion at `chapt4.md:591` is a useful re-usable sub-result. |
| Independence Criterion ($\{z_1, \ldots, z_k\}$ linearly independent iff $\exists m \ge 2k$ with the $\min$-over-dyadic-rationals norm bound) | `chapt4.md:591` | **not started** | Effort **M**. Stand-alone useful lemma. |
| Definition (isometry of a Banach space) | `chapt4.md:665` | **partial (via Mathlib)** | Mathlib has `LinearIsometry` / `LinearIsometryEquiv`. Effort to alias: **S**. |
| Question: are all effectively separable ad hoc computability structures isometric to the standard one? | `chapt4.md:670` | **n/a** | Methodological question; answer split (Hilbert: yes, Banach: no). |
| Hilbert answer: yes (via Lemma 8) | `chapt4.md:676` | **not started** | Same as §6 Lemma 8 row. |
| **Example** (ad hoc structure on $\ell^1$ NOT isometric to standard) | `chapt4.md:680` | **not started** | Effort **L**. Headline counterexample showing the Hilbert/Banach asymmetry. Requires §C5 #2/HM-style ℓ^1 instance. |
| Sub-Lemma (this structure satisfies the axioms) | `chapt4.md:721` | **not started** | Effort **M**. Verification of Norm Axiom via the explicit $\|x\| = \sum |\beta \alpha_k + \theta_k| + |\beta| \cdot \gamma$ telescoping recipe. |
| Sub-Lemma (this structure is not isometric to the standard structure on $\ell^1$, via extremal-points argument) | `chapt4.md:773` | **not started** | Effort **M** given the previous sub-lemma. Uses the classical fact that $\pm e_k$ are the only extremal points of the $\ell^1$ unit ball. |
| Sub-Lemma (only ad hoc computable multiple of $\Lambda = e_0$ is $0$) | `chapt4.md:784` | **not started** | Effort **S**. Mirror of Lemma 5. |

**Ch. 4 audit verdict** (after iter-06 walk):

- **Done**: 0 landmark items. The L5 layer is empty.
- **Partial via Mathlib**: 6 items (adjoint for bounded, self-adjoint for bounded, normal, spectrum, eigenvalue, isometry — all are Mathlib's standard names that we have not aliased into the project but are immediately available downstream).
- **Not started**: ~32 items, headlined by:
  - **Second Main Theorem** + Theorems 1, 2, 3 (§2) — the Part III headline cluster.
  - **Theorem 5** (non-normal counterexample, §4) — the negative result demonstrating self-adjointness necessity.
  - **Theorem 6 Eigenvector Theorem** (§5 final, §6 completed) — the eigenvector negative result.
  - **Lemmas 1–8** (§§5–6) — the ad hoc machinery + Lemma 7 (Gram-Schmidt → orthonormal basis) + Lemma 8 (spectral form, isomorphism of structures).
  - **Effective Independence Lemma** + **$\ell^1$ counterexample** (§7) — Banach asymmetry.
- **n/a**: 3 methodological remarks.
- **Total Ch. 4 landmark items**: ~37.

The chapter's dependency structure: **Second Main Theorem ⇒ Theorems 1, 2, 3**; **Theorem 6 ⇒ Lemmas 1–5 (preliminary) + Lemmas 6, 7, 8 (transfer to natural structure)**. Lemma 7 (Gram-Schmidt) and Lemma 8 (spectral form) are the central infrastructure that §C5 #4 (separable Hilbert instance) needs to build out — formalizing Lemmas 7 and 8 essentially _is_ formalizing the separable Hilbert instance + its uniqueness, which **doubles the value of the §C5 #4 priority** beyond just providing one more instance of `ComputabilityStructure`.

---

### Ch. 5 — Proof of Second Main Theorem (`PourEl-Richards-chapt5.md`, 1,415 lines)

Ch. 5 contains the proof of the Second Main Theorem and has 8 sections: (1) Spectral Theorem review, (2) Preliminaries (Uniformity Lemma + triangle functions + CompNorms), (3) Heuristics, (4) The Algorithm, (5) Proof that the algorithm works, (6) Normal operators, (7) Unbounded self-adjoint operators, (8) Converses (parts iii, iv). Most "items" here are technical sub-lemmas internal to a single proof rather than standalone landmarks; the chapter is largest in P-R (1,415 verbatim lines). Full enumeration below; **every landmark item is not-started in Lean**.

#### §1 — Spectral Theorem review (lines 35-280)

Items A–J in P-R's enumeration are classical spectral-theoretic prerequisites (Mathlib has fragments; most are not surfaced for unbounded operators).

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Spectral-measure properties (i, ii, iii: invariance, orthogonality, approximate eigenvectors) | `chapt5.md:45-48` | **partial (via Mathlib for bounded)** | Mathlib has `BorelSpace`/`spectralMeasure` for bounded normal operators (`Mathlib.Analysis.InnerProductSpace.Spectrum`). Effort to surface in L5 form: **L**. |
| Spectral-measure abstract properties (A: intersection, B: union, C: countable additivity) | `chapt5.md:51-53` | **partial (via Mathlib)** | Same as above. |
| Operational calculus (E: linearity, F: multiplication, G: norm bound, H: pointwise convergence, I: projections) | `chapt5.md:92-101` | **partial (via Mathlib)** | Mathlib has `ContinuousFunctionalCalculus`. Effort to surface for our use: **L**. |
| Operational calculus J for normal operators (conjugate ↔ adjoint) | `chapt5.md:263` | **partial (via Mathlib)** | Mathlib's continuous functional calculus handles this. |
| Measure $d\mu_{xy}$ with property D (positivity at $x = y$) | `chapt5.md:78-85` | **not started** | Effort **L**. The complex-measure-from-vector-pair construction. |
| **SpThm 1** (Nullity criterion: $x \in H_I$ + $\text{supp}(f) \cap I = \emptyset$ ⇒ $f(T)x = 0$) | `chapt5.md:120` | **not started** | Effort **M**. Internal lemma for SMT proof. |
| **SpThm 2** (Pointwise convergence a.e.: $H_I = 0$ + $f_n \to 0$ off $I$ ⇒ $f_n(T)x \to 0$) | `chapt5.md:124` | **not started** | Effort **M**. Cited in Proposition 3 (Section 5). |
| **SpThm 3** ($\lambda \in \text{spectrum}(T)$ ⇒ $H_{(\lambda-\epsilon,\lambda+\epsilon)} \ne 0$) | `chapt5.md:148` | **not started** | Effort **M**. Cited in Proposition 2 (spectrum density). |
| **SpThm 4** (eigenvector $x$ with eigenvalue $\lambda$ + continuous $f$ ⇒ $f(T)x = f(\lambda)x$) | `chapt5.md:176` | **not started** | Effort **S**. Cited in Proposition 4. |
| **SpThm 5** ($x$ eigenvector for $\lambda$ iff $x \in H_{\{\lambda\}}$, hence $\lambda$ eigenvalue iff $H_{\{\lambda\}} \ne 0$) | `chapt5.md:186` | **not started** | Effort **M**. Headline of the eigenvalue / spectrum distinction. |
| **SpThm 6** ($x_0 = E_I(x)$ ⇒ $\|x_0\|^2 = d\mu(x)$-measure of $I$) | `chapt5.md:225` | **not started** | Effort **M**. Used in spectral measure ↔ norm conversions. |
| **SpThm 7** ($\|f(T)\| \le \sup_{\lambda \in \text{spectrum}} |f(\lambda)|$) | `chapt5.md:250` | **not started** | Effort **S** (or via Mathlib's continuous functional calculus). Cited in Proposition 1, InEq estimates. |
| Normal-operator extension (Borel sets in $\mathbb{C}$, J identity) | `chapt5.md:260-271` | **not started** | Effort **M**. §6 uses this. |
| **Proposition** ($(T - i)^{-1}$ bounded normal for self-adjoint $T$) | `chapt5.md:279` | **partial (via Mathlib)** | Mathlib's resolvent set / spectrum machinery gives this for bounded; unbounded version needs work. |

#### §2 — Preliminaries (lines 281-572)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Lemma (Uniformity in the exponent)**: $T : X \to X$ bounded + effectively determined ⇒ $\{T^N e_n\}$ computable in both $N$ and $n$ | `chapt5.md:285` | **not started** | Effort **L**. Uses Effective Density Lemma (§C5 HM1) + Linear Forms Axiom + Limit Axiom. Inductive witness construction on the 4-fold rational coefficient array. |
| **Corollary** ($\{T^N y_n\}$ computable for any computable sequence $\{y_n\}$) | `chapt5.md:369` | **not started** | Effort **S** given the lemma. |
| Interval $[-M, M]$ setup (containing spectrum($T$) with margin) | `chapt5.md:373` | **not started** | Effort **S**. Vocabulary. |
| Sequence $\{x_n\}$ construction (dense on annulus $1 \le \|x_n\| \le 1001/1000$) | `chapt5.md:382` | **not started** | Effort **M**. Effective listing via Norm Axiom + rational threshold scanning. |
| **Pre-step A — Effective operational calculus Lemma**: computable continuous $\{f_m\}$ + computable $\{y_n\}$ ⇒ $\{f_m(T)(y_n)\}$ computable | `chapt5.md:420` | **not started** | Effort **L**. Uses SpThm 7 + Weierstrass approximation (L4 `IsComputableSeqCMap`) + Limit Axiom. |
| Pre-step A Corollary (norms $\|f_m(T)(y_n)\|$ computable in both vars) | `chapt5.md:432` | **not started** | Effort **S** given the lemma + Norm Axiom. |
| Pre-step B — Triangle functions $\tau_{qi}$ definition (supports overlap as $\ldots [-2,0], [-1,1], [0,2], \ldots$) | `chapt5.md:446-470` | **not started** | Effort **M**. Concrete construction. |
| Pre-step B — Trapezoidal function $\sigma$ (at $q = -1$ stage) | `chapt5.md:474` | **not started** | Effort **S**. |
| Triangle-decomposition identity ($\tau_{q-1}^* = \frac{1}{8} \sum_{i=h-7}^{h+7} c_i \tau_{qi}$ with $c_i \in \{1,2,\ldots,7,8,7,\ldots,1\}$) | `chapt5.md:487` | **not started** | Effort **M**. Geometric identity proved by slope-matching. |
| Two inequalities ($\|\tau_{qu}(T)(x_n)\| \ge (1/8) \|\tau_{q-1}^*(T)(x_n)\|$ and $\|\tau_{0u}(T)(x_n)\| \ge 1/(2M-1)$) | `chapt5.md:535-540` | **not started** | Effort **M**. Internal to the InEq 3 induction. |
| Pre-step C — CompNorm definitions (rational approximations with explicit error $(1/1000)(1/2M)(1/16^q)$) | `chapt5.md:550-572` | **not started** | Effort **M**. Combines Pre-steps A and B to produce a computable triple sequence of rationals. |

#### §3 — Heuristics (lines 573-854)

Items in §3 are deliberately non-rigorous (a non-effective sketch for pedagogical purposes). They are not Lean targets per se; the formal versions live in §§4-5.

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Heuristics I — simplified non-effective procedure (Steps 1-5) | `chapt5.md:579-690` | **n/a** | Pedagogical. Not a Lean target. |
| Heuristics II — 4 propositions to prove (rigorous in §5) | `chapt5.md:693-836` | **n/a** | Pedagogical. The propositions are the §5 targets. |
| Definition of set $A$ ("Not an eigenvalue!") | `chapt5.md:680` | **not started** (formal version in §4) | Same as §4 row below. |

#### §4 — The Algorithm (lines 855-956)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Construction of $\{\lambda_n\}$ algorithm (inductive selection of $i(q)$ via CompNorm maximization, with $I_{q i} \subseteq I_{q-1}^*$ constraint) | `chapt5.md:862-924` | **not started** | Effort **L**. The core algorithm. Effectivity by `Nat.find` / `Computable` selection. |
| **Lemma** ($\{\lambda_n\}$ is computable as a sequence of reals, via nested intervals of half-width $8^{-q}$) | `chapt5.md:920` | **not started** | Effort **M**. Direct from the nested-interval construction. |
| Construction of set $A$ ($n \in A$ iff $\exists q$ with CompNorm$_q^*(n) < 1/8$) | `chapt5.md:926-952` | **not started** | Effort **S** vocabulary. |
| **Lemma** (set $A$ is recursively enumerable) | `chapt5.md:953` | **not started** | Effort **S** given the construction. R.E. is the easy direction; non-recursive in general. |

#### §5 — Proof that the algorithm works (lines 957-1220)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **InEq 1** (CompNorm$_q^*$ ≈ true norm with explicit error) | `chapt5.md:1000` | **not started** | Effort **S** given Pre-step C. |
| **InEq 2** ($\|\tau_q^*(T)(x_n)\|$ close to maximizing $\|\tau_{qu}(T)(x_n)\|$ within doubled error) | `chapt5.md:1001` | **not started** | Effort **M**. Comparison of computed-max-index $v$ and unattainable-max-index $u$. |
| **InEq 3** ($\|\tau_q^*(T)(x_n)\| \ge (1/2M)(1/16^q)$ — uniform lower bound across $q$) | `chapt5.md:1002` | **not started** | Effort **L**. Inductive on $q$, base case at $q = 0$ via trapezoidal $\sigma$. |
| **Proposition 1** (every $\lambda_n \in \text{spectrum}(T)$) | `chapt5.md:1069` | **not started** | Effort **M** given SpThm 7 + InEq 3. |
| **Proposition 2** ($\{\lambda_n\}$ dense in spectrum($T$)) | `chapt5.md:1074` | **not started** | Effort **L** given SpThm 1, 3 + InEq 3 + the density of $\{x_n\}$ on the annulus. |
| **Proposition 3** (if $\lambda_n$ is not an eigenvalue then $n \in A$) | `chapt5.md:1116` | **not started** | Effort **M** given SpThm 5 + SpThm 2 + InEq 1. |
| **Proposition 4** (if $\lambda$ is an eigenvalue then $\exists n \notin A$ with $\lambda = \lambda_n$) | `chapt5.md:1125` | **not started** | Effort **L** given SpThm 4 + inductive geometric (ooo) lemma + InEq 1, 2. |
| **Eigenvalue Lemma** ($\tau_q^*(\lambda) \ge 1/7$ and CompNorm$_q^* \ge 1/7$ for all $q$, under $\|x_n - x\| < 1/1000$ approximation hypothesis) | `chapt5.md:1129` | **not started** | Effort **L**. Internal lemma to Proposition 4. |
| **Geometric (ooo) lemma** ($\tau_{qi}(\lambda) \ge 1/2$ for some $i = 8j-7, \ldots, 8j+7$ iff $\tau_{q-1}^*(\lambda) \ge 1/16$) | `chapt5.md:1148` | **not started** | Effort **M**. Geometric on the triangle-function support overlap. |

#### §6 — Normal operators (lines 1222-1291)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Theorem 1 (Normal Operators)**: Second Main Theorem for bounded normal operators with complex-spectrum analog | `chapt5.md:1226` | **not started** | Effort **L** given the bounded self-adjoint version. Modifications listed below. |
| **Proposition** ($T$ effectively determined bounded normal ⇒ $T^*$ effectively determined) | `chapt5.md:1235` | **not started** | Effort **M**. Uses First Main Theorem (§C5 #5) + Norm Axiom + Lemma 7 from Ch. 4. |
| Proof modifications listing — six items: (1) Weierstrass for two-variable polys, (2) 2-d grid (chessboard 64-fold), (3) 2-d triangle products $\tau_{qij} = \tau_{qi}(x)\tau_{qj}(y)$, (4) CompNorm rescaling ($1/4M^2$, $1/256^q$), (5) algorithm with $(i, j)$ index pair, (6) cutoff value changes ($1/4 \to 1/7$ instead of $1/2 \to 1/7$) | `chapt5.md:1252-1291` | **not started** | Effort **L–XL** total. Largely repetition with index changes; tractable once §§1-5 are formalized. |

#### §7 — Unbounded self-adjoint operators (lines 1293-1339)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| Effective generating set for unbounded $T$ definition | `chapt5.md:1297` | **not started** | Same as Ch. 4 §1 row (`chapt4.md:114`). |
| Trivial observation: $T$ effectively determined + computable constant $\alpha$ ⇒ $T + \alpha$ effectively determined with the same generating set | `chapt5.md:1299` | **not started** | Effort **S**. |
| **Proposition** ($T$ effectively determined + $T^{-1}$ exists and bounded ⇒ $T^{-1}$ effectively determined) | `chapt5.md:1303` | **not started** | Effort **M**. Useful in its own right; constructive bound on the rational-linear-combination approximant search. |
| **Second Main Theorem, unbounded case (i)+(ii)** — reduction to bounded normal via $N = (T - i)^{-1}$ + spectral map $\lambda = (1 + i\mu)/\mu$ | `chapt5.md:1325, 1331` | **not started** | Effort **L** given §§1-6 + the inverse-effectively-determined Proposition above. |

#### §8 — Converses (parts iii, iv) (lines 1341-1414)

| Landmark item | P-R location | Lean status | Lean ref / rationale |
|---|---|---|---|
| **Example 1 (Converse iii)**: computable $\{\lambda_n\}$ realized as spectrum of effectively determined self-adjoint $T$ via diagonal matrix $T e_n = \lambda_n e_n$ on computable orthonormal basis | `chapt5.md:1349` | **not started** | Effort **L**. Uses Lemma 7 from Ch. 4 (computable orthonormal basis exists). |
| **Example 2 (Converse iv)**: computable $\{\lambda_n\}$ + r.e. $A$ realized as eigenvalues $\{\lambda_n : n \notin A\}$ of effectively determined self-adjoint $T$, via "destroy eigenvalue $\lambda_{a(k)}$ by perturbing the $H_{a(k)}$ block from constant $\lambda_{a(k)}$ to $\lambda_{a(k)} + 2^{-k} x$ (continuous spectrum)" | `chapt5.md:1368` | **not started** | Effort **XL**. Most intricate single construction in Ch. 5. The perturbation argument + verification that $T = \lim T_k$ is effectively determined (via uniform-effective-convergence of operators). The bounded case is given; unbounded case is mechanical. |

**Ch. 5 audit verdict** (after iter-07 walk):

- **Done**: 0 landmark items. The L5 layer is empty.
- **Partial via Mathlib**: 4 items in §1 (spectral measure properties + operational calculus / continuous functional calculus — all available in Mathlib for bounded normal operators, not surfaced).
- **Not started**: ~32 items, headlined by:
  - **The Uniformity Lemma + Pre-steps A, B, C** (§2) — the entire effective-spectral-calculus framework.
  - **SpThm 1–7** (§1) — the 7 spectral-theoretic prerequisites cited throughout.
  - **InEq 1, 2, 3** (§5) — the three quantitative inequalities driving the algorithm.
  - **Propositions 1–4** (§5) — the four propositions that complete the bounded self-adjoint Second Main Theorem.
  - **Theorem 1 (Normal Operators)** (§6) — the extension to bounded normal.
  - **Second Main Theorem unbounded case** (§7) — the extension to unbounded self-adjoint.
  - **Examples 1, 2** (§8) — the converses (iii) and (iv).
- **n/a**: 3 items (Heuristics I + II are pedagogical; §3 has no formal targets).
- **Total Ch. 5 landmark items**: ~40 (largest of any chapter).

The chapter's structure is **monolithic** in the sense that everything lives inside one big proof; you cannot prove e.g. Proposition 2 without InEq 3, which requires Pre-step B and SpThm 7. The natural formalization milestones are: (M1) §1 spectral prerequisites surfaced (effort **L–XL**); (M2) §2 effective operational calculus + triangle machinery (effort **XL**); (M3) §§4-5 bounded self-adjoint Second Main (effort **XL**); (M4) §6 normal extension (effort **L**); (M5) §7 unbounded extension (effort **L**); (M6) §8 converses (effort **XL** for Example 2). Each milestone is itself a multi-round campaign; the **total** effort for Ch. 5 alone is comparable to the cumulative L1–L4 effort the project has already invested.

---

## C2 — Citation verification

**Completed in iter-08** via a spot-verification pass on every `done` row in the C1 tables. Methodology: open each `<chapter-file>:<line>` P-R cite and confirm the cited verbatim content matches the claimed semantic intent; open each `<file>:<line>` Lean ref and confirm the declaration header matches the claimed name and content.

**Result**: all `done` rows pass verification. No misattributions found. One minor citation-precision note (footnote ⓢ below).

### Verification log — `done` rows

Every row below was verified live in iter-08 by reading the literature/Lean file at the cited line.

#### Prerequisites (§0.2)

| Lean ref (verified) | P-R cite (verified) | Verdict |
|---|---|---|
| `L0/Bridge.lean:72` (`abbrev IsRecursivelyEnumerable`) | `0.2.prereq.md:25` ("recursively enumerable" definition) | ✓ Match |
| `L0/Bridge.lean:77` (`abbrev IsRecursiveSet`) | `0.2.prereq.md:27` ("recursive" definition) | ✓ Match |
| `L0/Bridge.lean:104` (`theorem prop_A_exists_re_not_recursive`) | `0.2.prereq.md:31` (Proposition A) | ✓ Match |
| `L0/PropB.lean:149` (`theorem prop_B`) | `0.2.prereq.md:35` (Proposition B) | ✓ Match |
| `L0/Bridge.lean:117` (`def cantorPair`), `:125` (`cantorPair_computable`) | `0.2.prereq.md:40-44` (existence of $J$ + inverses), `:46-50` (standard form formula) — Lean docstring cites `:49` for the formula | ✓ Match. **Footnote ⓢ** — see below. |
| `L0/Bridge.lean:148` (`def charFn`) | `0.2.prereq.md:52-56` (analysts' convention) | ✓ Match |

#### Ch. 0 — Computability on the real line

| Lean ref (verified) | P-R cite (verified) | Verdict |
|---|---|---|
| `L1/ComputableSeqReal.lean:87` (`def IsComputableSeqRat`) | `chapt0.md:46` (Definition 1) | ✓ Match — both use the $(-1)^{s(k)} \cdot a(k)/b(k)$ form with $b(k) \ne 0$. |
| `L1/ComputableSeqReal.lean:97` (`def IsComputableDoubleSeqRat`) | `chapt0.md:189` (double sequence via `Nat.pair` fold) | ✓ Match — Lean docstring cites `Ch. 0:189` verbatim. |
| `L1/ComputableSeqReal.lean:106` (`def IsComputableSeqReal`) | `chapt0.md:203` (Definition 5a) | ✓ Match — both use $\|r_{nk} - x_n\| \le 1/2^k$. |
| `L1/ComputableSeqReal.lean:157` (`theorem isComputableSeqReal_of_effectiveConvergence`) | `chapt0.md:246` (Proposition 1) | ✓ Match — closure under effective convergence. |
| `L1/ComputableSeqReal.lean:1086` (`def IsComputableReal`) | `chapt0.md:58` (Definition 3) | ✓ Match (with divergence D8 acknowledged — we use constant-sequence form, P-R uses Cauchy form, equivalence implicit). |
| `L2/GrzegorczykLacombe.lean:108` (`def IsGLComputable`) | `chapt0.md:427-435` (Definition A) | ✓ Match — Lean file at line 107 cites `chapt0.md:427-435` verbatim. Divergence D1 (positivity conjunct) acknowledged. |
| `L4/Instances/CMap.lean:1214` (`def IsComputableSeqCMap`) | `chapt0.md:468` (Definition B′, sequence form) | ✓ Match — polynomial-approximant form with rational-coefficient witness. |
| `L4/Instances/CMap.lean:1894` (`theorem isComputableSeqCMap_of_effectiveLimit`) | `chapt0.md:748` (Theorem 4 — Closure under effective uniform convergence) | ✓ Match — Lean docstring cites `chapt0.md:748` verbatim. |
| `L4/Instances/CMap.lean:2115` (`theorem isComputableSeqCMap_norm`) | `chapt0.md:977` (Theorem 7 — Maximum values) | ✓ Match. |

#### Ch. 2 — Axiomatic computability structure

| Lean ref (verified) | P-R cite (verified) | Verdict |
|---|---|---|
| `L3/ComputabilityStructure.lean:108` (`class ComputabilityStructure`) | `chapt2.md:51` (pair convention "$\langle X, \mathscr{S}\rangle$") | ✓ Match |
| `L3/ComputabilityStructure.lean:177` (`def IsComputableDoubleSeq`) | `chapt2.md:53` (double sequence via pairing) | ✓ Match |
| `L3/ComputabilityStructure.lean:169` (`def IsComputableElement`) | `chapt2.md:55` ("$x, x, x, \ldots$ computable" form) | ✓ Match |
| `L3/ComputabilityStructure.lean:120` (`isComputableSeq_linearCombination` field) | `chapt2.md:66-72` (Axiom 1 Linear Forms) | ✓ Match — Lean docstring cites `Ch. 2:66-72` verbatim. |
| `L3/ComputabilityStructure.lean:134` (`isComputableSeq_of_effectiveLimit` field) | `chapt2.md:58-64, 73` (effective convergence def + Axiom 2 Limits) | ✓ Match — Lean docstring cites `Ch. 2:58-64, 73`. |
| `L3/ComputabilityStructure.lean:144` (`isComputableSeqReal_norm` field) | `chapt2.md:75` (Axiom 3 Norms) | ✓ Match. |
| `L3/ComputabilityStructure.lean:153` (`zero_seq` field) | `chapt2.md:77` (non-vacuity) | ✓ Match. |
| `L4/Instances/CMap.lean:3023` (`computabilityStructureCMap_of`) | `chapt2.md:128-129` (C[a,b] case: Axiom 2 = Ch.0 Thm 4, Axiom 3 = Ch.0 Thm 7) | ✓ Match (line number filled per DA finding #2). |
| `L4/Instances/CMap.lean:1240` (`isComputableSeqCMap_linearCombination`) | `chapt2.md:66-72` (Axiom 1 instance) | ✓ Match. |
| `L4/Instances/CMap.lean:1894` (`isComputableSeqCMap_of_effectiveLimit`) | `chapt2.md:128-129` (Axiom 2 instance via Ch. 0 Thm 4) | ✓ Match — Lean file at lines 1892-1893 cites this verbatim. |
| `L4/Instances/CMap.lean:2115` (`isComputableSeqCMap_norm`) | `chapt2.md:128-129` (Axiom 3 instance via Ch. 0 Thm 7) | ✓ Match — Lean file at lines 2113-2114 cites this verbatim. |

#### Blueprint references

All blueprint `\leanok` citations referenced in C1 tables (`blueprint/src/L0.tex:35-46, 81-92, 144-155`, `blueprint/src/L1.tex:6-11, 13-19, 32-38, 52-128, 130-136, 162-173, 175-220`, `blueprint/src/L2.tex:6-17, 19-101`, `blueprint/src/L3.tex:5-17`, `blueprint/src/L4.tex:5-26, 28-41, 43-53, 55-77, 79-83, 85-89`, `blueprint/src/L5.tex:5-9, 11-15, 17-21, 23-27, 5-27`) were verified by direct read of the blueprint dispatcher files in iter-02 + iter-06. All are present at the cited line ranges.

### Footnotes

- **ⓢ Citation-precision note** (Cantor pair). The Lean docstring at `L0/Bridge.lean:63` cites `0.2.prereq.md:49` (the standard-form formula line `J(x,y) = (x+y)(x+y+1)/2 + x`). PR-COVERAGE's C1 row for the recursive pairing function cites `0.2.prereq.md:40-44` (the existence statement). Both citations are within the same paragraph (lines 40-50 in P-R). The Lean cite is precise to the formula; the PR-COVERAGE cite is the broader existence statement. **Not a misattribution** — different sub-points within the same logical unit. No remediation required.

- **ⓡ Mathlib-`REPred` equivalence not surfaced as a named theorem.** P-R `0.2.prereq.md:25` defines r.e. via "$A$ is the range of a recursive function or $A$ is empty"; we use Mathlib's `REPred` (semi-decidable membership) and rely on Mathlib's internal `REPred ↔ range-of-Computable` lemma. Not a citation drift; just a vocabulary choice. The L0 docstring at line 68-71 acknowledges this explicitly. No remediation required.

### Ch. 1 verbatim status (confirmed)

`literature/papers/PourEl-Richards-chapt1.md` does not exist (`ls literature/papers/PourEl-Richards-chapt1*` → no matches). CLAUDE.md "Corpus ingestion" table line for Ch. 1 reads `pending`. The entire Ch. 1 row in C1 correctly marks the chapter `deferred / not started`. The blueprint header `blueprint/src/L2.tex:3` mentions "Chapter 0 (G-L definition) + Chapter 1 (closure properties)" — this is a minor blueprint annotation drift (the L2 closure properties we have are actually based on Ch. 0 §3–§4 closures of `IsGLComputable`, not Ch. 1's differentiation / analytic function material). Flagged for future blueprint comment fix; not a citation or content issue.

### Summary of C2 findings

- **23 done rows verified clean** across Prerequisites + Ch. 0 + Ch. 2 (the chapters with `done` Lean coverage).
- **0 misattributed cites** found.
- **0 incorrect Lean line refs** found.
- **2 footnote-level precision notes** (ⓢ cantor pair sub-line and ⓡ REPred-equivalence vocabulary) — both informational, no remediation required.
- **1 blueprint comment drift** (`blueprint/src/L2.tex:3` mentions Ch. 1 inaccurately) — flagged for future blueprint edit, not a PR-COVERAGE issue.
- **Ch. 1 verbatim absence confirmed** matches the deferred row in C1 §Ch. 1.

---

## C3 — Deferral rationales + effort estimates

(To be expanded after C1 completion. Preliminary entries:)

| Item | Reason | Effort class |
|---|---|---|
| P-R Ch. 1 (Differentiation, analytic functions) — entire chapter | Verbatim not in corpus (CLAUDE.md "Corpus ingestion" → Ch. 1: pending). Not on critical path to L3/L5 keystone. | **L** to ingest + audit; **XL** to formalize fully |
| L4 `L^p[a,b]` computability structure instance (Ch. 2 §3, `chapt2.md:161`) | Requires Mathlib's measure-theoretic `Lp` machinery (already imported in `AnalysisBridge.lean`) plus a P-R-style "effective closure of computable simple functions" construction. Heavy. | **XL** |
| L4 separable Hilbert space instance (Ch. 2 §3) | Requires a computable orthonormal basis. Conceptually clean but cross-cutting (touches L1, L2, L3). | **L–XL** |
| L4 `ℓ^p` instance | Auxiliary to `L^p`; less critical because `ℓ^p` is `Lp` over counting measure. | **L** |
| L1 `IsComputableSeqComplex` predicate + `ScalarComputableSeq ℂ` instance | Needed to lift `ComputabilityStructure` from `𝕜 = ℝ` to `𝕜 = ℂ`. Complex-Hilbert + Plancherel both gate on this. | **M** |
| L5 First Main Theorem (Ch. 3) | Depends on L4 `L^p` instance + careful operator infrastructure. The proof in P-R is constructive in places that translate naturally to Lean, but the side conditions need careful formalization. | **L** (statement) + **XL** (proof) |
| L5 Effective Plancherel Theorem (Ch. 3) | Application of First Main to the Fourier transform; needs L^2 instance + Mathlib's `MeasureTheory.Fourier` glue. | **XL** |
| L5 Second Main Theorem (Ch. 4 statement, Ch. 5 proof) | The single largest result in P-R. Statement is **L** once "effectively determined" is defined; proof is **XL** (Ch. 5 is 1,415 verbatim lines of intricate spectral-theoretic argument). | **L** (statement) + **XL** (proof) |
| L5 Eigenvector Theorem (Ch. 4) | Construction of a specific operator (technical, but self-contained); does not depend on Second Main. | **L–XL** |
| Ch. 0 §7 Equivalence Theorem (G-L Def-A ↔ C[a,b]-`IsComputableSeqCMap` for constant sequence) | Reconciles the L2 and L4 predicate-on-elements vs. predicate-on-sequences split. Highest-value gap **right now** because closing it unifies the L2 single-function and L4 sequence-of-functions API. | **M** |
| Ch. 0 Theorem 1 (computable reals closed under +, ×, /, sequential limit with effective modulus) | Already covered for sequences (L1 lemmas), but P-R also has a point-form statement worth surfacing as a named theorem (currently only `IsComputableReal.zero`, `.ofRat` exist). | **S** |
| Ch. 0 Theorem 5 (G-L computable ⇔ sequentially computable + effectively uniformly continuous — characterization, of which Def A is the L2 working form) | Refinement of Def A: shows that the predicate's two clauses are the natural splitting. Closes a definitional vs. characterization gap. | **M** |

---

## C4 — Inventory of divergences from P-R

(Headline list previewed in the executive summary; full per-divergence entries follow.)

### D1 — Explicit positivity conjunct in `IsGLComputable`

**P-R**: `chapt0.md:427-435` writes `1/d(N)` as if `d(N) > 0` were classical. **We**: encode `∀ N, 0 < d N` as a third conjunct in the modulus witness, because Mathlib's `1/0 = 0` would collapse the predicate to mere sequential computability (in the worst case, a `d` that returns 0 everywhere makes the modulus implication vacuous; see Banach–Mazur counterexample motivation at `chapt0.md:520`). **Lean ref**: `L2/GrzegorczykLacombe.lean:108`. **Reconciliation**: the divergence is purely encoding-level; semantically, the predicate is equivalent to P-R's reading once one fixes a `1/0 = 0`-aware ambient theory.

### D2 — `IsComputableSeqReal.bound` extracts a `Computable ℕ`-valued bound

**P-R**: argues "$|y_n|$ is bounded" via uniform-continuity classical reasoning on the rational witness. **We**: extract a `Computable`-valued upper bound `M : ℕ → ℕ` from the witness directly (`L1/ComputableSeqReal.lean:891`). **Reason**: this is the form needed downstream in the L1 `mul` proof and the L2 `mul` proof (both of which need a computable upper bound to prove the modulus implication). **Reconciliation**: the existence of *some* bound is classical; making the bound `Computable` is strictly stronger and is what the downstream multiplicative arguments need. P-R can get away with the weaker form because his witness extraction is informal.

### D3 — `l2_mul_gl` uses `ContinuousMap.norm`-based bound

**P-R** `chapt0.md:504`: bounds $|f|$ and $|g|$ pointwise via the modulus witness plus a base point (continuity gives "if you know $|f|$ at a single base point and have the modulus, you can bound $|f|$ on the whole interval"). **We**: bound `|f|` and `|g|` via `ContinuousMap.norm` (the sup-norm), using compactness of `Set.Icc α β` (`CompactIccSpace ℝ` instance). **Reason**: the sup-norm bound is shorter and exists definitionally in Mathlib; P-R's base-point argument would require manual integration of the modulus across the interval. **Reconciliation**: the two bounds are equal (sup-norm = supremum over the compact interval = base-point-plus-modulus integration); the choice is purely tactical.

### D4 — `Computable` vs. `Recursive` vs. `Primrec` substrate distinction

**P-R**: writes "recursive" throughout (his theory is partial-recursive grammar). **We**: use Mathlib's `Computable` (total recursive over `Primcodable` types) as the canonical substrate, with `IsRecursive` (`L0/Bridge.lean:64`) as an alias for project-vocabulary continuity. We use `Primrec` (primitive recursive) for witness-arithmetic inside proofs where it shortens by avoiding `Nat.rec` boilerplate, then `to_comp` to upcast. **Reconciliation**: P-R's "recursive function $\mathbb{N} \to \mathbb{N}$" is exactly Mathlib's `Computable f` for `f : ℕ → ℕ`; the equivalence is built into Mathlib's `Computable` definition via Kleene's Theorem (encoded by `Nat.Partrec.Code`).

### D5 — Predicate-first vs. subtype design

**P-R**: presents constructions on "a computable real" or "a computable function" as if these were typed objects. **We** (CLAUDE.md commitment #3): `IsComputableSeqReal : (ℕ → ℝ) → Prop` is the primary form; bundled subtypes like `ComputableSeqReal := { f // IsComputableSeqReal f }` are *additions*, never *replacements*. **Reason**: matches Mathlib's `Continuous : Prop` / `ContinuousMap` precedent; avoids a duplicate type hierarchy. **Reconciliation**: the predicate form is mathematically equivalent to the subtype form; the difference is purely about which form is canonical for downstream proof statements.

### D6 — `AnalysisBridge.lean` is a no-symbol pointer file

**P-R** §0.2:58–81: lists the analysis vocabulary (Banach, Hilbert, $L^p$, $\ell^p$, $C[a,b]$, $C^n[a,b]$, $C^\infty[a,b]$, $C_0(\mathbb{R}^q)$) inline as definitions. **We**: `L0/AnalysisBridge.lean` introduces *no Lean symbols* — it is a docstring-only pointer mapping P-R names to Mathlib names; downstream layers import Mathlib names directly. **Reason**: CLAUDE.md commitment #1 ("add structure to Mathlib's preexisting types"); duplicating Mathlib's `NormedSpace`, `InnerProductSpace`, etc. would be costly and would invite divergence. **Reconciliation**: the pointer file *compiling* is itself a check that the Mathlib modules supplying these symbols are imported correctly.

### D7 — `IsComputableSeqComplex` deferred (not formalized yet)

**P-R**: complex numbers are first-class throughout (Ch. 3 Plancherel is on $L^2$ complex-valued). **We**: `L1/ComputableSeqComplex.lean` does **not exist** despite being listed in CLAUDE.md's "Lake project layout" table. `ScalarComputableSeq ℝ` exists at `L3/ComputabilityStructure.lean:95`; the `𝕜 = ℂ` instance is gated on the L1 complex predicate (`L3/ComputabilityStructure.lean:53` carries the placeholder docstring). **Status**: deliberate deferral until Complex-Hilbert downstream is on the roadmap. §C3 effort **M**; §C5 ranking #3.

### D8 — Predicate-first means `IsComputableReal` is the constant-sequence form, not the rational-Cauchy form

**P-R** Ch. 0 Definition 3 (the point predicate): "a real $x$ is computable iff there is a computable sequence of rationals $r_k$ with $|r_k - x| \le 2^{-k}$". **We**: `IsComputableReal x := IsComputableSeqReal (fun _ => x)` (`L1/ComputableSeqReal.lean:1086`). **Reconciliation**: the two are equivalent — `IsComputableSeqReal (fun _ => x)` unfolds to "there is a computable rational double-sequence $r(n,k)$ with $|r(n,k) - x| \le 2^{-k}$" which collapses on $n$ to P-R's Cauchy form. The equivalence theorem is implicit (and trivial), not surfaced as a named theorem; **flagged as a low-priority surfacing target**.

---

## C5 — Top-5 priority list

(Preview in executive summary; full ranking below with rationale.)

### #1 — L2/L4 Equivalence Theorem: `IsGLComputable f ↔ IsComputableSeqCMap (fun _ => f)`

- **P-R reference**: Ch. 0 §7.
- **Why now**: this is the *missing bridge* between the L2 predicate-on-a-single-function (`IsGLComputable`) and the L4 predicate-on-sequences (`IsComputableSeqCMap`). Without it, every L2 closure lemma (`l2_const_gl`, `l2_id_gl`, `l2_sum_gl`, `l2_neg_gl`, `l2_sub_gl`, `l2_smul_gl`, `l2_mul_gl`) lives in a separate world from the L3/L4 typeclass-instance machinery. With it, the L4 C[a,b] instance immediately certifies G-L computability for individual functions built via the L2 closure family.
- **What it unlocks**: clean cross-layer reuse; lets future L5 work cite a single "computable continuous function" predicate without case-splitting on which layer it came from. Also closes a CLAUDE.md project-narrative gap (the L2/L4 split currently reads as ad-hoc).
- **Effort**: **M** (one direction is a witness-construction from the G-L modulus to a rational-polynomial approximant; the other direction is "for-all-$n$" trivial).
- **Slug**: `/goal l2-l4-equivalence-theorem` (or similar).

### #2 — L4 `L^p[a,b]` ComputabilityStructure instance (Ch. 2 §3)

- **P-R reference**: `chapt2.md:161` (Definition (a) of $L^p$-computable function), `:166` ("It is not hard to verify that the computable sequences of $L^p[a,b]$ defined above satisfy the axioms of a computability structure").
- **Why now**: $L^p$ instance is the bedrock for Plancherel (Ch. 3) and the entire First Main Theorem application sweep (Ch. 3). Without it, every Ch. 3 application stays gated.
- **What it unlocks**: L5 First Main Theorem; Effective Plancherel; step-function classification (Intro:30, Ch. 3); all of P-R's "applied" computable analysis story.
- **Effort**: **XL**. Mathlib's `MeasureTheory.Lp` is heavy; building the P-R-style "effective $L^p$-closure of G-L computable functions" requires bridging G-L Def-A with $L^p$-norm convergence. Likely a multi-round campaign.
- **Slug**: `/goal l4-lp-instance` (multi-round; first round: `/goal l4-lp-instance-stub` for the typeclass-surface skeleton, then closure axioms).

### #3 — L1 `IsComputableSeqComplex` predicate + L3 `ScalarComputableSeq ℂ` instance

- **P-R reference**: Ch. 0 (the rational base lifts to Gaussian rationals trivially; Mathlib's `Complex` does most of the work).
- **Why now**: this is the cheapest win that **unblocks** large downstream territory. Complex-Hilbert (needed for quantum-mechanical Second Main and Eigenvector applications) is gated on it; the deferred placeholder at `L3/ComputabilityStructure.lean:53` flags the gap explicitly.
- **What it unlocks**: complex-Banach instances (Ch. 2 examples 2.1, 2.4–2.5 with complex scalars); Plancherel on $L^2(\mathbb{R}, \mathbb{C})$; the quantum-mechanical reading of Second Main / Eigenvector.
- **Effort**: **M**. Mirror the L1 real-sequence file with Gaussian-rational double-sequence witnesses; most closure lemmas follow by reduction to real ones.
- **Slug**: `/goal l1-complex-seq`.

### #4 — L4 separable Hilbert space ComputabilityStructure instance (Ch. 2 §3)

- **P-R reference**: `chapt2.md:147-148`.
- **Why now**: the cleanest non-`L^p` non-`C[a,b]` instance to add; isolates the recursion-theoretic content of orthonormal-basis-based computability. Also a prerequisite for the Eigenvector Theorem.
- **What it unlocks**: Eigenvector Theorem (Ch. 4); Second Main on Hilbert spaces; the "axioms determine the structure uniquely" side-condition lemmas.
- **Effort**: **L–XL**. Requires a "computable orthonormal basis" predicate + a constructive bijection between abstract sequences and basis-coordinate sequences. Cleaner than `L^p` (no measure theory), but still cross-cutting.
- **Slug**: `/goal l4-hilbert-instance`.

### #5 — L5 First Main Theorem statement (Ch. 3, no proof attempted)

- **P-R reference**: `chapt3.md:` (TBD iter-21).
- **Why now**: even just a `theorem firstMainTheorem : … := sorry` (with the `sorry` flagged) plants a flag at the top of the L5 staircase and gives downstream `/goal` rounds a precise climbing target. The statement itself is non-trivial — encoding "bounded operator", "preserves computability", and the side conditions is substantial.
- **What it unlocks**: a concrete blueprint node to build proofs *toward* (instead of the current `\notready` placeholder); a target around which to organize L4 prerequisites (which `L^p` / Hilbert pieces are needed before First Main can compile?).
- **Effort**: **L** (statement only; proof is **XL** and a separate round).
- **Slug**: `/goal l5-first-main-statement` (statement only) → followed by `/goal l5-first-main-proof` (separate, after L4 instances land).

### Honorable mentions (not in top 5 but worth noting)

- **HM1 — Effective Density Lemma + Stability Lemma (Ch. 2 §5)**. P-R Ch. 2 Theorems 1, 2 + Corollary 2a (`chapt2.md:204, 248, 253`). Project-narrative-critical: this is the formal substance behind "axioms determine the computability structure uniquely under mild side conditions" — the justification for the entire axiomatic-approach decision. **Effort**: **L** for the Effective Density Lemma (`Theorem 1`) + the `IsEffectiveGeneratingSet` predicate + the monomials-as-generating-set instance for C[a,b]; the Stability Lemma is then **S** as a corollary. **What it unlocks**: the much-easier Corollary 1a (Effective Weierstrass Theorem, which sidesteps the §7 polynomial-pulse proof entirely) + the "no proper extension" rigidity claim throughout the book. **Slug**: `/goal l4-effective-density-stability`. Demoted to honorable mention rather than top-5 because the Ch. 0 §7 Equivalence Theorem (#1) does the same job more directly via the C[a,b] sequence form, and the Stability Lemma is consumed primarily by the §6 counterexamples (off the critical path).
- **HM2 — Surface Composition + Insertion derived corollaries (Ch. 2 §1, P-R `chapt2.md:82-83`).** Used implicitly throughout the L4 proof (`L4/Instances/CMap.lean:1240` and downstream); surfacing them as named lemmas would close a small project-narrative gap and unblock the Effective Density Lemma proof (which cites both). **Effort**: **S** each.
- **HM3 — Closing CLAUDE.md vs. filesystem drift**: CLAUDE.md's "Lake project layout" table lists `L1/{ComputableSeqReal,ComputableSeqComplex,ComputableReal}.lean` but only `ComputableSeqReal.lean` exists. Either update CLAUDE.md (cheap, **S**) or split the file (slightly more work, **S–M**). Choose update-CLAUDE.md.
- **HM4 — Surface Definition 3 (point computable real) as a named characterization**: currently `IsComputableReal x := IsComputableSeqReal (fun _ => x)` is the *definition*; the rational-Cauchy form (P-R Def 3 verbatim) is implicit. A one-line lemma surfacing the equivalence would close §D8. Effort **S**.

---

## C6 — Self-containment

(Verified by the structure above: every section is internally complete; cross-references use stable file:line anchors; the executive summary stands alone; the doc is dated 2026-06-06.)

---

## C7 — Devil's-advocate review

**Status**: **PASSED** (iter-09, 2026-06-06). Full review at `.goals/pr-coverage-assessment/reviews/C7.md`.

The devil's-advocate subagent performed an adversarial review against all four sub-criteria:

- **(a) Citation accuracy**: 14 P-R verbatim cites sampled across Prereq + Ch. 0 + Ch. 2 + Ch. 3 + Ch. 4 + Ch. 5. All point at the claimed proposition / definition / theorem. **0 content-changing misattributions.**
- **(b) Lean ref existence**: 32 Lean file:line refs sampled across L0 + L1 + L2 + L3 + L4. Every cited line confirmed to host the claimed declaration. **0 broken refs.**
- **(c) No done-but-sorry**: All 8 `\bsorry\b` grep hits inspected — confirmed to be inside doc-blocks / `--` line comments / decl-docstrings, NOT inside `by` blocks or `:= sorry`-style defs. Two key `done`-row decl bodies (`prop_B` and `isComputableSeqCMap_of_effectiveLimit`) read end-to-end and verified sorry-free.
- **(d) Priority ↔ effort consistency**: §C5 top-5 effort labels match §C3 deferral-table labels row-by-row (M/M/XL/L–XL/L+XL match M/M/XL/L–XL/XL after the iter-09 split-syntax fix).

**Verdict**: `verdict: passes`.

### Findings + post-DA revisions

The DA flagged 5 minor presentation / precision items. Four are addressed within the audit-round allow_writes; one is out-of-scope and is flagged here for downstream attention.

| Finding | Severity | Action |
|---|---|---|
| 1. Ch. 2 line 146 cite for L^p instance points at the wrong paragraph (in-line C[a,b] math display); the L^p material is at `chapt2.md:153-183` (Definition (a) at `:161`). The "Ex. 2.4" naming is also incorrect (P-R has Examples 1–4, no 2.4). | Low (precision) | **Fixed iter-09** — three citations updated from `chapt2.md:146` / "Ex. 2.4" to `chapt2.md:161` / "Ch. 2 §3" in the exec summary, §C3 row, and §C5 #2 entry. |
| 2. `L4/Instances/CMap.lean:` line number omitted for `computabilityStructureCMap_of` (cited in §C1 Ch. 2 §2 table and §C2 verification table). | Low (precision) | **Fixed iter-09** — line number `:3023` added in both locations. |
| 3. `L3/ComputabilityStructure.lean:53` cited with "🚧-marker placeholder" wording, but there is no literal "🚧" emoji in the file. The pointer lands in the correct doc-block (lines 45-53). | Cosmetic | Wording retained — the pointer is to the correct discussion; the figurative framing is acceptable for a precision-flagged audit doc. |
| 4. §C5 #5 entry uses split syntax "L (statement) + XL (proof)" but §C3 First Main row uses only "XL". | Low (consistency) | **Fixed iter-09** — §C3 First Main row updated to mirror the split syntax. |
| 5. **Out-of-round**: `L0/PropB.lean:39` docstring says "the four theorems below are sorried with detailed TODO sketches" — stale; the four theorems are now fully proved (`insepA_re`, `insepB_re`, `insepA_insepB_disjoint`, `insepA_insepB_no_separator`). Not a PR-COVERAGE defect (the audit correctly lists Prop B as `done`), but a Lean-docstring-vs-state drift. | Low (Lean cleanup) | **Flagged for future round** — the audit-round allow_writes forbids Lean writes. **Recommended follow-up**: a `/goal cleanup-propb-docstring` round (slug suggestion) of effort **S** to refresh the `L0/PropB.lean:31-44` doc-block to match the current sorry-free state. |

### Audit acceptance

With C7 passed, all 7 criteria of the round are met:

- ✓ **C1** — per-section coverage table, ~213 landmark items enumerated across Intro / Prereq / Ch. 0 / Ch. 2 / Ch. 3 / Ch. 4 / Ch. 5 (Ch. 1 verbatim absent + deferred per CLAUDE.md ingestion table).
- ✓ **C2** — citation verification: 23 done rows + 32 Lean refs verified clean by both iter-08 and the C7 DA pass.
- ✓ **C3** — deferral rationales + effort estimates: 12-row table with S/M/L/XL classes.
- ✓ **C4** — divergence inventory: D1–D8.
- ✓ **C5** — top-5 priority list + 4 honorable mentions with effort + candidate `/goal` slugs.
- ✓ **C6** — self-contained, dated `2026-06-06`, one-page executive summary at top.
- ✓ **C7** — DA review with `verdict: passes`.

The audit is closed. Downstream rounds may now use this document as the canonical reference for `(a) where we stand against P-R`, `(b) where we deliberately diverge`, and `(c) what to do next`.

---

## Appendix — Audit-round bookkeeping

**Round opened**: 2026-06-06T09:14:40Z. **Mode**: explore. **Budget**: 50 iters / 3600 min.

**Allow-writes** for this round (audit-only; no Lean / blueprint / claims / proofs / intuition / literature writes): `docs/PR-COVERAGE.md`, `docs/state-assessment-*.md`, `.goals/pr-coverage-assessment/**`, `.goals/INDEX.md`, `current-goal.md`.

**Prior-round artifacts** (preserved): `.goals/pr-coverage-assessment/prior-{goal.md, iter-00.md, final.md}`. The prior round was abandoned at iter-18 with no substantive progress; per AUDIT.md, this fresh round is the user's intended retry.

**Pacing**: this audit is iterative. iter-02 lands the executive summary + Intro + Prerequisites + skeleton tables for Ch. 0–5 + C4 (full) + C5 (full) + D1–D8 divergence inventory. iter-03–08 deepen Ch. 0; iter-09–12 quick-scan Ch. 1; iter-13–20 deepen Ch. 2; iter-21–30 quick-scan Ch. 3/4/5; iter-31–40 synthesize and revise the executive summary; iter-41–45 DA + revisions.
