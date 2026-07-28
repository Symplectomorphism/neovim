-- Leader keys must be set before lazy.nvim loads plugins/keymaps
-- Deliberately different keys: localleader-prefixed mappings (iron.nvim,
-- quarto/molten) are meant to be a separate namespace from leader-prefixed
-- ones. Sharing Space for both meant <localleader>X and <leader>X were the
-- literal same keystroke, causing a real collision (iron.nvim's send_file
-- silently losing to Telescope's find_files depending on plugin load order).
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = false

-- :help option-list
vim.o.number = true
-- vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.showmode = false

-- Sync clipboard between OS and Neovim. Scheduled after UiEnter to avoid startup cost.
vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

vim.o.breakindent = true
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or a capital letter is in the search term
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true

-- Treesitter folding (lua/plugins/treesitter.lua) is available but shouldn't
-- start files pre-collapsed; foldlevel's default of 0 does exactly that.
vim.o.foldlevel = 99
