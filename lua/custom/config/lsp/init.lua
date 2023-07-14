require('custom.config.lsp.language.sh')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
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
    nmap('<leader>lD', vim.lsp.buf.type_definition, 'Type [D]efinition')

    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<leader>lh', vim.lsp.buf.signature_help, 'Signature Documentation')
  end,
})