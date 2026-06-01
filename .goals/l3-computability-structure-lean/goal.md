---
slug: l3-computability-structure-lean
started: 2026-06-01T19:20:06Z
mode: explore
max_iterations: 50
time_budget_minutes: 3600
allow_writes:
  - formal/**
  - claims/l3-computability-structure/**
  - claims/l1-computable-reals/**
  - CLAUDE.md
  - docs/zulip-drafts/**
  - docs/zulip-threads.md
  - .goals/l3-computability-structure-lean/**
  - .goals/INDEX.md
  - current-goal.md
forbid_writes:
  - claims/**
  - literature/papers/**
  - raw_papers/**
  - formal/lean-toolchain
  - formal/lake-manifest.json
devils_advocate_required_for: []
---

# Goal: Execute `docs/NEXT-SESSION.md` — land L3 ComputabilityStructure typeclass + clear the build, with build/L1/Zulip side-actions.

## Why this matters

L3 `ComputabilityStructure` is the architectural keystone of the entire
project — CLAUDE.md commitment #1 (typeclass over Mathlib types, not parallel
hierarchy). The L0/L1 prerequisites all compile; the L3 paper-design has been
DA-cleared 8 rounds. The type-checker is now the next, more decisive,
adjudicator.

Source prompt: `docs/NEXT-SESSION.md` (self-contained continuation prompt).
Prior `/goal`: `execute-docs-next-session-md` (success, 2/30 iters,
2026-06-01) closed all L0 sorries and wrote L1 `IsComputableSeqReal`.
Paper-claim foundation: `claims/l3-computability-structure/axioms.md`
(status `our_construction`, 8 DA rounds clean).

## Success criteria

- [ ] C1: `cd formal && lake build` returns exit code 0. Pre-existing L1 helper sorries may remain *iff* C3 keeps them with explicit `-- TODO(/formalize L1):` markers; no NEW `sorry` in any `def` / `structure` / `class` / `instance` / `abbrev` body (CLAUDE.md sorry policy).
- [ ] C2: `formal/ComputableAnalysis/L3/ComputabilityStructure.lean` exists, type-checks (`lake env lean ComputableAnalysis/L3/ComputabilityStructure.lean` returns 0 errors), is imported by `formal/ComputableAnalysis.lean`, and contains a `class ComputabilityStructure` whose fields encode the four P-R Ch. 2 conditions: `IsComputableSeq` predicate, Axiom 1 (Linear Forms), Axiom 2 (effective Limits), Axiom 3 (Norms; reaches down to L1's `IsComputableSeqReal`), and `zero_seq` non-vacuity. Field signatures concrete (no `sorry`); proofs of axiom-satisfaction for concrete instances are L4 work and deferred.
- [ ] C3: The 2 pre-existing L1 helper sorries (`isComputableSeqRat_const` ~L116, `isComputableSeqReal_const_rat` ~L126 of `formal/ComputableAnalysis/L1/ComputableSeqReal.lean`) are either (a) closed with a complete proof, OR (b) retained with their existing `-- TODO(/formalize L1):` markers after at most 3 substantive proof attempts each (Watchpoint: "don't spin on a single sorry").
- [ ] C4: Zulip post decision recorded. Either user-authorized posts go up with URL + 1-paragraph summary at `docs/zulip-threads.md`, or a one-line deferral note is appended to the relevant draft file(s) (e.g., "deferred 2026-06-01; revisit after L3 stub compiles").
- [ ] C5: CLAUDE.md milestone tracker reflects the L3 outcome — row for "L3 / ComputabilityStructure typeclass — three axioms" moves from `claimed` to `stub` (file exists with theorem-body sorries only) or `formalized` (predicate/structure bodies sorry-free; theorem bodies may still sorry). Rule per CLAUDE.md §"Milestone tracker".

## Hard stops

- Any write outside `allow_writes` or matching `forbid_writes`
- ≥3 iterations with identical unmet criteria
- Devil's-advocate verdict `unsound` on any committed claim (N/A — DA list empty)
- iter ≥ 50 or elapsed ≥ 3600 minutes
