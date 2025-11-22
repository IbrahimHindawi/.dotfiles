return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'mason-org/mason.nvim',
    'mason-org/mason-lspconfig.nvim',
    'hrsh7th/cmp-nvim-lsp',
  },

  config = function()
    require('mason').setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        }
      }
    })

    local mason_lsp = require("mason-lspconfig")

    mason_lsp.setup({
      ensure_installed = {
        "lua_ls",
        "pyright",
        "ts_ls",
        "glsl_analyzer",
        "marksman",
      }
    })

    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    vim.lsp.enable("pyright", {
      capabilities = capabilities,
    })

    vim.lsp.enable("rust_analyzer", {
      capabilities = capabilities,
    })

    vim.lsp.enable("clangd", {
      capabilities = capabilities,
      cmd = { "clangd" },
      filetypes = { "c", "h" },
    })

    vim.lsp.enable("zls", {
      capabilities = capabilities,
      cmd = { "/zig/zls/zls.exe" },
    })

    vim.lsp.enable("ts_ls", {
      capabilities = capabilities,
    })

    vim.lsp.enable("asm_lsp", {
      capabilities = capabilities,
    })

    vim.lsp.enable("glsl_analyzer", {
      capabilities = capabilities,
    })

  vim.lsp.enable("lua_ls", {
    settings = {
      Lua = {
        diagnostics = {
          globals = { "vim", "require" },
        },
        workspace = {
          checkThirdParty = false,
          library = vim.api.nvim_get_runtime_file("", true),
        },
      },
    },
  })
  end,
}
