return { -- Aligned columns + a header row pinned to the top while scrolling
  'hat0uma/csvview.nvim',
  ft = 'csv',
  ---@module 'csvview'
  ---@type CsvView.Options
  opts = {
    view = {
      header_lnum = true, -- auto-detect the header row
      sticky_header = { enabled = true },
    },
  },
  config = function(_, opts)
    require('csvview').setup(opts)

    -- setup() alone doesn't turn the view on; enable it whenever a csv
    -- buffer opens so the sticky header is there without a manual step.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'csv',
      callback = function(ev)
        vim.cmd 'CsvViewEnable'
        vim.keymap.set('n', '<localleader>cv', '<cmd>CsvViewToggle<cr>', { buffer = ev.buf, desc = 'Toggle CSV view' })
      end,
    })
  end,
}
