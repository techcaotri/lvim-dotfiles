-- Editing / motion / text-object plugins ported from LunarVim.
return {
  -- Flash: disable during regular / search; keep the user's motion keys.
  {
    "folke/flash.nvim",
    opts = { modes = { search = { enabled = false } } },
    keys = {
      { "<leader>F", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Flash remote" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash TS search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash search" },
    },
  },

  -- Surround (user used nvim-surround rather than LazyVim's mini.surround).
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },

  -- Delete/change without clobbering the register.
  { "gbprod/cutlass.nvim", event = "VeryLazy", opts = { cut_key = "m", exclude = { "ns" } } },

  -- Move lines/blocks (note: <A-j>/<A-k> line moves are set in keymaps.lua).
  { "fedepujol/move.nvim", event = "VeryLazy", opts = {} },

  -- Undo history tree.
  { "mbbill/undotree", cmd = "UndotreeToggle", keys = { { "<leader>U", "<cmd>UndotreeToggle<CR>", desc = "Undo tree" } } },

  -- Marks in the gutter.
  {
    "chentoast/marks.nvim",
    event = "VeryLazy",
    opts = {
      default_mappings = false,
      cyclic = true,
      bookmark_0 = { sign = "\u{2691}", virt_text = "->" },
      mappings = {
        set_next = "<leader>m,",
        delete = "<leader>mx",
        delete_line = "<leader>md",
        delete_buf = "<leader>mD",
        next = "<leader>mn",
        preview = "<leader>m:",
        prev = "<leader>mp",
        set_bookmark0 = "<leader>m0",
        set_bookmark1 = "<leader>m1",
        set_bookmark2 = "<leader>m2",
        set_bookmark3 = "<leader>m3",
        set_bookmark4 = "<leader>m4",
        set_bookmark5 = "<leader>m5",
        set_bookmark6 = "<leader>m6",
        set_bookmark7 = "<leader>m7",
        set_bookmark8 = "<leader>m8",
        set_bookmark9 = "<leader>m9",
      },
    },
  },

  -- Enhanced marks/jumps/buffers viewer.
  {
    "gcmt/vessel.nvim",
    event = "VeryLazy",
    opts = { create_commands = true, marks = { toggle_mark = true, use_backtick = true } },
    keys = {
      { "gj", "<Plug>(VesselViewJumps)", desc = "Vessel: jumps" },
      { "gL", "<Plug>(VesselViewMarks)", desc = "Vessel: marks" },
      { "gm", "<Plug>(VesselSetLocalMark)", desc = "Vessel: set local mark" },
    },
  },

  -- Auto-resize / maximize windows.
  {
    "JoseConseco/windows.nvim",
    event = "VeryLazy",
    dependencies = { "anuvyklack/middleclass", "anuvyklack/animation.nvim" },
    config = function()
      vim.o.winwidth = 20
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require("windows").setup()
    end,
  },

  -- Soft/hard wrap modes (commands mapped in keymaps.lua under <leader>W).
  { "andrewferrier/wrapping.nvim", event = "VeryLazy", opts = { create_keymaps = false } },

  -- Reverse-join (split args onto lines).
  {
    "AckslD/nvim-trevJ.lua",
    keys = {
      { "<leader>j", mode = { "n", "v" }, function() require("trevj").format_at_cursor() end, desc = "trevJ reverse-join" },
    },
    opts = {},
  },

  -- Align.
  { "junegunn/vim-easy-align", keys = { { "ga", "<Plug>(EasyAlign)", mode = { "n", "x" }, desc = "EasyAlign" } } },

  -- Multiple cursors.
  {
    "mg979/vim-visual-multi",
    event = "VeryLazy",
    init = function()
      vim.g.VM_set_statusline = 0
      vim.g.VM_silent_exit = 1
    end,
  },

  -- Extended % matching (treesitter-aware).
  {
    "andymass/vim-matchup",
    event = "VeryLazy",
    init = function()
      vim.g.matchup_treesitter_stopline = 500
      vim.g.matchup_matchparen_enabled = 0
      vim.g.matchup_surround_enabled = 1
      vim.g.matchup_matchparen_deferred_show_delay = 50
      vim.g.matchup_matchparen_deferred_hide_delay = 700
    end,
  },

  -- Small, low-config utilities.
  { "terryma/vim-expand-region", event = "VeryLazy" },
  { "airblade/vim-matchquote", event = "VeryLazy" },
  { "sitiom/nvim-numbertoggle", event = "VeryLazy" },
  { "lambdalisue/suda.vim", cmd = { "SudaRead", "SudaWrite" } },
  { "alpertuna/vim-header", cmd = { "AddHeader", "AddMinHeader" } },
  { "drmikehenry/vim-headerguard", ft = { "c", "cpp" } },
  { "tzachar/highlight-undo.nvim", event = "VeryLazy", opts = {} },

  -- Auto-save.
  {
    "Pocco81/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    opts = {
      trigger_events = { "InsertLeave", "TextChanged" },
      debounce_delay = 1000,
      condition = function(buf)
        local ft = vim.bo[buf].filetype
        local excluded = { NvimTree = true, ["neo-tree"] = true, alpha = true, dashboard = true, startify = true }
        if excluded[ft] then return false end
        if not vim.bo[buf].modifiable then return false end
        return true
      end,
    },
  },
}
