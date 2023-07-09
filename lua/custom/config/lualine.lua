-- See: https://github.com/hoob3rt/lualine.nvim

-- Configuration {{{1

-- Settings {{{2
-- Eviline config for lualine
-- Author: shadmansaleh
-- Credit: glepnir

lvim.builtin.lualine.style = "lvim"
lvim.builtin.lualine.sections.lualine_a = { "mode" }

vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = 'visual_multi_start',
  callback = function()
    vim.g.VM_set_statusline = 2
    require('lualine').hide()
  end
})

vim.api.nvim_create_autocmd({ 'User' }, {
  pattern = 'visual_multi_exit',
  callback = function()
    vim.opt.laststatus = 2
    require('lualine').hide({ unhide = true })
  end
})
