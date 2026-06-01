# example-collatz

**Status**: intuition — not a claim, not a proof.
**EXAMPLE**: this file is template scaffolding. Delete (and remove the row from `intuition/INDEX.md`) once you have your first real thread, or replace its contents with your own intuition while keeping the section layout.

## Mental model

Start with any positive integer `n`. Apply the rule: if `n` is even, replace it by `n/2`; if `n` is odd, replace it by `3n+1`. Iterate. The conjecture is that every starting `n` eventually hits 1 (after which the trajectory cycles `1 → 4 → 2 → 1`).

The picture: each trajectory is a sequence in `ℕ` that mixes "halving" (a strong contraction by factor 2) with occasional "tripling" (an expansion by factor 3, plus 1). For an odd step followed by some even steps, the net effect is roughly multiplication by `3/2^k` for some `k ≥ 1`. On average over "random" odd inputs, that multiplier is less than 1, so the trajectory drifts downward — but no proof of average behaviour rules out a single counterexample trajectory that escapes to infinity or settles into a non-trivial cycle.

## Analogies

- This is like a random walk on `log n` with biased drift toward zero, but the bias is deterministic, not stochastic — so probabilistic intuition is suggestive but not a proof.
- This differs from a contractive map (e.g., `n → ⌊n/2⌋`) because the `3n+1` branch can increase `n`, so contraction is not monotone.
- Where the analogy breaks: the random-walk picture treats odd-step occurrences as independent across trajectories, which they are not — the parity of subsequent terms is entirely determined by `n`.

## What would have to be true if this is right

- No starting `n` produces a strictly increasing infinite subsequence.
- No starting `n` lands in a non-trivial cycle (i.e., a cycle other than `1 → 4 → 2 → 1`).
- The set of `n` reaching 1 in at most `k` steps grows in a controllable way as `k → ∞`.

## What would falsify it

- A single explicit `n` whose trajectory has been verified to escape to infinity (computationally checked beyond what is known: as of writing, all `n < 2^68` are known to reach 1).
- An explicit non-trivial cycle.
- A proof that some structural class of starting integers (e.g., those of a specific 2-adic shape) cannot reach 1.

## What I don't know yet

- Whether the "average odd-step behaviour" intuition can be promoted into a Lyapunov function on `ℕ` (most attempts get stuck because `log n` is not strictly decreasing along trajectories — it can grow on a single `3n+1` step).
- Whether the right framing is dynamical-systems (orbits on `ℕ`) or number-theoretic (2-adic valuations of `3n+1` iterates).
- Whether known partial results — e.g., Tao 2019 showing almost all orbits attain almost-bounded values — are strengthenable.

## Pointers

- intuition references → none yet
- candidate sources to chase → invoke `lit-scout` (e.g., for "Tao 2019 Collatz almost-bounded orbits", "Lagarias survey Collatz")
- candidate formal claims to extract → `claims/example-collatz/example-collatz-statement.md` (companion claim, status `conjecture`)
- candidate experiments / computations → none queued
