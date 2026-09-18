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
  "roslyn",
  "sourcekit",
  "yamlls",
  "jsonls",
  "kotlin_language_server",
}

-- Servers/packages that lang.dotnet tries to install via Mason but
-- we don't want (either unused or fail to install cleanly).
local skip_mason = {
  "fsautocomplete",   -- F# LSP — not used
}

local function buffer_path(buf_or_path)
  local path = buf_or_path
  if type(buf_or_path) == "number" then
    path = vim.api.nvim_buf_get_name(buf_or_path)
  end
  return path ~= "" and path or nil
end

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
        kotlin_language_server = {
          mason = false,
          cmd = { "kotlin-language-server" },
          filetypes = { "kotlin" },
          root_dir = function(fname)
            fname = buffer_path(fname)
            if not fname then
              return nil
            end
            local util = require("lspconfig.util")
            return util.root_pattern(
              "settings.gradle", "settings.gradle.kts",
              "build.gradle", "build.gradle.kts",
              "pom.xml", ".git"
            )(fname)
          end,
        },

        -- Disable F# LSP (not used)
        fsautocomplete = { enabled = false },

        -- macOS-specific: Swift LSP (uses Xcode's sourcekit-lsp)
        sourcekit = {
          mason     = false,
          cmd       = { "/usr/bin/xcrun", "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          on_init  = function(client)
            -- Xcode SourceKit currently fails its variable-type inlay hints
            -- request for some Swift documents.
            client.server_capabilities.inlayHintProvider = false
          end,
          root_dir  = function(bufnr, on_dir)
            local fname = buffer_path(bufnr)
            if not fname then
              return
            end
            local util = require("lspconfig.util")
            local root = util.root_pattern(
              "Package.swift",
              "buildServer.json",
              "*.xcodeproj",
              "*.xcworkspace",
              ".git"
            )(fname) or util.find_git_ancestor(fname)
            if root then
              on_dir(root)
            end
          end,
        },
      },
    },
  },

  -- ── mason.nvim: skip unwanted packages ──────────────────────────
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(pkg)
        return not vim.tbl_contains(skip_mason, pkg)
      end, opts.ensure_installed)
    end,
  },

  -- ── mason-lspconfig: evict Nix-managed + skipped servers ────────
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      opts.ensure_installed = vim.tbl_filter(function(server)
        return not vim.tbl_contains(nix_managed, server)
          and not vim.tbl_contains(skip_mason, server)
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
        "java", "json", "kotlin", "lua", "luadoc", "markdown", "markdown_inline",
        "nix", "python", "query", "regex", "rust",
        "scala", "sql", "terraform", "toml", "tsx",
        "typescript", "vim", "vimdoc", "xml", "yaml",
        "zig", "swift",
        "c_sharp",
      },
    },
  },
}
