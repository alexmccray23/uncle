-- Neovim plugin for setting up summary tables for a question series

M = {}

Data = {}

function M.summaryTable()
  local specLang = vim.fn.input("Summary of... ")
  if specLang == "" then return else specLang = specLang:upper() end
  local totTables = vim.fn.input("\n\nHow many tables?")
  if totTables == "" then return end
  for index = 1, totTables do
    M.parseTable(specLang, index)
  end
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
  local question = ""
  local baseLang = "TOTAL BASE"
  local qualifier = "ALL"
  local qLang = ""
  local spec = ""
  for _, line in ipairs(wholeText) do
    if line:match("^T QUESTION %w+") then
      question = line:gsub("^T QUESTION (%w+):", "Q%1")
    end
    if line:match("^T /(.*)") then
      qLang = line:gsub("^T /(.*)", "%1")
    end
    if line:match("^Q .*") then
      qualifier = line:gsub("^Q (.*)", "%1")
    end
    if line:match("^R &IN2BASE==") then
      baseLang = line:gsub("^R &IN2BASE==(.-);.*", "%1")
    end
    if line:match(specLang) then
      spec = vim.split(line, ';', { plain = true })[2]
    end
  end
  Data[count] = {
    questionText = "R &IN2" .. qLang:upper() .. ";" .. spec,
    qualifierText = baseLang .. ";" .. qualifier .. ";NOPRINT",
  }
  --print(Data[question]['qualifierText'])
  for _,q in ipairs(Data) do
    print(q['questionText'])
  end
end

vim.api.nvim_create_user_command("Summary", M.summaryTable, {})
return M
