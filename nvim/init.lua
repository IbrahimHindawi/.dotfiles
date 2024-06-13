-- NEOVIM config
-- -----------------------------------------------------------------
local Plug = vim.fn['plug#']
vim.call('plug#begin', '~/vimfiles/autoload')
    Plug 'vim-airline/vim-airline'
    Plug 'folke/tokyonight.nvim'
    Plug 'sainnhe/gruvbox-material'
    Plug 'tikhomirov/vim-glsl'

    Plug 'ktunprasert/gui-font-resize.nvim'

    Plug 'nvim-treesitter/nvim-treesitter'
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/nvim-cmp'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/cmp-path'
    Plug 'hrsh7th/cmp-cmdline'
    Plug 'hrsh7th/cmp-vsnip'
    Plug 'hrsh7th/vim-vsnip'
    Plug 'mfussenegger/nvim-jdtls'

    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-telescope/telescope.nvim'

    Plug 'savq/melange-nvim'
vim.call('plug#end')

require('packer').startup(function(use)
    use {'wbthomason/packer.nvim'}
    use {'nyoom-engineering/oxocarbon.nvim'}
    use {'dgagn/diagflow.nvim'}
    -- Lua
    use {
      "folke/which-key.nvim",
      config = function()
        vim.o.timeout = true
        vim.o.timeoutlen = 300
        require("which-key").setup {
          -- your configuration comes here
          -- or leave it empty to use the default settings
          -- refer to the configuration section below
        }
      end
}
end)

-- USER
-- -----------------------------------------------------------------
vim.cmd('source '..vim.fn.stdpath("config")..'/ginit.vim')
vim.cmd('colorscheme oxocarbon')
vim.cmd('set expandtab')
vim.cmd('set guifont=Consolas:h8')
vim.cmd('set nowrap')
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
-- leader remap
vim.cmd('nnoremap <SPACE> <Nop>')
vim.cmd('let mapleader=" "')
vim.cmd('set shell=powershell.exe')
vim.opt.shell = 'powershell'
vim.opt.shellcmdflag = '-nologo -noprofile -ExecutionPolicy RemoteSigned -command'
vim.opt.shellxquote = ''

-- LSP
-- -----------------------------------------------------------------
local lspconfig = require('lspconfig')
lspconfig.pyright.setup{}
lspconfig.clangd.setup{
    -- filetypes = {"c", "h"},
    on_attach = function(client, bufnr)
      client.server_capabilities.semanticTokensProvider = nil
    end,
}
lspconfig.zls.setup{}
lspconfig.tsserver.setup{}
lspconfig.asm_lsp.setup{}
--[[
" note that if you are using Plug mapping you should not use `noremap` mappings.
nmap <F5> <Plug>(lcn-menu)
" Or map each action separately
nmap <silent>K <Plug>(lcn-hover)
nmap <silent> gd <Plug>(lcn-definition)
nmap <silent> <F2> <Plug>(lcn-rename)
]]
vim.cmd('nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>')
vim.cmd('nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>')
vim.cmd('nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>')
vim.cmd('nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>')
vim.cmd('nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>')
-- vim.cmd('nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>')
vim.cmd('nnoremap <silent> <C-p> <cmd>lua vim.lsp.buf.goto_prev()<CR>')
vim.cmd('nnoremap <silent> <C-n> <cmd>lua vim.lsp.buf.goto_next()<CR>')

-- DiagFlow
-- -----------------------------------------------------------------
require('diagflow').setup({
    enable = true,
    max_width = 100,  -- The maximum width of the diagnostic messages
    max_height = 20, -- the maximum height per diagnostics
    severity_colors = {  -- The highlight groups to use for each diagnostic severity level
        error = "DiagnosticFloatingError",
        warning = "DiagnosticFloatingWarn",
        info = "DiagnosticFloatingInfo",
        hint = "DiagnosticFloatingHint",
    },
    text_align = 'right',
    placement = 'top',
    show_borders = true
})

-- camelCase to snake_case
-- function c2s()
    -- vim.cmd([===[s//\=substitute(submatch(0),'[a-z]\@<=[A-Z]','_\l\0','g')/g]===])
-- end
vim.api.nvim_create_user_command('CamelCase2SnakeCase', [===========[%s//\=substitute(submatch(0),'[a-z]\@<=[A-Z]','_\l\0','g')/g]===========], {})

-- CMP
-- -----------------------------------------------------------------
-- Set up nvim-cmp.
local cmp = require'cmp'
cmp.setup({
snippet = {
  -- REQUIRED - you must specify a snippet engine
  expand = function(args)
    vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
  end,
},
window = {
  -- completion = cmp.config.window.bordered(),
  -- documentation = cmp.config.window.bordered(),
},
mapping = cmp.mapping.preset.insert({
  ['<C-b>'] = cmp.mapping.scroll_docs(-4),
  ['<C-f>'] = cmp.mapping.scroll_docs(4),
  ['<C-Space>'] = cmp.mapping.complete(),
  ['<C-e>'] = cmp.mapping.abort(),
  ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
}),
sources = cmp.config.sources({
  { name = 'nvim_lsp' },
  { name = 'vsnip' }, -- For vsnip users.
}, {
  { name = 'buffer' },
})
})
-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
sources = cmp.config.sources({
  { name = 'git' }, -- You can specify the `git` source if [you were installed it](https://github.com/petertriho/cmp-git).
}, {
  { name = 'buffer' },
})
})
-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
mapping = cmp.mapping.preset.cmdline(),
sources = {
  { name = 'buffer' }
}
})
-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
mapping = cmp.mapping.preset.cmdline(),
sources = cmp.config.sources({
  { name = 'path' }
}, {
  { name = 'cmdline' }
})
})
-- Set up lspconfig.
-- local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['clangd'].setup { capabilities = capabilities }
-- require('lspconfig')['pyright'].setup { capabilities = capabilities }

-- TREE
-- -----------------------------------------------------------------
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the five listed parsers should always be installed)
  ensure_installed = { "c", "lua", "python" },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,
  -- List of parsers to ignore installing (for "all")
  ignore_install = { "javascript" },
  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!
    on_attach = function(client, bufnr)
      client.server_capabilities.semanticTokensProvider = nil
    end,
  highlight = {
    enable = true,
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,
    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}

-- TELESCOPE
-- -----------------------------------------------------------------
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
