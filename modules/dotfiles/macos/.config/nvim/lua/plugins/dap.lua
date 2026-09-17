local function executable(name)
  local path = vim.fn.exepath(name)
  return path ~= "" and path or nil
end

local function project_root()
  return (LazyVim.root and LazyVim.root()) or vim.fn.getcwd()
end

local function select_program(prompt)
  return function()
    local path = vim.fn.input({
      prompt = prompt,
      default = project_root() .. "/",
      completion = "file",
    })

    if path == "" then
      return require("dap").ABORT
    end

    return vim.fn.fnamemodify(path, ":p")
  end
end

local function copy(value)
  return vim.deepcopy(value)
end

return {
  {
    "mfussenegger/nvim-dap",
    opts = function(_, opts)
      local dap = require("dap")
      local pick_process = require("dap.utils").pick_process

      local netcoredbg = executable("netcoredbg")
      if netcoredbg then
        dap.adapters.coreclr = {
          type = "executable",
          command = netcoredbg,
          args = { "--interpreter=vscode" },
        }

        dap.configurations.cs = {
          {
            name = ".NET: launch DLL",
            type = "coreclr",
            request = "launch",
            program = select_program("Debug DLL: "),
            cwd = project_root,
            stopAtEntry = false,
            console = "integratedTerminal",
          },
          {
            name = ".NET: attach",
            type = "coreclr",
            request = "attach",
            processId = pick_process,
          },
        }
      else
        vim.notify("netcoredbg is not on PATH; C# DAP is unavailable", vim.log.levels.WARN)
      end

      local lldb_dap = executable("lldb-dap") or executable("lldb-vscode")
      if lldb_dap then
        dap.adapters.lldb = {
          type = "executable",
          command = lldb_dap,
          name = "lldb",
        }

        local native = {
          {
            name = "Native: launch executable",
            type = "lldb",
            request = "launch",
            program = select_program("Executable: "),
            cwd = project_root,
            stopOnEntry = false,
            args = {},
          },
          {
            name = "Native: attach",
            type = "lldb",
            request = "attach",
            pid = pick_process,
          },
        }

        for _, filetype in ipairs({ "c", "cpp", "rust", "zig" }) do
          dap.configurations[filetype] = copy(native)
        end
      else
        vim.notify(
          "lldb-dap/lldb-vscode is not on PATH; native DAP is unavailable",
          vim.log.levels.WARN
        )
      end

      local swift_xcrun = "/usr/bin/xcrun"
      if vim.fn.executable(swift_xcrun) == 1 then
        dap.adapters.swift_lldb = {
          type = "executable",
          command = swift_xcrun,
          args = { "lldb-dap" },
          name = "Swift LLDB",
        }

        dap.configurations.swift = {
          {
            name = "Swift: launch macOS executable",
            type = "swift_lldb",
            request = "launch",
            program = select_program("Swift executable: "),
            cwd = project_root,
            stopOnEntry = false,
            args = {},
          },
          {
            name = "Swift: attach",
            type = "swift_lldb",
            request = "attach",
            pid = pick_process,
          },
        }
      end

      return opts
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local python = vim.env.NVIM_DEBUGPY_PYTHON
      if not python or vim.fn.executable(python) ~= 1 then
        vim.notify(
          "NVIM_DEBUGPY_PYTHON is missing; launch Neovim from the shellnix direnv environment",
          vim.log.levels.WARN
        )
        return
      end

      require("dap-python").setup(python)
    end,
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    opts = {},
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    opts = {},
  },
}
