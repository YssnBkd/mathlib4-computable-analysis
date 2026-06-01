#!/usr/bin/env python3
"""
UserPromptSubmit hook: prepend a compact goal-context header to the prompt
whenever current-goal.md has an active goal. Helps keep Claude oriented across
turns without bloating context.

Hook protocol:
  - stdin: JSON event ({prompt, session_id, ...})
  - stdout: arbitrary text is added as additional context to the prompt.
  - exit 0: success.
"""
import json
import os
import re
import sys
from pathlib import Path

REPO = Path(os.environ.get("CLAUDE_PROJECT_DIR", os.getcwd()))


def parse_frontmatter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n?", text, re.DOTALL)
    if not m:
        return {}
    fm = {}
    for line in m.group(1).splitlines():
        m2 = re.match(r"^([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*(.+?)\s*(?:#.*)?$", line)
        if m2:
            v = m2.group(2).strip().strip("\"'")
            fm[m2.group(1)] = v
    return fm


def main():
    # Drain stdin so the parent doesn't block.
    try:
        sys.stdin.read()
    except Exception:
        pass

    goal_file = REPO / "current-goal.md"
    if not goal_file.exists():
        return
    text = goal_file.read_text()
    if "---" not in text:
        return
    fm = parse_frontmatter(text)
    slug = fm.get("slug")
    if not slug or slug == "<kebab-case>":
        return

    mode = fm.get("mode", "explore")
    max_iters = fm.get("max_iterations", "?")

    criteria = []
    in_section = False
    for line in text.splitlines():
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
                "text": m.group(3).strip()[:90],
            })
    unmet = [c for c in criteria if not c["checked"]]
    if not unmet:
        return

    goal_dir = REPO / ".goals" / slug
    iters = list(goal_dir.glob("iter-*.md")) if goal_dir.is_dir() else []
    n = len(iters)

    lines = ["[/goal context]"]
    lines.append(f"  active: {slug} (mode={mode}, iter {n}/{max_iters})")
    lines.append("  unmet criteria:")
    for c in unmet[:6]:
        lines.append(f"    - {c['id']}: {c['text']}")
    if len(unmet) > 6:
        lines.append(f"    ... and {len(unmet)-6} more")
    lines.append("  if context unclear, read BOOTSTRAP.md")
    sys.stdout.write("\n".join(lines) + "\n")


if __name__ == "__main__":
    main()
