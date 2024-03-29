--Neovim plugin for adding weighting tables
local M = {}

function M.weightingTables()
  local tableArray = {}
  local input = vim.fn.input("Which questions do you want to add?: "):upper()
  if input == "" then return end
  local input_line = vim.fn.line('.')
  vim.fn.search('^TABLE', 'b')
  local line = vim.api.nvim_get_current_line()
  local tableNum = tonumber(line:sub(7))
  local questions = vim.split(input, " +", { plain = false, trimempty = true })
  for _, value in ipairs(questions) do
    local flag = vim.fn.search("QUESTION " .. value .. ":")
    tableNum = tableNum + 1
    if flag > 0 then
      local start_line = vim.fn.search('R &IN2BASE==', 'W')
      local end_line = vim.fn.search('^\\*\\n', 'W')
      local start_line2 = vim.fn.search('R &IN2\\*\\*D//S ', 'Wb')
      if start_line2 > start_line then start_line = start_line2 end
      local text = vim.api.nvim_buf_get_lines(0, start_line, end_line - 1, false)
      table.insert(tableArray, "*")
      table.insert(tableArray, "TABLE " .. tableNum)
      for _, row in ipairs(text) do
        table.insert(tableArray, row .. ";VALUE .")
      end
    else
      table.insert(tableArray, "*")
      table.insert(tableArray, "TABLE " .. tableNum)
      table.insert(tableArray, "*** " .. value .. " NOT FOUND! ***")
    end
  end
  vim.api.nvim_buf_set_lines(0, input_line - 1, input_line - 1, false, tableArray)
  vim.api.nvim_win_set_cursor(0, { input_line, 0 })
end

vim.api.nvim_create_user_command("WeightTables", M.weightingTables, {})

return M
