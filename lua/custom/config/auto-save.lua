local M = {}

M.excluded_bufs = { "NvimTree_", "dashboard", "startify", "alpha" }

function M.not_in(var, arr)
  for _, v in ipairs(arr) do
    if v:match(var) ~= nil then
      return false
    end
  end
  return true
end

function M.config()
  require("auto-save").setup {
    trigger_events = { "InsertLeave", "TextChanged" }, -- vim events that trigger auto-save. See :h events
    -- your config goes here
    debounce_delay = 1000,
    condition = function(buf)
      local fn = vim.fn
      if fn.getbufvar(buf, "&modifiable") == 1
          and M.not_in(vim.api.nvim_buf_get_name(0), M.excluded_bufs) then
        local undotree = vim.fn.undotree()
        if undotree.seq_last ~= undotree.seq_cur then
          return false -- don't try to save again if I tried to undo. k thanks
        end
        return true    -- met condition(s), can save
      end
      return false
    end
  }
end

return M
