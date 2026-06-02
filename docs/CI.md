# docs/CI.md — CI / Pages workflow split

The project ships two GitHub Actions workflows. They share a Pages deploy target but differ in build scope and cadence: a **fast** workflow runs on every push to keep the blueprint dep graph honest, and a **slow** workflow runs on tag pushes to bundle the full Mathlib-linked API documentation.

## Why two workflows

Building the Mathlib API docs (`lake build :docs`) compiles documentation for ~5900 transitively-imported Mathlib modules. That alone is ~15 minutes of the previous combined build. For a small bespoke project, the cost of doc-gen running on every commit is unacceptable: a 15-second local Lean change waits 20 minutes for CI confirmation, and reviewers tracking the blueprint dep graph see no change for the same 20 minutes.

The split moves doc-gen to a release cadence (tags) where the cost is amortized, while keeping the blueprint update on every push.

## `.github/workflows/blueprint.yml` — fast, every push (~3-5 min)

**Triggers**: push to `master`; manual via Actions tab → "Run workflow".

**What it does**:
1. Free Ubuntu disk space (Mathlib cache fetch needs ~10 GB).
2. Checkout the repository at full depth.
3. Install Lean toolchain via `leanprover/lean-action` with:
   - `build: true` — runs `lake build`
   - `lint: false` — no `lake check-lint` (we don't declare a `lint_driver`)
   - `mk_all-check: false` — no umbrella validation (`lake build` already validates)
   - `use-mathlib-cache: auto` — pulls pre-built oleans from Mathlib CI cache
4. Install Python 3.11, graphviz system packages, and `leanblueprint` from PyPI.
5. `leanblueprint web` → produces `blueprint/web/` (plasTeX HTML + dep graph).
6. `leanblueprint checkdecls` → validates every `\lean{...}` macro in `blueprint/src/*.tex` resolves to an actual Lean declaration.
7. Upload `blueprint/web/` as a Pages artifact.
8. Deploy to Pages.

**End state**: the live blueprint at `https://yssnbkd.github.io/mathlib4-computable-analysis/` reflects HEAD of `master`. The dep graph at `/dep_graph_document.html` shows `\leanok` state matching the current Lean code.

**Cross-link gap**: the blueprint's `\lean{ComputableAnalysis.L0.cantorPair}` macros generate links to `<dochome>/find/#doc/ComputableAnalysis.L0.cantorPair`. Between tag releases, the `/docs/` path does not exist on Pages, so those links 404 for *our* private declarations. Mathlib symbols (`Computable`, `Primrec`, ...) still resolve if you point `\dochome` in `blueprint/src/web.tex` at `https://leanprover-community.github.io/mathlib4_docs/` — left at our own `/docs/` URL by default so post-tag deploys "just work".

**Concurrency**: group `pages-fast-<ref>`, `cancel-in-progress: true`. Duplicate pushes are debounced.

## `.github/workflows/docs.yml` — slow, on tags (~15-20 min)

**Triggers**: push of tags matching `v*` or `release-*`; manual via Actions tab.

**What it does**:
1. Free Ubuntu disk space.
2. Checkout.
3. `leanprover-community/docgen-action` (with `blueprint: true`) — single composite action that runs:
   - Lean toolchain install + `lake build`
   - `lake build :docs` — the slow step; generates HTML docs for every transitively-imported Mathlib module (~5900 jobs)
   - Blueprint compilation (PDF + web)
   - Pages artifact upload + deploy

**End state**: Pages serves the blueprint at the root URL AND the API docs at `/docs/`. Our `\lean{...}` macros now resolve fully (project decls + Mathlib decls).

**Concurrency**: group `pages-slow-<ref>`, `cancel-in-progress: false`. A tagged docs build runs to completion even if more commits land on `master` during it.

## How to use

### Day to day

Push to `master`. The fast workflow runs in ~5 min, deploys the updated blueprint. Iterate locally before pushing — see "Local equivalents" below.

```bash
git push                          # → fast workflow runs
gh run watch --repo YssnBkd/mathlib4-computable-analysis    # optional: follow
```

### Release prep

Tag a release; the slow workflow runs once and deploys the full bundle.

```bash
git tag v0.1.0 -m "L0 + L3 blueprint MVP"
git push --tags
```

Until the next push to `master`, both the blueprint and `/docs/` resolve. After the next push to `master`, the fast workflow redeploys the blueprint without `/docs/`, and `/docs/` 404s until the next tag.

This is acceptable because:
- The docs at `/docs/` are a snapshot of the tagged commit, not HEAD.
- Reviewers visiting between tag and next push see the docs; reviewers later see the dep graph (which is the actually-up-to-date artifact).
- Tagging is intentional — you tag when you want a documented snapshot.

### Tag-then-keep-docs convention

If you want to push a series of patch commits to `master` AFTER a tag without losing the docs deploy, the simplest hack is to push the tag *last*:

```bash
git push                          # fast workflow deploys blueprint
# ... more commits, more pushes (each one runs fast workflow)
git tag v0.1.1 -m "patches"
git push --tags                   # slow workflow re-deploys docs on top
```

## When to fold slow into fast

Justified when:
- `doc-gen4` gains incremental builds (cache between runs) — not in stable as of 2026-06-02.
- The project's docs are deployed often enough that running on tags only feels too lazy.
- Pre-upstream cleanup: when L4/L5 are mostly closed and Mathlib reviewers are clicking the `\lean{...}` links in PR threads, the docs need to be current — flip the fast workflow to also build docs.

Until then: tag-driven docs deploy keeps the inner loop short.

## Local equivalents (sub-minute, run during the inner loop)

| CI step | Local command | Typical time on a 6-file project |
|---|---|---|
| Lean type-check a single file | `lake env lean ComputableAnalysis/L1/<file>.lean` | 2-8 s |
| Lean full build (incremental) | `lake build` | 5-30 s |
| Lean full build (cold, no cache) | `lake exe cache get && lake build` | 2-5 min (one-time) |
| Build blueprint HTML | `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint web` | 10-15 s |
| Validate `\lean{...}` decls | `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint checkdecls` | 3-5 s |
| Build blueprint PDF | `PATH="$PWD/.venv/bin:$PATH" .venv/bin/leanblueprint pdf` | 30-60 s (xelatex) |
| Build API docs locally | `lake build ComputableAnalysis:docs` | 10-15 min (full Mathlib doc-gen) |

**Inner-loop discipline**: `lake build` + `leanblueprint web` is ~30 s total. Don't wait for CI to know whether your code compiles; iterate locally and let CI confirm at the end.

## Troubleshooting

**Fast workflow fails at `leanblueprint checkdecls`**: a `\lean{<name>}` macro in `blueprint/src/*.tex` points at a Lean declaration that doesn't exist. Either fix the macro (typo in the namespace?) or add the missing decl. Do NOT add a sorry-bearing decl just to make the check pass — that violates CLAUDE.md's `\leanok` policy.

**Fast workflow fails at `lake build`**: the Mathlib cache may have rotated; the lean-action's `use-mathlib-cache: auto` should handle this, but if Mathlib's API changed, our imports may break. Locally run `lake update mathlib && lake exe cache get && lake build` to reproduce.

**Slow workflow fails at `lake build :docs`**: doc-gen4 sometimes fails on certain doc strings. Check the failed log; usually the fix is a malformed docstring (unclosed `*` for italics, etc.) in one of our `.lean` files.

**Slow workflow fails at `bundle exec jekyll build` with "Could not locate Gemfile"**: `docgen-action` defaults to `build-page: true`, which assumes `docs/` is a Jekyll source directory. Our `docs/` is internal markdown notes (no Gemfile). The fix — `build-page: false` in `docs.yml` — is already applied; if you ever lift docgen-action calls into other workflows, repeat the override. (This was the failure mode of the original combined workflow before the fast/slow split.)

**Pages deploy step fails with permissions error**: confirm `Settings → Pages → Source` is set to **GitHub Actions** (not "Deploy from a branch"). The workflow's `pages: write` permission is sufficient.

**`workflow` scope rejection on push** (`refusing to allow an OAuth App to create or update workflow without workflow scope`): your token lacks the `workflow` scope. Run `gh auth refresh -h github.com -s workflow` then retry.
