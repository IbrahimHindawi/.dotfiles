-- plugins are added here
-- if plugin needs config, it would be better to
-- place it under lua/plugins/pluginname.lua
return {
  'folke/tokyonight.nvim',
  'sainnhe/gruvbox-material',
  'rebelot/kanagawa.nvim',
  'NTBBloodbath/doom-one.nvim',
  'xiantang/darcula-dark.nvim',
  'bluz71/vim-moonfly-colors',
  'savq/melange-nvim',
  'EdenEast/nightfox.nvim',
  'nyoom-engineering/oxocarbon.nvim',
  'Mofiqul/vscode.nvim',
  'ss77a/carbonfox.nvim',

  'nvim-tree/nvim-web-devicons',
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
  'hrsh7th/cmp-nvim-lsp',
  'hrsh7th/cmp-buffer',
  'hrsh7th/cmp-path',
  'hrsh7th/cmp-cmdline',
  'hrsh7th/cmp-vsnip',
  'hrsh7th/vim-vsnip',

  'ktunprasert/gui-font-resize.nvim',
  'tikhomirov/vim-glsl',

  'nvim-treesitter/nvim-treesitter-context',

  'nvim-lua/plenary.nvim',
  'ziglang/zig.vim',

  'folke/which-key.nvim',
  -- Configure any other settings here. See the documentation for more details.
  -- colorscheme that will be used when installing plugins.
  install = { colorscheme = { "habamax" } },
  -- automatically check for plugin updates
  -- checker = { enabled = true },
}
