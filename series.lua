-- Neovim plugin that performs an inital cleanup of the specs used for summary tables
local wholeText = ""


local function getFormat()
  vim.fn.search('^TABLE', 'b')
  vim.fn.search('^R &IN2BASE==', 'W')
  local start_line = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  local end_line = vim.fn.search('\\*\\n', 'W')
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  wholeText = table.concat(lines, '\n')
  return wholeText
end

local function getColumnsFirst()
  vim.fn.search('^R &IN2BASE==', 'W')
  vim.fn.search('^R \\w', 'W')
  local orig_line = vim.api.nvim_get_current_line()
  local pattern = "\\(.\\+;\\)\\(R\\?(\\?1\\?\\!\\?\\|A\\?(\\?1\\?\\!\\?\\|PC\\?(\\?1\\?\\!\\?\\)\\(.\\+\\)\\(,\\|-\\)\\(.*\\)"
  local orig_cols = vim.fn.substitute(orig_line, pattern, "\\3", "")
  return orig_cols
end

local function getColumnsRest()
  vim.fn.search('^R &IN2BASE==', 'W')
  vim.fn.search('^R \\w', 'W')
  local new_line = vim.api.nvim_get_current_line()
  local pattern = "\\(.\\+;\\)\\(R\\?(\\?1\\?\\!\\?\\|A\\?(\\?1\\?\\!\\?\\|PC\\?(\\?1\\?\\!\\?\\)\\(.\\+\\)\\(,\\|-\\)\\(.*\\)"
  local new_cols = vim.fn.substitute(new_line, pattern, "\\3", "")
  return new_cols
end

local function replaceOld()
  vim.fn.search('^TABLE', 'b')
  vim.fn.search('^R &IN2BASE==', 'W')
  local start_line = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  local end_line = vim.fn.search('\\*\\n', 'W')
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  local newText = table.concat(lines, '\n')
  wholeText = vim.fn.substitute(wholeText, getColumnsFirst, getColumnsRest, '')

end

vim.api.nvim_create_user_command("Series", getColumnsRest, {})
