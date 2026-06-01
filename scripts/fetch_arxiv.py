#!/usr/bin/env python3
"""
Fetch an arXiv paper into raw_papers/<key>/ and seed literature/papers/<key>/.

Usage:
  scripts/fetch_arxiv.py <arxiv-id> <key>
Example:
  scripts/fetch_arxiv.py 2410.06209 leanagent2024

Creates:
  raw_papers/<key>/<arxiv-id>.pdf
  raw_papers/<key>/source.tar.gz       (canonical source bundle)
  raw_papers/<key>/source/             (extracted .tex tree)
  raw_papers/<key>/sha256              (checksums of pdf + source bundle)
  literature/papers/<key>/meta.json    (bibtex, arxiv id, sha256s)
  literature/papers/<key>/verbatim.md  (empty stub — extract statements here)
  literature/papers/<key>/notes.md     (empty stub — our annotations)
"""
import hashlib
import json
import shutil
import subprocess
import sys
import tarfile
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

REPO = Path(__file__).resolve().parents[1]


def sha256(p):
    h = hashlib.sha256()
    with open(p, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 16), b""):
            h.update(chunk)
    return h.hexdigest()


def fetch(url, dest):
    req = urllib.request.Request(url, headers={"User-Agent": "research-template/1.0"})
    with urllib.request.urlopen(req, timeout=60) as r, open(dest, "wb") as f:
        shutil.copyfileobj(r, f)


def main():
    if len(sys.argv) != 3:
        print("usage: fetch_arxiv.py <arxiv-id> <key>", file=sys.stderr)
        return 2
    arxiv_id, key = sys.argv[1], sys.argv[2]
    if not key.replace("-", "").replace("_", "").isalnum():
        print(f"key '{key}' should be alphanumeric / dashes / underscores", file=sys.stderr)
        return 2

    raw_dir = REPO / "raw_papers" / key
    lit_dir = REPO / "literature" / "papers" / key
    raw_dir.mkdir(parents=True, exist_ok=True)
    lit_dir.mkdir(parents=True, exist_ok=True)

    pdf_url = f"https://arxiv.org/pdf/{arxiv_id}"
    src_url = f"https://arxiv.org/e-print/{arxiv_id}"
    pdf_path = raw_dir / f"{arxiv_id}.pdf"
    src_path = raw_dir / "source.tar.gz"

    print(f"fetching {pdf_url} ...")
    fetch(pdf_url, pdf_path)
    print(f"fetching {src_url} ...")
    fetch(src_url, src_path)

    # Some arxiv e-prints are single .tex.gz, some are .tar.gz. Try tar first.
    src_dir = raw_dir / "source"
    src_dir.mkdir(exist_ok=True)
    try:
        with tarfile.open(src_path) as t:
            t.extractall(src_dir)
        extracted_kind = "tar"
    except tarfile.ReadError:
        # try single-file gzip
        import gzip
        with gzip.open(src_path, "rb") as g:
            (src_dir / "main.tex").write_bytes(g.read())
        extracted_kind = "gz"

    pdf_h = sha256(pdf_path)
    src_h = sha256(src_path)
    (raw_dir / "sha256").write_text(f"{pdf_h}  {pdf_path.name}\n{src_h}  {src_path.name}\n")

    meta = {
        "key": key,
        "arxiv_id": arxiv_id,
        "fetched_at": datetime.now(timezone.utc).isoformat(),
        "pdf": str(pdf_path.relative_to(REPO)),
        "source_bundle": str(src_path.relative_to(REPO)),
        "source_kind": extracted_kind,
        "sha256": {"pdf": pdf_h, "source": src_h},
    }
    (lit_dir / "meta.json").write_text(json.dumps(meta, indent=2) + "\n")

    if not (lit_dir / "verbatim.md").exists():
        (lit_dir / "verbatim.md").write_text(
            f"# {key} — verbatim extracts\n\n"
            f"arXiv: {arxiv_id}\n\n"
            "Extract verbatim `\\begin{{theorem}}...\\end{{theorem}}` etc. blocks here, "
            "with stable anchors like `<a id=\"thm-N\"></a>` so claims can cite them.\n"
        )
    if not (lit_dir / "notes.md").exists():
        (lit_dir / "notes.md").write_text(
            f"# {key} — notes\n\n"
            "Our interpretation, summaries, and questions. Keep separate from verbatim.\n"
        )
    print(f"OK: {key} -> raw_papers/{key}/, literature/papers/{key}/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
