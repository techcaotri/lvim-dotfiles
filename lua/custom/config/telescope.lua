lvim.builtin.telescope.defaults.layout_strategy = 'horizontal'
lvim.builtin.telescope.defaults.layout_config = {
  width = 0.90, -- 0.90,
  height = 0.65,
  preview_width = 0.4,
}

local ok, telescope = pcall(require, "telescope")
if not ok then return end

telescope.setup({
  pickers = {
    find_files = {
      entry_maker = require('custom.config.telescope-custom').file_displayer(),
    },
    oldfiles = {
      entry_maker = require('custom.config.telescope-custom').file_displayer(),
    },
    git_files = {
      entry_maker = require('custom.config.telescope-custom').file_displayer(),
    },
  },
})
