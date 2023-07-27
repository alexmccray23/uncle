-- Neovim plugin for matching an .rfl to a exported Promark .lay file

local M = {}

function M.rfl()
  M.parseLayout()
  local line_num = vim.fn.line('.')
  local line = vim.api.nvim_get_current_line()
  local question = M.selectQuestions()[2]
  local location = M.selectQuestions()[3]
  local start = M.data_table[question]['startCol']
  local length = M.data_table[question]['wfield']
  local remap = ""
  if location:match("%.") then
    remap = string.format("[%d.%d", start, length)
  else
    remap = string.format("[%d", start)
  end
  line = vim.fn.substitute(line, location:sub(0, #location - 1), remap, '')

  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { line })
  vim.fn.search('^Q ', 'W')
end

function M.selectQuestions()
  local buffer = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_get_current_line()
  local array = vim.split(line, ' +', { plain = false, trimempty = true })
  return { buffer, array[2], array[6] }
end

M.data_table = {}
local chk = 0
local buf_chk = 0
function M.parseLayout()
  local current_buffer = M.selectQuestions()[1]
  if chk > 1 and buf_chk == current_buffer then
    return M.data_table
  end
  if buf_chk ~= current_buffer then
    M.data_table = {}
  end

  local layDir = vim.split(vim.fn.expand("%:p"), "/", { plain = true })
  table.remove(layDir, #layDir)
  local fullPath = table.concat(layDir, "/") .. "/*.[Ll][Aa][Yy]"
  local temp = vim.fn.glob(fullPath, false, true)
  if #temp == 0 then
    print("Can't find layout file in current directory")
    return M
  end
  local layout = vim.fn.readfile(temp[#temp])
  for _, value in ipairs(layout) do
    local column = vim.split(value, ' +', { plain = false, trimempty = true })
    chk = #column[1]
    buf_chk = current_buffer
    M.data_table[column[1]] = {
      startCol = tonumber(column[2]),
      endCol = tonumber(column[3]),
      nfield = tonumber(column[5]),
      wfield = tonumber(column[6])
    }
  end
  return M.data_table
end

vim.api.nvim_create_user_command("Rfl", M.rfl, {})

return M
