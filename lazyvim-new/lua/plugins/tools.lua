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

  -- toggleterm execs (M-h horizontal, M-v vertical, M-i float).
  {
    "akinsho/toggleterm.nvim",
    keys = {
      { "<M-h>", "<cmd>ToggleTerm direction=horizontal size=20<cr>", desc = "Terminal (horizontal)" },
      { "<M-v>", "<cmd>ToggleTerm direction=vertical size=80<cr>", desc = "Terminal (vertical)" },
      { "<M-i>", "<cmd>ToggleTerm direction=float<cr>", desc = "Terminal (float)" },
    },
    opts = { open_mapping = nil },
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
    },
    config = function(_, opts)
      require("possession").setup(opts)
      pcall(function()
        require("telescope").load_extension("possession")
      end)
    end,
  },
}
