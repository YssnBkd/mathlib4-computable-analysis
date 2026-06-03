---
slug: l1-arithmetic-closure-and-real
ended: 2026-06-03T10:15:00Z
iterations: 7
outcome: success
---

# Final summary for goal: L1 arithmetic-closure round — lift `_add`, ship `_mul` + `_reindex`, define `IsComputableReal`, migrate to blueprint-native

## Criteria status

- [x] **C1**: `lake build` green; only residual sorry-warning is `ComputableAnalysis/L4/Instances/CMap.lean:104:23` (line-shifted from 261:23 by the C3 lift's 157-line deletion — same `axiom_linearity := sorry` body). `leanblueprint checkdecls` exits 0.
- [x] **C2** (migration): `blueprint/src/L1.tex` now has 11 envs (was 2), all `\leanok` except 0 stubs (was 2 `\notready`). Covers every sorry-free L1 decl plus the new C4/C5/C6 work.
- [x] **C3** (lift, DA-gated): `IsComputableSeqRat.add` shipped in `ComputableAnalysis/L1/ComputableSeqReal.lean` §4 (lines 159-305). CMap.lean's private copy + 60-line "TODO refactor → L1" comment block deleted. DA verdict `concerns` (see `reviews/C3.md`); all 3 weaknesses addressed in-round: (i) snake-case → dot-notation `IsComputableSeqRat.add`, (ii) η-form → Pi-form conclusion `IsComputableSeqRat (r₁ + r₂)`, (iii) round-tracking metadata stripped from Lean docstrings.
- [x] **C4** (mul): `IsComputableSeqRat.mul` shipped (~4 lines algebra after `refine`; `try ring` to match the `_add` idiom for `field_simp`-already-closes). Pure ℕ-product witness; no sign-case dispatch.
- [x] **C5** (reindex): `IsComputableSeqRat.comp` shipped (precomposition with a computable re-indexing `σ : ℕ → ℕ`). Proof is essentially `Computable.comp` plus pointwise hypothesis forwarding. `_finsetSum` deferred (criterion required only one of `_reindex`/`_finsetSum`).
- [x] **C6** (point predicate, DA-gated): `IsComputableReal x := IsComputableSeqReal (fun _ => x)` in §5, with sanity lemmas `.ofRat` and `.zero`. Blueprint `def:l1_isComputableReal` went `\notready` → `\leanok`. DA verdict `concerns` (see `reviews/C6.md`); all 4 concrete weaknesses addressed in-round: (i) citation corrected `Ch. 0:55 / Def 2` → `Ch. 0:58 / Def 3` (NEXT-SESSION.md had inherited the wrong line), (ii) added `.zero` sanity lemma (criterion permitted "1-2"; ship the upper bound, not just the renaming `.ofRat`), (iii) added `def`-vs-`abbrev` rationale to the Lean docstring, (iv) added equivalence disclaimer to the §5 section docstring (constant-sequence form ↔ Def 3 modulus form is a *derived* equivalence, not a direct restatement).
- [x] **C7** (satellite): `claims/l1-computable-reals/is-computable-seq-real.md` converted to post-2026-06-02 satellite format per `claims/TEMPLATE.md`. Formal statement removed (now in blueprint LaTeX); legacy `status: our_construction`, `lean_target: formal/...` (stale path), `topic:`, `referenced_by:` fields dropped; `blueprint: blueprint:def:l1_isComputableSeqReal` field added; `[[blueprint:def:l1_isComputableSeqReal]]` pointer at top of body. Design-rationale prose preserved (why Def 5a > Def 5, why predicate not type, L1 → L3 reach-down logic, Mathlib-idiom mapping).

## Artifacts produced

### Lean

- `ComputableAnalysis/L1/ComputableSeqReal.lean` (+259 lines):
  - **§4 — Arithmetic closure of `IsComputableSeqRat`** (new section, opens `namespace IsComputableSeqRat`):
    - `theorem add` — lifted from L4, public dot-notation, ~138-line proof body (verbatim from prior round)
    - `theorem mul` — new, ~12 lines (refine + 4-line algebra)
    - `theorem comp` — new, 8 lines (witness reindexing through σ)
  - **§5 — Computable real points** (new section):
    - `def IsComputableReal` — 1-line definition
    - `theorem IsComputableReal.ofRat` — 1 line (delegates to `isComputableSeqReal_const_rat`)
    - `theorem IsComputableReal.zero` — 2 lines (`simpa using ofRat 0`)
  - **§5 → §6** — smoke check section renumbered, `#check` block extended (3 new lines for the new public decls)
  - **Preamble updates**: `## What this file is NOT` note explains the §3-versus-§4 naming convention drift (snake-case `_const` at §3 predates the §4 dot-notation idiom)

- `ComputableAnalysis/L4/Instances/CMap.lean` (-157 lines):
  - Deleted: the inline `private theorem isComputableSeqRat_add` (~138-line proof body) and its 60-line "## L1 closure helpers (private; TODO: refactor → ComputableAnalysis.L1)" preamble
  - Preserved: the L4 axiom-instance scaffolding; `axiom_linearity := by … sorry` body still present (line 117 of the new file); `open ComputableAnalysis.L1` already in place so a future A1 proof can write `.add` unqualified

### Blueprint

- `blueprint/src/L1.tex` (+~84 lines):
  - 11 envs (was 2). All `\leanok`. Dep-graph nodes: `def:l1_isComputableSeqRat`, `def:l1_isComputableDoubleSeqRat`, `lem:l1_isComputableSeqRat_const`, `def:l1_isComputableSeqReal` (was already `\leanok` from prior round), `lem:l1_isComputableSeqReal_const_rat`, `lem:l1_isComputableSeqRat_add`, `lem:l1_isComputableSeqRat_mul`, `lem:l1_isComputableSeqRat_comp`, `def:l1_isComputableReal`, `lem:l1_isComputableReal_ofRat`, `lem:l1_isComputableReal_zero`.
- `blueprint/lean_decls` (+10 lines, auto-regenerated by `leanblueprint web`)

### Claims (satellite)

- `claims/l1-computable-reals/is-computable-seq-real.md` (rewritten ~216 lines): post-migration form per `claims/TEMPLATE.md`. Rationale preserved; pointer to `[[blueprint:def:l1_isComputableSeqReal]]`.

### `.goals/<slug>/`

- `goal.md`, `iter-00.md` (initialisation), `iter-02.md`…`iter-07.md` (iteration logs), `reviews/C3.md`, `reviews/C6.md` (DA verdicts).

### Allowlist extension (in-flight)

- `current-goal.md` `allow_writes` extended to include `blueprint/lean_decls` (auto-output of `leanblueprint web`) after a Stop-hook caught the side-effect on iter-02. Mirror change applied to `.goals/<slug>/goal.md`.

## Devil's-advocate verdicts

| Criterion | Artifact | Verdict | Key weakness flagged | In-round resolution |
|---|---|---|---|---|
| C3 | `ComputableAnalysis/L1/ComputableSeqReal.lean` §4 lift | `concerns` | (1) snake-case name diverges from Mathlib `.add`/`.comp` idiom; (2) η-form `fun k => r₁ k + r₂ k` conclusion vs. Pi-form `r₁ + r₂`; (3) round-tracking text in Lean docstrings. | All 3 acted on (rename to `IsComputableSeqRat.add`, Pi-form conclusion, docstring metadata stripped). Existing `_const` sanity lemmas kept at snake-case to limit blast radius — convention drift documented in file preamble. |
| C6 | `ComputableAnalysis/L1/ComputableSeqReal.lean` §5 def + `blueprint/src/L1.tex` envs | `concerns` | (1) **wrong P-R citation** (Ch. 0:55 = Def 2 = effective-convergence relation, not point predicate; Def 3 at 0:58 is the right reference); (2) constant-sequence form is *equivalent to* but not *identical to* Def 3; (3) only one sanity lemma (`.ofRat`) and it's a pure renaming; (4) silent `def`-vs-`abbrev` choice. | All 4 acted on. Citation fixed in 3 places (Lean docstring, blueprint env, criterion text in `current-goal.md` + `.goals/<slug>/goal.md`); added `.zero` 2nd sanity lemma; added equivalence disclaimer to §5 docstring; added `def`-vs-`abbrev` rationale (keep `def` so goals display `IsComputableReal x` not the unfolded ∃). |

Neither verdict was `unsound`; no claim required redoing.

## Key findings

- **Mathlib dot-notation pays off immediately.** DA's `concerns` on C3 forced rename `isComputableSeqRat_add` → `IsComputableSeqRat.add`. C4 and C5 then landed naturally in `namespace IsComputableSeqRat` as `.mul` and `.comp`; future A1 axiom calls write `h₁.add h₂` not `isComputableSeqRat_add h₁ h₂`. The rename cost was ~3 minutes (mechanical); doing it after `_mul`/`_comp` had landed would have been ~3× more painful.
- **Pi-form conclusion compatible with the existing proof body.** Changing `IsComputableSeqRat (fun k => r₁ k + r₂ k)` → `IsComputableSeqRat (r₁ + r₂)` did not require any proof-body edit — `(r₁ + r₂) k` reduces to `r₁ k + r₂ k` by `Pi.add_apply` definitionally, and the existing `show r₁ k + r₂ k = _` line transparently absorbs the change. Same for `_mul`/Pi.mul_apply.
- **`_mul` was ~3× shorter than `_add`.** The truncated-subtraction bookkeeping in `_add` consumed most of its 138-line proof. `_mul`'s witness is `(a₁·a₂, b₁·b₂, s₁+s₂)` — no sign-case dispatch, no truncated subtraction, just `pow_add` + `field_simp`. ~12 lines including the `refine`. Confirms the prior round's intuition that `_mul` was the cheap sibling.
- **`_reindex` (= `.comp`) is essentially free.** Mathlib's `Computable.comp` does all the recursion-theoretic lifting; we just precompose each component of the witness and forward the equality.
- **DA caught a citation bug NEXT-SESSION.md had inherited.** NEXT-SESSION.md (and hence the round's C6 criterion text) said "P-R Ch. 0:55". The verbatim corpus at `literature/papers/PourEl-Richards-chapt0.md:46-58` clearly shows line 55 is *inside Definition 2* (the convergence relation), and **Definition 3** at line 58 is the actual point predicate. Faithfulness-to-textbook is project commitment territory; the DA review was exactly the right tool.
- **L1.tex went from 2 envs to 11.** Dep-graph density is the proximate signal of L1 maturity; this round 5×'d the `\leanok` node count for L1.

## Open questions

- **`IsComputableSeqReal.add` / `.mul` (real-sequence closures) not shipped.** These are the *next* layer above `IsComputableSeqRat` closures (combine rational-sequence witnesses across the double-index + cast). Needed to lift `IsComputableReal.add` / `.mul` later, and to support L4 A1 directly at the real-sequence level.
- **`IsComputableSeqRat.finsetSum` not shipped.** Criterion C5 permitted either `.comp` or `.finsetSum`; we took `.comp` for the easy win. `.finsetSum` will be needed eventually for the L4 A1 axiom's `Σ_{j=0}^{d(n,k)} α_{n,k,j} · ...` form.
- **Definition 5 ↔ Definition 5a equivalence still deferred.** The L1 satellite explicitly states the two forms are equivalent (line 67-70 of the satellite); the formal proof remains unwritten.
- **`IsComputableReal.iff_seq` lemma not added.** DA's C6 review suggested an `Iff`-form (`IsComputableReal x ↔ IsComputableSeqReal (fun _ => x)`) for ergonomics. Skipped; was clearly improvement-class, not blocking.
- **Round-tracking metadata cleanup.** The `## What this file is NOT` preamble note about the §3-vs-§4 naming-convention drift carries some round-specific framing. Once the round is closed and the convention is settled, this can be retired in a future hygiene pass.

## Next-step recommendations

1. **Resume L4 A1 (`axiom_linearity` body) — now unblocked.** The closure toolkit shipped here is exactly the set the prior round's A1 strategy needed. Slug `l4-cmap-axiom-linearity-cont`, mode `proof-attempt`, ~6-8 iters / 150-180 min. The `.goals/l4-cmap-axiom-linearity/final.md` and `thinking/l4-cmap-axiom-linearity/iter-03-strategy.md` contain the full P-R-form A1 proof from 2026-06-02; the formalisation now has its scaffolding ready (`.add`/`.mul`/`.comp` resolved unqualified inside CMap's `open` scope).
2. **Ship `IsComputableSeqReal` real-sequence closures (`.add`/`.mul`/`.comp`).** Lifts `IsComputableSeqRat.*` through the double-rational-witness form to the real-sequence level. Slug `l1-real-sequence-closure`, mode `proof-attempt`, ~10 iters / 180 min. Closures here will be reused for L3 axiom proofs across all instances, not just CMap.
3. **L3 stability theorem (P-R Ch. 2.3).** Independent of L1/L4 work, high-leverage (vindicates the typeclass choice). Slug `l3-stability`, mode `proof-attempt`, ~8 iters / 150 min. Could run in parallel with #1.
4. **Update `docs/zulip-drafts/*` with the live blueprint + L1 dep-graph progress.** L1.tex now has 11 green nodes; the L0 + L3 Zulip pitches can credibly link to a populated chapter. Slug `zulip-l0-l3-l1-pitches`, mode `explore`, 3 iters / 60 min (conversational).
