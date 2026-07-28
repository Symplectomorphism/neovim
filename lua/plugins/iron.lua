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
      ignore_blank_lines = true,
    }

    -- Bound buffer-local, not via iron's built-in `keymaps` table (which sets
    -- *global* keymaps): mapleader == maplocalleader here, so a global
    -- <localleader>sf collides with <leader>sf (Telescope find_files) -- same
    -- literal keystroke -- and silently loses depending on plugin load order.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'julia',
      callback = function(ev)
        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
        end

        map('n', '<localleader>is', '<cmd>IronRepl<cr>', 'Open REPL')
        map('n', '<localleader>ir', '<cmd>IronRestart<cr>', 'Restart REPL')
        map('n', '<localleader>if', '<cmd>IronFocus<cr>', 'Focus REPL')
        map('n', '<localleader>ih', '<cmd>IronHide<cr>', 'Hide REPL')

        map('n', '<localleader>sc', function()
          iron.run_motion 'send_motion'
        end, 'Send motion')
        map('v', '<localleader>sc', iron.visual_send, 'Send selection')
        map('n', '<localleader>sf', iron.send_file, 'Send whole file')
        map('n', '<localleader>sl', iron.send_line, 'Send line')
        map('n', '<localleader>sp', iron.send_paragraph, 'Send paragraph')
        map('n', '<localleader>su', iron.send_until_cursor, 'Send until cursor')
        map('n', '<localleader>s<cr>', function()
          iron.send(nil, string.char(13))
        end, 'Send <CR> to REPL')
        map('n', '<localleader>s<space>', function()
          iron.send(nil, string.char(3))
        end, 'Interrupt REPL')
        map('n', '<localleader>sq', iron.close_repl, 'Exit REPL')
        map('n', '<localleader>scl', function()
          iron.send(nil, string.char(12))
        end, 'Clear REPL')
      end,
    })

    -- Inside the REPL itself: <localleader>if jumps back to wherever you came
    -- from, instead of erroring (IronFocus looks up a REPL by the *calling*
    -- buffer's filetype, and the REPL buffer's own filetype is "iron", which
    -- has no repl_definition -- it's a one-directional command by design).
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'iron',
      callback = function(ev)
        vim.keymap.set('n', '<localleader>if', '<cmd>wincmd p<cr>', { buffer = ev.buf, desc = 'Jump back from REPL' })
      end,
    })
  end,
}
