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

  -- Copilot
  {
    "zbirenbaum/copilot.lua",
    config = require("custom.config.copilot").config,
    dependencies = require("custom.config.copilot").dependencies,
  },

  -- Multiple cursors support
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
    branch = "main",
    config = function()
      require('custom.config.auto-save').config()
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

  -- Vertical movement of lines and blocks of code
  {
    "fedepujol/move.nvim",
    lazy = false,
  },

  -- Session management
  {
    'jedrzejboczar/possession.nvim',
    lazy = false,
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("possession").setup {
        autosave = {
          current = true,   -- or fun(name): boolean
          tmp = true,       -- or fun(): boolean
          tmp_name = 'tmp', -- or fun(): string
          on_load = true,
          on_quit = true,
        },
        plugins = {
          close_windows = {
            preserve_layout = true, -- or fun(win): boolean
            match = {
              floating = true,
              buftype = {
                'terminal',
              },
              filetype = {},
              custom = false, -- or fun(win): boolean
            },
          },
          delete_hidden_buffers = false,
          nvim_tree = true,
          -- tabby = true,
          delete_buffers = false,
        },
        hooks = {
          before_save = function()
            return require('custom.config.venv-selector').possession_before_save()
          end,
          after_load = function(name, user_data)
            require('custom.config.venv-selector').possession_after_load(name, user_data)
          end
        }
      }
      require('telescope').load_extension('possession')
    end,
  },

  -- Toggle number and relative number
  {
    "sitiom/nvim-numbertoggle",
    lazy = false,
  },

  -- delete, change, etc. without copying/yanking
  {
    "gbprod/cutlass.nvim",
    opts = {
      cut_key = "m",
      exclude = { "s<space>" },
    },
  },

  -- Telescope find emoji and symbols
  {
    'nvim-telescope/telescope-symbols.nvim',
    event = "VeryLazy",
  },

  -- Python debug adapter
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      require("dap-python").setup()
    end,
  },
  {
    "nvim-neotest/neotest",
  },
  {
    "nvim-neotest/neotest-python",
  },

  -- Python venv selector
  {
    "linux-cultist/venv-selector.nvim",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    config = function()
      require('custom.config.venv-selector').config()
    end,
    event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
  },

  -- Colorschemes and themes
  {
    'techcaotri/Colorschemes',
    lazy = false,
  },
  {
    'techcaotri-newpaper',
    dir = '/home/tripham/Dev/Playground_Terminal/Neovim_Awesome/newpaper.nvim',
    config = function()
      require("newpaper").setup({
        style = "dark",
      })
    end

  },

  -- Reverse join lines
  {
    'AckslD/nvim-trevJ.lua',
    config = 'require("trevj").setup()',
    init = function()
      vim.keymap.set({ 'n', 'v' }, '<leader>j', function()
          require('trevj').format_at_cursor()
        end,
        { desc = 'Reverse [j]oin (trevJ) at cursor' })
    end,
  },

  -- latex and markdown
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

  -- revamp menu ui for vim.ui.select and vim.ui.input
  {
    'stevearc/dressing.nvim',
    opts = {
      select = {
        backend = { "fzf_lua", "nui", "fzf", "builtin" },
        fzf_lua = {
          winopts = {
            width = 0.7,
            height = 0.5,
          },
        },
        fzf = {
          window = {
            width = 0.7,
            height = 0.5,
          },
        },
      },
    }
  },

  -- Bookmark places and quickly navigate between them
  {
    "ThePrimeagen/harpoon",
    event = "VimEnter",
    config = function()
      require("harpoon").setup {}
      require("telescope").load_extension "harpoon"
    end,
  },

  -- LSP enhancements
  {
    'ranjithshegde/ccls.nvim',
    event = "VeryLazy",
  },
  {
    -- 'nvimdev/lspsaga.nvim',
    'lspsaga.nvim',
    dir = '/home/tripham/Dev/Playground_Terminal/Neovim_Awesome/lspsaga.nvim',
    after = 'nvim-lspconfig',
    config = function()
      require('lspsaga').setup({
        symbol_in_winbar = {
          enable = true,
        },
        finder = {
          max_height = 0.7,
          max_width = 0.7,
        },
        outline = {
          layout = 'float',
          win_width = 70,
        }
      })
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons'      -- optional
    }
  },

  -- Motion plugins
  {
    'folke/flash.nvim',
    opts = {},
    keys = {
      { "<leader>F", mode = { "n", "x", "o" }, function() require("flash").jump() end,   desc = "Flash" },
      {
        "<leader>S",
        mode = { "n", "o", "x" },
        function() require("flash").treesitter() end,
        desc =
        "Flash Treesitter"
      },
      { "r",         mode = "o",               function() require("flash").remote() end, desc = "Remote Flash" },
      {
        "R",
        mode = { "o", "x" },
        function() require("flash").treesitter_search() end,
        desc =
        "Treesitter Search"
      },
      {
        "<c-s>",
        mode = { "c" },
        function() require("flash").toggle() end,
        desc =
        "Toggle Flash Search"
      },
    },
  },
  {
    'terryma/vim-expand-region',
    lazy = false,
  },
  {
    'kkoomen/vim-doge',
    build = ':call doge#install()'
  },
}
