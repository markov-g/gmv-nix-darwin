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
      global_env = {
        "POLARION_API_TOKEN",
        "ATLASSIAN_TOKEN",
        "GITLAB_PERSONAL_ACCESS_TOKEN",
      },
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
