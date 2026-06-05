# Zulip draft — predicate-first computable analysis, feedback wanted

> Target stream: `#new contributors` (cross-post or pointer in `#Mathlib4`).
> Topic: "Predicate-first computable analysis in Mathlib4 — architecture feedback?"
> Word count: ~370.

---

Hi all — I've been formalizing Pour-El & Richards' *Computability in Analysis and Physics* (Cambridge UP, 1989) in Lean 4, aiming at upstream contribution to `Mathlib.Computability.Analysis.*`. Repo: <https://github.com/YssnBkd/mathlib4-computable-analysis>; dep graph: <https://yssnbkd.github.io/mathlib4-computable-analysis/blueprint/dep_graph_document.html>. The design is deliberately **predicate-first**: rather than introducing a parallel type `ℝ_c` for "computable reals", a typeclass `ComputabilityStructure 𝕜 E` adds structure to Mathlib's existing Banach spaces `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]`. Predicates like `IsComputableSeqReal : (ℕ → ℝ) → Prop` live on Mathlib's own `ℝ`; bundled subtypes are additions, not replacements, only where ergonomics demand. The recursion-theoretic substrate is `Mathlib.Computability` (`Computable`, `Partrec`), not Type-2 Turing machines or Baire-space realizers.

Current state, all sorry-free under `[propext, Classical.choice, Quot.sound]`:
- **L0** — recursion-bridge layer (P-R Prerequisites; Prop B effective separation).
- **L1** — `IsComputableSeqRat` and `IsComputableSeqReal` with closure under arithmetic + `max`/`min`/`abs`; P-R Ch. 0 Proposition 1 lifted as `isComputableSeqReal_of_effectiveConvergence`.
- **L3** — the `ComputabilityStructure 𝕜 E` typeclass on Banach spaces, with the three P-R Ch. 2 axioms as fields.
- **L4** — first concrete instance: `C(Set.Icc α β, ℝ)` with the sup-norm. All three axioms (Linear Forms, Effective Limit, Computable Norm — P-R Ch. 2 Axioms 1, 2, 3) closed under explicit hypotheses `B ≥ max(|α|,|β|)`, `IsComputableReal α, β`, and `α ≤ β`.

The question I'd most value input on is the **predicate-vs-type tradeoff**. The predicate-first design mirrors P-R's own informal style (work over an ambient analysis-rich space; mark the subset of computable elements) and integrates with Mathlib's classical hierarchy without forking. The downsides are friction with TTE / represented-spaces idioms (Pauly, Brattka, Schröder), where definitions are naturally morphisms of effectively presented spaces. Has anyone tried to formalize computable analysis in Lean before? In particular, I'd love feedback on (a) representing computability of *points* via the constant-sequence trick from P-R intro:7, (b) the choice of `Computable` over `Partrec` as the substrate, and (c) whether the L4 instance signature — six hypotheses `(B) (hα_le) (hβ_le) (hα_c) (hβ_c) (hαβ)` — feels too heavy for upstream review.

---

## Notes for the human author (not part of the post)

- URLs verified 2026-06-05: repo `https://github.com/YssnBkd/mathlib4-computable-analysis` (200) and dep graph under the `/blueprint/` subpath (200). The bare-root Pages URL 404s — do **not** revert the `/blueprint/` segment.
- **Push-before-post gate:** the "all three axioms closed" claim in the L4 bullet is true of the working tree and of commit `b246f30`, but only becomes true of the *public* repo + live dep graph once that commit is pushed AND the blueprint workflow redeploys (~42 min). Verify the dep-graph link renders `lem:l4_cmap_axiom3` dark-green before posting.
- "Last week / today / this month" wording deliberately omitted — adjust for posting date.
- Three paragraphs match Zulip's preferred density. If the post is too long, the L0–L4 bullet list can collapse to a single sentence: "L0+L1+L3 and the L4 `C[a,b]` instance are sorry-free; see the blueprint for the dep graph."
- The closing question is intentionally **three specific sub-questions** (a, b, c) rather than a vague "thoughts?". This gives readers concrete anchors to respond to.
- If you're going to ping Brattka, Pauly, or Schröder by name, do it in a follow-up message in the same thread rather than the opening post.
- Cross-post or pointer in `#Mathlib4` after ~24h if the `#new contributors` thread is quiet.
