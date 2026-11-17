#!/bin/sh
# Mark the status line while sleep is disabled by the nosleep alias
# (pmset -a disablesleep 1). Without pmset (not macOS) this prints nothing.
pmset -g 2> /dev/null |
  awk '$1 == "SleepDisabled" && $2 == 1 { printf "#[fg=yellow]◉#[default] " }'
