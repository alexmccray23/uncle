-- Neovim plugin that formats a question series in Uncle
local wholeText = {}
local orig_cols = nil
local new_cols = nil

local M = {}

function M.menu()
  local choices = {
    { label = "1. 10/8-10/4-7/0-3",          func = M.one },
    { label = "2. 10/8-10/5-7/0-4",          func = M.two },
    { label = "3. 100/80-100/51-79/50/1-49", func = M.three },
    { label = "4. 100/80-100/50-79/1-49",    func = M.four },
    { label = "5. ABA consumption",          func = M.four },
  }
  for _, choice in ipairs(choices) do
    print(choice.label)
  end
  local input = tonumber(vim.fn.input("Select an option: "))
  if input and input >= 1 and input <= #choices then
    choices[input].func()
  else
    print(" Invalid selection")
  end
end

function M.scale()
  M.getFormat()
  M.getColumnsFirst()
  M.getColumnsRest()
  M.replaceOld()
end

function M.getFormat()
  vim.fn.search('^TABLE', 'b')
  vim.fn.search('^R &IN2BASE==', 'W')
  local start_line = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  local end_line = vim.fn.search('\\*\\n', 'W')
  wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  return wholeText
end

function M.getColumnsFirst()
  vim.fn.search('^R &IN2BASE==', 'b')
  vim.fn.search('^R \\w', 'W')
  local orig_line = vim.api.nvim_get_current_line()
  local pattern =
  "\\(.\\+;\\)\\(R\\?(\\?1\\?!\\?\\|A\\?(\\?1\\?!\\?\\|PC\\?(\\?1\\?!\\?\\)\\(.\\{-}\\)\\(,\\|-\\)\\(.\\+\\)"
  orig_cols = vim.fn.substitute(orig_line, pattern, "\\3", "")
  return orig_cols
end

function M.getColumnsRest()
  vim.fn.search('^R &IN2BASE==', 'W')
  vim.fn.search('^R \\w', 'W')
  local new_line = vim.api.nvim_get_current_line()
  local pattern =
  "\\(.\\+;\\)\\(R\\?(\\?1\\?!\\?\\|A\\?(\\?1\\?!\\?\\|PC\\?(\\?1\\?!\\?\\)\\(.\\{-}\\)\\(,\\|-\\)\\(.\\+\\)"
  new_cols = vim.fn.substitute(new_line, pattern, "\\3", "")
  return new_cols
end

function M.replaceOld()
  local new_lines = {}
  vim.fn.search('^TABLE', 'b')
  vim.fn.search('^R &IN2BASE==', 'W')
  local nline = vim.fn.getcurpos()[2] + 1
  vim.api.nvim_win_set_cursor(0, { nline, 0 })
  local eline = vim.fn.search('\\*\\n', 'W')
  for index, line in ipairs(wholeText) do
    new_lines[index] = vim.fn.substitute(line, orig_cols, new_cols, "g")
  end
  vim.api.nvim_buf_set_lines(0, nline - 1, eline - 1, false, new_lines)
end

vim.api.nvim_create_user_command("Scale", M.scale, {})

return M
