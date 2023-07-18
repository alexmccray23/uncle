-- Neovim plugin for setting up summary tables for a question series

local M = {}

local Data = {}

function M.summaryTable()
  for i, _ in ipairs(Data) do Data[i] = nil end
  local specLang = vim.fn.input("Summary of?: ")
  if specLang == "" then return else specLang = specLang:upper() end
  local totTables = vim.fn.input("\n\nHow many tables?: ")
  if totTables == "" then return end
  local nline = vim.fn.line('.')
  for index = 1, totTables do
    M.parseTable(specLang, index)
  end
  local text = M.summaryTableConstructor(specLang)
  vim.api.nvim_buf_set_lines(0, nline, nline, false, text)
  vim.api.nvim_win_set_cursor(0, { nline + #text, 0 })
end

function M.copyTable()
  vim.fn.search("^TABLE ", 'W')
  local start_line = vim.fn.getcurpos()[2] + 1
  local end_line = vim.fn.search('^\\*\\n', 'W')
  local wholeText = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line - 1, false)
  return wholeText
end

function M.parseTable(specLang, count)
  local wholeText = M.copyTable()
  local baseLang = "TOTAL BASE"
  local qualifier = "ALL"
  local qLang = ""
  local spec = ""
  for _, line in ipairs(wholeText) do
    if line:match("^T /(.*)") then
      qLang = line:gsub("^T /(.*)", "%1")
    end
    if line:match("^Q .*") then
      qualifier = line:gsub("^Q (.*)", "%1")
    end
    if line:match("^R &IN2BASE==") then
      baseLang = line:gsub("^R &IN2BASE==(.-);.*", "%1")
    end
    if line:match("^R .-" .. specLang) and spec == "" and not line:match("D//S") then
      spec = vim.split(line, ';', { plain = true })[2]
    end
  end
  Data[count] = {
    questionText = { "R &IN2" .. qLang:upper() .. ";" .. spec, "" },
    qualifierText = { baseLang .. ";" .. qualifier .. ";NOPRINT", "" },
  }
end

function M.contains(table, value)
  for _, v in pairs(table) do
    if v == value then return true end
  end
  return false
end

function M.summaryTableConstructor(specLang)
  local baseCount = 2
  local text = { "T Summary of " .. specLang,
    "O RANK RANKPCT",
    "R &IN2BASE==TOTAL SAMPLE;ALL;HP NOVP",
  }
  local base = { "TOTAL SAMPLE;ALL;NOPRINT", }
  for _, data in ipairs(Data) do
    if not M.contains(base, data['qualifierText'][1]) then
      table.insert(base, data['qualifierText'][1])
      data['questionText'][2] = baseCount
      baseCount = baseCount + 1
    else
      for i, v in ipairs(base) do
        if v == data['qualifierText'][1] then
          data['questionText'][2] = i
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
    table.insert(text, data['questionText'][1] .. ";VBASE " .. data['questionText'][2])
  end
  return text
end

vim.api.nvim_create_user_command("Summary", M.summaryTable, {})
return M
