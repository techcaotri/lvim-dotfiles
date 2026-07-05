-- Telescope + extensions, ported from the LunarVim setup.
-- NOTE: the two-column custom entry_maker (telescope-custom.lua) is intentionally
-- left out to reduce risk; default display is used. It can be re-added later.
return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      "kkharji/sqlite.lua",
      "nvim-telescope/telescope-ui-select.nvim",
      "nvim-telescope/telescope-smart-history.nvim",
      "nvim-telescope/telescope-live-grep-args.nvim",
      "nvim-telescope/telescope-file-browser.nvim",
      "nvim-telescope/telescope-symbols.nvim",
      "debugloop/telescope-undo.nvim",
      { "nvim-telescope/telescope-frecency.nvim", version = "^1.0.0" },
    },
    keys = {
      { "<leader>u", "<cmd>Telescope undo<cr>", desc = "Undo history" },
    },
    opts = function(_, opts)
      local actions = require("telescope.actions")
      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        layout_strategy = "horizontal",
        layout_config = { width = 0.90, height = 0.65, preview_width = 0.4 },
        cache_picker = false,
        mappings = {
          i = {
            ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
            ["<C-Down>"] = actions.cycle_history_next,
            ["<C-Up>"] = actions.cycle_history_prev,
          },
        },
        history = {
          path = vim.fn.expand("~/.local/share/nvim/databases/telescope_history.sqlite3"),
          limit = 100,
        },
      })
      opts.extensions = vim.tbl_deep_extend("force", opts.extensions or {}, {
        ["ui-select"] = require("telescope.themes").get_dropdown(),
        live_grep_args = { auto_quoting = true },
        frecency = {
          show_scores = true,
          show_unindexed = true,
          ignore_patterns = { "*.git/*", "*/tmp/*" },
          db_validate_threshold = 50,
          disable_devicons = false,
          workspaces = {
            conf = vim.fn.expand("~/.config"),
            app_data = vim.fn.expand("~/.local/share"),
            project = vim.fn.expand("~/Dev/"),
          },
        },
      })
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      for _, ext in ipairs({
        "fzf",
        "ui-select",
        "smart_history",
        "live_grep_args",
        "frecency",
        "undo",
        "file_browser",
        "possession",
      }) do
        pcall(telescope.load_extension, ext)
      end
    end,
  },
}
