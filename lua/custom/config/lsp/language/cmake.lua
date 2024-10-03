local lsp_manager = require("lvim.lsp.manager")
lsp_manager.setup("cmake", {
	filetypes = { "cmake", "txt" },
	on_init = require("lvim.lsp").common_on_init,
	capabilities = require("lvim.lsp").common_capabilities(),
})
lsp_manager.setup("neocmake", {
	filetypes = { "cmake", "txt" },
	on_init = require("lvim.lsp").common_on_init,
	capabilities = require("lvim.lsp").common_capabilities(),
})
