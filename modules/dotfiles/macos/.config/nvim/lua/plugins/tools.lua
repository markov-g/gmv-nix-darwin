-- ─────────────────────────────────────────────────────────────────────────────
--  Extra tools and productivity plugins
-- ─────────────────────────────────────────────────────────────────────────────
return {
  -- ── Catppuccin colorscheme (LazyVim default is tokyonight; override here) ───
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    opts = {
      flavour         = "mocha",
      transparent_background = false,
      show_end_of_buffer = false,
      term_colors     = true,
      dim_inactive = { enabled = true, shade = "dark", percentage = 0.15 },
      integrations = {
        cmp            = true,
        gitsigns       = true,
        nvimtree       = true,
        treesitter     = true,
        telescope      = { enabled = true },
        which_key      = true,
        mini           = { enabled = true, indentscope_color = "" },
        harpoon        = true,
        mason          = true,
        dap            = { enabled = true, enable_ui = true },
        neotest        = true,
        neotree        = true,
        lazygit        = true,
        lsp_trouble    = true,
      },
    },
  },
  -- Set catppuccin as the LazyVim colorscheme
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "catppuccin" },
  },

  -- ── Seamless vim/tmux pane navigation (C-h/j/k/l) ────────────────────────────
  {
    "christoomey/vim-tmux-navigator",
    cmd  = { "TmuxNavigateLeft", "TmuxNavigateDown", "TmuxNavigateUp", "TmuxNavigateRight" },
    keys = {
      { "<c-h>",  "<cmd>TmuxNavigateLeft<cr>",     desc = "Pane left"  },
      { "<c-j>",  "<cmd>TmuxNavigateDown<cr>",     desc = "Pane down"  },
      { "<c-k>",  "<cmd>TmuxNavigateUp<cr>",       desc = "Pane up"    },
      { "<c-l>",  "<cmd>TmuxNavigateRight<cr>",    desc = "Pane right" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Pane prev"  },
    },
  },

  -- ── LazyGit integration ───────────────────────────────────────────────────────
  {
    "kdheepak/lazygit.nvim",
    cmd          = { "LazyGit", "LazyGitConfig", "LazyGitCurrentFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>gg", "<cmd>LazyGit<cr>",            desc = "LazyGit" },
      { "<leader>gG", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit (current file)" },
    },
  },

  -- ── Undotree — visual undo history ────────────────────────────────────────────
  {
    "mbbill/undotree",
    keys = { { "<leader>u", "<cmd>UndotreeToggle<cr>", desc = "Undo Tree" } },
  },

  -- ── Database UI (dadbod) ──────────────────────────────────────────────────────
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod",                    lazy = true },
      { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" }, lazy = true },
    },
    cmd  = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function() vim.g.db_ui_use_nerd_fonts = 1 end,
    keys = { { "<leader>D", "<cmd>DBUIToggle<cr>", desc = "Database UI" } },
  },

  -- ── Neotest: run tests from inside nvim ───────────────────────────────────────
  {
    "nvim-neotest/neotest",
    optional    = true,
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-neotest/neotest-go",
      "rouge8/neotest-rust",
    },
  },

  -- ── oil.nvim: edit the filesystem like a buffer ────────────────────────────────
  {
    "stevearc/oil.nvim",
    opts = {
      view_options = { show_hidden = true },
      float = { padding = 2 },
    },
    keys = {
      { "<leader>o", "<cmd>Oil --float<cr>", desc = "Oil file manager (float)" },
      { "-",         "<cmd>Oil<cr>",          desc = "Open parent directory" },
    },
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- ── Marks: visual marks in the gutter ────────────────────────────────────────
  {
    "chentoast/marks.nvim",
    event  = "BufReadPre",
    config = true,
  },

  -- ── Obsidian: note-taking inside nvim ─────────────────────────────────────────
  -- Uncomment and set vault_dir to enable:
  -- {
  --   "epwalsh/obsidian.nvim",
  --   version  = "*",
  --   lazy     = true,
  --   ft       = "markdown",
  --   dependencies = { "nvim-lua/plenary.nvim" },
  --   opts = {
  --     workspaces = { { name = "notes", path = "~/notes" } },
  --   },
  -- },

  -- ── rest.nvim: HTTP client inside nvim (.http files) ────────────────────────
  {
    "rest-nvim/rest.nvim",
    ft   = { "http" },
    opts = {},
    keys = {
      { "<leader>rr", "<cmd>Rest run<cr>",      desc = "Run REST request" },
      { "<leader>rl", "<cmd>Rest run last<cr>", desc = "Run last REST request" },
    },
  },
}
