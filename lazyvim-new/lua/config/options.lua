-- Options -- loaded by LazyVim BEFORE lazy.nvim starts.
-- LazyVim already sets sane defaults (number, relativenumber, expandtab,
-- shiftwidth=2, tabstop=2, termguicolors, clipboard, ignorecase/smartcase,
-- undofile, laststatus=3, ...). Here we only set the deltas this user relied on
-- in the LunarVim config, plus user globals.

local opt = vim.opt

-- Leaders (space + backslash) -- backslash localleader keeps grug-far happy.
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- User overrides (from the old config.lua)
opt.relativenumber = true -- also a LazyVim default; kept explicit
opt.scrolloff = 3         -- LunarVim used 8; user overrode to 3
opt.number = true
opt.cursorline = true
opt.wrap = false
opt.timeoutlen = 1000

-- Prevent auto-continuation of // comments on newline after an inline comment.
opt.formatoptions:append("/")

-- Header author fields (alpertuna/vim-header)
vim.g.header_field_author = "Tri Pham"
vim.g.header_field_author_email = "techcaotri@gmail.com"

-- Clipboard: on non-Wayland sessions, use xclip (matches the old config.lua).
if os.getenv("XDG_SESSION_TYPE") ~= "wayland" then
  vim.g.clipboard = {
    name = "xclip",
    copy = {
      ["+"] = "xclip -i -selection clipboard",
      ["*"] = "xclip -i -selection clipboard",
    },
    paste = {
      ["+"] = "xclip -o -selection clipboard",
      ["*"] = "xclip -o -selection clipboard",
    },
    cache_enabled = true,
  }
end

-- LazyVim uses which-key; make sure it does not overwrite these leader choices.
-- (LazyVim reads vim.g.mapleader set above.)
