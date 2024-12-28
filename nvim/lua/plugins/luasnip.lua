return {
  'L3MON4D3/LuaSnip',
  config = function ()
    -- Load snippets from ~/.config/nvim/LuaSnip/
    vim.cmd[[
    " Use Tab to expand and jump through snippets
    imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
    smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'

    " Use Shift-Tab to jump backwards through snippets
    imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
    smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
    ]]
    require("luasnip.loaders.from_lua").load({paths = "%USERPROFILE%/AppData/Local/nvim/LuaSnip/"})
    -- require("luasnip.loaders.from_lua").load({paths = "%USERPROFILE%\\AppData\\Local\\nvim\\LuaSnip\\"})
    -- require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})
    -- Set up lspconfig.
    -- local capabilities = require('cmp_nvim_lsp').default_capabilities()
    -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
    -- require('lspconfig')['clangd'].setup { capabilities = capabilities }
    -- require('lspconfig')['pyright'].setup { capabilities = capabilities }
  end
}
