local M = {}

local au_id = vim.api.nvim_create_augroup("MyAutoCommands", { clear = true })


function M.autocmd(pattern, opts)
  opts.group = au_id
  vim.api.nvim_create_autocmd(pattern, opts)
end

return M
