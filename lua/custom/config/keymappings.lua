lvim.keys.normal_mode["<C-Left>"] = false
local opts = {
      mode = "n", -- NORMAL mode
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    }
local mappings = {
    -- Better window movement
    ["<C-h>"] = { "<C-w>h", "Window move Left" },
    ["<C-j>"] = { "<C-w>j", "Window move Down" },
    ["<C-k>"] = { "<C-w>k", "Window move Up" },
    ["<C-l>"] = { "<C-w>l", "Window move Right" },

    -- Resize with arrows
    ["<C-Up>"] = { ":resize -2<CR>", "Window resize Horizontal Decrease " },
    ["<C-Down>"] = { ":resize +2<CR>", "Window resize Horizontal Increase" },
    ["<C-Left>"] = { ":vertical resize -2<CR>", "Window resize Vertical Decrease" },
    ["<C-Right>"] = { ":vertical resize +2<CR>", "Window resize Vertical Increase" } ,

    -- Move current line / block with Alt-j/k a la vscode.
    ["<A-j>"] = { ":m .+1<CR>==", "Move current line/block Up" },
    ["<A-k>"] = { ":m .-2<CR>==", "Move current line/block Down" },

    -- QuickFix
    ["]q"] = { ":cnext<CR>", "QuickFix Next" },
    ["[q"] = { ":cprev<CR>", "QuickFix Prev" },
    ["<C-q>"] = { ":call QuickFixToggle()<CR>", "QuickFix Toggle" },

}

local leader_mappings_opts = {
      mode = "n", -- NORMAL mode
      prefix = "<leader>",
      buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
      silent = true, -- use `silent` when creating keymaps
      noremap = true, -- use `noremap` when creating keymaps
      nowait = true, -- use `nowait` when creating keymaps
    }

local leader_mappings = {
    -- Set line number
    n = {
      name = "LineNumbers",
      ["r"] = { ":set relativenumber!<CR>", "Toggle relative number" },
      ["n"] = { ":set number!<CR>", "Toggle number" },
    },
}

local which_key = require "which-key"
which_key.register(mappings, opts)
which_key.register(leader_mappings, leader_mappings_opts)
