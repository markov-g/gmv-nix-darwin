-- ─────────────────────────────────────────────────────────────────────────────
--  lazy.nvim bootstrap  +  LazyVim distribution
--  https://www.lazyvim.org  ·  https://github.com/folke/lazy.nvim
--
--  Languages configured:
--    Swift · .NET/C# · Python · Rust · Go · Java · Kotlin · Scala
--    C / C++ · Zig · SQL · Bash/sh · JSON · YAML · TOML · Markdown
--    Docker · Terraform/HCL · Kubernetes (helm/kustomize) · Nix
--    CI/CD (GitHub Actions, GitLab CI)  ·  Mojo* · Carbon* (via LSP)
--    (* Mojo/Carbon: not in LazyVim extras yet — manual LSP config in lsp.lua)
-- ─────────────────────────────────────────────────────────────────────────────

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({ { "Failed to clone lazy.nvim:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    vim.cmd("qa")
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- lockfile must be writable; ~/.config/nvim is a read-only nix store symlink
  lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json",
  spec = {
    -- ── LazyVim core ────────────────────────────────────────────────────────
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- ── Languages: mainstream ────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.lang.typescript" },  -- TypeScript / JavaScript
    { import = "lazyvim.plugins.extras.lang.python" },      -- Python (pyright + ruff)
    { import = "lazyvim.plugins.extras.lang.rust" },        -- Rust (rust-analyzer)
    { import = "lazyvim.plugins.extras.lang.go" },          -- Go (gopls)
    { import = "lazyvim.plugins.extras.lang.java" },        -- Java (jdtls)
    { import = "lazyvim.plugins.extras.lang.kotlin" },      -- Kotlin (kotlin-ls)
    { import = "lazyvim.plugins.extras.lang.scala" },       -- Scala (metals)
    { import = "lazyvim.plugins.extras.lang.clangd" },      -- C / C++ (clangd)

    -- ── Languages: systems / modern ──────────────────────────────────────────
    { import = "lazyvim.plugins.extras.lang.zig" },         -- Zig (zls)
    -- Swift: via lsp.lua (sourcekit-lsp, ships with Xcode)
    -- .NET/C#: via lsp.lua (OmniSharp / roslyn)
    -- Mojo: via lsp.lua (modular mojo-lsp — install via `modular install mojo`)
    -- Carbon: experimental, via lsp.lua

    -- ── Languages: data / config / markup ────────────────────────────────────
    { import = "lazyvim.plugins.extras.lang.json" },        -- JSON + JSON schema
    { import = "lazyvim.plugins.extras.lang.yaml" },        -- YAML + schema store
    { import = "lazyvim.plugins.extras.lang.toml" },        -- TOML
    { import = "lazyvim.plugins.extras.lang.sql" },         -- SQL (multiple dialects)
    { import = "lazyvim.plugins.extras.lang.markdown" },    -- Markdown + preview
    { import = "lazyvim.plugins.extras.lang.nix" },         -- Nix (nil_ls)

    -- ── Languages: DevOps / Infrastructure ───────────────────────────────────
    { import = "lazyvim.plugins.extras.lang.docker" },      -- Dockerfile / compose
    { import = "lazyvim.plugins.extras.lang.terraform" },   -- HCL / Terraform
    { import = "lazyvim.plugins.extras.lang.helm" },        -- Helm charts
    -- Kubernetes YAML: covered by yaml extra (schema store has k8s schemas)
    -- GitHub Actions / GitLab CI: YAML extra + custom treesitter (see lsp.lua)
    -- Bash/sh: built into LazyVim core (bashls + shfmt)

    -- ── Editor extras ────────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.editor.harpoon2" },  -- quick file marks
    { import = "lazyvim.plugins.extras.editor.telescope" }, -- fuzzy finder
    { import = "lazyvim.plugins.extras.editor.fzf" },       -- fzf-lua
    { import = "lazyvim.plugins.extras.editor.aerial" },    -- code outline / symbols

    -- ── DAP (debugger) ───────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.dap.core" },         -- DAP + UI + virtual text
    { import = "lazyvim.plugins.extras.dap.nlua" },         -- Lua debugger (neovim dev)

    -- ── Coding extras ────────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.coding.yanky" },          -- yank ring
    { import = "lazyvim.plugins.extras.coding.mini-surround" },  -- surround text objects
    { import = "lazyvim.plugins.extras.coding.luasnip" },        -- LuaSnip snippets

    -- ── Testing ──────────────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.test.core" },         -- neotest framework

    -- ── UI ───────────────────────────────────────────────────────────────────
    { import = "lazyvim.plugins.extras.ui.mini-animate" },   -- smooth scroll/cursor animations

    -- ── Custom plugins (lua/plugins/*.lua) ───────────────────────────────────
    { import = "plugins" },
  },
  defaults = { lazy = false, version = false },
  install  = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
  checker  = { enabled = true, notify = false },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})
