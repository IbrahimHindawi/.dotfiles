-- custom keys
vim.cmd('set nowrap')
vim.cmd('set expandtab')
vim.cmd('set tabstop=4')
vim.cmd('set shiftwidth=4')
vim.cmd('autocmd BufNewFile,BufRead *.asm set ft=masm')
vim.keymap.set('n', '<leader>c', '', {desc = 'Compile'})
-- vim.cmd('map <F5> :!scripts\\build.bat -c<cr>')
vim.keymap.set('n', '<leader>cc', ':!scripts\\build.bat -c<CR>', {desc = 'Compile'})
-- vim.cmd('map <F6> :!scripts\\build.bat -cr<CR>')
vim.keymap.set('n', '<leader>cb', ':!scripts\\build.bat -b<CR>', {desc = 'Build'})
vim.keymap.set('n', '<leader>cd', ':!scripts\\build.bat -crd<CR>', {desc = 'Debug'})
vim.keymap.set('n', '<leader>cr', ':!scripts\\build.bat -cr<CR>', {desc = 'Compile & Run'})
vim.keymap.set('n', '<leader>cm', '', {desc = 'Meta'})
vim.keymap.set('n', '<leader>cmb', ':!scripts\\build.bat -mb<CR>', {desc = 'Meta Build'})
vim.keymap.set('n', '<leader>cmc', ':!scripts\\build.bat -mc<CR>', {desc = 'Meta Compile'})
vim.keymap.set('n', '<leader>k', '', {desc = 'Code'})
vim.keymap.set('n', '<leader>kk', ':lua vim.diagnostic.setqflist()<CR>', {desc = 'Quick Fix'})
vim.keymap.set('n', '<leader>ka', ':lua vim.lsp.buf.code_action()<CR>', {desc = 'Code Action'})
-- vim.cmd('map <F11> :!scripts\\build.bat -s<CR>')
vim.cmd('nmap <C-l> :tabnext<CR>')
vim.cmd('nmap <C-h> :tabprev<CR>')
vim.cmd('set signcolumn=yes')
vim.cmd('set cursorline')

-- scrolling remap
vim.cmd('map <C-j> <C-y>')
vim.cmd('map <C-k> <C-e>')
vim.cmd('map <F2> :ClangdSwitchSourceHeader<CR>')

-- leader remap
vim.cmd('nnoremap <SPACE> <Nop>')
vim.cmd('let mapleader=" "')
vim.filetype.add({
    extension = {
        h = 'c'
    }
})

-- leader
function OpenInit()
    vim.cmd('edit ' .. vim.fn.stdpath('config') .. '/init.lua')
end
vim.keymap.set('n', '<leader>tt', ':Neotree reveal left<CR>')
vim.keymap.set('n', '<leader>tq', ':Neotree close<CR>')
vim.keymap.set('n', '<leader>q', OpenInit, {desc = "Open Config"})
vim.keymap.set('n', '<leader>t', '', {desc = "Neotree"})

-- lsp
vim.cmd('nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>')
vim.cmd('nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>')
vim.cmd('nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>')
vim.cmd('nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>')
vim.cmd('nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>')
-- vim.cmd('nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>')
vim.cmd('nnoremap <silent> <C-p> <cmd>lua vim.lsp.buf.goto_prev()<CR>')
vim.cmd('nnoremap <silent> <C-n> <cmd>lua vim.lsp.buf.goto_next()<CR>')

-- camelCase to snake_case
-- function c2s()
    -- vim.cmd([===[s//\=substitute(submatch(0),'[a-z]\@<=[A-Z]','_\l\0','g')/g]===])
-- end
vim.api.nvim_create_user_command('CamelCase2SnakeCase', [===========[%s//\=substitute(submatch(0),'[a-z]\@<=[A-Z]','_\l\0','g')/g]===========], {})
-- Load snippets from ~/.config/nvim/LuaSnip/
vim.cmd[[
" Use Tab to expand and jump through snippets
imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>' 
smap <silent><expr> <Tab> luasnip#jumpable(1) ? '<Plug>luasnip-jump-next' : '<Tab>'

" Use Shift-Tab to jump backwards through snippets
imap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
smap <silent><expr> <S-Tab> luasnip#jumpable(-1) ? '<Plug>luasnip-jump-prev' : '<S-Tab>'
]]
-- require("luasnip.loaders.from_lua").load({paths = "%USERPROFILE%/AppData/Local/nvim/LuaSnip/"})
require("luasnip.loaders.from_lua").load({paths = "~/AppData/Local/nvim/LuaSnip/"})
-- require("luasnip.loaders.from_lua").load({paths = "%USERPROFILE%\\AppData\\Local\\nvim\\LuaSnip\\"})
-- require("luasnip.loaders.from_lua").load({paths = "~/.config/nvim/LuaSnip/"})
-- Set up lspconfig.
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['clangd'].setup { capabilities = capabilities }
-- require('lspconfig')['pyright'].setup { capabilities = capabilities }
