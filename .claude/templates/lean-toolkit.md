# Lean 4 / Mathlib4 toolkit — reference

Load on demand from inside `/formalize`. The persona (`lean-prodigy-persona.md`) is the character; this is the cheat sheet. Skim, don't memorize. Quote URLs when you want to verify the current API; Mathlib evolves.

---

## 1. Search engines

The first reflex in `/formalize` is *search before define*. Use in this order of precision.

| Engine | URL | Use when… | Notes |
|---|---|---|---|
| `exact?` | tactic inside a proof | the goal "feels like a known lemma"; you want a *closer* | only returns goal-closing matches; cheap and accurate |
| `apply?` | tactic | structural goal that an existing lemma should reduce | lower bar than `exact?`; returns sub-goals if any |
| `rw?` | tactic | one subterm wants to be rewritten into another form | finds rewrite lemmas; great for `Eq` chains |
| `simp?` | tactic | proof drafted with `simp`; want the explicit lemma list | replace non-terminal `simp` with `simp only [...]` from output |
| `rw_search` | tactic | several rewrites chained | slower; use when `rw?` finds the wrong start |
| `hint` | tactic | "kitchen sink" — try all standard closers | last resort before manual proof |
| Loogle | https://loogle.lean-lang.org/ | you know the *type signature shape*, not the name | search by subexpression, e.g. `|- _ * _ = _ * _ → _` |
| LeanSearch | https://leansearch.net/ | natural-language description; LaTeX | semantic; "approximately the right lemma" lands top-5 |
| Moogle | https://www.moogle.ai/ | natural-language; alternative to LeanSearch | vector-DB; sometimes better on mathematical synonyms |
| LeanExplore | https://www.leanexplore.com/ | importance-weighted ranking across packages | PageRank-style; good for "what's the central lemma in area X" |
| LeanFinder | https://arxiv.org/abs/2510.15940 | when LeanSearch returns near-misses | newer (Oct 2025), claims ~30% improvement on intent match |
| Mathlib source | https://github.com/leanprover-community/mathlib4 | when you have a file path and want the surrounding context | use `lean-search-client` from inside the editor, or WebFetch the raw file |

**Workflow recipe.** Inside a proof: try `exact?`. If no match, type the goal's signature into loogle. If still nothing, paste the natural-language statement into LeanSearch. If still nothing, the lemma probably does not exist — write it as a small `lemma` of its own.

**The `LeanSearchClient` in-editor command** lets you write `#leansearch "natural-language query"` directly in the file; results paste into the editor. Same for `#loogle |- type sig`.

---

## 2. The tactic ladder

When the search ladder finds the closing lemma, you're done. When it doesn't, you reach for a tactic. Tactics are *ordered* — try the most specific first; only fall back to general-purpose tactics when nothing fits.

### Arithmetic / algebraic identities
- **`rfl`** — definitional equality. Always try first; it's free.
- **`ring`** — commutative ring identity (no hypotheses needed). For `(a + b)^2 = a^2 + 2*a*b + b^2`.
- **`ring_nf`** — normalizing form (useful when both sides need rearranging before another tactic).
- **`field_simp`** — clear denominators. Standard preamble before `ring` when fractions appear: `field_simp; ring`.
- **`module`** — like `ring` but for modules / abelian groups.
- **`abel`** — abelian group normalization.
- **`group`** — group identity (no commutativity).
- **`linear_combination h1 + 2 * h2`** — close an equality-in-rings goal from a user-supplied linear combination.

### Inequalities
- **`linarith`** — linear arithmetic over ordered fields, from existing hypotheses. *Workhorse.*
- **`nlinarith`** — nonlinear preprocessing; closes some products / squares.
- **`polyrith`** — multivariate polynomial; uses external SageMath (requires network). Try `linarith`/`nlinarith` first.
- **`positivity`** — proves `0 < x` / `0 ≤ x` structurally.
- **`bound`** — bridges `0 ≤ x` and `x ≤ y` style; overlaps `positivity`/`gcongr`.
- **`gcongr`** — generalized congruence: `f a ≤ f b` from `a ≤ b` using registered rules. Great inside sums / products.
- **`mono`** — monotonicity; similar to `gcongr`.

### Natural number / integer arithmetic
- **`omega`** — *Presburger over `ℕ`/`ℤ`*. Scott Morrison's contribution. Closes goals like `n + 1 < 2 * n + 3`.
- **`decide`** — closes a `Decidable` goal by kernel computation. Slow on non-trivial decidable instances.
- **`norm_num`** — numerical normalization over `ℕ, ℤ, ℚ, ℝ, ℂ`; handles `+ − × / ⁻¹ ^ %` and `=, ≠, <, ≤` on numerals.

### Logical / set-theoretic
- **`exact h.elim`** / **`exact h.left`** etc. — destruct hypotheses inline.
- **`tauto`** — propositional tautology.
- **`itauto`** — intuitionistic version.
- **`simp [...]`** — rewriting with the simp set; squeeze with `simp only [...]` for committed code (use `simp?` to get the list).
- **`aesop`** — extensible proof search. Reads `@[aesop ...]` rules. Default config tries `simp`, `constructor`, `exact?`, splits, and a backtracking apply-search.
- **`aesop?`** — shows what `aesop` tried; useful for debugging or extracting an explicit proof.

### Heavyweight automation
- **`hint`** — "try everything reasonable".
- **`exact?` / `apply?` / `rw?`** — already in the search ladder; they are tactics too.
- **`polyrith`** — external Sage call.

### Common closers for `Iff`, `Eq`, ∀, ∃
- **`Iff.intro`** + `.mp` / `.mpr` for explicit bidirectional.
- **`funext`** — function extensionality.
- **`ext x`** — extensionality (works for many structures; uses `@[ext]` lemmas).
- **`use t`** — provide the witness for `∃`.
- **`refine ⟨_, ?_⟩`** — anonymous constructor with named holes.
- **`obtain ⟨a, b, h⟩ := h2`** — destructure existentials and conjunctions.
- **`rintro ⟨a, b⟩ ⟨c, d⟩ rfl`** — recursive intro with pattern destructuring.

### Calc-block discipline
```lean
calc a = b   := by ring
  _ ≤ c    := by gcongr; positivity
  _ = d    := h₃
```
Calc blocks are *highly* readable. Mathlib reviewers prefer them over long `rw` chains for nontrivial equalities/inequalities.

### `show` and `change` for goal manipulation
- **`show <expr>`** — assert what you believe the goal is (after some `simp`s, often the displayed goal is not what you want to work with definitionally).
- **`change <expr>`** — like `show` but accepts any definitionally equal form.

---

## 3. Mathlib naming bible (full)

Quoted from `https://leanprover-community.github.io/contribute/naming.html`. These are *rules*, not preferences.

### Capitalization

- **Proofs / theorems / lemmas** — `snake_case`. `add_comm`, `Nat.mul_pos`.
- **Types, structures, classes, propositions** — `UpperCamelCase`. `Real`, `IsCompact`, `NormedSpace`.
- **Definitions of `Type`/`Sort` (other than propositions)** — `UpperCamelCase`.
- **Definitions returning a `Prop`** — `snake_case`.
- **Definitions returning a `Type`** — `UpperCamelCase`.
- **Otherwise** — `lowerCamelCase`. `Real.toNNReal`, `Finset.image`.

When a `snake_case` thing dots into an `UpperCamelCase` thing, the joining piece is `lowerCamelCase`: `MonoidHom.toOneHom_injective`.

### Theorem-name structure

- **Conclusion first, hypotheses after `of`.** `lt_of_succ_le : succ n ≤ m → n < m`.
- **Iff-lemmas use `_iff_`.** `add_pos_iff_pos_or_pos : 0 < a + b ↔ 0 < a ∨ 0 < b`.
- **Standard abbreviations.**
  - `pos`, `neg`, `nonpos`, `nonneg` — preferred over `zero_lt`, `lt_zero`, `le_zero`, `zero_le`.
  - `mul`, `div`, `add`, `sub`.
  - `eq`, `ne`, `le`, `lt`, `ge`, `gt`.
- **Predicates as nouns get `Is`-prefix.** `IsTopologicalRing`, `IsCompact`, `IsComputableReal`. Adjectives skip it (`Normal`, `Finite`).
- **Structural suffixes:** `_iff_`, `_of_`, `.ext`, `.ext_iff`, `_inj`, `_injective`, `_surjective`, `_monotone`, `_antitone`, `_strictMono`, `_left`, `_right`.
- **Acronyms grouped, case from first letter.** `LE`, `Ne` (not `NE`), `IsROrC`.

### Logical connectives use dot-namespace

- `And.intro`, `And.left`, `And.right`
- `Or.inl`, `Or.inr`, `Or.elim`
- `Eq.refl`, `Eq.trans`, `Eq.symm`
- `Iff.mp`, `Iff.mpr`, `Iff.intro`
- `Not.intro`

### Spelling

**American English.** `factorization`, `localization`, `neighborhood`, `behavior`. Never `factorisation`, `localisation`, `neighbourhood`, `behaviour`.

### File-header convention

Every Mathlib file opens with:
```lean
/-
Copyright (c) <YEAR> <Author Name>. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: <Author Name>
-/
import Mathlib...

/-!
# <Title>

<one-paragraph summary>

## Main definitions

* `Foo` — ...
* `Bar.baz` — ...

## Main theorems

* `Foo.bar_iff_baz` — ...

## Notation

...

## References

* [...] (`literature/papers/<key>:LINE`)

## Tags

<tag>, <tag>
-/
```

For this project, replace `<Author Name>` with `the mathlib-computable-analysis contributors`. The `## References` block must point to `literature/papers/<key>:LINE` since that is our internal canonical source.

---

## 4. Anti-patterns

These come up often enough that they get their own list.

- **Non-terminal `simp` in committed code.** Mid-draft is fine; commit must be `simp only [explicit_lemmas]` so future Mathlib evolution doesn't silently break the proof.
- **`@[simp]` whose LHS is simpler than RHS.** Will cause `simp` to loop or to *unsimplify*. Always check direction.
- **`decide` on non-decidable.** Fails immediately; even when decidable, large search spaces time out the kernel.
- **`rfl` on goals that need `simp`.** `rfl` checks definitional equality, not propositional. If the goal is `a + b = b + a` for non-trivial `a, b`, `rfl` fails; use `ring` or `Nat.add_comm`.
- **Diamond inheritance.** When extending two parent typeclasses that share a grandparent, beware non-defeq instance paths. The "forgetful inheritance" pattern (Wieser, Baanen) is the standard fix.
- **`autoImplicit true`** lets typos become silent universe-polymorphic variables. Mathlib disables it; this project's `lakefile.toml` should too.
- **`Type 0` instead of `Type*`.** Universe-monomorphism is almost always an accident.
- **`repeat` / `all_goals` without bounds.** Can loop. Prefer explicit iteration counts or named goal-handling.
- **`exact?` on a goal you have not `intro`'d yet.** Always `intro` first; `exact?` searches for the *current* goal state.
- **`sorry` in a `def`/`structure`/`class`/`instance`.** Already covered in the persona (R4). Refuse.

---

## 5. Computable-analysis-specific Mathlib lookup map

Project-specific. The current pinned Mathlib commit (see `lake-manifest.json` at repo root) is authoritative; the names below may have shifted. Always verify with `exact?` / `#check`.

### L0 — recursion-theoretic bridge

| P-R term | Mathlib hook |
|---|---|
| primitive-recursive function | `Mathlib.Computability.Primrec` |
| partial-recursive function | `Mathlib.Computability.Partrec` |
| computable function `ℕ → ℕ` | `Nat.Partrec.Code`, `Nat.RecursivelyEnumerable` |
| Cantor pairing | `Nat.pair`, `Nat.unpair`, `Nat.pair_lt_pair_iff_lt`-family |
| recursively enumerable set | `Set.RecursivelyEnumerable` |
| recursive set | `Set.Recursive` |
| recursively inseparable pair (P-R Prop. B) | not in Mathlib; this is an `our_construction` we build |
| halting problem | `Nat.Partrec.Code.eval_part`-family; see Carneiro arXiv:1810.08380 |

### L1 — computable reals and sequences

| P-R term | Mathlib hook |
|---|---|
| computable sequence of rationals | not bundled; we predicate using `Computable` from `Mathlib.Computability.Partrec.Computable` |
| computable real | not in Mathlib; we define `IsComputableReal : ℝ → Prop` |
| computable sequence of reals | `IsComputableSeqReal : (ℕ → ℝ) → Prop` |
| computable sequence of complexes | `IsComputableSeqComplex : (ℕ → ℂ) → Prop` |
| Cauchy with effective modulus | combine `IsCauSeq` (Mathlib) with effective modulus predicate |
| ambient real type | `Real` from `Mathlib.Data.Real.Basic` — *we predicate over this, never replace it* |

### L2 — computable continuous functions (Grzegorczyk–Lacombe)

| P-R term | Mathlib hook |
|---|---|
| continuous function on `[a,b]` | `ContinuousMap (Set.Icc a b) ℝ` from `Mathlib.Topology.ContinuousFunction.Basic` |
| effective modulus of continuity | predicate to define |
| effectively uniformly continuous | predicate combining `UniformContinuous` + computable modulus |
| computable continuous function | `IsGLComputable : C(Set.Icc a b, ℝ) → Prop` |

### L3 — computability structure (keystone)

| P-R term | Mathlib hook |
|---|---|
| Banach space | `NormedSpace ℝ E` + `CompleteSpace E` from `Mathlib.Analysis.NormedSpace.Basic` |
| inner product space / Hilbert | `InnerProductSpace ℝ E` + `CompleteSpace E` |
| linearity (P-R Axiom 1) | use `LinearMap`-like phrasing for rational combinations |
| sequential limit closure (P-R Axiom 2) | use `Tendsto`, `Filter.atTop`, effective modulus |
| computable norm (P-R Axiom 3) | references the L1 `IsComputableSeqReal` predicate |
| `ComputabilityStructure` (our typeclass) | new — class on `[NormedSpace ℝ E] [CompleteSpace E]` |

### L4 — concrete instances

| P-R term | Mathlib hook |
|---|---|
| `C([a,b], ℝ)` with sup norm | `ContinuousMap (Set.Icc a b) ℝ` already has the sup-norm instance via `ContinuousMap.boundedContinuousFunction` |
| `L^p[a,b]` | `MeasureTheory.Lp` from `Mathlib.MeasureTheory.Function.LpSpace.Basic` |
| separable Hilbert space | `InnerProductSpace ℝ E`, separable via `SecondCountableTopology E` or `Module.Free.Finite ℝ E` patterns |

### L5 — main theorems

| P-R result | Lean target |
|---|---|
| First Main Theorem (Ch. 3) | `ComputableAnalysis/L5/FirstMainTheorem.lean` |
| Plancherel | `ComputableAnalysis/L5/Plancherel.lean` |
| Second Main Theorem (Ch. 4) | `ComputableAnalysis/L5/SecondMainTheorem.lean` |
| Eigenvector Theorem (Ch. 4) | `ComputableAnalysis/L5/Eigenvector.lean` |

---

## 6. Kernel-reach commands

For sanity-checking from inside a Lean file. These do not contribute to the build but help you debug interactively.

- **`#check t`** — print the type of `t`.
- **`#check @t`** — print the type with all implicits explicit.
- **`#eval e`** — evaluate `e` (only works for decidable / computable terms).
- **`#print Foo`** — print the definition of `Foo`.
- **`#print axioms thm`** — print which axioms `thm` ultimately depends on. *Use this to detect `sorry`/`Classical.choice` reliance on important theorems.*
- **`#reduce e`** — reduce `e` to normal form (slow; use sparingly).
- **`#find _ : ?_ → ?_`** — search by type signature inside the editor (LeanSearchClient).

Every file the project commits has a `-- ## Smoke checks` block at the end with `#check` lines for each exported symbol. This is *not optional* — it documents the public surface and breaks loudly if a rename ships without updating dependent code.

---

## 7. The `#print axioms` discipline

When a theorem is "done", run `#print axioms <name>` and verify the dependencies are clean:

- `Classical.choice` — acceptable in classical Mathlib (CLAUDE.md commitment #4 makes this explicit).
- `Quot.sound`, `propext` — Lean foundations; acceptable.
- `sorryAx` — **FAILS**. The theorem has a `sorry` somewhere transitively. Find and fill it.

A theorem cannot be marked `formalized` in the milestone tracker (CLAUDE.md) if `#print axioms` shows `sorryAx`.

---

## 8. Lake / build commands the agent uses

From the repo root (post-2026-06-02 hoist):

- `lake update` — pulls Mathlib at the version specified in `lakefile.toml`; regenerates `lake-manifest.json`.
- `lake exe cache get` — downloads pre-built Mathlib oleans from the CI cache. *Always do this before `lake build` after a `lake update`*, or the first build takes hours.
- `lake build` — compiles the project's own code (and any uncached deps).
- `lake env lean <file.lean>` — type-checks a single file in the project environment. Faster feedback than `lake build` for one-file edits.
- `lake env -- python3 <script.py>` — run a script with `LEAN_PATH` set so import resolution matches the project.

The `/formalize` preflight runs these. You should not run them manually unless explicitly asked.

---

## 9. Loading-on-demand

This toolkit is intentionally long. You do *not* read the whole thing every session. The persona (`lean-prodigy-persona.md`) is always loaded; this is loaded *as needed*:

- §1 (search) — every time you can't find a lemma.
- §2 (tactic ladder) — every time arithmetic / inequality closes a gap.
- §3 (naming) — every time you create a new symbol.
- §4 (anti-patterns) — every time you reach for `decide`, `simp`, or `aesop`.
- §5 (computable-analysis map) — every time you start a new layer file.
- §6–§7 (kernel-reach, `#print axioms`) — at the end of each session.
- §8 (lake commands) — only when the preflight script is unavailable.

When a session feels stuck, the first move is `read § n` for the n that matches the problem, not "ask another LLM".
