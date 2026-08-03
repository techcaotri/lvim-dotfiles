-- Shared "current buffer context directory" helper.
--
-- Both the exec-terminals (plugins/tools.lua) and the file explorer
-- (plugins/explorer.lua, <leader>e) need the directory that best represents what
-- the user is working on -- NOT Neovim's launch cwd. Example: you `cd ~/Downloads`
-- then run `lvim-new ~/Dev/test.sh`; the cwd is ~/Downloads but you want the tree
-- (and terminals) rooted at ~/Dev.
--
-- Rule (kept identical for terminals and the explorer):
--   * project root  -- if the current file is inside a real project, and
--   * file's own dir -- otherwise.
-- `$HOME` is rejected as a "project root": it commonly holds markers like
-- package.json/.vscode, which would otherwise make every file resolve to $HOME
-- (project.nvim uses the same patterns, so this matches its auto-cd).

local M = {}

--- Directory representing the current buffer's context.
---@return string
function M.context_dir()
  local fname = vim.api.nvim_buf_get_name(0)
  -- Non-file buffers (dashboard, terminal, tree itself, ...): fall back to cwd.
  if fname == "" or vim.bo.buftype ~= "" then
    return vim.loop.cwd()
  end
  local fdir = vim.fn.fnamemodify(fname, ":p:h")
  local ok, project = pcall(require, "project_nvim.project")
  if ok then
    local got, root = pcall(project.get_project_root)
    if got and type(root) == "string" and root ~= "" then
      local home = vim.loop.os_homedir()
      if not (home and vim.fs.normalize(root) == vim.fs.normalize(home)) then
        return root
      end
    end
  end
  return fdir
end

--- Toggle nvim-tree. When opening, root it at the current buffer's context dir
--- (see context_dir) instead of whatever cwd nvim was launched from, and reveal
--- the current file. Closing is a plain toggle.
function M.explorer_toggle()
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok then
    return
  end
  if api.tree.is_visible() then
    api.tree.close()
  else
    api.tree.open({ path = M.context_dir(), find_file = true })
  end
end

return M
