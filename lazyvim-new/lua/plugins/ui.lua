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

  -- Bufferline: always visible (user override) + LunarVim mouse behavior
  -- (right-click a tab opens that buffer in a vertical split).
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
        right_mouse_command = "vert sbuffer %d",
        left_mouse_command = "buffer %d",
        diagnostics = "nvim_lsp",
      },
    },
  },

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

  -- Command line at the BOTTOM (classic), not the centered popup, for less
  -- distraction. LunarVim shipped no noice cmdline popup; LazyVim enables one by
  -- default, so route the cmdline back to the classic bottom line. Search (/, ?)
  -- also uses the bottom line. Notifications/LSP popups from noice are untouched.
  {
    "folke/noice.nvim",
    opts = {
      cmdline = { view = "cmdline" },
    },
  },

  -- Startup dashboard: list saved possession sessions (ports the old LunarVim
  -- alpha.lua behavior). LazyVim's snacks dashboard only knows about the built-in
  -- "session" source (persistence.nvim), so we append possession sessions —
  -- newest first — as numbered shortcuts before the Quit entry. Read straight from
  -- the session directory on disk so it does not depend on plugin load order.
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      local function session_items()
        local ok, cfg = pcall(require, "possession.config")
        local dir = (ok and cfg and cfg.session_dir) or (vim.fn.stdpath("data") .. "/possession")
        local files = vim.fn.glob(tostring(dir) .. "/*.json", true, true)
        table.sort(files, function(a, b)
          return vim.fn.getftime(a) > vim.fn.getftime(b)
        end)
        local items = {}
        for i, f in ipairs(files) do
          if i > 9 then -- show the 9 most-recent sessions (keys 1-9); rest via <leader>Pf
            break
          end
          local name = vim.fn.fnamemodify(f, ":t:r")
          items[#items + 1] = {
            icon = " ",
            key = tostring(i),
            desc = name,
            action = "<cmd>PossessionLoad " .. vim.fn.fnameescape(name) .. "<cr>",
          }
        end
        return items
      end

      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      local keys = opts.dashboard.preset.keys or {}
      local sess = session_items()
      if #sess > 0 then
        -- Insert the session shortcuts just before the "Quit" entry (or append).
        local quit_idx = #keys + 1
        for i, k in ipairs(keys) do
          if k.key == "q" then
            quit_idx = i
            break
          end
        end
        for j = #sess, 1, -1 do
          table.insert(keys, quit_idx, sess[j])
        end
      end
      opts.dashboard.preset.keys = keys
    end,
  },
}
