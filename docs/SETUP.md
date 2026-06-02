# docs/SETUP.md — first-time Lean toolchain setup

This project ships pre-written Lean code at the repo root (`lakefile.toml` +
`ComputableAnalysis/` umbrella + tree). To compile it you need
elan (Lean 4 toolchain manager) and Mathlib4's compiled cache.

## 1. Install elan

```bash
# macOS via Homebrew (recommended):
brew install elan-init

# or via the upstream installer:
curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \
  | sh -s -- -y --default-toolchain none
```

After install, ensure `~/.elan/bin` is on PATH (Homebrew handles this
automatically; the curl installer prints shell instructions).

Verify:

```bash
which elan && which lake && which lean
elan --version
```

The first `lake` / `lean` invocation at the repo root will auto-install the Lean
version pinned in `lean-toolchain` (currently `leanprover/lean4:v4.31.0-rc1`).

## 2. First build

```bash
# from repo root:
lake update              # resolve Mathlib4 dependency; writes lake-manifest.json
lake exe cache get       # download Mathlib's pre-compiled cache (≈10 min, saves 10–30 min build)
lake build               # compile our L0 stubs (≈1–2 min once Mathlib cache is in place)
```

`lake exe cache get` is essential — without it, `lake build` will compile
Mathlib from scratch (30+ minutes). The cache is published by the Mathlib team
for every commit, so almost always works on the first try.

## 3. What should build

After `lake build`, you should see:

- 0 compilation errors
- ~5 `sorry` warnings:
  - 1 in `ComputableAnalysis/L0/Bridge.lean` — `cantorPair_computable`
  - 4 in `ComputableAnalysis/L0/PropB.lean` — `insepA_re`, `insepB_re`,
    `insepA_insepB_disjoint`, `insepA_insepB_no_separator`
- 0 sorries in `AnalysisBridge.lean` (it's pure `#check` and `example` pointers)

If you see *unexpected* errors (especially "unknown identifier" or "unknown
import"), Mathlib's API may have changed since the identifier-verification work
in June 2026. The likely culprits:

- `REPred` / `ComputablePred` — check `Mathlib.Computability.RE` is still at
  that path
- `ComputablePred.halting_problem_re` / `halting_problem` — check
  `Mathlib.Computability.Halting` namespace
- `Lp` import path — check `Mathlib.MeasureTheory.Function.LpSpace.Basic`
- `lp` import path — check `Mathlib.Analysis.Normed.Lp.lpSpace`

When in doubt, search the symbol on
[Mathlib4 docs](https://leanprover-community.github.io/mathlib4_docs/).

## 4. Per-session workflow

For day-to-day work:

```bash
# from repo root:

# full build (after `lake exe cache get`):
lake build

# single-file check (much faster):
lake env lean ComputableAnalysis/L0/Bridge.lean

# interactive (with VS Code):
code .
```

VS Code with the Lean 4 extension gives the infoview (proof state at cursor) —
the standard Lean development experience.

## 5. Pinning Mathlib

`lake update` writes `lake-manifest.json` pinning Mathlib to whatever commit is
current. To bump:

```bash
lake update mathlib       # re-pin to latest Mathlib master
lake exe cache get        # refresh cache for the new commit
lake build                # rebuild
```

If `lake update` complains the lean-toolchain pin doesn't match Mathlib's
requirement, edit `lean-toolchain` to match Mathlib's value (visible at
the top of any error message), then `elan toolchain install <version>` and
retry.

## Troubleshooting

**"lean: command not found"** — elan is installed but `~/.elan/bin` isn't on
PATH. Add it to `~/.zshrc` / `~/.bashrc`:

```bash
export PATH="$HOME/.elan/bin:$PATH"
```

**"could not find toolchain v4.X.Y"** — elan didn't auto-fetch. Run
`elan toolchain install leanprover/lean4:v4.31.0-rc1`.

**"unknown package 'mathlib'"** — `lake update` hasn't been run, or it failed.
Re-run; check internet connectivity.

**Mathlib build takes forever** — you didn't run `lake exe cache get`. Cancel
the build, run the cache-get step, then retry.
