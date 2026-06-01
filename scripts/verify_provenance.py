#!/usr/bin/env python3
"""
Verify provenance integrity across proofs/ and literature/.

Checks:
  - Each proofs/<topic>/<claim-id>/*.md references a real claim at claims/<topic>/*.md
    whose frontmatter `id` matches <claim-id> (the directory name).
  - Every literature/papers/<key>/ directory has meta.json and verbatim.md.
  - Every <bibkey> mentioned in claims `sources:` resolves to literature/papers/<bibkey>/.

Exit 0 clean, 1 violations.
"""
import json
import re
import sys
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]
CLAIMS = REPO / "claims"
PROOFS = REPO / "proofs"
LIT = REPO / "literature" / "papers"


def parse_frontmatter(text):
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n?", text, re.DOTALL)
    if not m:
        return None
    fm = {}
    cur = None
    for line in m.group(1).splitlines():
        if not line.strip():
            continue
        if re.match(r"^\s+-\s+", line):
            if cur is not None:
                cur.append(re.sub(r"^\s+-\s+", "", line).strip().strip("\"'"))
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
            body = val.strip("[]").strip()
            fm[key] = [x.strip().strip("\"'") for x in body.split(",") if x.strip()]
            cur = None
        else:
            fm[key] = val.strip("\"'")
            cur = None
    return fm


def main():
    violations = []

    # 1. Build claim-id map.
    claim_ids = {}
    if CLAIMS.is_dir():
        for f in CLAIMS.rglob("*.md"):
            if f.name == "TEMPLATE.md":
                continue
            fm = parse_frontmatter(f.read_text())
            if fm and fm.get("id"):
                claim_ids[fm["id"]] = f.relative_to(REPO)

    # 2. Check proofs reference real claim ids.
    if PROOFS.is_dir():
        for d in PROOFS.iterdir():
            if not d.is_dir():
                continue
            for cd in d.iterdir():
                if not cd.is_dir():
                    continue
                cid = cd.name
                if cid not in claim_ids:
                    violations.append(
                        f"proofs/{d.name}/{cid}/: directory name does not match any "
                        f"claim id (known ids: {sorted(claim_ids)})"
                    )

    # 3. Literature integrity.
    bibkeys = set()
    if LIT.is_dir():
        for d in LIT.iterdir():
            if not d.is_dir():
                continue
            bibkeys.add(d.name)
            meta = d / "meta.json"
            verb = d / "verbatim.md"
            if not meta.exists():
                violations.append(f"literature/papers/{d.name}/: missing meta.json")
            else:
                try:
                    json.loads(meta.read_text())
                except Exception as e:
                    violations.append(f"literature/papers/{d.name}/meta.json: invalid JSON ({e})")
            if not verb.exists():
                violations.append(f"literature/papers/{d.name}/: missing verbatim.md")

    # 4. Claim sources resolve to literature/papers/<key>/ OR literature/papers/<key>.md.
    #
    # The project has an "intentional deviation accepted by the user" (CLAUDE.md):
    # for the P-R textbook, chapters are extracted as flat per-chapter files
    # `literature/papers/<key>.md` rather than the canonical
    # `literature/papers/<key>/verbatim.md` directory structure. This resolution
    # routine accepts both layouts so that the flat-file convention does not cause
    # /verify failures.
    def _source_resolves(key: str) -> bool:
        if not key:
            return False
        # (a) canonical bibkey directory layout
        if key in bibkeys:
            return True
        # (b) full path: literature/papers/<file>.md flat-file (accepted deviation)
        if key.startswith("literature/papers/"):
            p = REPO / key
            if p.exists():
                return True
            # also accept literature/papers/<bibkey>/<sub-path> patterns
            first_seg = key[len("literature/papers/"):].split("/")[0]
            if first_seg in bibkeys:
                return True
        return False

    if CLAIMS.is_dir():
        for f in CLAIMS.rglob("*.md"):
            if f.name == "TEMPLATE.md":
                continue
            fm = parse_frontmatter(f.read_text())
            if not fm:
                continue
            srcs = fm.get("sources") or []
            if isinstance(srcs, str):
                continue
            for s in srcs:
                key = s.split(":")[0].strip()
                if not _source_resolves(key):
                    violations.append(
                        f"{f.relative_to(REPO)}: source '{s}' -> "
                        f"could not resolve to literature/papers/{key}/ "
                        f"(bibkey dir) or literature/papers/{key} (flat file)"
                    )

    # 5. PDF-tiebreaker discipline in extraction-consensus.md (per CLAUDE.md rule 2).
    #    For every per-page row marked `disagree-resolved-via-PDF`, the
    #    corresponding `### Page <N> — verdict: ...` sub-section must contain a
    #    `PDF` reference (reads / glyph / shows / confirms / prints / italicizes /
    #    "PDF page N ...").  This catches the iter-02 anti-pattern of resolving a
    #    disagreement via pure logical inference (e.g., "the discrete system maps
    #    $\mathbb{Z}^n \to \mathbb{Z}^n$, so the extension is $\mathbb{R}^n \to
    #    \mathbb{R}^n$") with no visual PDF check.
    if LIT.is_dir():
        for d in LIT.iterdir():
            if not d.is_dir():
                continue
            ec = d / "extraction-consensus.md"
            if not ec.exists():
                continue
            ec_text = ec.read_text()
            disputed_pages = set()
            for line in ec_text.splitlines():
                if not line.lstrip().startswith("|"):
                    continue
                cells = [c.strip() for c in line.split("|")]
                # cells layout: ['', '<page>', '<verdict>', '<edits>', '']
                if len(cells) < 4:
                    continue
                page_cell = cells[1]
                verdict_cell = cells[2]
                if "disagree-resolved-via-PDF" not in verdict_cell:
                    continue
                m = re.match(r"(\d+)$", page_cell)
                if m:
                    disputed_pages.add(int(m.group(1)))
            missing = []
            for p in sorted(disputed_pages):
                # Find the per-page sub-section ("### Page N — ...") body.
                section_re = re.compile(
                    rf"^###\s+Page\s+{p}\s*[—–\-—]+.*?(?=^###\s|\Z)",
                    re.MULTILINE | re.DOTALL,
                )
                m = section_re.search(ec_text)
                if m:
                    body = m.group(0)
                    # Body must contain a PDF reference. Logical inference (e.g.,
                    # "because the discrete system has codomain ℤ^n the extension
                    # must be ℝ^n") is forbidden.
                    if not re.search(r"\bPDF\b", body):
                        missing.append(p)
                else:
                    # No matching sub-section found at all; require explicit
                    # "PDF page N" reference in the file as fallback.
                    if not re.search(rf"\bPDF\s+page\s+{p}\b", ec_text):
                        missing.append(p)
            if missing:
                violations.append(
                    f"literature/papers/{d.name}/extraction-consensus.md: "
                    f"page(s) {missing} marked `disagree-resolved-via-PDF` but the "
                    f"corresponding `### Page N — verdict: ...` sub-section contains "
                    f"no `PDF` reference. Per CLAUDE.md rule 2, PDF-tiebreaker "
                    f"verdicts must quote the printed glyph (reads / shows / "
                    f"confirms / prints / italicizes); logical inference is not a "
                    f"tiebreaker. Add a visual reference for each disputed page."
                )

    if violations:
        print("PROVENANCE VIOLATIONS:")
        for v in violations:
            print(f"  - {v}")
        return 1
    print(
        f"OK: {len(claim_ids)} claim(s), {len(bibkeys)} paper(s); "
        f"all proof dirs and source pointers resolve."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
