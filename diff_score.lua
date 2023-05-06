-- Neovim plugin for adding the difference score in summary tables
local function DiffScore()
  local line = vim.api.nvim_get_current_line()
  local revised = vim.fn.substitute(line, "\\s\\s\\+\\|\\t\\+", " ", "g")
  revised = vim.fn.substitute(revised, "\\(D/\\{1,2\\}S)\\?\\)\\(.*\\)", "\\1\\&UT-;NONE;EX(RD1-RD2) NOSZR", "")
  local new_line = revised
  vim.api.nvim_set_current_line(new_line)
end
vim.api.nvim_create_user_command("DiffScore", DiffScore, {})
