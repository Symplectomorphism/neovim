return { -- GitHub Copilot: inline ghost-text suggestions
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = '<M-l>',
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-]>',
      },
    },
    panel = { enabled = false }, -- ghost text only; blink.cmp handles the popup menu
  },
}
