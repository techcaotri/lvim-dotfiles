-- Colorscheme -- match the LunarVim setup (catppuccin-mocha) and keep the user's
-- personal colorscheme pack available for :Telescope colorscheme switching.
return {
  -- User's personal colorscheme collection (same as the LunarVim setup).
  { "techcaotri/Colorschemes", lazy = false, priority = 999 },

  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "mocha",
      -- Dashboard banner ("TP's LVim") in mocha's signature accent color.
      -- mauve = #cba6f7 -- the dark-pink/mauve "master" accent of catppuccin
      -- mocha. Alternatives if a different shade is wanted:
      -- pink = #f5c2e7, maroon = #eba0ac.
      custom_highlights = function(colors)
        return {
          SnacksDashboardHeader = { fg = colors.mauve },
        }
      end,
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        telescope = true,
        which_key = true,
        native_lsp = { enabled = true },
      },
    },
  },
  -- Tell LazyVim to use it.
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-mocha",
    },
  },
}
