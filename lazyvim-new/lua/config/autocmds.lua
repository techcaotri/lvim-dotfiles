-- Autocmds + user commands -- loaded by LazyVim on VeryLazy.
-- LazyVim ships common autocmds (highlight-on-yank, resize splits, close-with-q,
-- auto-create-dir, etc.); here we add only the user-specific ones from config.lua.

-- Filetype detection ported from LunarVim (jinja templates, zsh, ZMK *.keymap).
vim.filetype.add({
  extension = {
    jinja = "jinja",
    jinja2 = "jinja",
    j2 = "jinja",
    zsh = "zsh",
  },
})
-- ZMK / devicetree keymap files use dts syntax (from custom/config/syntax.lua).
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead" }, {
  pattern = "*.keymap",
  command = "set syntax=dts",
})

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

-- LunarVim LSP buffer mappings/options not covered by LazyVim's defaults
-- (from lunarvim/lua/lvim/lsp/config.lua buffer_mappings + buffer_options).
-- LazyVim already provides gd/gD/gr/gI/K; we add gs, gl, omnifunc and formatexpr.
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local buf = ev.buf
    vim.keymap.set("n", "gs", vim.lsp.buf.signature_help, { buffer = buf, desc = "Show signature help", silent = true })
    vim.keymap.set("n", "gl", function()
      local float = vim.diagnostic.config().float
      if float then
        local config = type(float) == "table" and vim.deepcopy(float) or {}
        config.scope = "line"
        vim.diagnostic.open_float(config)
      end
    end, { buffer = buf, desc = "Show line diagnostics", silent = true })
    -- LSP-powered completion + gq formatting, as LunarVim set on attach.
    vim.bo[buf].omnifunc = "v:lua.vim.lsp.omnifunc"
    vim.bo[buf].formatexpr = "v:lua.vim.lsp.formatexpr(#{timeout_ms:500})"
  end,
})

-- dap-repl buffers should not appear in the buffer list (LunarVim default).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "dap-repl",
  callback = function()
    vim.opt_local.buflisted = false
  end,
})

-- Fix gf for lua require-style paths (LunarVim default).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.opt_local.include = [=[\v<((do|load)file|require)\s*\(?['"]\zs[^'"]+\ze['"]]=]
    vim.opt_local.includeexpr = "substitute(v:fname,'\\.','/','g')"
    vim.opt_local.suffixesadd:prepend(".lua")
    vim.opt_local.suffixesadd:prepend("init.lua")
    for _, path in ipairs(vim.api.nvim_get_runtime_file("lua", true)) do
      vim.opt_local.path:append(path)
    end
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

-- Keep v:oldfiles fresh WITHIN the running session so the startup dashboard's
-- "Recent Files" section AND the `r` oldfiles picker include files opened this
-- session. Neovim only loads v:oldfiles from shada at startup and never refreshes
-- it live (verified: opening buffers, and even :wshada + :rshada, do not update
-- it). With a long-lived lvim-new server -- files opened via `tol-new --remote`
-- into the same instance -- newly-opened files would otherwise never appear in
-- recent files until a full restart. v:oldfiles is a mutable list, so we prepend
-- each real file as it is opened/entered (most-recent first, de-duplicated). This
-- only affects the in-session display; shada persistence on exit uses Neovim's
-- own internal list and is unaffected.
vim.api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
  group = vim.api.nvim_create_augroup("lvim_recent_oldfiles", { clear = true }),
  callback = function(args)
    local buf = args.buf
    if vim.bo[buf].buftype ~= "" then return end -- normal file buffers only
    local f = vim.api.nvim_buf_get_name(buf)
    if f == "" then return end
    f = vim.fn.fnamemodify(f, ":p")
    if vim.fn.filereadable(f) == 0 then return end
    local old = vim.v.oldfiles or {}
    for i = #old, 1, -1 do -- drop any existing entry so the file moves to the top
      if old[i] == f then table.remove(old, i) end
    end
    table.insert(old, 1, f)
    vim.v.oldfiles = old
  end,
})
