local function resolve_roslyn_command()
  local configured = vim.env.NVIM_ROSLYN_LS
  if configured and vim.fn.executable(configured) == 1 then
    return configured
  end

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

local function roslyn_cmd(dispatchers, config)
  local command = resolve_roslyn_command()
  if not command then
    error("Microsoft.CodeAnalysis.LanguageServer is not executable in Neovim's PATH")
  end

  return vim.lsp.rpc.start({
    command,
    "--logLevel=Information",
    "--extensionLogDirectory=" .. vim.fs.dirname(vim.lsp.log.get_filename()),
    "--stdio",
  }, dispatchers, {
    cwd = config.cmd_cwd,
    env = config.cmd_env,
    detached = config.detached,
  })
end

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
        roslyn = {
          mason = false,
          cmd = roslyn_cmd,
          filetypes = { "cs", "razor" },
        },
      },
    },
  },
  {
    "seblyng/roslyn.nvim",
    -- Nix currently provides roslyn-ls 5.6.x. Keep the plugin on the
    -- compatible pre-5.12 server integration until the Nix package catches up.
    commit = "de9a98d61ed3fd01b5016eea5fe9e32f1a4c7cfb",
    ft = { "cs", "razor" },
    opts = {
      broad_search = true,
      -- Roslyn 5.6/5.7 can recurse in its FileSystemWatcher on macOS and abort.
      filewatching = "off",
    },
    config = function(_, opts)
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
