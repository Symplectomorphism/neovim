return { -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    -- nvim-treesitter shells out to a bare `tree-sitter` to compile parsers.
    -- ~/.npm-global/bin/tree-sitter is a prebuilt binary linked against a
    -- newer glibc than this system ships, so it fails at runtime; the
    -- ~/.cargo/bin/tree-sitter build is compiled locally and works. Put it
    -- first so nvim's own subprocesses resolve to the working one.
    vim.env.PATH = vim.fn.expand '~/.cargo/bin' .. ':' .. vim.env.PATH

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
      'yaml',
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
