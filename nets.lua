-- Neovim plugin for adding nets to Uncle tables

local M = {}

function M.menu()
  local choices = {
    { label = "1. Generic 2-Way D/S", func = M.one },
    { label = "2. 2-Way D/S",         func = M.two },
    { label = "3. Generic Net",       func = M.three },
    { label = "4. 4-Way D/S",         func = M.four },
    { label = "5. 1-2 MINUS 4-5",     func = M.five },
    { label = "6. Party D/S",         func = M.submenu },
    { label = "7. Education",         func = M.seven },
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

function M.submenu()
  local sub_choices = {
    { label = "6.1. Leaners w/ Total",          func = M.six_one },
    { label = "6.2. Leaner w/ Indep/Undecided", func = M.six_two },
  }

  print(" ")
  print(" ")
  for _, choice in ipairs(sub_choices) do
    print(choice.label)
  end
  local input = tonumber(vim.fn.input("Select a submenu option: "))
  if input and input >= 1 and input <= #sub_choices then
    sub_choices[input].func()
  else
    print("Invalid selection")
  end
end

function M.one()
  local ls = require("luasnip")
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_win_set_cursor(0, { cursor[1], 0 })
  local line = vim.api.nvim_get_current_line()
  line = "ds" .. line:sub(2)
  vim.api.nvim_set_current_line(line)
  vim.api.nvim_win_set_cursor(0, { cursor[1], 2 })
  ls.expand("ds")
end

function M.two()
  local punches = {}
  local start_line = vim.fn.getcurpos()[2] - 1
  vim.api.nvim_win_set_cursor(0, { start_line, 0 })
  local end_line = start_line + 2
  local text = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  for index, line in ipairs(text) do
    punches[index] = vim.split(line, ';', { plain = true })
    punches[index][1] = vim.fn.substitute(punches[index][1], "^R\\s\\+\\(TOTAL \\)\\?", "", "")
    punches[index][1] = vim.fn.substitute(punches[index][1], "&IN2\\|&UT-", "", "")
  end
  local new_line = "R &IN2**D//S (" .. punches[1][1] .. " - " .. punches[2][1] .. ");NONE;EX(RD1-RD2) NOSZR"
  vim.fn.append(vim.fn.line('.'), new_line)
  vim.api.nvim_win_set_cursor(0, { start_line + 2, 0 })
end

function M.three()
  local r_row = {}
  local punches = {}
  local newText = { "" }
  local totRows = tonumber(vim.fn.input("How many rows?"))
  if totRows == nil then return end
  local label = vim.fn.input("Row label?"):upper()
  if label == "" then return end

  local start_line = vim.fn.line('.')
  local text = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line + totRows - 1, false)
  local pattern = "\\(.*\\)\\(-\\|,\\)\\(\\d\\+\\)\\()\\?\\)"
  for i, line in ipairs(text) do
    newText[i] = vim.fn.substitute(line, "^R ", "R   ", "")
    r_row[i] = vim.split(line, ';', { plain = true })
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "^R\\s\\+\\(\\S\\+\\s\\)\\?", "", "")
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "&IN2\\|&UT-", "", "")
    punches[i] = vim.fn.substitute(r_row[i][2], pattern, "\\3", "")
  end
  local pValue1 = vim.fn.substitute(r_row[1][2], pattern, "\\1\\2\\3:" .. punches[#text] .. "\\4", "")

  table.insert(newText, 1, "R TOTAL " .. label .. "&UT-;" .. pValue1)

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline + totRows - 1, false, newText)
  vim.api.nvim_win_set_cursor(0, { nline + 1, 0 })
end

function M.four()
  local r_row = {}
  local punches = {}
  local newText = { "", "", "", }
  local start_line = vim.fn.getcurpos()[2] - 1
  vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
  local end_line = start_line + 4
  local text = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local pattern = "\\(.*\\)\\(-\\|,\\)\\(\\d\\+\\)\\()\\?\\)"
  for i, line in ipairs(text) do
    newText[i] = vim.fn.substitute(line, "^R ", "R   ", "")
    r_row[i] = vim.split(line, ';', { plain = true })
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "^R\\s\\+\\(\\S\\+\\s\\)\\?", "", "")
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "&IN2\\|&UT-", "", "")
    punches[i] = vim.fn.substitute(r_row[i][2], pattern, "\\3", "")
  end
  local pValue1 = vim.fn.substitute(r_row[1][2], pattern, "\\1\\2\\3:" .. punches[2] .. "\\4", "")
  local pValue2 = vim.fn.substitute(r_row[3][2], pattern, "\\1\\2\\3:" .. punches[4] .. "\\4", "")
  local pLabel1 = r_row[1][1]
  local pLabel2 = r_row[3][1]
  pLabel1 = vim.fn.substitute(pLabel1, '^ALWAYS', 'ALWAYS//SOMETIMES', "")
  pLabel1 = vim.fn.substitute(pLabel1, '^GREAT DEAL', 'GREAT DEAL//SOME', "")
  pLabel1 = vim.fn.substitute(pLabel1, '^LOT', 'A LOT//SOME', "")
  pLabel2 = vim.fn.substitute(pLabel2, '^RARELY', 'RARELY//NEVER', "")
  pLabel2 = vim.fn.substitute(pLabel2, '^TOO\\|^VERY', 'NOT', "")
  pLabel2 = vim.fn.substitute(pLabel2, '^MUCH\\|NOT MUCH', 'NOT MUCH//NOTHING', "")
  pLabel2 = vim.fn.substitute(pLabel2, '^THAT', 'NOT', "")
  pLabel2 = vim.fn.substitute(pLabel2, '^LITTLE', 'LITTLE//NOT AT ALL', "")
  if pLabel2 == 'NOT DESCRIBE WELL' then
    pLabel1 = vim.fn.substitute(pLabel1, '^VERY', 'DESCRIBES', "")
    pLabel2 = vim.fn.substitute(pLabel2, '^NOT', "DOESN'T", "")
  end

  table.insert(newText, 1, "R &IN2**D//S (" .. pLabel1 .. " - " .. pLabel2 .. ");NONE;EX(RD1-RD2) NOSZR")
  table.insert(newText, 2, "R TOTAL " .. pLabel1 .. "&UT-;" .. pValue1)
  table.insert(newText, 3, "R TOTAL " .. pLabel2 .. "&UT-;" .. pValue2)

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline + 3, false, newText)
  vim.api.nvim_win_set_cursor(0, { nline + 1, 0 })
end

function M.five()
  local r_row = {}
  local punches = {}
  local newText = { "", "", "", }
  local start_line = vim.fn.getcurpos()[2] - 1
  vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
  local end_line = start_line + 5
  local text = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local pattern = "\\(.*\\)\\(-\\|,\\)\\(\\d\\+\\)\\()\\?\\)"
  for i, line in ipairs(text) do
    if i ~= 3 then
      newText[i] = vim.fn.substitute(line, "^R ", "R   ", "")
    else
      newText[i] = line
    end
    r_row[i] = vim.split(line, ';', { plain = true })
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "^R\\s\\+\\(\\S\\+\\s\\)\\?", "", "")
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "&IN2\\|&UT-", "", "")
    punches[i] = vim.fn.substitute(r_row[i][2], pattern, "\\3", "")
  end
  local pValue1 = vim.fn.substitute(r_row[1][2], pattern, "\\1\\2\\3:" .. punches[2] .. "\\4", "")
  local pValue2 = vim.fn.substitute(r_row[4][2], pattern, "\\1\\2\\3:" .. punches[5] .. "\\4", "")
  local pLabel1 = r_row[1][1]
  local pLabel2 = r_row[4][1]
  pLabel1 = vim.fn.substitute(pLabel1, '^POOR', 'POOR//WORKING', "")
  pLabel1 = vim.fn.substitute(pLabel1, '^INCOME', 'LOW INCOME//WORKING', "")
  pLabel2 = vim.fn.substitute(pLabel2, '^MIDDLE CLASS', 'UPPER//WELL-TO-DO', "")

  table.insert(newText, 1, "R &IN2**D//S (" .. pLabel1 .. " - " .. pLabel2 .. ");NONE;EX(RD1-RD2) NOSZR")
  table.insert(newText, 2, "R TOTAL " .. pLabel1 .. "&UT-;" .. pValue1)
  table.insert(newText, 3, "R TOTAL " .. pLabel2 .. "&UT-;" .. pValue2)
  local punch3 = table.remove(newText, 6)
  table.insert(newText, 8, punch3)

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline + 4, false, newText)
  vim.api.nvim_win_set_cursor(0, { nline + 1, 0 })
end

function M.six_one()
  local r_row = {}
  local punches = {}
  local newText = { "", "", "", }
  local start_line = vim.fn.getcurpos()[2] - 1
  vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
  local end_line = start_line + 7
  local text = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local pattern = "\\(.*\\)\\(-\\|,\\)\\(\\d\\+\\)\\()\\?\\)"
  for i, line in ipairs(text) do
    if i ~= 4 then
      newText[i] = vim.fn.substitute(line, "^R ", "R   \\&IN2", "")
    else
      newText[i] = line
    end
    r_row[i] = vim.split(line, ';', { plain = true })
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "^R\\s\\+\\(\\S\\+\\s\\)\\?", "", "")
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "&IN2\\|&UT-", "", "")
    punches[i] = vim.fn.substitute(r_row[i][2], pattern, "\\3", "")
  end
  local pValue1 = vim.fn.substitute(r_row[1][2], pattern, "\\1\\2\\3:" .. punches[3] .. "\\4", "")
  local pValue2 = vim.fn.substitute(r_row[5][2], pattern, "\\1\\2\\3:" .. punches[7] .. "\\4", "")
  local pLabel1 = r_row[1][1]
  local pLabel2 = r_row[7][1]

  table.insert(newText, 1, "R &IN2**D//S (" .. pLabel1 .. " - " .. pLabel2 .. ");NONE;EX(RD1-RD2) NOSZR")
  table.insert(newText, 2, "R TOTAL " .. pLabel1 .. "&UT-;" .. pValue1)
  table.insert(newText, 3, "R TOTAL " .. pLabel2 .. "&UT-;" .. pValue2)
  local punch3 = table.remove(newText, 7)
  table.insert(newText, 10, punch3)

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline + 6, false, newText)
  vim.api.nvim_win_set_cursor(0, { nline + 1, 0 })
end

function M.six_two()
  local r_row = {}
  local punches = {}
  local newText = { "", "", "", "" }
  local start_line = vim.fn.getcurpos()[2] - 1
  vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
  local end_line = start_line + 7
  local text = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local pattern = "\\(.*\\)\\(-\\|,\\)\\(\\d\\+\\)\\()\\?\\)"
  for i, line in ipairs(text) do
    newText[i] = vim.fn.substitute(line, "^R ", "R   \\&IN2", "")
    r_row[i] = vim.split(line, ';', { plain = true })
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "^R\\s\\+\\(\\S\\+\\s\\)\\?", "", "")
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "&IN2\\|&UT-", "", "")
    punches[i] = vim.fn.substitute(r_row[i][2], pattern, "\\3", "")
  end
  local pValue1 = vim.fn.substitute(r_row[1][2], pattern, "\\1\\2\\3:" .. punches[2] .. "\\4", "")
  local pValue2 = vim.fn.substitute(r_row[6][2], pattern, "\\1\\2\\3:" .. punches[7] .. "\\4", "")
  local pValue3 = vim.fn.substitute(r_row[3][2], pattern, "\\1\\2\\3:" .. punches[5] .. "\\4", "")
  local pLabel1 = r_row[1][1]
  local pLabel2 = r_row[7][1]

  table.insert(newText, 1, "R &IN2**D//S (" .. pLabel1 .. " - " .. pLabel2 .. ");NONE;EX(RD1-RD2) NOSZR")
  table.insert(newText, 2, "R TOTAL " .. pLabel1 .. "&UT-;" .. pValue1)
  table.insert(newText, 3, "R TOTAL " .. pLabel2 .. "&UT-;" .. pValue2)
  table.insert(newText, 4, "R TOTAL LEAN//INDEPENDENT&UT-;" .. pValue3)

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline + 6, false, newText)
  vim.api.nvim_win_set_cursor(0, { nline + 1, 0 })
end

function M.seven()
  local r_row = {}
  local punches = {}
  local newText = { "", "", "", "" }
  local start_line = vim.fn.getcurpos()[2] - 1
  vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
  local end_line = start_line + 7
  local text = vim.api.nvim_buf_get_lines(0, start_line, end_line, false)
  local pattern = "\\(.*\\)\\(-\\|,\\)\\(\\d\\+\\)\\()\\?\\)"
  local pValue1 = ""
  local pValue2 = ""
  local pValue3 = ""
  local hs_end = nil
  local sc_start = nil
  local sc_end = nil
  for i, line in ipairs(text) do
    if not (line:match("DON'T KNOW") or line:match("REFUSED")) then
      newText[i] = vim.fn.substitute(line, "^R ", "R   \\&IN2", "")
    else
      newText[i] = line
    end
    r_row[i] = vim.split(line, ';', { plain = true })
    --r_row[i][1] = vim.fn.substitute(r_row[i][1], "^R\\s\\+\\(\\S\\+\\s\\)\\?", "", "")
    r_row[i][1] = vim.fn.substitute(r_row[i][1], "&IN2\\|&UT-", "", "")
    punches[i] = vim.fn.substitute(r_row[i][2], pattern, "\\3", "")
    if vim.fn.match(line, "\\(GRADUATED HIGH SCHOOL\\)\\|\\(HIGH SCHOOL GRADUATE\\)") >= 0 then
      if i == 1 then
        pValue1 = vim.fn.substitute(r_row[i][2], pattern, "\\1\\2" .. punches[i] .. "\\4", "")
        hs_end = tonumber(vim.fn.substitute(r_row[i][2], pattern, "\\3", ""))
      else
        pValue1 = vim.fn.substitute(r_row[i][2], pattern, "\\1\\2" .. punches[1] .. ":\\3\\4", "")
        hs_end = tonumber(vim.fn.substitute(r_row[i][2], pattern, "\\3", ""))
      end
    elseif vim.fn.match(line, '\\(COLLEGE GRADUATE\\)\\|\\(GRADUATED COLLEGE\\)\\|\\(BACHELOR\\)') >= 0 then
      sc_start = tonumber(hs_end) + 1
      sc_end = vim.fn.str2nr(punches[i]) - 1
      if sc_start == sc_end then
        pValue2 = vim.fn.substitute(r_row[i][2], pattern, "\\1\\2" .. punches[i] .. "\\4", "")
      else
        pValue2 = vim.fn.substitute(r_row[i][2], pattern, "\\1\\2" .. sc_start .. ":" .. sc_end .. "\\4", "")
      end
    elseif vim.fn.match(line, "\\(POST\\(-\\| \\)GRADUATE\\)\\|\\(DOCTOR\\)\\|\\(PROFESSIONAL\\)") >= 0 then
      pValue3 = vim.fn.substitute(r_row[i][2], pattern, "\\1\\2" .. sc_end + 1 .. ":\\3\\4", "")
    end
  end

  table.insert(newText, 1, "R HIGH SCHOOL OR LESS&UT-;" .. pValue1)
  table.insert(newText, 2, "R SOME COLLEGE&UT-;" .. pValue2)
  table.insert(newText, 3, "R COLLEGE+&UT-;" .. pValue3)

  local nline = vim.fn.line('.')
  vim.api.nvim_buf_set_lines(0, nline - 1, nline + 6, false, newText)
  vim.api.nvim_win_set_cursor(0, { nline, 0 })
end

vim.api.nvim_create_user_command("Nets", M.menu, {})

return M
