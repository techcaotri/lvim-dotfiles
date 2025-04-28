-- Jinja
vim.filetype.add {
  extension = {
    jinja = 'jinja',
    jinja2 = 'jinja',
    j2 = 'jinja',
  },
}

local function configure_jinja_lsp(lspconfig)
	lspconfig.jinja_lsp.setup({
		on_attach = lsp_onattach,
	})
end
