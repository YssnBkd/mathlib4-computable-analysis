# claims/ — index

Registry of formal claims by goal-slug. Per-claim metadata (sources, dependencies, DA verdict) lives in each claim file's YAML frontmatter; this file gives an at-a-glance map.

> **2026-06-02 transition.** Starting with this date, `blueprint/src/*.tex` is the canonical source for *formal statements* and *formalization state*. Claim files persist as **rationale satellites**: design notes, alternatives considered, sourcing detail, devil's-advocate verdicts — paired with the LaTeX node via `[[blueprint:<label>]]` at the top. Statuses (`intuition` / `conjecture` / `our_construction` / `cited_result` / `verified` / `refuted` / `formalized`) used in pre-existing files remain readable but are no longer authoritative — the dep graph at `blueprint/web/dep_graph_document.html` is. Migration of pre-existing L1/L3 claim files to satellite form is deferred to per-layer rounds.

**Status mapping (old → blueprint).** For existing claim files; new claims should be written directly as satellites with no YAML status:

| Old YAML status | Blueprint state |
|---|---|
| `intuition` | Pre-blueprint (`intuition/*.md`); not in dep graph until LaTeX node added. |
| `conjecture` | Stated in blueprint without `\lean{}` — appears in graph but white-bordered. |
| `our_construction` | `\begin{definition}` in blueprint. |
| `cited_result` | `\mathlibok` if in Mathlib, else `\notready` + external citation. |
| `verified` | Stated + proof body in blueprint, no `\lean{}` (paper proof only). |
| `formalized` | `\lean{<decl>}\leanok` in blueprint. |
| `refuted` | Removed from blueprint; rationale satellite retained with `## Refutation` section. |

The `da_status` field on claim files still records the devil's-advocate verdict (`passes` / `unsupported` / `unsound` / `pending`) — orthogonal to dep-graph state and worth preserving on rationale satellites.

---

## example-collatz

| claim id | status | da_status | supersedes | superseded_by | central concept |
|---|---|---|---|---|---|
| `example-collatz-statement` | conjecture | pending | — | — | EXAMPLE — delete or replace. Every positive integer eventually reaches 1 under the `n → n/2` (even) / `n → 3n+1` (odd) map. |

### Claim files

- [`claims/example-collatz/example-collatz-statement.md`](example-collatz/example-collatz-statement.md) — EXAMPLE claim.

---

## (Future goals will add sections here)

Convention: one `##` per `<slug>` namespace.

## Cross-references

- Per-goal context + intuition: `intuition/INDEX.md` and `RESEARCH-INDEX.md`.
- Process certifications (formalization + DA review): `.goals/<slug>/reviews/*.md`.
- Verification (provenance + claim-id resolution): `scripts/verify_claims.py` checks the `dependencies:` field; `scripts/verify_provenance.py` checks `sources:` field against `literature/papers/<bibkey>/`.
