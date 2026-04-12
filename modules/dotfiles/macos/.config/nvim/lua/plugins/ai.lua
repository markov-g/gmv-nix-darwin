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
  -- Requires ~/.claude-env with credentials. Create it manually:
  --   cat > ~/.claude-env << 'EOF'
  --   export CLAUDE_CODE_USE_FOUNDRY=1
  --   export ANTHROPIC_FOUNDRY_RESOURCE=YOUR_RESOURCE_NAME
  --   export ANTHROPIC_FOUNDRY_API_KEY=YOUR_API_KEY
  --   export ANTHROPIC_DEFAULT_SONNET_MODEL=claude-sonnet-4-6
  --   export ANTHROPIC_DEFAULT_HAIKU_MODEL=claude-sonnet-4-6
  --   export ANTHROPIC_DEFAULT_OPUS_MODEL=claude-sonnet-4-6
  --   EOF
  --   chmod 600 ~/.claude-env
  --
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    config = true,
    opts = {
      terminal_cmd = "bash -c 'source ~/.claude-env && claude'",
      terminal = {
        split_side = "right",
        split_width_percentage = 0.40,
      },
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>",             desc = "Toggle Claude Code" },
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",         desc = "Focus Claude Code" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",     desc = "Resume Claude" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>",   desc = "Continue Claude" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",         desc = "Add buffer to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>",    desc = "Accept Claude diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>",      desc = "Reject Claude diff" },
    },
  },
}
