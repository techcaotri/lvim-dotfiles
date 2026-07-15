-- AI assistants. LazyVim's ai.copilot extra (imported in config/lazy.lua) provides
-- copilot.lua; here we enable auto-trigger and add avante.nvim.
return {
  -- Copilot: enable inline auto-suggestions (matches copilot.lua config).
  {
    "zbirenbaum/copilot.lua",
    opts = function(_, opts)
      -- Inline grey ghost-text suggestions (not the completion popup -- see
      -- vim.g.ai_cmp = false in config/options.lua). Accept with <M-l> (Alt+l);
      -- LazyVim's extra disables copilot's accept key for its cmp integration, so
      -- we set it back here. Cycle with <M-]>/<M-[>, dismiss with <C-]>.
      opts.suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        keymap = {
          accept = "<M-l>",
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      }
      opts.panel = { enabled = false }
      -- Copilot needs Node >= 22, but the `node` on PATH may be older (v20), which
      -- makes Copilot throw a version error on every buffer. Point it at the newest
      -- Node >= 22 we can find. nvm installs under either root depending on how it
      -- was bootstrapped, so both are scanned.
      local home = vim.fn.expand("~")
      local patterns = {
        home .. "/.nvm/versions/node/v*/bin/node", -- stock nvm ($NVM_DIR=~/.nvm)
        home .. "/.local/share/nvm/v*/bin/node", -- XDG-style nvm layout
      }
      if vim.env.NVM_DIR then
        table.insert(patterns, vim.env.NVM_DIR .. "/versions/node/v*/bin/node")
        table.insert(patterns, vim.env.NVM_DIR .. "/v*/bin/node")
      end
      local best, best_rank
      for _, pattern in ipairs(patterns) do
        for _, node in ipairs(vim.fn.glob(pattern, true, true)) do
          local major, minor, patch = node:match("/v(%d+)%.(%d+)%.(%d+)/")
          if major and tonumber(major) >= 22 then
            -- Rank numerically: a plain string/glob order would put v9 above v22.
            local rank = tonumber(major) * 1e6 + tonumber(minor) * 1e3 + tonumber(patch)
            if not best_rank or rank > best_rank then
              best, best_rank = node, rank
            end
          end
        end
      end
      if best then
        opts.copilot_node_command = best
      end
      return opts
    end,
  },

  -- Avante (Cursor-like AI). Needs ANTHROPIC_API_KEY at runtime to actually query.
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    build = "make",
    opts = {
      provider = "claude",
      behaviour = {
        auto_suggestions = false,
        auto_set_keymaps = true,
        minimize_diff = true,
        enable_token_counting = true,
      },
      windows = {
        position = "right",
        width = 30,
        wrap = true,
        input = { height = 8 },
      },
      diff = { autojump = true, list_opener = "copen", override_timeoutlen = 500 },
      suggestion = { debounce = 600, throttle = 600 },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-telescope/telescope.nvim",
      "hrsh7th/nvim-cmp",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = { default = { embed_image_as_base64 = false, prompt_for_file_name = false } },
      },
      {
        "MeanderingProgrammer/render-markdown.nvim",
        ft = { "markdown", "Avante" },
        opts = { file_types = { "markdown", "Avante" } },
      },
    },
  },
}
