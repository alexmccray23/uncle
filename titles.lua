-- Neovim plugin for shifting banner titles to fit above their columns

local M = {}

function M.copyTable()
  vim.fn.search('^Q ', 'b')
  local start_line = vim.fn.getcurpos()[2]
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  local end_line = vim.fn.search('\\*\\n', 'W')
  local text = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  return { text, start_line, end_line }
end

