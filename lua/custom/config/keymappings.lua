-- Disable some debug keymaps
lvim.builtin.which_key.mappings.d.b = {}
lvim.builtin.which_key.mappings.d.c = {}
lvim.builtin.which_key.mappings.d.C = {}
lvim.builtin.which_key.mappings.d.i = {}
lvim.builtin.which_key.mappings.d.o = {}
lvim.builtin.which_key.mappings.d.u = {}
lvim.builtin.which_key.mappings.d.p = {}
lvim.builtin.which_key.mappings.g.d = {}

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

  -- nvim-treesitter-context shortcuts
  ["[c"] = { function()
    require("treesitter-context").go_to_context()
  end, "Goto treesitter context" },

  -- duplicate line without touching " register
  ["yyp"] = { ":co.<CR>", "Duplicate line" },

  -- nvim-treesitter-context shortcuts
  ["gvd"] = { function()
    local current_full_path = vim.api.nvim_buf_get_name(0)
    local current_cursor_pos = vim.api.nvim_win_get_cursor(0)

    local original_window = vim.api.nvim_get_current_win()
    local buffer_name
    repeat
      vim.cmd(vim.api.nvim_replace_termcodes('normal <C-l>', true, true, true))
      local current_buf = vim.api.nvim_get_current_buf()
      buffer_name = vim.api.nvim_buf_get_name(current_buf)
    until (not string.find(buffer_name, 'NvimTree')) or vim.api.nvim_get_current_win() == original_window

    vim.cmd("e " .. current_full_path)
    vim.api.nvim_win_set_cursor(0, current_cursor_pos)

    vim.lsp.buf.definition()
  end, "Goto Definition in next window" },

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

    -- Add keymap for telescope frecency
    ["s"] = {
      function()
        require("telescope").extensions.frecency.frecency {
          workspace = "CWD",
        }
      end,
      'Telescope Frecency'
    },
  },

  b = {
    ["N"] = { ":enew<CR>", "New buffer" },
    ["c"] = { ":let @+=expand('%:p')<CR>", "[c]opy absolute path to clipboard" },
  },

  -- Bookmark using 'marks.nvim'
  m = { name = "Bookmark" },

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
    ['R'] = {
      function()
        require('custom.config.lsp.rename')({}, {})
      end, "LSP: Custom [R]ename" },
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
    ['W'] = { "<cmd>ClangdSwitchSourceHeader<CR>", "LSP: S[W]itch header/source" },
    o = {
      name = "OriginalLSP",
      ["r"] = { "<cmd>lua vim.lsp.buf.rename()<cr>", "LSP: [o]riginal [r]efactor" },
    }
  },

  -- F5: Delete trailing spaces
  ["<F5>"] = { "<cmd>:let _s=@/<Bar>:%s/\\s\\+$//e<Bar>:let @/=_s<Bar><CR>", "Delete all trailing spaces" },

  -- [Do]cumentation [Ge]nerator
  ["D"] = { "<Cmd>:DogeGenerate doxygen_javadoc<Cr>", "Doge: [D]ocumentation Generator" },

  -- Cppman submenu
  C = {
    name = "Cppman",
  },

  -- Wrapping submenu
  W = {
    name = "+Wrapping",
    ['t'] = { "<cmd>ToggleWrapMode<CR>", "Wrapping: [t]oggle Wrap" },
    ['s'] = { "<cmd>SoftWrapMode<CR>", "Wrapping: [s]oft Wrap" },
    ['h'] = { "<cmd>HardWrapMode<CR>", "Wrapping: [h]ard Wrap" },
  },

  -- Split window
  ['|'] = { "<cmd>:vsplit<CR>", "Split window vertically" },

  -- Git keymaps
  g = {
    d = {
      "<cmd>DiffviewOpen<CR>",
      "Git diffview open",
    },
    q = {
      "<cmd>DiffviewClose<CR>",
      "Git diffview close",
    },
    D = {
      "<cmd>Gitsigns diffthis HEAD<cr>",
      "Git Diff",
    },
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

-- Add smart semicolon ';' keymap (<C-S-;>) in insert mode
vim.api.nvim_set_keymap('i', '<M-j>', '<Esc><Esc>A;<ESC>a', { noremap = true, silent = true, desc = 'Smart semicolon' })
vim.api.nvim_set_keymap('i', '<C-M-j>', '<Esc><Esc>A;<Cr>',
  { noremap = true, silent = true, desc = 'Smart semicolon with Enter' })

-- Add LSP format in visual mode
vim.api.nvim_set_keymap('v', '<space>lf', "<cmd>lua vim.lsp.buf.format()<CR>",
  { noremap = true, silent = true, desc = 'Format selection' })

-- Add keymap for Googles Translate
vim.api.nvim_set_keymap('v', '<space><C-t>', '', {
  noremap = true,
  callback = function()
    vim.cmd('Translate en')
    -- local keys = vim.api.nvim_replace_termcodes('<ESC>', true, false, true)
    -- vim.api.nvim_feedkeys(keys, 'm', false)
    -- vim.api.nvim_feedkeys('<CR>', 'm', false)
    vim.defer_fn(function()
      local keys = vim.api.nvim_replace_termcodes('<ESC><CR>', true, false, true)
      vim.api.nvim_feedkeys(keys, 'm', false)
    end, 1000)
  end,
  silent = true,
  desc = 'Translate to EN'
})

-- Add keymap to convert to Unix EOL
vim.api.nvim_set_keymap('n', '<Space>bu', ':%s/\r//g<CR>',
  { noremap = true, silent = false, desc = "Convert to Unix EOL, remove ^M from end of line" })

local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ["<C-q>"] = actions.smart_send_to_qflist + actions.open_qflist,
      },
    },
  }
}

-- Add keymap for maximize window
vim.api.nvim_set_keymap('n', '<C-w>z', '<cmd>WindowsMaximize<CR>',
  { noremap = true, silent = false, desc = "WindowsMaximize" })
