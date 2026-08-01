return { -- Floating terminals for CLI agents that don't have a dedicated IDE-integration plugin
  'akinsho/toggleterm.nvim',
  version = '*',
  cmd = 'ToggleTerm',
  ft = { 'python' },
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

    -- One-shot, non-interactive run: quick sanity check without touching the
    -- REPL. close_on_exit = false so a traceback stays on screen after exit.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'python',
      callback = function(ev)
        vim.keymap.set('n', '<localleader>rr', function()
          local file = vim.fn.expand '%:p'
          local python = require('util.python').venv_bin 'python' or 'python3'
          Terminal:new({
            cmd = vim.fn.shellescape(python) .. ' ' .. vim.fn.shellescape(file),
            direction = 'float',
            float_opts = { border = 'rounded' },
            close_on_exit = false,
          }):toggle()
        end, { buffer = ev.buf, desc = 'Run current file (venv-aware)' })
      end,
    })
  end,
}
