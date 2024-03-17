-- Uncle syntax plugin

local M = {}

function M.selectQuestions()
  local buffer = vim.api.nvim_get_current_buf()
  local line = vim.api.nvim_get_current_line()
  local array = vim.split(line, ";", { plain = true })
  return { array[2], buffer }
end

M.data_table = {}
local chk = 0
local buf_chk = 0
function M.parseLayout()
  local current_buffer = M.selectQuestions()[2]
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

function M.parseSpec()
  local spec_table = {}
  local data_table = M.data_table
  local specs = vim.split(M.selectQuestions()[1]:upper():gsub(', ', ','), ' +', { plain = false, trimemtpy = true })
  for index, value in ipairs(specs) do
    if value:match("^[oO][rR]$") then
      spec_table[index] = {
        question = "OR",
        code = "OR",
        spec = "OR"
      }
    else
      local spec = vim.fn.substitute(value, [[\([nN][oO][tT]\)\?(\+\|)\+]], '', '')
      local qnum = vim.split(spec, '-', {})
      if data_table[qnum[1]] ~= nil then
        spec_table[index] = {
          question = qnum[1],
          code = qnum[2],
          spec = spec
        }
      elseif data_table["Q" .. qnum[1]] ~= nil then
        spec_table[index] = {
          question = "Q" .. qnum[1],
          code = qnum[2],
          spec = spec
        }
      else
        print("Can't find Q" .. qnum[1] .. " or " .. qnum[1] .. " in the layout file")
      end
    end
  end
  return spec_table
end

function M.replaceColumns()
  local fullSpec = M.selectQuestions()[1]:gsub(', ', ',')
  local origSpec = fullSpec
  local spec_table = M.parseSpec()
  for i, k in ipairs(spec_table) do
    if not k['question']:match("^[oO][rR]$") then
      local syntax = ""
      local code = spec_table[i]['code']
      local spec = [[\(!\S*\)\@<!]] .. spec_table[i]['spec']
      local scol = M.data_table[spec_table[i]['question']]['startCol']
      local ecol = M.data_table[spec_table[i]['question']]['endCol']
      local wfield = M.data_table[spec_table[i]['question']]['wfield']
      local nfield = M.data_table[spec_table[i]['question']]['nfield']

      if wfield == 1 then
        if scol == ecol then
          syntax = "1!" .. scol .. "-" .. code
          fullSpec = vim.fn.substitute(fullSpec, spec, syntax, '')
        else
          syntax = "1!" .. scol .. ":" .. ecol .. "-" .. code
          fullSpec = vim.fn.substitute(fullSpec, spec, syntax, '')
        end
      else
        if nfield == 1 then
          syntax = "R(1!" .. scol .. ":" .. ecol .. "," .. code .. ")"
          fullSpec = vim.fn.substitute(fullSpec, spec, syntax, '')
        elseif nfield == 2 then
          syntax = "R(1!" ..
              scol .. ":" .. (scol + wfield - 1) .. "/1!" .. (ecol - wfield + 1) .. ":" .. ecol .. "," .. code .. ")"
          fullSpec = vim.fn.substitute(fullSpec, spec, syntax, '')
        elseif nfield == 3 then
          syntax = "R(1!" ..
              scol ..
              ":" ..
              (scol + wfield - 1) ..
              "/1!" ..
              (scol + (2 * (wfield - 1))) ..
              ":" .. (scol + (3 * (wfield - 1))) .. "/1!" .. (ecol - wfield + 1) .. ":" .. ecol .. "," .. code .. ")"
          fullSpec = vim.fn.substitute(fullSpec, spec, syntax, '')
        else
          syntax = "R(1!" ..
              scol ..
              ":" ..
              (scol + wfield - 1) ..
              "/1!" ..
              (scol + (2 * (wfield - 1))) ..
              ":" .. (scol + (3 * (wfield - 1))) .. "...1!" .. (ecol - wfield + 1) .. ":" .. ecol .. "," .. code .. ")"
          fullSpec = vim.fn.substitute(fullSpec, spec, syntax, '')
        end
      end
    end
  end
  local line = vim.api.nvim_get_current_line()
  local array = vim.split(line, ";", { plain = true })
  array[2] = vim.fn.substitute(array[2]:gsub(', ', ','), origSpec, fullSpec, '')
  vim.api.nvim_set_current_line(vim.fn.join(array, ";"):upper())
end

function M.uncleSyntax()
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    M.parseLayout()
    M.replaceColumns()
    local next_line = current_line + 1
    vim.api.nvim_win_set_cursor(0, { next_line, 0 })
    current_line = next_line
  end
end

function M.combFix()
  local line = vim.fn.line('.')
  vim.cmd([[SpecFix]])
  vim.api.nvim_win_set_cursor(0, { line, 0 })
  vim.cmd([[USyntax]])
end

vim.api.nvim_create_user_command("USyntax", M.uncleSyntax, {})

return M
