#!/bin/bash
# Display battery percentage.
# No network access.
PERCENTAGE="$(pmset -g batt | grep -Eo "\d+%" | head -1)"
CHARGING="$(pmset -g batt | grep -c 'AC Power')"

if [ "$CHARGING" -gt 0 ]; then
  sketchybar --set "$NAME" icon="" label="${PERCENTAGE}"
else
  sketchybar --set "$NAME" icon="" label="${PERCENTAGE}"
fi
