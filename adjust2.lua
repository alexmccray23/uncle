-- Neovim plugin for adding and removing banner columns

local M = {}

local function display_menu(choices, prompt)
  local items = {}
  for _, choice in ipairs(choices) do
    table.insert(items, choice.label)
  end
  vim.ui.select(items, { prompt = prompt or "Select an option:" }, function(_, idx)
    if idx then
      local choice = choices[idx]
      if choice and choice.func then
        choice.func()
      end
    end
  end)
end

function M.menu()
  local choices = {
    { label = "1. Insert point", func = M.insert_column },
    { label = "2. Insert group", func = M.insert_group },
    { label = "3. Delete point", func = M.delete_column },
    { label = "4. Delete group", func = M.delete_group },
  }
  display_menu(choices)
end

local function enhance_picker_items(items)
  local enhanced = {}
  for _, item in ipairs(items) do
    local idx = tonumber(item.index) or item.index or 0
    local label = item.label or ""
    local padded = string.format("%05d", idx)
    table.insert(enhanced, {
      index = idx,
      label = label,
      _match_key = string.format("%s %s", padded, label),
      _display = label ~= "" and string.format("%d. %s", idx, label) or string.format("%d.", idx),
    })
  end
  return enhanced
end

local function select_with_index_priority(items, opts, callback)
  if not items or #items == 0 then
    if callback then
      callback(nil)
    end
    return
  end
  local select_opts = opts and vim.deepcopy(opts) or {}
  local user_format = select_opts.format_item
  select_opts.format_item = function(item)
    if user_format then
      return user_format(item)
    end
    return item._display
  end
  select_opts.matcher = select_opts.matcher or {}
  if not select_opts.matcher.fields then
    select_opts.matcher.fields = { "_match_key" }
  end

  local wrapped_cb = callback and vim.schedule_wrap(callback)
  vim.ui.select(enhance_picker_items(items), select_opts, function(choice, idx)
    if wrapped_cb then
      wrapped_cb(choice, idx)
    end
  end)
end

function M.insert_column()
  M.viewGroups {
    prompt = "\nSelect the group you want to add to:",
    on_select = function(group, curr_line)
      if group == nil then
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      end
      local wholeText, start_line, end_line = unpack(M.copyTable())
      local first_col
      local target_end
      --- @cast wholeText string[]
      for _, line in ipairs(wholeText) do
        if line:match "^(T .*)&CC%d+:%d+==" then
          local group_array = vim.split(line, "==", { plain = true })
          if group < 0 or group > #group_array - 1 then
            print(" Invalid group. Only " .. #group_array - 1 .. " groups total in banner.")
            vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
            return
          end
          local group_pat = "(.-)(%d+):(%d+)"
          local start_str = group_array[group]:gsub(group_pat, "%2")
          local end_str = group_array[group]:gsub(group_pat, "%3")
          first_col = tonumber(start_str)
          target_end = tonumber(end_str) + 1

          local function apply_insert(point)
            if point == nil then
              vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
              return
            end
            local shift = 1
            local new_text = M.adjustTitles(shift, first_col)
            local col = 0
            local cursor_point = 0
            for index, row in ipairs(new_text) do
              if row:match "^C &CE" or row:match "^F &CP" then
                col = col + 1
                if col == point then
                  cursor_point = index
                  table.insert(new_text, index, "C &CE")
                  break
                end
              end
            end
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line - 1, false, new_text)
            vim.api.nvim_win_set_cursor(0, { start_line + cursor_point - 1, 5 })
          end

          M.viewPoints(first_col, target_end - 1, {
            prompt = string.format("\nGroup %d spans %d-%d. Select destination:", group, first_col, target_end),
            extra_entries = {
              { index = target_end, label = "[After last column]" },
            },
            on_select = apply_insert,
          })
          return
        end
      end
      print " No groups available."
      vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
    end,
  }
end

function M.insert_group()
  M.viewGroups {
    prompt = "\nSelect the group to add after (choose 0 to add first):",
    include_zero = true,
    zero_label = "Add as first group",
    on_select = function(group, curr_line)
      if group == nil then
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      end
      local wholeText, start_line, end_line = unpack(M.copyTable())
      local first_col
      local end_col
      local ul_chk = 1
      local last_group
      --- @cast wholeText string[]
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
          local start_str = group_array[group]:gsub(group_pat, "%2")
          local end_str = group_array[group]:gsub(group_pat, "%3")
          first_col = tonumber(start_str)
          end_col = tonumber(end_str)
          break
        end
      end

      local function request_shift()
        vim.ui.input({ prompt = "\nHow many points: " }, function(shift_input)
          local shift = tonumber(shift_input or "")
          if shift == nil then
            vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
            return
          end
          local fc_chk = tonumber(first_col)
          local nc_start = end_col + 1
          local nc_end = end_col + shift

          vim.ui.input({ prompt = "\nWhat is the title?\n" }, function(title_input)
            if title_input == nil then
              vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
              return
            end
            local title = title_input:upper()
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
          end)
        end)
      end

      vim.defer_fn(request_shift, 0)
    end,
  }
end

function M.delete_column()
  M.viewGroups {
    prompt = "\nSelect the group you want to delete from:",
    on_select = function(group, curr_line)
      if group == nil then
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      end
      local wholeText, start_line, end_line = unpack(M.copyTable())
      local first_col
      local end_col
      --- @cast wholeText string[]
      for _, line in ipairs(wholeText) do
        if line:match "^(T .*)&CC%d+:%d+==" then
          local group_array = vim.split(line, "==", { plain = true })
          if group < 0 or group > #group_array - 1 then
            print(" Invalid group. Only " .. #group_array - 1 .. " groups total in banner.")
            vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
            return
          end
          local group_pat = "(.-)(%d+):(%d+)"
          local start_str = group_array[group]:gsub(group_pat, "%2")
          local end_str = group_array[group]:gsub(group_pat, "%3")
          first_col = tonumber(start_str)
          end_col = tonumber(end_str)

          local function apply_delete(point)
            if point == nil then
              vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
              return
            end
            local shift = -1
            local new_text = M.adjustTitles(shift, first_col)
            local col = 0
            local cursor_point = 0
            for index, row in ipairs(new_text) do
              if row:match "^C &CE" then
                col = col + 1
                if col == point then
                  cursor_point = index
                  table.remove(new_text, index)
                  break
                end
              end
            end
            vim.api.nvim_buf_set_lines(0, start_line - 1, end_line - 1, false, new_text)
            vim.api.nvim_win_set_cursor(0, { start_line + cursor_point - 1, 0 })
          end

          M.viewPoints(first_col, end_col, {
            prompt = string.format("\nGroup %d spans %d-%d. Select column to delete:", group, first_col, end_col),
            on_select = apply_delete,
          })
          return
        end
      end
      print " No groups available."
      vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
    end,
  }
end

function M.delete_group()
  M.viewGroups {
    prompt = "\nSelect the group you want to delete:",
    on_select = function(group, curr_line)
      if group == nil then
        vim.api.nvim_win_set_cursor(0, { curr_line, 0 })
        return
      end
      local wholeText, start_line, end_line = unpack(M.copyTable())
      local first_col
      local end_col
      --- @cast wholeText string[]
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
          local start_str = group_array[group]:gsub(group_pat, "%2")
          local end_str = group_array[group]:gsub(group_pat, "%3")
          first_col = tonumber(start_str)
          end_col = tonumber(end_str)
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
    end,
  }
end

function M.copyTable()
  local start_line = vim.fn.getcurpos()[2] + 1
  local end_line = vim.fn.search("^\\*\\n\\|F \\&CP", "W")
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  vim.fn.search("\\_^TABLE ", "b")
  return { wholeText, start_line, end_line }
end

function M.viewGroups(opts)
  opts = opts or {}
  local curr_line = vim.fn.line "."
  vim.fn.search("\\_^TABLE ", "b")
  local text = M.copyTable()[1]
  local titles = {}
  for i = 1, 150 do
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

  local items = {}
  local index = 1
  if opts.include_zero then
    table.insert(items, { index = 0, label = opts.zero_label or "First position" })
  end
  for _, group in ipairs(titles) do
    if group ~= "" then
      table.insert(items, { index = index, label = group })
      index = index + 1
    end
  end

  if #items == 0 then
    if opts.on_select then
      opts.on_select(nil, curr_line)
    end
    return curr_line
  end

  select_with_index_priority(items, {
    prompt = opts.prompt or "Select group:",
  }, function(choice)
    if opts.on_select then
      opts.on_select(choice and choice.index or nil, curr_line)
    end
  end)

  return curr_line
end

function M.viewPoints(first, last, opts)
  opts = opts or {}
  local text = M.copyTable()[1]
  local labels = {}
  for _, v in ipairs(text) do
    if v:match "^C &CE" or v:match "^F &CP" then
      local label = vim.fn.split(v, ";")[1]:sub(6)
      table.insert(labels, label)
    end
  end

  local items = {}
  for i = first, last do
    local label = labels[i]
    if label then
      label = label:gsub("=", ""):gsub("- ", "-")
    else
      label = ""
    end
    table.insert(items, {
      index = i,
      label = label,
    })
  end
  if opts.extra_entries then
    for _, entry in ipairs(opts.extra_entries) do
      local extra = vim.deepcopy(entry)
      extra.label = extra.label or ""
      table.insert(items, extra)
    end
  end

  if #items == 0 then
    if opts.on_select then
      opts.on_select(nil)
    end
    return
  end

  select_with_index_priority(items, {
    prompt = opts.prompt or string.format("Select point (%d-%d):", first, last),
  }, function(choice)
    if opts.on_select then
      opts.on_select(choice and choice.index or nil)
    end
  end)
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

vim.api.nvim_create_user_command("Adjust2", M.menu, {})

return M
