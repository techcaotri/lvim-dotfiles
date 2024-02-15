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
  { "kkharji/sqlite.lua" },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope-smart-history.nvim" },
      { "nvim-telescope/telescope-frecency.nvim" },
      { "kkharji/sqlite.lua" },
    },
    config = function()
      local ts_actions = require('telescope.actions')
      local lga_actions = require('telescope-live-grep-args.actions')
      require('telescope').setup({
        defaults = {
          cache_picker = false,
          mappings = {
            i = {
              ['<C-Down>'] = ts_actions.cycle_history_next,
              ['<C-Up>'] = ts_actions.cycle_history_prev,
            },
          },
          history = {
            path = '~/.local/share/nvim/databases/telescope_history.sqlite3',
            limit = 100,
          }
        },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown {
            }
          },
          live_grep_args = {
            auto_quoting = true,
            mappings = {
              i = {
                ['<C-k>'] = lga_actions.quote_prompt(),
              },
            },
          },
        }
      })

      require('telescope').load_extension('ui-select')
      require('telescope').load_extension('smart_history')
    end
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  },
  {
    'nvim-telescope/telescope-ui-select.nvim',
    lazy = true,
    dependencies = 'nvim-telescope/telescope.nvim',
  },

  {
    'nvim-telescope/telescope-smart-history.nvim',
    lazy = true,
    dependencies = { 'nvim-telescope/telescope.nvim', 'kkharji/sqlite.lua' },
  },

  {
    'nvim-telescope/telescope-live-grep-args.nvim',
    lazy = true,
    dependencies = 'nvim-telescope/telescope.nvim'
  },

  {
    "nvim-treesitter/playground",
    lazy = false,
  },

  -- Context treesitter for showing offset line number
  {
    'nvim-treesitter/nvim-treesitter-context',
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

  -- Tabularize source code
  {
    'junegunn/vim-easy-align',
    config = function()
      vim.cmd [[
          nmap ga <Plug>(EasyAlign)
          xmap ga <Plug>(EasyAlign)
        ]]
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
    keys = { { "<leader>M", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" } },
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
    opts = {
      modes = {
        -- options used when flash is activated through
        -- a regular search with `/` or `?`
        search = {
          -- when `true`, flash will be activated during regular search by default.
          -- You can always toggle when searching with `require("flash").toggle()`
          enabled = false,
        },
      },
    },
    keys = {
      { "<leader>F", mode = { "n", "x", "o" }, function() require("flash").jump() end,   desc = "Flash" },
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
  {
    'HiPhish/rainbow-delimiters.nvim',
  },
  {
    'tzachar/highlight-undo.nvim',
    require('highlight-undo').setup({
      -- hlgroup = 'HighlightUndo',
      -- duration = 500,
      -- keymaps = {
      --   { 'n', 'u',     'undo', {} },
      --   { 'n', '<c-r>', 'redo', {} },
      -- }
    })
  },
  {
    "lambdalisue/suda.vim",
  },

  -- Colorize ANSI escape codes
  {
    'powerman/vim-plugin-AnsiEsc',
    lazy = false,
  },

  -- Cppman cli interface
  {
    'madskjeldgaard/cppman.nvim',
    dependencies = { { 'MunifTanjim/nui.nvim' }
    },
    config = function()
      local cppman = require "cppman"
      cppman.setup()

      -- Make a keymap to open the word under cursor in CPPman
      vim.keymap.set("n", "<leader>mc", function()
          cppman.open_cppman_for(vim.fn.expand("<cword>"))
        end,
        { desc = 'CPP[m]an word under [c]ursor' }
      )

      -- Open search box
      vim.keymap.set("n", "<leader>ms", function()
          cppman.input()
        end,
        { desc = 'CPP[m]an open [s]earchbox' }
      )
    end
  },

  -- C++ header guard generator
  {
    'drmikehenry/vim-headerguard',
  },
  -- C++ implementation from header generator
  {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    -- Optional: Configuration
    opts = function()
      local options = {
        preview = {
          quit = "q",                             -- optional keymapping for quit preview
          accept = "<tab>",                       -- optional keymapping for accept preview
        },
        custom_define_class_function_commands = { -- optional
          TSCppImplWrite = {
            output_handle = require("nt-cpp-tools.output_handlers").get_add_to_cpp(),
          },
          --[[
                <your impl function custom command name> = {
                    output_handle = function (str, context)
                        -- string contains the class implementation
                        -- do whatever you want to do with it
                    end
                }
                ]]
        },
      }
      return options
    end,
    -- End configuration
    config = true,
  },

  -- Add header description
  {
    'alpertuna/vim-header',
  },

  -- Wrapping text
  {
    "andrewferrier/wrapping.nvim",
    config = function()
      require("wrapping").setup({
        create_keymaps = false,
      })
    end
  },

  -- Match quote
  {
    'airblade/vim-matchquote'
  },

  -- Quarto related plugins
  {
    "quarto-dev/quarto-nvim",
    opts = {
      lspFeatures = {
        languages = { 'r', 'python', 'julia', 'bash', 'html', 'lua' },
      },
    },
    ft = "quarto",
    keys = {
      { "<leader>qa",   ":QuartoActivate<cr>",                           desc = "quarto activate" },
      { "<leader>qp",   ":lua require'quarto'.quartoPreview()<cr>",      desc = "quarto preview" },
      { "<leader>qq",   ":lua require'quarto'.quartoClosePreview()<cr>", desc = "quarto close" },
      { "<leader>qh",   ":QuartoHelp ",                                  desc = "quarto help" },
      { "<leader>qe",   ":lua require'otter'.export()<cr>",              desc = "quarto export" },
      { "<leader>qE",   ":lua require'otter'.export(true)<cr>",          desc = "quarto export overwrite" },
      { "<leader>qrr",  ":QuartoSendAbove<cr>",                          desc = "quarto run to cursor" },
      { "<leader>qra",  ":QuartoSendAll<cr>",                            desc = "quarto run all" },
      { "<leader><cr>", ":SlimeSend<cr>",                                desc = "send code chunk" },
      { "<c-cr>",       ":SlimeSend<cr>",                                desc = "send code chunk" },
      {
        "<c-cr>",
        "<esc>:SlimeSend<cr>i",
        mode = "i",
        desc =
        "send code chunk"
      },
      {
        "<c-cr>",
        "<Plug>SlimeRegionSend<cr>",
        mode = "v",
        desc =
        "send code chunk"
      },
      {
        "<cr>",
        "<Plug>SlimeRegionSend<cr>",
        mode = "v",
        desc =
        "send code chunk"
      },
      { "<leader>ctr", ":split term://R<cr>",       desc = "terminal: R" },
      { "<leader>cti", ":split term://ipython<cr>", desc = "terminal: ipython" },
      { "<leader>ctp", ":split term://python<cr>",  desc = "terminal: python" },
      { "<leader>ctj", ":split term://julia<cr>",   desc = "terminal: julia" },
    },
  },

  {
    "jmbuhr/otter.nvim",
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
  },

  -- send code from python/r/qmd documets to a terminal or REPL
  -- like ipython, R, bash
  {
    "jpalardy/vim-slime",
    init = function()
      vim.b["quarto_is_" .. "python" .. "_chunk"] = false
      Quarto_is_in_python_chunk = function()
        require("otter.tools.functions").is_otter_language_context("python")
      end

      vim.cmd([[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      return a:text
      end
      endfunction
      ]])

      local function mark_terminal()
        vim.g.slime_last_channel = vim.b.terminal_job_id
        vim.print(vim.g.slime_last_channel)
      end

      local function set_terminal()
        vim.b.slime_config = { jobid = vim.g.slime_last_channel }
      end

      -- slime, neovvim terminal
      vim.g.slime_target = "neovim"
      vim.g.slime_python_ipython = 1

      require("which-key").register({
        ["<leader>cm"] = { mark_terminal, "mark terminal" },
        ["<leader>cs"] = { set_terminal, "set terminal" },
      })
    end,
  },

  {
    'rcarriga/nvim-notify'
  },
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = true,
  },

  {
    "lmburns/lf.nvim",
    config = function(_, opts)
      -- This feature will not work if the plugin is lazy-loaded
      vim.g.lf_netrw = 1

      require("lf").setup({
        escape_quit = false,
        border = "rounded",
      })

      vim.keymap.set("n", "<M-o>", "<Cmd>Lf<CR>")

      vim.api.nvim_create_autocmd({ "User" }, {
        pattern = "LfTermEnter",
        callback = function(a)
          vim.api.nvim_buf_set_keymap(a.buf, "t", "q", "q", { nowait = true })
        end,
      })
      require("lf").setup(opts)
    end,
    dependencies = { "toggleterm.nvim" }
  },

  {
    'nvim-pack/nvim-spectre',
    config = function()
      vim.keymap.set('n', '<leader>S', '<cmd>lua require("spectre").toggle()<CR>', {
        desc = "Toggle Spectre"
      })
      vim.keymap.set('n', '<leader>Sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
        desc = "Spectre: Search current word"
      })
      vim.keymap.set('n', '<leader>Sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
        desc = "Spectre: Search on current file"
      })
    end
  },

  {
    'sindrets/diffview.nvim',
  },
}
