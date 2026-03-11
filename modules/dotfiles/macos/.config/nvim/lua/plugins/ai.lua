-- ─────────────────────────────────────────────────────────────────────────────
--  AI coding assistance
--
--  avante.nvim   — inline AI chat panel, like Cursor (uses Claude by default)
--                  <leader>aa  Ask AI about selection / file
--                  <leader>ae  Edit selection with AI
--                  <leader>ar  Refresh AI response
--                  <leader>at  Toggle Avante panel
--
--  supermaven    — ultra-fast inline ghost completions (Tab to accept)
--                  Tab     Accept full suggestion
--                  C-j     Accept next word
--                  C-]     Dismiss suggestion
-- ─────────────────────────────────────────────────────────────────────────────
return {
  -- ── Avante: Claude / GPT AI assistant panel ─────────────────────────────────
  {
    "yetone/avante.nvim",
    cmd     = { "AvanteAsk", "AvanteEdit", "AvanteToggle", "AvanteRefresh", "AvanteSwitchProvider" },
    version = false,   -- always use the latest commit
    opts = {
      provider = "claude",
      auto_suggestions_provider = "claude",
      providers = {
        claude = {
          endpoint    = "https://api.anthropic.com",
          model       = "claude-sonnet-4-5",
          timeout     = 30000,
          temperature = 0,
          max_tokens  = 8096,
        },
      },
      behaviour = {
        auto_suggestions          = false, -- use supermaven for inline, avante for chat
        auto_set_highlight_group  = true,
        auto_set_keymaps          = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = true,
      },
      mappings = {
        diff = {
          ours   = "co", theirs = "ct",
          none   = "c0", both   = "cb",
          next   = "]x", prev   = "[x",
        },
        suggestion = {
          accept  = "<M-l>",
          next    = "<M-]>",
          prev    = "<M-[>",
          dismiss = "<C-]>",
        },
        jump = { next = "]]", prev = "[[" },
        submit = { normal = "<CR>", insert = "<C-s>" },
        ask    = "<leader>aa",
        edit   = "<leader>ae",
        refresh = "<leader>ar",
        toggle = {
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
            embed_image_as_base64  = false,
            prompt_for_file_name   = false,
            drag_and_drop          = { insert_mode = true },
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

  -- ── Supermaven: blazing-fast inline ghost completions ────────────────────────
  {
    "supermaven-inc/supermaven-nvim",
    event = "InsertEnter",
    opts = {
      keymaps = {
        accept_suggestion = "<Tab>",    -- accept full ghost text
        clear_suggestion  = "<C-]>",   -- dismiss
        accept_word       = "<C-j>",   -- accept next word only
      },
      ignore_filetypes = {
        "TelescopePrompt", "neo-tree", "toggleterm", "help",
      },
      color = {
        suggestion_color = "#6c7086",  -- catppuccin mocha overlay0 (subtle)
        cterm            = 244,
      },
    },
  },
}
