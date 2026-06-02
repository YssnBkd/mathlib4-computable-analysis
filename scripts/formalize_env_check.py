#!/usr/bin/env python3
"""
Pre-flight environment check for the /formalize skill.

Runs at the start of every /formalize invocation. Verifies that the Lean 4
toolchain, Lake, and the Mathlib dependency are healthy enough that the agent
can read goal states, type-check files, and reach Mathlib symbols.

A SHA256 watermark over `{lean-toolchain, lake-manifest.json, lakefile.toml}`
at the repo root lets us *skip* the slow build path when nothing relevant has
changed since the last green check. The watermark file `.formalize-env-ok`
records that hash plus the timestamp of the last successful smoke test.

Stdlib only — same discipline as `scripts/goal_stop_hook.py`. Never depends on
the project venv being healthy.

Exit codes
----------
0   OK — fast path (watermark matched) or cold build completed and smoke-tested
1   No Lean toolchain found (elan/lake/lean absent on PATH)
2   `lake build` failed (Mathlib or our code did not compile)
3   Smoke test failed (`lake env lean Tests/_smoke.lean` did not exit 0)
4   Needs init — `lakefile.toml` missing; re-run with --init
5   Init requested but `lakefile.toml` already exists (refusing to clobber)
6   Init: wrote scaffold; user must run `lake update` then re-invoke without --init

Flags
-----
--init             Scaffold `{lakefile.toml, lean-toolchain,
                   ComputableAnalysis.lean}` at git root. Refuses to overwrite.
--force            Ignore watermark; always rebuild.
--quiet            Suppress diagnostic prose; print only the final status line.
--json             Print the final status as a single JSON line.
--toolchain TC     Override the default toolchain for --init
                   (default: `leanprover/lean4:v4.16.0`).
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import time
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd())).resolve()
# FORMAL was REPO/"formal" before the 2026-06-02 hoist to git root. Kept as
# FORMAL to minimize refactor churn — semantically this is the Lake project root.
FORMAL = REPO
WATERMARK = FORMAL / ".formalize-env-ok"
SMOKE_DIR = FORMAL / "Tests"
SMOKE_FILE = SMOKE_DIR / "_smoke.lean"
DEFAULT_TOOLCHAIN = "leanprover/lean4:v4.16.0"

INSTALL_HINT = (
    "Install elan (the Lean toolchain manager):\n"
    "    curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh \\\n"
    "        | sh -s -- -y --default-toolchain none\n"
    "Then add `~/.elan/bin` to your PATH and re-run this script.\n"
    "On macOS via Homebrew: `brew install elan-init`.\n"
)


def log(msg: str, quiet: bool = False) -> None:
    if not quiet:
        print(msg, file=sys.stderr)


def emit_status(status: str, detail: dict, *, json_mode: bool) -> None:
    """Print the final status. status is the canonical tag (e.g., `OK_fast`)."""
    if json_mode:
        print(json.dumps({"status": status, **detail}))
    else:
        # plain final line; agents parse the prefix `formalize_env:`
        suffix = ""
        if detail:
            kv = " ".join(f"{k}={v}" for k, v in detail.items() if v is not None)
            suffix = " " + kv
        print(f"formalize_env: {status}{suffix}")


def which(cmd: str) -> str | None:
    p = shutil.which(cmd)
    if p:
        return p
    # Also check ~/.elan/bin since fresh elan installs do not propagate PATH
    # to the parent shell until `source` runs.
    elan_bin = Path.home() / ".elan" / "bin" / cmd
    if elan_bin.is_file() and os.access(elan_bin, os.X_OK):
        return str(elan_bin)
    return None


def hash_inputs() -> str | None:
    """SHA256 over the three files that pin the build environment.

    Returns None if any file is missing — caller should treat as 'needs init'.
    """
    h = hashlib.sha256()
    for rel in ("lean-toolchain", "lakefile.toml", "lake-manifest.json"):
        p = FORMAL / rel
        if not p.exists():
            return None
        h.update(rel.encode("utf-8"))
        h.update(b"\x00")
        h.update(p.read_bytes())
        h.update(b"\x00")
    return h.hexdigest()


def write_watermark(hash_hex: str, last_action: str) -> None:
    payload = {
        "hash": hash_hex,
        "last_action": last_action,
        "validated_at": datetime.now(timezone.utc).isoformat(),
    }
    WATERMARK.write_text(json.dumps(payload, indent=2) + "\n")


def read_watermark() -> dict | None:
    if not WATERMARK.exists():
        return None
    try:
        return json.loads(WATERMARK.read_text())
    except Exception:
        return None


def ensure_smoke_file() -> None:
    SMOKE_DIR.mkdir(parents=True, exist_ok=True)
    if not SMOKE_FILE.exists():
        SMOKE_FILE.write_text(
            "-- formalize env smoke test. Tiny; reaches Mathlib through `import`.\n"
            "import Mathlib.Data.Nat.Basic\n"
            "open Nat in\n"
            "example : 1 + 1 = 2 := by decide\n"
            "#check (Nat.add_comm : ∀ a b : Nat, a + b = b + a)\n"
        )


def run(cmd: list[str], cwd: Path, *, timeout: int, quiet: bool) -> subprocess.CompletedProcess:
    log(f"  $ ({cwd}) {' '.join(cmd)}", quiet)
    return subprocess.run(
        cmd,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        timeout=timeout,
        check=False,
    )


def run_smoke(lake: str, *, quiet: bool) -> tuple[bool, str]:
    """Returns (passed, diagnostic). Diagnostic is the tail of stderr on failure."""
    ensure_smoke_file()
    try:
        r = run([lake, "env", "lean", str(SMOKE_FILE.relative_to(FORMAL))],
                cwd=FORMAL, timeout=120, quiet=quiet)
    except subprocess.TimeoutExpired:
        return False, "smoke test timed out after 120s"
    if r.returncode != 0:
        tail = (r.stderr or r.stdout or "").splitlines()[-20:]
        return False, "\n".join(tail)
    return True, ""


def cmd_init(args: argparse.Namespace) -> int:
    quiet = args.quiet
    if (FORMAL / "lakefile.toml").exists():
        log("lakefile.toml already exists. Refusing to overwrite.", quiet)
        log("Remove it or move it aside if you really want to re-init.", quiet)
        emit_status("INIT_REFUSED", {"reason": "lakefile_exists"}, json_mode=args.json)
        return 5

    FORMAL.mkdir(parents=True, exist_ok=True)
    toolchain = args.toolchain or DEFAULT_TOOLCHAIN

    lakefile = (
        f'# Lake project for the computable-analysis-in-Mathlib project.\n'
        f'# Pinned commit lives in lake-manifest.json (regenerated by `lake update`).\n'
        f'name = "ComputableAnalysis"\n'
        f'defaultTargets = ["ComputableAnalysis"]\n'
        f'\n'
        f'[leanOptions]\n'
        f'pp.unicode.fun = true\n'
        f'autoImplicit = false\n'
        f'\n'
        f'[[require]]\n'
        f'name = "mathlib"\n'
        f'scope = "leanprover-community"\n'
        f'# version field intentionally omitted — pinned via lake-manifest.json\n'
        f'\n'
        f'[[lean_lib]]\n'
        f'name = "ComputableAnalysis"\n'
        f'srcDir = "."\n'
        f'roots = ["ComputableAnalysis"]\n'
    )
    (FORMAL / "lakefile.toml").write_text(lakefile)

    (FORMAL / "lean-toolchain").write_text(toolchain + "\n")

    umbrella = (
        '/-\n'
        'Copyright (c) 2026 the mathlib-computable-analysis contributors.\n'
        'Released under Apache 2.0. License at the project root.\n'
        '-/\n'
        '\n'
        '-- Umbrella import. Each /formalize iteration appends one `import` line\n'
        '-- below as a new layer file lands. Keep ordered L0 → L5.\n'
        '\n'
        '-- import ComputableAnalysis.L0.Bridge\n'
        '-- import ComputableAnalysis.L0.PropB\n'
        '-- import ComputableAnalysis.L1.ComputableSeqReal\n'
        '-- import ComputableAnalysis.L1.ComputableSeqComplex\n'
        '-- import ComputableAnalysis.L1.ComputableReal\n'
        '-- import ComputableAnalysis.L2.GrzegorczykLacombe\n'
        '-- import ComputableAnalysis.L3.ComputabilityStructure\n'
        '-- import ComputableAnalysis.L4.Instances.CMap\n'
        '-- import ComputableAnalysis.L4.Instances.Lp\n'
        '-- import ComputableAnalysis.L4.Instances.Hilbert\n'
        '-- import ComputableAnalysis.L5.FirstMainTheorem\n'
        '-- import ComputableAnalysis.L5.SecondMainTheorem\n'
        '-- import ComputableAnalysis.L5.Eigenvector\n'
    )
    (FORMAL / "ComputableAnalysis.lean").write_text(umbrella)

    ensure_smoke_file()

    log("Scaffolded:", quiet)
    log("  lakefile.toml", quiet)
    log(f"  lean-toolchain     ({toolchain})", quiet)
    log("  ComputableAnalysis.lean  (umbrella, empty imports)", quiet)
    log("  Tests/_smoke.lean        (kernel reach test)", quiet)
    log("", quiet)
    log("Next steps (one-time, takes several minutes the first time):", quiet)
    log("  lake update          # fetches Mathlib, pins lake-manifest.json", quiet)
    log("  lake exe cache get   # downloads Mathlib oleans from CI cache", quiet)
    log("  lake build           # compiles the umbrella + smoke", quiet)
    log("Then re-invoke `scripts/formalize_env_check.py` (no --init) to lock in the watermark.", quiet)
    emit_status("INIT_DONE", {"toolchain": toolchain}, json_mode=args.json)
    return 6


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--init", action="store_true", help="scaffold Lake project at repo root")
    parser.add_argument("--force", action="store_true", help="ignore watermark; always rebuild")
    parser.add_argument("--quiet", action="store_true", help="suppress diagnostic prose")
    parser.add_argument("--json", action="store_true", help="emit final status as JSON")
    parser.add_argument("--toolchain", default=DEFAULT_TOOLCHAIN, help="toolchain for --init")
    args = parser.parse_args(argv)

    quiet = args.quiet

    if args.init:
        return cmd_init(args)

    # ---- 0. toolchain present? ----
    elan = which("elan")
    lake = which("lake")
    lean = which("lean")

    if not elan and not lake and not lean:
        log("No Lean toolchain on PATH (elan, lake, lean all missing).", quiet)
        log("", quiet)
        log(INSTALL_HINT, quiet)
        emit_status("NO_LEAN", {"hint": "install_elan"}, json_mode=args.json)
        return 1

    if not lake:
        log("`lake` not on PATH but elan/lean may be present.", quiet)
        log("Run `elan default stable` or ensure `~/.elan/bin` is on PATH.", quiet)
        emit_status("NO_LAKE", {}, json_mode=args.json)
        return 1

    # ---- 1. lakefile present? ----
    if not (FORMAL / "lakefile.toml").exists():
        log("lakefile.toml missing — the Lake project is not initialized.", quiet)
        log("Run `python3 scripts/formalize_env_check.py --init` to scaffold.", quiet)
        emit_status("NEEDS_INIT", {"reason": "no_lakefile"}, json_mode=args.json)
        return 4

    if not (FORMAL / "lean-toolchain").exists():
        log("lean-toolchain missing — cannot determine Lean version.", quiet)
        emit_status("NEEDS_INIT", {"reason": "no_toolchain"}, json_mode=args.json)
        return 4

    if not (FORMAL / "lake-manifest.json").exists():
        log("lake-manifest.json missing — `lake update` has not been run.", quiet)
        log("Run: `lake update && lake exe cache get && lake build`.", quiet)
        log("This downloads and builds Mathlib (~10–30 min the first time).", quiet)
        emit_status("NEEDS_INIT", {"reason": "no_manifest", "next": "lake_update"}, json_mode=args.json)
        return 4

    # ---- 2. watermark check ----
    cur_hash = hash_inputs()
    wm = read_watermark()
    fast_path = (
        not args.force
        and cur_hash is not None
        and wm is not None
        and wm.get("hash") == cur_hash
    )

    if fast_path:
        log("Watermark matches — fast path.", quiet)
        ok, diag = run_smoke(lake, quiet=quiet)
        if not ok:
            log("Smoke test FAILED despite matching watermark.", quiet)
            log(diag, quiet)
            log("The watermark is stale (oleans likely missing). Forcing rebuild.", quiet)
            # fall through to slow path
            fast_path = False
        else:
            write_watermark(cur_hash, "fast_path_smoke_ok")
            emit_status("OK_fast", {"hash": cur_hash[:12]}, json_mode=args.json)
            return 0

    # ---- 3. slow path: cache, build, smoke ----
    log("Slow path: cache get → build → smoke.", quiet)

    log("Step 1/3: lake exe cache get (downloads Mathlib oleans)…", quiet)
    try:
        r = run([lake, "exe", "cache", "get"], cwd=FORMAL, timeout=900, quiet=quiet)
    except subprocess.TimeoutExpired:
        log("lake exe cache get TIMED OUT after 15min. Network or cache server issue.", quiet)
        emit_status("BUILD_FAIL", {"stage": "cache_get", "reason": "timeout"}, json_mode=args.json)
        return 2
    if r.returncode != 0:
        # Some projects don't ship a `cache` exe; fall through but log.
        log("  (cache get exited non-zero; continuing — lake build will compile from source)", quiet)
        tail = (r.stderr or r.stdout or "").splitlines()[-5:]
        for ln in tail:
            log(f"    | {ln}", quiet)

    log("Step 2/3: lake build (compiles the umbrella + any layer files)…", quiet)
    t0 = time.monotonic()
    try:
        r = run([lake, "build"], cwd=FORMAL, timeout=3600, quiet=quiet)
    except subprocess.TimeoutExpired:
        log("lake build TIMED OUT after 60min. Likely first-time Mathlib compile.", quiet)
        emit_status("BUILD_FAIL", {"stage": "lake_build", "reason": "timeout"}, json_mode=args.json)
        return 2
    elapsed = time.monotonic() - t0
    if r.returncode != 0:
        log(f"lake build FAILED after {elapsed:.0f}s.", quiet)
        tail = (r.stderr or r.stdout or "").splitlines()[-30:]
        for ln in tail:
            log(f"  | {ln}", quiet)
        emit_status("BUILD_FAIL", {"stage": "lake_build", "elapsed_s": int(elapsed)}, json_mode=args.json)
        return 2
    log(f"  build OK in {elapsed:.0f}s", quiet)

    log("Step 3/3: smoke test…", quiet)
    ok, diag = run_smoke(lake, quiet=quiet)
    if not ok:
        log("Smoke test FAILED after a clean build:", quiet)
        log(diag, quiet)
        emit_status("SMOKE_FAIL", {}, json_mode=args.json)
        return 3

    # success → refresh watermark (hash inputs may have changed during the build,
    # specifically lake-manifest.json gets updated by `lake update`)
    cur_hash = hash_inputs()
    if cur_hash:
        write_watermark(cur_hash, "cold_build")
    emit_status("OK_cold", {"hash": (cur_hash or "")[:12], "elapsed_s": int(elapsed)}, json_mode=args.json)
    return 0


if __name__ == "__main__":
    sys.exit(main())
