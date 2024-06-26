-- Neovim plugin for adding and removing banner columns

local M = {}

function M.menu()
  local choices = {
    { label = "1. Insert point", func = M.insert_column },
    { label = "2. Insert group", func = M.insert_group },
    { label = "3. Delete point", func = M.delete_column },
    { label = "4. Delete group", func = M.delete_group },
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

function M.insert_column()
  local curr_line = M.viewGroups()
  local group = tonumber(vim.fn.input "\nWhich group do you want to add to: ")
  if group == nil then
    vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
    return
  end
  local wholeText, start_line, end_line = unpack(M.copyTable())
  local first_col = nil
  local point = ""
  for _, line in ipairs(wholeText) do
    if line:match "^(T .*)&CC%d+:%d+==" then
      local group_array = vim.split(line, "==", { plain = true })
      if group < 0 or group > #group_array - 1 then
        print(" Invalid group. Only " .. #group_array - 1 .. " groups total in banner.")
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      end
      local group_pat = "(.-)(%d+):(%d+)"
      first_col = group_array[group]:gsub(group_pat, "%2")
      local new_end = group_array[group]:gsub(group_pat, "%3") + 1
      M.viewPoints(tonumber(first_col), tonumber(new_end) - 1)
      ::resubmit::
      point = vim.fn.input(string.format("\nGroup %d will go from %d to %d. Where to: ", group, first_col, new_end))
      if point == "" then
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      elseif tonumber(point) < tonumber(first_col) or tonumber(point) > tonumber(new_end) then
        -- print " "
        print "\nInvalid column."
        goto resubmit
      end
      break
    end
  end

  local shift = 1
  local fc_chk = tonumber(first_col)
  local new_text = M.adjustTitles(shift, fc_chk)
  local col = 0
  local cursor_point = 0
  for index, row in ipairs(new_text) do
    if row:match "^C &CE" or row:match "^F &CP" then
      col = col + 1
      if col == tonumber(point) then
        cursor_point = index
        table.insert(new_text, index, "C &CE")
      end
    end
  end
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line - 1, false, new_text)
  vim.api.nvim_win_set_cursor(0, { start_line + cursor_point - 1, 5 })
end

function M.insert_group()
  local curr_line = M.viewGroups()
  local group = tonumber(vim.fn.input "\nAdd after which group? (Enter 0 to add first group): ")
  if group == nil then
    vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
    return
  end
  local wholeText, start_line, end_line = unpack(M.copyTable())
  local first_col = nil
  local end_col = nil
  local ul_chk = 1
  local last_group = nil
  for i, line in ipairs(wholeText) do
    if line:match "^(T .*)&CC%d+:%d+==" then
      ul_chk = i - 1
      local group_array = vim.split(line, "==", { plain = true })
      if group < 0 or group > #group_array - 1 then
        print(" Invalid group. Only " .. #group_array - 1 .. " groups total in banner.")
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      end
      last_group = #group_array - 1
      local group_pat = "(.-)(%d+):(%d+)"
      if group == 0 then
        first_col = 1
        end_col = 1
        break
      end
      first_col = group_array[group]:gsub(group_pat, "%2")
      end_col = group_array[group]:gsub(group_pat, "%3")
      break
    end
  end
  local shift = tonumber(vim.fn.input "\nHow many points: ")
  if shift == nil then
    vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
    return
  end
  local fc_chk = tonumber(first_col)
  local nc_start = end_col + 1
  local nc_end = end_col + shift
  local title = vim.fn.input "\nWhat is the title?\n"
  title = title:upper()
  local new_text = M.adjustGroups(group, shift, ul_chk, fc_chk, nc_start, nc_end, title, last_group)

  local col = 0
  local cursor_point = 0
  for index, row in ipairs(new_text) do
    if row:match "^T $" then
      table.remove(new_text, index)
    end
    if row:match "^C &CE" or row:match "^F &CP" then
      col = col + 1
      if col == nc_start then
        cursor_point = index
        for _ = 1, shift do
          table.insert(new_text, index, "C &CE")
        end
      end
    end
  end
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line - 1, false, new_text)
  vim.api.nvim_win_set_cursor(0, { start_line + cursor_point - 1, 5 })
end

function M.delete_column()
  local curr_line = M.viewGroups()
  local group = tonumber(vim.fn.input "\nWhich group do you want to delete from: ")
  if group == nil then
    vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
    return
  end
  local wholeText, start_line, end_line = unpack(M.copyTable())
  local point = ""
  local first_col = nil
  for _, line in ipairs(wholeText) do
    if line:match "^(T .*)&CC%d+:%d+==" then
      local group_array = vim.split(line, "==", { plain = true })
      if group < 0 or group > #group_array - 1 then
        print(" Invalid group. Only " .. #group_array - 1 .. " groups total in banner.")
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      end
      local group_pat = "(.-)(%d+):(%d+)"
      first_col = group_array[group]:gsub(group_pat, "%2")
      local end_col = group_array[group]:gsub(group_pat, "%3")
      M.viewPoints(tonumber(first_col), tonumber(end_col))
      ::resubmit::
      point = vim.fn.input(string.format("\nGroup %d goes from %d to %d: ", group, first_col, end_col))
      if point == "" then
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      elseif tonumber(point) < tonumber(first_col) or tonumber(point) > tonumber(end_col) then
        print "\nInvalid column."
        goto resubmit
      end
      break
    end
  end

  local shift = -1
  local fc_chk = tonumber(first_col)
  local new_text = M.adjustTitles(shift, fc_chk)
  local col = 0
  local cursor_point = 0
  for index, row in ipairs(new_text) do
    if row:match "^C &CE" then
      col = col + 1
      if col == tonumber(point) then
        cursor_point = index
        table.remove(new_text, index)
      end
    end
  end
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line - 1, false, new_text)
  vim.api.nvim_win_set_cursor(0, { start_line + cursor_point - 1, 0 })
end

function M.delete_group()
  local curr_line = M.viewGroups()
  local group = tonumber(vim.fn.input "\nWhich group do you want to delete: ")
  if group == nil then
    vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
    return
  end
  local wholeText, start_line, end_line = unpack(M.copyTable())
  local first_col = nil
  local end_col = nil
  for _, line in ipairs(wholeText) do
    if line:match "^(T .*)&CC%d+:%d+==" then
      local group_array = vim.split(line, "==", { plain = true })
      if group < 0 or group > #group_array - 1 then
        print(" Invalid group. Only " .. #group_array - 1 .. " groups total in banner.")
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      end
      local group_pat = "(.-)(%d+):(%d+)"
      if group == 0 then
        first_col = 1
        end_col = 1
        break
      end
      first_col = group_array[group]:gsub(group_pat, "%2")
      end_col = group_array[group]:gsub(group_pat, "%3")
      break
    end
  end
  local fc_chk = tonumber(first_col)
  local oc_start = fc_chk
  local oc_end = tonumber(end_col)
  local shift = -(oc_end - oc_start + 1)
  local new_text = M.removeGroups(shift, fc_chk)
  local col = 0
  local cursor_point = 0
  for index, row in ipairs(new_text) do
    if row:match "^T $" then
      table.remove(new_text, index)
    end
    if row:match "^C &CE" then
      col = col + 1
      if col == oc_start then
        cursor_point = index
        for _ = 1, -shift do
          table.remove(new_text, index)
        end
      end
    end
  end
  vim.api.nvim_buf_set_lines(0, start_line - 1, end_line - 1, false, new_text)
  vim.api.nvim_win_set_cursor(0, { start_line + cursor_point - 1, 0 })
end

function M.copyTable()
  local start_line = vim.fn.getcurpos()[2] + 1
  local end_line = vim.fn.search("^\\*\\n\\|F \\&CP", "W")
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  vim.fn.search("\\_^TABLE ", "b")
  return { wholeText, start_line, end_line }
end

function M.viewGroups()
  local curr_line = vim.fn.line "."
  vim.fn.search("\\_^TABLE ", "b")
  local text = M.copyTable()[1]
  local titles = {}
  for i = 1, 50 do
    titles[i] = ""
  end
  for _, line in ipairs(text) do
    if line:match "^(T .*)&CC(%d+):(%d+)" then
      local segments = {}
      for segment in string.gmatch(line, "([^&]+)") do
        table.insert(segments, segment)
      end
      for i = 2, #segments do
        local parts = {}
        for part in string.gmatch(segments[i], "([^%s]+)") do
          table.insert(parts, part)
        end
        local range = parts[1]
        local label = table.concat(parts, " ", 2)

        if range:find ":" then
          local _, end_idx = range:match "CC(%d+):(%d+)"
          local end_idx_num = tonumber(end_idx)
          if end_idx_num ~= nil and titles[end_idx_num] then
            titles[end_idx_num] = titles[end_idx_num] .. " " .. label
          elseif end_idx_num ~= nil then
            titles[end_idx_num] = label
          end
        end
      end
    end
  end
  local index = 1
  print " "
  print " "
  for _, group in ipairs(titles) do
    if group ~= "" then
      print(index .. "." .. group)
      index = index + 1
    end
  end
  return curr_line
end

function M.viewPoints(first, last)
  local text = M.copyTable()[1]
  local labels = {}
  for _, v in ipairs(text) do
    if v:match "^C &CE" or v:match "^F &CP" then
      local label = vim.fn.split(v, ";")[1]:sub(6)
      table.insert(labels, label)
    end
  end
  print " "
  print " "
  for i, v in ipairs(labels) do
    if i >= first and i <= last then
      print(string.format("%d. %s", i, v:gsub("=", ""):gsub("- ", "-")))
    end
  end
end

function M.adjustTitles(shift, fc_chk)
  local text = M.copyTable()[1]
  local new_text = {}
  for _, line in ipairs(text) do
    local title_row = ""
    if line:match "^(T .*)&CC(%d+):(%d+)" then
      line = vim.fn.substitute(line, "%", "%%", "g")
      local title_array = vim.split(line, "&CC", { plain = true })
      local title_pat = "(%d+):(%d+)(.*)"
      for _, col in ipairs(title_array) do
        if col:match(title_pat) then
          local title_chk = col:gsub(title_pat, "%1")
          if fc_chk == tonumber(title_chk) then
            local title_begin = col:gsub(title_pat, "%1")
            local title_end = col:gsub(title_pat, "%2") + shift
            local title_text = col:gsub(title_pat, "%3")
            title_row = title_row .. "&CC" .. title_begin .. ":" .. title_end .. title_text
          elseif fc_chk < tonumber(title_chk) then
            local title_begin = col:gsub(title_pat, "%1") + shift
            local title_end = col:gsub(title_pat, "%2") + shift
            local title_text = col:gsub(title_pat, "%3")
            title_row = title_row .. "&CC" .. title_begin .. ":" .. title_end .. title_text
          else
            local title_text = "&CC" .. col
            title_row = title_row .. title_text
          end
        end
      end
      line = line:gsub("&CC.*", title_row)
    end
    table.insert(new_text, line)
  end
  return new_text
end

function M.adjustGroups(group, shift, ul_chk, fc_chk, nc_start, nc_end, title, last_group)
  local text = M.copyTable()[1]
  local new_text = {}
  for i, line in ipairs(text) do
    if line:match "^(T .*)&CC(%d+):(%d+)" then
      local title_row = ""
      local title_array = vim.split(line, "&CC", { plain = true })
      local title_pat = "^(%d+):(%d+)(.*)"
      local group_chk = 1
      for j, col in ipairs(title_array) do
        if group == 0 then
          if i == ul_chk and j == 1 then
            local title_addition = string.format("&CC%d:%d %s", nc_start, nc_end, title)
            title_row = title_addition
          elseif i == ul_chk + 1 and j == 1 then
            local title_addition = string.format("&CC%d:%d==", nc_start, nc_end)
            title_row = title_addition
          elseif j > 1 then
            local title_begin = col:gsub(title_pat, "%1") + shift
            local title_end = col:gsub(title_pat, "%2") + shift
            local title_text = col:gsub(title_pat, "%3")
            title_row = title_row .. "&CC" .. title_begin .. ":" .. title_end .. title_text
          end
          -- elseif group == #title_array - 1 then
        elseif group == last_group then
          if i == ul_chk and j == #title_array then
            local title_addition = string.format("&CC%d:%d %s", nc_start, nc_end, title)
            title_row = title_row .. "&CC" .. col .. title_addition
          elseif i == ul_chk + 1 and j == #title_array then
            local title_addition = string.format("&CC%d:%d==", nc_start, nc_end)
            title_row = title_row .. "&CC" .. col .. title_addition
          elseif j > 1 then
            local title_text = "&CC" .. col
            title_row = title_row .. title_text
          end
        elseif col:match(title_pat) then
          local title_chk = col:gsub(title_pat, "%1")
          local title_text = ""
          if tonumber(title_chk) > fc_chk then
            if group_chk == 1 then
              local title_addition = ""
              if i == ul_chk then
                title_addition = string.format("&CC%d:%d %s", nc_start, nc_end, title)
              elseif i == ul_chk + 1 then
                title_addition = string.format("&CC%d:%d==", nc_start, nc_end)
              end
              local title_begin = col:gsub(title_pat, "%1") + shift
              local title_end = col:gsub(title_pat, "%2") + shift
              title_text = col:gsub(title_pat, "%3")
              title_row = title_row .. title_addition .. "&CC" .. title_begin .. ":" .. title_end .. title_text
              group_chk = 0
            else
              local title_begin = col:gsub(title_pat, "%1") + shift
              local title_end = col:gsub(title_pat, "%2") + shift
              title_text = col:gsub(title_pat, "%3")
              title_row = title_row .. "&CC" .. title_begin .. ":" .. title_end .. title_text
            end
          else
            title_text = "&CC" .. col
            title_row = title_row .. title_text
          end
        end
      end
      line = line:gsub("&CC.*", title_row)
    end
    table.insert(new_text, line)
  end
  return new_text
end

function M.removeGroups(shift, fc_chk)
  local text = M.copyTable()[1]
  local new_text = {}
  for _, line in ipairs(text) do
    local title_row = ""
    if line:match "^(T .*)&CC(%d+):(%d+)" then
      local title_array = vim.split(line, "&CC", { plain = true })
      local title_pat = "(%d+):(%d+)(.*)"
      for _, col in ipairs(title_array) do
        if col:match(title_pat) then
          local title_chk = col:gsub(title_pat, "%1")
          if fc_chk == tonumber(title_chk) then
          elseif fc_chk < tonumber(title_chk) then
            local title_begin = col:gsub(title_pat, "%1") + shift
            local title_end = col:gsub(title_pat, "%2") + shift
            local title_text = col:gsub(title_pat, "%3")
            title_row = title_row .. "&CC" .. title_begin .. ":" .. title_end .. title_text
          else
            local title_text = "&CC" .. col
            title_row = title_row .. title_text
          end
        end
      end
      line = line:gsub("&CC.*", title_row)
    end
    table.insert(new_text, line)
  end
  return new_text
end

vim.api.nvim_create_user_command("Adjust", M.menu, {})

return M
