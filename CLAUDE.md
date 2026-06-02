# CLAUDE.md — Computable Analysis in Mathlib4

## Mission

Build a Lean 4 formalization of Pour-El & Richards-style computable analysis
(*Computability in Analysis and Physics*, Cambridge UP 1989), intended for
upstream contribution to Mathlib4 under `Mathlib.Computability.Analysis.*`.

**Primary deliverable: Lean code at the repo root** (`lakefile.toml` + `ComputableAnalysis/`). Paper artifacts (`intuition/`,
`claims/`, `proofs/`, `literature/`) are *design infrastructure for the Lean
code* — useful when they accelerate getting working Lean, otherwise skip them.
The Lean type-checker is the final arbiter; Mathlib community review (Zulip) is
the human arbiter.

## Core architectural commitments

These are the technical decisions that shape the public API. They are
deliberately P-R-shaped — the alternative (TTE / represented spaces) is heavier
and less compatible with Mathlib's classical-analysis hierarchy.

1. **Add structure to Mathlib's pre-existing types.** A `ComputabilityStructure`
   typeclass on a Banach space `[NormedAddCommGroup E] [NormedSpace 𝕜 E]
   [CompleteSpace E]`. We do NOT define a parallel category of "computable
   Banach spaces". *(P-R intro:28,
   `literature/papers/PourEl-Richards-0.1.introduction.md:28`)*

2. **Sequences are primary, points are derived.** Predicates are stated on
   sequences `ℕ → α` first; a single element is computable iff its constant
   sequence is. *(P-R intro:7)*

3. **Predicates as primary form.** `IsComputableSeqReal : (ℕ → ℝ) → Prop` on
   Mathlib's `ℝ`. **No new `ℝ_c` type.** Bundled subtypes
   `ComputableSeqReal := { f // IsComputableSeqReal f }` are allowed where
   Mathlib idiom calls for it (compare `Continuous : Prop` and `ContinuousMap`).
   Use bundled forms only when the predicate form gets ergonomically
   unwieldy — they are *additions*, never replacements, for the predicate.

4. **Substrate is Mathlib's `Computable` / `Partrec`.** All recursion-theoretic
   predicates eventually unfold to `Computable f` for `f : ℕ → ℕ` (or
   higher-arity via `Primcodable`). No oracle Turing machines, Type-2 TMs,
   Baire-space realizers in the public API.

## Preferences — surface conflicts, don't auto-refuse

These are *preferences*, not bans. The earlier version of this file made them
"anti-goals" with hard refusal; experience showed that produced over-deference
and stalled progress. The new rule: if a P-R-shaped approach is awkward and a
non-P-R technique would clearly succeed, **try the technique and document the
conflict in a comment**. The public-facing API still lives under the P-R-shaped
commitments above.

- **P-R is the headline framework.** TTE / represented spaces / Weihrauch
  reducibility (Pauly, Brattka) and Bishop / Brouwer constructive frameworks
  are alternatives. Borrow techniques from them when they help; state results
  in P-R-shaped API.
- **Classical reasoning.** Mathlib is classical; we match.
- **Mathlib4 naming and style.** snake_case proofs, UpperCamelCase
  types/classes, `Is`-prefix for `Prop`-valued predicates, 100-char lines,
  `Type*` over `Type 0`, `autoImplicit false`.

## Workflow — lean-first by default

For prerequisites and standard textbook content:

1. Write the Lean file at `ComputableAnalysis/L<N>/<name>.lean` with a
   header docstring that quotes P-R verbatim and gives rationale.
2. `lake build` (from repo root). Fix until it compiles. The single-file check
   `lake env lean ComputableAnalysis/L<N>/<name>.lean` is faster than full build.
3. **Optional**: add a short `claims/<topic>/<id>.md` summary if the design is
   non-obvious. For pure aliases / namespace bridges, the Lean docstring
   suffices — no claim file required.
4. **Highly recommended**: post on Mathlib Zulip
   (`#new contributors` / `#Mathlib4`) for community feedback after each
   layer's stubs compile. Record threads under `docs/zulip-threads.md`.

For genuinely open research (novel theorems whose truth is uncertain, novel
proof strategies): the heavier `/intuition → /claim → /proof-attempt →
/devils-advocate` cadence is documented at `.claude/skills/` and the existing
`.goals/` infrastructure. Use it only when the textbook isn't the spec.

The `/goal` autonomous-iteration pattern and devil's-advocate review cycle were
designed for open mathematical research where conjecture-truth is uncertain. For
*formalization* of a 1989 textbook, the type-checker is a better verifier than
DA paper review. Default to lean-first.

## Five-layer architecture

| Layer | Content | P-R chapter | Lean target |
|---|---|---|---|
| L0 | Recursion bridge + analysis-prerequisites pointer | Ch. 0.2 | `ComputableAnalysis/L0/{Bridge,PropB,AnalysisBridge}.lean` |
| L1 | Computable reals + computable sequences | Ch. 0 | `ComputableAnalysis/L1/{ComputableSeqReal,ComputableSeqComplex,ComputableReal}.lean` |
| L2 | Grzegorczyk-Lacombe computable continuous functions | Ch. 0–1 | `ComputableAnalysis/L2/GrzegorczykLacombe.lean` |
| L3 | `ComputabilityStructure` typeclass on Banach spaces | Ch. 2 | `ComputableAnalysis/L3/ComputabilityStructure.lean` |
| L4 | Instances: `C[a,b]`, `L^p`, separable Hilbert | Ch. 2+ | `ComputableAnalysis/L4/Instances/*.lean` |
| L5 | First/Second Main Theorems, Eigenvector Theorem | Ch. 3–5 | `ComputableAnalysis/L5/*.lean` |

## Lake project layout

```
(repo root)
  lakefile.toml              ← Mathlib4 git dependency, autoImplicit false
  lean-toolchain             ← matches Mathlib4 master (currently v4.31.0-rc1)
  lake-manifest.json         ← pinned Mathlib commit (auto-written by `lake update`)
  ComputableAnalysis.lean    ← umbrella import
  ComputableAnalysis/
    L0/{Bridge,PropB,AnalysisBridge}.lean
    L1/…
    L2/…
    L3/…
    L4/Instances/…
    L5/…
  blueprint/                 ← leanblueprint sources (added 2026-06-02 transition)
    src/{content,L0,L1,…}.tex
```

Lake convention: module `ComputableAnalysis.L0.Bridge` ↔ file
`ComputableAnalysis/L0/Bridge.lean`. The `[[lean_lib]]` name `ComputableAnalysis`
is the directory root at git root (sibling to `lakefile.toml`), with the umbrella `.lean` next to it. *Hoisted from `formal/` on 2026-06-02 to satisfy `leanblueprint`'s lakefile-at-git-root assumption.*

See `docs/SETUP.md` for first-time install steps (elan + lake update + cache get).

## `sorry` policy

- **Allowed:** theorem and lemma proof bodies while the formal proof matures.
- **Forbidden:** `def` / `structure` / `class` / `instance` / `abbrev` bodies
  (these define the public API; if the body isn't concrete, the milestone isn't
  ready and the file isn't committable).
- Every `sorry` carries a `-- TODO(/formalize L<N>):` comment naming the
  obstruction.

## Status taxonomy (claim files)

Every `claims/<topic>/<id>.md` carries one label in YAML frontmatter:

| Label | Meaning |
|---|---|
| `intuition` | Informal idea. Not a claim of truth. |
| `conjecture` | Precise statement we believe but cannot yet prove. |
| `our_construction` | Definition or object we introduce. |
| `cited_result` | Theorem from the literature. Source pointer required. |
| `verified` | Complete paper proof, audited. *Intermediate.* |
| `formalized` | Lean file type-checks; predicate/structure bodies sorry-free. **Terminal.** |
| `refuted` | Previously held; now broken. Counterexample required. |

`formalized` is the terminal state for milestones. `verified` (paper-only) is
intermediate. A milestone with only a paper proof and no Lean stub is **not**
done.

## Mathlib community engagement (do this!)

- After L0 stubs compile: post to Zulip `#new contributors` with a 3-paragraph
  project pitch + link to repo. Mention the P-R framework choice explicitly and
  invite challenges.
- After L3 axioms stub compiles: post to `#Mathlib4`. Brattka, Pauly, Schröder
  read that stream; their input on the P-R-vs-represented-spaces tension is
  high-value.
- Record significant threads at `docs/zulip-threads.md` (one section per thread,
  links + 1-paragraph summary).
- Adapt the design based on feedback BEFORE building the next layer.

## Looking up a result

1. `literature/INDEX.md` → paper key.
2. `literature/papers/<key>/` — for P-R, per-chapter files
   (`PourEl-Richards-chapt<N>.md`, intentionally flat layout for navigability of
   a 600-page textbook); for other papers, the canonical `verbatim.md`
   structure. **Any theorem cited in a proof must quote verbatim from the
   relevant file, with a `file:line` pointer.**
3. Lean files cite via comment: `-- ref: literature/papers/<key>:LINE`.

## Milestone tracker

Status values: `pending` (not started) → `in-progress` (work begun) → `stub`
(Lean file exists with sorries) → `formalized` (Lean type-checks; predicates
sorry-free) → `done` (Lean type-checks AND theorems sorry-free; terminal).

### Corpus ingestion (P-R chapters)

| Chapter | Topic | Status | Pointer |
|---|---|---|---|
| Intro | — | `done` | `literature/papers/PourEl-Richards-0.1.introduction.md` |
| Prerequisites | Logic + analysis recap | `done` | `literature/papers/PourEl-Richards-0.2.prerequisites.md` |
| Ch. 0 | Computable reals + G-L continuous functions | `done` | `literature/papers/PourEl-Richards-chapt0.md` |
| Ch. 1 | Differentiation, analytic functions | `pending` | — (deferred; needed for advanced L2 results) |
| Ch. 2 | Axiomatic computability structure (keystone) | `done` | `literature/papers/PourEl-Richards-chapt2.md` |
| Ch. 3 | First Main Theorem + applications | `done` | `literature/papers/PourEl-Richards-chapt3.md` |
| Ch. 4 | Second Main Theorem + Eigenvector Theorem | `done` | `literature/papers/PourEl-Richards-chapt4.md` |
| Ch. 5 | Proof of Second Main Theorem | `done` | `literature/papers/PourEl-Richards-chapt5.md` |

### Construction milestones

| Layer | Milestone | Status | Lean target | Pointer |
|---|---|---|---|---|
| L0 | Map P-R logic prerequisites onto Mathlib's `Computability.*` | `done` | `ComputableAnalysis/L0/Bridge.lean` | Lean file (0 sorries; `cantorPair_computable` closed via `Primrec₂` composition) |
| L0 | Recursively inseparable pair (P-R Prop. B) | `done` | `ComputableAnalysis/L0/PropB.lean` | Lean file (0 sorries; all 4 lemmas proven; `no_separator` via `Code.fixed_point₂`) |
| L0 | Analysis prerequisites pointer (Banach/Hilbert/Lp/etc) | `done` | `ComputableAnalysis/L0/AnalysisBridge.lean` | Lean file (0 sorries; smoke-test `L^p` example now takes abstract measure to avoid Lebesgue import) |
| L1 | `IsComputableSeqReal` definition | `done` | `ComputableAnalysis/L1/ComputableSeqReal.lean` | Lean file (0 sorries; constant-sequence helpers `isComputableSeqRat_const` / `isComputableSeqReal_const_rat` closed via `Nat.cast_natAbs` + `Int.cast_abs` + sign case-split; `conv_lhs` to avoid `Rat.num_div_den` rewriting under projections) |
| L1 | `IsComputableSeqComplex` definition | `claimed` | `ComputableAnalysis/L1/ComputableSeqComplex.lean` | `claims/l1-computable-reals/is-computable-seq-real.md` (deferred — out of scope for `execute-docs-next-session-md`) |
| L1 | `IsComputableReal` definition | `pending` | `ComputableAnalysis/L1/ComputableReal.lean` | — |
| L1 | Computable reals form a countable subfield of ℝ | `pending` | `ComputableAnalysis/L1/SubfieldStructure.lean` | — |
| L2 | Grzegorczyk-Lacombe computable continuous function definition | `pending` | `ComputableAnalysis/L2/GrzegorczykLacombe.lean` | — |
| L2 | Closure properties of G-L computable functions | `pending` | `ComputableAnalysis/L2/GLClosure.lean` | — |
| L3 | `ComputabilityStructure` typeclass — three axioms | `formalized` | `ComputableAnalysis/L3/ComputabilityStructure.lean` | Lean file (0 sorries; class with 5 fields encoding A1/A2/A3 + NV; auxiliary `ScalarComputableSeq` typeclass with ℝ instance via L1) |
| L3 | Uniqueness theorem under mild side conditions | `pending` | `ComputableAnalysis/L3/Stability.lean` | — |
| L4 | Instance: `C([a,b], ℝ)` with sup norm | `stub` | `ComputableAnalysis/L4/Instances/CMap.lean` | Lean file (def/instance bodies sorry-free; predicate via P-R Ch. 2:141 polynomial-approximation form; `zero_seq` proven; A1/A2/A3 theorem-body sorries with `-- TODO(/formalize L4 CMap):` and explicit P-R citation in each TODO). **Round `l4-cmap-axiom-linearity` (2026-06-02, budget-exhausted): shipped `private theorem isComputableSeqRat_add` (~80 lines, fully proved) inline at top of file — closure of `IsComputableSeqRat` under pointwise addition, with `-- TODO(refactor → L1):` for a future move. A1 itself still sorry (needs `_mul`/`_reindex`/`_finsetSum` + witness assembly).** |
| L4 | Instance: `L^p[a,b]` | `pending` | `ComputableAnalysis/L4/Instances/Lp.lean` | — |
| L4 | Instance: separable Hilbert space | `pending` | `ComputableAnalysis/L4/Instances/Hilbert.lean` | — |
| L5 | First Main Theorem (Ch. 3) | `pending` | `ComputableAnalysis/L5/FirstMainTheorem.lean` | — |
| L5 | Effective Plancherel theorem | `pending` | `ComputableAnalysis/L5/Plancherel.lean` | — |
| L5 | Second Main Theorem (Ch. 4) | `pending` | `ComputableAnalysis/L5/SecondMainTheorem.lean` | — |
| L5 | Eigenvector Theorem (Ch. 4) | `pending` | `ComputableAnalysis/L5/Eigenvector.lean` | — |
