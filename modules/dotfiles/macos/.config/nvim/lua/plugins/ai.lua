-- ─────────────────────────────────────────────────────────────────────────────
--  AI coding assistance
--
--  copilot.lua  — inline ghost completions (Tab)   :Copilot auth on first run
--  avante.nvim  — Claude chat panel                needs ANTHROPIC_API_KEY
--
--  claude-code.nvim removed: crashes on TermClose (nvim_buf_get_name on closed
--  buffer). Re-add when the plugin fixes the upstream bug. Use Claude Code
--  directly in a tmux split in the meantime: Ctrl-a " then run `claude`.
--
--  Keymaps:
--    Tab / C-j / C-l   accept full / word / line  (Copilot)
--    M-] / M-[         next / prev suggestion
--    M-Esc             dismiss
--    <leader>aa/ae/at  Avante ask / edit / toggle
-- ─────────────────────────────────────────────────────────────────────────────
return {

  -- ── Copilot ──────────────────────────────────────────────────────────────────
  {
    "zbirenbaum/copilot.lua",
    cmd   = "Copilot",
    event = "InsertEnter",
    opts = {
      suggestion = {
        enabled      = true,
        auto_trigger = true,
        debounce     = 75,
        keymap = {
          accept      = "<Tab>",
          accept_word = "<C-j>",
          accept_line = "<C-l>",
          next        = "<M-]>",
          prev        = "<M-[>",
          dismiss     = "<M-Esc>",
        },
      },
      panel = { enabled = false },
      filetypes = {
        TelescopePrompt = false,
        ["neo-tree"]    = false,
        toggleterm      = false,
        help            = false,
        gitcommit       = false,
        ["*"]           = true,
      },
    },
  },

  -- ── Avante — Claude chat panel ────────────────────────────────────────────────
  {
    "yetone/avante.nvim",
    cmd     = { "AvanteAsk", "AvanteEdit", "AvanteToggle", "AvanteRefresh", "AvanteSwitchProvider" },
    version = false,
    opts = {
      provider = "claude",
      auto_suggestions_provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model    = "claude-sonnet-4-6",
          timeout  = 30000,
          extra_request_body = {
            temperature = 0,
            max_tokens  = 8096,
          },
        },
      },
      behaviour = {
        auto_suggestions             = false,
        auto_set_highlight_group     = true,
        auto_set_keymaps             = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
      },
      mappings = {
        diff    = { ours = "co", theirs = "ct", none = "c0", both = "cb", next = "]x", prev = "[x" },
        jump    = { next = "]]", prev = "[[" },
        submit  = { normal = "<CR>", insert = "<C-s>" },
        ask     = "<leader>aa",
        edit    = "<leader>ae",
        refresh = "<leader>ar",
        toggle  = {
          default    = "<leader>at",
          debug      = "<leader>ad",
          hint       = "<leader>ah",
          suggestion = "<leader>as",
        },
      },
      hints = { enabled = true },
    },
    build = "make",
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name  = false,
            drag_and_drop         = { insert_mode = true },
          },
        },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = { file_types = { "markdown", "Avante" } },
        ft   = { "markdown", "Avante" },
      },
    },
  },
}