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
  local year = 2023     -- TODO: parse directory structure to capture year

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
  if mill_start <= 35 and mill_end >= 44 then mill_agegroup = " OR 1!" .. agrp['startCol'] .. "-3" end
  if mill_start <= 45 and mill_end >= 54 then mill_agegroup = " OR 1!" .. agrp['startCol'] .. "-4" end
  if mill_start <= 55 and mill_end >= 64 then mill_agegroup = " OR 1!" .. agrp['startCol'] .. "-5" end
  table.insert(text, "C &CEMILL=ENIAL;" .. mill_range .. mill_agegroup)

  local genx_start = year - 1980
  local genx_end = year - 1965
  local genx_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], genx_start, genx_end)
  local genx_agegroup = ""
  if genx_start <= 45 and genx_end >= 54 then genx_agegroup = " OR 1!" .. agrp['startCol'] .. "-4" end
  if genx_start <= 55 and genx_end >= 64 then genx_agegroup = " OR 1!" .. agrp['startCol'] .. "-5" end
  table.insert(text, "C &CEGEN X;" .. genx_range .. genx_agegroup)

  local boom_start = year - 1964
  local boom_end = year - 1946
  local boom_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], boom_start, boom_end)
  table.insert(text, "C &CEBABY BOOM- ERS;" .. boom_range)

  local silent_start = year - 1945
  local silent_end = year - 1928
  local silent_range = string.format("R(1!%s:%s,%s:%s)", qage['startCol'], qage['endCol'], silent_start, silent_end)
  table.insert(text, "C &CESILENT GEN;" .. silent_range)

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
  local year = 2023     -- TODO: parse directory structure to capture year

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

end

function M.getColumns()
  local data = {}
  local layDir = vim.split(vim.fn.expand("%:p"), "/", { plain = true })
  table.remove(layDir, #layDir)
  local fullPath = table.concat(layDir, "/") .. "/*.[Ll][Aa][Yy]"
  local layout = vim.fn.readfile(vim.fn.glob(fullPath))
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
