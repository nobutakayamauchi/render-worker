# Render Worker Codex Operating Policy

This repository is intended to support fast, smartphone-first operation with Codex and GitHub Actions. Prefer immediate progress over repeated low-value approval prompts, while preserving explicit confirmation for operations with meaningful external or destructive impact.

## Primary operating mode

- Work directly in this repository and continue from existing files instead of restarting work from scratch.
- Prefer readable scripts and checked-in files over long inline shell one-liners.
- Prefer deterministic, inspectable automation.
- Keep local VPS work lightweight. Heavy Chromium, HyperFrames snapshot/final render, and FFmpeg encode should run in GitHub Actions whenever practical.
- Do not repeatedly ask for confirmation for safe read-only inspection, lightweight validation, or known workspace-local checks.

## Automatically safe / proceed without asking when allowed by the environment

Treat these as routine operations inside this repository:

- Read-only Git inspection: `git status`, `git diff`, `git log`, `git show`, `git branch --show-current`, `git remote -v`, `git fetch`.
- Read-only GitHub CLI inspection: `gh auth status`, `gh run list`, `gh run view`, `gh run watch`, read-only `gh api` calls for Actions runs, jobs, logs, and artifacts.
- Workspace-local file inspection: `cat`, `sed -n`, `rg`, `find`, `ls`, `stat`, `ffprobe`, `file`.
- Lightweight syntax and asset checks such as `node scripts/check.mjs`, `bash -n scripts/*.sh`, JSON parsing, HTML/JS syntax checks, and package metadata inspection.
- Workspace-local creation or modification of expected project files such as `index.html`, `TRANSITIONS.json`, `package.json`, `scripts/*`, and `.github/workflows/*`, provided the change is directly required by the current task and remains within this repository.
- Creation of temporary or generated files under this repository when needed for preview, audio generation, or packaging.

## Require explicit confirmation

Always stop for user approval before operations with meaningful external or destructive impact, including:

- `git push`, force push, tag push, release publication, or other writes to remote GitHub state.
- `git rebase`, `git reset --hard`, history rewriting, conflict resolution that discards one side, or branch deletion.
- File deletion beyond clearly generated temporary files, especially recursive deletion.
- `sudo`, package-manager changes to the host, system service changes, firewall/network changes, credential changes, or writes outside the repository.
- Any command that could expose secrets, tokens, private keys, credentials, or sensitive environment variables.
- Any Base64-obfuscated or otherwise difficult-to-inspect execution pattern such as `eval(Buffer.from(..., 'base64').toString())`.
- Arbitrary inline `node -e`, `python -c`, or shell payloads that contain substantial generated code and are not readily inspectable.

## Avoid approval-hostile command construction

Do not use Base64 wrappers, `eval`, or opaque encoded payloads simply to write files or execute project logic.

Instead:

1. Write a readable `.mjs`, `.js`, `.sh`, or other source file inside the repository.
2. Show or validate the file when useful.
3. Execute that file normally.

Prefer commands such as:

- `node scripts/check.mjs`
- `bash scripts/generate_audio.sh`
- `node scripts/render.mjs`

rather than long `node -e` or encoded one-liners.

## GitHub Actions render policy

GitHub Actions is the canonical heavy render environment for this repository.

Local VPS responsibilities:

- edit HTML/JS/JSON
- generate or update scripts
- lightweight checks
- inspect Git state
- prepare commits

GitHub Actions responsibilities:

- Chromium / HyperFrames browser work
- snapshots when required
- final 1080x1920 render
- FFmpeg encode / mux
- H.264 + AAC output
- `ffprobe` verification
- artifact upload

Do not burn local VPS resources repeatedly on heavy render verification when Actions can perform the same work.

## Completion rules for video render tasks

For BridgePatch-style vertical SNS videos, do not declare completion until the requested completion criteria are actually verified. Typical checks include:

- all required source images are used
- transition plan exists when requested
- output is not merely a static slideshow when composition-aware transitions were requested
- required BGM / SE are present
- audio stream is verified with `ffprobe`
- target resolution and approximate duration are verified
- GitHub Actions run succeeds
- final MP4 artifact exists

Report concrete run/artifact/output facts rather than assuming success.

## Approval philosophy

The goal is not zero approvals. The goal is zero repeated approvals for low-risk, already-understood work.

Use this hierarchy:

1. Read / inspect / validate: proceed immediately.
2. Repository-local implementation required by the active task: proceed when clearly scoped and reversible.
3. Remote mutation, history rewrite, deletion, host/system changes, credential exposure, or opaque execution: require explicit approval.

When uncertain, prefer a readable and reversible implementation path rather than repeatedly interrupting the user.