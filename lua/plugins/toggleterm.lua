return { -- Floating terminals for CLI agents that don't have a dedicated IDE-integration plugin
  'akinsho/toggleterm.nvim',
  version = '*',
  cmd = 'ToggleTerm',
  keys = { '<leader>ag' },
  opts = {
    direction = 'float',
    float_opts = { border = 'rounded' },
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    local Terminal = require('toggleterm.terminal').Terminal
    local antigravity = Terminal:new { cmd = 'agy', hidden = true, direction = 'float' }

    vim.keymap.set({ 'n', 't' }, '<leader>ag', function()
      antigravity:toggle()
    end, { desc = 'Toggle Antigravity CLI' })
  end,
}
