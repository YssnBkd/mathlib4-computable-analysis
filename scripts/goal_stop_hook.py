#!/usr/bin/env python3
"""
Stop hook for /goal autonomous research iteration.

Reads $CLAUDE_PROJECT_DIR/current-goal.md. If non-empty and the goal is not
satisfied, emits {"decision":"block","reason":"..."} to inject a continuation
prompt and keep Claude iterating. Halts (exit 0, no block) on success,
stagnation, budget exhaustion, forbidden write, or unauthorized check-mark.

Stdlib only — never depends on the project venv being healthy.

Hook protocol reference:
  - stdin: JSON event ({session_id, transcript_path, hook_event_name, stop_hook_active})
  - stdout JSON {"decision":"block","reason": <text>} blocks the stop and feeds
    <text> back to Claude as a new prompt.
  - exit 0 with no stdout: allows the stop normally.
"""
import json
import os
import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path
from fnmatch import fnmatch

REPO = Path(os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd()))


def read_event():
    try:
        return json.loads(sys.stdin.read() or "{}")
    except Exception:
        return {}


def parse_frontmatter(text):
    """Tiny YAML-ish parser for our schema. Returns (frontmatter dict, body)."""
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n?(.*)$", text, re.DOTALL)
    if not m:
        return {}, text
    fm_block, body = m.group(1), m.group(2)
    fm = {}
    current_list = None
    for raw in fm_block.splitlines():
        line = raw.rstrip()
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if re.match(r"^\s+-\s+", line):
            if current_list is not None:
                item = re.sub(r"^\s+-\s+", "", line)
                item = re.sub(r"\s+#.*$", "", item).strip().strip("\"'")
                current_list.append(item)
            continue
        m2 = re.match(r"^([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*(.*)$", line)
        if not m2:
            current_list = None
            continue
        key, val = m2.group(1), m2.group(2).strip()
        if val == "" or val.startswith("#"):
            current_list = []
            fm[key] = current_list
        else:
            val = re.sub(r"\s+#.*$", "", val).strip().strip("\"'")
            try:
                fm[key] = int(val)
            except ValueError:
                try:
                    fm[key] = float(val)
                except ValueError:
                    fm[key] = val
            current_list = None
    return fm, body


def parse_criteria(body):
    """Parse '- [ ] C1: ...' lines under '## Success criteria'."""
    criteria = []
    in_section = False
    for line in body.splitlines():
        if line.startswith("## "):
            in_section = line.startswith("## Success criteria")
            continue
        if not in_section:
            continue
        m = re.match(r"^- \[( |x|X)\]\s+([A-Z]\d+):\s*(.*)$", line)
        if m:
            criteria.append({
                "id": m.group(2),
                "checked": m.group(1).lower() == "x",
                "text": m.group(3).strip(),
            })
    return criteria


def glob_match(path, patterns):
    """Return first matching pattern, or None."""
    for raw in patterns:
        pat = re.sub(r"\s+\(.*\)$", "", raw).strip()
        if not pat:
            continue
        if fnmatch(path, pat):
            return pat
        # also try '**' semantics: 'foo/**' should match 'foo/anything/...'
        if pat.endswith("/**"):
            prefix = pat[:-3]
            if path.startswith(prefix):
                return pat
    return None


def git_files_changed():
    try:
        # --untracked-files=all expands new directories to individual files,
        # so forbid/allow glob patterns can match specific paths.
        r = subprocess.run(
            ["git", "-C", str(REPO), "status", "--porcelain", "--untracked-files=all"],
            capture_output=True, text=True, check=False, timeout=10,
        )
        paths = []
        for line in r.stdout.splitlines():
            if len(line) < 3:
                continue
            path = line[3:]
            if " -> " in path:
                path = path.split(" -> ", 1)[-1]
            paths.append(path.strip().strip("\""))
        return paths
    except Exception:
        return []


def emit_block(reason):
    print(json.dumps({"decision": "block", "reason": reason}))
    sys.exit(0)


def emit_allow():
    sys.exit(0)


def state_from_iter(it_path):
    """Extract (unmet, progress, files_changed, has_revert) from an iter file.

    Used by the stagnation detector so that within-criterion progress (different
    progress: lines, different files_changed sets, or an explicit revert:) does
    not trigger HALT just because the unmet-set is unchanged.
    """
    try:
        t = it_path.read_text()
        unmet = None
        m = re.search(r"unmet:\s*\[(.*?)\]", t)
        if m:
            unmet = tuple(sorted(
                x.strip().strip("'\"")
                for x in m.group(1).split(",")
                if x.strip()
            ))
        progress = None
        m = re.search(r"^progress:\s*(.+)$", t, re.MULTILINE)
        if m:
            progress = m.group(1).strip()
        files = None
        m = re.search(r"^files_changed:\s*(.+?)$", t, re.MULTILINE)
        if m:
            files = m.group(1).strip()
        has_revert = bool(re.search(r"^revert:\s*", t, re.MULTILINE))
        return (unmet, progress, files, has_revert)
    except Exception:
        return (None, None, None, False)


def unmet_from_iter(it_path):
    """Back-compat shim returning only the unmet tuple."""
    return state_from_iter(it_path)[0]


def main():
    _event = read_event()  # currently unused; reserved for stop_hook_active inspection
    goal_file = REPO / "current-goal.md"
    if not goal_file.exists():
        emit_allow()
    text = goal_file.read_text()
    if not text.strip() or "---" not in text:
        emit_allow()

    fm, body = parse_frontmatter(text)
    slug = fm.get("slug")
    if not slug or slug == "<kebab-case>" or not isinstance(slug, str):
        emit_allow()

    mode = str(fm.get("mode", "explore"))
    try:
        max_iters = int(fm.get("max_iterations", 12))
    except (TypeError, ValueError):
        max_iters = 12
    try:
        time_budget = int(fm.get("time_budget_minutes", 90))
    except (TypeError, ValueError):
        time_budget = 90
    started = str(fm.get("started", "") or "")
    allow_writes = fm.get("allow_writes", []) or []
    forbid_writes = fm.get("forbid_writes", []) or []
    devils_req = fm.get("devils_advocate_required_for", []) or []
    if not isinstance(allow_writes, list):
        allow_writes = []
    if not isinstance(forbid_writes, list):
        forbid_writes = []
    if not isinstance(devils_req, list):
        devils_req = []

    goal_dir = REPO / ".goals" / slug
    goal_dir.mkdir(parents=True, exist_ok=True)
    reviews_dir = goal_dir / "reviews"
    reviews_dir.mkdir(exist_ok=True)

    iter_files = sorted(goal_dir.glob("iter-*.md"))
    n = len(iter_files)

    # ---- 1. forbidden-write check ----
    changed = git_files_changed()
    violations = [p for p in changed if glob_match(p, forbid_writes)]
    if violations:
        emit_block(
            f"HALT (forbidden write). Goal '{slug}' forbid_writes matched on: "
            f"{violations}. Revert these changes before continuing."
        )

    # ---- 2. allow_writes scope check ----
    if allow_writes:
        out_of_scope = []
        for p in changed:
            if glob_match(p, allow_writes):
                continue
            if p.startswith(f".goals/{slug}/") or p == "current-goal.md":
                continue
            out_of_scope.append(p)
        if out_of_scope:
            emit_block(
                f"HALT (out-of-scope write). Goal '{slug}' allow_writes does not cover: "
                f"{out_of_scope}. Either revert or extend allow_writes in current-goal.md."
            )

    # ---- 3. parse criteria; validate devil's-advocate reviews on [x] ones ----
    criteria = parse_criteria(body)
    if not criteria:
        emit_allow()

    bogus = []
    for c in criteria:
        if c["checked"] and c["id"] in devils_req:
            rev = reviews_dir / f"{c['id']}.md"
            if not rev.exists():
                bogus.append(c["id"])
                continue
            rt = rev.read_text()
            if not re.search(r"^verdict:\s*passes\s*$", rt, re.MULTILINE | re.IGNORECASE):
                bogus.append(c["id"])
    if bogus:
        emit_block(
            f"HALT (unauthorized check). Criteria {bogus} marked [x] without a passing "
            f"devil's-advocate review at .goals/{slug}/reviews/<id>.md. "
            f"Either invoke `/devils-advocate <id>` to produce a review with "
            f"`verdict: passes`, or revert the checkmark in current-goal.md."
        )

    unmet = [c["id"] for c in criteria if not c["checked"]]

    # ---- 4. success ----
    if not unmet:
        log = goal_dir / f"iter-{n+1:02d}.md"
        log.write_text(
            f"# iter-{n+1:02d} — SUCCESS\n\n"
            f"timestamp: {datetime.now(timezone.utc).isoformat()}\n"
            f"unmet: []\n"
            f"all criteria satisfied; awaiting `/goal-end`.\n"
        )
        emit_allow()

    # ---- 5. stagnation ----
    # Augmented per `tidy-percolating-barto.md` plan (2026-05-21):
    #   - Identical unmet-set alone is no longer enough to trigger HALT.
    #   - The detector also requires that `progress:` field be unchanged AND
    #     `files_changed:` line be unchanged across the last 3 iters. Different
    #     progress lines or different file edits are real within-criterion
    #     advancement.
    #   - If any of the last 3 iters has a `revert:` line (honest-accounting
    #     revert of a checkbox), the stagnation counter resets — the revert is a
    #     legitimate mid-flight move and must not subsequently cause HALT 3 iters
    #     later.
    if len(iter_files) >= 3:
        last3_state = [state_from_iter(p) for p in iter_files[-3:]]
        current_unmet = tuple(sorted(unmet))
        last3_unmet = [s[0] for s in last3_state]
        unmet_unchanged = (
            all(u == current_unmet for u in last3_unmet if u is not None)
            and len(set(last3_unmet)) <= 1
        )
        progress_unchanged = len({s[1] for s in last3_state}) <= 1
        files_unchanged = len({s[2] for s in last3_state}) <= 1
        any_revert = any(s[3] for s in last3_state)
        if unmet_unchanged and progress_unchanged and files_unchanged and not any_revert:
            emit_block(
                f"HALT (stagnation). Unmet criteria identical AND no `progress:` change "
                f"AND no `files_changed:` change for 3+ iterations: {list(current_unmet)}. "
                f"Break: pick a different angle, add a `progress:` line describing the "
                f"within-criterion advancement you intend, invoke `lit-scout` with a "
                f"different query, or run `/goal-end` to abandon."
            )

    # ---- 6. budget ----
    if n >= max_iters:
        emit_block(
            f"HALT (iteration budget exhausted). N={n} >= max_iterations={max_iters}. "
            f"Unmet: {unmet}. Run `/goal-end` to write a final summary."
        )
    if started:
        try:
            t0 = datetime.fromisoformat(started.replace("Z", "+00:00"))
            elapsed_min = (datetime.now(timezone.utc) - t0).total_seconds() / 60.0
            if elapsed_min >= time_budget:
                emit_block(
                    f"HALT (time budget exhausted). Elapsed {elapsed_min:.1f}min "
                    f">= {time_budget}min. Unmet: {unmet}. Run `/goal-end`."
                )
        except Exception:
            pass

    # ---- 7. write iteration log + inject continuation ----
    next_n = n + 1
    log = goal_dir / f"iter-{next_n:02d}.md"
    log.write_text(
        f"# iter-{next_n:02d}\n\n"
        f"timestamp: {datetime.now(timezone.utc).isoformat()}\n"
        f"unmet: [{', '.join(unmet)}]\n"
        f"mode: {mode}\n"
        f"progress: <fill in: one-line description of what changed this iter; the "
        f"stagnation detector reads this field>\n"
        f"files_changed: {changed}\n"
    )

    next_focus = unmet[0]
    focus_text = next((c["text"] for c in criteria if c["id"] == next_focus), "")
    da_note = (
        f" Before marking {next_focus} as [x], invoke `/devils-advocate {next_focus}`."
        if next_focus in devils_req else ""
    )
    reason = (
        f"Goal '{slug}' not satisfied (iter {next_n}/{max_iters}, mode={mode}). "
        f"Unmet: {unmet}. Focus on {next_focus}: {focus_text}.{da_note} "
        f"Stay within allow_writes; append a one-line note to "
        f".goals/{slug}/iter-{next_n:02d}.md when you commit a new artifact, "
        f"and update the `progress:` field there (e.g., "
        f"`progress: pages 19-24 diffed; 1 verbatim edit applied`)."
    )
    emit_block(reason)


if __name__ == "__main__":
    main()
