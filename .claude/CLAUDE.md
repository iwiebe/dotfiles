# User memory — Isaac (iwiebe)

Personal defaults across all projects. A project-level CLAUDE.md overrides these.

## Git — workflow guardrails
- **Never `git push` to a remote unless I explicitly tell you to in that turn.**
  Committing locally when I ask is fine; pushing always needs an explicit,
  per-instance instruction. Never push as a "finishing" step.
- When a change is ready to commit, **suggest a commit message**, then use
  **AskUserQuestion** to let me choose: **Commit** (as written), **Edit message**,
  or **Hold**. Don't run `git commit` until I pick.
- Don't commit directly to `main` on shared repos without asking — prefer a branch.

## Preferences
- **Package manager: pnpm** (via corepack). Don't use `npm`/`yarn` unless a repo
  clearly requires it.
- Match the surrounding code's conventions; don't add new tools or dependencies
  without asking. Confirm before anything destructive or outward-facing.
