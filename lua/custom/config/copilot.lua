local M = {}

M.dependencies = {
  -- "zbirenbaum/copilot-cmp",
  -- "copilot-cmp",
  -- dir = "/home/tripham/Dev/Playground_Terminal/Neovim_Awesome/copilot-cmp",
}

function M.config()
  require("copilot").setup({
    suggestion = {
      enable = true,
      auto_trigger = true,
    },
    panel = {
      enable = true,
    },
  })
  -- require("copilot_cmp").setup()
end

return M
