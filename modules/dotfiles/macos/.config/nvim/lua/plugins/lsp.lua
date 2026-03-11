-- ─────────────────────────────────────────────────────────────────────────────
--  Extra LSP configs for languages not yet in LazyVim's extras:
--    Swift · .NET/C# · Mojo · Carbon · Bash · GitHub Actions · GitLab CI
-- ─────────────────────────────────────────────────────────────────────────────
return {
  -- ── Mason: ensure these servers/tools are installed ──────────────────────────
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      -- Only list tools NOT already installed by LazyVim language extras.
      -- Extras already handle: bash-language-server, shfmt, yaml-language-server,
      -- marksman, markdownlint, hadolint, nil, stylua, etc.
      vim.list_extend(opts.ensure_installed, {
        -- .NET / C#
        "omnisharp",
        -- Shell
        "shellcheck",
        -- SQL
        "sqlfluff",
        -- Nix
        "nixpkgs-fmt",
      })
    end,
  },

  -- ── nvim-lspconfig: extra server configs ─────────────────────────────────────
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {

        -- ── Swift (sourcekit-lsp ships with Xcode CLT) ────────────────────────
        -- Install: xcode-select --install  OR  brew install sourcekit-lsp
        sourcekit = {
          cmd      = { "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("Package.swift", "*.xcodeproj", "*.xcworkspace")(fname)
              or util.find_git_ancestor(fname)
          end,
          settings = {},
        },

        -- ── .NET / C# (OmniSharp) ─────────────────────────────────────────────
        -- Install via Mason: :MasonInstall omnisharp
        omnisharp = {
          cmd = { "omnisharp" },
          filetypes = { "cs", "vb" },
          settings = {
            FormattingOptions = { EnableEditorConfigSupport = true },
            MsBuild           = { LoadProjectsOnDemand = false },
            RoslynExtensionsOptions = { EnableAnalyzersSupport = true },
          },
        },

        -- ── Bash / Shell ──────────────────────────────────────────────────────
        bashls = {
          filetypes = { "sh", "bash", "zsh" },
          settings  = { bashIde = { globPattern = "**/*@(.sh|.inc|.bash|.command|.zsh)" } },
        },

        -- ── YAML with schema injection ────────────────────────────────────────
        -- GitHub Actions, GitLab CI, k8s, Helm — schemas auto-resolved via
        -- schemastore.nvim (bundled with the yaml LazyVim extra)
        yamlls = {
          settings = {
            yaml = {
              schemas = {
                -- GitHub Actions
                ["https://json.schemastore.org/github-workflow.json"]        = ".github/workflows/*.{yml,yaml}",
                ["https://json.schemastore.org/github-action.json"]          = ".github/actions/**/*.{yml,yaml}",
                -- GitLab CI
                ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = ".gitlab-ci.{yml,yaml}",
                -- Docker Compose
                ["https://json.schemastore.org/docker-compose.json"]         = "docker-compose*.{yml,yaml}",
                -- Kubernetes
                ["https://json.schemastore.org/kustomization.json"]          = "kustomization.{yml,yaml}",
              },
              validate  = true,
              completion = true,
              hover     = true,
            },
          },
        },

        -- ── Mojo (Modular) ────────────────────────────────────────────────────
        -- Install: modular install mojo  →  adds `mojo-lsp` to PATH
        -- If mojo-lsp is not installed this silently does nothing.
        mojo = {
          cmd      = { "mojo-lsp" },
          filetypes = { "mojo" },
          root_dir  = require("lspconfig.util").find_git_ancestor,
        },
      },
    },
  },

  -- ── Treesitter: extra parsers ─────────────────────────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "swift",        -- Swift
        "c_sharp",      -- C# / .NET
        "zig",          -- Zig
        "bash",         -- Bash / shell scripts
        "dockerfile",   -- Dockerfile
        "hcl",          -- Terraform / HCL
        "helm",         -- Helm templates
        "yaml",         -- YAML (GitHub Actions, k8s, etc.)
        "json",         -- JSON
        "toml",         -- TOML / Cargo.toml
        "sql",          -- SQL
        "markdown",     -- Markdown
        "markdown_inline",
        "nix",          -- Nix
        "regex",        -- Regex highlighting inside strings
        "comment",      -- TODO / FIXME / HACK highlighting
        "git_config",   -- .gitconfig
        "gitignore",    -- .gitignore
        "gitcommit",    -- commit messages
        "diff",         -- diff files
        "make",         -- Makefile
      })
    end,
  },

  -- ── Filetype detection for Carbon (.carbon) ────────────────────────────────
  -- Carbon LSP (carbon-ls) is not yet widely available; add treesitter detection
  -- when Carbon Grammar matures. For now we register the filetype so other tools
  -- (formatter, linter) can pick it up when available.
  {
    "LazyVim/LazyVim",
    opts = function()
      vim.filetype.add({
        extension = {
          carbon = "carbon",
          mojo   = "mojo",
          ["🔥"]  = "mojo",
        },
      })
    end,
  },
}
