-- Make sure to setup `mapleader` and `maplocalleader` before
-- loading lazy.nvim so that mappings are correct.
-- This is also a good place to setup other settings (vim.opt)
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"
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
require('lazy').setup('plugins')
require('nvim-keys')
vim.cmd.colorscheme 'vscode'
-- vim.opt_global.conceallevel=2
vim.diagnostic.config({
  underline = true,
  virtual_text = true,
  signs = true,
})
vim.fn.sign_define("DiagnosticSignError", {text = " ", texthl = "DiagnosticSignError"})
vim.fn.sign_define("DiagnosticSignWarn", {text = " ", texthl = "DiagnosticSignWarn"})
vim.fn.sign_define("DiagnosticSignInfo", {text = " ", texthl = "DiagnosticSignInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text = "󰌵", texthl = "DiagnosticSignHint"})

vim.api.nvim_set_hl(0, "DiagnosticUnderlineError", { underline = true, sp = "#ff0000" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineWarn",  { underline = true, sp = "#ffaa00" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineInfo",  { underline = true, sp = "#00aaff" })
vim.api.nvim_set_hl(0, "DiagnosticUnderlineHint",  { underline = true, sp = "#888888" })
