-- Neovim plugin for adding the difference score in summary tables
local function diffScore()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local line = vim.api.nvim_get_current_line()
  line = vim.fn.substitute(line, "\\s\\s\\+\\|\\t\\+", " ", "g")
  local new_line = vim.fn.substitute(line, "\\(D/\\{1,2\\}S)\\?\\)\\(.*\\)", "\\1\\&UT-;NONE;EX(RD1-RD2) NOSZR", "")
  vim.api.nvim_set_current_line(new_line)
  local next_line = current_line + 1
  vim.api.nvim_win_set_cursor(0, { next_line, 0 })
end
vim.api.nvim_create_user_command("DiffScore", diffScore, {})
