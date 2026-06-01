# claims/ — index

Registry of formal claims by goal-slug. Per-claim metadata (status, DA verdict, supersedes/superseded-by, sources, dependencies) lives in each claim file's YAML frontmatter; this file gives an at-a-glance map.

**Status conventions** (per `claims/TEMPLATE.md`):

- `intuition` — informal idea, not a claim of truth.
- `conjecture` — precise statement we believe but cannot yet prove.
- `our_construction` — definition / object we introduce.
- `cited_result` — theorem from the literature, used as a building block.
- `verified` — claim with complete proof we have audited (DA verdict required).
- `refuted` — claim previously held that has been broken.

The `da_status` field separately records the devils-advocate verdict (`passes` / `unsupported` / `unsound` / `pending`) — this is orthogonal to `status` and tracks the protocol outcome of devil's-advocate review.

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
