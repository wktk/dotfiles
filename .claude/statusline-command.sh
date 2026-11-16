#!/bin/sh
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Build git branch segment (skip optional locks)
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)

# Dirty indicator: red * when there are uncommitted changes
dirty=""
if [ -n "$branch" ]; then
  git_status=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  [ -n "$git_status" ] && dirty=1
fi

# Ahead/behind indicator: yellow ↑N / ↓N (skipped silently if no upstream)
ahead_behind=""
if [ -n "$branch" ]; then
  ab=$(git -C "$cwd" --no-optional-locks rev-list --count --left-right @{u}...HEAD 2>/dev/null)
  if [ -n "$ab" ]; then
    behind=$(echo "$ab" | cut -f1)
    ahead=$(echo "$ab" | cut -f2)
    [ "$ahead" -gt 0 ] 2>/dev/null && ahead_behind="${ahead_behind}\033[33m↑${ahead}\033[0m"
    [ "$behind" -gt 0 ] 2>/dev/null && ahead_behind="${ahead_behind}\033[33m↓${behind}\033[0m"
  fi
fi

# Build the status line
# blue for cwd, cyan for git branch, dim for model
printf "\033[34m%s\033[0m" "$(echo "$cwd" | sed "s|$HOME|~|")"
if [ -n "$branch" ]; then
  printf " \033[32m%s\033[0m" "$branch"
  [ -n "$dirty" ] && printf "\033[31m*\033[0m"
  [ -n "$ahead_behind" ] && printf "%b" "$ahead_behind"
fi
printf " \033[36m%s\033[0m" "$model"
[ -n "$used" ] && printf " \033[33mctx:%.0f%%\033[0m" "$used"
[ -n "$five_hour" ] && printf " \033[35m5h:%.0f%%\033[0m" "$five_hour"
[ -n "$seven_day" ] && printf " \033[35m7d:%.0f%%\033[0m" "$seven_day"
