---
id: <topic>-<short-slug>
blueprint: blueprint:<label>          # the \label{...} in blueprint/src/*.tex this satellites
created: <ISO 8601>
sources: []                           # required if cited from literature; format: <bibkey>:<locator>
dependencies: []                      # other claim ids this builds on
da_status: pending                    # pending | passes | unsupported | unsound
---

> **Blueprint:** `[[blueprint:<label>]]` — formal statement and formalization
> state (`\leanok` / `\notready` / `\mathlibok`) live there. This file holds
> design rationale only.

# <one-line statement>

## Why this construction

<2-3 sentences: why this particular phrasing / typeclass / predicate shape,
rather than alternatives. What constraint pinned it.>

## Alternatives considered

- <alternative 1> — rejected because <one line>.
- <alternative 2> — rejected because <one line>.

## Mathlib-idiom mapping

<which Mathlib types / typeclasses / namespaces this hooks into; if the answer
is "creates a new abstraction", note why an existing one was insufficient.>

## Sources

- P-R Ch.X:Y — <verbatim quote or paraphrase> (see `literature/papers/PourEl-Richards-chapt<N>.md:<line>`)
- <other-paper>:<page> — <relevance>

## Devil's-advocate verdict

- Last reviewed: <date or "never">
- Verdict: <passes | unsupported | unsound | (none yet)>
- Open weaknesses: <one line each>

## Notes for future revisions

- <hint a future revisitor would value: "if Mathlib eventually exports `Foo.bar`, this could be simplified to just an alias">
