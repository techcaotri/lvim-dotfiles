-- Keymaps -- loaded by LazyVim on VeryLazy (after which-key).
-- Ported from the LunarVim custom keymappings.lua. LazyVim already provides many
-- of the same bindings (window nav <C-hjkl>, resize <C-arrows>, move lines <A-jk>,
-- quickfix ]q/[q, save <C-s>); those are intentionally left to LazyVim. Only the
-- user-specific bindings and leader groups are reproduced here.

local map = vim.keymap.set

-- ---------------------------------------------------------------------------
-- Terminal function-key passthroughs (F1-F12) and modifier remaps (F13-F57).
-- These let the terminal deliver Shift/Ctrl/Alt+Fn as high function keycodes.
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- Non-leader editing / navigation
-- ---------------------------------------------------------------------------
-- Paste in visual mode without clobbering the register (cutlass.nvim also helps).
map("x", "p", "P", { noremap = true, silent = true, desc = "Paste (keep register)" })
-- Copy whole file to system clipboard.
map("n", "<C-c>", "<cmd>%y+<CR>", { silent = true, desc = "Copy whole file" })
-- Cycle buffers with Tab / Shift-Tab (bufferline).
map("n", "<Tab>", "<cmd>BufferLineCycleNext<CR>", { silent = true, desc = "Next buffer" })
map("n", "<S-Tab>", "<cmd>BufferLineCyclePrev<CR>", { silent = true, desc = "Prev buffer" })
-- Duplicate current line without touching the yank register.
map("n", "yyp", "<cmd>co.<CR>", { silent = true, desc = "Duplicate line" })
-- Jump to the treesitter context (scope) header.
map("n", "[c", function()
  pcall(function()
    require("treesitter-context").go_to_context()
  end)
end, { silent = true, desc = "Goto treesitter context" })

-- Quickfix toggle (replaces LunarVim's QuickFixToggle()).
local function toggle_qf()
  local open = false
  for _, w in ipairs(vim.fn.getwininfo()) do
    if w.quickfix == 1 and w.loclist == 0 then
      open = true
    end
  end
  vim.cmd(open and "cclose" or "copen")
end
map("n", "<C-q>", toggle_qf, { silent = true, desc = "Quickfix toggle" })

-- Goto definition in the next (non-explorer) window.
map("n", "gvd", function()
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
end, { silent = true, desc = "Goto Definition in next window" })

-- Window maximize (windows.nvim).
map("n", "<C-w>z", "<cmd>WindowsMaximize<CR>", { silent = true, desc = "Maximize window" })

-- Glance (peek) navigation.
map("n", "gD", "<cmd>Glance definitions<CR>", { silent = true, desc = "Glance: definitions" })
map("n", "gR", "<cmd>Glance references<CR>", { silent = true, desc = "Glance: references" })
map("n", "gY", "<cmd>Glance type_definitions<CR>", { silent = true, desc = "Glance: type definitions" })
map("n", "gM", "<cmd>Glance implementations<CR>", { silent = true, desc = "Glance: implementations" })

-- Smart semicolon in insert mode.
map("i", "<M-j>", "<Esc><Esc>A;<Esc>a", { noremap = true, silent = true, desc = "Smart semicolon" })
map("i", "<C-M-j>", "<Esc><Esc>A;<CR>", { noremap = true, silent = true, desc = "Smart semicolon + Enter" })

-- ---------------------------------------------------------------------------
-- Visual-mode leader bindings
-- ---------------------------------------------------------------------------
map("v", "<leader>lf", function()
  vim.lsp.buf.format()
end, { silent = true, desc = "LSP: Format selection" })
map("v", "<leader><C-t>", function()
  vim.cmd("Translate en")
  vim.defer_fn(function()
    local keys = vim.api.nvim_replace_termcodes("<ESC><CR>", true, false, true)
    vim.api.nvim_feedkeys(keys, "m", false)
  end, 1000)
end, { silent = true, desc = "Translate to EN" })

-- ---------------------------------------------------------------------------
-- Leader groups + mappings
-- ---------------------------------------------------------------------------
-- <leader>n : line numbers
map("n", "<leader>nr", "<cmd>set relativenumber!<CR>", { silent = true, desc = "Toggle relative number" })
map("n", "<leader>nn", "<cmd>set number!<CR>", { silent = true, desc = "Toggle number" })

-- <leader>s : search (telescope)
map("n", "<leader>sF", "<cmd>Telescope current_buffer_fuzzy_find<CR>", { silent = true, desc = "Find in current file" })
map("n", "<leader>sL", "<cmd>Telescope resume<CR>", { silent = true, desc = "Resume last search" })
map("n", "<leader>sl", function()
  require("telescope-live-grep-args.shortcuts").grep_word_under_cursor()
end, { silent = true, desc = "Live grep word under cursor" })
map("n", "<leader>ss", function()
  require("telescope").extensions.frecency.frecency({ workspace = "CWD" })
end, { silent = true, desc = "Telescope Frecency" })

-- <leader>b : buffers
map("n", "<leader>bN", "<cmd>enew<CR>", { silent = true, desc = "New buffer" })
map("n", "<leader>bc", "<cmd>let @+=expand('%:p')<CR>", { silent = true, desc = "Copy absolute path" })
map("n", "<leader>bu", [[:%s/\r//g<CR>]], { silent = false, desc = "Convert to Unix EOL (strip ^M)" })

-- <leader>P : possession sessions
map("n", "<leader>Ps", function()
  pcall(function()
    require("custom.possession").possession_save()
  end)
end, { silent = true, desc = "Possession: save (prompt)" })
map("n", "<leader>Pf", "<cmd>Telescope possession list<CR>", { silent = true, desc = "Possession: find sessions" })
map("n", "<leader>Pi", "<cmd>PossessionShow<CR>", { silent = true, desc = "Possession: show info" })

-- <leader>v : python venv
map("n", "<leader>vs", "<cmd>VenvSelect<CR>", { silent = true, desc = "Venv Select" })
map("n", "<leader>vc", "<cmd>VenvSelectCached<CR>", { silent = true, desc = "Venv Select cached" })

-- <leader>d : debug (dap)
map("n", "<leader>dc", function()
  local pattern = vim.fn.getcwd() .. "/.vscode/launch.json"
  local types = { cppdbg = { "c", "cpp" }, codelldb = { "rust" }, delve = { "go" } }
  pcall(function()
    require("dap.ext.vscode").load_launchjs(pattern, types)
  end)
end, { silent = true, desc = "Reload .vscode/launch.json" })
map("n", "<leader>dL", function()
  require("dap").run_last()
end, { silent = true, desc = "Run last session" })
map("n", "<leader>dBl", function()
  require("dap").list_breakpoints()
end, { silent = true, desc = "List breakpoints" })
map("n", "<leader>dBc", function()
  require("dap").clear_breakpoints()
end, { silent = true, desc = "Clear breakpoints" })

-- <leader>l : LSP (user's custom LSP tree; LazyVim's own LSP maps are under <leader>c)
map("n", "<leader>l<M-d>", "<cmd>Telescope diagnostics bufnr=0 theme=get_ivy<CR>", { silent = true, desc = "Buffer diagnostics" })
map("n", "<leader>lD", function()
  vim.diagnostic.open_float({ scope = "line" })
end, { silent = true, desc = "Line diagnostics (float)" })
map("n", "<leader>ld", function()
  require("telescope.builtin").lsp_document_symbols({ fname_width = 35, symbol_width = 60, symbol_type_width = 15 })
end, { silent = true, desc = "Document symbols" })
map("n", "<leader>lR", function()
  local ok = pcall(function()
    require("custom.lsp.rename")({}, {})
  end)
  if not ok then
    vim.lsp.buf.rename()
  end
end, { silent = true, desc = "Rename (custom)" })
map("n", "<leader>lS", function()
  require("telescope.builtin").lsp_workspace_symbols({ fname_width = 0.5, symbol_width = 0.35, symbol_type_width = 0.15 })
end, { silent = true, desc = "Workspace symbols" })
map("n", "<leader>lr", function()
  require("telescope.builtin").lsp_references({ fname_width = 65, trim_text = true })
end, { silent = true, desc = "All references" })
map("n", "<leader>lH", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
end, { silent = true, desc = "Toggle inlay hints" })
map("n", "<leader>lW", "<cmd>ClangdSwitchSourceHeader<CR>", { silent = true, desc = "Switch header/source" })
map("n", "<leader>lor", vim.lsp.buf.rename, { silent = true, desc = "Original LSP rename" })
-- LspSaga submenu (<leader>ls*)
local saga = {
  O = { "outgoing_calls", "Outgoing calls" },
  i = { "incoming_calls", "Incoming calls" },
  a = { "code_action", "Code action" },
  d = { "peek_definition", "Peek definition" },
  t = { "peek_type_definition", "Peek type definition" },
  D = { "diagnostic_jump_next", "Diagnostic jump next" },
  f = { "finder", "Finder" },
  K = { "hover_doc", "Hover doc" },
  I = { "finder imp", "Finder implement" },
  o = { "outline", "Outline" },
  r = { "rename", "Rename" },
}
for key, spec in pairs(saga) do
  map("n", "<leader>ls" .. key, "<cmd>Lspsaga " .. spec[1] .. "<CR>", { silent = true, desc = "LspSaga: " .. spec[2] })
end

-- <leader>g : git diffview submenu
map("n", "<leader>gdo", "<cmd>DiffviewOpen<CR>", { silent = true, desc = "Diffview open" })
map("n", "<leader>gdc", "<cmd>DiffviewClose<CR>", { silent = true, desc = "Diffview close" })
map("n", "<leader>gdh", "<cmd>Gitsigns diffthis HEAD<CR>", { silent = true, desc = "Diff vs HEAD" })
map("n", "<leader>gdr", "<cmd>DiffviewFileHistory<CR>", { silent = true, desc = "Repo history" })
map("n", "<leader>gdf", "<cmd>DiffviewFileHistory --follow %<CR>", { silent = true, desc = "File history" })
map("n", "<leader>gds", "<cmd>DiffviewFileHistory --follow<CR>", { silent = true, desc = "Selection history" })

-- <leader>W : wrapping
map("n", "<leader>Wt", "<cmd>ToggleWrapMode<CR>", { silent = true, desc = "Toggle wrap" })
map("n", "<leader>Ws", "<cmd>SoftWrapMode<CR>", { silent = true, desc = "Soft wrap" })
map("n", "<leader>Wh", "<cmd>HardWrapMode<CR>", { silent = true, desc = "Hard wrap" })

-- Standalone leader maps
map("n", "<leader>|", "<cmd>vsplit<CR>", { silent = true, desc = "Split window vertically" })
map("n", "<leader>D", "<cmd>DogeGenerate doxygen_javadoc<CR>", { silent = true, desc = "Doge: generate docs" })
map("n", "<leader><F5>", [[<cmd>let _s=@/<Bar>%s/\s\+$//e<Bar>let @/=_s<CR>]], { silent = true, desc = "Delete trailing spaces" })
map("n", "<leader>cc", ":<C-u>lua C()<Left><Left>", { silent = false, desc = "Copy lua result" })

-- which-key group labels -- deferred to VeryLazy so which-key is loaded first.
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  once = true,
  callback = function()
    pcall(function()
      require("which-key").add({
        { "<leader>n", group = "LineNumbers" },
        { "<leader>P", group = "Possession" },
        { "<leader>v", group = "Python venv" },
        { "<leader>l", group = "LSP" },
        { "<leader>ls", group = "LspSaga" },
        { "<leader>lo", group = "Original LSP" },
        { "<leader>gd", group = "Diffview" },
        { "<leader>W", group = "Wrapping" },
        { "<leader>C", group = "Cppman" },
        { "<leader>dB", group = "Breakpoints" },
        { "=", group = "Yanky" },
        { "\\", group = "VM-*" },
        { "z", group = "Fold" },
      })
    end)
  end,
})
