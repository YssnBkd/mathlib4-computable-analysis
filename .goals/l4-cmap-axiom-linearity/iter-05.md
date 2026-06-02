# iter-05

timestamp: 2026-06-01T23:32:19.570893+00:00
unmet: [C2, C3, C4, C5, C6]
mode: proof-attempt
progress: SHIPPED isComputableSeqRat_add fully proved in formal/ComputableAnalysis/L4/Instances/CMap.lean — closure of L1's IsComputableSeqRat under pointwise addition. Lake build green with 1 sorry-warning (the original L4 instance grouping A1/A2/A3); helper has zero internal sorries. Witness via 4-case dispatch on sign-parities + cross-product comparison; Computable newA/newS via Computable.cond + Primrec.beq/.nat_le.swap.decide + of_eq; rational identity via pow_red (a (-1)^n = (-1)^(n%2) helper) + Nat.cast_sub + field_simp + try-ring across 6 sub-cases. C2 still unmet (A1 itself needs _mul/_reindex/_finsetSum helpers + ~50-line witness construction); _add alone unlocks none of A1, but is the largest single closure helper.
files_changed: ['.goals/INDEX.md', 'current-goal.md', '.goals/l4-cmap-axiom-linearity/goal.md', '.goals/l4-cmap-axiom-linearity/iter-00.md', '.goals/l4-cmap-axiom-linearity/iter-02.md', '.goals/l4-cmap-axiom-linearity/iter-03.md', '.goals/l4-cmap-axiom-linearity/iter-04.md', '.goals/l4-cmap-axiom-linearity/iter-05.md', 'thinking/l4-cmap-axiom-linearity/iter-02-orientation.md', 'thinking/l4-cmap-axiom-linearity/iter-03-strategy.md', 'thinking/l4-cmap-axiom-linearity/iter-04-add-helper.lean.draft', 'formal/ComputableAnalysis/L4/Instances/CMap.lean']
