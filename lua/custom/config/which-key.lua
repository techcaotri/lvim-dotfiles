lvim.builtin.which_key.setup.plugins.marks = true
lvim.builtin.which_key.setup.plugins.registers = true
lvim.builtin.which_key.setup.plugins.presets.operators = false
lvim.builtin.which_key.setup.plugins.presets.motions = true
lvim.builtin.which_key.setup.plugins.presets.text_objects = true
lvim.builtin.which_key.setup.plugins.presets.windows = true
lvim.builtin.which_key.setup.plugins.presets.nav = true
lvim.builtin.which_key.setup.plugins.presets.z = true
lvim.builtin.which_key.setup.plugins.presets.g = true
lvim.builtin.which_key.setup.window.padding = { 1, 2, 1, 2 }
lvim.builtin.which_key.setup.ignore_missing = false

lvim.builtin.which_key.setup.operators = {
  d = "Delete",
  c = "Change",
  y = "Yank (copy)",
  ["g~"] = "Toggle case",
  ["gu"] = "Lowercase",
  ["gU"] = "Uppercase",
  [">"] = "Indent right",
  ["<lt>"] = "Indent left",
  ["zf"] = "Create fold",
  ["!"] = "Filter though external program",
}

vim.o.timeout = true
vim.o.timeoutlen = 250


-- lvim.builtin.which_key.on_config_done = function ()
-- local keymaps = vim.api.nvim_get_keymap("n")
-- local Log = require "lvim.core.log"
-- Log:debug "abcd"
-- print(vim.inspect(keymaps))
-- Log:debug(vim.inspect(keymaps))
-- for _, keymap in pairs(keymaps) do
--   if keymap ~= nil then
--     Log:debug(keymap.lhs)
--   end
-- end
-- end
