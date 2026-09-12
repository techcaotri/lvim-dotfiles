-- File explorer: nvim-tree, reproducing LunarVim's default behavior
-- (lua/lvim/core/nvimtree.lua) plus the user's overrides from ~/.config/lvim.
--
-- LunarVim adds a custom on_attach on top of nvim-tree's defaults:
--   l / o / <CR> open   |  v open in VERTICAL SPLIT  |  h close directory
--   C change root to node | gtg telescope live_grep here | gtf telescope find_files here

-- Telescope scoped to the node under the cursor (LunarVim's start_telescope).
local function start_telescope(telescope_mode)
  -- lib.get_node_at_cursor no longer exists in current nvim-tree; the API
  -- function is api.tree.get_node_under_cursor().
  local node = require("nvim-tree.api").tree.get_node_under_cursor()
  if not node then
    return
  end
  local abspath = node.link_to or node.absolute_path
  local is_folder = node.nodes ~= nil
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
  -- h / <BS> ("Close Directory"): upstream's navigate.parent_close targets the
  -- LAST GROUP NODE, so for a directory with a single child it closes the CHILD
  -- (and only moves the cursor once the child is already closed) - the
  -- directory itself never closes. Old LunarVim closed the directory under the
  -- cursor. Restore that: close the dir itself when open; on files keep the
  -- upstream cursor-to-parent move.
  local function close_dir()
    local node = api.tree.get_node_under_cursor()
    if not node then
      return
    end
    if node.nodes ~= nil and node.parent then -- a (non-root) directory
      if node.open then
        node.open = false
        node.explorer.renderer:draw()
      end
      return
    end
    api.node.navigate.parent_close()
  end
  vim.keymap.set("n", "h", close_dir, opts("Close Directory"))
  vim.keymap.set("n", "<BS>", close_dir, opts("Close Directory"))
  vim.keymap.set("n", "C", api.tree.change_root_to_node, opts("CD"))
  -- P ("Parent Directory") changes the tree root to the parent directory of
  -- the node under the cursor. Upstream's api.node.navigate.parent only MOVES
  -- THE CURSOR to the parent entry (and does nothing visible at the top
  -- level), which reads as broken. So: root becomes the node's parent
  -- directory; for a top-level node fall back to the parent of the current
  -- root (same as "-").
  vim.keymap.set("n", "P", function()
    local node = api.tree.get_node_under_cursor()
    if not node then
      return
    end
    local parent = node.parent
    if parent and parent ~= node.explorer then
      api.tree.change_root_to_node(parent)
    else
      api.tree.change_root_to_parent()
    end
  end, opts("Parent Directory"))
  vim.keymap.set("n", "gtg", function() start_telescope("live_grep") end, opts("Telescope Live Grep"))
  vim.keymap.set("n", "gtf", function() start_telescope("find_files") end, opts("Telescope Find File"))
end

return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFileToggle", "NvimTreeClose" },
    keys = {
      -- Root the tree at the opening file's context dir (project root, else the
      -- file's own dir), not nvim's launch cwd. See lua/custom/dir.lua. The
      -- authoritative binding is in config/keymaps.lua (VeryLazy); this keeps the
      -- lazy-load-on-key trigger consistent.
      { "<leader>e", function() require("custom.dir").explorer_toggle() end, desc = "Explorer" },
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
        -- Show entries ignored by .gitignore (nvim-tree hides them by default).
        -- They render with the default "disabled" look: the NvimTreeGitIgnored*
        -- highlight groups link to Comment (gray), applied to names because
        -- highlight_git = "name" above.
        git_ignored = false,
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
