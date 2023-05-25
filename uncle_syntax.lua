-- Uncle syntax plugin

M = {}

function M.selectQuestions()
  local line = vim.api.nvim_get_current_line()
  local array = vim.split(line, ";", { plain = true })
  return array[2]
end

function M.parseLayout()
  Data = {}
  local layDir = vim.split(vim.fn.expand("%:p"), "/", { plain = true })
  table.remove(layDir, #layDir)
  local fullPath = table.concat(layDir, "/") .. "/*.[Ll][Aa][Yy]"
  local temp = vim.fn.glob(fullPath, false, true)
  local layout = vim.fn.readfile(temp[#temp])
  for _, value in ipairs(layout) do
    local column = vim.split(value, ' +', { plain = false, trimempty = true })
    Data[column[1]] = {
      startCol = tonumber(column[2]),
      endCol = tonumber(column[3]),
      nfield = tonumber(column[5]),
      wfield = tonumber(column[6])
    }
  end
  SpecTable = {}
  local specs = vim.split(M.selectQuestions():upper(), ' +', { plain = false, trimemtpy = true })
  for index, value in ipairs(specs) do
    if value:match("^[oO][rR]$") then
      SpecTable[index] = {
        question = "OR",
        code = "OR",
        spec = "OR"
      }
    else
      local spec = vim.fn.substitute(value, "(\\+", '', '')
      spec = vim.fn.substitute(spec, ")\\+", '', '')
      local qnum = vim.split(spec, '-', {})
      if Data[qnum[1]] ~= nil then
        SpecTable[index] = {
          question = qnum[1],
          code = qnum[2],
          spec = spec
        }
      elseif Data["Q" .. qnum[1]] ~= nil then
        SpecTable[index] = {
          question = "Q" .. qnum[1],
          code = qnum[2],
          spec = spec
        }
      else
        print("Can't find Q" .. qnum[1] .. " or " .. qnum[1] .. " in the layout file")
      end
    end
  end
end

function M.replaceColumns()
  local fullSpec = M.selectQuestions()
  for i, k in ipairs(SpecTable) do
    if not k['question']:match("^[oO][rR]$") then
      local syntax = ""
      local code = SpecTable[i]['code']
      local spec = SpecTable[i]['spec']
      local scol = Data[SpecTable[i]['question']]['startCol']
      local ecol = Data[SpecTable[i]['question']]['endCol']
      local wfield = Data[SpecTable[i]['question']]['wfield']
      local nfield = Data[SpecTable[i]['question']]['nfield']

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
  local origSpec = M.selectQuestions()
  local line = vim.api.nvim_get_current_line()
  line = vim.fn.substitute(line, origSpec, fullSpec, '')
  vim.api.nvim_set_current_line(line)
end

function M.uncleSyntax()
  -- Set the count to 1 if there is no count given.
  local count = vim.v.count ~= 0 and vim.v.count or 1
  local current_line = vim.api.nvim_win_get_cursor(0)[1]

  for _ = 1, count do
    M.selectQuestions()
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
