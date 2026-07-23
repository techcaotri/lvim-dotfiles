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

  -- Command line AND command output at the BOTTOM (classic), like LunarVim -- not
  -- noice's centered popup. LazyVim enables noice's cmdline popup + command_palette
  -- preset by default. We:
  --   * route the cmdline input back to the classic bottom line (cmdline.view), and
  --   * let Neovim render messages / :command output natively on the bottom line
  --     (messages.enabled = false) instead of noice popups/splits.
  -- Search (/, ?) stays at the bottom. Notifications still go through snacks; noice
  -- LSP hover/signature popups are untouched. (cmdheight=0 is set in
  -- config/options.lua so there is no blank command-line row under the statusline.)
  {
    "folke/noice.nvim",
    opts = {
      cmdline = { view = "cmdline" },
      messages = { enabled = false },
      presets = { command_palette = false, long_message_to_split = false },
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

      -- Banner: "TP's LVim" in the same ANSI-Shadow style as the default LazyVim
      -- logo. Colored via the SnacksDashboardHeader highlight -- see
      -- colorscheme.lua (catppuccin custom_highlights -> mocha mauve accent).
      opts.dashboard.preset.header = [[
████████╗ ██████╗  ██╗ ███████╗    ██╗       ██╗   ██╗ ██╗ ███╗   ███╗
╚══██╔══╝ ██╔══██╗ ╚═╝ ██╔════╝    ██║       ██║   ██║ ╚═╝ ████╗ ████║
   ██║    ██████╔╝     ███████╗    ██║       ██║   ██║ ██╗ ██╔████╔██║
   ██║    ██╔═══╝      ╚════██║    ██║       ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║
   ██║    ██║          ███████║    ███████╗   ╚████╔╝  ██║ ██║ ╚═╝ ██║
   ╚═╝    ╚═╝          ╚══════╝    ╚══════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝
]]

      local keys = opts.dashboard.preset.keys or {}

      -- Recent Files should list ALL recent files, not just the current
      -- project/root. LazyVim's default "r" action routes through LazyVim.pick,
      -- which injects cwd = LazyVim.root() and thus scopes oldfiles to the
      -- project. root=false disables that scoping so every recent file shows.
      for _, k in ipairs(keys) do
        if k.key == "r" then
          k.action = ':lua LazyVim.pick("oldfiles", { root = false })()'
          k.desc = "Recent Files (all)"
        end
      end

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
