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
}
