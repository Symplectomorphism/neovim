return {
  'NMAC427/guess-indent.nvim', -- Detect tabstop and shiftwidth automatically
  opts = {
    -- 'tex'/'plaintex'/'bib' are forced to spaces in lua/plugins/latex.lua;
    -- letting this plugin detect tabs there would fight that (and feed
    -- conform's tex-fmt --usetabs on save if a file has stray tab noise).
    filetype_exclude = { 'netrw', 'tutor', 'tex', 'plaintex', 'bib' },
  },
}
