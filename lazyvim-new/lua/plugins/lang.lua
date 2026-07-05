-- Language-specific plugins not fully covered by LazyVim lang Extras.
-- NOTE: TypeScript uses LazyVim's default vtsls (from extras.lang.typescript).
-- The old setup used typescript-tools.nvim; to switch back, disable vtsls and add
-- pmizio/typescript-tools.nvim. Kept on vtsls here to avoid two TS servers.
return {
  -- ---- Python ----
  {
    "linux-cultist/venv-selector.nvim",
    branch = "regexp",
    ft = "python",
    dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim" },
    cmd = { "VenvSelect", "VenvSelectCached" },
    opts = {
      options = {
        notify_user_on_venv_activation = true,
        fd_binary_name = "fd",
        enable_default_searches = true,
        enable_cached_venvs = true,
        cached_venv_automatic_activation = true,
      },
    },
  },
  {
    "benomahony/uv.nvim",
    ft = "python",
    opts = { picker_integration = true },
  },
  { "nvim-neotest/neotest-python", ft = "python" },

  -- ---- Go ----
  {
    "ray-x/go.nvim",
    dependencies = { "ray-x/guihua.lua", "neovim/nvim-lspconfig", "nvim-treesitter/nvim-treesitter" },
    ft = { "go", "gomod" },
    build = ':lua require("go.install").update_all_sync()',
    opts = {},
    config = function(_, opts)
      require("go").setup(opts)
    end,
  },

  -- ---- Rust: keep LazyVim's rustaceanvim, add the user's <leader>R keys ----
  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft = { "rust" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function(ev)
          local o = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "<leader>Rr", "<cmd>RustLsp run<CR>", o)
          vim.keymap.set("n", "<leader>RR", "<cmd>RustLsp runnables<CR>", o)
          vim.keymap.set("n", "<leader>Rd", "<cmd>RustLsp debug<CR>", o)
          vim.keymap.set("n", "<leader>RD", "<cmd>RustLsp debuggables<CR>", o)
          vim.keymap.set("n", "<leader>lA", "<cmd>RustLsp hover actions<CR>", o)
          vim.keymap.set("n", "<leader>la", "<cmd>RustLsp codeAction<CR>", o)
        end,
      })
    end,
  },

  -- ---- Dart / Flutter ----
  {
    "akinsho/flutter-tools.nvim",
    ft = { "dart" },
    dependencies = { "nvim-lua/plenary.nvim", "stevearc/dressing.nvim" },
    opts = {
      debugger = { enabled = true, run_via_dap = true },
      dev_log = { enabled = false },
    },
  },

  -- ---- Quarto / REPL ----
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dependencies = { "jmbuhr/otter.nvim" },
    opts = {
      lspFeatures = { languages = { "r", "python", "julia", "bash", "html", "lua" } },
    },
    keys = {
      { "<leader>qa", "<cmd>QuartoActivate<cr>", desc = "Quarto activate" },
      { "<leader>qp", "<cmd>QuartoPreview<cr>", desc = "Quarto preview" },
      { "<leader>qq", "<cmd>QuartoClosePreview<cr>", desc = "Quarto close preview" },
      { "<leader>qra", "<cmd>QuartoSendAll<cr>", desc = "Quarto run all" },
      { "<leader>qrr", "<cmd>QuartoSendAbove<cr>", desc = "Quarto run to cursor" },
    },
  },
  {
    "jpalardy/vim-slime",
    ft = { "python", "quarto", "markdown" },
    init = function()
      vim.g.slime_target = "neovim"
      vim.g.slime_python_ipython = 1
    end,
  },

  -- ---- C / C++ tooling ----
  {
    "madskjeldgaard/cppman.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    ft = { "c", "cpp" },
    keys = {
      { "<leader>Cc", function() require("cppman").open_cppman_for(vim.fn.expand("<cword>")) end, desc = "Cppman: word" },
      { "<leader>Cs", function() require("cppman").input() end, desc = "Cppman: search" },
    },
    config = true,
  },
  {
    "Badhi/nvim-treesitter-cpp-tools",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    ft = { "c", "cpp" },
    opts = {},
    config = true,
  },
  { "ranjithshegde/ccls.nvim", ft = { "c", "cpp", "objc", "objcpp" } },

  -- ---- JSON / YAML ----
  { "gennaro-tedesco/nvim-jqx", ft = { "json", "yaml" } },

  -- ---- Markdown ----
  {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    build = "cd app && npm install",
    init = function()
      vim.g.mkdp_auto_close = true
      vim.g.mkdp_open_ip = "127.0.0.1"
      vim.g.mkdp_port = "8888"
      vim.g.mkdp_theme = "light"
    end,
    keys = { { "<leader>M", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown preview" } },
  },

  -- ---- Misc language tools ----
  {
    "tomiis4/Hypersonic.nvim",
    cmd = "Hypersonic",
    event = "CmdlineEnter",
    opts = {},
  },
  {
    "kkoomen/vim-doge",
    build = ":call doge#install()",
    cmd = "DogeGenerate",
    keys = { { "<leader>D", "<cmd>DogeGenerate doxygen_javadoc<cr>", desc = "Doge: generate docs" } },
  },
  {
    "weirongxu/plantuml-previewer.vim",
    ft = { "plantuml" },
    dependencies = { "tyru/open-browser.vim", "aklt/plantuml-syntax" },
  },
}
