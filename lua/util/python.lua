local M = {}

--- Walks up from `start_dir` looking for a `.venv` (the default layout for
--- `uv venv` / `uv sync`, also used by venv/virtualenv) and returns the path
--- to `name` inside its bin/, or nil if no venv with that executable is found.
function M.venv_bin(name, start_dir)
  local dir = start_dir or vim.fn.expand '%:p:h'
  while dir and dir ~= '' do
    local candidate = dir .. '/.venv/bin/' .. name
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      break
    end
    dir = parent
  end
  return nil
end

return M
