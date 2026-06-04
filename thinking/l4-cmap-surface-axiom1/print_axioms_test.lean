import ComputableAnalysis.L4.Instances.CMap

/-! Standalone `#print axioms` check for `isComputableSeqCMap_linearCombination`.

This file is NOT part of the lake library; run with
`lake env lean thinking/l4-cmap-surface-axiom1/print_axioms_test.lean`.

Per `docs/PITFALLS.md §7`, this is the only correct way to audit whether the
A1 lemma is genuinely sorry-free — projecting `#print axioms (instance).field`
gives a false positive due to sibling A2/A3 fields' sorries dragging in
`sorryAx`. -/

#print axioms ComputableAnalysis.L4.isComputableSeqCMap_linearCombination
