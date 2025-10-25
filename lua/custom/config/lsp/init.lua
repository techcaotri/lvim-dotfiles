require('custom.config.lsp.language.cpp')
require('custom.config.lsp.language.html_jsp')
require('custom.config.lsp.language.json')
require('custom.config.lsp.language.lua_ls')
require('custom.config.lsp.language.sh')
require('custom.config.lsp.language.go')
require('custom.config.lsp.language.cmake')
require('custom.config.lsp.language.jinja')

require("lspconfig").lua_ls.setup({
  settings = { Lua = { hint = { enable = true } } },
})

local M = {}
function M.show_inlay_hints(buf)
  local function enable_builtin_inlay(bufnr)
    -- Support both pre-0.10 dev API and 0.10+ API shapes
    -- 1) Old nightly: vim.lsp.inlay_hint(bufnr, true)
    if type(vim.lsp.inlay_hint) == "function" then
      return vim.lsp.inlay_hint(bufnr, true)
    end
    -- 2) Newer: vim.lsp.inlay_hint.enable(...)
    local ih = vim.lsp.inlay_hint
    if ih and type(ih.enable) == "function" then
      -- Try the 0.10 stable signature first: enable(bufnr, true)
      local ok = pcall(ih.enable, bufnr, true)
      if not ok then
        -- Fallback to older dev signature: enable(true, { bufnr = bufnr })
        pcall(ih.enable, true, { bufnr = bufnr })
      end
    end
  end

  local clients = vim.lsp.get_active_clients({ bufnr = buf })
  if #clients == 0 then return end

  for _, client in ipairs(clients) do
    if client.server_capabilities and client.server_capabilities.inlayHintProvider then
      if client.name == "clangd" then
        -- Use clangd_extensions if present; otherwise fall back to builtin
        local ok_ext = pcall(require, "clangd_extensions")
        if ok_ext then
          local ok_inlay, ce_inlay = pcall(require, "clangd_extensions.inlay_hints")
          if ok_inlay and ce_inlay and type(ce_inlay.set_inlay_hints) == "function" then
            ce_inlay.set_inlay_hints()
          else
            enable_builtin_inlay(buf)
          end
        else
          enable_builtin_inlay(buf)
        end
      else
        -- Non-clangd LSPs → builtin inlay hints
        enable_builtin_inlay(buf)
      end
    end
  end
end

require('custom.config.autocmd').autocmd('LspAttach', {
  callback = function(ev)
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = desc })
    end
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    -- nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')

    local client = vim.lsp.get_client_by_id(ev.data.client_id)

    if client.name ~= 'copilot' and client.name ~= 'rust-analyzer' then
      nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    end
    nmap('<leader>lh', vim.lsp.buf.signature_help, 'Signature Documentation')

    M.show_inlay_hints(ev.buf)
  end,
})

require 'lspconfig'.qmlls.setup {
  cmd = { '/home/tripham/Qt_new/6.8.0/gcc_64/bin/qmlls', '--verbose' }
}

return M;
