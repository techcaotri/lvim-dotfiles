-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- lvim.log.level="debug"

require("custom.plugins")
require("custom.config.lualine")
require("custom.config.nvim-tree")
require("custom.config.telescope")
require("custom.config.which-key")
require("custom.config.keymappings")
require("custom.config.toggleterm")
require("custom.config.syntax")
require("custom.config.alpha")
require("custom.config.lsp")
require("custom.config.project")
require("custom.config.dap")

-- require("custom.config.lspsaga-settings.test")

vim.opt.relativenumber = true
lvim.colorscheme = "newpaper"

lvim.builtin.mason.ensure_installed = {
  "bashls",
  "clangd",
  "cmake-language-server",
  "cssls",
  "flake8",
  "html",
  "isort",
  "jsonls",
  "prettierd",
  "pyright",
  "shellcheck",
  "shfmt",
  "stylua",
  "sumneko_lua",
  "tsserver",
  "yamlls",
}

vim.b.navic_lazy_update_context = true
-- Disable default breadcrumbs and use the one from LspSaga instead.
lvim.builtin.breadcrumbs.active = false

-- Always start 'flash.nvim' when opening file
require('custom.config.autocmd').autocmd({ "BufNewFile", "BufRead" }, {
  callback = function()
    require("flash").toggle(true)
  end
})

-- bypass null-ls warning, refer to https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match("warning: multiple different client offset_encodings") then
    return
  end

  notify(msg, ...)
end

local rainbow_delimiters = require 'rainbow-delimiters'
vim.g.rainbow_delimiters = {
  ---Query names by file type
  query = {
    ['']       = 'rainbow-delimiters',
    javascript = 'rainbow-delimiters-react'
  },
  ---Highlight strategies by file type
  strategy = {
    [''] = require 'rainbow-delimiters.strategy.global',
  },
  ---Event logging settings
  log = {
    ---Log level of the module, see `:h log_levels`.
    level = vim.log.levels.WARN,
    ---File name of the log file
    file  = vim.fn.stdpath('log') .. '/rainbow-delimiters.log',
  },
  -- Highlight groups in order of display
  highlight = {
    -- The colours are intentionally not in the usual order to make
    -- the contrast between them stronger
    'RainbowDelimiterYellow',
    'RainbowDelimiterBlue',
    'RainbowDelimiterGreen',
    'RainbowDelimiterViolet',
    'RainbowDelimiterCyan',
  }
}

-- Prevent auto add // comment after adding newline at the statement with comment at the end
-- vim.opt_local.formatoptions:remove({ 'r', 'o' })
vim.opt.formatoptions:append('/')

-- Add header author's name and email
vim.g.header_field_author = 'Tri Pham'
vim.g.header_field_author_email = 'techcaotri@gmail.com'
