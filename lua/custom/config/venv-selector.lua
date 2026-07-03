local M = {}

local Log

function M.config()
  -- lvim.log.level = "debug"
  Log = require "lvim.core.log"
  Log:init()

  -- NOTE (2026-07): venv-selector.nvim was rewritten ("regex"/v2). The old top-level
  -- options (auto_refresh, search_venv_managers, search_workspace, search=<bool>, parents,
  -- name, dap_enabled, ...) no longer exist. Passing the old `search = true` boolean is what
  -- caused `t: expected table, got boolean` in config.lua:finalize_settings.
  --
  -- v2 config lives under `options` / `search` / `hooks` / `cache`. The installed v2 requires
  -- Neovim 0.11+ only (NOT 0.12), so no plugin downgrade is needed here.
  --
  -- Old option -> v2 mapping:
  --   auto_refresh / search / parents / name / search_venv_managers / search_workspace
  --       -> removed. v2 ships default fd-based searches (cwd, workspace, file, poetry,
  --          pipenv, pyenv, pixi, conda, pipx, virtualenvs, hatch). Venvs are found by their
  --          `.../bin/python` binary, so custom directory names like ".linux-venv" or
  --          ".venv-python310" are discovered automatically regardless of the folder name.
  --   dap_enabled            -> removed (dap wiring changed; handled elsewhere via nvim-dap-python).
  --   fd_binary_name         -> options.fd_binary_name (auto-detected if omitted).
  --   notify_user_on_activate -> options.notify_user_on_venv_activation.
  require("venv-selector").setup({
    options = {
      -- Print a message when a venv is activated.
      notify_user_on_venv_activation = true,

      -- Name of the fd binary. On Debian/Ubuntu it is often "fdfind"; leave unset to auto-detect.
      fd_binary_name = "fd",

      -- Keep v2's default searches (poetry/pipenv/pyenv/conda/cwd/workspace/file/...).
      enable_default_searches = true,

      -- Remember and auto-activate the last venv used per project (replaces the old
      -- possession-based restore below, which is kept working as a fallback).
      enable_cached_venvs = true,
      cached_venv_automatic_activation = true,
    },
  })
end

function M.get_cached_venv()
  -- v2 cache (venvs2.json) is keyed by project root and each entry is a table:
  --   { value = "<python_path>", type = "venv"|"anaconda"|"uv", source = ... }
  -- (v1 stored a bare python-path string keyed by cwd.)
  local ok, config = pcall(require, "venv-selector.config")
  if not ok then return nil end
  local path = require("venv-selector.path")
  local cache_file = path.expand(config.user_settings.cache.file)
  if vim.fn.filereadable(cache_file) ~= 1 then
    return nil
  end
  local lines = vim.fn.readfile(cache_file)
  if lines == nil or lines[1] == nil then
    return nil
  end
  local decoded_ok, venv_cache = pcall(vim.fn.json_decode, lines[1])
  if not decoded_ok or type(venv_cache) ~= "table" then
    return nil
  end
  local entry = venv_cache[vim.fn.getcwd()]
  if entry == nil then
    return nil
  end
  -- v2 shape (table with .value) -> normalize to { path, type }.
  if type(entry) == "table" and entry.value ~= nil then
    return { path = entry.value, type = entry.type or "venv" }
  end
  -- Tolerate a legacy bare-string entry.
  if type(entry) == "string" then
    return { path = entry, type = "venv" }
  end
  return nil
end

function M.possession_before_save()
  local cached_venv = M.get_cached_venv()
  Log:debug("cached_venv: " .. vim.inspect(cached_venv))

  return {
    ["venv-selector"] = {
      cached_venv = cached_venv,
    }
  }
end

function M.possession_after_load(name, user_data)
  Log:debug("user_data: " .. vim.inspect(user_data))
  if user_data == nil or user_data['venv-selector'] == nil then
    return
  end

  local cached = user_data['venv-selector']['cached_venv']
  if cached == nil then
    return
  end

  -- Normalize: current format is { path = ..., type = ... }; tolerate a legacy bare string.
  local venv_path, venv_type
  if type(cached) == "table" then
    venv_path, venv_type = cached.path, cached.type or "venv"
  elseif type(cached) == "string" then
    venv_path, venv_type = cached, "venv"
  end
  if not venv_path or venv_path == "" then
    return
  end

  Log:debug("Loading venv_path: " .. vim.inspect(venv_path))
  -- v2 API: activate a venv from its python path. (The old
  -- venv.set_venv_and_system_paths() no longer exists in venv-selector.)
  local ok, vs = pcall(require, "venv-selector")
  if ok and type(vs.activate_from_path) == "function" then
    pcall(vs.activate_from_path, venv_path, venv_type)
    -- Prevent the asking for 'Enter' input
    vim.api.nvim_feedkeys("<CR>", 'm', false)
  end
end

return M
