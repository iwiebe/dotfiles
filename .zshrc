# .zshrc
fpath+=("$(brew --prefix)/share/zsh/site-functions")
autoload -U promptinit; promptinit
prompt pure

alias gam="/Users/iwiebe/bin/gam7/gam"
alias vp="cd /Users/iwiebe/src/GitHub/village-portal"
alias iwd="cd /Users/iwiebe/src/GitHub/iw-docker/ansible"
alias iwd-down='ansible-playbook -i /Users/iwiebe/src/GitHub/iw-docker/ansible/inventories/prod/hosts.yml /Users/iwiebe/src/GitHub/iw-docker/ansible/playbooks/miner-control.yml -e "start_group=none stop_group=night_miners"'
alias iwd-up='ansible-playbook -i /Users/iwiebe/src/GitHub/iw-docker/ansible/inventories/prod/hosts.yml /Users/iwiebe/src/GitHub/iw-docker/ansible/playbooks/miner-control.yml -e "start_group=night_miners stop_group=none"'


#alias ansible="docker run -ti --rm -v ~/.ssh:/root/.ssh -v $(pwd):/apps -w /apps alpine/ansible ansible"

#alias ansible-playbook=" docker run -ti --rm -v ~/.ssh:/root/.ssh -v $(pwd):/apps -w /apps alpine/ansible ansible-playbook"

export PATH=$PATH:~/src/Qt/Tools/CMake
export PATH=$PATH:~/src/Qt/Tools/ninja

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/iwiebe/.lmstudio/bin"
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
  git worktree add -b "$branch" "$dir" && cd "$dir"
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
  cd "$HOME/src/GitHub/village-portal" && git worktree remove "$dir"
}

alias gwl="git worktree list"

ulimit -n 65536
