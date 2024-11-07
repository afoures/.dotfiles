number_of_new_commit=$(git fetch > /dev/null; git rev-list HEAD...origin/main --count)
if [[ number_of_new_commit -eq 0 ]]; then
  return
fi

git merge --no-commit --no-ff main > /dev/null
has_conflict=$?
if [[ ! has_conflict -eq 0 ]]; then
  git merge --abort
  return
fi

git pull > /dev/null

# - if brew file changed, run it
# - if kitty config changed, reload it
# - if zsh config changed, source it
# - if tmux config changed, reload it
