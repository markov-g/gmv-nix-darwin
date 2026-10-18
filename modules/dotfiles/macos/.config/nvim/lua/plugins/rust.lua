-- Deltas found comparing this config against letsgetrusty/neovim-rust
-- (an NvChad-based Rust setup). Everything else it configures --
-- rustaceanvim, crates.nvim, codelldb DAP, neotest-rust-equivalent --
-- is already provided by LazyVim's own `lang.rust` extra (imported in
-- config/lazy.lua), confirmed against LazyVim's actual rust.lua source.
-- Only these two pieces were genuinely new:

return {
  -- ── rustaceanvim: testables keymap ───────────────────────────────────────
  -- LazyVim's lang.rust extra already binds <leader>cR (codeAction) and
  -- <leader>dr (debuggables) via its own on_attach function. This chains
  -- an additional <leader>dt -> RustLsp testables onto whatever on_attach
  -- is already set, rather than replacing it -- lazy.nvim's opts deep-merge
  -- can't merge two function values, so a naive second on_attach here would
  -- have silently clobbered LazyVim's keymaps instead of adding to them.
  {
    "mrcjkb/rustaceanvim",
    opts = function(_, opts)
      opts.server = opts.server or {}
      local prior_on_attach = opts.server.on_attach
      opts.server.on_attach = function(client, bufnr)
        if prior_on_attach then
          prior_on_attach(client, bufnr)
        end
        vim.keymap.set("n", "<leader>dt", function()
          vim.cmd.RustLsp("testables")
        end, { desc = "Rust Testables", buffer = bufnr })
      end
      return opts
    end,
  },

  -- ── conform.nvim: explicit rustfmt ───────────────────────────────────────
  -- Neither our lsp.lua nor LazyVim's lang.rust extra register a formatter
  -- for Rust. In practice this repo's dotnet.lua already sets conform's
  -- global `default_format_opts.lsp_format = "fallback"`, so Rust saves were
  -- very likely already being formatted via rust-analyzer's own built-in
  -- rustfmt integration (LSP fallback) even without this entry -- this
  -- isn't confirmed to have been a real gap. Making it explicit here (the
  -- direct conform -> rustfmt path, matching letsgetrusty/neovim-rust's
  -- rust.vim rustfmt_autosave) costs nothing and documents the choice
  -- instead of leaving it implicit in a .NET-motivated global fallback.
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.rust = { "rustfmt" }
      return opts
    end,
  },
}
