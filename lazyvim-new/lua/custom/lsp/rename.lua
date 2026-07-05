-- Custom floating rename (CosmicUI-style), ported from the LunarVim setup and
-- updated for Neovim 0.11 (make_position_params now requires position_encoding).
-- Falls back to vim.lsp.buf.rename() if nui.nvim is unavailable.
return function(popup_opts, opts)
  local ok, Input = pcall(require, "nui.input")
  if not ok then
    return vim.lsp.buf.rename()
  end
  local event = require("nui.utils.autocmd").event
  local curr = vim.fn.expand("<cword>")
  local prompt = "> "
  local width = math.max(25, #curr + #prompt + 1)

  local input = Input(vim.tbl_deep_extend("force", {
    position = { row = 1, col = 0 },
    relative = "cursor",
    size = { width = width },
    border = { style = "single", text = { top = " Rename ", top_align = "left" } },
    win_options = { winhighlight = "Normal:Normal,FloatBorder:FloatBorder" },
  }, popup_opts or {}), vim.tbl_deep_extend("force", {
    prompt = prompt,
    default_value = curr,
    on_submit = function(new_name)
      if not new_name or #new_name == 0 or new_name == curr then
        return
      end
      local clients = vim.lsp.get_clients({ bufnr = 0 })
      local enc = clients[1] and clients[1].offset_encoding or "utf-16"
      local params = vim.lsp.util.make_position_params(0, enc)
      params.newName = new_name
      vim.lsp.buf_request(0, "textDocument/rename", params, function(err, result)
        if err or not result then
          return
        end
        vim.lsp.util.apply_workspace_edit(result, enc)
        local n = 0
        for _, changes in pairs(result.changes or {}) do
          n = n + #changes
        end
        for _, dc in pairs(result.documentChanges or {}) do
          n = n + #(dc.edits or {})
        end
        vim.notify(string.format("Renamed to '%s' (%d change%s)", new_name, n, n == 1 and "" or "s"))
      end)
    end,
  }, opts or {}))

  input:mount()
  input:map("i", "<Esc>", function() input:unmount() end, { noremap = true })
  input:map("n", "<Esc>", function() input:unmount() end, { noremap = true })
  input:on(event.BufLeave, function() input:unmount() end)
end
