return {
  'nvim-telescope/telescope.nvim',
  config = function()
    local builtin = require('telescope.builtin')
    vim.keymap.set('n', '<leader>f', builtin.find_files, {desc = "Telescope"})
    vim.keymap.set('n', '<leader>ff', builtin.find_files, {desc = "Find Files"})
    vim.keymap.set('n', '<leader>fg', builtin.live_grep, {desc = "Live Grep"})
    vim.keymap.set('n', '<leader>fb', builtin.buffers, {desc = "Buffers"})
    vim.keymap.set('n', '<leader>fh', builtin.help_tags, {desc = "Help"})
  end
}
