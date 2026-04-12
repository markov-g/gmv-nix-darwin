-- Servers that Nix manages (do NOT let Mason install these)
local nix_managed = {
  "nil_ls",     -- Nix
  "gopls",      -- Go
  "rust_analyzer",
  "clangd",     -- C/C++
  "zls",        -- Zig
  "bashls",
  "lua_ls",
  "ts_ls",
  "yamlls",
  "jsonls",
}

return {
  -- ── nvim-lspconfig: server definitions ──────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- Nix-managed servers
        nil_ls         = { mason = false },
        gopls          = { mason = false },
        rust_analyzer  = { mason = false },
        clangd         = { mason = false },
        zls            = { mason = false },
        bashls         = { mason = false, filetypes = { "sh", "bash" } },
        lua_ls         = { mason = false },
        ts_ls          = { mason = false },
        jsonls         = { mason = false },
        yamlls         = {
          mason = false,
          settings = {
            yaml = {
              schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = "/.github/workflows/*",
                ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = "/docker-compose*.yml",
              },
            },
          },
        },

        -- macOS-specific: Swift LSP (uses Xcode's sourcekit-lsp)
        sourcekit = {
          cmd       = { "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_dir  = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("Package.swift", "*.xcodeproj", "*.xcworkspace")(fname)
              or util.find_git_ancestor(fname)
          end,
        },
      },
    },
  },

  -- ── Mason: evict Nix-managed and skip F# server ─────────────────
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(server)
        -- Skip Nix-managed servers and fsautocomplete (F# — not used)
        return not vim.tbl_contains(nix_managed, server)
          and server ~= "fsautocomplete"
      end, opts.ensure_installed)
    end,
  },

  -- ── Treesitter: additional parsers ──────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash", "c", "css", "diff", "dockerfile",
        "go", "gomod", "gosum", "html", "javascript",
        "json", "lua", "luadoc", "markdown", "markdown_inline",
        "nix", "python", "query", "regex", "rust",
        "scala", "sql", "terraform", "toml", "tsx",
        "typescript", "vim", "vimdoc", "xml", "yaml",
        "zig", "swift",
        "c_sharp",
      },
    },
  },
}
