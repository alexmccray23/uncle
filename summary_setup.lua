-- Neovim plugin for setting up summary tables for a question series

local M = {}

local Data = {}

function M.summaryTable()
  for i, _ in ipairs(Data) do
    Data[i] = nil
  end
  local specLang = vim.fn.input "Summary of?: "
  if specLang == "" then
    return
  else
    specLang = specLang:upper()
  end
  local totTables = vim.fn.input "\n\nHow many tables?: "
  if totTables == "" then
    return
  end
  local nline = vim.fn.line "."
  for index = 1, totTables do
    M.parseTable(specLang, index)
  end
  local text = M.summaryTableConstructor(specLang)
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + #text, 0 })
end

function M.copyTable()
  vim.fn.search("^TABLE ", "W")
  local start_line = vim.fn.getcurpos()[2] + 1
  local end_line = vim.fn.search("^\\*\\n", "W")
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  return wholeText
end

function M.parseTable(specLang, count)
  local wholeText = M.copyTable()
  local qual = "ALL"
  local question = ""
  local qLang = ""
  local spec = ""
  local rqual = ""
  local tqual = ""
  local fdp = 2
  local qualifierText = {}
  for _, line in ipairs(wholeText) do
    if line:match "^T /(.*)" then
      qLang = line:gsub("^T /(.*)", "%1")
    end
    if line:match "^T QUESTION" then
      question = line:gsub("^T QUESTION (.*):", "%1")
    end
    if line:match "^R" and vim.fn.match(line, specLang) > 0 and spec == "" and not line:match "D//S" then
      spec = vim.split(line, ";", { plain = true })[2]
      rqual = vim.split(spec, ",", { plain = true })[1]
      tqual = vim.split(spec, "-", { plain = true })[1]
      if rqual:match "^R%(1" then
        local vals = rqual:gsub("R%(1!(%d+)", "%1")
        local flds = vim.split(vals, ":", { plain = true })
        local len = tonumber(flds[2]) - tonumber(flds[1]) + 1
        local ext = M.my_repeat("9", len)
        qual = rqual .. ",1:" .. ext .. ")"
        qualifierText = { "Q" .. question .. " BASE;" .. qual .. ";NOPRINT", "", fdp }
      elseif tqual:match "^1!" then
        qual = tqual .. "-1:9"
        qualifierText = { "Q" .. question .. " BASE;" .. qual .. ";NOPRINT", "", fdp }
      elseif spec:match "^A%(" then
        local fst = spec:gsub("A%(1?!?(%d-):(%d-)%).*", "%1")
        local snd = spec:gsub("A%(1?!?(%d-):(%d-)%).*", "%2")
        local len = tonumber(snd) - tonumber(fst) + 1
        fdp = vim.fn.max { fdp - len + 1, 0 }
        qualifierText = { "TOTAL ASKED;ALL;NOPRINT", "", fdp }
      elseif spec:match "^PC%(" then
        local fst = spec:gsub("PC%(1?!?(%d-):(%d-), 50%).*", "%1")
        local snd = spec:gsub("PC%(1?!?(%d-):(%d-), 50%).*", "%2")
        local len = tonumber(snd) - tonumber(fst) + 1
        fdp = vim.fn.max { fdp - len + 1, 0 }
        qualifierText = { "TOTAL ASKED;ALL;NOPRINT", "", fdp }
      end
    end
  end
  Data[count] = {
    questionText = { "R &IN2" .. qLang:upper() .. ";" .. spec, "", fdp },
    qualifierText = qualifierText,
  }
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

function M.row_option(specLang, data)
  local option = ""
  if specLang == "MEAN" or specLang == "MEDIAN" then
    option = ";FDP " .. data["questionText"][3]
  else
    option = ";VBASE " .. data["questionText"][2]
  end
  return option
end

function M.summaryTableConstructor(specLang)
  local baseCount = 2
  local text = { "T Summary of " .. specLang, "O RANK RANKPCT", "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP" }
  local base = { "TOTAL ASKED;ALL;NOPRINT" }
  for _, data in ipairs(Data) do
    if not M.contains(base, data["qualifierText"][1]) then
      table.insert(base, data["qualifierText"][1])
      data["questionText"][2] = baseCount
      baseCount = baseCount + 1
    else
      for i, v in ipairs(base) do
        if v == data["qualifierText"][1] then
          data["questionText"][2] = i
        end
      end
    end
  end
  for index, value in ipairs(base) do
    if index > 1 then
      table.insert(text, string.format("R   %2d %s", index, value))
    end
  end
  for _, data in ipairs(Data) do
    table.insert(text, data["questionText"][1] .. M.row_option(specLang, data))
  end
  return text
end

vim.api.nvim_create_user_command("Summary", M.summaryTable, {})
return M
