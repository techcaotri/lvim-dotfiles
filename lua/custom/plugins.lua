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
        name = { "venv", ".venv", ".linux-venv" }, -- NOTE: You can also use a lua table here for multiple names: {"venv", ".venv"}`

        -- fd_binary_name (default: fd) - The name of the fd binary on your system. Some Debian based Linux Distributions like Ubuntu use ´fdfind´.
        fd_binary_name = "fd",


        -- notify_user_on_activate (default: true) - Prints a message that the venv has been activated
        notify_user_on_activate = true,

      })
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
}
