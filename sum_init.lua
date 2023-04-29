-- Neovim plugin that performs an inital cleanup of the specs used for summary tables
local function sumInit()
  local line_num = vim.fn.line('.')
  local end_line = vim.fn.search('*\\n', 'W') - 1
  local lines = vim.api.nvim_buf_get_lines(0, line_num - 1, end_line, false)
  local new_lines = {}

  local current_question = nil
  for index, line in ipairs(lines) do
    if line:match('^Q?%w+') then
      current_question = line:match('^Q?%w+')
      local diff_score = vim.fn.substitute(line, '^Q\\?\\w\\+.\\?\\(\\t\\+\\|\\s\\+\\)', 'R ', '')
      diff_score = diff_score:gsub('\t+', ' ')
      diff_score = diff_score:gsub('\r', '\n')
      new_lines[index] = string.upper(diff_score)
    elseif vim.fn.match(line, "\\(^\\t\\+\\|^\\s\\+\\)\\(.*\\)(:\\d") >= 0 then
      local r_row = nil
      r_row = vim.fn.substitute(line, "\\((:\\.*\\)", '(' .. current_question .. ":", "")
      r_row = vim.fn.substitute(r_row, "\\(^\\t\\+\\|^\\s\\+\\)", "R   ", "")
      r_row = r_row:gsub(" %(", ';(')
      r_row = r_row:gsub('\r', '\n')
      new_lines[index] = string.upper(r_row)
    elseif vim.fn.match(line, "\\(^\\t\\+\\|^\\s\\+\\)\\(%\\?\\)\\(\\d\\+-\\?\\d*\\)") >= 0 then
      local r_row = nil
      local group_pat = "\\(^\\t\\+\\|^\\s\\+\\)\\(%\\?\\)\\(\\d\\+-\\?\\d*\\)"
      r_row = vim.fn.substitute(line, group_pat, 'R   \\2\\3;(' .. current_question .. ':\\3)', '')
      r_row = r_row:gsub('\r', '\n')
      new_lines[index] = string.upper(r_row)
    elseif vim.fn.match(line, "\\(^\\t\\+\\|^\\s\\+\\)\\(.*\\)(\\D") >= 0 then
      local r_row = nil
      r_row = vim.fn.substitute(line, "\\(^\\t\\+\\|^\\s\\+\\)", "R   ", "")
      r_row = vim.fn.substitute(r_row, "\\(\\t*\\|\\s*\\)(", ";(", "")
      r_row = r_row:gsub('\r', '\n')
      new_lines[index] = string.upper(r_row)
    end
  end
  vim.api.nvim_buf_set_lines(0, line_num - 1, end_line, false, new_lines)
end

vim.api.nvim_create_user_command("SumInit", sumInit, {})
