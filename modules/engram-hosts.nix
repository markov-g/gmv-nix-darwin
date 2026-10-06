# Single source of truth for which machines have Engram (local-only memory
# MCP server) enabled -- the Homebrew tap/cask, the opencode.jsonc "mcp.engram"
# block, and the brew-trust activation reminder all key off this one list.
#
# Why gated at all: gentleman-programming/tap requires a one-time, manual,
# interactive `brew trust` per formula/cask on first use (Homebrew's Tap
# Trust security gate -- see docs.brew.sh/Taps -- has no declarative or
# non-interactive bypass). That's a real exception to this repo's
# zero-imperative-steps model, accepted deliberately on a chosen subset of
# machines rather than silently applied everywhere.
#
# To add a machine: add its host string below, then run darwin-rebuild and
# follow the `brew trust` reminder printed during activation (see
# homebrew.nix). To remove one: delete its entry here -- the tap, cask, and
# opencode.jsonc MCP block are all gone on the next rebuild.
[
  "minidevbox"
]
