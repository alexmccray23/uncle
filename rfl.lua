-- Neovim plugin for matching an .rfl to an exported Promark .lay file

local M = {}

function M.rfl()
  M.parseLayout()
  local lflag = vim.fn.search('^Q ', 'c')
  while lflag > 0 do
    local line_num = vim.fn.line('.')
    local line = vim.api.nvim_get_current_line()
    local array = vim.split(line, ' +', { plain = false, trimempty = true })
    local question = array[2]
    local location = array[6]
    local mflag = false
    if #array > 6 then mflag = true end
    if M.contains(M.data_table, question) == false then
      line = vim.fn.substitute(line, location:sub(0, #location - 1), "[", '')
      vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { line })
      lflag = vim.fn.search('^Q ', 'W')
    else
      local start = M.data_table[question]['startCol']
      local wfield = M.data_table[question]['wfield']
      local nfield = M.data_table[question]['nfield']
      local length = wfield * nfield
      local remap = ""
      if location:match("%.") then
        remap = string.format("[%d.%d", start, length)
      else
        remap = string.format("[%d", start)
      end
      line = vim.fn.substitute(line, location:sub(0, #location - 1), remap, '')

      vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { line })

      if mflag == false then
        lflag = vim.fn.search('^Q ', 'W')
      else
        local lines = vim.fn.ceil(nfield / 3)
        local ncol = start
        for row = 1, lines do
          vim.fn.search('^X ', 'W')
          local line = vim.api.nvim_get_current_line()
          local array = vim.split(line, ' +', { plain = false, trimempty = true })
          for i = 2, #array do
            local ocol = array[i]:match("%[%d+"):sub(2)
            line = line:gsub(ocol, ncol)
            ncol = ncol + wfield
          end
          vim.api.nvim_buf_set_lines(0, line_num - 1 + row, line_num + row, false, { line })
        end
        lflag = vim.fn.search('^Q ', 'W')
      end
    end
  end
end

M.data_table = {}
local chk = 0
local buf_chk = 0
function M.parseLayout()
  local current_buffer = vim.api.nvim_get_current_buf()
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

function M.contains(table, key)
  for i, _ in pairs(table) do
    if i == key then return true end
  end
  return false
end

vim.api.nvim_create_user_command("Rfl", M.rfl, {})

return M
