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

require("lvim.lsp.manager").setup("clangd", {
  on_attach = function (client)
    client.server_capabilities.workspaceSymbolProvider = false
  end
})
require("lvim.lsp.manager").setup("ccls", {
  on_attach = function (client)
      -- This list is copied from https://github.com/MaskRay/ccls/blob/ee2d4f5b9a2181e2c71341d34c7d2463f0c28cd1/src/messages/initialize.cc #L104
      -- textDocumentSync = true, -- Comment out since adding this will make 'ccls' stop working
      client.server_capabilities.hoverProvider = false
      client.server_capabilitiescompletionProvider = false
      -- signatureHelpProvider = false, -- Comment out since adding this will make 'ccls' stop working
      client.server_capabilities.declarationProvider = false
      client.server_capabilities.definitionProvider = false
      client.server_capabilities.implementationProvider = true
      client.server_capabilities.typeDefinitionProvider = false
      client.server_capabilities.referencesProvider = false
      client.server_capabilities.documentHighlightProvider = false
      client.server_capabilities.documentSymbolProvider = false
      client.server_capabilities.workspaceSymbolProvider = false
      client.server_capabilities.codeActionProvider = false
      client.server_capabilities.codeLensProvider = false
      client.server_capabilities.documentFormattingProvider = false
      client.server_capabilities.documentRangeFormattingProvider = false
      client.server_capabilities.documentOnTypeFormattingProvider = false
      client.server_capabilities.renameProvider = false
      client.server_capabilities.documentLinkProvider = false
      client.server_capabilities.foldingRangeProvider = false
      client.server_capabilities.executeCommandProvider = false
      -- callHierarchyProvider = true -- Comment out since adding this will make 'ccls' stop working
      client.server_capabilities.workspace = false
  end
})

-- require("clangd").setup {
--   on_attach = function (client)
--     client.server_capabilities.workspaceSymbolProvider = false
--   end
-- }
