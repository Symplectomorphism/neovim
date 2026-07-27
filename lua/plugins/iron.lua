return { -- Send code to a real REPL (Julia Pkg/help/shell modes, OhMyREPL, etc. all work natively)
  'Vigemus/iron.nvim',
  ft = { 'julia' },
  config = function()
    local iron = require 'iron.core'
    local view = require 'iron.view'

    iron.setup {
      config = {
        scratch_repl = true,
        repl_definition = {
          julia = {
            command = { 'julia', '--project=@.' },
            format = require('iron.fts.common').bracketed_paste,
          },
        },
        repl_open_cmd = view.right(0.4),
      },
      keymaps = {
        send_motion = '<localleader>sc',
        visual_send = '<localleader>sc',
        send_file = '<localleader>sf',
        send_line = '<localleader>sl',
        send_paragraph = '<localleader>sp',
        send_until_cursor = '<localleader>su',
        cr = '<localleader>s<cr>',
        interrupt = '<localleader>s<space>',
        exit = '<localleader>sq',
        clear = '<localleader>scl',
      },
      ignore_blank_lines = true,
    }

    vim.keymap.set('n', '<localleader>is', '<cmd>IronRepl<cr>', { desc = 'Open REPL' })
    vim.keymap.set('n', '<localleader>ir', '<cmd>IronRestart<cr>', { desc = 'Restart REPL' })
    vim.keymap.set('n', '<localleader>if', '<cmd>IronFocus<cr>', { desc = 'Focus REPL' })
    vim.keymap.set('n', '<localleader>ih', '<cmd>IronHide<cr>', { desc = 'Hide REPL' })
  end,
}
