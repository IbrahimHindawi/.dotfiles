-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Setup lazy.nvim
require("lazy").setup({
  spec = {
    'nvim-lualine/lualine.nvim',
    'nvim-tree/nvim-web-devicons',
    'folke/tokyonight.nvim',
    'sainnhe/gruvbox-material',
    'rebelot/kanagawa.nvim',
    'NTBBloodbath/doom-one.nvim',
    'xiantang/darcula-dark.nvim',
    'bluz71/vim-moonfly-colors',
    'savq/melange-nvim',
    'EdenEast/nightfox.nvim',
    'nyoom-engineering/oxocarbon.nvim',

    {
      "startup-nvim/startup.nvim",
      dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim", "nvim-telescope/telescope-file-browser.nvim" },
      config = function()
        require "startup".setup()
      end
    },
    {
        'nvim-neo-tree/neo-tree.nvim',
        branch = "v3.x",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "nvim-tree/nvim-web-devicons",
          "MunifTanjim/nui.nvim",
        }
    },

    'ktunprasert/gui-font-resize.nvim',

    'nvim-treesitter/nvim-treesitter',
    'nvim-treesitter/nvim-treesitter-context',
    'neovim/nvim-lspconfig',
    'hrsh7th/nvim-cmp',
    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-path',
    'hrsh7th/cmp-cmdline',
    'hrsh7th/cmp-vsnip',
    'hrsh7th/vim-vsnip',
    'tikhomirov/vim-glsl',

    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
    'ziglang/zig.vim',

    'folke/which-key.nvim',
  },
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  checker = { enabled = true },
})

-- USER
-- -----------------------------------------------------------------
vim.cmd('colorscheme carbonfox')
-- vim.cmd('set guifont=Consolas:h8')
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

function openinit()
    vim.cmd('edit ' .. vim.fn.stdpath('config') .. '/init.lua')
end

vim.keymap.set('n', '<leader>tt', ':Neotree reveal left<CR>')
vim.keymap.set('n', '<leader>tq', ':Neotree close<CR>')
vim.keymap.set('n', '<leader>c', openinit)


-- LSP
-- -----------------------------------------------------------------
local lspconfig = require('lspconfig')
-- lspconfig.on_server_ready(function(server)
--     local opts = {},
--     server:setup(opts)
-- end)
lspconfig.pyright.setup{}
lspconfig.clangd.setup{
    cmd = {
        "clangd",
        -- "--function-arg-placeholders"
    },
    filetypes = {"c", "h", "cpp"},
    -- on_init = function(client, initialization_result)
    --     if client.server_capabilities then
    --         client.server_capabilities.documentFormattingProvider = false
    --         client.server_capabilities.semanticTokensProvider = false
    --     end
    -- end,
    -- on_attach = function(client, bufnr)
    --     client.server_capabilities.semanticTokensProvider = nil
    -- end,
}
lspconfig.zls.setup{
    cmd = { '\\zig\\zls\\zls.exe' }
}
lspconfig.ts_ls.setup{}
lspconfig.asm_lsp.setup{}
lspconfig.glsl_analyzer.setup{}

-- TREE
-- -----------------------------------------------------------------
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c", "lua", "python" },
  sync_install = false,
  auto_install = true,
    -- on_attach = function(client, bufnr)
    --   client.server_capabilities.semanticTokensProvider = nil
    -- end,
  highlight = {
    enable = true,
    -- additional_vim_regex_highlighting = false,
  },
  indent = { 
      enable = false 
  },
}

-- LUALINE
-- -----------------------------------------------------------------
require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
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
-- require('diagflow').setup({
--     enable = true,
--     max_width = 100,  -- The maximum width of the diagnostic messages
--     max_height = 20, -- the maximum height per diagnostics
--     severity_colors = {  -- The highlight groups to use for each diagnostic severity level
--         error = "DiagnosticFloatingError",
--         warning = "DiagnosticFloatingWarn",
--         info = "DiagnosticFloatingInfo",
--         hint = "DiagnosticFloatingHint",
--     },
--     text_align = 'right',
--     placement = 'top',
--     show_borders = true
-- })

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

-- TELESCOPE
-- -----------------------------------------------------------------
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
