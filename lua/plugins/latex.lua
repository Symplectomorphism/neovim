return { -- LaTeX support (Build, View, Sync)
  'lervag/vimtex',
  lazy = false, -- must load at startup to configure filetypes
  init = function()
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_view_general_viewer = 'zathura'
    -- vim.g.vimtex_quickfix_mode = 0
  end,
}
