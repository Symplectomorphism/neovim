return { -- Send code to a real REPL (Julia Pkg/help/shell modes, OhMyREPL, etc. all work natively)
  'Vigemus/iron.nvim',
  ft = { 'julia', 'python' },
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
          -- --no-autoindent: without it, ipython's own indentation plus the
          -- indentation already in pasted code compounds and drifts blocks
          -- (loops, function bodies) to the right on every send.
          --
          -- command is a function (iron.nvim re-evaluates it on every REPL
          -- start, not just once at setup) so it can prefer a project-local
          -- `.venv` (uv's default layout) over whatever's on $PATH -- the
          -- venv's own ipython, if present, is the only way to get its
          -- installed packages, since the binary's shebang is pinned to that
          -- venv's python regardless of what's active in the calling shell.
          python = {
            command = function()
              local venv = require 'util.python'
              local ipython = venv.venv_bin 'ipython'
              if ipython then
                return { ipython, '--no-autoindent' }
              end
              local python = venv.venv_bin 'python'
              if python then
                return { python }
              end
              return { 'ipython', '--no-autoindent' }
            end,
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

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'python',
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

        -- Cell send: cells are delimited by `# %%` markers, the Jupytext /
        -- VS Code "percent format" convention this config already uses for
        -- .ipynb round-tripping (see jupytext.nvim in quarto.lua). A cell
        -- runs from just after the marker above the cursor to just before
        -- the marker below it (or the buffer's start/end if there is none).
        local function cell_bounds()
          local cur = vim.api.nvim_win_get_cursor(0)[1]
          local lines = vim.api.nvim_buf_get_lines(ev.buf, 0, -1, false)
          local marker = '^%s*#%s*%%%%'

          local start_line = 1
          for l = cur, 1, -1 do
            if lines[l]:match(marker) then
              start_line = l + 1
              break
            end
          end

          local end_line = #lines
          for l = cur + 1, #lines do
            if lines[l]:match(marker) then
              end_line = l - 1
              break
            end
          end

          return start_line, end_line
        end

        map('n', '<localleader>sb', function()
          local start_line, end_line = cell_bounds()
          iron.send(nil, vim.api.nvim_buf_get_lines(ev.buf, start_line - 1, end_line, false))
        end, 'Send cell/block (# %%)')

        -- Cell navigation: jump to the next/previous `# %%` marker, same
        -- convention as the "next/prev section" motions this pair normally
        -- performs, repurposed here since Python has no real use for those.
        map('n', ']]', function()
          vim.fn.search('^\\s*#\\s*%%', 'W')
        end, 'Next cell')
        map('n', '[[', function()
          vim.fn.search('^\\s*#\\s*%%', 'bW')
        end, 'Previous cell')
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
