vim.keymap.set('n', 'zR', require('ufo').openAllFolds, { desc = 'Open All Folds' })
vim.keymap.set('n', 'zM', require('ufo').closeAllFolds , { desc = 'Close All Folds' })

return {
  'kevinhwang91/nvim-ufo',
  event = 'BufReadPost',
  dependencies = {
      'kevinhwang91/promise-async',
      'nvim-treesitter/nvim-treesitter'
  },
  init = function ()
    vim.o.foldenable = true
    vim.o.foldcolumn = 'auto:9'
    vim.o.foldlevel = 99
    vim.o.foldlevelstart = 99
    vim.o.fillchars = 'eob: ,fold: ,foldopen:⌄,foldsep:│,foldclose:>'
  end,
  config = function ()
    local ufo = require'ufo'
    ufo.setup({
        provider_selector = function (bufnr, filetype, buftype)
            return { 'lsp', 'indent' }
        end
    })
  end
}

