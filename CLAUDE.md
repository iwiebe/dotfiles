# dotfiles — repo rules

Overrides the git guardrails in `~/.claude/CLAUDE.md` for this repo only. This
is a single-user repo whose whole job is to stay in sync across machines, so a
change that is committed but unpushed is an unfinished change.

## Git — run the full cycle for every set of changes

1. **Pull first, automatically.** `git pull --rebase --autostash` before
   touching files, and again before committing. No need to ask.
2. **Confirm the commit.** As soon as a set of changes is complete, use
   **AskUserQuestion** with the full proposed message in the dialog (format as
   in `~/.claude/CLAUDE.md`). Ask straight away rather than waiting for me to
   raise it.
3. **Push automatically** once I pick Commit. Standing authorization for this
   repo — no per-turn instruction needed.

Commit directly to `main`. No branch, no PR.

**GitHub Desktop stashes behind you.** It stashes uncommitted work as
`!!GitHub_Desktop<branch>` before pulling, so a change that "vanished" is
usually sitting in `git stash list`. Check there before redoing the work.

## Brewfile

Installing a package means recording it: add the entry in alphabetical order
within its `brew`/`cask` block, above it a comment holding the package's own
description (`brew info --json=v2 <pkg> | jq -r '.formulae[0].desc'`, or
`.casks[0].desc`). The file is generated-looking on purpose — keep it that way.
