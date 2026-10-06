local map = vim.keymap.set

-- jk / kj to escape insert mode
map("i", "jk", "<Esc>", { desc = "Escape insert mode" })
map("i", "kj", "<Esc>", { desc = "Escape insert mode" })

-- Move lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move line down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move line up" })

-- Alt-j/k to move lines in normal mode
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })

-- Keep cursor centered on scroll/search
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")

-- Paste without losing register in visual mode
map("x", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- Delete without yanking
map({ "n", "v" }, "<A-d>", [["_d]], { desc = "Delete without yank" })

-- Quick save
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Save file" })

-- LazyGit float
map("n", "<leader>gg", function()
  Snacks.terminal("lazygit", { cwd = LazyVim.root(), esc_esc = false, ctrl_hjkl = false })
end, { desc = "Lazygit (root)" })

-- Dev Containers via the official CLI and Podman
local function devcontainer_terminal(subcommand, command)
  local root = LazyVim.root() or vim.fn.getcwd()
  local args = {
    "devcontainer",
    subcommand,
    "--docker-path",
    "podman",
    "--workspace-folder",
    root,
  }
  vim.list_extend(args, command or {})
  Snacks.terminal(args, { cwd = root, auto_close = false })
end

map("n", "<leader>cdu", function()
  devcontainer_terminal("up")
end, { desc = "Dev Container: start" })
map("n", "<leader>cdb", function()
  devcontainer_terminal("build")
end, { desc = "Dev Container: build" })
map("n", "<leader>cde", function()
  devcontainer_terminal("exec", { "sh" })
end, { desc = "Dev Container: shell" })

-- Undotree
map("n", "<leader>U", "<cmd>UndotreeToggle<CR>", { desc = "Undotree" })

-- Database UI
map("n", "<leader>D", "<cmd>DBUIToggle<CR>", { desc = "Database UI" })
