return { -- LaTeX support (Build, View, Sync)
  'lervag/vimtex',
  lazy = false, -- must load at startup to configure filetypes
  init = function()
    vim.g.vimtex_view_method = 'zathura'
    vim.g.vimtex_view_general_viewer = 'zathura'
    -- vim.g.vimtex_quickfix_mode = 0

    -- Quickfix window (errors/warnings) opens unfocused on every compile
    -- (quickfix_mode's default of 2) but otherwise lingers indefinitely.
    -- Auto-close it a few keystrokes after returning to the source buffer
    -- instead of manually <C-w>j + :q-ing it every time.
    vim.g.vimtex_quickfix_autoclose_after_keystrokes = 3

    -- Same as vimtex's built-in engine map, except the no-directive default
    -- ('_') is lualatex instead of pdflatex -- plain pdflatex can't handle
    -- fontspec (used e.g. by the nvim-cheatsheet doc). Per-file
    -- `% !TeX program = ...` directives still pick their own engine.
    vim.g.vimtex_compiler_latexmk_engines = {
      _ = '-lualatex',
      pdfdvi = '-pdfdvi',
      pdfps = '-pdfps',
      pdflatex = '-pdf',
      luatex = '-lualatex',
      lualatex = '-lualatex',
      xelatex = '-xelatex',
      ['context (pdftex)'] = '-pdf -pdflatex=texexec',
      ['context (luatex)'] = '-pdf -pdflatex=context',
      ['context (xetex)'] = "-pdf -pdflatex='texexec --xtx'",
    }

    -- Force spaces regardless of guess-indent.nvim's per-file detection
    -- (lua/plugins/guess-indent.lua excludes these filetypes). Without this,
    -- a file with stray tabs makes guess-indent set noexpandtab, which makes
    -- conform's tex-fmt formatter re-inject tabs on every save via --usetabs.
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'tex', 'plaintex', 'bib' },
      callback = function()
        vim.opt_local.expandtab = true
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
      end,
    })
  end,
}
