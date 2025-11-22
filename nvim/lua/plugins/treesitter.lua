return {
  'nvim-treesitter/nvim-treesitter',
  config = function()
    local config = require('nvim-treesitter.configs')
      config.setup({
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
            enable = true
        },
    })
  end
}
