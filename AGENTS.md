# Agent Guide

Context for working on this fork of `zed` with the CLI agent.

> Note: `AGENTS.md` is for this fork only. Do not include it in upstream PRs. Keep it untracked/ignored locally.
> We ignore `AGENTS.md` via `.gitignore`; never stage or commit that change upstream.

## Workflow expectations
- PR titles: sentence‑style; start lowercase unless a proper noun requires caps.
- PR body: always include a **Release Notes:** section with bullet(s) or `- N/A` if not user‑facing. Add a concise summary and any testing notes.
- Commits: small, focused, present tense, include scope (e.g. `git: collapse nested paths before refreshing statuses`), optional body for nuance.
- Branches: use short, descriptive names (e.g. `ch/git-status-dedupe`).
- Formatting: run `cargo fmt` after Rust changes. Prefer `rg` for search, avoid destructive git commands.
- Verification: run relevant tests when feasible (e.g. `cargo test -p <crate>`, `cargo fmt -- --check`). If tests are impractical, list manual steps you performed or that the reviewer should try.

## Contributing tips
- Keep edits minimal to the requested surface area; leave unrelated files untouched.
- When opening PRs, double‑check the release notes block to satisfy the bot.
- For large changes, summarize the why in the PR description, and add a brief testing note (even if “not run”).
- If a change is not user‑facing (e.g. code health), state that explicitly in Release Notes.
