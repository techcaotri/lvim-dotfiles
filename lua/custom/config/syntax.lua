vim.cmd("syntax on")
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.keymap" },
  command = "set syntax=dts"
})
