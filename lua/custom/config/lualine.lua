-- See: https://github.com/hoob3rt/lualine.nvim

local components = require("lvim.core.lualine.components")

local function possession_session()
  return require('possession.session').session_name or 'tmp'
end

lvim.builtin.lualine.style = "lvim"
lvim.builtin.lualine.sections.lualine_a = { "mode", }
lvim.builtin.lualine.sections.lualine_c = {
  components.diff,
  components.python_env,
  possession_session
}
lvim.builtin.lualine.sections.lualine_x = {
  components.diagnostics,
  components.lsp,
  components.spaces,
  components.encoding,
  components.filetype,
}

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
