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

vim.opt.relativenumber = true
lvim.colorscheme =  "newpaper"

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

-- require("lspconfig").ccls.setup({
-- 	cmd = { "ccls" },
-- 	filetypes = { "c", "cc", "cpp", "objc", "objcpp" },
-- })

-- bypass null-ls warning, refer to https://github.com/jose-elias-alvarez/null-ls.nvim/issues/428
local notify = vim.notify
vim.notify = function(msg, ...)
  if msg:match("warning: multiple different client offset_encodings") then
    return
  end

  notify(msg, ...)
end
