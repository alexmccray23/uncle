-- Neovim plugin for setting up multiple-field summary tables for a question series

local M = {}

local Data = {}

function M.menu()
  local choices = {
    { label = "1. Rank by d/s", func = M.get_fields },
    { label = "2. Rank by value", func = M.get_fields },
  }
  for _, choice in ipairs(choices) do
    print(choice.label)
  end
  local input = tonumber(vim.fn.input "Select an option: ")
  if input and input >= 1 and input <= #choices then
    M.summaryTable(input)
  else
    print " Invalid selection"
  end
end

function M.get_fields()
  local rows = tonumber(vim.fn.input "Number of rows: ")
  if rows == "" then
    return
  end
  local fields = {}
  for i = 1, rows do
    local field = vim.fn.input("row #" .. i .. ": ")
    if field == "" then
      return
    end
    fields[i] = field:upper()
  end
  return fields
end

function M.summaryTable(choice)
  for i, _ in ipairs(Data) do
    Data[i] = nil
  end
  local fields = M.get_fields()
  local totTables = vim.fn.input "\n\nHow many tables?: "
  if totTables == "" then
    return
  end
  local nline = vim.fn.line "."
  for index = 1, totTables do
    M.parseTable(fields, index, choice)
  end
  local text = M.summaryTableConstructor()
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + #text, 0 })
end

function M.parseTable(fields, count, choice)
  local wholeText = M.copyTable()
  local qLang = ""
  local qual = ""
  local rqual = ""
  local tqual = ""
  local question = ""
  local questionText = {}
  local qualifierText = {}
  for _, line in ipairs(wholeText) do
    if line:match "^T /(.*)" then
      qLang = line:gsub("^T /(.*)", "%1")
    end
    if line:match "^T QUESTION" then
      question = line:gsub("^T QUESTION (.*):", "%1")
    end
    if choice == 1 then
      questionText[choice] = "R " .. qLang:upper() .. "&UT-;NONE;EX(RD1-RD2) NOSZR VBASE " .. count + 1 .. " NG" .. count .. "* PAG " .. #fields + 1
    else
      questionText[choice] = "R " .. qLang:upper() .. "&UT-;NONE;EX(RD1-RD2) NOSZR VBASE " .. count + 1 .. " NG" .. count .. "@"
    end
    for i = 1, #fields do
      local j = i + choice
      if line:match "^R" and vim.fn.match(line, fields[i]) > 0 and not line:match "D//S" then
        local spec = vim.split(line, ";", { plain = true })[2]
        if vim.fn.match(line, fields[1]) > 0 and choice == 2 then
          questionText[1] = "R --RANK LINE--;" .. spec .. ";NOPRINT VBASE " .. count + 1 .. " NG" .. count .. "* PAG " .. #fields + 2
        end
        questionText[j] = "R   " .. fields[i] .. ";" .. spec .. ";VBASE " .. count + 1 .. " NG" .. count .. "@"
        if qual == "" then
          spec = vim.split(line, ";", { plain = true })[2]
          rqual = vim.split(spec, ",", { plain = true })[1]
          tqual = vim.split(spec, "-", { plain = true })[1]
          if spec:match "^R%(1" then
            local vals = spec:gsub("R%(1!(%d+)", "%1")
            local flds = vim.split(vals, ":", { plain = true })
            local len = tonumber(flds[2]) - tonumber(flds[1]) + 1
            local ext = M.my_repeat("9", len)
            qual = rqual .. ",1:" .. ext .. ")"
            qualifierText = { "Q" .. question .. " BASE;" .. qual .. ";NOPRINT", "" }
          elseif spec:match "^1!" then
            qual = tqual .. "-1:9"
            qualifierText = { "Q" .. question .. " BASE;" .. qual .. ";NOPRINT", "" }
          end
        end
      end
    end
  end
  Data[count] = {
    questionText = questionText,
    qualifierText = qualifierText,
  }
end

function M.summaryTableConstructor()
  local text = { "T Summary of ", "O RANK RANKPCT", "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP" }
  local base = { "TOTAL ASKED;ALL;NOPRINT" }
  for _, data in ipairs(Data) do
    if not M.contains(base, data["qualifierText"][1]) then
      table.insert(base, data["qualifierText"][1])
    end
  end
  for index, value in ipairs(base) do
    if index > 1 then
      table.insert(text, string.format("R   %2d %s", index, value))
    end
  end
  for _, data in ipairs(Data) do
    for _, field in ipairs(data["questionText"]) do
      table.insert(text, field)
    end
  end
  return text
end

function M.copyTable()
  vim.fn.search("^TABLE ", "W")
  local start_line = vim.fn.getcurpos()[2] + 1
  local end_line = vim.fn.search("^\\*\\n", "W")
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  return wholeText
end

function M.contains(table, value)
  for _, v in pairs(table) do
    if v == value then
      return true
    end
  end
  return false
end

function M.my_repeat(pattern, count)
  local string = ""
  for _ = 1, count do
    string = string .. pattern
  end
  return string
end

vim.api.nvim_create_user_command("Sum2", M.menu, {})

return M
