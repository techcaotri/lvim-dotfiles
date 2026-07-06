-- Debugging. LazyVim's dap.core extra (imported in config/lazy.lua) provides
-- nvim-dap + dap-ui + nvim-dap-virtual-text + mason-nvim-dap. Here we add the
-- language adapters (cpp/python/js), the user's F-key keymaps, and launch.json
-- autoloading. Mason data dir resolves per NVIM_APPNAME via stdpath("data").
return {
  -- Virtual text column (matches the old virt_text_win_col = 80).
  { "theHamsta/nvim-dap-virtual-text", opts = { virt_text_win_col = 80 } },

  -- Python debug adapter.
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      pcall(function()
        require("dap-python").setup("python")
      end)
    end,
  },

  -- JS/TS debug adapter.
  {
    "mxsdev/nvim-dap-vscode-js",
    ft = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
    dependencies = {
      "mfussenegger/nvim-dap",
      {
        "microsoft/vscode-js-debug",
        commit = "4d7c704d3f07",
        -- Idempotent build: skip if already bundled (out/src/vsDebugServer.js);
        -- otherwise clean-build so the final `mv dist out` never fails on an
        -- existing out/ (the original cause of the build error).
        build = "test -f out/src/vsDebugServer.js || "
          .. "(rm -rf out dist && npm install --legacy-peer-deps "
          .. "&& npx gulp vsDebugServerBundle && mv dist out)",
      },
    },
    config = function()
      pcall(function()
        require("dap-vscode-js").setup({
          debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
          adapters = { "pwa-node", "pwa-chrome", "node-terminal" },
        })
      end)
    end,
  },

  -- Core dap: cpp adapter, F-key keymaps, launch.json autoload.
  {
    "mfussenegger/nvim-dap",
    config = function()
      local dap = require("dap")

      -- cppdbg adapter (cpptools OpenDebugAD7).
      dap.adapters.cppdbg = {
        id = "cppdbg",
        type = "executable",
        command = vim.fn.stdpath("data")
          .. "/mason/packages/cpptools/extension/debugAdapters/bin/OpenDebugAD7",
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
          stopAtEntry = false,
          setupCommands = {
            { text = "-enable-pretty-printing", description = "enable pretty printing", ignoreFailures = false },
          },
        },
        {
          name = "Attach to gdbserver :1234",
          type = "cppdbg",
          request = "launch",
          MIMode = "gdb",
          miDebuggerServerAddress = "localhost:1234",
          miDebuggerPath = "/usr/bin/gdb",
          cwd = "${workspaceFolder}",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
        },
      }
      dap.configurations.c = dap.configurations.cpp

      -- F-key debugging keymaps (the terminal remaps in keymaps.lua deliver these).
      local map = vim.keymap.set
      local o = { silent = true }
      map("n", "<F9>", function() dap.continue() end, o)
      map("n", "<S-F9>", function() dap.pause() end, o)
      map("n", "<A-F9>", function() dap.run_to_cursor() end, o)
      map("n", "<C-F2>", function() dap.terminate() end, o)
      map("n", "<F7>", function() dap.step_into() end, o)
      map("n", "<F8>", function() dap.step_over() end, o)
      map("n", "<S-F8>", function() dap.step_out() end, o)
      map("n", "<S-F7>", function() dap.step_back() end, o)
      map("n", "<F6>", function() dap.toggle_breakpoint() end, o)
      map("n", "<C-F6>", function() dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: ")) end, o)
      map("n", "<A-F6>", function() dap.set_breakpoint(vim.fn.input("Breakpoint condition: ")) end, o)
      map("n", "<F10>", function() dap.run_last() end, o)
      map("n", "<C-F10>", function() dap.focus_frame() end, o)

      -- Breakpoint signs.
      vim.fn.sign_define("DapBreakpoint", { text = "\u{1F535}", texthl = "DiagnosticInfo" })
      vim.fn.sign_define("DapBreakpointRejected", { text = "\u{1F534}", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapBreakpointCondition", { text = "\u{1F7E1}", texthl = "DiagnosticWarn" })
      vim.fn.sign_define("DapStopped", { text = "\u{1F7E2}", texthl = "DiagnosticOk" })

      -- Auto-load .vscode/launch.json (cppdbg/codelldb/delve).
      local function load_launchjs()
        pcall(function()
          require("dap.ext.vscode").load_launchjs(
            vim.fn.getcwd() .. "/.vscode/launch.json",
            { cppdbg = { "c", "cpp" }, codelldb = { "rust" }, delve = { "go" } }
          )
        end)
      end
      vim.api.nvim_create_autocmd("BufWritePost", {
        pattern = "*/.vscode/launch.json",
        callback = load_launchjs,
      })
      vim.api.nvim_create_autocmd("SessionLoadPost", { callback = load_launchjs })
    end,
  },
}
