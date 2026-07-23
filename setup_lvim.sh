#!/usr/bin/env bash
#
# setup_lvim.sh -- switch between the OLD LunarVim config and the NEW LazyVim
# migration config (see docs/LunarVim_Plugins_Structure_Analysis_Brainstorming_Implementation.md,
# Part II). The two configs run fully isolated via NVIM_APPNAME, so this script is
# non-destructive and instantly reversible.
#
#   ./setup_lvim.sh new   -> set up / activate the NEW LazyVim config (command: lvim-new)
#   ./setup_lvim.sh old    -> tear the NEW config down and go back to LunarVim (command: lvim)
#   ./setup_lvim.sh status -> show what is currently set up
#
# Nothing about the existing LunarVim install (~/.config/lvim, the `lvim` command)
# is ever modified. "old" simply removes the parallel `lvim-new` launcher/symlink.
set -euo pipefail

# --- Resolve paths ----------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_DIR="$SCRIPT_DIR"

APPNAME="lvim-lazyvim"                       # NVIM_APPNAME for the new config
NEW_SRC="$REPO_DIR/lazyvim-new"              # LazyVim config source (in this repo)
CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
NEW_CFG_LINK="$CFG_DIR/$APPNAME"             # ~/.config/lvim-lazyvim  -> NEW_SRC
LAUNCHER_DIR="$HOME/.local/bin"
LAUNCHER="$LAUNCHER_DIR/lvim-new"            # convenience command for the new config

# Neovim binary the launcher runs. Defaults to a locally-built 0.12.x used for
# testing the migration on the newest Neovim; override with LVIM_NEW_NVIM=... (set
# it to 'nvim' to use the system Neovim). The system nvim (LunarVim) is untouched.
NVIM_BIN="${LVIM_NEW_NVIM:-/home/tripham/Dev/Playground_Terminal/neovim/build/bin/nvim}"
# A build tree that was NOT `make install`ed cannot locate its runtime, so point
# VIMRUNTIME at its source runtime/ dir (bundled parsers are found via build/lib).
# Leave empty (LVIM_NEW_VIMRUNTIME=) for an installed nvim or one already on PATH.
NVIM_RUNTIME="${LVIM_NEW_VIMRUNTIME:-/home/tripham/Dev/Playground_Terminal/neovim/runtime}"

# --- Pretty output ----------------------------------------------------------
if [ -t 1 ]; then
  BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GRN=$'\033[32m'
  YLW=$'\033[33m'; BLU=$'\033[34m'; CYN=$'\033[36m'; RST=$'\033[0m'
else
  BOLD=""; DIM=""; RED=""; GRN=""; YLW=""; BLU=""; CYN=""; RST=""
fi
say()  { printf '%s\n' "$*"; }
head() { printf '\n%s== %s ==%s\n' "$BOLD$BLU" "$*" "$RST"; }
ok()   { printf '  %s[ok]%s %s\n' "$GRN" "$RST" "$*"; }
info() { printf '  %s[..]%s %s\n' "$CYN" "$RST" "$*"; }
warn() { printf '  %s[!!]%s %s\n' "$YLW" "$RST" "$*"; }
err()  { printf '  %s[xx]%s %s\n' "$RED" "$RST" "$*" >&2; }

usage() {
  cat <<EOF
${BOLD}setup_lvim.sh${RST} -- switch between LunarVim (old) and LazyVim (new)

  ${BOLD}new${RST}     Set up + activate the new LazyVim migration config.
          Adds the '${BOLD}lvim-new${RST}' command; leaves LunarVim untouched.
  ${BOLD}old${RST}     Remove the new config launcher/symlink; use LunarVim (${BOLD}lvim${RST}).
  ${BOLD}status${RST}  Show the current setup.

The two editors are isolated via NVIM_APPNAME, so switching is safe and reversible.
EOF
}

# --- Neovim version check ---------------------------------------------------
check_nvim() {
  # Resolve the Neovim binary the launcher will use. If NVIM_BIN is not an
  # executable file, fall back to whatever `nvim` is on PATH (and clear the
  # build-tree VIMRUNTIME, which only applies to the local build).
  if [ ! -x "$NVIM_BIN" ]; then
    if command -v nvim >/dev/null 2>&1; then
      warn "NVIM_BIN '$NVIM_BIN' not found; falling back to 'nvim' on PATH."
      NVIM_BIN="$(command -v nvim)"; NVIM_RUNTIME=""
    else
      err "No Neovim binary found (NVIM_BIN='$NVIM_BIN' and no 'nvim' on PATH)."; exit 1
    fi
  fi
  local v
  v="$("$NVIM_BIN" --version 2>/dev/null | sed -nE '1s/^NVIM v([0-9]+\.[0-9]+\.[0-9]+).*/\1/p')"
  info "Neovim binary : $NVIM_BIN"
  info "Neovim version: $v"
  [ -n "$NVIM_RUNTIME" ] && info "VIMRUNTIME    : $NVIM_RUNTIME (local build tree)"
  # LazyVim requires >= 0.11.2
  local major minor patch
  IFS=. read -r major minor patch <<<"$v"
  if [ "${major:-0}" -eq 0 ] && { [ "${minor:-0}" -lt 11 ] || { [ "${minor:-0}" -eq 11 ] && [ "${patch:-0}" -lt 2 ]; }; }; then
    warn "LazyVim requires Neovim >= 0.11.2. The new config may not work on $v."
  fi
}

# --- Actions ----------------------------------------------------------------
setup_new() {
  head "Setting up the NEW LazyVim config"
  check_nvim

  if [ ! -d "$NEW_SRC" ]; then
    err "New config source not found: $NEW_SRC"; exit 1
  fi
  ok "Config source: $NEW_SRC"

  # Link ~/.config/lvim-lazyvim -> repo/lazyvim-new
  if [ -e "$NEW_CFG_LINK" ] && [ ! -L "$NEW_CFG_LINK" ]; then
    local backup="$NEW_CFG_LINK.backup.$$"
    warn "$NEW_CFG_LINK exists and is not our symlink; backing up to $backup"
    mv "$NEW_CFG_LINK" "$backup"
  fi
  ln -sfn "$NEW_SRC" "$NEW_CFG_LINK"
  ok "Linked config dir: $NEW_CFG_LINK -> $NEW_SRC"

  # Install the lvim-new launcher. It runs NVIM_BIN under NVIM_APPNAME, and sets
  # VIMRUNTIME when NVIM_BIN is a non-installed build tree. `exec -a lvim-new`
  # sets the process title so tmux `pane_current_command` (and tools like tol-new)
  # see 'lvim-new' instead of 'nvim' -- the same trick LunarVim uses for `lvim`.
  mkdir -p "$LAUNCHER_DIR"
  if [ -n "$NVIM_RUNTIME" ]; then
    cat >"$LAUNCHER" <<EOF
#!/usr/bin/env bash
# Auto-generated by setup_lvim.sh -- launches the LazyVim migration config,
# fully isolated from LunarVim via NVIM_APPNAME=$APPNAME.
# Uses a locally-built Neovim; VIMRUNTIME points at its source runtime/ dir so the
# build tree can find its runtime (bundled parsers resolve via build/lib/nvim).
# exec -a lvim-new: run under the 'lvim-new' name (not 'nvim') in tmux/ps.
export NVIM_APPNAME="$APPNAME"
export VIMRUNTIME="$NVIM_RUNTIME"
exec -a lvim-new "$NVIM_BIN" "\$@"
EOF
  else
    cat >"$LAUNCHER" <<EOF
#!/usr/bin/env bash
# Auto-generated by setup_lvim.sh -- launches the LazyVim migration config,
# fully isolated from LunarVim via NVIM_APPNAME=$APPNAME.
# exec -a lvim-new: run under the 'lvim-new' name (not 'nvim') in tmux/ps.
export NVIM_APPNAME="$APPNAME"
exec -a lvim-new "$NVIM_BIN" "\$@"
EOF
  fi
  chmod +x "$LAUNCHER"
  ok "Installed launcher: $LAUNCHER  (nvim: $NVIM_BIN)"

  head "New config -- isolated locations (NVIM_APPNAME=$APPNAME)"
  say "  config : $NEW_CFG_LINK  (-> $NEW_SRC)"
  say "  data   : $DATA_DIR/$APPNAME     (plugins, mason tools)"
  say "  state  : $STATE_DIR/$APPNAME    (lazy-lock, shada, undo)"
  say "  cache  : $CACHE_DIR/$APPNAME"

  head "How to use"
  say "  Launch the NEW editor:   ${BOLD}lvim-new${RST}    (or: NVIM_APPNAME=$APPNAME nvim)"
  say "  Your OLD editor:         ${BOLD}lvim${RST}        (LunarVim -- unchanged)"
  say ""
  case ":$PATH:" in
    *":$LAUNCHER_DIR:"*) ;;
    *) warn "$LAUNCHER_DIR is not on your \$PATH -- run via: $LAUNCHER" ;;
  esac
  warn "First launch will git-clone LazyVim + ~100 plugins (needs network, takes a few minutes)."
  warn "Some plugins build native bits (avante 'make', vscode-js-debug 'npm', markdown-preview 'npm')."
  say ""
  say "  ${DIM}First run tip:${RST} lvim-new --headless '+Lazy! sync' +qa   # install everything up front"
  say "  ${DIM}Health check:${RST}  lvim-new '+checkhealth' "
  say "  ${DIM}Revert:${RST}        $0 old"
  head "Done -- NEW config is active as 'lvim-new'"
}

setup_old() {
  head "Reverting to the OLD LunarVim config"

  if [ -L "$LAUNCHER" ] || [ -f "$LAUNCHER" ]; then
    rm -f "$LAUNCHER"; ok "Removed launcher: $LAUNCHER"
  else
    info "Launcher not present (already reverted): $LAUNCHER"
  fi

  if [ -L "$NEW_CFG_LINK" ]; then
    rm -f "$NEW_CFG_LINK"; ok "Removed config symlink: $NEW_CFG_LINK"
  elif [ -e "$NEW_CFG_LINK" ]; then
    warn "$NEW_CFG_LINK is a real directory (not our symlink); left untouched."
  else
    info "Config symlink not present (already reverted): $NEW_CFG_LINK"
  fi

  head "State preserved"
  say "  - New config files remain in the repo: $NEW_SRC"
  say "  - Isolated data/state/cache for '$APPNAME' are kept for future testing:"
  say "      $DATA_DIR/$APPNAME , $STATE_DIR/$APPNAME , $CACHE_DIR/$APPNAME"
  say "  - To also delete the isolated plugin data:  rm -rf $DATA_DIR/$APPNAME $STATE_DIR/$APPNAME $CACHE_DIR/$APPNAME"

  head "Active editor"
  say "  ${BOLD}lvim${RST}  ->  LunarVim  (~/.config/lvim, unchanged)"
  head "Done -- reverted to LunarVim"
}

show_status() {
  head "setup_lvim.sh status"
  say "  repo            : $REPO_DIR"
  say "  new config src  : $NEW_SRC $( [ -d "$NEW_SRC" ] && echo "(present)" || echo "(MISSING)" )"
  if [ -L "$NEW_CFG_LINK" ]; then
    say "  config symlink  : $NEW_CFG_LINK -> $(readlink "$NEW_CFG_LINK")  ${GRN}[new active]${RST}"
  else
    say "  config symlink  : $NEW_CFG_LINK  ${DIM}[not linked]${RST}"
  fi
  if [ -x "$LAUNCHER" ]; then
    say "  launcher        : $LAUNCHER  ${GRN}[installed]${RST}"
  else
    say "  launcher        : $LAUNCHER  ${DIM}[absent]${RST}"
  fi
  say "  LunarVim (old)  : $CFG_DIR/lvim  (command: lvim)"
}

# --- Dispatch ---------------------------------------------------------------
case "${1:-}" in
  new)    setup_new ;;
  old)    setup_old ;;
  status) show_status ;;
  -h|--help|help|"") usage ;;
  *) err "Unknown argument: ${1:-}"; echo; usage; exit 2 ;;
esac
