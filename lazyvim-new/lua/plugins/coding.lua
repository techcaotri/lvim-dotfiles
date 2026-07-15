-- Treesitter + completion tweaks.
-- Completion: LazyVim's default is blink.cmp (kept). To restore nvim-cmp instead,
-- add { import = "lazyvim.plugins.extras.coding.nvim-cmp" } to config/lazy.lua.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ignore_install = opts.ignore_install or {}
      vim.list_extend(opts.ignore_install, { "dart" })
      opts.indent = opts.indent or {}
      opts.indent.disable = { "yaml", "python", "dart" }
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, {
          "c", "cpp", "python", "go", "rust", "lua", "json", "yaml",
          "bash", "markdown", "markdown_inline", "javascript", "typescript", "tsx",
        })
      end
    end,
  },
  -- Inspect the treesitter tree.
  { "nvim-treesitter/playground", cmd = { "TSPlaygroundToggle", "TSHighlightCapturesUnderCursor" } },

  -- Completion muscle memory: LunarVim's cmp used <C-j>/<C-k> to select items and
  -- <C-Space>/<C-e> to open/abort. Map the same on blink.cmp.
  {
    "saghen/blink.cmp",
    optional = true,
    opts = {
      keymap = {
        ["<C-j>"] = { "select_next", "fallback" },
        ["<C-k>"] = { "select_prev", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide", "fallback" },
        -- Keep Tab OFF the Copilot-accept path (Copilot is accepted with <M-l>).
        -- Defining <Tab> here also stops LazyVim's blink config from splicing
        -- ai_accept into it; Tab still jumps snippets, else falls through.
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
    },
  },

  -- Autopairs: LunarVim used nvim-autopairs (treesitter checks, <M-e> fast wrap).
  -- Replace LazyVim's default mini.pairs to keep identical pairing behavior.
  { "nvim-mini/mini.pairs", enabled = false },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      check_ts = true,
      ts_config = { lua = { "string", "source" }, javascript = { "string", "template_string" } },
      disable_filetype = { "TelescopePrompt", "spectre_panel" },
      fast_wrap = {
        map = "<M-e>",
        chars = { "{", "[", "(", '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], "%s+", ""),
        offset = 0,
        end_key = "$",
        keys = "qwertyuiopzxcvbnmasdfghjkl",
        check_comma = true,
        highlight = "Search",
        highlight_grey = "Comment",
      },
    },
  },
}
