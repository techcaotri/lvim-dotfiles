-- LazyVim migration config (parallel to LunarVim) -- entry point.
-- Deployed via NVIM_APPNAME=lvim-lazyvim (see setup_lvim.sh), so it is fully
-- isolated from the existing LunarVim install at ~/.config/lvim.
require("config.lazy")

-- Load user keymaps + autocmds deterministically. LazyVim also auto-loads
-- lua/config/{keymaps,autocmds}.lua on VeryLazy via a cache-gated loader that can
-- skip them when the config-dir module index is not yet warm. `require` caches, so
-- these run exactly once regardless of whether LazyVim also loads them. Keymap
-- registration needs no plugins (which-key group labels defer themselves to
-- VeryLazy), so loading here is safe and guarantees they apply on every startup.
pcall(require, "config.keymaps")
pcall(require, "config.autocmds")
