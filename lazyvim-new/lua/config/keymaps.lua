-- Keymaps -- full parity with the LunarVim setup.
-- This reproduces BOTH (a) the user's custom bindings from keymappings.lua and
-- (b) the LunarVim DEFAULT <leader> tree (buffers/debug/git/lsp/plugins/search/...),
-- minus the entries the user disabled, mapped to LazyVim/native equivalents.
--
-- All bindings are set inside apply(), which is called immediately (deterministic)
-- and again on VeryLazy -- AFTER LazyVim's own keymaps -- so the user's bindings win
-- over any overlapping LazyVim defaults.

local function apply()
  local map = vim.keymap.set
  local function m(mode, lhs, rhs, desc, opts)
    opts = opts or {}
    opts.silent = opts.silent ~= false
    opts.desc = desc
    map(mode, lhs, rhs, opts)
  end

  -- =========================================================================
  -- Terminal function-key passthroughs (F1-F12) + modifier remaps (F13-F57)
  -- =========================================================================
  for i = 1, 12 do
    map({ "i", "c", "t" }, "<F" .. i .. ">", "<Esc><F" .. i .. ">", { noremap = true, silent = true })
  end
  local fkey_remaps = {
    ["<F13>"] = "<S-F1>", ["<F14>"] = "<S-F2>", ["<F15>"] = "<S-F3>", ["<F16>"] = "<S-F4>",
    ["<F17>"] = "<S-F5>", ["<F18>"] = "<S-F6>", ["<F19>"] = "<S-F7>", ["<F20>"] = "<S-F8>",
    ["<F21>"] = "<S-F9>", ["<F22>"] = "<S-F10>", ["<F23>"] = "<S-F11>", ["<F24>"] = "<S-F12>",
    ["<F25>"] = "<C-F1>", ["<F26>"] = "<C-F2>", ["<F27>"] = "<C-F3>", ["<F28>"] = "<C-F4>",
    ["<F29>"] = "<C-F5>", ["<F30>"] = "<C-F6>", ["<F31>"] = "<C-F7>", ["<F32>"] = "<C-F8>",
    ["<F33>"] = "<C-F9>", ["<F34>"] = "<C-F10>", ["<F35>"] = "<C-F11>", ["<F36>"] = "<C-F12>",
    ["<F37>"] = "<C-S-F1>", ["<F54>"] = "<A-F6>", ["<F57>"] = "<A-F9>",
  }
  for lhs, rhs in pairs(fkey_remaps) do
    map({ "n", "x" }, lhs, rhs, { remap = true, silent = true })
  end

  -- =========================================================================
  -- Non-leader editing / navigation (keymappings.lua)
  -- =========================================================================
  m("x", "p", "P", "Paste (keep register)", { noremap = true })
  m("n", "<C-c>", "<cmd>%y+<CR>", "Copy whole file")
  m("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", "Next buffer")
  m("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", "Prev buffer")
  m("n", "yyp", "<cmd>co.<CR>", "Duplicate line")
  m("n", "[c", function() pcall(function() require("treesitter-context").go_to_context() end) end, "Goto treesitter context")
  m("n", "<C-w>z", "<cmd>WindowsMaximize<CR>", "Maximize window")
  m("n", "gD", "<cmd>Glance definitions<CR>", "Glance: definitions")
  m("n", "gR", "<cmd>Glance references<CR>", "Glance: references")
  m("n", "gY", "<cmd>Glance type_definitions<CR>", "Glance: type definitions")
  m("n", "gM", "<cmd>Glance implementations<CR>", "Glance: implementations")
  m("i", "<M-j>", "<Esc><Esc>A;<Esc>a", "Smart semicolon", { noremap = true })
  m("i", "<C-M-j>", "<Esc><Esc>A;<CR>", "Smart semicolon + Enter", { noremap = true })

  -- Quickfix toggle (LunarVim QuickFixToggle()).
  local function toggle_qf()
    local open = false
    for _, w in ipairs(vim.fn.getwininfo()) do
      if w.quickfix == 1 and w.loclist == 0 then open = true end
    end
    vim.cmd(open and "cclose" or "copen")
  end
  m("n", "<C-q>", toggle_qf, "Quickfix toggle")

  -- Goto definition in the next (non-explorer) window.
  m("n", "gvd", function()
    local path = vim.api.nvim_buf_get_name(0)
    local pos = vim.api.nvim_win_get_cursor(0)
    local origin = vim.api.nvim_get_current_win()
    local name
    repeat
      vim.cmd("wincmd l")
      name = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
    until (not name:find("neo%-tree")) and (not name:find("NvimTree")) or vim.api.nvim_get_current_win() == origin
    vim.cmd("e " .. vim.fn.fnameescape(path))
    vim.api.nvim_win_set_cursor(0, pos)
    vim.lsp.buf.definition()
  end, "Goto Definition in next window")

  -- =========================================================================
  -- LunarVim DEFAULT single-key leader maps (non-disabled)
  -- =========================================================================
  m("n", "<leader>;", function()
    local ok = pcall(function() require("snacks").dashboard() end)
    if not ok then vim.cmd("Alpha") end
  end, "Dashboard")
  m("n", "<leader>w", "<cmd>w!<CR>", "Save")
  m("n", "<leader>q", "<cmd>confirm q<CR>", "Quit")
  m("n", "<leader>/", "gcc", "Comment toggle line", { remap = true })
  m("x", "<leader>/", "gc", "Comment toggle (visual)", { remap = true })
  m("n", "<leader>c", function()
    local ok = pcall(function() require("snacks").bufdelete() end)
    if not ok then vim.cmd("bd") end
  end, "Close Buffer")
  m("n", "<leader>f", "<cmd>Telescope find_files<CR>", "Find File")
  m("n", "<leader>h", "<cmd>nohlsearch<CR>", "No Highlight")
  m("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", "Explorer")

  -- =========================================================================
  -- <leader>b : Buffers (LunarVim defaults + user)
  -- =========================================================================
  m("n", "<leader>bj", "<cmd>BufferLinePick<CR>", "Jump")
  m("n", "<leader>bf", "<cmd>Telescope buffers previewer=false<CR>", "Find")
  m("n", "<leader>bb", "<cmd>BufferLineCyclePrev<CR>", "Previous")
  m("n", "<leader>bn", "<cmd>BufferLineCycleNext<CR>", "Next")
  m("n", "<leader>bW", "<cmd>noautocmd w<CR>", "Save without formatting")
  m("n", "<leader>be", "<cmd>BufferLinePickClose<CR>", "Pick which buffer to close")
  m("n", "<leader>bh", "<cmd>BufferLineCloseLeft<CR>", "Close all to the left")
  m("n", "<leader>bl", "<cmd>BufferLineCloseRight<CR>", "Close all to the right")
  m("n", "<leader>bD", "<cmd>BufferLineSortByDirectory<CR>", "Sort by directory")
  m("n", "<leader>bL", "<cmd>BufferLineSortByExtension<CR>", "Sort by language")
  -- user additions
  m("n", "<leader>bN", "<cmd>enew<CR>", "New buffer")
  m("n", "<leader>bc", "<cmd>let @+=expand('%:p')<CR>", "Copy absolute path")
  m("n", "<leader>bu", [[:%s/\r//g<CR>]], "Convert to Unix EOL", { silent = false })

  -- =========================================================================
  -- <leader>d : Debug (LunarVim defaults not disabled + user)
  -- =========================================================================
  m("n", "<leader>dt", function() require("dap").toggle_breakpoint() end, "Toggle Breakpoint")
  m("n", "<leader>dd", function() require("dap").disconnect() end, "Disconnect")
  m("n", "<leader>dg", function() require("dap").session() end, "Get Session")
  m("n", "<leader>dr", function() require("dap").repl.toggle() end, "Toggle Repl")
  m("n", "<leader>ds", function() require("dap").continue() end, "Start")
  m("n", "<leader>dq", function() require("dap").close() end, "Quit")
  m("n", "<leader>dU", function() require("dapui").toggle({ reset = true }) end, "Toggle UI")
  -- user additions
  m("n", "<leader>dc", function()
    local pattern = vim.fn.getcwd() .. "/.vscode/launch.json"
    local types = { cppdbg = { "c", "cpp" }, codelldb = { "rust" }, delve = { "go" } }
    pcall(function() require("dap.ext.vscode").load_launchjs(pattern, types) end)
  end, "Reload .vscode/launch.json")
  m("n", "<leader>dl", function() require("dap").run_last() end, "Run last session")
  m("n", "<leader>dBl", function() require("dap").list_breakpoints() end, "List breakpoints")
  m("n", "<leader>dBc", function() require("dap").clear_breakpoints() end, "Clear breakpoints")

  -- =========================================================================
  -- <leader>p : Plugins (Lazy)
  -- =========================================================================
  m("n", "<leader>pi", "<cmd>Lazy install<CR>", "Install")
  m("n", "<leader>ps", "<cmd>Lazy sync<CR>", "Sync")
  m("n", "<leader>pS", "<cmd>Lazy<CR>", "Status")
  m("n", "<leader>pc", "<cmd>Lazy clean<CR>", "Clean")
  m("n", "<leader>pu", "<cmd>Lazy update<CR>", "Update")
  m("n", "<leader>pp", "<cmd>Lazy profile<CR>", "Profile")
  m("n", "<leader>pl", "<cmd>Lazy log<CR>", "Log")
  m("n", "<leader>pd", "<cmd>Lazy debug<CR>", "Debug")

  -- =========================================================================
  -- <leader>g : Git (LunarVim defaults + user diffview submenu)
  -- =========================================================================
  m("n", "<leader>gg", function()
    local ok = pcall(function() require("snacks").lazygit() end)
    if not ok then vim.cmd("LazyGit") end
  end, "Lazygit")
  m("n", "<leader>gj", function() require("gitsigns").nav_hunk("next") end, "Next Hunk")
  m("n", "<leader>gk", function() require("gitsigns").nav_hunk("prev") end, "Prev Hunk")
  m("n", "<leader>gl", function() require("gitsigns").blame_line() end, "Blame")
  m("n", "<leader>gL", function() require("gitsigns").blame_line({ full = true }) end, "Blame Line (full)")
  m("n", "<leader>gp", function() require("gitsigns").preview_hunk() end, "Preview Hunk")
  m("n", "<leader>gr", function() require("gitsigns").reset_hunk() end, "Reset Hunk")
  m("n", "<leader>gR", function() require("gitsigns").reset_buffer() end, "Reset Buffer")
  m("n", "<leader>gs", function() require("gitsigns").stage_hunk() end, "Stage Hunk")
  m("n", "<leader>gu", function() require("gitsigns").undo_stage_hunk() end, "Undo Stage Hunk")
  m("n", "<leader>go", "<cmd>Telescope git_status<CR>", "Open changed file")
  m("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", "Checkout branch")
  m("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", "Checkout commit")
  m("n", "<leader>gC", "<cmd>Telescope git_bcommits<CR>", "Checkout commit (file)")
  -- user diffview submenu (<leader>gd*)
  m("n", "<leader>gdo", "<cmd>DiffviewOpen<CR>", "Diffview open")
  m("n", "<leader>gdc", "<cmd>DiffviewClose<CR>", "Diffview close")
  m("n", "<leader>gdh", "<cmd>Gitsigns diffthis HEAD<CR>", "Diff vs HEAD")
  m("n", "<leader>gdr", "<cmd>DiffviewFileHistory<CR>", "Repo history")
  m("n", "<leader>gdf", "<cmd>DiffviewFileHistory --follow %<CR>", "File history")
  m("n", "<leader>gds", "<cmd>DiffviewFileHistory --follow<CR>", "Selection history")

  -- =========================================================================
  -- <leader>l : LSP (LunarVim defaults not disabled + user custom)
  -- =========================================================================
  m("n", "<leader>la", vim.lsp.buf.code_action, "Code Action")
  m("n", "<leader>lw", "<cmd>Telescope diagnostics<CR>", "Diagnostics (all)")
  m("n", "<leader>lf", function()
    local ok = pcall(function() require("conform").format({ async = true, lsp_fallback = true }) end)
    if not ok then vim.lsp.buf.format() end
  end, "Format")
  m("n", "<leader>li", "<cmd>LspInfo<CR>", "Info")
  m("n", "<leader>lI", "<cmd>Mason<CR>", "Mason Info")
  m("n", "<leader>lj", function() vim.diagnostic.jump({ count = 1, float = true }) end, "Next Diagnostic")
  m("n", "<leader>lk", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev Diagnostic")
  m("n", "<leader>ll", function() vim.lsp.codelens.run() end, "CodeLens Action")
  m("n", "<leader>lq", function() vim.diagnostic.setloclist() end, "Quickfix")
  m("n", "<leader>le", "<cmd>Telescope quickfix<CR>", "Telescope Quickfix")
  m("n", "<leader>lh", vim.lsp.buf.signature_help, "Signature Help")
  -- user custom
  m("n", "<leader>l<M-d>", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<CR>", "Buffer diagnostics")
  m("n", "<leader>lD", function() vim.diagnostic.open_float({ scope = "line" }) end, "Line diagnostics (float)")
  m("n", "<leader>ld", function()
    require("telescope.builtin").lsp_document_symbols({ fname_width = 35, symbol_width = 60, symbol_type_width = 15 })
  end, "Document symbols")
  m("n", "<leader>lR", function()
    local ok = pcall(function() require("custom.lsp.rename")({}, {}) end)
    if not ok then vim.lsp.buf.rename() end
  end, "Rename (custom)")
  m("n", "<leader>lS", function()
    require("telescope.builtin").lsp_workspace_symbols({ fname_width = 0.5, symbol_width = 0.35, symbol_type_width = 0.15 })
  end, "Workspace symbols")
  m("n", "<leader>lr", function()
    require("telescope.builtin").lsp_references({ fname_width = 65, trim_text = true })
  end, "All references")
  m("n", "<leader>lH", function()
    vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
  end, "Toggle inlay hints")
  m("n", "<leader>lW", "<cmd>ClangdSwitchSourceHeader<CR>", "Switch header/source")
  m("n", "<leader>lor", vim.lsp.buf.rename, "Original LSP rename")
  local saga = {
    O = { "outgoing_calls", "Outgoing calls" }, i = { "incoming_calls", "Incoming calls" },
    a = { "code_action", "Code action" }, d = { "peek_definition", "Peek definition" },
    t = { "peek_type_definition", "Peek type definition" }, D = { "diagnostic_jump_next", "Diagnostic jump next" },
    f = { "finder", "Finder" }, K = { "hover_doc", "Hover doc" }, I = { "finder imp", "Finder implement" },
    o = { "outline", "Outline" }, r = { "rename", "Rename" },
  }
  for key, spec in pairs(saga) do
    m("n", "<leader>ls" .. key, "<cmd>Lspsaga " .. spec[1] .. "<CR>", "LspSaga: " .. spec[2])
  end

  -- =========================================================================
  -- <leader>L : Config / LazyVim (LunarVim's +LunarVim submenu equivalents)
  -- =========================================================================
  m("n", "<leader>Lc", "<cmd>edit " .. vim.fn.stdpath("config") .. "/lua/config/options.lua<CR>", "Edit config")
  m("n", "<leader>Lk", "<cmd>Telescope keymaps<CR>", "View keymaps")
  m("n", "<leader>Li", "<cmd>Lazy<CR>", "Lazy (plugin manager)")
  m("n", "<leader>Ll", "<cmd>Lazy log<CR>", "Lazy log")
  m("n", "<leader>Lp", "<cmd>Lazy profile<CR>", "Startup profile")
  m("n", "<leader>Lx", "<cmd>LazyExtras<CR>", "LazyExtras")
  m("n", "<leader>Lh", "<cmd>LazyHealth<CR>", "Health check")

  -- =========================================================================
  -- <leader>s : Search (LunarVim defaults not disabled + user)
  -- =========================================================================
  m("n", "<leader>sb", "<cmd>Telescope git_branches<CR>", "Checkout branch")
  m("n", "<leader>sc", "<cmd>Telescope colorscheme<CR>", "Colorscheme")
  m("n", "<leader>sf", "<cmd>Telescope find_files<CR>", "Find File")
  m("n", "<leader>sh", "<cmd>Telescope help_tags<CR>", "Find Help")
  m("n", "<leader>sH", "<cmd>Telescope highlights<CR>", "Find highlight groups")
  m("n", "<leader>sM", "<cmd>Telescope man_pages<CR>", "Man Pages")
  m("n", "<leader>sr", "<cmd>Telescope oldfiles<CR>", "Open Recent File")
  m("n", "<leader>sR", "<cmd>Telescope registers<CR>", "Registers")
  m("n", "<leader>st", "<cmd>Telescope live_grep<CR>", "Text (live grep)")
  m("n", "<leader>sk", "<cmd>Telescope keymaps<CR>", "Keymaps")
  m("n", "<leader>sC", "<cmd>Telescope commands<CR>", "Commands")
  m("n", "<leader>sp", function()
    require("telescope.builtin").colorscheme({ enable_preview = true })
  end, "Colorscheme with Preview")
  -- user additions
  m("n", "<leader>sF", "<cmd>Telescope current_buffer_fuzzy_find<CR>", "Find in current file")
  m("n", "<leader>sL", "<cmd>Telescope resume<CR>", "Resume last search")
  m("n", "<leader>sl", function()
    require("telescope-live-grep-args.shortcuts").grep_word_under_cursor()
  end, "Live grep word under cursor")
  m("n", "<leader>ss", function()
    require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
  end, "Telescope Frecency")

  -- =========================================================================
  -- <leader>T : Treesitter
  -- =========================================================================
  m("n", "<leader>Ti", "<cmd>checkhealth vim.treesitter<CR>", "Treesitter Info")

  -- =========================================================================
  -- Other user standalone leader maps
  -- =========================================================================
  m("n", "<leader>nr", "<cmd>set relativenumber!<CR>", "Toggle relative number")
  m("n", "<leader>nn", "<cmd>set number!<CR>", "Toggle number")
  m("n", "<leader>Ps", function() pcall(function() require("custom.possession").possession_save() end) end, "Possession: save (prompt)")
  m("n", "<leader>Pf", "<cmd>Telescope possession list<CR>", "Possession: find sessions")
  m("n", "<leader>Pi", "<cmd>PossessionShow<CR>", "Possession: show info")
  m("n", "<leader>vs", "<cmd>VenvSelect<CR>", "Venv Select")
  m("n", "<leader>vc", function()
    -- venv-selector v2 only defines :VenvSelectCached when automatic activation is
    -- off; call the cached-retrieve directly so this works regardless.
    local ok = pcall(function() require("venv-selector.cached_venv").retrieve() end)
    if not ok then vim.cmd("VenvSelect") end
  end, "Venv Select cached")
  m("n", "<leader>|", "<cmd>vsplit<CR>", "Split window vertically")
  m("n", "<leader>D", "<cmd>DogeGenerate doxygen_javadoc<CR>", "Doge: generate docs")
  m("n", "<leader><F5>", [[<cmd>let _s=@/<Bar>%s/\s\+$//e<Bar>let @/=_s<CR>]], "Delete trailing spaces")
  m("n", "<leader>cc", ":<C-u>lua C()<Left><Left>", "Copy lua result", { silent = false })
  m("n", "<leader>Wt", "<cmd>ToggleWrapMode<CR>", "Toggle wrap")
  m("n", "<leader>Ws", "<cmd>SoftWrapMode<CR>", "Soft wrap")
  m("n", "<leader>Wh", "<cmd>HardWrapMode<CR>", "Hard wrap")

  -- =========================================================================
  -- Visual-mode leader bindings
  -- =========================================================================
  m("v", "<leader>lf", function() vim.lsp.buf.format() end, "LSP: Format selection")
  m("v", "<leader>la", vim.lsp.buf.code_action, "LSP: Code Action")
  m("v", "<leader>gr", function() require("gitsigns").reset_hunk() end, "Reset Hunk")
  m("v", "<leader>gs", function() require("gitsigns").stage_hunk() end, "Stage Hunk")
  m("v", "<leader><C-t>", function()
    vim.cmd("Translate en")
    vim.defer_fn(function()
      local keys = vim.api.nvim_replace_termcodes("<ESC><CR>", true, false, true)
      vim.api.nvim_feedkeys(keys, "m", false)
    end, 1000)
  end, "Translate to EN")
end

-- which-key group labels (deferred; which-key must be loaded).
local function groups()
  pcall(function()
    require("which-key").add({
      { "<leader>b", group = "Buffers" },
      { "<leader>d", group = "Debug" },
      { "<leader>dB", group = "Breakpoints" },
      { "<leader>g", group = "Git" },
      { "<leader>gd", group = "Diffview" },
      { "<leader>l", group = "LSP" },
      { "<leader>ls", group = "LspSaga" },
      { "<leader>lo", group = "Original LSP" },
      { "<leader>L", group = "Config/LazyVim" },
      { "<leader>n", group = "LineNumbers" },
      { "<leader>p", group = "Plugins" },
      { "<leader>P", group = "Possession" },
      { "<leader>s", group = "Search" },
      { "<leader>T", group = "Treesitter" },
      { "<leader>v", group = "Python venv" },
      { "<leader>W", group = "Wrapping" },
      { "<leader>C", group = "Cppman" },
      { "=", group = "Yanky" },
      { "\\", group = "VM-*" },
      { "z", group = "Fold" },
    })
  end)
end

-- Apply now (deterministic) and again on VeryLazy (so we win over LazyVim defaults).
apply()
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    apply()
    groups()
  end,
})
