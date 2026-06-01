---
slug: l3-computability-structure-axioms
started: 2026-06-01T13:49:34Z
ended: 2026-06-01T15:22:54Z
iterations: 8
outcome: success
---

# Final summary for goal: state the three Pour-El–Richards axioms of a computability structure as a precise `our_construction` claim, with verbatim source pointers

## Criteria status

- [x] **C1**: `intuition/l3-computability-structure.md` exists — full mental model (one-sentence picture, why sequences not points, why three axioms, what each rules in/out, the L^∞ counterexample for "what could go wrong", stability lemma rationale, cross-layer reach into L1, falsification conditions, residual unknowns).
- [x] **C2**: `claims/l3-computability-structure/axioms.md` exists with status `our_construction` — Axioms 1 (Linear Forms), 2 (Limits), 3 (Norms), plus (NV) non-vacuity. Effective convergence defined as auxiliary. Cleared round-2 DA review on the second attempt after a round-1 `unsound` verdict whose five weaknesses were resolved inline.
- [x] **C3**: Verbatim source pointers in place for every axiom and the (NV) clause: `PourEl-Richards-chapt2.md:58–64` (effective convergence), `:66–72` (A1), `:73` (A2), `:75` (A3), `:77` (NV), plus `:53` (double-sequence convention) and `:55` (computable point).
- [x] **C4**: `claims/l1-computable-reals/is-computable-seq-real.md` stub exists with status `our_construction`. Defines `IsComputableSeqReal` (P-R Def 5a, `chapt0.md:203–207`), `IsComputableSeqComplex` (coordinatewise, `chapt0.md:216`), and the auxiliary computable-rational and effective-convergence definitions. Equivalence with P-R Def 5 stated but not yet proved (downstream).
- [x] **C5**: Devil's-advocate review verdict `passes` at `.goals/l3-computability-structure-axioms/reviews/C2.md` (round 2, 2026-06-01). Round-1 verdict (`unsound`, five weaknesses) preserved at `reviews/C2-round1.md` for audit.
- [x] **C6**: `/verify` clean — `scripts/verify_claims.py` confirms 3 claims across 4 files with valid frontmatter and status taxonomy; `scripts/verify_provenance.py` confirms all source pointers resolve.

All six criteria satisfied. iter-08 written by the Stop hook with `unmet: []` and the SUCCESS sentinel.

## Artifacts produced

- **`intuition/l3-computability-structure.md`** — 105 lines of prose mental model; ground truth for the rationale that pre-committed us to *these* three axioms and not a fourth. (Iter-02.)
- **`claims/l3-computability-structure/axioms.md`** — the formal `our_construction` claim. 12K, status `our_construction`, `lean_target: formal/L3/ComputabilityStructure.lean`. Includes formalization remarks (non-axiomatic commentary) tying each axiom to its Mathlib hook and the L1 reach-down. (Iter-02; revised iter-03 per DA round-1; backfilled lean_target iter-05.)
- **`claims/l1-computable-reals/is-computable-seq-real.md`** — the L1 stub the L3 axioms depend on. Defines `IsComputableSeqReal` and `IsComputableSeqComplex`; downstream L1 work (computable points, closure under arithmetic, subfield structure) explicitly deferred. (Iter-03; backfilled lean_target iter-05.)
- **`.goals/l3-computability-structure-axioms/reviews/C2.md`** — round-2 DA verdict `passes`, with citation re-audit, hypothesis-weakening probe, counterexample-disclosure verification.
- **`.goals/l3-computability-structure-axioms/reviews/C2-round1.md`** — preserved round-1 verdict (`unsound`, five weaknesses), referenced from the claim file's "Resolutions" section for audit continuity.
- **Out-of-band: `CLAUDE.md` constitutional amendment** — committed in `145e79a`. Iter-05 amended CLAUDE.md to make Mathlib4 the primary deliverable (Architectural commitment #6 and Rule 7; "Lean integration cadence" section; milestone tracker gains a Lean target column; L1/L3 bumped to `claimed`). This was approved out-of-band via `thinking/_plans/ticklish-dreaming-twilight.md`; logged here because it shaped C4 + the final lean_target frontmatter fields.
- **Out-of-band: `/formalize` skill suite** — committed in `30a7ef0`. Iter-07 built `.claude/commands/formalize.md`, `.claude/templates/lean-prodigy-persona.md`, `.claude/templates/lean-toolkit.md`, `scripts/formalize_env_check.py`, plus `.claude/settings.json` and `BOOTSTRAP.md` updates. Not in scope of this goal's criteria; built because the next /goal (L3 Lean stub) needs it.
- **Out-of-band fix: `scripts/verify_provenance.py`** — committed in `abe06db`. Iter-07 added a `_source_resolves` helper accepting both the canonical bibkey-directory layout *and* the documented flat-file `literature/papers/<key>.md` layout that this project has adopted for P-R chapters. Was silently blocking C6 across every P-R-sourced claim.

## Devil's-advocate verdicts

| Artifact | Round | Verdict | Key issues found | Status |
|---|---|---|---|---|
| `claims/l3-computability-structure/axioms.md` | 1 | `unsound` | (1) NV equivalence with P-R asserted without derivation; (2) complex scalar case had no L1 referent; (3) pairing-function commitment unjustified; (4) intrinsic-uniqueness rationale-gap; (5) `Nat.Partrec` decoding sloppiness | All five resolved inline; round-2 invoked next |
| `claims/l3-computability-structure/axioms.md` | 2 | `passes` | One non-blocking stylistic refinement noted: double-sequence-of-scalars Cantor-pairing decoding not restated for the scalar case (uniform across P-R, inferable, but explicit is better) | Refinement deferred to L1 elaboration |

## Key findings

- **The L3 keystone is now formally committed.** `IsComputableSeq : (ℕ → X) → Prop` is the primitive predicate; (A1) linear forms / (A2) effective limits / (A3) norm-reach-into-L1 / (NV) non-vacuity are the four typeclass fields. The shape is fixed; downstream layers can build on it.
- **The cross-layer dependency graph is one-directional.** L3 → L1 (via Axiom 3's `IsComputableSeqReal` and Axiom 1's scalar references for both `K = ℝ` and `K = ℂ`). L1 has no reverse dependency on L3. This was a known assumption; the goal made it concrete.
- **`Computable` (total) is the right Mathlib substrate.** Not `Nat.Partrec` (partial). P-R's recursive functions in Ch. 2 §1 are applied at every input, hence total. Documented inline; the entire downstream L0 layer can rely on this commitment.
- **The pairing-function choice is immaterial.** `Nat.pair` is the project's commitment; immateriality follows from Axiom 1 + Composition Property (`chapt2.md:82–97`). A downstream lemma will discharge this formally.
- **Intrinsic uniqueness is NOT a consequence of (A1)–(A3)+(NV) alone.** It requires effective separability + the Stability Lemma (`chapt2.md:248`), which live at L4. The trivial-everywhere-zero predicate `IsComputableSeq := λ x. ∀ n, x n = 0` satisfies every axiom we wrote down and captures none of P-R's intended content; this is disclosed inline at the claim, not hidden.
- **Constitutional drift was caught and corrected mid-goal.** Iter-04's interruption ("when exactly are you going to use Lean?") surfaced an architectural drift where Lean had been treated as Phase B rather than as the primary deliverable. Iter-05's constitutional amendment closed this; the L1/L3 claim files now carry `lean_target:` frontmatter as a load-bearing field.
- **The `/formalize` skill is in place for the next round.** It was built as a meta-task in iter-07 — not part of the goal's criteria but required for the next goal (which will produce `formal/L3/ComputabilityStructure.lean`). Six-phase orchestration, PhD-prodigy persona, full toolkit reference, watermarked env preflight.
- **One latent project-level bug was surfaced and fixed.** `scripts/verify_provenance.py` had been silently blocking `/verify` on every P-R-sourced claim due to a layout mismatch with the documented flat-file convention. Fix landed in commit `abe06db`.

## Open questions

1. **L3 Lean stub.** The natural next milestone: produce `formal/L3/ComputabilityStructure.lean` using `/formalize`. The claim file's "Formalization remarks" section is the input; the typeclass shape is fixed.
2. **L1 elaboration.** The L1 stub explicitly defers: `IsComputableReal : ℝ → Prop` (constant-sequence case), closure under field operations, the countable-subfield theorem, proof of Def 5 ↔ Def 5a equivalence, and effective sign-decidability (P-R Proposition 0). Each is a small downstream claim; some are needed before the Lean L3 stub can typecheck against concrete L4 instances.
3. **Double-sequence scalar decoding** (DA round-2 non-blocking refinement). The L1 stub should explicitly state that double-sequence versions of `IsComputableSeqReal`/`IsComputableSeqComplex` use the same `Nat.pair` re-indexing as the X-valued case. Inferable from `chapt0.md:189`, but explicit beats inferable.
4. **The Stability Lemma at L4.** The claim flagged this as where intrinsic uniqueness comes from. Proving it requires the Effective Density Lemma + the effective-separability predicate.
5. **Concrete L4 instances**: `C([a,b], ℝ)`, `L^p[a,b]`, separable Hilbert. These exercise the L3 typeclass with real Mathlib structures and will surface any latent design defects in the typeclass shape.
6. **iter-01 is missing from the iter file sequence** (iters 00, 02, 03, 04, 05, 06, 07, 08). Cause unclear — likely a hook quirk or manual deletion. Not consequential, noted for audit.

## Next-step recommendations

In recommended priority order:

1. **Bootstrap the `formal/` Lake project** (small one-time goal, e.g., `formal-bootstrap`). Run `python3 scripts/formalize_env_check.py --init`, then `cd formal && lake update && lake exe cache get && lake build`. This pins Mathlib4 (`lake-manifest.json` is recorded) and populates the watermark. It is high-blast-radius (downloads / builds ~30 minutes of Mathlib) so deserves its own focused round with explicit user confirmation. Until this is done, no /formalize session can succeed past Phase 0.

2. **Open `/goal l3-computability-structure-lean`** (mode `proof-attempt` or `explore`) — produce `formal/L3/ComputabilityStructure.lean` as the typeclass stub corresponding to `claims/l3-computability-structure/axioms.md`. Criteria: file exists; type-checks against the pinned Mathlib commit; exports `ComputabilityStructure`, `IsComputableSeq`, and the four axiom-field names; predicates / structure bodies sorry-free per CLAUDE.md commitment #6; DA-Lean review passes. This is the natural use of `/formalize`.

3. **(Optional, can be deferred)** A small `/goal l1-elaboration` round to discharge the deferred L1 items — `IsComputableReal`, arithmetic closure, the Def 5 ↔ Def 5a equivalence proof, and the double-sequence scalar decoding refinement. Useful for downstream L4 work; not blocking the L3 Lean stub.

4. **(Optional)** A `/goal claude-md-cleanup` if you want to fold the iter-04/05 constitutional amendment narrative (currently spread across `thinking/_plans/ticklish-dreaming-twilight.md` and the iter-05 progress note) into a single retrospective under `thinking/`. Pure hygiene; not load-bearing.

The fastest path to a tangible Mathlib4 contribution is **#1 → #2**.
