-- Neovim plugin that performs an inital cleanup of the specs used for summary tables
local function sumInit()
  local line_num = vim.fn.line('.')
  local end_line = vim.fn.search('*\\n', 'W') - 1
  local lines = vim.api.nvim_buf_get_lines(0, line_num - 1, end_line, false)
  local new_lines = {}

  local current_question = nil
  for _, line in ipairs(lines) do
    if line:match('^Q?%w+') then
      current_question = line:match('^Q?%w+')
      local diff_score = vim.fn.substitute(line, [[^Q\?\w\+.\?\(\t\+\|\s\+\)]], 'R ', '')
      diff_score = diff_score:gsub('\t+', ' ')
      table.insert(new_lines, diff_score:upper())
    elseif vim.fn.match(line, [[\(^\t\+\|^\s\+\)\(.*\)(:\d]]) >= 0 then
      local r_row = nil
      r_row = vim.fn.substitute(line, [[\((:\.*\)]], '(' .. current_question .. ':', '')
      r_row = vim.fn.substitute(r_row, [[\(^\t\+\|^\s\+\)]], 'R   ', '')
      r_row = r_row:gsub(' %(', ';(')
      table.insert(new_lines, r_row:upper())
    elseif vim.fn.match(line, [[\(^\t\+\|^\s\+\)\(%\?\)\(\d\+-\?\d*\)]]) >= 0 then
      local r_row = nil
      local group_pat = [[\(^\t\+\|^\s\+\)\(%\?\)\(\d\+-\?\d*\)]]
      local replacement = string.format([[R   \2\3;(%s:\3)]], current_question)
      r_row = vim.fn.substitute(line, group_pat, replacement, '')
      table.insert(new_lines, r_row:upper())
    elseif vim.fn.match(line, [[\(^\t\+\|^\s\+\)\(.*\)(\D]]) >= 0 then
      local r_row = nil
      r_row = vim.fn.substitute(line, [[\(^\t\+\|^\s\+\)]], 'R   ', '')
      r_row = vim.fn.substitute(r_row, [[\(\t*\|\s*\)(]], ';(', '')
      table.insert(new_lines, r_row:upper())
    end
  end
  vim.api.nvim_buf_set_lines(0, line_num - 1, end_line, false, new_lines)
  vim.api.nvim_win_set_cursor(0, { line_num, 0 })
end

vim.api.nvim_create_user_command('SumInit', sumInit, {})
