#!/bin/bash
# Display active network interface status.
# No external network calls; reads local interface state only.
SSID="$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I 2>/dev/null | awk -F': ' '/ SSID/{print $2}')"

if [ -n "$SSID" ]; then
  sketchybar --set "$NAME" icon="W" label="$SSID"
else
  IFACE="$(route -n get default 2>/dev/null | awk '/interface:/{print $2}')"
  if [ -n "$IFACE" ]; then
    sketchybar --set "$NAME" icon="E" label="$IFACE"
  else
    sketchybar --set "$NAME" icon="X" label="offline"
  fi
fi
