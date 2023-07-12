local opts = {
  mode = "n",         -- NORMAL mode
  buffer = nil,       -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,      -- use `silent` when creating keymaps
  noremap = true,     -- use `noremap` when creating keymaps
  nowait = true,      -- use `nowait` when creating keymaps
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
  ["<C-Right>"] = { ":vertical resize +2<CR>", "Window resize Vertical Increase" },

  -- Move current line / block with Alt-j/k a la vscode.
  ["<A-j>"] = { ":m .+1<CR>==", "Move current line/block Up" },
  ["<A-k>"] = { ":m .-2<CR>==", "Move current line/block Down" },

  -- QuickFix
  ["]q"] = { ":cnext<CR>", "QuickFix Next" },
  ["[q"] = { ":cprev<CR>", "QuickFix Prev" },
  ["<C-q>"] = { ":call QuickFixToggle()<CR>", "QuickFix Toggle" },

  -- save
  ["<C-s>"] = { "<cmd> w <CR>", "Save file" },

  -- Copy all
  ["<C-c>"] = { "<cmd> %y+ <CR>", "Copy whole file" },

  -- cycle through buffers
  ["<tab>"] = { "<cmd> BufferLineCycleNext <CR>", "Goto next buffer" },

  ["<S-tab>"] = { "<cmd> BufferLineCyclePrev <CR>", "Goto prev buffer" },

  -- Add descriptions for empty shortcuts
  ["p"] = { "p", "Paste" },
  ["P"] = { "P", "Paste" },
}

local leader_mappings_opts = {
  mode = "n",         -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,       -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,      -- use `silent` when creating keymaps
  noremap = true,     -- use `noremap` when creating keymaps
  nowait = true,      -- use `nowait` when creating keymaps
}

local leader_mappings = {
  -- Set line number
  n = {
    name = "LineNumbers",
    ["r"] = { ":set relativenumber!<CR>", "Toggle relative number" },
    ["n"] = { ":set number!<CR>", "Toggle number" },
  },

  s = {
   ["F"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "Find in current [F]ile" }
  }
}

local which_key = require "which-key"
which_key.register(mappings, opts)
which_key.register(leader_mappings, leader_mappings_opts)
which_key.register({
  ["="] = {
    name = "+Yanky"
  }
})
which_key.register({
  ["["] = {
    name = "+Previous motion"
  }
})
which_key.register({
  ["]"] = {
    name = "+Next motion"
  }
})
which_key.register({
  ["\\"] = {
    name = "+VM-*"
  }
})
which_key.register({
  ["g"] = {
    name = "+Go to"
  }
})
which_key.register({
  ["z"] = {
    name = "+Fold"
  }
})
