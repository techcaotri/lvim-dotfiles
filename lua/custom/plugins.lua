lvim.plugins = {
  {
    -- "p00f/clangd_extensions.nvim",
    "Toni500github/clangd_extensions.nvim",
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
          },
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
    config = function()
      require("telescope").setup {
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown {
              -- even more opts
            }
          }
        }
      }
      -- To get fzf loaded and working with telescope, you need to call
      -- load_extension, somewhere after setup function:
      require("telescope").load_extension("ui-select")
    end,
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
  {
    "tpope/vim-fugitive",
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
    branch = "regexp",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    config = function()
      require('custom.config.venv-selector').config()
    end,
  },

  -- Colorschemes and themes
  {
    'techcaotri/Colorschemes',
    lazy = false,
  },
  { "catppuccin/nvim", name = "catppuccin", priority = 1000
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
      vim.g.mkdp_theme = 'light'
    end,
  },

  -- revamp menu ui for vim.ui.select and vim.ui.input
  {
    'stevearc/dressing.nvim',
    opts = {
      select = {
        enabled = true,
        backend = { "telescope", "fzf", "fzf_lua", "builtin" },
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
    'chentoast/marks.nvim',
    config = function()
      require('marks').setup({
        -- whether to map keybinds or not. default true
        default_mappings = false,
        -- whether movements cycle back to the beginning/end of buffer. default true
        cyclic = true,
        bookmark_0 = { sign = "⚑", virt_text = "->" },
        mappings = {
          set_next = "<leader>m,",
          delete = "<leader>mx",
          delete_line = '<leader>md',
          delete_buf = '<leader>mD',
          next = "<leader>mn",
          prev = "<leader>mp",
          preview = "<leader>m:",
          set_bookmark0 = "<leader>m0",
          set_bookmark1 = '<leader>m1',
          set_bookmark2 = '<leader>m2',
          set_bookmark3 = '<leader>m3',
          set_bookmark4 = '<leader>m4',
          set_bookmark5 = '<leader>m5',
          set_bookmark6 = '<leader>m6',
          set_bookmark7 = '<leader>m7',
          set_bookmark8 = '<leader>m8',
          set_bookmark9 = '<leader>m9',
        },
      })
    end
  },

  -- LSP enhancements
  {
    'ranjithshegde/ccls.nvim',
    event = "VeryLazy",
  },
  {
    'nvimdev/lspsaga.nvim',
    -- 'lspsaga.nvim',
    -- dir = '/home/tripham/Dev/Playground_Terminal/Neovim_Awesome/lspsaga.nvim',
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
    -- require('highlight-undo').setup({
    -- hlgroup = 'HighlightUndo',
    -- duration = 500,
    -- keymaps = {
    --   { 'n', 'u',     'undo', {} },
    --   { 'n', '<c-r>', 'redo', {} },
    -- }
    -- })
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
      vim.keymap.set("n", "<leader>Cc", function()
          cppman.open_cppman_for(vim.fn.expand("<cword>"))
        end,
        { desc = '[C]PPman word under [c]ursor' }
      )

      -- Open search box
      vim.keymap.set("n", "<leader>Cs", function()
          cppman.input()
        end,
        { desc = '[C]PPman open [s]earchbox' }
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
    config = function()
      require('flutter-tools').setup {
        -- (uncomment below line for windows only)
        -- flutter_path = "home/flutter/bin/flutter.bat",

        debugger = {
          -- make these two params true to enable debug mode
          enabled = true,
          run_via_dap = true,
          register_configurations = function(_)
            require("dap").configurations.dart = {
              {
                type = "dart",
                request = "launch",
                name = "Launch flutter",
                dartSdkPath = '/home/tripham/Dev/flutter/bin/cache/dart-sdk/',
                flutterSdkPath = "/home/tripham/Dev/flutter",
                program = "${workspaceFolder}/lib/main.dart",
                cwd = "${workspaceFolder}",
              }
            }
            -- uncomment below line if you've launch.json file already in your vscode setup
            require("dap.ext.vscode").load_launchjs()
          end,
        },
        dev_log = {
          -- toggle it when you run without DAP
          enabled = false,
          open_cmd = "tabedit",
        },
      }
    end,
  },

  {
    "lmburns/lf.nvim",
    config = function(_, opts)
      -- This feature will not work if the plugin is lazy-loaded
      vim.g.lf_netrw = 1

      require("lf").setup({
        escape_quit = false,
        border = "rounded",
        default_cmd = "lfrun",
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
    'MagicDuck/grug-far.nvim',
    tag = "1.6.3",
    init = function()
      local function grugfar(mode, wincmd, current_word, current_file)
        return function()
          local caller
          if mode == 'n' then
            caller = 'open'
          else
            -- send control-u before calling the command
            -- This is required for visual mode
            vim.api.nvim_feedkeys('\27', 'nx', false)
            caller = 'with_visual_selection'
          end
          require('grug-far')[caller] {
            windowCreationCommand = wincmd,
            prefills = {
              search = mode == 'n' and current_word and vim.fn.expand '<cword>',
              paths = current_file and vim.fn.expand '%',
              flags = '--sort=path',
            },
          }
        end
      end
      for _, mode in ipairs { 'n', 'v' } do
        local keymap = vim.api.nvim_set_keymap
        keymap(mode, '<Leader>S', '', {
          callback = grugfar(mode, 'tabnew', nil, nil),
          desc = 'Search and Replace',
        })
        keymap(mode, '<Leader>Ss', '', {
          callback = grugfar(mode, 'split', true, nil),
          desc = 'hsplit: S/R selected words',
        })
        keymap(mode, '<Leader>Sv', '', {
          callback = grugfar(mode, 'vsplit', nil, nil),
          desc = 'vsplit: S/R selected words',
        })
        keymap(mode, '<Leader>St', '', {
          callback = grugfar(mode, 'tabnew', true, nil),
          desc = 'tabnew: S/R of selected words',
        })
        keymap(mode, '<Leader>Sf', '', {
          callback = grugfar(mode, 'vsplit', true, true),
          desc = 'vsplit: S/R selected words in current file',
        })
      end
    end,
    config = function()
      require('grug-far').setup { startInInsertMode = false }
    end,
  },

  {
    'sindrets/diffview.nvim',
  },

  -- image preview
  -- Fix the issue: luarocks unable to install 'magick' with lua version > 5.1. Reference: https://github.com/3rd/image.nvim/issues/124#issuecomment-2030392795
  {
    "vhyrro/luarocks.nvim",
    priority = 1001,
    opts = {
      rocks = { "magick" },
    },
  },

  -- Selecting files from your editing history
  {
    'nvim-telescope/telescope-frecency.nvim',
    config = function()
      require("telescope").setup {
        extensions = {
          frecency = {
            show_scores = true,
            show_unindexed = true,
            ignore_patterns = { "*.git/*", "*/tmp/*" },
            db_validate_threshold = 50,
            disable_devicons = false,
            workspaces = {
              workspaces = {
                ["conf"]     = "/home/tripham/.config",
                ["app_data"] = "/home/tripham/.local/share",
                ["project"]  = "/home/tripham/Dev/",
              }
            }
          }
        },
      }
      require("telescope").load_extension "frecency"
    end,
  },

  -- Google translate
  {
    'uga-rosa/translate.nvim',
    config = function()
      require("translate").setup({
        default = {
          command = "translate_shell",
          output = "insert",
          parse_before = "trim",
        },
      })
    end,
  },

  -- Java
  {
    'mfussenegger/nvim-jdtls',
    ft = { 'java' },
    config = function()
      local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

      local workspace_dir = '/home/tripham/.cache/nvim/javajdlts/' .. project_name

      -- See `:help vim.lsp.start_client` for an overview of the supported `config` options.
      local config = {
        -- The command that starts the language server
        -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
        cmd = {

          -- 💀
          'java', -- or '/path/to/java11_or_newer/bin/java'
          -- depends on if `java` is in your $PATH env variable and if it points to the right version.

          '-Declipse.application=org.eclipse.jdt.ls.core.id1',
          '-Dosgi.bundles.defaultStartLevel=4',
          '-Declipse.product=org.eclipse.jdt.ls.core.product',
          '-Dlog.protocol=true',
          '-Dlog.level=ALL',
          '-Xms1g',
          '--add-modules=ALL-SYSTEM',
          '--add-opens', 'java.base/java.util=ALL-UNNAMED',
          '--add-opens', 'java.base/java.lang=ALL-UNNAMED',

          -- 💀
          -- See `data directory configuration` section in the README
          '-data', workspace_dir,
        },

        -- 💀
        -- This is the default if not provided, you can remove it. Or adjust as needed.
        -- One dedicated LSP server & client will be started per unique root_dir
        root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew' }),

        -- Here you can configure eclipse.jdt.ls specific settings
        -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
        -- for a list of options
        settings = {
          java = {
          }
        },

        -- Language server `initializationOptions`
        -- You need to extend the `bundles` with paths to jar files
        -- if you want to use additional eclipse.jdt.ls plugins.
        --
        -- See https://github.com/mfussenegger/nvim-jdtls#java-debug-installation
        --
        -- If you don't plan on using the debugger or other eclipse.jdt.ls plugins you can remove this
        init_options = {
          bundles = {}
        },
      }
      require('jdtls').start_or_attach(config)
    end
  },

  -- telescope undo
  {
    "debugloop/telescope-undo.nvim",
    dependencies = { -- note how they're inverted to above example
      {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
      },
    },
    keys = {
      { -- lazy style key map
        "<leader>u",
        "<cmd>Telescope undo<cr>",
        desc = "undo history",
      },
    },
    opts = {
      -- don't use `defaults = { }` here, do this in the main telescope spec
      extensions = {
        undo = {
          -- telescope-undo.nvim config, see below
        },
        -- no other extensions here, they can have their own spec too
      },
    },
    config = function(_, opts)
      -- Calling telescope's setup from multiple specs does not hurt, it will happily merge the
      -- configs for us. We won't use data, as everything is in it's own namespace (telescope
      -- defaults, as well as each extension).
      require("telescope").setup(opts)
      require("telescope").load_extension("undo")
    end,
  },

  -- json formatter
  {
    "gennaro-tedesco/nvim-jqx",
    ft = { "json", "yaml" },
  },

  -- common formatter
  {
    "mhartington/formatter.nvim",
  },

  -- Go multi tool
  {
    "ray-x/go.nvim",
    dependencies = { -- optional packages
      "ray-x/guihua.lua",
      "neovim/nvim-lspconfig",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("go").setup()
    end,
    event = { "CmdlineEnter" },
    ft = { "go", 'gomod' },
    build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
  },
  -- regex
  {
    'tomiis4/Hypersonic.nvim',
    event = "CmdlineEnter",
    cmd = "Hypersonic",
    config = function()
      require('hypersonic').setup({
        -- config
      })
    end
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {
      stiffness = 0.8,               -- 0.6      [0, 1]
      trailing_stiffness = 0.5,      -- 0.25     [0, 1]
      distance_stop_animating = 0.5, -- 0.1      > 0
      hide_target_hack = false,      -- true     boolean
      legacy_computing_symbols_support = true,
    },
  },
  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false,   -- This plugin is already lazy
    config = function()
      vim.g.rustaceanvim = {
        -- Plugin configuration
        tools = {
        },
        -- LSP configuration
        server = {
          on_attach = function(client, bufnr)
            local wk = require "which-key"
            wk.register({
              ["<leader>lA"] = { "<Cmd>RustLsp hover actions<CR>", "rustaceanvim: Hover Actions" },
              ["<leader>la"] = { "<Cmd>RustLsp codeAction<CR>", "rustaceanvim: Code Actions" },
              ["<leader>R"] = {
                name = "rustaceanvim:",
                r = { "<Cmd>RustLsp[!] run {args[]}?<CR>", "rustaceanvim: Run" },
                R = { "<Cmd>RustLsp[!] runnables {args[]}?<CR>", "rustaceanvim: Runnables" },
                d = { "<Cmd>RustLsp[!] debug {args[]}?<CR>", "rustaceanvim: Debug" },
                D = { "<Cmd>RustLsp[!] debuggables {args[]}?<CR>", "rustaceanvim: Debuggables" },
              },
              ["K"] = { "<Cmd>RustLsp openDocs<CR>", "rustaceanvim: Open Docs" },
            })
          end,
          default_settings = {
            -- rust-analyzer language server configuration
            ['rust-analyzer'] = {
            },
          },
        },
      }
    end
  },
  {
    "AndrewRadev/bufferize.vim",
  },
  -- WINDOWS --
  {
    "JoseConseco/windows.nvim",
    dependencies = {
      "anuvyklack/middleclass",
      "anuvyklack/animation.nvim"
    },
    config = function()
      vim.o.winwidth = 20
      vim.o.winminwidth = 10
      vim.o.equalalways = false
      require('windows').setup()
    end
  },
  {
    "weirongxu/plantuml-previewer.vim",
    dependencies = {
      "tyru/open-browser.vim",
      "aklt/plantuml-syntax",
    },
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- Set this to "*" to always pull the latest release version, or set it to false to update to the latest code changes.
    opts = {
      ---@alias Provider "claude" | "openai" | "azure" | "gemini" | "cohere" | "copilot" | string
      provider = "claude", -- Recommend using Claude
      -- WARNING: Since auto-suggestions are a high-frequency operation and therefore expensive,
      -- currently designating it as `copilot` provider is dangerous because: https://github.com/yetone/avante.nvim/issues/1048
      -- Of course, you can reduce the request frequency by increasing `suggestion.debounce`.
      auto_suggestions_provider = "claude",
      -- claude = {
      --   endpoint = "https://api.anthropic.com",
      --   model = "claude-3-5-haiku-20241022",
      --   temperature = 0,
      --   max_tokens = 8192,
      -- },
      ---Specify the special dual_boost mode
      ---1. enabled: Whether to enable dual_boost mode. Default to false.
      ---2. first_provider: The first provider to generate response. Default to "openai".
      ---3. second_provider: The second provider to generate response. Default to "claude".
      ---4. prompt: The prompt to generate response based on the two reference outputs.
      ---5. timeout: Timeout in milliseconds. Default to 60000.
      ---How it works:
      --- When dual_boost is enabled, avante will generate two responses from the first_provider and second_provider respectively. Then use the response from the first_provider as provider1_output and the response from the second_provider as provider2_output. Finally, avante will generate a response based on the prompt and the two reference outputs, with the default Provider as normal.
      ---Note: This is an experimental feature and may not work as expected.
      dual_boost = {
        enabled = false,
        first_provider = "openai",
        second_provider = "claude",
        prompt =
        "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
        timeout = 60000, -- Timeout in milliseconds
      },
      behaviour = {
        auto_suggestions = false, -- Experimental stage
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
        minimize_diff = true,         -- Whether to remove unchanged lines when applying a code block
        enable_token_counting = true, -- Whether to enable token counting. Default to true.
      },
      mappings = {
        --- @class AvanteConflictMappings
        diff = {
          ours = "co",
          theirs = "ct",
          all_theirs = "ca",
          both = "cb",
          cursor = "cc",
          next = "]x",
          prev = "[x",
        },
        suggestion = {
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
        jump = {
          next = "]]",
          prev = "[[",
        },
        submit = {
          normal = "<CR>",
          insert = "<C-s>",
        },
        sidebar = {
          apply_all = "A",
          apply_cursor = "a",
          switch_windows = "<Tab>",
          reverse_switch_windows = "<S-Tab>",
        },
      },
      hints = { enabled = true },
      windows = {
        ---@type "right" | "left" | "top" | "bottom"
        position = "right", -- the position of the sidebar
        wrap = true,        -- similar to vim.o.wrap
        width = 30,         -- default % based on available width
        sidebar_header = {
          enabled = true,   -- true, false to enable/disable the header
          align = "center", -- left, center, right for title
          rounded = true,
        },
        input = {
          prefix = "> ",
          height = 8, -- Height of the input window in vertical layout
        },
        edit = {
          border = "rounded",
          start_insert = true, -- Start insert mode when opening the edit window
        },
        ask = {
          floating = false,    -- Open the 'AvanteAsk' prompt in a floating window
          start_insert = true, -- Start insert mode when opening the ask window
          border = "rounded",
          ---@type "ours" | "theirs"
          focus_on_apply = "ours", -- which diff to focus after applying
        },
      },
      highlights = {
        ---@type AvanteConflictHighlights
        diff = {
          current = "DiffText",
          incoming = "DiffAdd",
        },
      },
      --- @class AvanteConflictUserConfig
      diff = {
        autojump = true,
        ---@type string | fun(): any
        list_opener = "copen",
        --- Override the 'timeoutlen' setting while hovering over a diff (see :help timeoutlen).
        --- Helps to avoid entering operator-pending mode with diff mappings starting with `c`.
        --- Disable by setting to -1.
        override_timeoutlen = 500,
      },
      suggestion = {
        debounce = 600,
        throttle = 600,
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick",         -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua",              -- for file_selector provider fzf
      "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua",        -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  },
  {
    "gcmt/vessel.nvim",
    config = function()
      require("vessel").setup({
        create_commands = true,
        commands = {
          view_marks = "Marks", -- you can customize each command name
          view_jumps = "Jumps",
          view_buffers = "Buffers",
        },
        marks = {
          toggle_mark = true,
          use_backtick = true,
        },
      })
      vim.api.nvim_set_keymap('n', 'gj', '<Plug>(VesselViewJumps)',
        { noremap = true, silent = true, desc = 'Vessel: View all jumps' })
      vim.api.nvim_set_keymap('n', 'gL', '<Plug>(VesselViewMarks)',
        { noremap = true, silent = true, desc = 'Vessel: View all marks' })
      vim.api.nvim_set_keymap('n', 'gm', '<plug>(VesselSetLocalMark)',
        { noremap = true, silent = true, desc = 'Vessel: Set local marks' })
    end,
  },
  {
    'dnlhc/glance.nvim',
    cmd = 'Glance',
  },
  -- {
  --   'fei6409/log-highlight.nvim',
  --   config = function()
  --     require('log-highlight').setup {}
  --   end,
  -- },
  {
    "powerman/vim-plugin-AnsiEsc",
    lazy = true,
    cmd = {
      "AnsiEsc",
    },
  },
  {
    "hedyhli/outline.nvim",
    config = function()
      -- Example mapping to toggle outline
      vim.keymap.set("n", "<leader>o", "<cmd>Outline<CR>",
        { desc = "Toggle Outline" })

      require("outline").setup {
        -- Your setup opts here (leave empty to use defaults)
      }
    end,
  },
  {
    'andymass/vim-matchup',
    init = function()
      -- modify your configuration vars here
      vim.g.matchup_treesitter_stopline = 500

      -- or call the setup function provided as a helper. It defines the
      -- configuration vars for you
      require('match-up').setup({
        treesitter = {
          stopline = 500
        }
      })
    end,
    -- or use the `opts` mechanism built into `lazy.nvim`. It calls
    -- `require('match-up').setup` under the hood
    ---@type matchup.Config
    opts = {
      treesitter = {
        stopline = 500,
      }
    }
  },
}
