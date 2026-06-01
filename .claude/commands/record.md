---
description: Checkpoint the current session — copy session JSONL into archive/ with sha256 and git HEAD.
---

Archive the active session for tamper-evident research history.

Do this:

1. Locate the active session JSONL. Claude Code session files for this project live under:
   `~/.claude/projects/<encoded-project-dir>/<session-id>.jsonl`
   where `<encoded-project-dir>` is the absolute path of this repo with `/` replaced by `-` and a leading `-`.
   Find the most recently modified `*.jsonl` file there.
2. Compute its `sha256` (use `shasum -a 256` or `.venv/bin/python -c "import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" <path>`).
3. Copy it to `archive/raw/<session-id>-<short-description>.jsonl`. Ask the user for the short description; default to today's date.
4. Run `git rev-parse HEAD` (if there is a commit). Capture the hash; "(none)" if no commit yet.
5. Append an entry to `archive/checkpoints.json` (create with `[]` if missing). Each entry:
   ```json
   {
     "session_id": "<id>",
     "archived_at": "<ISO 8601>",
     "source_path": "<original path>",
     "archive_path": "archive/raw/<filename>",
     "sha256": "<hash>",
     "size_bytes": <int>,
     "git_head": "<hash or 'none'>",
     "description": "<user description>"
   }
   ```
6. Commit the archive with `git add archive/ && git commit -m "checkpoint: <description>"`. Tell the user the commit hash and the archive size.

**Hard rules**:
- Never modify the source `.jsonl` in `~/.claude/projects/`. Copy only.
- Always include sha256 — this is the integrity chain.
- Append to checkpoints.json; never rewrite previous entries.
