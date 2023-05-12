-- Neovim plugin for shifting banner titles to fit above their columns

local M = {}

function M.copyTable()
  local start_line = vim.fn.getcurpos()[2]
  local end_line = vim.fn.search('^\\*\\n\\|F \\&CP', 'W')
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  return { wholeText, start_line, end_line }
end

function M.getColumnWidths()
  local wholeText = M.copyTable()[1]
  local columnWidth = {}
  local o_colw = nil
  for _, line in ipairs(wholeText) do
    if line:match("O FORMAT") then
      o_colw = line:gsub("^(O FORMAT 27 )(%d)(.*)", "%2")
    elseif line:match("^C %&CE") then
      local colw = nil
      local line_split = vim.split(line, ";", { plain = true })
      if #line_split > 2 and line_split[3]:match("COLW %d") then
        colw = line_split[3]:gsub("(.*)(COLW )(%d)(.*)", "%3")
      else
        colw = o_colw
      end
      table.insert(columnWidth, colw)
    end
  end
  return columnWidth
end

function M.titleCheck()
  local titleRow = {}
  local upperRow = {}
  local reducedRow = {}
  local text = M.copyTable()[1][1]
  local columnWidth = M.getColumnWidths()
  --text = text:gsub("^T ", "")
  text = text:gsub("%&CC(%d+):(%d+)", "|&CC%1:%2|")
  local titleArray = vim.split(text, "|", { plain = true })
  local total_width = 0
  for index, value in ipairs(titleArray) do
    if index % 2 == 0 then
      total_width = 0
      local range = value:gsub("%&CC", "")
      local v_check = vim.split(range, ":")
      for col = tonumber(v_check[1]), tonumber(v_check[2]) do
        total_width = total_width + columnWidth[col]
        if col ~= tonumber(v_check[2]) then
          total_width = total_width + 1
        end
      end
      table.insert(reducedRow, value)
    elseif index % 2 == 1 then
      local text_width = 0
      local temp = value:gsub("//", "/")
      temp = temp:gsub("%&&", "&")
      temp = temp:gsub("^%s+", "")
      text_width = #temp
      local move = 0
      if index > 1 and text_width > total_width then
        move = vim.fn.confirm(temp .. " is too wide by " .. text_width - total_width .. ". Move?", "&Yes\n&No\n&Cancel")
        if move == 3 then
          return
        elseif move == 1 then
          local reduce = ""
          local replace = ""
          reduce = temp:gsub("/", "/ ")
          replace = value:gsub("//", "// ")
          reduce = vim.fn.substitute(value, "S/ R/ H/", "S/R/H", "g")
          replace = vim.fn.substitute(value, "S// R// H//", "S//R//H", "g")
          local replace_array = vim.split(replace, " +", { plain = false, trimempty = true })
          local reduce_array = vim.split(reduce, " +", { plain = false, trimempty = true })
          local subtract_temp = text_width
          for i = 1, #reduce_array do
            local new_title_row = {}
            local trimmed_title_row = {}
            local new_title_row2 = ""
            local trimmed_title_row2 = ""
            subtract_temp = subtract_temp - #reduce_array[i]
            for _, v in ipairs({ unpack(replace_array, 1, i) }) do
              table.insert(new_title_row, v)
            end
            for _, v in ipairs({ unpack(replace_array, i + 1) }) do
              table.insert(trimmed_title_row, v)
            end
            if subtract_temp <= total_width or (i == #reduce_array - 1 and #trimmed_title_row == 1) then
              if #trimmed_title_row ~= 0 then
                new_title_row2 = table.concat(new_title_row, " ")
                trimmed_title_row2 = table.concat(trimmed_title_row, " ")
                table.insert(upperRow, titleArray[index - 1] .. " " .. new_title_row2)
                table.insert(reducedRow, " " .. trimmed_title_row2)
              end
              break
            end
          end
        else
          table.insert(reducedRow, value)
        end
      else
        table.insert(reducedRow, value)
      end
    end
  end
  if #upperRow > 0 then
    titleRow[1] = "T " .. table.concat(upperRow, "")
    titleRow[2] = table.concat(reducedRow, "")
  else
    titleRow[1] = table.concat(reducedRow, "")
  end
  return titleRow
end

function M.replaceTitles()
  local text = M.titleCheck()
  local nline = M.copyTable()[2]
  if text ~= nil then
    vim.api.nvim_buf_set_lines(0, nline - 1, nline, false, text)
    vim.api.nvim_win_set_cursor(0, { nline, 0 })
  end
end

vim.api.nvim_create_user_command("Titles", M.replaceTitles, {})

return M
