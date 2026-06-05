# Zulip outreach draft — `#new contributors` / `#Mathlib4`

**Topic suggestion**: *Computable analysis (Pour-El & Richards) in Lean 4 — architecture sanity check*

---

Hi all — I'm working on a Lean 4 / Mathlib4 formalization of Pour-El & Richards' *Computability in Analysis and Physics* (Cambridge UP 1989), aimed at upstream contribution under `Mathlib.Computability.Analysis.*`. The framing choice I've made is deliberately P-R-shaped rather than represented-spaces / TTE flavored: computability is a **predicate** on sequences of pre-existing Mathlib types, not a parallel category of "computable spaces". Concretely, `IsComputableSeqReal : (ℕ → ℝ) → Prop` lives on Mathlib's `ℝ` (there is no new `ℝ_c` type), and a `ComputabilityStructure` typeclass adds a `Prop`-valued predicate `isComputableSeq : (ℕ → E) → Prop` on top of any Banach space `[NormedAddCommGroup E] [NormedSpace 𝕜 E] [CompleteSpace E]`. The substrate underneath is Mathlib's existing `Computable` / `Partrec` on `ℕ` — no oracle TMs, no Type-2 / Baire-space realizers in the public API.

Where the project is: L0 (recursion bridge to Mathlib `Computable`), L1 (computable reals + sequences, including P-R Ch. 0 Prop 1 effective-Cauchy-to-IsComputableSeqReal), L3 (the `ComputabilityStructure` typeclass), and the L4 `C[α, β]` instance (`computabilityStructureCMap_of`) are all `sorry`-free and ship clean axiom prints (`[propext, Classical.choice, Quot.sound]`). Concretely for L4: all three P-R Ch. 2 axioms — Linear Forms (A1), Limit (A2 = P-R Ch. 0 Thm 4), and Norm (A3 = P-R Ch. 0 Thm 7) — are individually proved, parameterized by an explicit rational bound `B ≥ max(|α|, |β|)` and computable-real witnesses for the endpoints (the recursive-endpoint hypothesis from P-R Ch. 2:128 is load-bearing, not cosmetic — without it an empty `Set.Icc α β` admits adversarial coefficients). Blueprint + dep graph live at <https://yssnbkd.github.io/mathlib4-computable-analysis/blueprint/> (graph at `/blueprint/dep_graph_document.html`); code at <https://github.com/YssnBkd/mathlib4-computable-analysis>.

Before I push further (L2 Grzegorczyk-Lacombe, then L4 `Lᵖ` and separable Hilbert, then the First / Second Main Theorems), I would like a sanity check on the headline architecture choice: **is `IsComputableSeqReal : (ℕ → ℝ) → Prop` on Mathlib's `ℝ`, with Mathlib `Computable` / `Partrec` as the recursion-theoretic substrate, the right shape for upstream — or should the public API instead expose a represented-space / realizer layer (in the Pauly / Brattka tradition) and recover the P-R predicates as a corollary?** I'd especially value input from anyone who has thought about computable analysis in Lean before, or has opinions on how the Weihrauch-degree machinery should or shouldn't be visible at the surface. Happy to break this into a smaller thread if useful.

---

## Notes for the human author (not part of the post)

- URLs verified 2026-06-05: the Pages site lives under the `/blueprint/` subpath (200); the bare-root URL 404s. Don't revert the `/blueprint/` segment.
- **Push-before-post gate:** the "all three axioms / instance sorry-free" claim is true of commit `b246f30`, not yet of the public repo. Push that commit and let the blueprint workflow redeploy (~42 min) before posting, then confirm the dep graph shows `lem:l4_cmap_axiom3` dark-green.
- See `docs/zulip-draft-final.md` for the merged post (this draft's single headline question + the cli draft's structure and `Continuous`/`ContinuousMap` analogy).
