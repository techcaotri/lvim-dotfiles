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
  -- Disable clangd by default to run it concurrently with ccls
  require("clangd_extensions").setup {
    server = { autostart = false },
  }
end

return M
