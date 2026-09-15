# .zshrc
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

alias gam="$HOME/bin/gam7/gam"
alias vp="cd $HOME/src/GitHub/village-portal"
alias iwd="cd $HOME/src/GitHub/iw-docker/ansible"
alias iwd-down='ansible-playbook -i $HOME/src/GitHub/iw-docker/ansible/inventories/prod/hosts.yml $HOME/src/GitHub/iw-docker/ansible/playbooks/miner-control.yml -e "start_group=none stop_group=night_miners"'
alias iwd-up='ansible-playbook -i $HOME/src/GitHub/iw-docker/ansible/inventories/prod/hosts.yml $HOME/src/GitHub/iw-docker/ansible/playbooks/miner-control.yml -e "start_group=night_miners stop_group=none"'


#alias ansible="docker run -ti --rm -v ~/.ssh:/root/.ssh -v $(pwd):/apps -w /apps alpine/ansible ansible"

#alias ansible-playbook=" docker run -ti --rm -v ~/.ssh:/root/.ssh -v $(pwd):/apps -w /apps alpine/ansible ansible-playbook"

export PATH=$PATH:~/src/Qt/Tools/CMake
export PATH=$PATH:~/src/Qt/Tools/ninja

# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section

# IDE/Nuxt Dev Tools Connection
export EDITOR="zed --wait"
export LAUNCH_EDITOR="zed"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# Claude Alias
alias clauded="claude --allow-dangerously-skip-permissions"

# Prefer pnpm; use `command npm` for the rare repo that needs real npm
alias npm="pnpm"

# Git worktree helpers
gwa() {
  local branch="$1"
  local dir="$HOME/src/GitHub/worktrees/$branch"
  local src; src="$(git rev-parse --show-toplevel)" || return 1
  git worktree add -b "$branch" "$dir" || return 1
  # .env.e2e is gitignored, so it isn't carried into the new worktree — copy it
  # over from the source repo so e2e tests work out of the box.
  [ -f "$src/.env.e2e" ] && cp "$src/.env.e2e" "$dir/.env.e2e"
  cd "$dir"
}

gwc() {
  local branch="$1"
  local dir="$HOME/src/GitHub/worktrees/$branch"
  if git show-ref --verify --quiet "refs/heads/$branch"; then
    git worktree add "$dir" "$branch" && cd "$dir"
  else
    git fetch origin "$branch" &&
      git worktree add --track -b "$branch" "$dir" "origin/$branch" && cd "$dir"
  fi
}

gwr() {
  local branch="$1"
  local dir="$HOME/src/GitHub/worktrees/$branch"
  cd "$HOME/src/GitHub/village-portal" || return 1
  # --force so a dirty/ignored-file tree (node_modules, .nuxt, .env) still
  # unregisters; then rm -rf sweeps the gitignored leftovers that make git's
  # own rmdir fail with "Directory not empty"; prune cleans stale metadata.
  git worktree remove --force "$dir" 2>/dev/null
  rm -rf "$dir"
  git worktree prune
}

alias gwl="git worktree list"

ulimit -n 65536
