-- ─────────────────────────────────────────────────────────────────────────────
--  LSP configuration
--
--  Nix-managed servers (on PATH via system.nix — Mason must NOT touch these):
--    nil_ls, gopls, rust_analyzer, clangd, zls, statix
--
--  The LazyVim lang.nix extra registers nil_ls in nvim-lspconfig servers table
--  (not in ensure_installed). mason-lspconfig then sees an unmanaged server and
--  tries to auto-install it. Fix: set mason = false on all nix-managed servers
--  so mason-lspconfig skips them entirely, regardless of load order.
-- ─────────────────────────────────────────────────────────────────────────────

local nix_managed = {
  nil_ls        = true,
  gopls         = true,
  rust_analyzer = true,
  clangd        = true,
  zls           = true,
  statix        = true,
}

return {

  -- ── Mason: tools Mason CAN install on aarch64-darwin ─────────────────────────
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "omnisharp",
        "shellcheck",
        "sqlfluff",
        "nixpkgs-fmt",
      })
    end,
  },

  -- ── mason-lspconfig: evict nix-managed servers ───────────────────────────────
  {
    "mason-org/mason-lspconfig.nvim",
    opts = function(_, opts)
      -- Filter ensure_installed
      opts.ensure_installed = opts.ensure_installed or {}
      local filtered = {}
      for _, s in ipairs(opts.ensure_installed) do
        if not nix_managed[s] then table.insert(filtered, s) end
      end
      opts.ensure_installed = filtered
      -- Belt-and-suspenders: also exclude from auto-install
      opts.automatic_installation = { exclude = vim.tbl_keys(nix_managed) }
      return opts
    end,
  },

  -- ── nvim-lspconfig: mark nix-managed servers as mason = false ────────────────
  -- This is the KEY fix: mason-lspconfig checks the mason option per-server.
  -- Setting mason = false tells it "this server is externally managed, skip it."
  -- LazyVim's lang.nix extra sets nil_ls = {} which triggers auto-install;
  -- we override that here with mason = false to prevent it.
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {

        -- ── Nix-managed: explicitly opt out of Mason ──────────────────────────
        nil_ls        = { mason = false },
        gopls         = { mason = false },
        rust_analyzer = { mason = false },
        clangd        = { mason = false },
        zls           = { mason = false },

        -- ── Swift ─────────────────────────────────────────────────────────────
        sourcekit = {
          cmd       = { "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_dir  = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("Package.swift", "*.xcodeproj", "*.xcworkspace")(fname)
              or util.find_git_ancestor(fname)
          end,
        },

        -- ── C# / OmniSharp ────────────────────────────────────────────────────
        -- Requires a .csproj or .sln — won't activate on standalone .cs files
        omnisharp = {
          cmd = { "omnisharp" },
          filetypes = { "cs", "vb" },
          settings = {
            FormattingOptions       = { EnableEditorConfigSupport = true },
            MsBuild                 = { LoadProjectsOnDemand = false },
            RoslynExtensionsOptions = { EnableAnalyzersSupport = true },
          },
        },

        -- ── Bash / Shell ──────────────────────────────────────────────────────
        bashls = {
          filetypes = { "sh", "bash", "zsh" },
          settings  = { bashIde = { globPattern = "**/*@(.sh|.inc|.bash|.command|.zsh)" } },
        },

        -- ── YAML + schemas ────────────────────────────────────────────────────
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                ["https://json.schemastore.org/github-workflow.json"] = ".github/workflows/*.{yml,yaml}",
                ["https://json.schemastore.org/github-action.json"]   = ".github/actions/**/*.{yml,yaml}",
                ["https://json.schemastore.org/docker-compose.json"]  = "docker-compose*.{yml,yaml}",
                ["https://json.schemastore.org/kustomization.json"]   = "kustomization.{yml,yaml}",
              },
              validate = true, completion = true, hover = true,
            },
          },
        },

        -- ── Mojo ─────────────────────────────────────────────────────────────
        mojo = {
          cmd       = { "mojo-lsp" },
          filetypes = { "mojo" },
          root_dir  = require("lspconfig.util").find_git_ancestor,
        },
      },
    },
  },

  -- ── Treesitter parsers ────────────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "swift", "c_sharp", "zig", "bash", "dockerfile",
        "hcl", "helm", "yaml", "json", "toml", "sql",
        "markdown", "markdown_inline", "nix", "regex",
        "comment", "git_config", "gitignore", "gitcommit",
        "diff", "make",
      })
    end,
  },

  -- ── Filetype registration ─────────────────────────────────────────────────────
  {
    "LazyVim/LazyVim",
    opts = function()
      vim.filetype.add({
        extension = { carbon = "carbon", mojo = "mojo", ["🔥"] = "mojo" },
      })
    end,
  },
}