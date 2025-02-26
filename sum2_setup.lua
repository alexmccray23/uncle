-- Neovim plugin for setting up multiple-field summary tables for a question series

local M = {}

local Data = {}

function M.menu()
  local choices = {
    { label = "1. Rank by d/s" },
    { label = "2. Rank by value" },
  }
  for _, choice in ipairs(choices) do
    print(choice.label)
  end
  local input = M.get_user_input("Select an option: ", function(input)
    return M.validate_range(input, 1, #choices)
  end)
  if input then
    M.summaryTable(tonumber(input))
  else
    vim.notify("Invalid selection", vim.log.levels.ERROR)
  end
end

function M.get_user_input(prompt, validator)
  local input = vim.fn.input(prompt)
  if validator then
    return validator(input) and input or nil
  end
  return input
end

function M.validate_number(input)
  return tonumber(input) ~= nil
end

function M.validate_range(input, min, max)
  local num = tonumber(input)
  return num and num >= min and num <= max
end

function M.get_fields()
  local rows = M.get_user_input("Number of rows: ", M.validate_number)
  if not rows then
    return
  end

  local fields = {}
  for i = 1, rows do
    local field = M.get_user_input("row #" .. i .. ": ")
    if field == "" then
      return
    end
    fields[i] = field:upper()
  end
  return fields
end

function M.summaryTable(choice)
  Data = {} -- Reset Data
  local fields = M.get_fields()
  if not fields then
    return
  end

  local totTables = M.get_user_input("\n\nHow many tables?: ", M.validate_number)
  if not totTables then
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
  local qLang, qual, question = "", "", ""
  local questionText, qualifierText = {}, {}

  for _, line in ipairs(wholeText) do
    if line:match "^T /(.*)" then
      qLang = line:match "^T /(.*)"
    elseif line:match "^T QUESTION" then
      question = line:match "^T QUESTION (.*):"
    end

    if choice == 1 then
      questionText[choice] = string.format(
        "R %s&UT-;NONE;EX(RD1-RD2) NOSZR VBASE %d NG%d* PAG %d",
        qLang:upper(),
        count + 1,
        count,
        #fields + 1
      )
    else
      questionText[choice] =
        string.format("R %s&UT-;NONE;EX(RD1-RD2) NOSZR VBASE %d NG%d@", qLang:upper(), count + 1, count)
    end

    for i = 1, #fields do
      if
        line:match "^R"
        and vim.fn.match(line, fields[i]) > 0
        and not line:match "HP NOVP"
        and not line:match "D//S"
        and questionText[i + choice] == nil
      then
        local spec = vim.split(line, ";", { plain = true })[2]
        if vim.fn.match(line, fields[1]) > 0 and choice == 2 then
          questionText[1] =
            string.format("R --RANK LINE--;%s;NOPRINT VBASE %d NG%d* PAG %d", spec, count + 1, count, #fields + 2)
        end
        questionText[i + choice] = string.format("R   %s;%s;VBASE %d NG%d@", fields[i], spec, count + 1, count)

        if qual == "" then
          if spec:match "^R%(1" then
            local rqual = vim.split(spec, ",", { plain = true })[1]
            local vals = rqual:gsub("R%(1!(%d+)", "%1")
            local flds = vim.split(vals, ":", { plain = true })
            local len = tonumber(flds[2]) - tonumber(flds[1]) + 1
            qual = string.format("%s,1:%s)", rqual, string.rep("9", len))
            qualifierText = { string.format("Q%s BASE;%s;NOPRINT", question, qual) }
          elseif spec:match "^1!" then
            qual = string.format("%s-1:9", vim.split(spec, "-", { plain = true })[1])
            qualifierText = { string.format("Q%s BASE;%s;NOPRINT", question, qual) }
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
  for i, data in ipairs(Data) do
    for _, field in ipairs(data.qualifierText) do
      table.insert(text, string.format("R   %2d %s", i + 1, field))
    end
  end
  for _, data in ipairs(Data) do
    for _, field in ipairs(data.questionText) do
      table.insert(text, field)
    end
  end
  return text
end

function M.copyTable()
  vim.fn.search("^TABLE ", "W")
  local start_line = vim.fn.getcurpos()[2] + 1
  local end_line = vim.fn.search("^\\*\\n", "W")
  return vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
end

vim.api.nvim_create_user_command("Sum2", M.menu, {})

return M
