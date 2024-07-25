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
    'nvim-pack/nvim-spectre',
    config = function()
      vim.keymap.set('n', '<leader>S', function()
        require('spectre').open({
          is_insert_mode = true,
          -- the directory where the search tool will be started in
          cwd = ".",
          is_close = false, -- close an exists instance of spectre and open new
        })
      end, {
        desc = "Toggle Spectre"
      })
      vim.keymap.set('n', '<leader>Sw', '<cmd>lua require("spectre").open_visual({select_word=true})<CR>', {
        desc = "Spectre: Search current word"
      })
      vim.keymap.set('n', '<leader>Sp', '<cmd>lua require("spectre").open_file_search({select_word=true})<CR>', {
        desc = "Spectre: Search on current file"
      })
      vim.keymap.set('v', '<leader>Sw', '<cmd>lua require("spectre").open_visual({select_word=false})<CR>', {
        desc = "Spectre: Search current word"
      })
      require('spectre').setup({
        cwd = '.',
      })
    end
  },

  {
    'sindrets/diffview.nvim',
  },

  -- image preview
  {
    "3rd/image.nvim",
    event = "VeryLazy",
    dependencies = {
      {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
          require("nvim-treesitter.configs").setup({
            ensure_installed = { "markdown" },
            highlight = { enable = true },
          })
        end,
      },
    },
    opts = {
      backend = "kitty",
      integrations = {
        markdown = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "markdown", "vimwiki" }, -- markdown extensions (ie. quarto) can go here
        },
        neorg = {
          enabled = true,
          clear_in_insert_mode = false,
          download_remote_images = true,
          only_render_image_at_cursor = false,
          filetypes = { "norg" },
        },
      },
      max_width = nil,
      max_height = nil,
      max_width_window_percentage = nil,
      max_height_window_percentage = 50,
      kitty_method = "normal",
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
  {
    "cbochs/portal.nvim",
    -- Optional dependencies
    config = function()
      vim.keymap.set("n", "<leader>o", "<cmd>Portal jumplist backward<cr>")
      vim.keymap.set("n", "<leader>i", "<cmd>Portal jumplist forward<cr>")
    end,
    dependencies = {
      "cbochs/grapple.nvim",
      "ThePrimeagen/harpoon"
    },
  }
}
