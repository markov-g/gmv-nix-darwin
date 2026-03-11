-- Custom autocmds layered on top of LazyVim defaults
local function augroup(name)
  return vim.api.nvim_create_augroup("user_" .. name, { clear = true })
end

-- Highlight yanked text briefly
vim.api.nvim_create_autocmd("TextYankPost", {
  group    = augroup("highlight_yank"),
  callback = function() vim.highlight.on_yank({ higroup = "IncSearch", timeout = 150 }) end,
})

-- Resize splits when the terminal window is resized
vim.api.nvim_create_autocmd("VimResized", {
  group    = augroup("resize_splits"),
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- Auto-close certain filetypes with q
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("close_with_q"),
  pattern = { "help", "lspinfo", "man", "notify", "qf", "spectre_panel",
              "startuptime", "tsplayground", "neotest-output", "checkhealth",
              "neotest-summary", "neotest-output-panel" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})

-- Wrap + spell in text-heavy files
vim.api.nvim_create_autocmd("FileType", {
  group   = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown", "text", "rst", "norg" },
  callback = function()
    vim.opt_local.wrap  = true
    vim.opt_local.spell = true
  end,
})

-- Set Nix files to use 2-space indentation
vim.api.nvim_create_autocmd("FileType", {
  group    = augroup("nix_indent"),
  pattern  = "nix",
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab  = true
  end,
})
