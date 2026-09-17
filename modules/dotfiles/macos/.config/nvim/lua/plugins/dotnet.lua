return {
  -- The LazyVim dotnet extra configures OmniSharp. Roslyn owns C# LSP
  -- startup here instead.
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
    enabled = false,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        omnisharp = { enabled = false },
        fsautocomplete = { enabled = false },
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    ft = { "cs", "razor" },
    opts = {
      broad_search = true,
      filewatching = "roslyn",
    },
    config = function(_, opts)
      local command = vim.fn.exepath("Microsoft.CodeAnalysis.LanguageServer")
      if command == "" then
        command = vim.fn.exepath("roslyn-language-server")
      end
      if command == "" then
        command = vim.fn.exepath("roslyn-ls")
      end

      if command == "" then
        vim.notify(
          "Roslyn language server is not on PATH. Launch Neovim from the shellnix direnv environment and restart it.",
          vim.log.levels.ERROR
        )
        return
      end

      vim.lsp.config("roslyn", {
        cmd = { command, "--stdio" },
      })
      require("roslyn").setup(opts)
    end,
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.default_format_opts = opts.default_format_opts or {}
      opts.default_format_opts.lsp_format = "fallback"
      return opts
    end,
  },
}
