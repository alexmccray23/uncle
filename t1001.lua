--Neovim plugin that converts question labels to table numbers in the banner test tables.

local M = {}

function M.testTables()
  local tableArray = {}
  local line = vim.api.nvim_get_current_line()
  local nline = vim.fn.getcurpos()[2] + 1
  local questions = line:gsub("^(X RUN )(.-)( B 9.*)", "%2")
  local temp = questions:upper()
  local array = vim.split(temp, " +", { plain = false, trimempty = true })
  for _, value in ipairs(array) do
    local flag = vim.fn.search("QUESTION " .. value .. ":", 'b')
    if flag > 0 then
      vim.fn.search("^TABLE ", 'b')
      local tableNum = string.sub(vim.api.nvim_get_current_line(), 7)
      table.insert(tableArray, tableNum)
    else
      table.insert(tableArray, "@" .. value)
    end
  end
  local new_string = table.concat(tableArray, " ")
  line = line:gsub(questions, new_string)
  vim.api.nvim_buf_set_lines(0, nline - 2, nline - 1, false, { line })
  vim.api.nvim_win_set_cursor(0, { nline, 0 })
end

vim.api.nvim_create_user_command("T1001", M.testTables, {})

return M
