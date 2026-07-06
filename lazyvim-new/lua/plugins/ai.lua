-- AI assistants. LazyVim's ai.copilot extra (imported in config/lazy.lua) provides
-- copilot.lua; here we enable auto-trigger and add avante.nvim.
return {
  -- Copilot: enable inline auto-suggestions (matches copilot.lua config).
  {
    "zbirenbaum/copilot.lua",
    opts = function(_, opts)
      opts.suggestion = { enabled = true, auto_trigger = true }
      opts.panel = { enabled = true }
      -- Copilot needs Node >= 22, but the default `node` on this machine is v20
      -- (which makes Copilot throw a version error on every buffer). Point it at
      -- the newest nvm-installed Node >= 22 if one exists.
      local nodes = vim.fn.glob(vim.fn.expand("~") .. "/.nvm/versions/node/v*/bin/node", true, true)
      local best
      for _, n in ipairs(nodes) do
        local major = tonumber(n:match("/v(%d+)%."))
        if major and major >= 22 then
          best = n
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
