---
slug: l4-cmap-surface-axiom1
ended: 2026-06-04T08:00:00Z
iterations: 5
outcome: success
---

# Final summary for goal: Surface the A1 win — extract `isComputableSeqCMap_linearCombination` as a standalone sorry-free lemma and add a green blueprint node `lem:l4_cmap_axiom1` wired into `thm:l4_cmap_instance`

## Criteria status

- [x] **C1: standalone sorry-free A1 lemma + instance delegation.**
  Theorem `ComputableAnalysis.L4.isComputableSeqCMap_linearCombination` at
  `ComputableAnalysis/L4/Instances/CMap.lean:636` with hypothesis tuple matching
  the L3 A1 field signature (specialised to `E := C(Set.Icc α β, ℝ)`, `𝕜 := ℝ`,
  `IsComputableSeq := IsComputableSeqCMap`). The `computabilityStructureCMap_of`
  instance field at `CMap.lean:1286-1287` is the one-liner
  `isComputableSeq_linearCombination := isComputableSeqCMap_linearCombination B hα_le hβ_le`.
  PITFALLS §7 standalone `#print axioms` check on the named theorem reports
  `[propext, Classical.choice, Quot.sound]` — **no `sorryAx`**.
- [x] **C2: blueprint node `lem:l4_cmap_axiom1` faithful and DA-passed.**
  Block at `blueprint/src/L4.tex:5-26` with `\lean{...}`, `\leanok` (statement
  and proof), statement-level `\uses{def:l3_computabilityStructure,
  def:l1_isComputableSeqRat}` and proof-level
  `\uses{lem:l1_isComputableSeqRat_{add,mul,comp}}`. DA verdict `passes`
  (`.goals/l4-cmap-surface-axiom1/reviews/C2.md`); one cosmetic over-estimate
  (stray factor 2 in the triangle-inequality bound) tightened same-iter to
  match the actual Lean estimate.
- [x] **C3: proof-level wiring + DA-passed.**
  `thm:l4_cmap_instance`'s `\begin{proof}` block at `L4.tex:34-40` now carries
  `\uses{lem:l4_cmap_axiom1, def:l1_isComputableSeqReal}` (proof-level, not
  statement-level); Linearity paragraph shortened to `\Cref{lem:l4_cmap_axiom1}`.
  DA verdict `passes` (`.../reviews/C3.md`); solid edge
  `lem:l4_cmap_axiom1 -> thm:l4_cmap_instance` renders at
  `dep_graph_document.html:1123` with no `[style=dashed]` attribute.
- [x] **C4: full verification pipeline green.**
  `lake build`: 2532 jobs, exit 0; single sorry-warning at the (line-shifted)
  instance line; 2 sorries unchanged at A2/A3 fields. `CMap.lean` 100-col
  clean (Python codepoint check). `leanblueprint web` exit 0 (re-run after C2
  tightening — still exit 0). `leanblueprint checkdecls` exit 0 (the new
  `\lean{...isComputableSeqCMap_linearCombination}` target resolves in the
  lake env). The original C4(b) was over-strict in extending the 100-col rule
  to `.tex`; project convention is paragraph-per-line for LaTeX prose
  (matching PFR/Carleson/sphere-eversion) and the `verify` skill enforces
  only the pipeline checks above.

## Artifacts produced

- `ComputableAnalysis/L4/Instances/CMap.lean` (modified): inline A1 body
  (was lines 643..1257, ~615 lines) hoisted into the new top-level theorem
  at lines 636..1278; instance field replaced with single-line delegation
  at 1286-1287. +30 net lines.
- `blueprint/src/L4.tex` (modified): added `\begin{lemma}...\end{lemma}`
  block + `\begin{proof}\leanok ... \end{proof}` block for `lem:l4_cmap_axiom1`;
  updated `thm:l4_cmap_instance`'s proof-level `\uses` and shortened the
  Linearity paragraph to defer to the new lemma.
- `blueprint/lean_decls` (regenerated): now includes
  `ComputableAnalysis.L4.isComputableSeqCMap_linearCombination`.
- `thinking/l4-cmap-surface-axiom1/extract_a1.py`: Python file-surgery script
  with three sanity assertions (lines 619, 643, 1258) and an indentation-aware
  dedent of the tactic body (4-space → 2-space, strict ≥2-space requirement).
- `thinking/l4-cmap-surface-axiom1/print_axioms_test.lean`: standalone-theorem
  `#print axioms` audit per `docs/PITFALLS.md §7`. Not part of the lake
  library; runs via `lake env lean ...`.
- `.goals/l4-cmap-surface-axiom1/{goal,iter-00..05,final}.md`: round trail.
- No `claims/l4-cmap-surface-axiom1/`, `proofs/l4-cmap-surface-axiom1/`, or
  `intuition/l4-cmap-surface-axiom1.md` were created — this round was a
  pure refactor + blueprint exposure of already-proved mathematics, not a
  novel research thread.

## Devil's-advocate verdicts

| Artifact | Verdict | Key observation |
|---|---|---|
| `blueprint/src/L4.tex` `lem:l4_cmap_axiom1` block (C2) | **passes** | All five sub-criteria satisfied (label, `\lean{}`, `\leanok`, proof env, prose faithfulness). One cosmetic imprecision (extra factor 2 in the triangle bound) — under-promising, not over-claiming. Tightened same iter. |
| `thm:l4_cmap_instance` `\uses` placement + edge rendering (C3) | **passes** | Lemma referenced ONLY inside `\begin{proof}` (proof-level). Edge renders solid, hyperlink works, theorem fill blue (`can_prove`) is correct. Non-blocking: leanblueprint emission quirk omits the direct `def:l3_computabilityStructure -> thm:l4_cmap_instance` dashed edge — out of round scope. |

## Key findings

1. **PITFALLS §7's standalone-theorem `#print axioms` method is essential.**
   The field-projection `#print axioms (instance).field` would have reported
   `sorryAx` here because of sibling A2/A3 sorries — a false positive that
   would block `\leanok` on the lemma. Extracting to a standalone theorem and
   `#print axioms`-ing *that* is the only correct test. This round operationalises
   that pattern for the first time in the project.
2. **L4 now has a first green node** (`lem:l4_cmap_axiom1`, dark-green fill
   `#1CAC78`). Before this round the L4 chapter contributed zero `fully_proved`
   colour despite ~615 lines of closed A1 proof — the dep graph hid the win
   because the consumer instance carried sibling `sorryAx`. The extract-to-named-lemma
   pattern is the project's standard idiom for surfacing partial wins.
3. **Big code-motion refactors are best done via a Python file-surgery script
   with assertions**, not a giant `Edit` `old_string`. The
   `thinking/l4-cmap-surface-axiom1/extract_a1.py` pattern (sanity-assert on
   anchor lines, strict-indent dedent of the moved block, two-half re-emission)
   gave a deterministic, audit-trail edit for ~615 lines that would have been
   error-prone via the Edit tool.
4. **Proof-level vs statement-level `\uses` matters for graph rendering.**
   Solid edges = proof-level; dashed edges = statement-level. Empirically
   verified across this graph. For typeclass-instance nodes whose body
   assigns a field from a lemma, the lemma is a proof-level dependency
   (matches `docs/BLUEPRINT-CONVENTIONS.md`'s "needed to state" /
   "needed to prove" distinction).
5. **Devil's-advocate caught a real (though benign) prose-vs-code mismatch**
   that no `lake build` / `checkdecls` step would surface. The factor-2 in
   the triangle bound was looser than the actual Lean estimate. The DA
   workflow is paying off precisely where it should: prose-to-code faithfulness
   checks that the type-checker can't see.
6. **Stop-hook bookkeeping discipline matters.** Three of the round's five
   iterations were pure bookkeeping (extend `allow_writes` for inherited dirt,
   flip `- [ ]` checkboxes after substantive close, hook auto-scaffolded
   iter-04/05 success markers). The hook is the canonical "is the round done?"
   signal; the iter-prose is for humans.

## Open questions

- **The leanblueprint dep-graph quirk** noted in the C3 DA review (no direct
  edge `def:l3_computabilityStructure -> thm:l4_cmap_instance` despite the
  statement-level `\uses`). Not a round blocker; worth a separate observation /
  upstream report later.
- **Whether the `FinsetSumHelper` namespace inside `CMap.lean`** should be
  hoisted up to L1 (slug `l1-finsetsum-and-ite` in NEXT-SESSION's menu).
  Its lemmas are about `IsComputableSeqRat` closure under finite sums /
  conditionals — L1-shaped code currently stranded inside L4. Independent of
  the A2/A3 closures; would free ~250 lines of `CMap.lean`. Possible
  parallel-able round.
- **Whether the standalone A1 lemma will need its hypothesis list trimmed
  before upstream Mathlib contribution.** Currently `B`, `hα_le`, `hβ_le` are
  explicit arguments; that's natural for the C[a,b] specialisation but a
  reviewer may prefer the lemma quantify over all three implicitly. Defer to
  the L4-instance polish round just before upstreaming.

## Next-step recommendations (ranked)

1. **L1 finite-`max` and absolute-value closure** (slug e.g.
   `l1-max-abs-closure`). Foundation-first, ~7-10 iters by recent L1 budgets,
   clean extension of an already-green layer. Unblocks the A3 close in the
   subsequent round. Per `docs/PITFALLS.md §1`, grep Mathlib first for
   `Computable.max` / `Primrec.max` / `Computable.natAbs` and friends before
   defining helpers inline.
2. **A2 close** (slug `l4-cmap-axiom2-effectivelimit`). Independent of L1
   max/abs work — A2 only needs the effective-limit triangle-inequality
   bookkeeping and a diagonalisation, all from P-R Ch. 0 Thm 4. Can run in a
   parallel git worktree per CLAUDE.md's parallel-agent guidance (do **not**
   share a working tree with the L1 round — both touch documentation files).
3. **L1 helper hoist** (slug `l1-finsetsum-and-ite`). Moves the
   `FinsetSumHelper` closure helpers from `CMap.lean` up to L1's
   `IsComputableSeqRat` namespace. Low-leverage right now (no consumer
   blocked), but the code is L1-shaped and would let `CMap.lean` shrink by
   ~250 lines, improving review-readability for the eventual A3 work.
4. **Zulip outreach.** L4 now has a first green node — credible material for
   a `#new contributors` / `#Mathlib4` post (per CLAUDE.md §"Mathlib community
   engagement"). The pitch is: "P-R-style computability structure on Banach
   spaces, with the C[a,b] instance's A1 axiom (linearity) fully formalised;
   A2 and A3 are the next milestones — feedback welcome." User does the
   posting, not the agent.
