local filetypes = { "c", "cpp", "objc", "objcpp", "opencl" }
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
}

-- Use ccls as the default language server for cpp types. Refer to 'custom.config.clangd-extension' for disabling clangd at the start
require("ccls").setup {
  filetypes = filetypes,
  lsp = {
    server = server_config,
    disable_capabilities = {
      completionProvider = true,
      documentFormattingProvider = true,
      documentRangeFormattingProvider = true,
      documentHighlightProvider = true,
      documentSymbolProvider = true,
      workspaceSymbolProvider = true,
      renameProvider = true,
      hoverProvider = true,
      codeActionProvider = true,
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
