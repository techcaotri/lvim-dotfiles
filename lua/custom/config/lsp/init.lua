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
  local clients = vim.lsp.get_active_clients({ bufnr = buf })
  if #clients > 0 then
    for _, client in ipairs(clients) do
      if client.server_capabilities.inlayHintProvider then
        -- vim.notify(vim.inspect(client))
        if client.name == 'clangd' then
          -- Show inlay hints using clangd_extensions
          require("clangd_extensions.inlay_hints").set_inlay_hints()
        else
          -- Show inlay_hints using the new 0.10 nvim's lsp feature
          local nvim_version = tostring(vim.version())
          print('current neovim build version: ' .. nvim_version)
          if nvim_version == '0.10.0-dev+g643bea31b' or nvim_version == '0.10.0-dev+gd191bdf9d' then
            vim.lsp.inlay_hint(buf, true)
          else
            vim.lsp.inlay_hint.enable(true, {})
          end
        end
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
