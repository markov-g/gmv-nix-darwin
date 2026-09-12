#!/bin/bash
# Display current date and time.
# No network access.
sketchybar --set "$NAME" label="$(date '+%H:%M  %d %b')"
