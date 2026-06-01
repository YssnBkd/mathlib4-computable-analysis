/-
Copyright (c) 2026 The mathlib-computable-analysis contributors. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: The mathlib-computable-analysis contributors
-/
import ComputableAnalysis.L0.Bridge
import ComputableAnalysis.L0.PropB
import ComputableAnalysis.L0.AnalysisBridge
import ComputableAnalysis.L1.ComputableSeqReal
import ComputableAnalysis.L3.ComputabilityStructure

/-!
# Computable analysis in Mathlib4

A Pour-El & Richards-style axiomatic development of computable analysis,
intended for upstream contribution to `Mathlib.Computability.Analysis.*`.

See `CLAUDE.md` for the project's architectural commitments, `literature/INDEX.md`
for the P-R verbatim corpus, and the five-layer architecture for the L0→L5
progression.

This file is the umbrella import; downstream consumers (or `#check` callers)
should `import ComputableAnalysis` rather than reaching into individual modules.
-/
