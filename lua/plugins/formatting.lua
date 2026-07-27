return { -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      -- Skip lsp_fallback format-on-save for languages without a standardized style
      local disable_filetypes = { c = true, cpp = true }
      local ft = vim.bo[bufnr].filetype
      if disable_filetypes[ft] then
        return nil
      else
        -- julia has to pay Julia's process startup cost on every save
        local slow_filetypes = { julia = true }
        return { timeout_ms = slow_filetypes[ft] and 5000 or 500, lsp_format = 'fallback' }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      python = { 'ruff_format', 'ruff_organize_imports' },
      tex = { 'tex-fmt' },
      julia = { 'juliaformatter' },
      -- javascript = { 'prettierd', 'prettier', stop_after_first = true },
    },
    formatters = {
      juliaformatter = {
        command = 'julia',
        args = { '-e', 'using JuliaFormatter; format(ARGS[1])', '--', '$FILENAME' },
        stdin = false,
      },
    },
  },
}
