-- File explorer: nvim-tree (the plugin the LunarVim setup used), matching its
-- settings. LazyVim's default is the snacks explorer; we use nvim-tree for parity.
return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus", "NvimTreeFindFileToggle", "NvimTreeClose" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "Explorer" },
    },
    opts = {
      sync_root_with_cwd = false,
      update_focused_file = { enable = true, update_root = false },
      hijack_directories = { enable = true, auto_open = true },
      view = { relativenumber = true },
      renderer = { full_name = true },
      actions = {
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
    },
  },
}
