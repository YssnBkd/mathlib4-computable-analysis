# Blueprint authoring conventions (leanblueprint + plastexdepgraph)

Durable record of how to author this project's blueprint correctly.

**Standing rule: never author blueprint markup from memory or inference — consult
the authoritative sources below first.** The original L0/L1 blueprint was written
without consulting them, which produced a misreading of the coloring semantics and
a planned "refactor" (a layer of `\mathlibok` citation nodes) that would have
diverged from every mature blueprint in the ecosystem. This file closes that loop.

## Authoritative sources (consult before editing)

On-disk — ground truth for *this* project's renderer:
- `.venv/lib/python3.9/site-packages/leanblueprint/Packages/blueprint.py` — defines
  `\leanok`, `\mathlibok`, `\notready`, `\lean`, `\discussion`; the `colors` dict;
  `colorizer` (border), `fillcolorizer` (fill), `make_lean_data`, `make_legend`.
- `.venv/lib/python3.9/site-packages/plastexdepgraph/Packages/depgraph.py` — defines
  `\uses`, `\proves`, `\alsoIn`, `\bpcolor`, `\graphcolor`; the node/edge model.

Upstream:
- <https://github.com/PatrickMassot/leanblueprint>
- <https://github.com/PatrickMassot/plastexdepgraph>

Reference blueprints (the community idiom):
- PFR <https://github.com/teorth/pfr/tree/master/blueprint/src>, sphere-eversion,
  Carleson, FLT.

## Macro reference (intended use)

- `\lean{Decl, ...}` — fully-qualified Lean decl name(s) the node corresponds to;
  renders a doc link. Verified by `leanblueprint checkdecls`.
- `\leanok` — "this environment is formalized in Lean, sorry-free." On a *statement*
  env ⇒ statement formalized; on a *proof* env ⇒ proof formalized.
- `\uses{label, ...}` — dependency edges. **Placement matters** (see below).
- `\proves{label}` — for a *detached* proof (not the immediate sibling of its
  statement). Adjacent proofs auto-bind, so this is usually unnecessary.
- `\notready` — statement not ready to formalize. Use on stub nodes with no Lean yet.
- `\discussion{n}` — link GitHub issue #n.
- `\mathlibok` — "this node already lives in Mathlib upstream." Sets both `leanok`
  and `mathlibok`. **Rarely used — see the warning below.**

## Coloring semantics (verified against `blueprint.py`)

Two independent dimensions: **border = statement state**, **fill = proof state**.

**Border** (`colorizer`, first match wins):
1. `mathlibok` → `darkgreen`
2. `leanok` → `green`
3. `can_state` → `blue`
4. `notready` → `#FFAA33` (orange)
5. else → no border color

**Fill** (`fillcolorizer`):
- `proved` → `#9CEC8B` (mid green)
- elif `can_prove ∧ (can_state ∨ stated)` → `#A3D6FF` (blue)
- definition override (node is a `\begin{definition}`): `stated` → `#B0ECA3`
  (light green); elif `can_state` → `#A3D6FF`
- elif (non-definition) `fully_proved` → `#1CAC78` (dark green)

**Derived flags** (`make_lean_data`):
- `can_state` = every *statement-level* `\uses` target is `leanok` ∧ node not `notready`
- `can_prove` = every `\uses` target (statement + proof) is `leanok`
- `proved` = the **proof** environment carries `\leanok`
- `fully_proved` = every ancestor (incl. self) is `proved` OR is a definition

### The trap (dark-green fill)

A dark-green *fill* (`fully_proved`, `#1CAC78`) requires every ancestor to be
`proved`-or-definition. A theorem marked `\leanok` but lacking a
`\begin{proof}\leanok ... \end{proof}` block is **not `proved`** → it can never get a
dark-green fill, and it drags down its descendants. **Every formalized statement
needs a proof env carrying `\leanok`.** (This was the L0/L1 white-background bug.)

## `\uses` placement — statement vs proof

The graph distinguishes two edge kinds:
- **statement-level `\uses`** (inside the theorem/def/lemma env) → *dashed* edge. Use
  ONLY when the *statement text itself* references the target (e.g. it mentions a def).
- **proof-level `\uses`** (inside the proof env) → *solid* edge. Use for results
  invoked *in the proof*.

Idiom (PFR, verbatim): `\lean{}`+`\leanok` on the statement; `\uses{deps}`+`\leanok`
on the proof.

> Mistake to avoid (was present in L0): proof dependencies placed at statement level.
> `thm:propA`'s proof uses the halting lemmas, so that `\uses` belongs in its *proof*
> env, not the theorem env.

## ⚠ Do NOT build a `\mathlibok` "foundation layer"

`\mathlibok` marks a result you *stated in your blueprint* that turns out to already
live in Mathlib (so you won't reprove it). It is `\leanok` + a dark-green border + an
"in Mathlib" legend entry.

**It is NOT a mechanism for citation nodes** representing every Mathlib lemma your
proofs rest on. Evidence (raw `.tex` grepped, 2026-06-03):

| Blueprint | `\leanok` | `\uses{` | `\mathlibok` |
|---|---|---|---|
| PFR | 406 | 232 | **0** |
| Carleson | 360 | 118 | **0** |
| sphere-eversion | 116 | 70 | **0** |

Across 1100+ formalized nodes in the three most-cited blueprints, `\mathlibok`
appears **zero** times. The community idiom is to **model only your own nodes** and
let dependence on Mathlib stay implicit (a leaf node simply gets `\leanok` when
proved). A "Mathlib foundation chapter" of `\mathlibok` nodes would make this
blueprint unlike any in the ecosystem and add graph noise. **Do not do it.** Reserve
`\mathlibok` for the rare case where a result you *stated* is found to already exist
upstream.

## Node text = mathematics, not project status

Blueprint node bodies describe the math (statement / proof sketch). They must NOT
carry project-management changelog: round slugs, dates, "white-bordered", "post
round X", "iter-NN". Status is conveyed by graph *colors*, not prose. (PFR /
sphere-eversion node text is pure mathematics.) Keep round bookkeeping in `.goals/`.

## Stub nodes (L2–L5)

Keep `\notready` until the Lean lands. When it lands: add `\lean{}` + `\leanok` to
the statement **and** a `\begin{proof}\leanok ... \end{proof}` block (else no green
fill — see the trap above). Write the proof as a real prose sketch, not "see the
Lean file" — a blueprint's primary value is the human-readable narrative.

## File structure

- `web.tex` / `print.tex` — format entry points; both `\input{macros/common}` plus
  their format macros, then `\input{content}`. Project URLs `\home` / `\github` /
  `\dochome` are set in `web.tex`.
- `content.tex` — a sequence of `\input{LN}` chapter files.
- One chapter `.tex` per layer (`L0`…`L5`).

## Verification pipeline

1. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web` — exit 0, regenerates
   `blueprint/web/`.
2. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls` — exit 0; every
   `\lean{<Decl>}` must resolve in the lake environment.
3. Inspect `blueprint/web/dep_graph_document.html` (the DOT is embedded as a
   `renderDot(\`...\`)` JS string) to confirm borders/fills match intent.
