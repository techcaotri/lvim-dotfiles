local M = {}

M.dependencies = {
  "zbirenbaum/copilot-cmp",
}

function M.config()
  require("copilot").setup({
    suggestion = {
      enable = false,
    },
    panel = {
      enable = false,
    },
  })
  require("copilot_cmp").setup()
end

return M
