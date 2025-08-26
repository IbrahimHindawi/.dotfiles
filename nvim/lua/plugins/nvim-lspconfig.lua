return {
  'neovim/nvim-lspconfig',
  config = function()
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
    -- masonlsp.setup()
    -- masonlsp.setup({
    --     ensure_installed = {
    --         'lua_ls',
    --         'pyright',
    --         'ts_ls',
    --         'glsl_analyzer',
    --         'marksman',
    --     }
    -- })
    -- local masonlsp = require'mason-lspconfig',
    -- 'mason-org/mason-lspconfig.nvim',
    local masonlsp = require'mason-lspconfig'
    opts = {}
    dependencies = {
        { 'mason-org/mason.nvim', opts = {} },
        'neovim/nvim-lspconfig',
    }
    -- require "configs.lspconfig",
    local capabilities = require('cmp_nvim_lsp').default_capabilities()
    local lspconfig = require('lspconfig')
    -- lspconfig.on_server_ready(function(server)
    --     local opts = {},
    --     server:setup(opts)
    -- end)
    lspconfig.pyright.setup{}
    lspconfig.rust_analyzer.setup{}
    lspconfig.clangd.setup{
        capabilities = capabilities,
        cmd = {
            "clangd",
            -- "--function-arg-placeholders"
        },
        filetypes = {"c", "h"},
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
        cmd = { '/zig/zls/zls.exe' }
    }
    lspconfig.ts_ls.setup{}
    lspconfig.asm_lsp.setup{}
    lspconfig.glsl_analyzer.setup{}
    lspconfig.lua_ls.setup {
      on_init = function(client)
        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if vim.loop.fs_stat(path..'/.luarc.json') or vim.loop.fs_stat(path..'/.luarc.jsonc') then
            return
          end
        end

        client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
          runtime = {
            -- Tell the language server which version of Lua you're using
            -- (most likely LuaJIT in the case of Neovim)
            version = 'LuaJIT'
          },
          -- Make the server aware of Neovim runtime files
          workspace = {
            checkThirdParty = false,
            library = {
              vim.env.VIMRUNTIME
              -- Depending on the usage, you might want to add additional paths here.
              -- "${3rd}/luv/library"
              -- "${3rd}/busted/library",
            }
            -- or pull in all of 'runtimepath'. NOTE: this is a lot slower and will cause issues when working on your own configuration (see https://github.com/neovim/nvim-lspconfig/issues/3189)
            -- library = vim.api.nvim_get_runtime_file("", true)
          }
        })
      end,
      settings = {
        Lua = {}
      }
    }
  end
}

