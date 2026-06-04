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

## Agent model

**Every agent on this project must run on the `claude-opus-4-8` model**, including any
subagents it spawns. Do not dispatch work on a lighter or cheaper model — the
Lean/Mathlib proof reasoning requires full Opus capability.

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
  types/classes, `Is`-prefix for *noun* `Prop`-valued predicates only (Mathlib's
  rule: `Is` for nouns like `IsTopologicalRing`, not adjectives like `Normal` —
  <https://leanprover-community.github.io/contribute/naming.html>), 100-char
  lines, `Type*` over `Type 0`, `autoImplicit false`. Class/structure fields name
  the *conclusion* (`add_comm`, `norm_smul`), never `axiom_*`.

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

### When in doubt, grep — never assume

Three reflexive checks, each a 2-to-5-second tool call, that prevent the most
expensive avoidable mistakes (each one cost an iter in `l4-cmap-axiom-linearity-cont`):

- **Mathlib symbol existence**: before depending on any Mathlib lemma or
  Primrec/Computable primitive, `grep -rn "<symbol>" .lake/packages/mathlib/Mathlib/<area>/`.
  If no hit, the symbol doesn't exist by that name — define inline (typically
  via `Computable.nat_rec` or `Primrec.nat_rec`) or search synonyms. *E.g.,
  `Primrec.nat_pow` does not exist — see `docs/PITFALLS.md` §1.*
- **Literature citations**: for any `P-R Ch. X:Y`-style or `<file>:<line>`
  reference, `Read literature/papers/<key>.md` with `offset: Y, limit: 3` and
  verify the quoted phrase appears verbatim BEFORE writing the citation. Do
  not trust memory of line numbers — they shift across edits. *E.g., "for
  recursive reals a, b" is at Ch. 2:128, not :148 — verified the expensive
  way; see `docs/PITFALLS.md` §6.*
- **`allow_writes` scope** (in `/goal` rounds): before editing a file path
  not yet touched this round, `grep -F "<path>" current-goal.md`. The Stop
  hook HALTs out-of-scope writes — catching it after the fact costs an iter
  + a revert. *E.g., `claims/INDEX.md` is typically NOT in round-scoped
  allow_writes — see `docs/PITFALLS.md` §5.*

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
- **Blueprint consistency.** `\leanok` in `blueprint/src/*.tex` may only mark
  a node whose `\lean{decl}` target has no `sorry` transitively. `verify` enforces this; `#print axioms <decl>` showing `sorryAx` is a refusal.

## Status (carried by blueprint)

The dep graph at `blueprint/web/dep_graph_document.html` is the source of truth
for "what's stated / proved / formalized" (post-2026-06-02 transition to
Patrick Massot's `leanblueprint` framework — see `claims/INDEX.md` for the
mapping from the old 7-label YAML taxonomy).

Color encodes **two independent dimensions**: the node **border** is the
*statement* state, the node **fill** is the *proof* state. (Full `blueprint.py`
logic and the dark-green-fill trap are in `docs/BLUEPRINT-CONVENTIONS.md`.)

**Border — statement state:**

| Border | Marker | Meaning |
|---|---|---|
| Dark green | `\mathlibok` | Statement already lives in Mathlib upstream. |
| Green | `\leanok` on the statement (+ `\lean{<Decl>}`) | Statement formalized in Lean. |
| Blue | every statement-level `\uses` target is leanok | Ready to formalize; Lean target not declared yet. |
| Orange (`#FFAA33`) | `\notready` | Statement not ready for formalization. |

**Fill — proof state:**

| Fill | Condition | Meaning |
|---|---|---|
| Dark green (`#1CAC78`) | `fully_proved`: self + all ancestors proved-or-definition | Proof and entire upward cone formalized. |
| Mid green (`#9CEC8B`) | `proved`: the proof env carries `\leanok` | This proof formalized. |
| Light green (`#B0ECA3`) | definition, `stated` | Definition concrete in Lean. |
| Blue (`#A3D6FF`) | `can_prove`: all dependencies leanok | Dependencies formalized; proof not yet. |

A node reaches dark-green *fill* only with BOTH a `\leanok` statement and a
`\begin{proof}\leanok ... \end{proof}` block. `\mathlibok` is for the rare
already-upstream result — **not** a citation-node mechanism (see
`docs/BLUEPRINT-CONVENTIONS.md`).

For non-blueprint artifacts (pre-formal mental models under `intuition/`),
status is implicitly `intuition` and they do not appear in the dep graph until
a corresponding LaTeX node is added.

Rationale satellites under `claims/` may retain legacy YAML `status: ...`
fields during transition; they are no longer authoritative. New claim files
follow `claims/TEMPLATE.md` (satellite form with `blueprint:` field pointing at
the `\label{...}`).

## CI / Pages workflows

Two GitHub Actions workflows, split by cadence (full rationale: `docs/CI.md`):

- **`.github/workflows/blueprint.yml`** — fast, every push to `master`, ~3-5 min. Builds the Lean project and the blueprint web output; deploys to Pages. No Mathlib API docs.
- **`.github/workflows/docs.yml`** — slow, on tags matching `v*` / `release-*`, ~15-20 min. Builds Lean + blueprint + full Mathlib-linked API docs via `leanprover-community/docgen-action`.

Live: `https://yssnbkd.github.io/mathlib4-computable-analysis/` (blueprint home, dep graph at `/dep_graph_document.html`). API docs at `/docs/` only between tag deploy and next push to `master`.

Don't wait for CI to validate code. Local `lake build` is sub-minute incremental; CI is the final sanity check, not the inner loop.

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

## Construction milestone tracker

**The dep graph at `blueprint/web/dep_graph_document.html` is the milestone
tracker.** Each definition/lemma/theorem appears as a node; color denotes
formalization state (see "Status (carried by blueprint)" above). Build it with
`PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web`; live URL will be
added here once GitHub Pages is enabled.

### Corpus ingestion (P-R chapters)

The corpus ingestion table tracks paper-extract progress, NOT Lean progress.
It stays as a hand-maintained markdown table because it lives outside the
blueprint's scope.

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

### Construction milestones — see blueprint dep graph

This table was retired on 2026-06-02 in favor of the auto-generated blueprint
dep graph (`blueprint/web/dep_graph_document.html`). The graph supersedes the
hand-maintained table and stays in sync with the actual Lean state via
`leanblueprint checkdecls`.

The five-layer scaffold (L0…L5) is captured both by
`ComputableAnalysis/L<N>/*.lean` (Lean source) and `blueprint/src/L<N>.tex`
(LaTeX dispatcher chapters). Layer status is read off the dep graph's node
colors per the "Status (carried by blueprint)" section above.

## Lessons from prior rounds

Cross-round Lean / formalization knowledge harvested from completed rounds.
These were learned the expensive way (iter-by-iter pitfalls in `.goals/*/iter-*.md`)
and elevated here so future sessions don't re-derive them.

- **`docs/LEAN-IDIOMS.md`** — positive Lean tactics that worked
  (`convert ... using 1`, `show ...` to bridge `Computable.nat_rec`'s
  IH-form, `@[reducible]` on class-type defs, inner-witness extraction from
  `IsComputableSeqRat`, `Finset.sum` vs `Nat.rec` choice for closure helpers,
  helper-first round design). Read when planning a new proof.
- **`docs/PITFALLS.md`** — Lean / Mathlib gotchas with workarounds
  (missing `Primrec.nat_pow`, the absent `IsComputableSeqRat ↔ Computable ℚ`
  bridge, `Computable.id`-makes-inductions-ugly, `obtain` consumes the
  hypothesis, citation typos, allow_writes traps). Read when debugging a
  confusing error.

Skim both files before opening a new L-layer round.
