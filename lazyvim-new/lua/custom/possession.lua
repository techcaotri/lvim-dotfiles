-- Custom possession save prompt (ported from custom/config/possession.lua).
-- Lets you save the session under the current dir's basename, "tmp", or a new name.
local M = {}

function M.possession_save()
  local cwd = vim.fn.getcwd()
  local base = vim.fn.fnamemodify(cwd, ":t")
  local choices = { base, "tmp", "(new name...)" }
  vim.ui.select(choices, { prompt = "Save session as:" }, function(choice)
    if not choice then
      return
    end
    if choice == "(new name...)" then
      vim.ui.input({ prompt = "Session name: " }, function(name)
        if name and name ~= "" then
          vim.cmd("PossessionSave! " .. name)
        end
      end)
    else
      vim.cmd("PossessionSave! " .. choice)
    end
  end)
end

return M
