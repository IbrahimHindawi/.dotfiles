return {
  'epwalsh/obsidian.nvim',
  -- config = function ()
    -- local obsidian = require'obsidian'
    -- obsidian.setup({
        version = "*",  -- recommended, use latest release instead of latest commit
        lazy = true,
        ft = "markdown",
        conceallevel = 2,
        ui = {
            enable = false,
            checkboxes = {
                [" "] = { char = "󰄱", hl_group = "ObsidianTodo" },
                ["x"] = { char = "", hl_group = "ObsidianDone" },
                [">"] = { char = "", hl_group = "ObsidianRightArrow" },
                ["~"] = { char = "󰰱", hl_group = "ObsidianTilde" },
                ["!"] = { char = "", hl_group = "ObsidianImportant" },         
            },
        },
        -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
        -- event = {
        --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
        --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
        --   -- refer to `:h file-pattern` for more examples
        --   "BufReadPre path/to/my-vault/*.md",
        --   "BufNewFile path/to/my-vault/*.md",
        -- },
        dependencies = {
        -- Required.
        "nvim-lua/plenary.nvim",
        },
        opts = {
          workspaces = {
            {
              name = "personal",
              path = "~/vaults/personal",
            },
            {
              name = "work",
              path = "~/vaults/work",
            },
          },
        },
  -- })
  -- end
}
