-- Neovim plugin for adding generation points

--[[Generation breaks
 - Gen Z         1997-2012
 - Millennial    1981-1996
 - Gen X         1965-1980
 - Baby Boomers  1946-1964
 - Silent Gen    1928-1945
 - GI Gen        1901-1927
--]]
local M = {}

function M.menu()
  local choices = {
    { label = "1. POS (QAGE & AGEGROUP)", func = M.standard },
    { label = "2. NBC (AGE & Q2A)",       func = M.nbc },
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

function M.standard()
  local text = {}
  local qage = M.getColumns()['QAGE']
  local agrp = M.getColumns()['AGEGROUP']
  local year = vim.fn.expand("%:p"):gsub(".*kdata/(%d+).*", "%1")
  local labels = { "GEN Z", "MILLENIAL", "GEN X", "BABY BOOMERS", "SILENT GEN", "GI GEN" }
  local start_years = { 1997, 1981, 1965, 1946, 1928, 1901 }
  local end_years = { 2012, 1996, 1980, 1964, 1945, 1927 }

  for i = 1, #labels do
    local start_age = year - end_years[i]
    local end_age = year - start_years[i]
    local range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], start_age, end_age)
    local agegroup = string.format(" OR 1!%s", agrp['startCol'])
    local grp = ""

    if start_age <= 18 and end_age >= 24 then grp = "-1" end

    for j = 25, 55, 10 do
      if start_age <= j and end_age >= (j + 9) then grp = string.format("-%d", (j - 5) / 10) end
    end

    if #grp > 0 then agegroup = agegroup .. grp else agegroup = "" end
    table.insert(text, "C &CE" .. labels[i] .. ";" .. range .. agegroup)
  end

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline - 1, false, text)
  vim.api.nvim_win_set_cursor(0, { nline, 0 })
end

function M.nbc()
  local text = {}
  local qage = M.getColumns()['AGE']
  local agrp = M.getColumns()['Q2A']
  local year = vim.fn.expand("%:p"):gsub(".*kdata/(%d+).*", "%1")
  local labels = { "GEN Z", "MILLENIAL", "GEN X", "BABY BOOMERS", "SILENT GEN", "GI GEN" }
  local start_years = { 1997, 1981, 1965, 1946, 1928, 1901 }
  local end_years = { 2012, 1996, 1980, 1964, 1945, 1927 }

  for i = 1, #labels do
    local start_age = year - end_years[i]
    local end_age = year - start_years[i]
    local range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], start_age, end_age)
    local agegroup = string.format(" OR R(1!%s:%s", agrp['startCol'], agrp['endCol'])
    local grp = ""

    if start_age <= 18 and end_age >= 24 then grp = ",01" end

    for j = 25, 70, 5 do
      if start_age <= j and end_age >= (j + 4) then grp = grp .. string.format(",%02d", (j - 15) / 5) end
    end

    if #grp > 0 then agegroup = agegroup .. grp .. ")" else agegroup = "" end
    table.insert(text, "C &CE" .. labels[i] .. ";" .. range .. agegroup)
  end

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline - 1, false, text)
  vim.api.nvim_win_set_cursor(0, { nline, 0 })
end

function M.getColumns()
  local data = {}
  local layDir = vim.split(vim.fn.expand("%:p"), "/", { plain = true })
  table.remove(layDir, #layDir)
  local fullPath = table.concat(layDir, "/") .. "/*.[Ll][Aa][Yy]"
  local temp = vim.fn.glob(fullPath, false, true)
  local layout = vim.fn.readfile(temp[#temp])
  for _, value in ipairs(layout) do
    local column = vim.split(value, ' +', { plain = false, trimempty = true })
    if column[1] == "QAGE" or column[1] == "AGEGROUP" or column[1] == "AGE" or column[1] == "Q2A" then
      data[column[1]] = {
        startCol = tonumber(column[2]),
        endCol = tonumber(column[3]),
      }
    end
  end
  return (data)
end

vim.api.nvim_create_user_command("Generation", M.menu, {})

return M
