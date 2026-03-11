-- Custom options layered on top of LazyVim defaults
-- https://www.lazyvim.org/configuration/general
local opt = vim.opt

-- ── Editor feel ───────────────────────────────────────────────────────────────
opt.relativenumber  = true      -- relative line numbers (great for jump motions)
opt.scrolloff       = 8         -- keep 8 lines above/below cursor
opt.sidescrolloff   = 8
opt.wrap            = false     -- don't wrap long lines
opt.colorcolumn     = "120"     -- soft line-length guide at col 120
opt.cursorcolumn    = false

-- ── Clipboard ─────────────────────────────────────────────────────────────────
opt.clipboard = "unnamedplus"   -- always use system clipboard

-- ── Indentation ───────────────────────────────────────────────────────────────
opt.tabstop    = 2
opt.shiftwidth = 2
opt.expandtab  = true
opt.smartindent = true

-- ── Search ────────────────────────────────────────────────────────────────────
opt.ignorecase = true
opt.smartcase  = true
opt.hlsearch   = false

-- ── Splits ────────────────────────────────────────────────────────────────────
opt.splitright = true
opt.splitbelow = true

-- ── Persistent undo ───────────────────────────────────────────────────────────
opt.undofile   = true
opt.undolevels = 10000

-- ── Completion ────────────────────────────────────────────────────────────────
opt.pumheight = 12              -- max autocomplete popup height
opt.pumblend  = 10              -- slight transparency on popup

-- ── Misc ─────────────────────────────────────────────────────────────────────
opt.confirm        = true       -- confirm instead of error on unsaved-quit
opt.virtualedit    = "block"    -- allow cursor anywhere in visual block mode
opt.smoothscroll   = true       -- smooth scrolling (Neovim 0.10+)
opt.foldlevel      = 99         -- start with all folds open
opt.foldmethod     = "expr"
opt.foldexpr       = "nvim_treesitter#foldexpr()"
