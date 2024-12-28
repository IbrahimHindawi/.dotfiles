-- custom keys
vim.cmd('set nowrap')
vim.cmd('set expandtab')
vim.cmd('set tabstop=4')
vim.cmd('set shiftwidth=4')
vim.cmd('autocmd BufNewFile,BufRead *.asm set ft=masm')
vim.cmd('map <F5> :!scripts\\build.bat -c<CR>')
vim.cmd('map <F6> :!scripts\\build.bat -cr<CR>')
vim.cmd('map <F11> :!scripts\\build.bat -s<CR>')
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
vim.keymap.set('n', '<leader>c', OpenInit)

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
