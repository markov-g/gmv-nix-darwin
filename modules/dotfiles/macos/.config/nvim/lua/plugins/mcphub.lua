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
      global_env = function()
        local resolved = {}
        for _, name in ipairs({
          "POLARION_API_TOKEN",
          "ATLASSIAN_TOKEN",
          "GITLAB_PERSONAL_ACCESS_TOKEN",
        }) do
          local value = vim.env[name]
          if value and value ~= "" then
            resolved["input:" .. name] = value
          end
        end
        return resolved
      end,
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
  },
}
