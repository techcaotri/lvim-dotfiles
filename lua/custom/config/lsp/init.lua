require('custom.config.lsp.language.sh')
require('custom.config.lsp.language.cpp')

require('custom.config.autocmd').autocmd('LspAttach', {
  callback = function(ev)
    local nmap = function(keys, func, desc)
      if desc then
        desc = 'LSP: ' .. desc
      end
      vim.keymap.set('n', keys, func, { buffer = ev.buf, desc = desc })
    end
    nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
    nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')

    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<leader>lh', vim.lsp.buf.signature_help, 'Signature Documentation')

    local clients = vim.lsp.get_active_clients({ bufnr = ev.buf })
    if #clients > 0 then
      for _, client in ipairs(clients) do
        if client.server_capabilities.inlayHintProvider then
          -- vim.notify(vim.inspect(client))
          if client.name == 'clangd' then
            -- Show inlay hints using clangd_extensions
            require("clangd_extensions.inlay_hints").set_inlay_hints()
          else
            -- Show inlay_hints using the new 0.10 nvim's lsp feature
            vim.lsp.inlay_hint(ev.buf, true)
          end
        end
      end
    end
  end,
})
