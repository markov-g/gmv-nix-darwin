-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  AI plugins — Copilot + Claude Code                             ║
-- ╚══════════════════════════════════════════════════════════════════╝

return {
  -- ── GitHub Copilot ──────────────────────────────────────────────
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
          accept      = "<Tab>",
          accept_word = "<C-l>",
          accept_line = "<C-j>",
          next        = "<M-]>",
          prev        = "<M-[>",
          dismiss     = "<C-]>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        markdown = true,
        help     = false,
      },
    },
  },

  -- ── Claude Code (terminal + editor integration) ─────────────────
  --
  -- Sources ~/.claude.env and ~/.codex.env if present (same pattern as ~/.herdr-start.sh).
  -- opencode reads its provider credentials from those files at launch.
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    opts = {
      terminal_cmd = "zsh -c 'setopt allexport; [[ -f ~/.claude.env ]] && source ~/.claude.env; [[ -f ~/.codex.env ]] && source ~/.codex.env; unsetopt allexport; opencode'",
      terminal = {
        split_side = "right",
        split_width_percentage = 0.40,
      },
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",             desc = "Toggle OpenCode" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",         desc = "Focus OpenCode" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",     desc = "Resume OpenCode" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>",   desc = "Continue OpenCode" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",         desc = "Add buffer to OpenCode" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to OpenCode" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",    desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",      desc = "Reject diff" },
    },
  },
}
