# lvim-new: Problems and Solutions

## 1. Purpose

This document is the troubleshooting and postmortem record for the `lvim-new`
(LazyVim migration) configuration. Each entry describes one concrete problem seen
while using `lvim-new`, the investigation, the root cause, and the exact fix, so the
same class of problem can be recognized and resolved quickly.

It complements, but does not duplicate:

- `docs/LunarVim_Plugins_Structure_Analysis_Brainstorming_Implementation.md`
  (Part III: how the `lvim-new` system is built; Part III.18: the design-time triage
  tree). Deep design detail lives there.
- `lazyvim-new/README.md` (setup and first-run gaps).
- Part II-B, section II.17 of the analysis doc (the dated change log).

## 2. How to read this document

Every issue uses the same shape:

- **Symptom**: what the user sees.
- **Reproduction**: exact steps.
- **Investigation**: what was checked and found.
- **Root cause**: the underlying reason, tagged `Fact` (verified), `Assumption`
  (reasoned but not proven), or `Open question`.
- **Mechanism**: the elaboration of why the root cause produces the symptom.
- **Solution**: the change, with file and commit.
- **Verification**: the exact command run and its result, with a `PASS` / `FAIL` /
  `Not verified` label. Nothing is called "tested" unless the command was actually run.
- **Status**: `DONE`, `DONE (interactive verification recommended)`, etc.
- **Risks / fallbacks**: residual risk and alternative fixes.

## 3. Environment and context

| Item | Value |
|---|---|
| New editor | `lvim-new` (`NVIM_APPNAME=lvim-lazyvim`), locally built **Neovim v0.12.4** |
| Old editor | `lvim` (LunarVim), system **Neovim v0.11.5-dev** |
| Config root | `~/.config/lvim-lazyvim` -> `~/.dotfiles/lvim/lazyvim-new` (symlink) |
| Data / state | `~/.local/share/lvim-lazyvim`, `~/.local/state/lvim-lazyvim` |

Two facts recur across issues and are worth stating once:

- **The two editors are fully isolated** by `NVIM_APPNAME`, so a fix in `lvim-new`
  never affects LunarVim.
- **Many bugs are Neovim-0.12-plus-migration interactions.** LunarVim runs on 0.11
  and had some plugins configured differently (or left inactive). A behavior that
  "worked in LunarVim" often did so because a plugin was inactive there, not because
  Neovim behaved differently.

---

## 4. Issues

### Issue 1: `:SudaRead` on a root-owned file crashes with `E439: Undo list corrupt`

This is the most involved issue in this document, so it is written out in full.

**Symptom.**
`E439: Undo list corrupt` appears (with a Lua/undo stack traceback) and the editor
becomes unusable after reading a root-owned file with `suda.vim`.

**Reproduction.**

1. `lvim-new /etc/audit/rules.d/50-software-install.rules` (a root-owned, non-readable
   file, so it opens empty with `[Permission Denied]`).
2. In `lvim-new`, run `:SudaRead` (reads the file through `sudo`, entering the sudo
   password at the prompt).
3. Crash: `E439: Undo list corrupt`.

**Investigation.**

- `:SudaRead` with no argument runs `edit suda://<current file>`
  (`suda.vim/plugin/suda.vim`), which fires suda's `BufReadCmd suda://*` handler,
  `suda#BufReadCmd()` (`suda.vim/autoload/suda.vim:178`).
- That handler is the important part:

  ```vim
  let ul = &undolevels
  set undolevels=-1          " GLOBAL option, not setlocal
  try
    setlocal noswapfile noundofile
    let echo_message = suda#read('<afile>', { 'range': '1' })   " runs sudo cat -> :1read tempfile
    silent lockmarks 0delete _
    ...
  finally
    let &undolevels = ul     " restore
  endtry
  ```

  So suda sets the **global** `undolevels = -1` for the entire read, rewrites the
  buffer (`:1read` then `:0delete`), then restores `undolevels`.

- For a root file, `filereadable()` is false, so `suda#read` takes the `sudo cat`
  branch. That branch prompts for the password with `inputsecret()`, so the
  `undolevels = -1` window stays open for as long as the user is typing the password
  and the editor is redrawing.

- The crash could **not** be reproduced headlessly: this host has no passwordless
  `sudo`, and a headless run cannot drive the interactive `inputsecret()`. Two
  observations narrowed it before the fix:
  - Launching with `-V9` verbose logging made the crash **vanish** (the verbose
    per-operation disk I/O changes the timing). So this is a **timing race**, not a
    deterministic code path.
  - A **minimal** config (a clean Neovim 0.12.4 with *only* `suda.vim`) does **not**
    crash; the **full** `lvim-new` config does. So the race is with an lvim-new
    plugin, not with `suda` / Neovim core.

- A faithful, **password-free** repro harness pinned it down. A fake `sudo` script
  fails the first non-interactive attempt (so `suda#read` opens `inputsecret()` --
  the event-loop wait that is the race window) and then accepts any dummy password.
  With it, the crash reproduces reliably. Bisecting plugins via a `$LVIM_DISABLE`
  switch:

  | Round | Disabled | Result |
  |---|---|---|
  | 1 | 8 timer/attach plugins (incl. `noice`, `highlight-undo`) | clean |
  | 2 | `highlight-undo` only | **still crashes** |
  | 3 | `noice`, `blink`, `smear-cursor`, `auto-save` | clean |
  | 4 | `noice` only | clean |

  Disabling **`noice.nvim` alone** stops the crash; disabling `highlight-undo` alone
  does not. Culprit: **`noice.nvim`**.

- Why `noice`: during the `inputsecret()` password wait the cursor does not move, so
  `CursorMoved`-driven plugins do not fire -- only the event loop runs. `noice` owns
  the command line via Neovim's **external cmdline** (`ext_cmdline`) UI, so
  `inputsecret()` is routed through noice, which runs its own cmdline buffer/redraw
  work on the event loop **inside** suda's global `undolevels = -1` window.

**Root cause.**

- `Fact` (enabling condition): `suda.vim` sets the **global** `undolevels = -1` for
  the entire read, and for a root file that window spans the interactive
  `inputsecret()` sudo password prompt.
- `Fact` (bisected trigger): **`noice.nvim`**. With noice owning the command line
  (`ext_cmdline`), the `inputsecret()` prompt is handled by noice, which runs its
  cmdline buffer/redraw work on the event loop during that wait -- overlapping suda's
  `undolevels = -1` window and leaving the undo list corrupt (`E439`). Disabling noice
  removes the crash; disabling suda's undo toggle (via pre-auth, below) also removes it.

**Mechanism (causal chain).**

```mermaid
flowchart TD
    Cmd[":SudaRead on a root file"] --> BRC["suda#BufReadCmd(): set GLOBAL<br/>undolevels=-1 for the whole read (suda.vim:181)"]
    BRC --> Prompt["suda#read -> sudo cat -> inputsecret()<br/>(password prompt: the event loop runs here)"]
    Prompt --> Noice["noice owns the cmdline (ext_cmdline),<br/>so inputsecret() is routed through it"]
    Noice --> Work["noice runs cmdline buffer/redraw work<br/>on the event loop DURING the prompt"]
    Work --> Overlap["that work overlaps the active<br/>global undolevels=-1 window"]
    Overlap --> E439["undo list left inconsistent<br/>=> E439: Undo list corrupt"]
```

**Solution.** `lazyvim-new/lua/plugins/ui.lua` (commit `e467f2e`): disable noice's
command line, so Neovim's native bottom cmdline handles `:` **and**
`input()`/`inputsecret()` -- keeping noice off suda's `inputsecret()` path:

```lua
{
  "folke/noice.nvim",
  opts = {
    cmdline = { enabled = false },   -- was { view = "cmdline" }
    messages = { enabled = false },
    presets = { command_palette = false, long_message_to_split = false },
  },
}
```

noice stays enabled for its LSP hover/signature popups; only its cmdline is off. This
also yields the *fully native* classic bottom command line we wanted anyway (the old
`view = "cmdline"` was noice approximating it).

Note on `de5ed3e`: an earlier commit added a `highlight-undo` `ignore_cb` and an
`auto-save` `buftype` guard on the initial (wrong) hypothesis that `highlight-undo`
was the cause. The bisect above disproved that (round 2). Those changes are harmless
hardening (auto-save should not sudo-write `suda://` buffers; highlight-undo need not
track them) and were kept, but they are **not** the fix.

**Verification.**

- `Fact / PASS`: the password-free repro harness reproduces `E439` on the old config
  and is **clean** on the new one. The harness exercises the identical suda code path
  (`inputsecret()` inside the global `undolevels = -1` window) as a real root file, so
  the on-disk root-file case is covered by the same path. Bisect chain recorded above
  (round 4: disabling noice's cmdline / noice alone -> clean).
- `Fact / PASS` (headless): the config loads with noice enabled, `cmdline.enabled =
  false`, `require("noice")` OK, and no load errors.

**Status.** `DONE`.

**Risks / fallbacks.**

- The enabling condition -- suda's global `undolevels = -1` spanning the interactive
  prompt -- still exists, so if a future plugin re-introduces event-loop work on the
  cmdline during `inputsecret()`, the same class of crash could return. Two
  independent fallbacks that both cut the window regardless of any plugin:
  1. Pre-authenticate sudo so the prompt (and the long `undolevels=-1` window) does not
     happen in the editor: run `sudo -v` in a shell first, then `:SudaRead`.
  2. Use an external askpass so the password is never entered in-editor (this host has
     `/usr/bin/zenity`):
     ```lua
     vim.env.SUDO_ASKPASS = "/usr/bin/zenity"   -- or a small "zenity --password" wrapper
     vim.g["suda#executable"] = "sudo -A"
     ```

---

### Issue 2: Creating a file from the file-tree pane errors with `Invalid buffer id`

**Symptom.**
`vim.schedule callback: .../editor.lua:153: Invalid buffer id: 75` (with an
`auto-save/init.lua` traceback) after creating a file from the left `nvim-tree` pane.

**Reproduction.** In the `nvim-tree` explorer, create a new file.

**Investigation.** Creating a file from `nvim-tree` makes and then wipes a scratch
buffer. `auto-save`'s save is debounced (`vim.schedule`'d ~1s later), so its
`condition(buf)` ran after that scratch buffer id was already invalid, and read
`vim.bo[buf].filetype` on it.

**Root cause.** `Fact`: `auto-save`'s `condition` touched `vim.bo[buf]` for a
no-longer-valid buffer id.

**Solution.** `lazyvim-new/lua/plugins/editor.lua` (commit `30e68a9`): bail out before
touching `vim.bo[buf]`:

```lua
if not buf or not vim.api.nvim_buf_is_valid(buf) then return false end
```

**Verification.** `Fact / PASS` (headless): `condition(99999)` -> `false`,
`condition(nil)` -> `false`, `condition(<valid>)` -> `true`, no error.

**Status.** `DONE`.

---

### Issue 3: `Tab` does not select the item in the completion popup

**Symptom.** With the `blink.cmp` completion popup open, `Tab` does nothing useful.

**Investigation.** `blink`'s `<Tab>` was `{ "snippet_forward", "fallback" }` (set that
way earlier specifically to keep `Tab` off the Copilot accept path, see Issue 6). It
did not accept a popup item.

**Root cause.** `Fact`: `<Tab>` had no completion-accept command.

**Solution.** `lazyvim-new/lua/plugins/coding.lua` (commit `6ad23a3`):

```lua
["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
```

`Tab` now accepts the highlighted item (or the first if none is selected) when the
popup is open, else jumps a snippet, else a normal Tab. It is still off the Copilot
path: defining `<Tab>` keeps LazyVim from splicing `ai_accept` into it, so Copilot
ghost text is still accepted only with `<M-l>`.

**Verification.** `Fact / PASS` (headless): resolved `blink.keymap["<Tab>"] =
{ "select_and_accept", "snippet_forward", "fallback" }`; `select_and_accept` is a real
blink command; config loads with no errors.

**Status.** `DONE`.

---

### Issue 4: `<leader>e` file tree shows the launch cwd, not the file's directory

**Symptom.** `cd ~/Downloads; lvim-new ~/Dev/test.sh` then `<leader>e` shows the tree
rooted at `~/Downloads`, not `~/Dev`.

**Investigation.** `nvim-tree` runs with `sync_root_with_cwd = false` and
`update_focused_file.update_root = false` (deliberately, so the root does not chase the
focused buffer). A bare `:NvimTreeToggle` therefore roots at Neovim's launch cwd. The
same is true of old LunarVim; this is a behavior to implement, not a regression.

**Root cause.** `Fact`: `<leader>e` used `:NvimTreeToggle`, which roots at cwd.

**Solution.** New shared module `lazyvim-new/lua/custom/dir.lua` (commit `67df83b`):
`context_dir()` returns the project root if the file is in a real project, else the
file's own directory (`$HOME` is rejected as a root, see Issue 5), and
`explorer_toggle()` opens `nvim-tree` rooted there. `<leader>e` calls it. The
`term_dir()` used by the exec-terminals now delegates to the same `context_dir()`, so
the tree and terminals share one rule.

**Verification.** `Fact / PASS` (headless): from a `downloads` cwd, opening
`dev/test.sh` roots the tree at `dev/`; opening `proj/src/main.cpp` (with a
`CMakeLists.txt`) roots it at `proj/`; second `<leader>e` still closes the tree.

**Status.** `DONE`. Detail in Part III.7.5(c).

---

### Issue 5: Terminals (and, before Issue 4, the tree) open in `$HOME`

**Symptom.** `<M-h>` / `<M-v>` / `<M-i>` terminals opened in `$HOME` for a file not in
a project.

**Investigation.** The cwd came from `project.nvim`'s `get_project_root()`. This host
has `package.json`, `package-lock.json`, and `.vscode` directly in `$HOME`, and those
are in `project.nvim`'s pattern list, so `get_project_root()` returned `$HOME` for
every file under it.

**Root cause.** `Fact`: `$HOME` was treated as a project root.

**Solution.** `lazyvim-new/lua/custom/dir.lua` (commits `9c52ea2`, `7e4f9b1`): reject
`$HOME` as a project root and fall back to the file's own directory.

**Verification.** `Fact / PASS` (headless): a file under a real project resolves to the
project root; a lone file resolves to its own directory; a file directly under `$HOME`
falls back to its own directory rather than `$HOME`.

**Status.** `DONE`. Detail in Part III.7.5(c).

---

### Issue 6: Undo/redo appear broken on JSON (and other formatted filetypes)

**Symptom.** `u` / `<C-r>` seem to do nothing on JSON files, while they work on plain
text.

**Investigation.** LazyVim enables format-on-save; `auto-save` writes on every
debounced change. For a filetype with a formatter (JSON via `jsonls`/`conform`), each
auto-save reformatted the whole buffer, stacking an extra undo state on top of the
edit, so the first `u` undid the invisible reformat, not the change. Plain text has no
formatter, so it was unaffected.

**Root cause.** `Fact`: format-on-save reformatting the buffer on every auto-save write.

**Solution.** `lazyvim-new/lua/config/options.lua` (commit `1709c84`):
`vim.g.autoformat = false`. This also matches old LunarVim's `format_on_save = false`
default. Format on demand with `<leader>lf`.

**Verification.** `Fact / PASS` (headless): with a formatter attached, editing a JSON
buffer and letting auto-save fire no longer reformats it, and `u` reverts the edit.

**Status.** `DONE`. Detail in Part III.7.5(b).

---

### Issue 7: Copilot suggestions appear in the completion popup, accepted with `Tab`

**Symptom.** Copilot completions showed as items in the `blink.cmp` popup (accepted by
`Tab`), not as inline grey ghost text.

**Investigation.** LazyVim's Copilot extra is gated on `vim.g.ai_cmp`. The default
(`true`) routes Copilot through the completion menu.

**Root cause.** `Fact`: `vim.g.ai_cmp` was `true`.

**Solution.** commit `2e3c36d`, three coordinated changes:

- `config/options.lua`: `vim.g.ai_cmp = false` -> native inline ghost text; drops the
  Copilot blink source; also turns off blink's own `ghost_text`.
- `plugins/ai.lua`: `copilot.lua` suggestion enabled + auto-triggered, `accept = <M-l>`
  (Alt+l), cycle `<M-]>`/`<M-[>`, dismiss `<C-]>`, panel off.
- `plugins/coding.lua`: `blink <Tab>` defined by us, which stops LazyVim from splicing
  `ai_accept` into `Tab`. Copilot is accepted only with `<M-l>`.

**Verification.** `Fact / PASS` (headless): resolved config shows `ai_cmp = false`,
blink `ghost_text` off, copilot `suggestion.keymap.accept = <M-l>`, panel off.

**Status.** `DONE`. Detail in Part III.9 and III.12.

---

### Issue 8: Dashboard "Recent Files" is scoped to the project and goes stale

**Symptom.** The startup dashboard's recent files listed only files under the current
project, and did not update with files opened during a long-lived session.

**Root cause.** `Fact`: the `r` action routed through `LazyVim.pick`, which injects
`cwd = LazyVim.root()`; and `v:oldfiles` is only loaded from shada at startup, never
refreshed mid-session.

**Solution.** commit `396d0e9` (`ui.lua`): override the `r` action to
`LazyVim.pick("oldfiles", { root = false })`. commit `f34291d` (`autocmds.lua`): a
`BufReadPost`/`BufWinEnter` autocmd prepends each opened file to the mutable
`v:oldfiles`.

**Verification.** `Fact / PASS` (headless): after opening files A then B mid-session,
the recent-files section shows B then A at the top; the `r` action resolves to the
un-scoped pick.

**Status.** `DONE`. Detail in Part III.7.5(d).

---

### Issue 9: `<leader>c` opened the `+code` group instead of closing the buffer

**Symptom.** `<leader>c` (LunarVim close-buffer muscle memory) opened LazyVim's
`+code` which-key group.

**Solution.** commit `58bfba1`: `<leader>c` now closes the buffer
(`Snacks.bufdelete`); the LazyVim `+code` group is removed and every action mirrored
under `<leader>l` (+LSP), with the 8 LSP `<leader>c*` keys disabled at the source via
`servers["*"].keys = {lhs, false}`.

**Verification.** `Fact / PASS` (headless): zero `<leader>c*` sub-mappings remain in any
mode; `<leader>c` -> "Close buffer".

**Status.** `DONE`. Detail in Part III.7.5(a) and III.8.8.

---

### Issue 10: Miscellaneous smaller fixes

| # | Symptom | Root cause | Fix | Commit |
|---|---|---|---|---|
| 10a | Copilot errored "Node 22+ required" on every buffer | default `node` on PATH is v20; Node 22 lives in a non-default nvm root | scan both nvm roots, rank numerically, set `copilot_node_command` | `1e25b95` |
| 10b | `s` was hijacked by flash | LazyVim maps `s`/`S` to flash | disable flash `s` (native substitute), `S` = normal flash jump | `0792fb2`, `a1ee7ea` |
| 10c | Wanted `Ctrl+C` = "copy whole file" with a select-all flash | LunarVim behavior not ported | `<C-c>` = `:%y+`, flash the whole buffer in the Visual highlight 250 ms, echo `N lines yanked` | `a1ee7ea` |
| 10d | Window navigation stopped at the edges | wrap-around not ported | restore circular `<C-h/j/k/l>` navigation | `da4e49b` |

---

## 5. Summary table

| # | Problem | Root cause (one line) | Fix location | Commit | Status |
|---|---|---|---|---|---|
| 1 | `:SudaRead` -> `E439: Undo list corrupt` | `noice`'s cmdline (`ext_cmdline`) runs event-loop work during suda's `inputsecret()`, inside suda's global `undolevels=-1` window | `ui.lua` (noice `cmdline.enabled=false`) | `e467f2e` | DONE |
| 2 | file-tree file create -> `Invalid buffer id` | auto-save `condition` touched a wiped buffer | `editor.lua` | `30e68a9` | DONE |
| 3 | `Tab` does not accept popup item | `<Tab>` had no accept command | `coding.lua` | `6ad23a3` | DONE |
| 4 | `<leader>e` shows launch cwd | `nvim-tree` roots at cwd; no context-dir logic | `custom/dir.lua` | `67df83b` | DONE |
| 5 | terminals open in `$HOME` | `$HOME` treated as a project root | `custom/dir.lua` | `9c52ea2`, `7e4f9b1` | DONE |
| 6 | undo/redo broken on JSON | format-on-save reformats on every auto-save | `options.lua` | `1709c84` | DONE |
| 7 | Copilot in popup / `Tab` accept | `vim.g.ai_cmp = true` | `options.lua`, `ai.lua`, `coding.lua` | `2e3c36d` | DONE |
| 8 | Recent Files scoped + stale | `LazyVim.pick` root; `v:oldfiles` snapshot | `ui.lua`, `autocmds.lua` | `396d0e9`, `f34291d` | DONE |
| 9 | `<leader>c` opens `+code` group | LazyVim default group on `<leader>c` | `keymaps.lua`, `lsp.lua` | `58bfba1` | DONE |
| 10a | Copilot "Node 22+" error | wrong `node` on PATH | `ai.lua` | `1e25b95` | DONE |
| 10b | `s` hijacked by flash | LazyVim flash `s`/`S` | `editor.lua` | `0792fb2`, `a1ee7ea` | DONE |
| 10c | no `Ctrl+C` copy-all flash | not ported | `keymaps.lua` | `a1ee7ea` | DONE |
| 10d | window nav stops at edges | wrap not ported | `keymaps.lua` | `da4e49b` | DONE |

## 6. Diagnostic patterns that recurred

These are the general techniques that solved the issues above, useful for the next one:

1. **Diff against old LunarVim.** Several "new" bugs were caused by a plugin being
   active or present in `lvim-new` but not in LunarVim (Issue 6's format-on-save;
   Issue 1's culprit `noice` is a LazyVim default LunarVim never had). `grep` the
   LunarVim config (`~/.dotfiles/lvim/lua`) for the plugin and check whether its
   `setup()` actually runs. It narrows the suspect set; it does not always name the
   culprit (Issue 1 needed the bisect below).
2. **Resolve the real, merged options.** For any plugin, the effective config is
   `require("lazy.core.plugin").values(plugin, "opts", false)`. Reading the spec file
   is not enough because lazy.nvim merges specs.
3. **Reproduce headless where possible -- and know its limits.** `lvim-new --headless
   <file> -c 'lua ...'` with a `vim.defer_fn` drives most flows and captures
   `:messages`. It cannot drive interactive input (password prompts) or reliably
   reproduce timing races.
4. **A timing race gives itself away two ways** (both seen in Issue 1): it disappears
   under `-V9` verbose logging (the per-operation disk I/O reorders the event loop),
   and a *minimal* config (clean Neovim + only the suspect subsystem) does not
   reproduce it while the full config does. When both are true, bisect plugins with a
   `$LVIM_DISABLE` switch (a tiny `lua/plugins/*.lua` that returns `{ name, enabled =
   false }` specs from an env var).
5. **Make the reproduction cheap and secret-free.** Issue 1's crash needed a real sudo
   password. A fake `sudo` that fails the first non-interactive attempt (forcing
   `inputsecret()`) then accepts any dummy password reproduced the exact code path
   without the real password -- turning a slow, sensitive bisect into fast, safe rounds.
6. **Guard callbacks against stale state.** Debounced / `vim.schedule`'d callbacks
   (auto-save, Issue 2) can fire after the buffer they captured is gone. Always
   `nvim_buf_is_valid` before `vim.bo[buf]`.
7. **Watch for global option toggles.** `set undolevels=-1` (global) in suda (the
   enabling condition for Issue 1) and format-on-save (Issue 6) both corrupt undo
   indirectly. A plugin that toggles a global option around a buffer change or an
   interactive prompt is a red flag.

## 7. Cross-references

- Design and as-built detail:
  `docs/LunarVim_Plugins_Structure_Analysis_Brainstorming_Implementation.md`,
  Part III (esp. III.7.5 deviations, III.18 triage).
- Dated change log: same doc, Part II-B, section II.17.
- Setup and first-run gaps: `lazyvim-new/README.md`.
