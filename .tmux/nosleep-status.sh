#!/bin/sh
# Mark the status line while sleep is disabled by the nosleep alias
# (pmset -a disablesleep 1). Without pmset (not macOS) this prints nothing.
# The mark blinks by turning into a blank of the same width for one second in
# ten, relying on status-interval 1; #[blink] depends on the terminal.
pmset -g 2> /dev/null |
  awk -v t="$(date +%s)" '$1 == "SleepDisabled" && $2 == 1 {
    printf "%s ", (t % 10 == 9 ? " " : "#[fg=yellow]◉#[default]")
  }'
