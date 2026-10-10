return {
  {
    "nvim-orgmode/orgmode",
    event = "VeryLazy",
    ft = { "org" },
    config = function()
      require("orgmode").setup({
        org_agenda_files = "~/orgfiles/**/*",
        org_default_notes_file = "~/orgfiles/refile.org",
      })

      -- NOTE: orgmode's own README labels `vim.lsp.enable("org")` as
      -- "Experimental LSP support" (go-to-definition/folding for org files).
      -- Deliberately left out for now -- add it here if wanted later.
    end,
  },
}
