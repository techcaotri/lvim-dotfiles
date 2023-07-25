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
  end,
})

table.insert(lvim.builtin.cmp.sources, 
  { name = "vsnip" }
)
