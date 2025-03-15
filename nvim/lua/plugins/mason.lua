return {
    'williamboman/mason.nvim',
    config = function ()
        local mason = require'mason'
        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
        })
        local masonlsp = require'mason-lspconfig'
        masonlsp.setup({
            ensure_installed = {
                'lua_ls',
                'pyright',
                'ts_ls',
                'asm_lsp',
                'glsl_analyzer',
                'marksman',
            }
        })
    end
}
