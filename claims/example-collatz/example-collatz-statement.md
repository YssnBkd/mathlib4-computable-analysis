---
id: example-collatz-statement
status: conjecture
created: 2026-05-31
dependencies: []
sources: []
---

# Every positive integer eventually reaches 1 under the Collatz map

EXAMPLE — this claim is template scaffolding. Delete the file (and remove the row from `claims/INDEX.md`) once you have your first real claim, or replace its contents with your own statement while keeping the YAML frontmatter and section layout.

## Formal statement

\begin{conjecture}
Let $T : \mathbb{N}_{>0} \to \mathbb{N}_{>0}$ be defined by
$$T(n) = \begin{cases} n/2 & \text{if } n \text{ even},\\ 3n+1 & \text{if } n \text{ odd}.\end{cases}$$
For every $n \in \mathbb{N}_{>0}$, there exists a finite $k \in \mathbb{N}$ such that $T^k(n) = 1$.
\end{conjecture}

## Informal restatement

Pick any positive integer and repeatedly apply the rule "halve if even, triple-and-add-one if odd." The conjecture asserts that this process always reaches 1, no matter the starting integer. Equivalently, the only cycle of the map $T$ within $\mathbb{N}_{>0}$ is the trivial cycle $\{1, 2, 4\}$, and no orbit escapes to infinity.

## Why we believe it (or believed it)

- All starting values $n < 2^{68}$ have been computationally verified to reach 1 (per published numerical surveys).
- A heuristic "average-multiplier" argument suggests odd steps followed by an even step give a multiplicative factor close to $3/4$, so trajectories should drift downward in $\log n$. (This is not a proof.)
- Tao (2019) showed that *almost all* starting values reach an almost-bounded value, ruling out a "thick" set of escaping trajectories.

## Dependencies

(none — this is a stand-alone statement)

## Devil's-advocate verdict

- Last reviewed: never
- Verdict: (none yet)
- Open weaknesses: this file is scaffolding only; a real review would not be useful here.
