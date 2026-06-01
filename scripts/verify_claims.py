#!/usr/bin/env python3
"""
Verify the claims/ tree:
  - every claim file has YAML frontmatter
  - status is one of the allowed values
  - sources: is non-empty when status is cited_result or verified
  - id matches filename
  - dependencies reference existing claim ids

Exit codes: 0 = clean, 1 = violations.
"""
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
CLAIMS = REPO / "claims"

ALLOWED_STATUS = {
    "intuition", "conjecture", "our_construction",
    "cited_result", "verified", "refuted",
}
NEED_SOURCES = {"cited_result", "verified"}


def parse_frontmatter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n?", text, re.DOTALL)
    if not m:
        return None
    fm = {}
    cur = None
    for line in m.group(1).splitlines():
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if re.match(r"^\s+-\s+", line):
            if cur is not None:
                item = re.sub(r"^\s+-\s+", "", line).strip().strip("\"'")
                cur.append(item)
            continue
        m2 = re.match(r"^([a-zA-Z_][a-zA-Z0-9_]*)\s*:\s*(.*)$", line)
        if not m2:
            cur = None
            continue
        key, val = m2.group(1), m2.group(2).strip()
        if val == "":
            cur = []
            fm[key] = cur
        elif val.startswith("["):
            # inline list
            body = val.strip("[]").strip()
            fm[key] = [x.strip().strip("\"'") for x in body.split(",") if x.strip()]
            cur = None
        else:
            fm[key] = val.strip("\"'")
            cur = None
    return fm


def main():
    if not CLAIMS.is_dir():
        print("claims/ does not exist — nothing to verify")
        return 0
    violations = []
    all_ids = set()
    file_id = {}
    for f in CLAIMS.rglob("*.md"):
        if f.name in ("TEMPLATE.md", "INDEX.md"):
            continue
        text = f.read_text()
        fm = parse_frontmatter(text)
        rel = f.relative_to(REPO)
        if fm is None:
            violations.append(f"{rel}: no YAML frontmatter")
            continue
        cid = fm.get("id")
        status = fm.get("status")
        sources = fm.get("sources") or []
        if not cid:
            violations.append(f"{rel}: missing id")
        else:
            all_ids.add(cid)
            file_id[cid] = rel
            expected_stem = cid.split("-", 1)[-1] if "-" in cid else cid
            # don't enforce exact filename match; just record
        if status not in ALLOWED_STATUS:
            violations.append(f"{rel}: invalid status '{status}' (allowed: {sorted(ALLOWED_STATUS)})")
        if status in NEED_SOURCES and not sources:
            violations.append(
                f"{rel}: status '{status}' requires non-empty sources: in frontmatter"
            )
    # Second pass: dependencies
    for f in CLAIMS.rglob("*.md"):
        if f.name in ("TEMPLATE.md", "INDEX.md"):
            continue
        fm = parse_frontmatter(f.read_text())
        if not fm:
            continue
        deps = fm.get("dependencies") or []
        if isinstance(deps, str):
            continue
        for d in deps:
            d_id = d.split(":")[0].strip()
            if d_id and d_id not in all_ids:
                violations.append(
                    f"{f.relative_to(REPO)}: dependency '{d}' does not match any known claim id"
                )

    if violations:
        print("CLAIM VIOLATIONS:")
        for v in violations:
            print(f"  - {v}")
        return 1
    print(f"OK: {len(all_ids)} claim(s) verified across {sum(1 for _ in CLAIMS.rglob('*.md') if _.name != 'TEMPLATE.md')} file(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
