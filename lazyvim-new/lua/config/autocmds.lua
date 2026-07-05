-- Autocmds + user commands -- loaded by LazyVim on VeryLazy.
-- LazyVim ships common autocmds (highlight-on-yank, resize splits, close-with-q,
-- auto-create-dir, etc.); here we add only the user-specific ones from config.lua.

-- Auto-reload files changed on disk (from the old config.lua).
local autoread = vim.api.nvim_create_augroup("ar_autoread", { clear = true })
vim.api.nvim_create_autocmd("FileChangedShellPost", {
  pattern = "*",
  group = autoread,
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.")
  end,
})
vim.api.nvim_create_autocmd({ "FocusGained", "CursorHold" }, {
  pattern = "*",
  group = autoread,
  callback = function()
    if vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

-- Keep flash.nvim search integration enabled when opening files (from config.lua).
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  callback = function()
    pcall(function()
      require("flash").toggle(true)
    end)
  end,
})

-- :Redir <cmd> -- capture an ex/lua command's output into a scratch buffer.
-- Usage: :Redir lua=vim.tbl_keys(package.loaded)
vim.api.nvim_create_user_command("Redir", function(ctx)
  local lines = vim.split(vim.api.nvim_exec2(ctx.args, { output = true }).output, "\n", { plain = true })
  vim.cmd("new")
  vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
  vim.opt_local.modified = false
end, { nargs = "+", complete = "command" })

-- :RunNode -- run the current JS file in a vertical terminal split.
vim.api.nvim_create_user_command("RunNode", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("vsplit term://node " .. file)
end, { desc = "Run current Node.js file in a new vertical split terminal" })

-- Global helper C(...) -- copy a lua value to the + register (from keymappings.lua).
function _G.C(...)
  local args = { ... }
  local output
  if #args == 0 then
    output = "nil"
  elseif #args == 1 then
    output = type(args[1]) == "table" and vim.inspect(args[1]) or tostring(args[1])
  else
    output = vim.inspect(args)
  end
  vim.fn.setreg("+", output)
  print("Copied: " .. (string.len(output) > 50 and string.sub(output, 1, 50) .. "..." or output))
  return args[1]
end
