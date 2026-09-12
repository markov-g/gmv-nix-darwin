#!/bin/bash
# Display the name of the currently focused application.
# No network access, no shell injection, no dynamic package execution.
sketchybar --set "$NAME" label="$INFO"
