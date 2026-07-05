# lazyvim-new — LazyVim migration config (parallel to LunarVim)

This is the **new** Neovim configuration migrated from the LunarVim setup, built on
[LazyVim](https://www.lazyvim.org). It runs **in parallel** with the existing
LunarVim install via `NVIM_APPNAME`, so nothing about `~/.config/lvim` (the `lvim`
command) is touched. See
`docs/LunarVim_Plugins_Structure_Analysis_And_Brainstorming.md` (Part II) for the
full design and rationale.

## Activate / revert

From the repo root:

```
./setup_lvim.sh new     # set up the 'lvim-new' command (LazyVim); LunarVim untouched
./setup_lvim.sh old     # remove 'lvim-new'; go back to LunarVim (lvim)
./setup_lvim.sh status  # show current state
```

- New editor: **`lvim-new`**  (= `NVIM_APPNAME=lvim-lazyvim nvim`)
- Old editor: **`lvim`**       (LunarVim, unchanged)

Isolated dirs for the new config: `~/.config/lvim-lazyvim` (this dir, symlinked),
`~/.local/share/lvim-lazyvim`, `~/.local/state/lvim-lazyvim`, `~/.cache/lvim-lazyvim`.

## First run

The first launch git-clones LazyVim + ~100 plugins and installs LSP servers,
treesitter parsers, and formatters. Give it a few minutes; some plugins build native
bits (`avante` → `make`, `vscode-js-debug` → `npm`, `markdown-preview` → `npm`).
Pre-install everything up front with:

```
lvim-new --headless '+Lazy! sync' +qa
lvim-new '+checkhealth'
```

## Structure

```
init.lua                     entry; loads config.lazy + user keymaps/autocmds
lua/config/lazy.lua          lazy.nvim bootstrap + LazyVim + Extras imports
lua/config/options.lua       vim.opt + globals (leader, clipboard, header, ...)
lua/config/keymaps.lua       ported keymaps + <leader> groups
lua/config/autocmds.lua      autoread, flash toggle, :Redir, :RunNode, _G.C()
lua/plugins/*.lua            re-homed user plugins + overrides (see below)
lua/custom/possession.lua    custom possession save-prompt helper
```

Plugin specs: `colorscheme` (catppuccin-mocha), `editor`, `telescope`, `git`, `ui`,
`coding`, `lsp`, `dap`, `lang`, `ai`, `tools`. Languages come from LazyVim `lang.*`
Extras (python, clangd, go, rust, typescript, json, yaml, markdown, cmake, java).

## Known differences from the LunarVim setup (verify these)

- Completion is **blink.cmp** (LazyVim default), not nvim-cmp. To restore nvim-cmp,
  add `{ import = "lazyvim.plugins.extras.coding.nvim-cmp" }` to `config/lazy.lua`.
- TypeScript uses **vtsls** (LazyVim default) instead of typescript-tools.nvim.
- File explorer is **neo-tree** (LazyVim default) instead of nvim-tree.
- Dashboard is **snacks.dashboard** (LazyVim default) instead of alpha; the custom
  alpha session list is not ported.
- The custom two-column telescope entry display is not ported (default display used).
- `lazy-lock.json` is gitignored here; commit yours after a clean `:Lazy sync` if you
  want a reproducible lockfile.
