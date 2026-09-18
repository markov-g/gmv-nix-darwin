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
    -- Nix currently provides roslyn-ls 5.7.x. Keep the plugin on the
    -- compatible pre-5.12 server integration until the Nix package catches up.
    commit = "de9a98d61ed3fd01b5016eea5fe9e32f1a4c7cfb",
    ft = { "cs", "razor" },
    opts = {
      broad_search = true,
      -- Roslyn 5.7 can recurse in its FileSystemWatcher on macOS and abort.
      filewatching = "off",
    },
    config = function(_, opts)
      local function resolve_command()
        local configured = vim.env.NVIM_ROSLYN_LS
        if configured and vim.fn.executable(configured) == 1 then
          return configured
        end

        -- roslyn-ls from Nix exposes the Microsoft.CodeAnalysis.LanguageServer
        -- executable. Keep the other names as compatibility fallbacks.
        for _, name in ipairs({
          "Microsoft.CodeAnalysis.LanguageServer",
          "roslyn-language-server",
          "roslyn-ls",
        }) do
          local command = vim.fn.exepath(name)
          if command ~= "" then
            return command
          end
        end
      end

      local function command_args(command)
        return {
          command,
          "--logLevel=Information",
          "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
          "--stdio",
        }
      end

      local command = resolve_command()

      if not command then
        vim.notify(
          "Roslyn language server is not on PATH. Launch Neovim from the project direnv environment and restart it.",
          vim.log.levels.ERROR
        )
        return
      end

      vim.lsp.config("roslyn", {
        cmd = command_args(command),
        on_new_config = function(new_config)
          local current = resolve_command()
          if current then
            new_config.cmd = command_args(current)
          end
        end,
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
