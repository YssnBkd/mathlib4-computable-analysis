#!/usr/bin/env python3
"""Extract A1 inline body into a standalone theorem.

Plan (1-indexed line numbers; the script uses 0-indexed Python slicing):
- Lines  1..618 : unchanged prefix (everything up to instance docstring).
- INSERT          : standalone theorem `isComputableSeqCMap_linearCombination`
                    (docstring + signature + dedented body).
- Lines 619..642 : unchanged instance docstring + decl opener + first field
                    `IsComputableSeq := IsComputableSeqCMap`.
- REPLACE         : the inline A1 field (was lines 643..1257) with a single
                    delegation line `isComputableSeq_linearCombination :=
                    isComputableSeqCMap_linearCombination B hα_le hβ_le`.
- Lines 1258..end : unchanged (A2/A3/NV + section/namespace closers).

Safety:
- Sanity-asserts on lines 619, 643, 1258 before mutating.
- Dedent only strips 2 leading spaces; any non-blank line with <2 leading
  spaces aborts with an error (uncovered indentation pattern).
"""

from pathlib import Path
import sys

src = Path('ComputableAnalysis/L4/Instances/CMap.lean')
lines = src.read_text(encoding='utf-8').splitlines(keepends=True)
print(f"Loaded {len(lines)} lines.")

# --- Sanity checks ---------------------------------------------------------
assert lines[618].startswith('/-- The `ComputabilityStructure'), \
    f"Line 619 unexpected: {lines[618]!r}"
assert lines[642].rstrip('\n') == '  isComputableSeq_linearCombination := by', \
    f"Line 643 unexpected: {lines[642]!r}"
assert lines[1257].rstrip('\n') == '  isComputableSeq_of_effectiveLimit := by', \
    f"Line 1258 unexpected: {lines[1257]!r}"

# --- Build dedented tactic body ------------------------------------------
tactic_lines = lines[643:1257]  # 1-indexed lines 644..1257 (the A1 body inside `by`)
dedented = []
for idx, line in enumerate(tactic_lines, start=644):
    if line.strip() == '':
        dedented.append(line)
        continue
    if not line.startswith('  '):
        print(f"ERROR: line {idx} has <2 leading spaces: {line!r}", file=sys.stderr)
        sys.exit(1)
    dedented.append(line[2:])

# --- Compose new theorem block --------------------------------------------
theorem_docstring = (
    "/-- **C[a,b] computability — Axiom 1 (Linear Forms).** P-R Ch. 2:66-72.\n"
    "\n"
    "Given a fixed rational bound `B ≥ max(|α|, |β|)`, the C[a,b]-sequence\n"
    "predicate `IsComputableSeqCMap` is closed under finite linear combinations\n"
    "with computable rational scalar arrays. This is the A1 instance field of\n"
    "`computabilityStructureCMap_of` extracted as a named, sorry-free lemma so\n"
    "that the blueprint's `lem:l4_cmap_axiom1` can `\\lean{}`-link directly to\n"
    "it without inheriting `sorryAx` from the sibling A2/A3 fields (see\n"
    "`docs/PITFALLS.md §7`).\n"
    "\n"
    "Proof shape (rounds `l4-cmap-axiom-linearity-cont` and\n"
    "`l4-cmap-axiom-linearity-bound`): witnesses for the linear combination are\n"
    "obtained by applying the same finite combination to the witness polynomials\n"
    "of `x` and `y`. A per-level precision pad\n"
    "`M(n, m) := m + (d n + 1) + bound_max n + 2` absorbs both the per-summand\n"
    "norm bound (controlled by `B`) and the arity, turning the polynomial\n"
    "triangle inequality into the required `1 / 2 ^ m` estimate. -/\n"
)

theorem_sig = (
    "theorem isComputableSeqCMap_linearCombination\n"
    "    (B : ℕ) (hα_le : |α| ≤ (B : ℝ)) (hβ_le : |β| ≤ (B : ℝ)) :\n"
    "    ∀ (x y : ℕ → C(Set.Icc α β, ℝ))\n"
    "      (coefα coefβ : ℕ × ℕ → ℝ) (d : ℕ → ℕ),\n"
    "      IsComputableSeqCMap x → IsComputableSeqCMap y →\n"
    "      ScalarComputableSeq.IsComputableSeq (fun n => coefα (Nat.unpair n)) →\n"
    "      ScalarComputableSeq.IsComputableSeq (fun n => coefβ (Nat.unpair n)) →\n"
    "      Computable d →\n"
    "      IsComputableSeqCMap\n"
    "        (fun n => ∑ k ∈ Finset.range (d n + 1),\n"
    "            (coefα (n, k) • x k + coefβ (n, k) • y k)) := by\n"
)

theorem_block = theorem_docstring + theorem_sig + ''.join(dedented) + '\n'

# --- Delegation line (replaces the entire inline A1 field body) -----------
delegation = (
    '  isComputableSeq_linearCombination :=\n'
    '    isComputableSeqCMap_linearCombination B hα_le hβ_le\n'
)

# --- Assemble new file ----------------------------------------------------
new_content = (
    ''.join(lines[:618]) +         # 1..618 unchanged
    theorem_block +                # new theorem
    ''.join(lines[618:642]) +      # 619..642 unchanged (instance docstring + decl + IsComputableSeq field)
    delegation +                   # new short A1 field
    ''.join(lines[1257:])          # 1258..end unchanged (A2/A3/NV + closers)
)

src.write_text(new_content, encoding='utf-8')
new_lines = new_content.count('\n')
print(f"Wrote {new_lines} lines (was {len(lines)}).")
print(f"Lines removed from inline A1: {1257 - 643 + 1}")
print(f"Lines added for standalone theorem: ~{theorem_block.count(chr(10))}")
