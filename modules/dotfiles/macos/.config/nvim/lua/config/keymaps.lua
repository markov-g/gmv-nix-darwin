-- Custom keymaps layered on top of LazyVim defaults
-- https://www.lazyvim.org/configuration/keymaps
local map = vim.keymap.set

-- ── Escape ────────────────────────────────────────────────────────────────────
map("i", "jk", "<ESC>",   { desc = "Exit insert mode (jk)" })
map("i", "kj", "<ESC>",   { desc = "Exit insert mode (kj)" })

-- ── Move lines up/down with Alt-j/k ───────────────────────────────────────────
map("n", "<A-j>", "<cmd>m .+1<cr>==",       { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==",       { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi",{ desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi",{ desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv",       { desc = "Move selection down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv",       { desc = "Move selection up" })

-- ── Better paste (don't yank replaced text in visual mode) ────────────────────
map("v", "p", '"_dP', { desc = "Paste without yanking replaced text" })

-- ── Navigate quickfix / location list ─────────────────────────────────────────
map("n", "[q", "<cmd>cprev<cr>", { desc = "Prev quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })

-- ── LazyGit ───────────────────────────────────────────────────────────────────
map("n", "<leader>gg", function()
  require("lazygit").lazygit()
end, { desc = "LazyGit (float)" })

-- ── Database UI ───────────────────────────────────────────────────────────────
map("n", "<leader>D", "<cmd>DBUIToggle<cr>", { desc = "Database UI" })

-- ── Undo tree ─────────────────────────────────────────────────────────────────
map("n", "<leader>u", "<cmd>UndotreeToggle<cr>", { desc = "Undo Tree" })

-- ── Avante AI assistant (see ai.lua) ─────────────────────────────────────────
-- <leader>aa  Ask AI
-- <leader>ae  Edit with AI
-- <leader>ar  Refresh AI

-- ── Harpoon (via LazyVim extra) ───────────────────────────────────────────────
-- <leader>h   Add file to harpoon
-- <C-e>       Toggle harpoon menu

-- ── Window/pane movement matching tmux (vim-tmux-navigator) ──────────────────
-- C-h/j/k/l  Move across vim splits AND tmux panes seamlessly

-- ── Misc ──────────────────────────────────────────────────────────────────────
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location list" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })
