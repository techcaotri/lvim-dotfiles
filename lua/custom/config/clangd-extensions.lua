local M = {}

M.filetype = {
  "c",
  "cpp",
  "cc",
  "cxx",
}

M.dependencies = {
  "neovim/nvim-lspconfig",
}

function M.config(client, bufnr)
  require("clangd_extensions").setup {
    server = { autostart = true },
  }
end

return M
