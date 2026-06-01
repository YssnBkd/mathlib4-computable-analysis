---
slug: l3-computability-structure-axioms
started: 2026-06-01T13:49:34Z
mode: explore
max_iterations: 8
time_budget_minutes: 90
allow_writes:
  - intuition/l3-computability-structure.md
  - thinking/l3-computability-structure-axioms/**
  - claims/l3-computability-structure/**
  - claims/l1-computable-reals/**
  - proofs/l3-computability-structure/**
  - .goals/l3-computability-structure-axioms/**
  - .goals/INDEX.md
forbid_writes:
  - literature/papers/**
  - raw_papers/**
  - CLAUDE.md
devils_advocate_required_for:
  - "C2"
---

# Goal: state the three Pour-El–Richards axioms of a computability structure as a precise `our_construction` claim, with verbatim source pointers

## Why this matters

L3 is the architectural keystone of the entire project (CLAUDE.md commitment #1): every layer above (L4 instances, L5 main theorems) and below (L1 computable reals supplies Axiom 3's "computable sequence of reals") is shaped by the precise form of these three axioms. P-R Ch. 2 is already verbatim-ingested at `literature/papers/PourEl-Richards-chapt2.md`, so the round is bounded: transcribe with discipline, stub the one cross-layer dependency, and have devil's-advocate verify the statement before we build anything on top. See `intuition/l3-computability-structure.md` (to be created in C1).

## Success criteria

- [ ] C1: `intuition/l3-computability-structure.md` exists — prose mental model: why these three axioms, what each one rules in/out, falsification conditions, residual unknowns. No formal statements (Rule 3).
- [ ] C2: `claims/l3-computability-structure/axioms.md` exists with status `our_construction`, stating the three P-R Ch. 2 axioms (linearity, limits, norm) precisely.
- [ ] C3: Each axiom in C2 carries a verbatim-quoted source pointer of the form `literature/papers/PourEl-Richards-chapt2.md:LINE` with the exact P-R wording in a quoted block.
- [ ] C4: `claims/l1-computable-reals/is-computable-seq-real.md` stub exists with status `our_construction` — the L1 term that Axiom 3 (norm) references — with a verbatim source pointer to `literature/papers/PourEl-Richards-chapt0.md:LINE`.
- [ ] C5: Devil's-advocate review on `claims/l3-computability-structure/axioms.md` returns verdict `passes`; review written to `.goals/l3-computability-structure-axioms/reviews/C2.md`.
- [ ] C6: `/verify` returns clean across the touched files (no missing status labels or unresolved source pointers).

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes` (in particular: `CLAUDE.md`, `literature/papers/**`, other claims topics)
- ≥3 iterations with identical unmet criteria (stagnation)
- Devil's-advocate verdict `unsound` on any committed claim
- iter ≥ 8 or elapsed ≥ 90 minutes
