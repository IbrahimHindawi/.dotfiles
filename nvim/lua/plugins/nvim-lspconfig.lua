return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "mason-org/mason.nvim",
    "mason-org/mason-lspconfig.nvim",
    "hrsh7th/cmp-nvim-lsp",
  },

  config = function()
    -- mason (installer only)
    require("mason").setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    require("mason-lspconfig").setup({
      ensure_installed = {
        "lua_ls",
        "pyright",
        "ts_ls",
        "glsl_analyzer",
        "marksman",
        "clangd",
      },
    })

    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    -- .h files are C, not C++
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = "*.h",
      callback = function() vim.bo.filetype = "c" end,
    })

    -- clangd (FORCED C MODE)
    vim.lsp.config("clangd", {
      capabilities = capabilities,
      cmd = { "clangd", "--header-insertion=never" },
      filetypes = { "c", "h" },
    })
    vim.lsp.enable("clangd")

    -- pyright
    vim.lsp.config("pyright", { capabilities = capabilities })
    vim.lsp.enable("pyright")

    -- rust_analyzer
    vim.lsp.config("rust_analyzer", { capabilities = capabilities })
    vim.lsp.enable("rust_analyzer")

    -- ts_ls
    vim.lsp.config("ts_ls", { capabilities = capabilities })
    vim.lsp.enable("ts_ls")

    -- glsl_analyzer
    vim.lsp.config("glsl_analyzer", { capabilities = capabilities })
    vim.lsp.enable("glsl_analyzer")

    -- marksman
    vim.lsp.config("marksman", { capabilities = capabilities })
    vim.lsp.enable("marksman")

    -- zls (custom path)
    vim.lsp.config("zls", { capabilities = capabilities, cmd = { "/zig/zls/zls.exe" } })
    vim.lsp.enable("zls")

    -- asm_lsp
    vim.lsp.config("asm_lsp", { capabilities = capabilities })
    vim.lsp.enable("asm_lsp")

    -- lua_ls
    vim.lsp.config("lua_ls", {
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = { globals = { "vim", "require" } },
          workspace = { checkThirdParty = false, library = vim.api.nvim_get_runtime_file("", true) },
        },
      },
    })
    vim.lsp.enable("lua_ls")
  end,
}
