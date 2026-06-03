# Prompt for next session

> *Paste this as the opening message in the next conversation. It is self-contained;
> you do not need prior transcripts.* This is a **default** — if the user opens with a
> different request, follow their direction.

---

You are continuing work on **mathlib-computable-analysis**, a Lean 4 / Mathlib4
formalization of Pour-El & Richards' *Computability in Analysis and Physics* (Cambridge
UP 1989), targeting upstream contribution to `Mathlib.Computability.Analysis.*`. Repo root:
`/Users/yassineboulkaid/Projets/Claude/mathlib-computable-analysis/`. **Read `CLAUDE.md`
first** — it is the project constitution. The deliverable is **Lean code**; the
type-checker is the final arbiter.

## What just happened (2026-06-04 conformance pass)

The previous session audited the project against official Lean 4 + leanblueprint
conventions and ran a three-phase cleanup. **No mathematics changed; no new `sorry`
appeared.** The build is green (2532 jobs); the only sorry-warning is at
`CMap.lean:639` (the C[a,b] instance `def`, from its open A2/A3 fields).

1. **A planned refactor was investigated and rejected.** The prior `NEXT-SESSION.md`
   proposed adding a project-wide layer of `\mathlibok` "foundation nodes" to make the
   Mathlib dependency visible in the dep graph. Research into the three most-cited
   community blueprints killed it: **`\mathlibok` is used 0 times across PFR (406
   `\leanok`), Carleson (360), and sphere-eversion (116)** — see the evidence table in
   `docs/BLUEPRINT-CONVENTIONS.md` §"Do NOT build a `\mathlibok` foundation layer". The
   community idiom is to model only your *own* nodes and let Mathlib be invisible
   substrate. **Do not resurrect the foundation-layer plan.**

2. **Docs corrected, blueprint cleaned, Lean conventions enforced.** `CLAUDE.md`'s status
   section now separates border (statement state) from fill (proof state). Blueprint node
   text is pure mathematics — all changelog/iteration/"see `.lean:NN`" prose stripped;
   `\usepackage{cleveref}` added to `web.tex`/`print.tex` so `\Cref` resolves; `\uses`
   placement fixed (statement-level when the statement text references the target,
   proof-level for results invoked in the proof). Lean files: `#check`/smoke-test blocks
   removed, `try ring` crutches replaced by `ring` (or dropped where `field_simp` already
   closed the goal), all lines wrapped to ≤100 columns.

3. **The L3 axiom fields were renamed to name their conclusion** (Mathlib rule: structure
   fields name the conclusion, never `axiom_*`). Current `ComputabilityStructure` fields:
   `isComputableSeq_linearCombination` (A1), `isComputableSeq_of_effectiveLimit` (A2),
   `isComputableSeqReal_norm` (A3), `zero_seq` (NV). The old `axiom_linearity` /
   `axiom_limits` / `axiom_norms` names survive only in *historical* artifacts
   (`claims/`, `.goals/`, round slugs) — deliberately not rewritten.

The durable conventions are recorded in `docs/BLUEPRINT-CONVENTIONS.md`; read it before
touching any `.tex`.

## Current state (accurate as of 2026-06-04, post-cleanup)

| Layer | Lean state | Blueprint |
|---|---|---|
| L0 | done, 0 sorry (recursion bridge + Prop B inseparable pair) | `L0.tex` — 12 nodes `\leanok`, 8 with proof blocks (dark-green fill) |
| L1 | rational-seq closures + real *point* predicate done, 0 sorry | `L1.tex` — 11 `\leanok`, 7 with proof blocks |
| L2 | not started (Grzegorczyk–Lacombe) | `L2.tex` — 1 `\notready` stub |
| L3 | `ComputabilityStructure` typeclass done, 0 sorry | `L3.tex` — 1 `\leanok` def |
| L4 | C[a,b]: **A1 closed (sorry-free)**; A2/A3 sorried; Lᵖ/Hilbert not started | `L4.tex` — `thm:l4_cmap_instance` (white border: instance carries `sorryAx`); 2 `\notready` |
| L5 | not started (Main Theorems) | `L5.tex` — 4 `\notready` stubs |

- **HEAD = `59bf80d`.** This session's cleanup (18 modified files + new
  `docs/BLUEPRINT-CONVENTIONS.md`) is **uncommitted** in the working tree. Commit it
  first if the user approves (they have not yet asked).
- The two remaining `sorry`s are in `CMap.lean`: A2 `isComputableSeq_of_effectiveLimit`
  at **line 1268**, A3 `isComputableSeqReal_norm` at **line 1279**. Each has a detailed
  TODO sketch in the field body (`CMap.lean:1258-1279`) citing P-R Ch. 0 Thm 4 (A2) and
  Thm 7 (A3) — **re-verify those citations verbatim before copying them into a claim or
  blueprint** (`docs/PITFALLS.md` §6).
- `blueprint/web/` is gitignored (regenerated, not committed).

## Recommended next task — drive C[a,b] to a complete instance

Closing the C[a,b] instance is the highest-value near-term milestone: it would be the
**first complete `ComputabilityStructure` instance**, validating the entire L3 keystone
against a real Banach space — a genuine, shareable result. Two phases:

**Phase 1 — surface the A1 win (low-risk warmup).** Right now the public dep graph hides
the hardest-already-done axiom: because the instance carries `sorryAx` from A2/A3, the
single `thm:l4_cmap_instance` node is white-bordered, so a viewer sees *nothing* green in
L4 even though A1 (linearity, with the full polynomial-approximation machinery) is closed.
Extract the A1 field body into a named, sorry-free lemma (e.g.
`isComputableSeqCMap_linearCombination`), make the instance field `:=` that lemma, and add
a green blueprint node (`lem:l4_cmap_axiom1`, `\lean{}` + `\leanok` + a `\begin{proof}
\leanok` block) wired by proof-level `\uses` into `thm:l4_cmap_instance`. This makes real
progress visible without proving anything new. *(Confirm the extraction stays sorry-free
with the standalone-theorem `#print axioms` method — `docs/PITFALLS.md` §7 — not field
projection, which gives false positives.)*

**Phase 2 — close A2 and A3.**
- **A3** (`isComputableSeqReal_norm`, sup-norm is computable) is blocked on **L1 closure
  under finite `max` and absolute value** — the field's own TODO says so. Do the L1
  max/abs closure first (clean extension of the already-green L1 layer), then A3.
- **A2** (`isComputableSeq_of_effectiveLimit`) is closer to self-contained: the TODO
  sketches a diagonalized polynomial approximant whose witnesses are computable by
  composition of recursive functions (P-R Ch. 0 Thm 4). It mainly needs the
  effective-limit triangle-inequality bookkeeping.

Closing both makes `computabilityStructureCMap_of` sorry-free → `thm:l4_cmap_instance`
becomes `\leanok` (green border, and dark-green fill once its proof block is `\leanok`).

## Other viable directions (ranked menu)

- **L1 buildout** (slug `l1-real-sequence-closure`): lift `IsComputableSeqRat.{add,mul,comp}`
  through `IsComputableSeqReal`; add finite-`max`/abs closure. Foundational — directly
  unblocks A3 above and every future instance. Good if you prefer foundations-first.
- **L1 helper hoist** (slug `l1-finsetsum-and-ite`): move the private `FinsetSumHelper`
  closure helpers from `CMap.lean` up to L1's `IsComputableSeqRat` namespace (frees ~250
  lines of L1-shaped code currently stranded in L4).
- **L3 stability theorem** (slug `l3-stability`): uniqueness of `IsComputableSeq` under
  effective separability (P-R Ch. 2 Stability Lemma). Independent of L1/L4, high-leverage,
  exercises the typeclass design.
- **L2 Grzegorczyk–Lacombe** (slug `l2-grzegorczyk-lacombe`): new front. Note the heavy
  overlap with `CMap.lean`'s polynomial-approximation machinery — scope it to *reuse*, not
  duplicate, before starting.
- **Zulip outreach** (per `CLAUDE.md` §"Mathlib community engagement"): with L0/L1/L3
  green and L4-A1 closed, the project is credible to pitch. Prepare drafts only — **the
  user does the actual posting/sharing**, not you.

## Hard guardrails

- **Never commit unless the user explicitly asks.** `git push` is denied in settings.
- **Sorry policy** (`CLAUDE.md`): `sorry` allowed only in theorem/lemma bodies, each with
  a `-- TODO(/formalize L<N>):` comment; **never** in `def`/`structure`/`class`/`instance`/
  `abbrev` bodies. `\leanok`/`\mathlibok` only on decls with no transitive `sorry`.
- **Do not author L5/L2 theorem statements (or any P-R citation) from memory.** Grep the
  literature and verify the quoted phrase verbatim first (`CLAUDE.md` §"When in doubt,
  grep"; `docs/PITFALLS.md` §6).
- **Do not touch**: `claims/INDEX.md`, `.github/workflows/**`, `lakefile.toml`,
  `lake-manifest.json`, `lean-toolchain`, `literature/papers/**/verbatim.md`, and the
  historical `.goals/**` / `claims/**` / `thinking/**` archives.
- **Read `docs/PITFALLS.md` + `docs/LEAN-IDIOMS.md`** before opening a new L-layer round.

## Verification pipeline (run in order)

1. `lake build 2>&1 | tail -5` — expect 0 errors. Until A2/A3 close, expect exactly **2
   `sorry`s** (`CMap.lean:1268,1279`) and **1** sorry-warning at `CMap.lean:639`.
2. `python3 -c "[print(p,i) for p in ['<file>'] for i,l in enumerate(open(p,encoding='utf-8'),1) if len(l.rstrip(chr(10)))>100]"`
   — no line >100 columns (count **codepoints**, not bytes; awk over-counts unicode).
3. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web 2>&1 | tail -5` — exit 0.
4. `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls; echo "exit: $?"` —
   must stay exit 0 (every `\lean{}` target resolves in the lake env).

---

*End of prompt.*
