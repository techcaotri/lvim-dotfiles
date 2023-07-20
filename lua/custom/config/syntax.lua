vim.cmd("syntax on")
require('custom.config.autocmd').autocmd({ "BufNewFile", "BufRead" }, {
  pattern = { "*.keymap" },
  command = "set syntax=dts"
})
