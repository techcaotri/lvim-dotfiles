lvim.plugins = {
  {
    "p00f/clangd_extensions.nvim",
    ft = require("custom.config.clangd-extensions").filetype,
    config = require("custom.config.clangd-extensions").config,
    dependencies = require("custom.config.clangd-extensions").dependencies,
  },
  {
    "NvChad/nvim-colorizer.lua",
    config = function(_, opts)
      require("colorizer").setup(opts)

      -- execute colorizer as soon as possible
      vim.defer_fn(function()
        require("colorizer").attach_to_buffer(0)
      end, 0)
    end,
  },
  {
    "max397574/better-escape.nvim",
    event = "InsertEnter",
    config = function()
      require("better_escape").setup()
    end
  },
  {
    "L3MON4D3/LuaSnip"
  },
  {
    "rafamadriz/friendly-snippets"
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  {
    "nvim-treesitter/playground",
    lazy = false,
  },
  {
    "zbirenbaum/copilot.lua",
    config = require("custom.config.copilot").config,
    dependencies = require("custom.config.copilot").dependencies,
  },
  {
    "mg979/vim-visual-multi",
    lazy = false,
    config = function()
      vim.g.VM_set_statusline = 0 -- disable VM's statusline updates to prevent clobbering
      vim.g.VM_silent_exit = 1    -- because the status line already tells me the mode
    end
  },
  {
    "gbprod/yanky.nvim",
    lazy = false,
  },
  {
    "aserowy/tmux.nvim",
    event = "VeryLazy",
    dependencies = {
      "gbprod/yanky.nvim",
      "folke/which-key.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      -- change the name of the module
      require "custom.config.tmux-yanky"
      -- or you can just copy-paste the config here.
    end,
  },
  {
    "Pocco81/auto-save.nvim",
    lazy = false,
    config = function()
      require("auto-save").setup {
        trigger_events = { "InsertLeave", "TextChanged" }, -- vim events that trigger auto-save. See :h events
        -- your config goes here
        debounce_delay = 1000,
        condition = function(buf)
          local fn = vim.fn
          local undotree = vim.fn.undotree()
          if undotree.seq_last ~= undotree.seq_cur then
            return false -- don't try to save again if I tried to undo. k thanks
          end
        end
      }
    end,
  },
  {
    "kdheepak/lazygit.nvim",
    -- optional for floating window border decoration
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  { "folke/neodev.nvim", opts = {} },
  {
    "mbbill/undotree",
    lazy = false,
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    "fedepujol/move.nvim",
    lazy = false,
  },
  -- {
  --   'jedrzejboczar/possession.nvim',
  --   lazy = false,
  --   dependencies = { 'nvim-lua/plenary.nvim' },
  --   config = function()
  --     require("possession").setup {
  --       autosave = {
  --         current = true,   -- or fun(name): boolean
  --         tmp = true,       -- or fun(): boolean
  --         tmp_name = 'tmp', -- or fun(): string
  --         on_load = true,
  --         on_quit = true,
  --       },
  --       plugins = {
  --         close_windows = {
  --           preserve_layout = true, -- or fun(win): boolean
  --           match = {
  --             floating = true,
  --             buftype = {
  --               'terminal',
  --             },
  --             filetype = {},
  --             custom = false, -- or fun(win): boolean
  --           },
  --         },
  --         delete_hidden_buffers = false,
  --         nvim_tree = true,
  --         -- tabby = true,
  --         delete_buffers = false,
  --       },
  --     }
  --     require('telescope').load_extension('possession')
  --   end,
  -- },
  {
    "sitiom/nvim-numbertoggle",
    lazy = false,
  },
  {
    "gbprod/cutlass.nvim",
    opts = { cut_key = "m" },
  },
  {
    'nvim-telescope/telescope-symbols.nvim',
    event = "VeryLazy",
  },
  -- {
  --   'navarasu/onedark.nvim',
  --   config = function()
  --     require('onedark').setup {
  --       style = 'darker',
  --       ending_tildes = false,
  --       colors = {
  --         dark_grey = '#282C34',
  --         dim_grey = '#606570',
  --         mid_grey = '#4C515D',
  --       },
  --       highlights = {
  --         -- ExampleNC = {fg = '#0000ff', bg = '#00ff00', sp = '$cyan', fmt = 'underline,italic'},
  --         NormalNC = { bg = '$mid_grey' },
  --         EndOfBuffer = { bg = 'NONE' },
  --         SignColumn = { bg = 'NONE' },
  --         VertSplit = { bg = '$dark_grey' },
  --         StatusLine = { bg = '$dark_grey' },
  --         IndentlineOne = { fg = '$mid_grey' },
  --         IndentlineTwo = { fg = '$dim_grey' },
  --         NavicSeparator = { fg = '$mid_grey' },
  --       }
  --     }
  --   end
  -- },
  {
    'techcaotri/Colorschemes',
    lazy = false,
  },
  {
    'loctvl842/monokai-pro.nvim',
    lazy = false,
  },
  {
    "iamcco/markdown-preview.nvim",
    build = "cd app && npm install",
    ft = "markdown",
    lazy = true,
    keys = { { "<leader>m", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" } },
    config = function()
      vim.g.mkdp_auto_close = true
      vim.g.mkdp_open_to_the_world = false
      vim.g.mkdp_open_ip = "127.0.0.1"
      vim.g.mkdp_port = "8888"
      vim.g.mkdp_browser = ""
      vim.g.mkdp_echo_preview_url = true
      vim.g.mkdp_page_title = "${name}"
    end,
  },
}
