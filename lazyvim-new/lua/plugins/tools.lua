-- Terminal / search / clipboard / session tools ported from LunarVim.
return {
  -- tmux navigation + clipboard/register sync.
  {
    "aserowy/tmux.nvim",
    event = "VeryLazy",
    opts = {
      copy_sync = { enable = true, sync_clipboard = false, sync_registers = true },
      navigation = { enable_default_keybindings = true },
      resize = { enable_default_keybindings = false },
    },
  },

  -- Yank ring highlight (LazyVim's coding.yanky extra provides the keys).
  {
    "gbprod/yanky.nvim",
    opts = { highlight = { on_put = true, on_yank = true, timer = 300 } },
  },

  -- Project-wide find & replace.
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    opts = { startInInsertMode = false },
    keys = {
      { "<leader>S", mode = { "n", "v" }, function() require("grug-far").open() end, desc = "Search/Replace (grug-far)" },
      { "<leader>Ss", mode = { "n", "v" }, function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "S/R word" },
      { "<leader>Sf", mode = { "n", "v" }, function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>"), paths = vim.fn.expand("%") } }) end, desc = "S/R word in file" },
    },
  },

  -- Translation.
  {
    "uga-rosa/translate.nvim",
    cmd = "Translate",
    opts = { default = { command = "translate_shell", output = "insert" } },
  },

  -- lf file manager in a floating window.
  {
    "lmburns/lf.nvim",
    dependencies = { "akinsho/toggleterm.nvim" },
    cmd = "Lf",
    init = function()
      vim.g.lf_netrw = 1
    end,
    opts = {},
    keys = { { "<M-o>", "<cmd>Lf<cr>", desc = "lf file manager" } },
  },

  -- toggleterm execs (M-h horizontal, M-v vertical, M-i float), reproducing
  -- LunarVim's exec-terminal behavior (lvim.core.terminal): dedicated terminal
  -- counts, dynamic fractional sizes, bound in BOTH normal and terminal modes.
  {
    "akinsho/toggleterm.nvim",
    keys = { { "<M-h>" }, { "<M-v>" }, { "<M-i>" } },
    opts = {
      size = 20,
      open_mapping = nil,
      hide_numbers = true,
      shade_terminals = true,
      shading_factor = 2,
      start_in_insert = true,
      insert_mappings = true,
      persist_size = false,
      close_on_exit = true,
      float_opts = { border = "curved" },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)

      -- LunarVim's dynamic size: fractions of the current window dimension.
      local function dyn_size(direction, size)
        if size <= 1 then
          local id = vim.api.nvim_get_current_win()
          if direction == "horizontal" then
            return vim.api.nvim_win_get_height(id) * size
          end
          return vim.api.nvim_win_get_width(id) * size
        end
        return size
      end

      local Terminal = require("toggleterm.terminal").Terminal
      local execs = {
        { key = "<M-h>", direction = "horizontal", size = 0.3, count = 101, desc = "Horizontal Terminal" },
        { key = "<M-v>", direction = "vertical", size = 0.4, count = 102, desc = "Vertical Terminal" },
        { key = "<M-i>", direction = "float", size = nil, count = 103, desc = "Float Terminal" },
      }
      for _, e in ipairs(execs) do
        local term
        local function toggle()
          if not term then
            term = Terminal:new({ direction = e.direction, count = e.count, hidden = false })
          end
          term:toggle(e.size and dyn_size(e.direction, e.size) or nil, e.direction)
        end
        vim.keymap.set({ "n", "t" }, e.key, toggle, { desc = e.desc, noremap = true, silent = true })
      end
    end,
  },

  -- Capture command output into a buffer.
  { "AndrewRadev/bufferize.vim", cmd = "Bufferize" },

  -- Render ANSI escape colors.
  { "powerman/vim-plugin-AnsiEsc", cmd = "AnsiEsc" },

  -- Session management (possession) + custom save prompt.
  {
    "jedrzejboczar/possession.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      autosave = { current = true, tmp = true, tmp_name = "tmp", on_load = true, on_quit = true },
      plugins = {
        close_windows = { preserve_layout = true, match = { floating = true, buftype = { "terminal" } } },
        delete_hidden_buffers = false,
        nvim_tree = true,
        delete_buffers = false,
      },
      -- Persist + restore the active Python venv per session (venv-selector v2).
      hooks = {
        before_save = function()
          local cached
          local ok, config = pcall(require, "venv-selector.config")
          if ok and config.user_settings and config.user_settings.cache then
            local path = require("venv-selector.path")
            local cache_file = path.expand(config.user_settings.cache.file)
            if vim.fn.filereadable(cache_file) == 1 then
              local lines = vim.fn.readfile(cache_file)
              local dok, cache = pcall(vim.fn.json_decode, lines[1])
              if dok and type(cache) == "table" then
                local entry = cache[vim.fn.getcwd()]
                if type(entry) == "table" and entry.value then
                  cached = { path = entry.value, type = entry.type or "venv" }
                end
              end
            end
          end
          return { ["venv-selector"] = { cached_venv = cached } }
        end,
        after_load = function(_, user_data)
          local c = user_data and user_data["venv-selector"] and user_data["venv-selector"].cached_venv
          if type(c) == "table" and c.path and c.path ~= "" then
            local ok, vs = pcall(require, "venv-selector")
            if ok and type(vs.activate_from_path) == "function" then
              pcall(vs.activate_from_path, c.path, c.type or "venv")
            end
          end
        end,
      },
    },
    config = function(_, opts)
      require("possession").setup(opts)
      pcall(function()
        require("telescope").load_extension("possession")
      end)
    end,
  },

  -- Project/root detection (ported from LunarVim's lvim.builtin.project /
  -- custom/config/project.lua). Auto-cds to the project root using the user's
  -- detection methods + pattern list, and adds the telescope "projects" picker.
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    opts = {
      detection_methods = { "pattern", "lsp" },
      patterns = {
        ".git",
        "_darcs",
        ".hg",
        ".bzr",
        ".svn",
        "Makefile",
        "package.json",
        "package-lock.json",
        "yarn.lock",
        "requirements.txt",
        "pyproject.toml",
        ".vscode",
        "pubspec.yaml",
        "CMakeLists.txt",
        "manim.cfg",
      },
    },
    config = function(_, opts)
      require("project_nvim").setup(opts)
      pcall(function()
        require("telescope").load_extension("projects")
      end)
    end,
  },
}
