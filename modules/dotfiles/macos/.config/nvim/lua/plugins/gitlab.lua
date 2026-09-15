return {
  {
    "gitlab.vim",
    url = "https://gitlab.com/gitlab-org/editor-extensions/gitlab.vim.git",
    event = "VeryLazy",
    config = function()
      require("gitlab").setup({
        glab = {
          enabled = true,
        },
        statusline = {
          enabled = false,
        },
        minimal_message_level = vim.log.levels.ERROR,
      })
    end,
  },
}
