-- Neovim plugin for summing weighting table values
local function weightAdd()
  local start_line = vim.fn.getcurpos()[2]
  local end_line = vim.fn.search('^\\*', 'W')
  local text = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  local value = 0
  for _, v in ipairs(text) do
    v = string.sub(vim.split(v, ";", { plain = true })[3], 7)
    value = value + v
  end
  print("Weighting sum: " .. value)
end
vim.api.nvim_create_user_command("WtAdd", weightAdd, {})
