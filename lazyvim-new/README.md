# lazyvim-new — LazyVim migration config (parallel to LunarVim)

This is the **new** Neovim configuration migrated from the LunarVim setup, built on
[LazyVim](https://www.lazyvim.org). It runs **in parallel** with the existing
LunarVim install via `NVIM_APPNAME`, so nothing about `~/.config/lvim` (the `lvim`
command) is touched. See
`docs/LunarVim_Plugins_Structure_Analysis_Brainstorming_Implementation.md` (Part II) for the
full design and rationale.

- New editor: **`lvim-new`** (= `NVIM_APPNAME=lvim-lazyvim nvim`), runs on a locally
  built **Neovim 0.12.x**
- Old editor: **`lvim`** (LunarVim, unchanged), runs on the **system nvim (0.11.x)**

Isolated dirs for the new config: `~/.config/lvim-lazyvim` (this dir, symlinked),
`~/.local/share/lvim-lazyvim`, `~/.local/state/lvim-lazyvim`, `~/.cache/lvim-lazyvim`.

---

## Setup from scratch (step by step)

The pieces live in **two** repos:

| What | Where | Repo |
|---|---|---|
| This LazyVim config + `setup_lvim.sh` | `~/.dotfiles/lvim/` | submodule `techcaotri/lvim-dotfiles` |
| Neovim build script | `~/.dotfiles/script/build_and_update_neovim.sh` | parent `techcaotri/dotfiles` |
| `tol-new`, `mimeopen_bg` | `~/.dotfiles/bin/` | parent `techcaotri/dotfiles` |
| `lvim-new.desktop` | `~/.dotfiles/apps/` | parent `techcaotri/dotfiles` |

`~/bin` is a symlink to `~/.dotfiles/bin`, and both `~/bin` and `~/.local/bin` are on
`PATH` — so once the files exist, `tol-new`, `mimeopen_bg` and `lvim-new` are callable
with no extra PATH work.

### 1. Get the latest code

```bash
cd ~/.dotfiles
git pull

# this config lives in the 'lvim' submodule
git submodule update --init --recursive lvim

cd ~/.dotfiles/lvim
git fetch origin
git checkout lazyvim-migration    # the migration branch
git pull
```

> The submodule pointer in the parent repo may lag behind the submodule's branch. To
> record the current submodule commit in the parent: `cd ~/.dotfiles && git add lvim`.

### 2. Build Neovim 0.12.x (without touching the system nvim)

`lvim-new` is pinned to a locally built Neovim so the **system `nvim` stays on
0.11.x** for LunarVim. The build script clones into `~/Dev/Playground_Terminal/neovim`
and **builds but does not install** (there is no `sudo make install` unless you ask
for it):

```bash
~/.dotfiles/script/build_and_update_neovim.sh              # defaults to v0.12.4, Release
# options:
#   -v, --version <tag>       e.g. v0.12.4  (default)
#   -b, --build-type <type>   Release (default) | RelWithDebInfo | Debug
#   -i, --install             ALSO install system-wide -- do NOT use if you want to
#                             keep the system nvim on 0.11.x
```

This produces:

- binary: `~/Dev/Playground_Terminal/neovim/build/bin/nvim`
- runtime: `~/Dev/Playground_Terminal/neovim/runtime`

Both matter: because the build is **not installed**, the binary's compiled-in
`VIMRUNTIME` (`/usr/local/share/nvim`) does not exist, so the launcher must point
`VIMRUNTIME` at the source tree — `setup_lvim.sh` does this for you (step 3).

Verify:

```bash
~/Dev/Playground_Terminal/neovim/build/bin/nvim --version | head -1   # NVIM v0.12.4
nvim --version | head -1                                              # system: still 0.11.x
```

### 3. Activate `lvim-new`

From the repo root (`~/.dotfiles/lvim`):

```bash
./setup_lvim.sh new      # create the 'lvim-new' command; LunarVim untouched
./setup_lvim.sh status   # show current state (binary, VIMRUNTIME, symlinks)
./setup_lvim.sh old      # remove 'lvim-new'; back to LunarVim only
```

`setup_lvim.sh new` does two things:

1. symlinks `~/.config/lvim-lazyvim` → this directory, and
2. writes the launcher `~/.local/bin/lvim-new`, which is essentially:

   ```bash
   export NVIM_APPNAME="lvim-lazyvim"
   export VIMRUNTIME="$HOME/Dev/Playground_Terminal/neovim/runtime"
   exec -a lvim-new "$HOME/Dev/Playground_Terminal/neovim/build/bin/nvim" "$@"
   ```

   `exec -a lvim-new` runs Neovim **under the `lvim-new` name**, so tmux
   `pane_current_command` and `ps` show `lvim-new` instead of `nvim` (same trick
   LunarVim uses for `lvim`) — that is what `tol-new` matches on.

**Using a different Neovim** — override with env vars (the script falls back to `nvim`
on `PATH` if the build is missing):

```bash
# use an installed nvim already on PATH (no VIMRUNTIME override needed)
LVIM_NEW_NVIM="$(command -v nvim)" LVIM_NEW_VIMRUNTIME= ./setup_lvim.sh new

# use some other build tree
LVIM_NEW_NVIM=/path/to/nvim LVIM_NEW_VIMRUNTIME=/path/to/runtime ./setup_lvim.sh new
```

### 4. First run — plugins, Mason tools, native bits

The first launch git-clones LazyVim + ~130 plugins, ~36 treesitter parsers and the
Mason tools. Give it a few minutes; some plugins build native bits (`avante` →
`make`, `vscode-js-debug` → `npm`, `markdown-preview` → `npm`). Pre-install the
plugins up front:

```bash
lvim-new --headless '+Lazy! sync' +qa      # ~130 plugins, a few minutes
```

#### 4a. Mason LSP servers — headless is NOT enough

`:Lazy sync` installs only the Mason packages listed in `mason.nvim`'s
`ensure_installed` (see `lua/plugins/lsp.lua`) — the formatters/linters/DAP bits
(`stylua`, `shfmt`, `prettierd`, `clang-format`, `cpptools`, …).

The **LSP servers** (`clangd`, `lua_ls`, `basedpyright`, `gopls`, `jdtls`, …) are
installed by **`mason-lspconfig`**, which only loads once a real buffer opens. A
headless run therefore leaves you with formatters but **no LSP servers at all**, and
opening a file headlessly does not reliably trigger it either.

Easiest fix — open `lvim-new` **interactively** once, open any source file, and let
`:Mason` finish. To do it deterministically instead, have Neovim print the exact
package list its own config wants, then install it:

```bash
# 1. what does this config want from Mason?
lvim-new --headless -c 'lua
  local map = require("mason-lspconfig.mappings").get_mason_map().lspconfig_to_package
  local servers = require("lazyvim.util").opts("nvim-lspconfig").servers or {}
  local pkgs = {}
  for name, o in pairs(servers) do
    if (type(o) ~= "table" or o.mason ~= false) and map[name] then pkgs[#pkgs+1] = map[name] end
  end
  table.sort(pkgs) print("WANT: " .. table.concat(pkgs, " "))' -c 'qa' 2>&1 | grep WANT

# 2. install them (async -- keep Neovim alive while Mason works)
lvim-new --headless -c 'MasonInstall clangd lua-language-server basedpyright pyright ruff \
  gopls rust-analyzer json-lsp yaml-language-server jdtls css-lsp html-lsp marksman \
  bash-language-server jinja-lsp neocmakelsp bacon-ls copilot-language-server' \
  -c 'sleep 540' -c 'qa'

# 3. verify
ls ~/.local/share/lvim-lazyvim/mason/packages     # ~38 packages
```

A healthy setup ends up with ~38 Mason packages. Check that a server really attaches:

```bash
lvim-new --headless some_file.cpp -c 'lua vim.defer_fn(function()
  local n = {} for _, c in ipairs(vim.lsp.get_clients({bufnr=0})) do n[#n+1] = c.name end
  print("LSP: " .. table.concat(n, ",")) vim.cmd("qa") end, 12000)' 2>&1 | grep LSP
# -> LSP: clangd
```

> Mason's async installs are killed if Neovim exits too early (you may see a
> `java-test` warning). That is why the commands above hold the session open with
> `sleep` instead of quitting immediately.

#### 4b. blink.cmp's native fuzzy library

blink.cmp downloads a prebuilt `libblink_cmp_fuzzy.so` on first start. It writes
`target/release/version` = `v0.0.0` **before** downloading and rewrites it with the
real tag **after** — so if Neovim is killed mid-download (easy to do with `--headless`
+ `qa`), you are left with a stale `.so.tmp`, `version` stuck at `v0.0.0`, and blink
re-downloading on **every** start while silently falling back to the slow Lua matcher.

Let one interactive start finish the download. To repair a half-finished one:

```bash
D=~/.local/share/lvim-lazyvim/lazy/blink.cmp/target/release
sha256sum "$D"/libblink_cmp_fuzzy.so.tmp                  # compare with the .sha256 file
mv "$D"/libblink_cmp_fuzzy.so.tmp "$D"/libblink_cmp_fuzzy.so
git -C ~/.local/share/lvim-lazyvim/lazy/blink.cmp describe --tags --exact-match  # e.g. v1.10.2
printf 'v1.10.2' > "$D"/version                           # stops the re-download loop

# verify: prints RUST(native), not LUA(fallback)
lvim-new --headless -c 'lua vim.defer_fn(function()
  print("BLINK: " .. (pcall(require, "blink.cmp.fuzzy.rust") and "RUST(native)" or "LUA(fallback)"))
  vim.cmd("qa") end, 5000)' 2>&1 | grep BLINK
```

Finally:

```bash
lvim-new '+checkhealth'
```

### 5. Copilot needs Node >= 22

`copilot.lua` refuses to start on Node < 22 (`Node.js version 22 or newer required
but found 20.x`) — and the `node` on `PATH` is often an older nvm default.

`lua/plugins/ai.lua` therefore resolves `copilot_node_command` itself: it globs for
nvm-installed Nodes, keeps only `v22+`, and picks the newest. It scans **both** nvm
layouts, because the two coexist on some machines and only one may hold the new Node:

- `~/.nvm/versions/node/v*/bin/node` (stock nvm)
- `~/.local/share/nvm/v*/bin/node` (XDG-style layout)
- plus `$NVM_DIR` if set

So you only need Node >= 22 **installed** somewhere nvm-ish; it does **not** have to be
the `node` on `PATH`. Install one with `nvm install 22`, then verify what Copilot picked:

```bash
lvim-new --headless -c 'lua vim.defer_fn(function()
  local o = require("lazy.core.plugin").values(
    require("lazy.core.config").plugins["copilot.lua"], "opts", false) or {}
  print("COPILOT_NODE: " .. (o.copilot_node_command or "(unset -> PATH node)"))
  vim.cmd("qa") end, 6000)' 2>&1 | grep COPILOT_NODE
# -> COPILOT_NODE: /home/you/.local/share/nvm/v22.17.1/bin/node
```

If it prints `(unset -> PATH node)`, no Node >= 22 was found in any of the scanned
roots — install one, or add your root to the `patterns` list in `lua/plugins/ai.lua`.

### 6. Bring over your LunarVim sessions

Both editors use **possession.nvim** with the same JSON format, and the startup
dashboard lists saved sessions — but the two configs have **separate** session dirs
(they follow `stdpath("data")`, which `NVIM_APPNAME` isolates):

| Editor | Sessions live in |
|---|---|
| LunarVim | `~/.local/share/lvim/possession/` |
| `lvim-new` | `~/.local/share/lvim-lazyvim/possession/` |

A plain copy is all it takes — no conversion:

```bash
mkdir -p ~/.local/share/lvim-lazyvim/possession
cp ~/.local/share/lvim/possession/*.json ~/.local/share/lvim-lazyvim/possession/
```

The `"name"` inside each file must match its filename (it already does), so the
sessions show up on the `lvim-new` dashboard and load with `:PossessionLoad <name>`.
Verify what the dashboard will list:

```bash
lvim-new --headless -c 'lua vim.defer_fn(function()
  local n = {} for _, s in ipairs(require("possession.query").as_list()) do n[#n+1] = s.name end
  table.sort(n) print("SESSIONS(" .. #n .. "): " .. table.concat(n, ", ")) vim.cmd("qa") end, 6000)' \
  2>&1 | grep SESSIONS
```

Copying is **one-way and non-destructive**: LunarVim keeps its own copies, and from
here the two diverge — saving a session in `lvim-new` does not update LunarVim's.

> The auto-saved scratch session (`tmp`) is rewritten every time `lvim-new` exits, so
> don't be surprised when your copied `tmp.json` is overwritten by your next session.

### 7. tmux integration — `tol-new`

`~/.dotfiles/bin/tol-new` is the `lvim-new` twin of `tol`: it finds a **running
`lvim-new` server inside tmux** and opens the file there; otherwise it starts
`lvim-new` in the current pane. It differs from `tol` in exactly three ways:

- looks for sockets `${XDG_RUNTIME_DIR}/lvim-lazyvim.*.0` (LunarVim uses `lvim.*.0`)
- matches tmux panes whose command contains `lvim-new` (the `lvim-new` launcher
  runs `exec -a lvim-new nvim …`, so its process title is `lvim-new`, not `nvim`)
- drives `lvim-new --server … --remote …` and logs to `/tmp/tol-new.log`

It is executable and already on `PATH` (via `~/bin` → `~/.dotfiles/bin`):

```bash
command -v tol-new            # -> /home/tripham/bin/tol-new
tol-new path/to/file.cpp      # open in the running lvim-new (must be inside tmux)
```

> `tol`/`tol-new` use `tmux list-panes` / `send-keys`, so they only do anything
> meaningful **inside a tmux session**.

### 8. Desktop entry — `lvim-new.desktop`

`~/.dotfiles/apps/lvim-new.desktop` is a copy of `lvim.desktop` with
`Name=LunarVim New` and `Exec=tol-new %F`. Link it into the user applications dir and
register it:

```bash
ln -sf ~/.dotfiles/apps/lvim-new.desktop ~/.local/share/applications/lvim-new.desktop

# sanity-check the entry, then refresh the MIME cache
desktop-file-validate ~/.local/share/applications/lvim-new.desktop
update-desktop-database ~/.local/share/applications
```

Verify it registered (it should claim the same 19 MIME types as `lvim.desktop`):

```bash
grep -c 'lvim-new.desktop' ~/.local/share/applications/mimeinfo.cache
```

> `update-desktop-database` may exit non-zero while printing warnings about **other**,
> pre-existing `.desktop` files that lack a `MimeType` key. That is unrelated — as long
> as `desktop-file-validate` passes for `lvim-new.desktop`, it is registered.

### 9. `mimeopen_bg` — make `lvim-new` the **second** option

`~/.dotfiles/bin/mimeopen_bg` is a patched `mimeopen` (Perl) that opens the chosen app
in the background. With `-a` it prints an "open with" menu:

```bash
mimeopen_bg -a some_file.cpp
#   ...
#   3) 010 Editor      (010editor)
#   2) LunarVim New    (lvim-new)     <-- always slot 2
#   1) LunarVim        (lvim)
```

**Why a script patch and not `mimeapps.list`.** The menu is built from
`File::MimeInfo::Applications::mime_applications_all()`, which returns
`($default, @other)` and is numbered `1) = default`, `2) = first of @other`, …

- `_default()` reads `mimeapps.list` → controls **only slot #1**.
- `_others()` reads **`mimeinfo.cache`** and **ignores `mimeapps.list` associations
  entirely** (verified: putting `lvim-new.desktop` first in `[Added Associations]`
  does not move it in the menu).

So `mimeapps.list` **cannot** put an app in slot #2 — it can only make it the default.
`mimeopen_bg` therefore splices `lvim-new` into slot #2 itself, right after
`mime_applications_all()`:

- it reads the `MimeType=` list straight from
  `~/.local/share/applications/lvim-new.desktop`, so it only applies to the file types
  `lvim-new` declares (edit the desktop file and it self-syncs);
- it de-dupes any existing `lvim-new` entry, then inserts it after the default (or after
  the first "other" when the type has no default), so it lands on **2** either way;
- unsupported types (e.g. `text/markdown`) are left untouched.

Nothing to install — the file is already on `PATH`. Just verify:

```bash
perl -c ~/.dotfiles/bin/mimeopen_bg          # syntax OK
printf 'x\n' | mimeopen_bg -a some_file.cpp  # 'x' cancels; check that 2) is LunarVim New
```

> Harmless noise: stock `File::MimeInfo` prints
> `Use of uninitialized value $file ... line 140` warnings. They predate this patch.

**Alternative (optional): make `lvim-new` the _default_ (#1) instead.** This is the only
thing `mimeapps.list` can do, and it *replaces* `lvim` as the opener:

```bash
grep -oP '^MimeType=\K.*' ~/.dotfiles/apps/lvim-new.desktop | tr ';' '\n' | grep . |
  while IFS= read -r m; do xdg-mime default lvim-new.desktop "$m"; done
# revert a type:  xdg-mime default lvim.desktop <mimetype>
```

### 10. End-to-end check

```bash
./setup_lvim.sh status                      # launcher + symlinks + nvim version
lvim-new --version | head -1                # NVIM v0.12.4
nvim --version    | head -1                 # system still 0.11.x
command -v tol-new mimeopen_bg              # both under ~/bin
desktop-file-validate ~/.local/share/applications/lvim-new.desktop
printf 'x\n' | mimeopen_bg -a some_file.cpp # 'LunarVim New' is option 2

ls ~/.local/share/lvim-lazyvim/lazy     | wc -l   # ~130 plugins
ls ~/.local/share/lvim-lazyvim/mason/packages | wc -l   # ~38 Mason packages (step 4a)
ls ~/.local/share/lvim-lazyvim/possession         # your migrated sessions (step 6)
```

Then, from a file manager, "Open With → **LunarVim New**" routes:
`lvim-new.desktop` → `tol-new %F` → running `lvim-new` in tmux (or a new one).

---

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

## Behavior notes (deliberate deviations from stock LazyVim)

- **`<leader>c` closes the buffer** (LunarVim behavior). LazyVim's **`+code` group is
  removed**; every function it held is mirrored under **`<leader>l` (+LSP)** — e.g.
  `cf`→`lf`, `ca`→`la`, `cr`→`lR`, plus `lF` (format injected), `lA` (source action),
  `lC` (refresh codelens), `lO` (organize imports), `ln` (rename file), `lc` (copy lua
  result), `lm` (slime).
- **Format-on-save is OFF** (`vim.g.autoformat = false`, matching LunarVim's
  `format_on_save = false`). Required: `auto-save.nvim` writes on every debounced
  change, and format-on-save would rewrite the whole buffer each time, adding an extra
  undo state — which made `u` / `<C-r>` appear broken on formatted filetypes (JSON).
  Format on demand with `<leader>lf`.
- **Terminals** (`<M-h>` / `<M-v>` / `<M-i>`) open in the **project root** when the file
  is in a project, else in the **file's own directory** (`$HOME` is rejected as a
  "project root" — it contains `package.json`/`.vscode`).
- **Dashboard "Recent Files"** lists **all** recent files (not scoped to the current
  project), and stays fresh within a session (`v:oldfiles` is updated as files open).
- Command line / messages render at the **bottom** (classic), not as noice popups;
  `cmdheight = 0`.
- Startup dashboard lists saved **possession** sessions.

## Known differences from the LunarVim setup (verify these)

- Completion is **blink.cmp** (LazyVim default), not nvim-cmp. To restore nvim-cmp,
  add `{ import = "lazyvim.plugins.extras.coding.nvim-cmp" }` to `config/lazy.lua`.
- TypeScript uses **vtsls** (LazyVim default) instead of typescript-tools.nvim.
- The custom two-column telescope entry display is not ported (default display used).
- `lazy-lock.json` is gitignored here; commit yours after a clean `:Lazy sync` if you
  want a reproducible lockfile.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `module 'vim.uri' not found`, missing `syntax.vim` | `VIMRUNTIME` not set for the un-installed build. Re-run `./setup_lvim.sh new`. |
| `lvim-new: command not found` | `~/.local/bin` not on `PATH`, or `setup_lvim.sh new` not run. |
| `tol-new` does nothing | Not inside tmux, or no running `lvim-new`. Check `/tmp/tol-new.log`. |
| "LunarVim New" missing from Open-With | Re-run the `ln -sf` + `update-desktop-database` in step 8. |
| `lvim-new` not option 2 in `mimeopen_bg` | The file's MIME type is not in `lvim-new.desktop`'s `MimeType=`. Add it, then re-run `update-desktop-database`. |
| Undo/redo seem broken | Something re-enabled format-on-save; keep `vim.g.autoformat = false`. |
| No LSP at all (no `clangd`/`lua_ls` in `:Mason`) | `:Lazy sync` alone never installs LSP servers — only `mason-lspconfig` does, and only once a buffer opens. See step 4a. |
| `Node.js version 22 or newer required but found 20.x` | No Node >= 22 in the roots `lua/plugins/ai.lua` scans. Install one (`nvm install 22`) or add your nvm root there. See step 5. |
| Completion feels slow; "Downloading pre-built binary" on every start | blink.cmp's download was interrupted; `version` is stuck at `v0.0.0` and it silently uses the Lua matcher. See step 4b. |
| Dashboard shows no sessions | Sessions are per-`NVIM_APPNAME`. Copy them from `~/.local/share/lvim/possession/`. See step 6. |
| `update-desktop-database` seems to do nothing | Don't pipe it into `head` — the SIGPIPE kills it before it writes `mimeinfo.cache`. Run it bare. |
