return {
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local ts = require('nvim-treesitter')
    local parsers = { 'c', 'lua', 'python', 'markdown', 'markdown_inline' }

    ts.setup({
      install_dir = vim.fn.stdpath('data') .. '/site',
    })

    ts.install(parsers):wait(300000)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'c', 'lua', 'python', 'markdown' },
      callback = function()
        vim.treesitter.start()
      end,
    })

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'c', 'lua', 'python' },
      callback = function()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end,
    })
  end,
}
