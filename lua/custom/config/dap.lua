local M = {}

-- lvim.log.level = "debug"

local Log = require "lvim.core.log"
Log:init()

local api = vim.api
local keymap_restore = {}

-- Keeped keymaps:
-- <leader>dt: Toggle Breakpoint
-- <leader>dU: Toggle UI
-- <leader>dr: Toggle Repl
-- <leader>dc: Disconnect
-- <leader>ds: Start
-- <leader>dq: Quit/Close
-- Added keymaps:
-- <leader>dl: Run last session
-- <leader>dbl: List breakpoints
-- <leader>dbc: Clear breakpoints

local new_keymaps = {
  -- ['<F9>'] = { "<Cmd>lua require('dap').continue()<CR>", "DAP: Continue/Resume" },

  ['<F9>'] = { func = function() require('dap').continue() end, desc = "DAP: Continue/Resume" },
  ['<S-F9>'] = { func = function() require('dap').pause() end, desc = "DAP: Pause" },
  ['<A-F9>'] = { func = function() require('dap').run_to_cursor() end, desc = "DAP: Run to cursor" },
  ['<C-F2>'] = { func = function() require('dap').terminate() end, desc = "DAP: Stop debugging" },
  ['<F7>'] = { func = function() require('dap').step_into() end, desc = "DAP: Step into" },
  ['<F8>'] = { func = function() require('dap').step_over() end, desc = "DAP: Step over" },
  ['<S-F8>'] = { func = function() require('dap').step_out() end, desc = "DAP: Step out" },
  ['<F6>'] = { func = function() require('dap').toggle_breakpoint() end, desc = "DAP: Toggle breakpoints" },
  ['<C-F6>'] = { func = function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, desc =
  "DAP: Breakpoints with message" },
  ['<A-F6>'] = { func = function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end, desc =
  "DAP: Breakpoints with condition" },
  ['<S-F7>'] = { func = function() require('dap').step_back() end, desc = "DAP: Step back" },
  ['<F10>'] = { func = function() require('dap').run_last() end, desc = "DAP: Run last session" },
  ['<C-F10>'] = { func = function() require('dap').focus_frame() end, desc = "DAP: Focus frame (Stack traverse)" },
}

function M.register_dap_keymaps()
  for _, buf in pairs(api.nvim_list_bufs()) do
    local keymaps = api.nvim_buf_get_keymap(buf, 'n')
    for k, keymap in pairs(new_keymaps) do
      for _, cur_keymap in pairs(keymaps) do
        if cur_keymap.lhs == k then
          Log:debug("Found -> Save and replace: keymap.lhs: " ..
            k .. ", cur_keymap.rhs: " .. cur_keymap.rhs .. ", keymap.desc: " .. keymap.desc)
          table.insert(keymap_restore, cur_keymap)
          api.nvim_buf_del_keymap(buf, 'n', cur_keymap)
        end
      end

      api.nvim_set_keymap(
        'n', k, '', { callback = keymap.func, desc = keymap.desc, silent = true })
    end
  end

  -- api.nvim_set_keymap('n', '<C-F6>', '', { callback = function ()
  --   require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ') )
  -- end})

  local Keys = require("which-key.keys")
  Keys.update()
end

function M.unregister_dap_keymaps()
  Log:debug("unregister_dap_keymaps")
  if keymap_restore == nil then
    Log:d("keymap_restore is nil -> return")
    return
  end

  for _, keymap in pairs(keymap_restore) do
    api.nvim_buf_set_keymap(
      keymap.buffer,
      keymap.mode,
      keymap.lhs,
      keymap.rhs,
      { silent = keymap.silent == 1 }
    )
  end
  keymap_restore = {}
  local Keys = require("which-key.keys")
  Keys.update()
end

function M.config()
  local status_ok, dap = pcall(require, "dap")
  if not status_ok then
    Log:debug "dap plugin is not ok"
    return
  end

  local dapui_ok, dapui = pcall(require, 'dapui')
  if not dapui_ok then
    Log:debug "dap plugin is not ok"
    return
  end

  dap.listeners.after['event_initialized']['me'] = function()
    dapui.open()
    M.register_dap_keymaps()
  end

  dap.listeners.before['event_terminated']['me'] = function()
    dapui.close()
    M.unregister_dap_keymaps()
  end

  dap.listeners.after['disconnect']['me'] = function()
    dapui.close()
    M.unregister_dap_keymaps()
  end

  dap.adapters.cppdbg = {
    id = 'cppdbg',
    type = 'executable',
    command = '/home/tripham/.local/share/lvim/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7',
  }

  dap.configurations.cpp = {
    {
      name = "Launch file",
      type = "cppdbg",
      request = "launch",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
      end,
      cwd = "${workspaceFolder}",
      stopOnEntry = false,
      setupCommands = {
        {
          text = '-enable-pretty-printing',
          description = 'enable pretty printing',
          ignoreFailures = true
        },
      },
    },
    {
      name = 'Attach to gdbserver :1234',
      type = 'cppdbg',
      request = 'launch',
      MIMode = 'gdb',
      miDebuggerServerAddress = 'localhost:1234',
      miDebuggerPath = '/usr/bin/gdb',
      cwd = '${workspaceFolder}',
      program = function()
        return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
      end,
    },
  }
  dap.configurations.c = dap.configurations.cpp

  -- auto reload .vscode/launch.json
  local type_to_filetypes = { cppdbg = { "c", "cpp" }, codelldb = { "rust" }, delve = { "go" } }
  local dap_vscode = require("dap.ext.vscode")
  pcall(dap_vscode.load_launchjs, nil, type_to_filetypes)

  local pattern = vim.fn.getcwd() .. './.vscode/launch.json'
  Log:debug("load_launchjs pattern" .. pattern)
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = pattern,
    callback = function(args)
      pcall(dap_vscode.load_launchjs, args.file, type_to_filetypes)
    end
  })

  -- Auto load .vscode/launch.json
  require('custom.config.autocmd').autocmd("SessionLoadPost", {
    callback = function()
      Log:debug("load_launchjs pattern" .. pattern)
      pcall(dap_vscode.load_launchjs, pattern, type_to_filetypes)
    end
  })
end

M.config()
return M
