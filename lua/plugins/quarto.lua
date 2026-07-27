return {
  { -- Quarto
    'quarto-dev/quarto-nvim',
    dependencies = {
      'jmbuhr/otter.nvim',
      'nvim-treesitter/nvim-treesitter',
    },
    config = function()
      require('quarto').setup {
        lspFeatures = {
          enabled = true,
          chunks = 'curly',
          languages = { 'r', 'python', 'julia', 'bash', 'lua', 'html' },
          diagnostics = {
            enabled = true,
            triggers = { 'BufWritePost' },
          },
          completion = {
            enabled = true,
          },
        },
        keymap = {
          format = nil, -- keep <leader>f mapped to conform.nvim

          hover = 'K',
          definition = 'gd',

          -- Kickstart uses 'grn' for rename; keep both, or set to nil to use 'grn' exclusively
          rename = '<leader>rn',
          references = 'gr',
        },
        codeRunner = {
          enabled = true,
          default_method = 'molten',
        },
      }
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'quarto' }, -- add 'markdown' too if you want in .md
        callback = function(ev)
          local runner = require 'quarto.runner'
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
          end
          map('n', '<localleader>rc', runner.run_cell, 'Quarto: run cell')
          map('n', '<localleader>rl', runner.run_line, 'Quarto: run line')
          map('n', '<localleader>rA', runner.run_all, 'Quarto: run all cells')
          map('v', '<localleader>r', runner.run_range, 'Quarto: run visual range')
        end,
      })
    end,
  },

  { -- Molten (Jupyter Runner)
    'benlubas/molten-nvim',
    version = '^1.0.0',
    build = ':UpdateRemotePlugins',
    dependencies = { '3rd/image.nvim' },
    init = function()
      vim.g.python3_host_prog = vim.fn.expand '~/.virtualenvs/neovim/bin/python'
      vim.g.molten_image_provider = 'image.nvim'
      -- vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = true
      vim.g.molten_auto_open_html_in_browser = true
      vim.g.molten_tick_rate = 200
    end,
    config = function()
      local init = function()
        vim.cmd [[MoltenInit]]
      end
      local deinit = function()
        vim.cmd [[MoltenDeinit]]
      end
      vim.keymap.set('n', '<localleader>mi', init, { silent = true, desc = 'Initialize molten' })
      vim.keymap.set('n', '<localleader>md', deinit, { silent = true, desc = 'Stop molten' })
      vim.keymap.set('n', '<localleader>mp', ':MoltenImagePopup<CR>', { silent = true, desc = 'molten image popup' })
      vim.keymap.set('n', '<localleader>mb', ':MoltenOpenInBrowser<CR>', { silent = true, desc = 'molten open in browser' })
      vim.keymap.set('n', '<localleader>mh', ':MoltenHideOutput<CR>', { silent = true, desc = 'hide output' })
      vim.keymap.set('n', '<localleader>ms', ':noautocmd MoltenEnterOutput<CR>', { silent = true, desc = 'show/enter output' })
    end,
  },

  { -- Jupytext: transparently edit .ipynb files as Quarto markdown, synced
    -- back to .ipynb on save via the `jupytext` CLI (pip install --user jupytext).
    -- Python cells get filetype=quarto, so the run-cell keymaps above (rc/rl/rA/r)
    -- work on .ipynb files the same way they already do on .qmd files.
    'GCBallesteros/jupytext.nvim',
    lazy = false,
    opts = {
      custom_language_formatting = {
        python = {
          extension = 'qmd',
          style = 'quarto',
          force_ft = 'quarto',
        },
      },
    },
  },

  { -- Image Rendering
    '3rd/image.nvim',
    opts = {
      backend = 'ueberzug',
      processor = 'magick_cli',
      max_width = 100,
      max_height = 12,
      max_width_window_percentage = math.huge,
      max_height_window_percentage = math.huge,
      window_overlap_clear_enabled = true,
      window_overlap_clear_ft_ignore = { 'cmp_menu', 'cmp_docs', '' },
    },
  },

  { -- Otter (LSP for embedded code chunks)
    'jmbuhr/otter.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {},
  },
}
