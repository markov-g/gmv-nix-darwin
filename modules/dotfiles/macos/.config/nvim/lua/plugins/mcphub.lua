return {
  {
    "mcphub.nvim",
    url = "https://github.com/ravitemer/mcphub.nvim.git",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    build = "bundled_build.lua",
    opts = {
      use_bundled_binary = true,
      config = vim.fn.expand("~/.config/mcphub/servers.json"),
      shutdown_delay = 0,
      auto_approve = false,
      auto_toggle_mcp_servers = false,
      workspace = {
        enabled = true,
        look_for = {
          ".mcphub/servers.json",
          ".vscode/mcp.json",
          ".cursor/mcp.json",
        },
      },
    },
    config = function(_, opts)
      local source = vim.fn.expand("~/.config/mcphub/servers.json")
      if vim.fn.filereadable(source) ~= 1 then
        vim.notify("MCPHub config is missing: " .. source, vim.log.levels.ERROR)
        return
      end
      local lines = vim.fn.readfile(source)
      if #lines == 0 then
        vim.notify("MCPHub config is empty or missing: " .. source, vim.log.levels.ERROR)
        return
      end

      local ok, config = pcall(vim.json.decode, table.concat(lines, "\n"))
      if not ok or type(config) ~= "table" then
        vim.notify("MCPHub config is not valid JSON: " .. source, vim.log.levels.ERROR)
        return
      end

      local required = {
        ["atlassian-mcp"] = "ATLASSIAN_TOKEN",
        ["gitlab-csc-read"] = "GITLAB_PERSONAL_ACCESS_TOKEN",
        polarion = "POLARION_API_TOKEN",
      }
      local missing = {}

      for server, variable in pairs(required) do
        local value = vim.env[variable]
        if not value or value == "" then
          missing[variable] = true
          if config.mcpServers then
            config.mcpServers[server] = nil
          end
        end
      end

      local function expand(value)
        if type(value) == "string" then
          return (value:gsub("%${([%w_]+)}", function(variable)
            return vim.env[variable] or "${" .. variable .. "}"
          end))
        elseif type(value) == "table" then
          for key, item in pairs(value) do
            value[key] = expand(item)
          end
        end
        return value
      end

      config = expand(config)

      if next(missing) then
        local names = {}
        for variable in pairs(missing) do
          table.insert(names, variable)
        end
        table.sort(names)
        vim.notify(
          "MCPHub disabled servers with missing environment variables: "
            .. table.concat(names, ", "),
          vim.log.levels.WARN
        )
      end

      local temp = vim.fn.tempname()
      local encoded = vim.json.encode(config)
      vim.fn.writefile(vim.split(encoded, "\n", { plain = true }), temp)
      vim.fn.setfperm(temp, "rw-------")

      vim.api.nvim_create_autocmd("VimLeavePre", {
        once = true,
        callback = function()
          vim.fn.delete(temp)
        end,
      })

      opts = vim.deepcopy(opts)
      opts.config = temp
      require("mcphub").setup(opts)
    end,
  },
}
