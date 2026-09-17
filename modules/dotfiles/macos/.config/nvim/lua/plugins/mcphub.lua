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
      shutdown_delay = 300000,
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
      local variables = {
        "ATLASSIAN_TOKEN",
        "GITLAB_PERSONAL_ACCESS_TOKEN",
        "POLARION_API_TOKEN",
      }
      local global_env = {}
      local missing = {}

      for _, variable in ipairs(variables) do
        local value = vim.env[variable]
        if value and value ~= "" then
          global_env[variable] = value
        else
          table.insert(missing, variable)
        end
      end

      if #missing > 0 then
        vim.notify(
          "MCPHub cannot see exported environment variables: "
            .. table.concat(missing, ", "),
          vim.log.levels.WARN
        )
      end

      opts = vim.deepcopy(opts)
      opts.config = vim.fn.expand("~/.config/mcphub/servers.json")
      opts.global_env = global_env
      require("mcphub").setup(opts)
    end,
  },
}
