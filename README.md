# lvim-dotfiles

Neovim/LunarVim dotfiles. This repo holds **two** editor configurations that run
side by side, fully isolated from each other via `NVIM_APPNAME`:

| Editor | Command | Config | Neovim |
|---|---|---|---|
| **LunarVim** (original) | `lvim` | this repo's root (`~/.config/lvim`) | system `nvim` (0.11.x) |
| **LazyVim** (migration) | `lvim-new` | [`lazyvim-new/`](lazyvim-new/) (`~/.config/lvim-lazyvim`) | locally built 0.12.x |

Switching is safe and reversible — setting up `lvim-new` never touches LunarVim:

```bash
./setup_lvim.sh new      # set up the 'lvim-new' command (LazyVim)
./setup_lvim.sh old      # remove it; back to LunarVim only
./setup_lvim.sh status   # show current state
```

## → Setting up `lvim-new`

**See [`lazyvim-new/README.md`](lazyvim-new/README.md)** for the full step-by-step
guide, covering:

1. getting the latest code (this repo is a submodule of `~/.dotfiles`)
2. building Neovim 0.12.x with `script/build_and_update_neovim.sh` — **without**
   replacing the system `nvim` used by LunarVim
3. activating the `lvim-new` launcher (`setup_lvim.sh new`), incl. `LVIM_NEW_NVIM` /
   `LVIM_NEW_VIMRUNTIME` overrides
4. first run — `:Lazy sync`, plus the two things it does *not* do for you: installing
   the **Mason LSP servers** (`:Lazy sync` only installs formatters/linters) and
   finishing **blink.cmp's** native fuzzy library download
5. pointing Copilot at a **Node >= 22** (the `node` on `PATH` is often too old)
6. bringing your **possession sessions** over from LunarVim so they show up on the
   `lvim-new` startup dashboard
7. tmux integration via **`tol-new`**
8. installing + registering the **`lvim-new.desktop`** entry ("LunarVim New")
9. **`mimeopen_bg`** — how `lvim-new` is offered as the *second* option in the
   "open with" menu (and why `mimeapps.list` cannot do that)

It also documents the deliberate behavior deviations from stock LazyVim (e.g.
`<leader>c` closes the buffer and the `+code` group is merged into `+LSP`;
format-on-save is off), plus troubleshooting.

## Design / migration notes

`docs/LunarVim_Plugins_Structure_Analysis_And_Brainstorming.md` (Part II) — the full
analysis of the LunarVim setup and the rationale behind the LazyVim migration.
