-- Neovim plugin for combining tables
local function combine()
  vim.fn.search('^TABLE', 'b')
  local start_line = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  vim.fn.search('\\*\\n', 'W')
  local cursor = vim.fn.line('.')
  local end_line = vim.fn.search('\\*\\n', 'W')
  local text = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  for index, line in ipairs(text) do
    if line:match("^%*$") then
      table.remove(text, index)
      table.remove(text, index)
    end
  end
  for index, line in ipairs(text) do
    if index > 3 then
      if line:match("T QUESTION") then
        line = line:gsub("^T (.*)", "R /  /%1;NULL;MR")
      elseif line:match("^T .*") then
        line = line:gsub("^(T )(.*)", "R %2;NULL;MR")
      end
      text[index] = line
    end
  end
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line - 1, false, text)
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
end
vim.api.nvim_create_user_command("Combine", combine, {})
