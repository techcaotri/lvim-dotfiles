local filetypes = { "c", "cpp", "objc", "objcpp", "opencl" }
local navic = require("nvim-navic")
local server_config = {
  filetypes = filetypes,
  init_options = {
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
  -- on_attach = function(client, bufnr)
  --   navic.attach(client, bufnr)
  -- end
}

-- Use clangd as the default language server for cpp types. Since ccls doesn't support inlayhints -> https://github.com/MaskRay/ccls/issues/932
-- Only utilize the callHierarchyProvider of ccls
require("ccls").setup {
  filetypes = filetypes,
  lsp = {
    server = server_config,
    disable_capabilities = {
      -- This list is copied from https://github.com/MaskRay/ccls/blob/ee2d4f5b9a2181e2c71341d34c7d2463f0c28cd1/src/messages/initialize.cc #L104
      -- textDocumentSync = true, -- Comment out since adding this will make 'ccls' stop working
      hoverProvider = false,
      completionProvider = false,
      -- signatureHelpProvider = false, -- Comment out since adding this will make 'ccls' stop working
      declarationProvider = false,
      definitionProvider = false,
      implementationProvider = false,
      typeDefinitionProvider = false,
      referencesProvider = false,
      documentHighlightProvider = false,
      documentSymbolProvider = false,
      workspaceSymbolProvider = false,
      codeActionProvider = false,
      codeLensProvider = false,
      documentFormattingProvider = false,
      documentRangeFormattingProvider = false,
      documentOnTypeFormattingProvider = false,
      renameProvider = false,
      documentLinkProvider = false,
      foldingRangeProvider = false,
      executeCommandProvider = false,
      -- callHierarchyProvider = true, -- Comment out since adding this will make 'ccls' stop working
      workspace = false,
    },
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
