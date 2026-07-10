-- LSP UI + server tweaks. LazyVim's lang Extras (imported in config/lazy.lua)
-- provide the actual servers (clangd, gopls, jsonls, yamlls, jdtls, rust-analyzer
-- via rustaceanvim, pyright/basedpyright). Here we add the UI plugins and the
-- server-specific overrides the user relied on.
return {
  -- LspSaga (call hierarchy, peek, finder, rename, outline) -- <leader>ls* keys.
  {
    "nvimdev/lspsaga.nvim",
    event = "LspAttach",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    opts = {
      symbol_in_winbar = { enable = true },
      finder = { max_height = 0.7, left_width = 0.3, right_width = 0.4 },
      outline = { layout = "float", max_height = 0.7, win_width = 70 },
    },
  },

  -- Glance (peek definitions/references) -- gD/gR/gY/gM keys.
  { "dnlhc/glance.nvim", cmd = "Glance", opts = {} },

  -- Symbols outline sidebar -- <leader>o.
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = { { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle Outline" } },
    opts = {},
  },

  -- Server-specific overrides layered onto LazyVim's lspconfig setup.
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}

      -- Retire LazyVim's <leader>c (+code) LSP keymaps at the source: each one is
      -- mirrored under <leader>l (+LSP), and <leader>c now closes the buffer (see
      -- config/keymaps.lua). Disabling via the '*' server keys with {lhs,false} is
      -- deterministic -- no LspAttach ordering race.
      opts.servers["*"] = opts.servers["*"] or {}
      opts.servers["*"].keys = opts.servers["*"].keys or {}
      vim.list_extend(opts.servers["*"].keys, {
        -- ca/cc are mode {n,x} in LazyVim; a bare {lhs,false} only disables "n",
        -- so name the modes to also drop the visual-mode variants.
        { "<leader>ca", false, mode = { "n", "x" } },
        { "<leader>cc", false, mode = { "n", "x" } },
        { "<leader>cA", false }, { "<leader>cC", false }, { "<leader>cr", false },
        { "<leader>cR", false }, { "<leader>cl", false }, { "<leader>co", false },
      })

      -- html also handles .jsp (matches lvim.lsp.manager("html", { filetypes = ... })).
      opts.servers.html = vim.tbl_deep_extend("force", opts.servers.html or {}, {
        filetypes = { "html", "jsp" },
      })

      -- bash LSP (no LazyVim lang.sh extra); also attach to zsh (LunarVim did).
      opts.servers.bashls = vim.tbl_deep_extend("force", opts.servers.bashls or {}, {
        filetypes = { "sh", "zsh", "bash" },
      })

      -- ccls: secondary C/C++ server used for call-hierarchy (clangd stays primary).
      opts.servers.ccls = {
        offset_encoding = "utf-32",
        init_options = {
          compilationDatabaseDirectory = "build",
          cache = { directory = vim.fs.normalize("~/.cache/ccls/") },
        },
      }

      -- lua_ls inlay hints (matches lua_ls.lua override).
      opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, {
        settings = { Lua = { hint = { enable = true } } },
      })

      -- CSS/SCSS/LESS server (was in LunarVim's mason ensure_installed).
      opts.servers.cssls = opts.servers.cssls or {}

      -- Jinja templates -- the .jinja/.jinja2/.j2 filetype is registered in
      -- config/autocmds.lua; jinja_lsp is a Mason package (jinja-lsp).
      opts.servers.jinja_lsp = opts.servers.jinja_lsp or {}

      -- CMake language server (LunarVim ran it alongside neocmake from lang.cmake).
      opts.servers.cmake = opts.servers.cmake or {}

      -- Qt QML: qmlls ships with Qt (not a Mason package), so skip Mason and point
      -- at the Qt6 binary (matches the old lsp/init.lua qmlls cmd).
      opts.servers.qmlls = {
        mason = false,
        cmd = { "/home/tripham/Qt_new/6.8.0/gcc_64/bin/qmlls", "--verbose" },
      }
    end,
  },

  -- Extra Mason tools the user installed (formatters/linters).
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "prettierd",
        "shfmt",
        "shellcheck",
        "stylua",
        "isort",
        "flake8",
        "cmake-language-server",
        -- C/C++ debugging: the cppdbg DAP adapter (plugins/dap.lua) launches
        -- mason's cpptools OpenDebugAD7 binary.
        "cpptools",
        "clang-format",
      })
    end,
  },

  -- Shell formatting with shfmt (installed via Mason above). LazyVim's conform
  -- default maps only the `sh` filetype; also map `bash` so shfmt formats shell
  -- scripts however Neovim detects their filetype. shfmt does not support zsh
  -- syntax, so zsh is intentionally left unmapped.
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.sh = opts.formatters_by_ft.sh or { "shfmt" }
      opts.formatters_by_ft.bash = { "shfmt" }
    end,
  },
}
