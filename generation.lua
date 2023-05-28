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

  local genz_start = 18 --Will need to be updated when applicable (~2030)
  local genz_end = year - 1997
  local genz_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], genz_start, genz_end)
  local genz_agegroup = ""
  if genz_start <= 18 and genz_end >= 24 then genz_agegroup = " OR 1!" .. agrp['startCol'] .. "-1" end
  if genz_start <= 25 and genz_end >= 34 then genz_agegroup = " OR 1!" .. agrp['startCol'] .. "-2" end
  if genz_start <= 35 and genz_end >= 44 then genz_agegroup = " OR 1!" .. agrp['startCol'] .. "-3" end
  if genz_start <= 45 and genz_end >= 54 then genz_agegroup = " OR 1!" .. agrp['startCol'] .. "-4" end
  if genz_start <= 55 and genz_end >= 64 then genz_agegroup = " OR 1!" .. agrp['startCol'] .. "-5" end
  table.insert(text, "C &CEGEN Z;" .. genz_range .. genz_agegroup)

  local mill_start = year - 1996
  local mill_end = year - 1981
  local mill_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], mill_start, mill_end)
  local mill_agegroup = ""
  if mill_start <= 18 and mill_end >= 24 then mill_agegroup = " OR 1!" .. agrp['startCol'] .. "-1" end
  if mill_start <= 25 and mill_end >= 34 then mill_agegroup = " OR 1!" .. agrp['startCol'] .. "-2" end
  if mill_start <= 35 and mill_end >= 44 then mill_agegroup = " OR 1!" .. agrp['startCol'] .. "-3" end
  if mill_start <= 45 and mill_end >= 54 then mill_agegroup = " OR 1!" .. agrp['startCol'] .. "-4" end
  if mill_start <= 55 and mill_end >= 64 then mill_agegroup = " OR 1!" .. agrp['startCol'] .. "-5" end
  table.insert(text, "C &CEMILL=ENIAL;" .. mill_range .. mill_agegroup)

  local genx_start = year - 1980
  local genx_end = year - 1965
  local genx_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], genx_start, genx_end)
  local genx_agegroup = ""
  if genx_start <= 18 and genx_end >= 24 then genx_agegroup = " OR 1!" .. agrp['startCol'] .. "-1" end
  if genx_start <= 25 and genx_end >= 34 then genx_agegroup = " OR 1!" .. agrp['startCol'] .. "-2" end
  if genx_start <= 35 and genx_end >= 44 then genx_agegroup = " OR 1!" .. agrp['startCol'] .. "-3" end
  if genx_start <= 45 and genx_end >= 54 then genx_agegroup = " OR 1!" .. agrp['startCol'] .. "-4" end
  if genx_start <= 55 and genx_end >= 64 then genx_agegroup = " OR 1!" .. agrp['startCol'] .. "-5" end
  table.insert(text, "C &CEGEN X;" .. genx_range .. genx_agegroup)

  local boom_start = year - 1964
  local boom_end = year - 1946
  local boom_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], boom_start, boom_end)
  local boom_agegroup = ""
  if boom_start <= 18 and boom_end >= 24 then boom_agegroup = " OR 1!" .. agrp['startCol'] .. "-1" end
  if boom_start <= 25 and boom_end >= 34 then boom_agegroup = " OR 1!" .. agrp['startCol'] .. "-2" end
  if boom_start <= 35 and boom_end >= 44 then boom_agegroup = " OR 1!" .. agrp['startCol'] .. "-3" end
  if boom_start <= 45 and boom_end >= 54 then boom_agegroup = " OR 1!" .. agrp['startCol'] .. "-4" end
  if boom_start <= 55 and boom_end >= 64 then boom_agegroup = " OR 1!" .. agrp['startCol'] .. "-5" end
  table.insert(text, "C &CEBABY BOOM- ERS;" .. boom_range .. boom_agegroup)

  local silent_start = year - 1945
  local silent_end = year - 1928
  local silent_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], silent_start, silent_end)
  local silent_agegroup = ""
  if silent_start <= 18 and silent_end >= 24 then silent_agegroup = " OR 1!" .. agrp['startCol'] .. "-1" end
  if silent_start <= 25 and silent_end >= 34 then silent_agegroup = " OR 1!" .. agrp['startCol'] .. "-2" end
  if silent_start <= 35 and silent_end >= 44 then silent_agegroup = " OR 1!" .. agrp['startCol'] .. "-3" end
  if silent_start <= 45 and silent_end >= 54 then silent_agegroup = " OR 1!" .. agrp['startCol'] .. "-4" end
  if silent_start <= 55 and silent_end >= 64 then silent_agegroup = " OR 1!" .. agrp['startCol'] .. "-5" end
  table.insert(text, "C &CESILENT GEN;" .. silent_range .. silent_agegroup)

  local gi_start = year - 1927
  local gi_end = year - 1901
  local gi_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], gi_start, gi_end)
  table.insert(text, "C &CEGI GEN;" .. gi_range)

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline - 1, false, text)
  vim.api.nvim_win_set_cursor(0, { nline, 0 })
end

function M.nbc()
  local text = {}
  local qage = M.getColumns()['AGE']
  local agrp = M.getColumns()['Q2A']
  local year = vim.fn.expand("%:p"):gsub(".*kdata/(%d+).*", "%1")

  local genz_start = 18 --Will need to be updated when applicable (~2030)
  local genz_end = year - 1997
  local genz_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], genz_start, genz_end)
  local genz_agegroup = string.format(" OR R(1!%s:%s", agrp['startCol'], agrp['endCol'])
  local genz_grp = ""
  if genz_start <= 18 and genz_end >= 24 then genz_grp = genz_grp .. ",01" end
  if genz_start <= 25 and genz_end >= 29 then genz_grp = genz_grp .. ",02" end
  if genz_start <= 30 and genz_end >= 34 then genz_grp = genz_grp .. ",03" end
  if genz_start <= 35 and genz_end >= 39 then genz_grp = genz_grp .. ",04" end
  if genz_start <= 40 and genz_end >= 44 then genz_grp = genz_grp .. ",05" end
  if genz_start <= 45 and genz_end >= 49 then genz_grp = genz_grp .. ",06" end
  if genz_start <= 50 and genz_end >= 54 then genz_grp = genz_grp .. ",07" end
  if genz_start <= 55 and genz_end >= 59 then genz_grp = genz_grp .. ",08" end
  if genz_start <= 60 and genz_end >= 64 then genz_grp = genz_grp .. ",09" end
  if genz_start <= 65 and genz_end >= 69 then genz_grp = genz_grp .. ",10" end
  if genz_start <= 70 and genz_end >= 74 then genz_grp = genz_grp .. ",11" end
  if genz_start <= 75 and genz_end >= 99 then genz_grp = genz_grp .. ",12" end
  if #genz_grp > 0 then genz_agegroup = genz_agegroup .. genz_grp .. ")" else genz_agegroup = "" end
  table.insert(text, "C &CEGEN Z;" .. genz_range .. genz_agegroup)

  local mill_start = year - 1996
  local mill_end = year - 1981
  local mill_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], mill_start, mill_end)
  local mill_agegroup = string.format(" OR R(1!%s:%s", agrp['startCol'], agrp['endCol'])
  local mill_grp = ""
  if mill_start <= 18 and mill_end >= 24 then mill_grp = mill_grp .. ",01" end
  if mill_start <= 25 and mill_end >= 29 then mill_grp = mill_grp .. ",02" end
  if mill_start <= 30 and mill_end >= 34 then mill_grp = mill_grp .. ",03" end
  if mill_start <= 35 and mill_end >= 39 then mill_grp = mill_grp .. ",04" end
  if mill_start <= 40 and mill_end >= 44 then mill_grp = mill_grp .. ",05" end
  if mill_start <= 45 and mill_end >= 49 then mill_grp = mill_grp .. ",06" end
  if mill_start <= 50 and mill_end >= 54 then mill_grp = mill_grp .. ",07" end
  if mill_start <= 55 and mill_end >= 59 then mill_grp = mill_grp .. ",08" end
  if mill_start <= 60 and mill_end >= 64 then mill_grp = mill_grp .. ",09" end
  if mill_start <= 65 and mill_end >= 69 then mill_grp = mill_grp .. ",10" end
  if mill_start <= 70 and mill_end >= 74 then mill_grp = mill_grp .. ",11" end
  if mill_start <= 75 and mill_end >= 99 then mill_grp = mill_grp .. ",12" end
  if #mill_grp > 0 then mill_agegroup = mill_agegroup .. mill_grp .. ")" else mill_agegroup = "" end
  table.insert(text, "C &CEMILL=ENIAL;" .. mill_range .. mill_agegroup)

  local genx_start = year - 1980
  local genx_end = year - 1965
  local genx_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], genx_start, genx_end)
  local genx_agegroup = string.format(" OR R(1!%s:%s", agrp['startCol'], agrp['endCol'])
  local genx_grp = ""
  if genx_start <= 18 and genx_end >= 24 then genx_grp = genx_grp .. ",01" end
  if genx_start <= 25 and genx_end >= 29 then genx_grp = genx_grp .. ",02" end
  if genx_start <= 30 and genx_end >= 34 then genx_grp = genx_grp .. ",03" end
  if genx_start <= 35 and genx_end >= 39 then genx_grp = genx_grp .. ",04" end
  if genx_start <= 40 and genx_end >= 44 then genx_grp = genx_grp .. ",05" end
  if genx_start <= 45 and genx_end >= 49 then genx_grp = genx_grp .. ",06" end
  if genx_start <= 50 and genx_end >= 54 then genx_grp = genx_grp .. ",07" end
  if genx_start <= 55 and genx_end >= 59 then genx_grp = genx_grp .. ",08" end
  if genx_start <= 60 and genx_end >= 64 then genx_grp = genx_grp .. ",09" end
  if genx_start <= 65 and genx_end >= 69 then genx_grp = genx_grp .. ",10" end
  if genx_start <= 70 and genx_end >= 74 then genx_grp = genx_grp .. ",11" end
  if genx_start <= 75 and genx_end >= 99 then genx_grp = genx_grp .. ",12" end
  if #genx_grp > 0 then genx_agegroup = genx_agegroup .. genx_grp .. ")" else genx_agegroup = "" end
  table.insert(text, "C &CEGEN X;" .. genx_range .. genx_agegroup)

  local boom_start = year - 1964
  local boom_end = year - 1946
  local boom_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], boom_start, boom_end)
  local boom_agegroup = string.format(" OR R(1!%s:%s", agrp['startCol'], agrp['endCol'])
  local boom_grp = ""
  if boom_start <= 18 and boom_end >= 24 then boom_grp = boom_grp .. ",01" end
  if boom_start <= 25 and boom_end >= 29 then boom_grp = boom_grp .. ",02" end
  if boom_start <= 30 and boom_end >= 34 then boom_grp = boom_grp .. ",03" end
  if boom_start <= 35 and boom_end >= 39 then boom_grp = boom_grp .. ",04" end
  if boom_start <= 40 and boom_end >= 44 then boom_grp = boom_grp .. ",05" end
  if boom_start <= 45 and boom_end >= 49 then boom_grp = boom_grp .. ",06" end
  if boom_start <= 50 and boom_end >= 54 then boom_grp = boom_grp .. ",07" end
  if boom_start <= 55 and boom_end >= 59 then boom_grp = boom_grp .. ",08" end
  if boom_start <= 60 and boom_end >= 64 then boom_grp = boom_grp .. ",09" end
  if boom_start <= 65 and boom_end >= 69 then boom_grp = boom_grp .. ",10" end
  if boom_start <= 70 and boom_end >= 74 then boom_grp = boom_grp .. ",11" end
  if boom_start <= 75 and boom_end >= 99 then boom_grp = boom_grp .. ",12" end
  if #boom_grp > 0 then boom_agegroup = boom_agegroup .. boom_grp .. ")" else boom_agegroup = "" end
  table.insert(text, "C &CEBABY BOOM- ERS;" .. boom_range .. boom_agegroup)


  local silent_start = year - 1945
  local silent_end = year - 1928
  local silent_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], silent_start, silent_end)
  local silent_agegroup = string.format(" OR R(1!%s:%s", agrp['startCol'], agrp['endCol'])
  local silent_grp = ""
  if silent_start <= 18 and silent_end >= 24 then silent_grp = silent_grp .. ",01" end
  if silent_start <= 25 and silent_end >= 29 then silent_grp = silent_grp .. ",02" end
  if silent_start <= 30 and silent_end >= 34 then silent_grp = silent_grp .. ",03" end
  if silent_start <= 35 and silent_end >= 39 then silent_grp = silent_grp .. ",04" end
  if silent_start <= 40 and silent_end >= 44 then silent_grp = silent_grp .. ",05" end
  if silent_start <= 45 and silent_end >= 49 then silent_grp = silent_grp .. ",06" end
  if silent_start <= 50 and silent_end >= 54 then silent_grp = silent_grp .. ",07" end
  if silent_start <= 55 and silent_end >= 59 then silent_grp = silent_grp .. ",08" end
  if silent_start <= 60 and silent_end >= 64 then silent_grp = silent_grp .. ",09" end
  if silent_start <= 65 and silent_end >= 69 then silent_grp = silent_grp .. ",10" end
  if silent_start <= 70 and silent_end >= 74 then silent_grp = silent_grp .. ",11" end
  if silent_start <= 75 and silent_end >= 99 then silent_grp = silent_grp .. ",12" end
  if #silent_grp > 0 then silent_agegroup = silent_agegroup .. silent_grp .. ")" else silent_agegroup = "" end
  table.insert(text, "C &CESILENT GEN;" .. silent_range .. silent_agegroup)

  local gi_start = year - 1927
  local gi_end = year - 1901
  local gi_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], gi_start, gi_end)
  local gi_agegroup = string.format(" OR R(1!%s:%s", agrp['startCol'], agrp['endCol'])
  local gi_grp = ""
  if gi_start <= 18 and gi_end >= 24 then gi_grp = gi_grp .. ",01" end
  if gi_start <= 25 and gi_end >= 29 then gi_grp = gi_grp .. ",02" end
  if gi_start <= 30 and gi_end >= 34 then gi_grp = gi_grp .. ",03" end
  if gi_start <= 35 and gi_end >= 39 then gi_grp = gi_grp .. ",04" end
  if gi_start <= 40 and gi_end >= 44 then gi_grp = gi_grp .. ",05" end
  if gi_start <= 45 and gi_end >= 49 then gi_grp = gi_grp .. ",06" end
  if gi_start <= 50 and gi_end >= 54 then gi_grp = gi_grp .. ",07" end
  if gi_start <= 55 and gi_end >= 59 then gi_grp = gi_grp .. ",08" end
  if gi_start <= 60 and gi_end >= 64 then gi_grp = gi_grp .. ",09" end
  if gi_start <= 65 and gi_end >= 69 then gi_grp = gi_grp .. ",10" end
  if gi_start <= 70 and gi_end >= 74 then gi_grp = gi_grp .. ",11" end
  if gi_start <= 75 and gi_end >= 99 then gi_grp = gi_grp .. ",12" end
  if #gi_grp > 0 then gi_agegroup = gi_agegroup .. gi_grp .. ")" else gi_agegroup = "" end
  table.insert(text, "C &CEGI GEN;" .. gi_range .. gi_agegroup)

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
