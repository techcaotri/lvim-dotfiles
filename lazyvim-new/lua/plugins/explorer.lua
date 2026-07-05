-- File explorer: nvim-tree, reproducing LunarVim's default behavior
-- (lua/lvim/core/nvimtree.lua) plus the user's overrides from ~/.config/lvim.
--
-- LunarVim adds a custom on_attach on top of nvim-tree's defaults:
--   l / o / <CR> open   |  v open in VERTICAL SPLIT  |  h close directory
--   C change root to node | gtg telescope live_grep here | gtf telescope find_files here

-- Telescope scoped to the node under the cursor (LunarVim's start_telescope).
local function start_telescope(telescope_mode)
  local node = require("nvim-tree.lib").get_node_at_cursor()
  if not node then
    return
  end
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.open ~= nil
  local basedir = is_folder and abspath or vim.fn.fnamemodify(abspath, ":h")
  require("telescope.builtin")[telescope_mode]({ cwd = basedir })
end

local function on_attach(bufnr)
  local api = require("nvim-tree.api")
  local function opts(desc)
    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
  end

  -- Keep all stock nvim-tree mappings, then layer LunarVim's "useful keys".
  api.config.mappings.default_on_attach(bufnr)

  vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
  vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
  vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
  vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
  vim.keymap.set("n", "gtg", function() start_telescope("live_grep") end, opts("Telescope Live Grep"))
  vim.keymap.set("n", "gtf", function() start_telescope("find_files") end, opts("Telescope Find File"))
end

return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFileToggle", "NvimTreeClose" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer" },
    },
    opts = {
      on_attach = on_attach,
      auto_reload_on_write = false,
      -- LunarVim defaults; user overrode root-following to OFF:
      sync_root_with_cwd = false,
      update_focused_file = { enable = true, update_root = false },
      hijack_directories = { enable = false, auto_open = true },
      view = {
        width = 30,
        side = "left",
        centralize_selection = true,
        relativenumber = true, -- user override
        signcolumn = "yes",
      },
      renderer = {
        highlight_git = "name",
        root_folder_label = ":t",
        full_name = true, -- user override (long names in floating popup)
        special_files = { "Cargo.toml", "Makefile", "README.md", "readme.md" },
        highlight_clipboard = "name",
      },
      diagnostics = {
        enable = true,
        show_on_dirs = false,
      },
      filters = {
        custom = { "node_modules", "\\.cache" },
      },
      git = { enable = true, show_on_dirs = true, timeout = 400 },
      actions = {
        use_system_clipboard = true,
        change_dir = { enable = true, global = false },
        open_file = {
          quit_on_open = false,
          resize_window = false,
          window_picker = {
            enable = true,
            picker = "default",
            chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            exclude = {
              filetype = { "notify", "lazy", "qf", "diff", "fugitive", "fugitiveblame" },
              buftype = { "nofile", "terminal", "help" },
            },
          },
        },
        remove_file = { close_window = true },
        -- user override: file popup near the cursor with rounded border
        file_popup = {
          open_win_config = {
            relative = "cursor",
            border = "rounded",
            style = "minimal",
            row = 1,
            col = 1,
          },
        },
      },
      ui = { confirm = { remove = true, trash = true, default_yes = false } },
      trash = { cmd = "gio trash" },
      live_filter = { prefix = "[FILTER]: ", always_show_folders = true },
    },
  },
}
