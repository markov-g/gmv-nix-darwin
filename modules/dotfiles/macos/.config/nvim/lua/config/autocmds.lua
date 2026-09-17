local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("YankHighlight", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Resize splits on terminal resize
autocmd("VimResized", {
  group = augroup("ResizeSplits", { clear = true }),
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- Close certain buffers with q
autocmd("FileType", {
  group = augroup("CloseWithQ", { clear = true }),
  pattern = { "help", "qf", "man", "notify", "lspinfo", "checkhealth" },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- Wrap + spell for prose filetypes
autocmd("FileType", {
  group = augroup("ProseSettings", { clear = true }),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.wrap  = true
    vim.opt_local.spell = true
  end,
})

-- 2-space indent for Nix files
autocmd("FileType", {
  group = augroup("NixIndent", { clear = true }),
  pattern = { "nix" },
  callback = function()
    vim.opt_local.tabstop    = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.expandtab  = true
  end,
})

-- Use FzfLua for LSP navigation, with a definition fallback when a server
-- does not implement declarations (common for C# and Python).
autocmd("LspAttach", {
  group = augroup("FzfLspNavigation", { clear = true }),
  callback = function(event)
    local function supports(method)
      for _, client in ipairs(vim.lsp.get_clients({ bufnr = event.buf })) do
        if client:supports_method(method, event.buf) then
          return true
        end
      end
      return false
    end

    local function navigate(method, picker)
      if not supports(method) then
        vim.notify("LSP does not support " .. method, vim.log.levels.INFO)
        return
      end
      require("fzf-lua")[picker]({ jump1 = true, ignore_current_line = true })
    end

    local function map(lhs, rhs, desc)
      vim.keymap.set("n", lhs, rhs, {
        buffer = event.buf,
        silent = true,
        desc = desc,
      })
    end

    map("gd", function()
      navigate("textDocument/definition", "lsp_definitions")
    end, "Goto Definition")

    map("gD", function()
      if supports("textDocument/declaration") then
        navigate("textDocument/declaration", "lsp_declarations")
      else
        navigate("textDocument/definition", "lsp_definitions")
      end
    end, "Goto Declaration or Definition")

    map("gr", function()
      navigate("textDocument/references", "lsp_references")
    end, "References")

    map("gI", function()
      navigate("textDocument/implementation", "lsp_implementations")
    end, "Goto Implementation")

    map("gy", function()
      navigate("textDocument/typeDefinition", "lsp_typedefs")
    end, "Goto Type Definition")
  end,
})
