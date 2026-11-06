#!/usr/bin/env bash
# two git calls per refresh: status for branch + untracked files, diff for line counts

status=$(git status --porcelain=v2 --branch --untracked-files=all 2>/dev/null) || { echo ""; exit 0; }

branch=""
oid=""
untracked_files_count=0
while IFS= read -r line; do
  case "$line" in
    "# branch.head "*) branch=${line#"# branch.head "} ;;
    "# branch.oid "*) oid=${line#"# branch.oid "} ;;
    "? "*) untracked_files_count=$((untracked_files_count + 1)) ;;
  esac
done <<< "$status"

# detached HEAD: show the short sha, like before
[ "$branch" = "(detached)" ] && branch=${oid:0:7}

# " 3 files changed, 10 insertions(+), 2 deletions(-)" (staged + unstaged, vs HEAD)
shortstat=$(git diff HEAD --shortstat 2>/dev/null)
tracked_files_count=$(echo "$shortstat" | sed -n 's/^ *\([0-9]*\) file.*/\1/p')
added_lines_count=$(echo "$shortstat" | sed -n 's/.* \([0-9]*\) insertion.*/\1/p')
deleted_lines_count=$(echo "$shortstat" | sed -n 's/.* \([0-9]*\) deletion.*/\1/p')

added_lines_count=${added_lines_count:-0}
deleted_lines_count=${deleted_lines_count:-0}
touched_files_count=$((${tracked_files_count:-0} + untracked_files_count))

output="on #[fg=5] $branch#[default]"

changes=""
[ "$touched_files_count" -gt 0 ] && changes+=" #[fg=color4] $touched_files_count#[default] -"
[ "$added_lines_count" -gt 0 ] && changes+=" #[fg=color2] $added_lines_count#[default]"
[ "$deleted_lines_count" -gt 0 ] && changes+=" #[fg=color1] $deleted_lines_count#[default]"

[ -n "$changes" ] && output="$changes $output"

echo "$output"
