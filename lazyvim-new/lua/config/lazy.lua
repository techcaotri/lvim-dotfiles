-- Bootstrap lazy.nvim, LazyVim, and this config's plugin specs.
-- This mirrors the official LazyVim starter, plus a curated set of "Extras"
-- (language packs, DAP, tests, telescope picker, yanky, copilot) chosen to match
-- the functionality of the previous LunarVim setup.

local lazypath = vim.env.LAZY or vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core (defaults + its plugin specs)
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- ---- Extras: editor / coding / debugging / testing ----
    -- Telescope as the picker (this config is telescope-heavy)
    { import = "lazyvim.plugins.extras.editor.telescope" },
    -- Yank ring (replaces the LunarVim yanky.nvim setup)
    { import = "lazyvim.plugins.extras.coding.yanky" },
    -- Debugging (nvim-dap + dap-ui + virtual text)
    { import = "lazyvim.plugins.extras.dap.core" },
    -- Testing (neotest)
    { import = "lazyvim.plugins.extras.test.core" },
    -- AI: GitHub Copilot
    { import = "lazyvim.plugins.extras.ai.copilot" },

    -- ---- Extras: language packs ----
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.clangd" },
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    -- NOTE: lang.typescript (vtsls) is intentionally NOT imported; the user's setup
    -- uses typescript-tools.nvim instead (see lua/plugins/lang.lua).
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.markdown" },
    { import = "lazyvim.plugins.extras.lang.cmake" },
    { import = "lazyvim.plugins.extras.lang.java" },

    -- ---- This config's own specs (override + add user plugins) ----
    { import = "plugins" },
  },
  defaults = {
    -- LazyVim uses lazy-loading; user specs can still opt into eager loading.
    lazy = false,
    version = false,
  },
  install = { colorscheme = { "catppuccin", "tokyonight", "habamax" } },
  checker = { enabled = true, notify = false }, -- background update checks
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
