return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    require('nvim-treesitter').setup {}

    -- 'c', 'lua', 'vim', 'vimdoc', 'query', 'diff' are built into Neovim now
    local parsers = {
      'bash',
      'html',
      'luadoc',
      'markdown',
      'markdown_inline',
      'latex',
      'python',
      'julia',
      'cpp',
    }

    -- Only installs parsers that are missing
    require('nvim-treesitter').install(parsers)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = parsers,
      callback = function()
        vim.treesitter.start()
        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
      end,
    })
  end,
}
