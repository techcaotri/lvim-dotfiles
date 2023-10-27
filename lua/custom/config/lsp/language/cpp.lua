local filetypes = { "c", "cpp", "objc", "objcpp", "opencl" }
local server_config = {
  filetypes = filetypes,
  init_options = {
    compilationDatabaseDirectory = "./build/",
    cache = {
      directory = vim.fs.normalize "~/.cache/ccls/",
    }
  },
  name = "ccls",
  cmd = { "ccls" },
  offset_encoding = "utf-32",
  root_dir = vim.fs.dirname(
    vim.fs.find({ "compile_commands.json", "compile_flags.txt", ".git" }, { upward = true })[1]
  ),
}

-- Use clangd as the default language server for cpp types. Since ccls doesn't support inlayhints -> https://github.com/MaskRay/ccls/issues/932
-- Only utilize the callHierarchyProvider of ccls
require("ccls").setup {
  filetypes = filetypes,
  lsp = {
    server = server_config,
    disable_diagnostics = true,
    disable_signature = true,
    codelens = { enable = false },
    lspconfig = {
      autostart = true,
      cmd = { "ccls" },
      filetypes = { "c", "cc", "cpp", "objc", "objcpp" },
    }
  },
}

local clangd_flags = {
  "--background-index",
  "--all-scopes-completion",
  "--suggest-missing-includes",
  "--completion-style=detailed",
  "--enable-config",          -- clangd 11+ supports reading from .clangd configuration file
  "--offset-encoding=utf-16", --temporary fix for null-ls
}
local clangd_bin = "clangd"
require("lvim.lsp.manager").setup("clangd", {
  on_attach = function(client)
    client.server_capabilities.workspaceSymbolProvider = false
  end,
  cmd = { clangd_bin, unpack(clangd_flags) },
})

require("lvim.lsp.manager").setup("ccls", {
  on_attach = function(client)
    -- This list is copied from https://github.com/MaskRay/ccls/blob/ee2d4f5b9a2181e2c71341d34c7d2463f0c28cd1/src/messages/initialize.cc #L104
    -- textDocumentSync = true, -- Comment out since adding this will make 'ccls' stop working
    -- signatureHelpProvider = false, -- Comment out since adding this will make 'ccls' stop working
    -- callHierarchyProvider = true -- Comment out since adding this will make 'ccls' stop working
  end
})

-- require("clangd").setup {
--   on_attach = function (client)
--     client.server_capabilities.workspaceSymbolProvider = false
--   end
-- }
