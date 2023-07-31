local M = {}

local Log

function M.config()
  -- lvim.log.level = "debug"
  Log = require "lvim.core.log"
  Log:init()

  require("venv-selector").setup({

    -- auto_refresh (default: false). Will automatically start a new search every time VenvSelect is opened.
    -- When its set to false, you can refresh the search manually by pressing ctrl-r. For most users this
    -- is probably the best default setting since it takes time to search and you usually work within the same
    -- directory structure all the time.
    auto_refresh = false,

    -- search_venv_managers (default: true). Will search for Poetry and Pipenv virtual environments in their
    -- default location. If you dont use the default location, you can
    search_venv_managers = true,

    -- search_workspace (default: true). Your lsp has the concept of "workspaces" (project folders), and
    -- with this setting, the plugin will look in those folders for venvs. If you only use venvs located in
    -- project folders, you can set search = false and search_workspace = true.
    search_workspace = true,

    -- path (optional, default not set). Absolute path on the file system where the plugin will look for venvs.
    -- Only set this if your venvs are far away from the code you are working on for some reason. Otherwise its
    -- probably better to let the VenvSelect search for venvs in parent folders (relative to your code). VenvSelect
    -- searchs for your venvs in parent folders relative to what file is open in the current buffer, so you get
    -- different results when searching depending on what file you are looking at.
    -- path = "/home/username/your_venvs",

    -- search (default: true) - Search your computer for virtual environments outside of Poetry and Pipenv.
    -- Used in combination with parents setting to decide how it searches.
    -- You can set this to false to speed up the plugin if your virtual envs are in your workspace, or in Poetry
    -- or Pipenv locations. No need to search if you know where they will be.
    search = true,

    -- dap_enabled (default: false) Configure Debugger to use virtualvenv to run debugger.
    -- require nvim-dap-python from https://github.com/mfussenegger/nvim-dap-python
    -- require debugpy from https://github.com/microsoft/debugpy
    -- require nvim-dap from https://github.com/mfussenegger/nvim-dap
    dap_enabled = false,

    -- parents (default: 2) - Used when search = true only. How many parent directories the plugin will go up
    -- (relative to where your open file is on the file system when you run VenvSelect). Once the parent directory
    -- is found, the plugin will traverse down into all children directories to look for venvs. The higher
    -- you set this number, the slower the plugin will usually be since there is more to search.
    -- You may want to set this to to 0 if you specify a path in the path setting to avoid searching parent
    -- directories.
    parents = 2,

    -- name (default: venv) - The name of the venv directories to look for.
    name = { "venv", ".venv", ".linux-venv", ".venv-python310" },     -- NOTE: You can also use a lua table here for multiple names: {"venv", ".venv"}`

    -- fd_binary_name (default: fd) - The name of the fd binary on your system. Some Debian based Linux Distributions like Ubuntu use ´fdfind´.
    fd_binary_name = "fd",


    -- notify_user_on_activate (default: true) - Prints a message that the venv has been activated
    notify_user_on_activate = true,
  })
end

function M.get_cached_venv()
  local config = require("venv-selector.config")
  if vim.fn.filereadable(config.settings.cache_file) == 1 then
    local cache_file = vim.fn.readfile(config.settings.cache_file)
    if cache_file ~= nil and cache_file[1] ~= nil then
      local venv_cache = vim.fn.json_decode(cache_file[1])
      if venv_cache ~= nil and venv_cache[vim.fn.getcwd()] ~= nil then
        return venv_cache[vim.fn.getcwd()]
      end
    end
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
  local venv = require("venv-selector.venv")
  if user_data == nil or venv == nil then
    return
  end

  -- Load cached venv-selector
  if user_data['venv-selector'] ~= nil and user_data['venv-selector']['cached_venv'] ~= nil then
    local venv_path = user_data['venv-selector']['cached_venv']
    Log:debug("Loading venv_path: " .. vim.inspect(venv_path))
    venv.set_venv_and_system_paths(venv_path)
    -- Prevent the asking for 'Enter' input
    vim.api.nvim_feedkeys("<CR>",'m',false)
  end
end

return M
