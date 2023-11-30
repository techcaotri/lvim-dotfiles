-- Disable some debug keymaps
lvim.builtin.which_key.mappings.d.b = {}
lvim.builtin.which_key.mappings.d.c = {}
lvim.builtin.which_key.mappings.d.C = {}
lvim.builtin.which_key.mappings.d.i = {}
lvim.builtin.which_key.mappings.d.o = {}
lvim.builtin.which_key.mappings.d.u = {}
lvim.builtin.which_key.mappings.d.p = {}

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

  -- nvim-treesitter-context shortcuts
  ["[c"] = { function()
    require("treesitter-context").go_to_context()
  end, "Goto treesitter context" },

  -- duplicate line without touching " register
  ["yyp"] = { ":co.<CR>", "Duplicate line" },
}

-- Disable <leader>ls for using it with LspSaga submenu
lvim.builtin.which_key.mappings.l.s = {}
-- Disable <leader>lr for using it with LspSaga submenu
lvim.builtin.which_key.mappings.l.r = {}
-- Disable <leader>ld for remapping it to diagnostic floating window
lvim.builtin.which_key.mappings.l.d = {}
-- Disable <leader>sl for remapping it to diagnostic floating window
lvim.builtin.which_key.mappings.s.l = {}

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

  -- Search submenu
  s = {
    ["F"] = { "<cmd> Telescope current_buffer_fuzzy_find <CR>", "Find in current [F]ile" },
    ["L"] = { "<cmd>Telescope resume<cr>", "Resume last search" },
    ["l"] = {
      function()
        require("telescope-live-grep-args.shortcuts").grep_word_under_cursor()
      end,
      "[l]ive grep word under cursor" },
  },

  b = {
    ["N"] = { ":enew<CR>", "New buffer" },
    ["c"] = { ":let @+=expand('%:p')<CR>", "[c]opy absolute path to clipboard" },
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
    ['c'] = {
      function()
        local pattern = vim.fn.getcwd() .. '/.vscode/launch.json'
        local type_to_filetypes = { cppdbg = { "c", "cpp" }, codelldb = { "rust" }, delve = { "go" } }
        vim.print("load_launchjs pattern" .. pattern)
        require('dap.ext.vscode').load_launchjs(pattern, type_to_filetypes)
      end,
      "Reload '.vscode/launch.json'" },
    ['l'] = { "<cmd>lua require('dap').run_last()<CR>", "Run last session" },
    b = {
      name = "Breakpoints",
      ['l'] = { "<cmd>lua require('dap').list_breakpoints()<CR>", "List Breakpoints" },
      ['c'] = { "<cmd>lua require('dap').clear_breakpoints()<CR>", "Clear Breakpoints" },
    }
  },

  -- LSP keymaps
  l = {
    -- Diagnostic related keymaps
    ['<M-d>'] = { "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<cr>", "Buffer Diagnostics" },
    ['d'] = { "<cmd>lua vim.diagnostic.open_float({scope=\"line\"})<CR>", "LSP: Show [d]iagnostic in floating window" },

    ['D'] = { "<cmd>Telescope lsp_document_symbols<CR>", "LSP: Document Symbols" },
    ['R'] = { "<cmd>lua vim.lsp.buf.rename()<cr>", "LSP: [R]ename" },
    ['r'] = {
      function()
        require("telescope.builtin").lsp_references({ fname_width = 65, trim_text = true, })
      end,
      "LSP: All [r]eferences" },
    ['H'] = {
      function()
        -- show inlay hints for current buffer
        require('custom.config.lsp').show_inlay_hints(0)
      end,
      "LSP: Show inlay [H]ints" },
    ['s'] = {
      name = "LspSaga",
      ['O'] = { "<cmd>Lspsaga outgoing_calls<CR>", "LspSaga: [O]utgoing Calls" },
      ['i'] = { "<cmd>Lspsaga incoming_calls<CR>", "LspSaga: [i]ncoming Calls" },
      ['a'] = { "<cmd>Lspsaga code_action<CR>", "LspSaga: Code [a]ction" },
      ['d'] = { "<cmd>Lspsaga peek_definition<CR>", "LspSaga: Peek [d]efinition" },
      ['t'] = { "<cmd>Lspsaga peek_type_definition<CR>", "LspSaga: Peek [t]ype Definition" },
      ['D'] = { "<cmd>Lspsaga diangostic_jump_next<CR>", "LspSaga: [D]iagnostic Jump Next" },
      ['f'] = { "<cmd>Lspsaga finder<CR>", "LspSaga: [f]inder" },
      ['K'] = { "<cmd>Lspsaga hover_doc<CR>", "LspSaga: Documentation Hover" },
      ['I'] = { "<cmd>Lspsaga finder imp<CR>", "LspSaga: Finder [I]mplement" },
      ['o'] = { "<cmd>Lspsaga outline<CR>", "LspSaga: Finder [o]utline" },
      ['r'] = { "<cmd>Lspsaga rename<CR>", "LspSaga: [r]ename" },
    },
    ['W'] = { "<cmd>ClangdSwitchSourceHeader<CR>", "LSP: S[W]itch header/source" }
  },

  -- F5: Delete trailing spaces
  ["<F5>"] = { "<cmd>:let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar><CR>", "Delete all trailing spaces" },

  -- [Do]cumentation [Ge]nerator
  ["D"] = { "<Cmd>:DogeGenerate doxygen_javadoc<Cr>", "Doge: [D]ocumentation Generator" },

  -- Cppman submenu
  m = {
    name = "Cppman",
  },

  -- Wrapping submenu
  W = {
    ['t'] = { "<cmd>ToggleWrapMode<CR>", "Wrapping: [t]oggle Wrap" },
    ['s'] = { "<cmd>SoftWrapMode<CR>", "Wrapping: [s]oft Wrap" },
    ['h'] = { "<cmd>HardWrapMode<CR>", "Wrapping: [h]ard Wrap" },
  },

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

-- Add smart semicolon ';' keymap (<C-S-;>) in insert mode
vim.api.nvim_set_keymap('i', '<M-j>', '<Esc><Esc>A;<ESC>a', { noremap = true, silent = true, desc = 'Smart semicolon' })
vim.api.nvim_set_keymap('i', '<C-M-j>', '<Esc><Esc>A;<Cr>',
  { noremap = true, silent = true, desc = 'Smart semicolon with Enter' })

-- Add LSP format in visual mode
vim.api.nvim_set_keymap('v', '<space>lf', "<cmd>lua vim.lsp.buf.format()<CR>",
  { noremap = true, silent = true, desc = 'Format selection' })
