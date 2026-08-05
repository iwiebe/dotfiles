# User memory — Isaac (iwiebe)

Personal defaults across all projects. A project-level CLAUDE.md overrides these.

## Git — workflow guardrails
- **Never `git push` to a remote unless I explicitly tell you to in that turn.**
  Committing locally when I ask is fine; pushing always needs an explicit,
  per-instance instruction. Never push as a "finishing" step.
- **Don't ask about committing until I bring it up.** When a change is done,
  summarize it and stop — I want room to test, tweak, and iterate first. Only
  when I say I'm ready to commit (or ask for a commit), use **AskUserQuestion**
  to let me choose: **Commit**, **Edit message**, or **Hold** — and put the full
  proposed commit message **inside the dialog itself** (e.g., as the Commit
  option's preview/description), not only in chat text above it. Don't run
  `git commit` until I pick.
- Don't commit directly to `main` on shared repos without asking — prefer a branch.

## Preferences
- **Package manager: pnpm** (via corepack). Don't use `npm`/`yarn` unless a repo
  clearly requires it.
- Match the surrounding code's conventions; don't add new tools or dependencies
  without asking. Confirm before anything destructive or outward-facing.

## Dev server
- **Assume I already have the dev server running on port 3000.** Don't start a
  fresh server on 3000. Either start yours on a different port (e.g. 3001) OR ask
  whether you can use my running instance on 3000. Never assume 3000 is free.
