-- Neovim plugin for generating region tables

local M = {}

function M.menu()
  local choices = {
    { label = "1. Nets", func = M.nets },
    { label = "2. No Nets", func = M.noNets },
    { label = "3. 8-pt National", func = M.eightPoinNational },
    { label = "4. 4-pt National", func = M.fourPointNational },
    { label = "5. 8-pt + States", func = M.eightPointStates },
  }
  for _, choice in ipairs(choices) do
    print(choice.label)
  end
  local input = tonumber(vim.fn.input "Select an option: ")
  if input and input >= 1 and input <= #choices then
    choices[input].func()
  else
    print " Invalid selection"
  end
end

function M.nets()
  M.viewColumns()
  local region_col = tonumber(vim.fn.input "Region/DMA name column #: ")
  if region_col == nil then
    return
  end
  local county_col = tonumber(vim.fn.input "State/County name column #: ")
  if county_col == nil then
    return
  end
  local fips_col = tonumber(vim.fn.input "FIPS code column #: ")
  if fips_col == nil then
    return
  end
  local layout_col = vim.fn.input "Data columns - X:Y in R(1!X:Y...: "
  if layout_col == "" then
    layout_col = "X:Y"
  end
  vim.api.nvim_exec2([[g/\(^\t\|^$\)/d]], {})
  local sort_cmd = string.format("2,$!sort -b -t$'\\t' -k%s,%s -k%s,%sn", region_col, region_col, fips_col, fips_col)
  vim.api.nvim_exec2(sort_cmd, {})
  local text = vim.api.nvim_buf_get_lines(0, 1, -1, false)
  local region_data = {}
  local county_data = {}
  local fips_data = {}
  for _, line in ipairs(text) do
    local array = vim.split(line, "\t", { plain = false })
    table.insert(region_data, vim.trim(array[region_col]))
    table.insert(county_data, vim.trim(array[county_col]))
    table.insert(fips_data, vim.trim(array[fips_col]))
  end
  vim.api.nvim_exec2("new", {})
  local regionTable = {
    "*",
    "TABLE ",
    "* QUESTION REG:",
    "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP",
  }
  local main_string = ""
  local substring = ""
  local nTotal = #fips_data
  local region_string = ""
  local county_string = ""
  for i = 1, nTotal do
    local region = region_data[i]
    local county = county_data[i]
    local fips = fips_data[i]
    if i == 1 then
      region_string = string.format("R %s&UT-;R(1!%s,%s", region, layout_col, fips)
    elseif region ~= region_data[i - 1] then
      main_string = main_string .. region_string .. ")\n" .. substring
      substring = ""
      region_string = string.format("R %s&UT-;R(1!%s,%s", region, layout_col, fips)
    elseif i == nTotal and region == region_data[i - 1] then
      county_string = string.format("R   %s;R(1!%s,%s)\n", county, layout_col, fips)
      substring = substring .. county_string
      region_string = region_string .. "," .. fips
      main_string = main_string .. region_string .. ")\n" .. substring
    else
      region_string = region_string .. "," .. fips
    end
    if i == nTotal and region ~= region_data[i - 1] then
      region_string = string.format("R %s&UT-;R(1!%s,%s", region, layout_col, fips)
      county_string = string.format("R   %s;R(1!%s,%s)\n", county, layout_col, fips)
      substring = substring .. county_string
      main_string = main_string .. region_string .. ")\n" .. substring
    end
    county_string = string.format("R   %s;R(1!%s,%s)\n", county, layout_col, fips)
    substring = substring .. county_string
  end
  local region_array = vim.split(main_string:upper():gsub("/", "//"), "\n", { plain = false, trimempty = true })
  for _, v in ipairs(region_array) do
    table.insert(regionTable, v)
  end
  vim.api.nvim_buf_set_lines(0, 0, 0, false, regionTable)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

function M.noNets()
  M.viewColumns()
  local region_col = tonumber(vim.fn.input "Region/DMA name column #: ")
  if region_col == nil then
    return
  end
  local fips_col = tonumber(vim.fn.input "FIPS code column #: ")
  if fips_col == nil then
    return
  end
  local layout_col = vim.fn.input "Data columns - X:Y in R(1!X:Y...: "
  if layout_col == "" then
    layout_col = "X:Y"
  end
  vim.api.nvim_exec2([[g/\(^\t\|^$\)/d]], {})
  local sort_cmd = string.format("2,$!sort -b -t$'\\t' -k%s,%s -k%s,%sn", region_col, region_col, fips_col, fips_col)
  vim.api.nvim_exec2(sort_cmd, {})
  local text = vim.api.nvim_buf_get_lines(0, 1, -1, false)
  local region_data = {}
  local fips_data = {}
  for _, line in ipairs(text) do
    local array = vim.split(line, "\t", { plain = false })
    table.insert(region_data, vim.trim(array[region_col]))
    table.insert(fips_data, vim.trim(array[fips_col]))
  end
  vim.api.nvim_exec2("new", {})
  local regionTable = {
    "*",
    "TABLE ",
    "* QUESTION REG:",
    "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP",
    "R REGION&UT-;NULL",
  }
  local main_string = ""
  local nTotal = #fips_data
  local region_string = ""
  for i = 1, nTotal do
    local region = region_data[i]
    local fips = fips_data[i]
    if i == 1 then
      region_string = string.format("R   %s;R(1!%s,%s", region, layout_col, fips)
    elseif region ~= region_data[i - 1] then
      main_string = main_string .. region_string .. ")\n"
      region_string = string.format("R   %s;R(1!%s,%s", region, layout_col, fips)
    elseif i == nTotal and region == region_data[i - 1] then
      region_string = region_string .. "," .. fips
      main_string = main_string .. region_string .. ")\n"
    else
      region_string = region_string .. "," .. fips
    end
    if i == nTotal and region ~= region_data[i - 1] then
      region_string = string.format("R   %s;R(1!%s,%s", region, layout_col, fips)
      main_string = main_string .. region_string .. ")\n"
    end
  end
  local region_array = vim.split(main_string:upper():gsub("/", "//"), "\n", { plain = false, trimempty = true })
  for _, v in ipairs(region_array) do
    table.insert(regionTable, v)
  end
  vim.api.nvim_buf_set_lines(0, 0, 0, false, regionTable)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

function M.eightPoinNational()
  local layout_col = vim.fn.input "Data columns - X:Y in R(1!X:Y...: "
  if layout_col == "" then
    layout_col = "X:Y"
  end
  local line_num = vim.fn.line "."
  local regionTable = {
    "*",
    "TABLE ",
    "* QUESTION REG:",
    "T Region.",
    "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP",
    "R NORTHEAST&UT-;R(1!" .. layout_col .. ",09,23,25,33,44,50,10,11,24,34,36,42,54)",
    "R   NEW ENGLAND;R(1!" .. layout_col .. ",09,23,25,33,44,50)",
    "R   MID ATLANTIC;R(1!" .. layout_col .. ",10,11,24,34,36,42,54)",
    "R MIDWEST&UT-;R(1!" .. layout_col .. ",17,18,26,27,39,55,19,20,29,31,38,46)",
    "R   GREAT LAKES;R(1!" .. layout_col .. ",17,18,26,27,39,55)",
    "R   FARM BELT;R(1!" .. layout_col .. ",19,20,29,31,38,46)",
    "R SOUTH&UT-;R(1!" .. layout_col .. ",01,05,12,13,22,28,45,21,37,40,47,48,51)",
    "R   DEEP SOUTH;R(1!" .. layout_col .. ",01,05,12,13,22,28,45)",
    "R   OUTER SOUTH;R(1!" .. layout_col .. ",21,37,40,47,48,51)",
    "R WEST&UT-;R(1!" .. layout_col .. ",02,04,08,16,30,32,35,49,56,06,15,41,53)",
    "R   MOUNTAIN;R(1!" .. layout_col .. ",04,08,16,30,32,35,49,56)",
    "R   PACIFIC;R(1!" .. layout_col .. ",02,06,15,41,53)",
  }
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num - 1, false, regionTable)
end

function M.fourPointNational()
  local layout_col = vim.fn.input "Data columns - X:Y in R(1!X:Y...: "
  if layout_col == "" then
    layout_col = "X:Y"
  end
  local line_num = vim.fn.line "."
  local regionTable = {
    "*",
    "TABLE ",
    "* QUESTION REG:",
    "T Region.",
    "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP",
    "R NORTHEAST&UT-;R(1!" .. layout_col .. ",09,23,25,33,44,50,10,11,24,34,36,42,54)",
    "R   CONNECTICUT;R(1!" .. layout_col .. ",09)",
    "R   DELAWARE;R(1!" .. layout_col .. ",10)",
    "R   MAINE;R(1!" .. layout_col .. ",23)",
    "R   MARYLAND;R(1!" .. layout_col .. ",24)",
    "R   MASSACHUSETTS;R(1!" .. layout_col .. ",25)",
    "R   NEW HAMPSHIRE;R(1!" .. layout_col .. ",33)",
    "R   NEW JERSEY;R(1!" .. layout_col .. ",34)",
    "R   NEW YORK;R(1!" .. layout_col .. ",36)",
    "R   PENNSYLVANIA;R(1!" .. layout_col .. ",42)",
    "R   RHODE ISLAND;R(1!" .. layout_col .. ",44)",
    "R   VERMONT;R(1!" .. layout_col .. ",50)",
    "R   WASHINGTON D.C.;R(1!" .. layout_col .. ",11)",
    "R   WEST VIRGINIA;R(1!" .. layout_col .. ",54)",
    "R MIDWEST&UT-;R(1!" .. layout_col .. ",17,18,26,27,39,55,19,20,29,31,38,46)",
    "R   ILLINOIS;R(1!" .. layout_col .. ",17)",
    "R   INDIANA;R(1!" .. layout_col .. ",18)",
    "R   IOWA;R(1!" .. layout_col .. ",19)",
    "R   KANSAS;R(1!" .. layout_col .. ",20)",
    "R   MICHIGAN;R(1!" .. layout_col .. ",26)",
    "R   MINNESOTA;R(1!" .. layout_col .. ",27)",
    "R   MISSOURI;R(1!" .. layout_col .. ",29)",
    "R   NEBRASKA;R(1!" .. layout_col .. ",31)",
    "R   NORTH DAKOTA;R(1!" .. layout_col .. ",38)",
    "R   OHIO;R(1!" .. layout_col .. ",39)",
    "R   SOUTH DAKOTA;R(1!" .. layout_col .. ",46)",
    "R   WISCONSIN;R(1!" .. layout_col .. ",55)",
    "R SOUTH&UT-;R(1!" .. layout_col .. ",01,05,12,13,22,28,45,21,37,40,47,48,51)",
    "R   ALABAMA;R(1!" .. layout_col .. ",01)",
    "R   ARKANSAS;R(1!" .. layout_col .. ",05)",
    "R   FLORIDA;R(1!" .. layout_col .. ",12)",
    "R   GEORGIA;R(1!" .. layout_col .. ",13)",
    "R   KENTUCKY;R(1!" .. layout_col .. ",21)",
    "R   LOUISIANA;R(1!" .. layout_col .. ",22)",
    "R   MISSISSIPPI;R(1!" .. layout_col .. ",28)",
    "R   NORTH CAROLINA;R(1!" .. layout_col .. ",37)",
    "R   OKLAHOMA;R(1!" .. layout_col .. ",40)",
    "R   SOUTH CAROLINA;R(1!" .. layout_col .. ",45)",
    "R   TENNESSEE;R(1!" .. layout_col .. ",47)",
    "R   TEXAS;R(1!" .. layout_col .. ",48)",
    "R   VIRGINIA;R(1!" .. layout_col .. ",51)",
    "R WEST&UT-;R(1!" .. layout_col .. ",02,04,08,16,30,32,35,49,56,06,15,41,53)",
    "R   ALASKA;R(1!" .. layout_col .. ",02)",
    "R   ARIZONA;R(1!" .. layout_col .. ",04)",
    "R   CALIFORNIA;R(1!" .. layout_col .. ",06)",
    "R   COLORADO;R(1!" .. layout_col .. ",08)",
    "R   HAWAII;R(1!" .. layout_col .. ",15)",
    "R   IDAHO;R(1!" .. layout_col .. ",16)",
    "R   MONTANA;R(1!" .. layout_col .. ",30)",
    "R   NEVADA;R(1!" .. layout_col .. ",32)",
    "R   NEW MEXICO;R(1!" .. layout_col .. ",35)",
    "R   OREGON;R(1!" .. layout_col .. ",41)",
    "R   UTAH;R(1!" .. layout_col .. ",49)",
    "R   WASHINGTON;R(1!" .. layout_col .. ",53)",
    "R   WYOMING;R(1!" .. layout_col .. ",56)",
  }
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num - 1, false, regionTable)
end

function M.eightPointStates()
  local layout_col = vim.fn.input "Data columns - X:Y in R(1!X:Y...: "
  if layout_col == "" then
    layout_col = "X:Y"
  end
  local line_num = vim.fn.line "."
  local regionTable = {
    "*",
    "TABLE 205",
    "* QUESTION REG:",
    "T Region.",
    "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP",
    "R NORTHEAST&UT-;R(1!" .. layout_col .. ",09,23,25,33,44,50,10,11,24,34,36,42,54)",
    "R   NEW ENGLAND&UT-;R(1!" .. layout_col .. ",9,23,25,33,44,50)",
    "R     CONNECTICUT;R(1!" .. layout_col .. ",09)",
    "R     MAINE;R(1!" .. layout_col .. ",23)",
    "R     MASSACHUSETTS;R(1!" .. layout_col .. ",25)",
    "R     NEW HAMPSHIRE;R(1!" .. layout_col .. ",33)",
    "R     RHODE ISLAND;R(1!" .. layout_col .. ",44)",
    "R     VERMONT;R(1!" .. layout_col .. ",50)",
    "R   MID ATLANTIC&UT-;R(1!" .. layout_col .. ",10,11,24,34,36,42,54)",
    "R     DELAWARE;R(1!" .. layout_col .. ",10)",
    "R     MARYLAND;R(1!" .. layout_col .. ",24)",
    "R     NEW JERSEY;R(1!" .. layout_col .. ",34)",
    "R     NEW YORK;R(1!" .. layout_col .. ",36)",
    "R     PENNSYLVANIA;R(1!" .. layout_col .. ",42)",
    "R     WASHINGTON D.C.;R(1!" .. layout_col .. ",11)",
    "R     WEST VIRGINIA;R(1!" .. layout_col .. ",54)",
    "R MIDWEST&UT-;R(1!" .. layout_col .. ",17,18,26,27,39,55,19,20,29,31,38,46)",
    "R   GREAT LAKES&UT-;R(1!" .. layout_col .. ",17,18,26,27,39,55)",
    "R     ILLINOIS;R(1!" .. layout_col .. ",17)",
    "R     INDIANA;R(1!" .. layout_col .. ",18)",
    "R     MICHIGAN;R(1!" .. layout_col .. ",26)",
    "R     MINNESOTA;R(1!" .. layout_col .. ",27)",
    "R     OHIO;R(1!" .. layout_col .. ",39)",
    "R     WISCONSIN;R(1!" .. layout_col .. ",55)",
    "R   FARM BELT&UT-;R(1!" .. layout_col .. ",19,20,29,31,38,46)",
    "R     IOWA;R(1!" .. layout_col .. ",19)",
    "R     KANSAS;R(1!" .. layout_col .. ",20)",
    "R     MISSOURI;R(1!" .. layout_col .. ",29)",
    "R     NEBRASKA;R(1!" .. layout_col .. ",31)",
    "R     NORTH DAKOTA;R(1!" .. layout_col .. ",38)",
    "R     SOUTH DAKOTA;R(1!" .. layout_col .. ",46)",
    "R SOUTH&UT-;R(1!" .. layout_col .. ",01,05,12,13,22,28,45,21,37,40,47,48,51)",
    "R   DEEP SOUTH&UT-;R(1!" .. layout_col .. ",1,5,12,13,22,28,45)",
    "R     ALABAMA;R(1!" .. layout_col .. ",01)",
    "R     ARKANSAS;R(1!" .. layout_col .. ",05)",
    "R     FLORIDA;R(1!" .. layout_col .. ",12)",
    "R     GEORGIA;R(1!" .. layout_col .. ",13)",
    "R     LOUISIANA;R(1!" .. layout_col .. ",22)",
    "R     MISSISSIPPI;R(1!" .. layout_col .. ",28)",
    "R     SOUTH CAROLINA;R(1!" .. layout_col .. ",45)",
    "R   OUTER SOUTH&UT-;R(1!" .. layout_col .. ",21,37,40,47,48,51)",
    "R     KENTUCKY;R(1!" .. layout_col .. ",21)",
    "R     NORTH CAROLINA;R(1!" .. layout_col .. ",37)",
    "R     OKLAHOMA;R(1!" .. layout_col .. ",40)",
    "R     TENNESSEE;R(1!" .. layout_col .. ",47)",
    "R     TEXAS;R(1!" .. layout_col .. ",48)",
    "R     VIRGINIA;R(1!" .. layout_col .. ",51)",
    "R WEST&UT-;R(1!" .. layout_col .. ",02,04,08,16,30,32,35,49,56,06,15,41,53)",
    "R   MOUNTAIN&UT-;R(1!" .. layout_col .. ",4,8,16,30,32,35,49,56)",
    "R     ARIZONA;R(1!" .. layout_col .. ",04)",
    "R     COLORADO;R(1!" .. layout_col .. ",08)",
    "R     IDAHO;R(1!" .. layout_col .. ",16)",
    "R     MONTANA;R(1!" .. layout_col .. ",30)",
    "R     NEVADA;R(1!" .. layout_col .. ",32)",
    "R     NEW MEXICO;R(1!" .. layout_col .. ",35)",
    "R     UTAH;R(1!" .. layout_col .. ",49)",
    "R     WYOMING;R(1!" .. layout_col .. ",56)",
    "R   PACIFIC&UT-;R(1!" .. layout_col .. ",2,6,15,41,53)",
    "R     ALASKA;R(1!" .. layout_col .. ",02)",
    "R     CALIFORNIA;R(1!" .. layout_col .. ",06)",
    "R     HAWAII;R(1!" .. layout_col .. ",15)",
    "R     OREGON;R(1!" .. layout_col .. ",41)",
    "R     WASHINGTON;R(1!" .. layout_col .. ",53)",
  }
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num - 1, false, regionTable)
end

function M.viewColumns()
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  print { " ", " " }
  local header = vim.split(vim.api.nvim_get_current_line(), "\t", { plain = false })
  for i, h in ipairs(header) do
    print(i, h)
  end
  print " "
end

vim.api.nvim_create_user_command("Region", M.menu, {})

return M
