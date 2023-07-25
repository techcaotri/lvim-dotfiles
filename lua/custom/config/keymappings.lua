-- Disable some debug keymaps
lvim.builtin.which_key.mappings.d.b = {}
lvim.builtin.which_key.mappings.d.c = {}
lvim.builtin.which_key.mappings.d.C = {}
lvim.builtin.which_key.mappings.d.i = {}
lvim.builtin.which_key.mappings.d.o = {}
lvim.builtin.which_key.mappings.d.u = {}
lvim.builtin.which_key.mappings.d.p = {}

-- Disable <leader>ls for using it with LspSaga submenu
lvim.builtin.which_key.mappings.l.s = {}

local opts = {
  mode = "n",     -- NORMAL mode
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
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

  -- Harpoon bookmarks management
  B = {
    name = "Harpoon bookmarks",
    a = { "<Cmd>lua require('harpoon.mark').add_file()<Cr>", "Add" },
    m = { "<Cmd>lua require('harpoon.ui').toggle_quick_menu()<Cr>", "Menu" },
    f = { "<Cmd>Telescope harpoon marks<CR>", "Telescope [f]ind marks" },
    ["1"] = { "<Cmd>lua require('harpoon.ui').nav_file(1) <Cr>", "Jump 1" },
    ["2"] = { "<Cmd>lua require('harpoon.ui').nav_file(2) <Cr>", "Jump 2" },
    ["3"] = { "<Cmd>lua require('harpoon.ui').nav_file(3) <Cr>", "Jump 3" },
    ["4"] = { "<Cmd>lua require('harpoon.ui').nav_file(4) <Cr>", "Jump 4" },
    ["5"] = { "<Cmd>lua require('harpoon.ui').nav_file(5) <Cr>", "Jump 5" },
  },
}

local leader_mappings_opts = {
  mode = "n",     -- NORMAL mode
  prefix = "<leader>",
  buffer = nil,   -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true,  -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true,  -- use `nowait` when creating keymaps
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
  },

  b = {
    ["N"] = { ":enew<CR>", "New buffer" }
  },

  -- Possession session management
  P = {
    name = "Possession",
    ["s"] = {
      function()
        require("custom.config.possession").possession_save()
      end,
      "[P]ossession: [s]ave session with prompt" },
    ["f"] = { "<cmd> Telescope possession list<CR>", "[P]ossession: Telescope/[f]ind sessions" },
    ["i"] = { "<cmd> PossessionShow<CR>", "[P]ossession: Show session [i]nformation" }
  },

  -- Python venv management
  v = {
    name = "Python [v]env",
    ["s"] = { "<cmd>:VenvSelect<cr>", "Venv [S]elect" },
    ["c"] = { "<cmd>:VenvSelectCached<cr>", "Venv [S]elect cached" },
  },

  -- Debug keymaps
  d = {
    ['c'] = { "<cmd>lua require('dap.ext.vscode').load_launchjs()<CR>", "Reload '.vscode/launch.json'" },
    ['l'] = { "<cmd>lua require('dap').run_last()<CR>", "Run last session" },
    b = {
      name = "Breakpoints",
      ['l'] = { "<cmd>lua require('dap').list_breakpoints()<CR>", "List Breakpoints" },
      ['c'] = { "<cmd>lua require('dap').clear_breakpoints()<CR>", "Clear Breakpoints" },
    }
  },

  -- LSP keymaps
  l = {
    ['D'] = { "<cmd>Telescope lsp_document_symbols<CR>", "LSP: Document Symbols" },
    ['R'] = { "<cmd>Telescope lsp_references<CR>", "LSP: All [R]eferences" },
    ['s'] = {
      name = "LspSaga",
      ['o'] = { "<cmd>Lspsaga outgoing_calls<CR>", "LspSaga: [o]utgoing Calls" },
      ['i'] = { "<cmd>Lspsaga incoming_calls<CR>", "LspSaga: [i]ncoming Calls" },
      ['a'] = { "<cmd>Lspsaga code_action<CR>", "LspSaga: Code [a]ction" },
      ['d'] = { "<cmd>Lspsaga peek_definition<CR>", "LspSaga: Peek [d]efinition" },
      ['t'] = { "<cmd>Lspsaga peek_type_definition<CR>", "LspSaga: Peek [t]ype Definition" },
      ['D'] = { "<cmd>Lspsaga diangostic_jump_next<CR>", "LspSaga: [D]]iagnostic Jump Next" },
      ['f'] = { "<cmd>Lspsaga finder<CR>", "LspSaga: [f]inder" },
      ['K'] = { "<cmd>Lspsaga hover_doc<CR>", "LspSaga: Documentation Hover" },
      ['I'] = { "<cmd>Lspsaga finder imp<CR>", "LspSaga: Finder [I]mplement" },
      ['O'] = { "<cmd>Lspsaga outline<CR>", "LspSaga: Finder [O]utline" },
      ['r'] = { "<cmd>Lspsaga rename<CR>", "LspSaga: [r]ename" },
    },
  },

  -- F5: Delete trailing spaces
  ["<F5>"] = { "<cmd>:let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar><CR>", "Delete all trailing spaces" },
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
