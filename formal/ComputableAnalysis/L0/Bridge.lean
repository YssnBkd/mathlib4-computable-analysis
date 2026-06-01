/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import Mathlib.Computability.Partrec
import Mathlib.Computability.PartrecCode
import Mathlib.Computability.RE
import Mathlib.Computability.Halting
import Mathlib.Data.Nat.Pairing

/-!
# L0 — Pour-El & Richards prerequisites: recursion-theory bridge

This file aliases Pour-El & Richards' Ch. 0.2 ("Prerequisites from logic and
analysis") notation onto Mathlib4's existing `Computability.*` machinery.

P-R explicitly says at Ch. 0.2:12 that the entire book uses only ONE nontrivial
fact from recursion theory — the existence of a recursively enumerable
nonrecursive set (Proposition A below) — plus a pairing function. A slightly
stronger fact, the existence of a recursively inseparable pair (Proposition B),
is occasionally needed; it lives in a sibling file `PropB.lean`.

## P-R notion → Mathlib symbol

(References: `literature/papers/PourEl-Richards-0.2.prerequisites.md`)

| P-R notation (line) | Mathlib4 |
|---|---|
| "recursive function `a : ℕ → ℕ`" (:5) | `Computable a` |
| "recursive function `ℕ^q → ℕ`" (:5) | `Computable a` via `Primcodable (Fin q → ℕ)` |
| "recursively enumerable set" (:25) | `REPred (· ∈ A)` |
| "recursive set" (:27) | `ComputablePred (· ∈ A)` |
| **Proposition A** (:31): ∃ r.e. nonrecursive set | `ComputablePred.halting_problem{_re,}` |
| pairing `J(x,y) = (x+y)(x+y+1)/2 + x` (:49) | this file's `cantorPair`; see also `Nat.pair` |
| `χ_S` analyst's convention (:55) | this file's `charFn` |

## Note on the pairing function

P-R uses Cantor's triangular formula `J(x,y) = (x+y)(x+y+1)/2 + x`. Mathlib's
`Nat.pair` uses the max-based square formula `if a < b then b² + a else a² + a + b`.
Both are recursive bijections `ℕ × ℕ ≃ ℕ`. Throughout downstream layers we use
`Nat.pair` (since Mathlib's lemmas are built on it); `cantorPair` is provided
only for fidelity when an argument cites P-R's specific formula. The two pairings
are interconvertible via a recursive bijection of `ℕ`, so all P-R statements
transfer.

## References

- Pour-El, M.B. & Richards, J.I., *Computability in Analysis and Physics*,
  Springer-Verlag 1989. Verbatim Ch. 0.2 at
  `literature/papers/PourEl-Richards-0.2.prerequisites.md`.
- Soare, R.I., *Recursively Enumerable Sets and Degrees*, Springer 1987 (for the
  Prop. B construction in the sibling file).
-/

namespace ComputableAnalysis.L0

/-! ## §1 — Recursive functions, r.e. sets, recursive sets -/

/-- P-R's "recursive function" (any arity, via Mathlib's `Primcodable` framework).

ref: `literature/papers/PourEl-Richards-0.2.prerequisites.md:5` -/
abbrev IsRecursive {α : Type*} {β : Type*} [Primcodable α] [Primcodable β]
    (f : α → β) : Prop :=
  Computable f

/-- P-R "recursively enumerable set" (Ch. 0.2:25). Mathlib's `REPred` captures the
membership predicate as a partial-recursive characteristic function; equivalent to
P-R's "A is the range of a recursive function or A is empty" by standard r.e.-set
theory. -/
abbrev IsRecursivelyEnumerable {α : Type*} [Primcodable α] (A : Set α) : Prop :=
  REPred (· ∈ A)

/-- P-R "recursive set" (Ch. 0.2:27): both A and its complement are r.e.
Equivalently (Post's theorem) `(· ∈ A)` is a `ComputablePred`. -/
abbrev IsRecursiveSet {α : Type*} [Primcodable α] (A : Set α) : Prop :=
  ComputablePred (· ∈ A)

/-! ## §2 — Proposition A: ∃ r.e. nonrecursive set

P-R Ch. 0.2:31. Mathlib witnesses Prop A with the halting predicate on
`Nat.Partrec.Code`. -/

/-- The halting set at a fixed input `n`: codes `c` such that `c.eval n` halts.

Mathlib does not give this set a name; we name it here for use in `prop_A`. -/
def haltingSetAt (n : ℕ) : Set Nat.Partrec.Code :=
  { c | (c.eval n).Dom }

/-- The halting set is r.e. (direct from Mathlib). -/
theorem haltingSetAt_re (n : ℕ) :
    IsRecursivelyEnumerable (haltingSetAt n) :=
  ComputablePred.halting_problem_re n

/-- The halting set is not recursive (direct from Mathlib). -/
theorem haltingSetAt_not_recursive (n : ℕ) :
    ¬ IsRecursiveSet (haltingSetAt n) :=
  ComputablePred.halting_problem n

/-- **Pour-El & Richards, Proposition A** (Ch. 0.2:31).

There exists a recursively enumerable, non-recursive set. -/
theorem prop_A_exists_re_not_recursive :
    ∃ (α : Type) (_inst : Primcodable α) (A : Set α),
      IsRecursivelyEnumerable A ∧ ¬ IsRecursiveSet A :=
  ⟨Nat.Partrec.Code, inferInstance, haltingSetAt 0,
    haltingSetAt_re 0, haltingSetAt_not_recursive 0⟩

/-! ## §3 — Pairing function

P-R's `J(x,y) = (x+y)(x+y+1)/2 + x` vs Mathlib's max-based `Nat.pair`. -/

/-- P-R's Cantor pairing function `J(x,y) = (x+y)(x+y+1)/2 + x`.

ref: `literature/papers/PourEl-Richards-0.2.prerequisites.md:49` -/
def cantorPair (x y : ℕ) : ℕ :=
  (x + y) * (x + y + 1) / 2 + x

/-- `cantorPair` is two-argument computable.

It is primitive recursive — composition of `Nat.add`, `Nat.mul`, `Nat.div` — so
`Primrec.to_comp` (Computable from Primrec) closes the goal once we exhibit a
`Primrec` witness for the explicit formula. -/
theorem cantorPair_computable : Computable₂ cantorPair := by
  show Computable fun p : ℕ × ℕ => (p.1 + p.2) * (p.1 + p.2 + 1) / 2 + p.1
  refine Primrec.to_comp ?_
  -- Build the witness layer by layer using `Primrec₂.comp` against
  -- `Primrec₂.nat_add/mul/div` and `Primrec.fst/snd`. Each `Primrec₂.comp`
  -- substitutes two `Primrec : ℕ × ℕ → ℕ` subexpressions into a binary primrec.
  exact Primrec₂.comp Primrec.nat_add
    (Primrec₂.comp Primrec.nat_div
      (Primrec₂.comp Primrec.nat_mul
        (Primrec₂.comp Primrec.nat_add Primrec.fst Primrec.snd)
        (Primrec₂.comp Primrec.nat_add
          (Primrec₂.comp Primrec.nat_add Primrec.fst Primrec.snd)
          (Primrec.const 1)))
      (Primrec.const 2))
    Primrec.fst

/-! ## §4 — Characteristic function (analyst's convention)

P-R uses the analyst's convention `χ_S(x) = 1 if x ∈ S else 0` (Ch. 0.2:55),
contrasted with the logicians' convention `0 ∈ S → 1`. Mathlib's `Set.indicator`
is the standard tool but takes a value-providing function rather than a bool. -/

/-- P-R's characteristic function under the analyst's convention. -/
def charFn (S : Set ℕ) [DecidablePred (· ∈ S)] (x : ℕ) : ℕ :=
  if x ∈ S then 1 else 0

/-! ## §5 — Smoke checks -/

#check @IsRecursive
#check @IsRecursivelyEnumerable
#check @IsRecursiveSet
#check @haltingSetAt
#check @haltingSetAt_re
#check @haltingSetAt_not_recursive
#check @prop_A_exists_re_not_recursive
#check @cantorPair
#check @cantorPair_computable
#check @charFn

end ComputableAnalysis.L0
