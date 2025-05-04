#!/usr/bin/env bash
if git rev-parse --is-inside-work-tree &>/dev/null; then

  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

  tracked_files_count=$(git diff --numstat | wc -l)
  tracked_added_lines_count=$(git diff --numstat | awk '{added += $1} END {print added}')
  tracked_deleted_lines_count=$(git diff --numstat | awk '{deleted += $2} END {print deleted}')

  untracked_files_count=$(git ls-files --others --exclude-standard | wc -l)
  untracked_added_lines_count=$(git ls-files --others --exclude-standard | xargs wc -l | awk '/total$/ {print $1}')

  added_lines_count=$((${tracked_added_lines_count:-0} + ${untracked_added_lines_count:-0}))
  deleted_lines_count=${tracked_deleted_lines_count:-0}
  touched_files_count=$((${tracked_files_count:-0} + ${untracked_files_count:-0}))

  output="on #[fg=5] $branch#[default]"
  
  changes=""
  [ "$touched_files_count" -gt 0 ] && changes+=" #[fg=color4] $touched_files_count#[default] -"
  [ "$added_lines_count" -gt 0 ] && changes+=" #[fg=color2] $added_lines_count#[default]"
  [ "$deleted_lines_count" -gt 0 ] && changes+=" #[fg=color1] $deleted_lines_count#[default]"

  [ -n "$changes" ] && output="$changes $output"

  echo "$output"
else
  echo ""
fi
