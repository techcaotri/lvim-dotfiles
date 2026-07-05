-- UI / aesthetics ported from LunarVim.
return {
  -- Rainbow delimiters (config lives in vim.g, matching the old config.lua).
  {
    "HiPhish/rainbow-delimiters.nvim",
    event = { "BufReadPost", "BufNewFile" },
    init = function()
      vim.g.rainbow_delimiters = {
        query = { [""] = "rainbow-delimiters", javascript = "rainbow-delimiters-react" },
        strategy = { [""] = function() return require("rainbow-delimiters.strategy.global") end },
        log = {
          level = vim.log.levels.WARN,
          file = vim.fn.stdpath("log") .. "/rainbow-delimiters.log",
        },
        highlight = {
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  -- Sticky scope/context header.
  { "nvim-treesitter/nvim-treesitter-context", event = "VeryLazy", opts = {} },

  -- Always show the bufferline (matches lvim.builtin.bufferline.always_show).
  { "akinsho/bufferline.nvim", opts = { options = { always_show_bufferline = true } } },

  -- Inline color-code highlighting.
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = { user_default_options = { names = false } },
  },

  -- Animated cursor.
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
    opts = {
      stiffness = 0.8,
      trailing_stiffness = 0.5,
      distance_stop_animating = 0.5,
      legacy_computing_symbols_support = true,
    },
  },

  -- Show whitespace in visual selection (0.10-compat branch, per the pin strategy).
  {
    "mcauley-penney/visual-whitespace.nvim",
    branch = "compat-v10",
    event = "ModeChanged",
    config = true,
    keys = {
      { "<leader>tw", mode = { "n", "v" }, function() require("visual-whitespace").toggle() end, desc = "Toggle visual whitespace" },
    },
  },
}
