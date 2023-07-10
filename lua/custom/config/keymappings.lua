lvim.keys.normal_mode["<C-Left>"] = false
local opts = {
      mode = "n", -- NORMAL mode
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    }
local mappings = {
      ["<C-Left>"] = { ":vertical resize -2<CR>", "Resize with arrow left" }
}

local which_key = require "which-key"
which_key.register(mappings, opts)

